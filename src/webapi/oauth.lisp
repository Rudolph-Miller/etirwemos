(in-package :baihu)

#|
OAuth 用のライブラリです。

Contents
--------
1. OAuth クラス
2. リクエスト・トークン
3. プロバイダの認証画面のURI と CALLBACK
4. アクセス・トークン

|#


;;;;;
;;;;; OAuth クラス
;;;;;
;; oauth の情報を保持するクラスです。
(defclass oauth ()
  ((consumer-key            :accessor consumer-key           :initarg :consumer-key           :initform nil)
   (consumer-secret         :accessor consumer-secret        :initarg :consumer-secret        :initform nil)
   (request-token-url       :accessor request-token-url      :initarg :request-token-url      :initform nil)
   (authorize-url           :accessor authorize-url          :initarg :authorize-url          :initform nil)
   (access-token-url        :accessor access-token-url       :initarg :access-token-url       :initform nil)
   (callback-url            :accessor callback-url           :initarg :callback-url           :initform nil)
   (access-token-table      :accessor access-token-table     :initarg :access-token-table     :initform nil)
   ;; これは mysql のプロシージャ名を保持しとくんじゃね。
   (mysql-procedure-update  :accessor mysql-procedure-update :initarg :mysql-procedure-update :initform nil)
   (mysql-procedure-delete  :accessor mysql-procedure-delete :initarg :mysql-procedure-delete :initform nil)
   ;; user かぁ 森羅 にしたらいらんなぁ。
   (user-data-id            :accessor user-data-id           :initarg :user-data-id           :initform nil)
   (user-data-name          :accessor user-data-name         :initarg :user-data-name         :initform nil)))


;; こりゃぁ何じゃったじゃろうか。
;; provider は :twitter とかそんな名前じゃったと思うわ。
;; oauth を pool するとな？
;; あ、下のクラスか。
;; oauth に関する情報をクラスにして蓄積するんじゃね。
;; こりゃぁ、いつロードするんじゃろうか。恐らく DB(mysql)からなんじゃろうけど。
(defvar *oauth-pool* (make-hash-table))
(defun oauth-set (provider oauth &key (pool *oauth-pool*))
  (setf (gethash provider pool) oauth))
(defun oauth-get (provider &key (pool *oauth-pool*))
  (gethash (if (keywordp provider)
               provider
               (intern-keyword (format nil "~a" provider)))
           pool))


;;
;; 2. リクエスト・トークン
;;
(defvar *request-token-pool* (make-hash-table :test 'equalp))

(defun load-request-token (provider callback-uri)
  (let ((oauth (oauth-get provider)))
    (assert oauth)
    (cl-oauth:obtain-request-token (request-token-url oauth)
                                   (cl-oauth:make-consumer-token :key    (consumer-key  oauth)
                                                                 :secret (consumer-secret   oauth))
                                   :callback-uri (format nil "~a/?oauth_searvice=~a" callback-uri provider))))

(defgeneric save-request-token-key (provider token-key))
(defmethod save-request-token-key (provider token-key)
  (assert provider)
  (assert token-key)
  (format nil "~a@~a" token-key provider))

(defgeneric save-request-token-key (provider token))
(defmethod save-request-token-key (provider (token cl-oauth:request-token))
  (assert provider)
  (assert token)
  (let ((token-key (hunchentoot:url-decode (cl-oauth:token-key token))))
    (save-request-token-key provider token-key)))


(defgeneric save-request-token (provider token))
(defmethod save-request-token (provider (token cl-oauth:request-token))
  (when (and provider token)
    (setf (gethash (save-request-token-key provider token) *request-token-pool*)
          token)))

(defun get-request-token-at (provider token-key)
  "*request-token-pool* から リクエストトークンKEY で リクエストトークンを取得する。"
  (when (and provider token-key)
    (gethash (save-request-token-key provider token-key)
             *request-token-pool*)))

(defun get-request-token-function (provider)
  (cond ((eq :twitter provider) #'(lambda (token-key) (get-request-token-at :twitter token-key)))
        ((eq :hatena  provider) #'(lambda (token-key) (get-request-token-at :hatena token-key)))
        (t (error "このプロバイダは対応していません。プロバイダ=~a" provider))))

(defun clear-request-token-pool ()
  "*request-token-pool* の リクエストトークンを全て削除する。"
  (setf *request-token-pool* (make-hash-table :test 'equalp)))


;;;;;
;;;;; 3. プロバイダの認証画面のURI と CALLBACK
;;;;;
(defgeneric oauth-login-uri (provider request-token))
(defmethod oauth-login-uri (provider (request-token cl-oauth:request-token))
  (let ((oauth (oauth-get provider)))
    (save-request-token provider request-token)
    (let ((auth-uri (cl-oauth:make-authorization-uri (authorize-url oauth)
                                                     request-token)))
      (format nil "~a" (puri:uri auth-uri)))))


(defun oauth-callback-p (val)
  "oauth からのコールバックかどうかを判定する関数じゃね。
プロバイダ(twitterなど)の認証画面から帰ってきたときに、query paramに provide がセットされているんよ。
それを引数にして単純に返しとるだけじゃね。
もう少し盛ろうと思っとったんじゃろうね。"
  (if val t nil))


;;;;;
;;;;; アクセス・トークン
;;;;;
(defgeneric get-access-token (provider request-token))
(defmethod get-access-token (provider (request-token cl-oauth:request-token))
  "承認されたリクエストトークンを エンドポイント に遅り、アクセストークンを取得する。"
  (let ((oauth (oauth-get provider)))
    (assert oauth)
    (cl-oauth:obtain-access-token (access-token-url oauth) request-token)))

(defgeneric save-access-token (access-token parson provider))
(defmethod save-access-token ((access-token cl-oauth:access-token) parson provider)
  "取得したアクセストークンをDBに保管します。iwasaki"
  (let* ((user-data (cl-oauth:token-user-data access-token))
         (oauth     (oauth-get provider))
         (proc      (mysql-procedure-update oauth))
         (user-id   (user-data-id oauth))
         (user-name (user-data-name oauth)))
    (simple-sql-call (sql-gen ("CALL `baihu`.`~a`(@ret,'~a','~a','~a','~a','~a','~a')")
                              proc
                              parson
                              provider
                              (cl-oauth:token-key     access-token)
                              (cl-oauth:token-secret  access-token)
                              (assoc-str-val user-id  user-data)
                              (hunchentoot:url-decode (assoc-str-val user-name user-data))))))

(defun delete-access-token (provider parson user)
  (let ((oauth (oauth-get provider)))
    (simple-sql-call
     (sql-gen ("CALL `baihu`.`~a`(@ret,'~a','~a')")
              (mysql-procedure-delete oauth)
              parson
              user))))

(defun oauth-user-access-token (provider parson &key user)
  "DBに保管した アクセストークンKEY と SECRET で アクセストークンを作成し返します。"
  (declare (ignore user))
  (let ((oauth (oauth-get provider)))
    (when parson
      (let ((rec (car (simple-sql-select
                       (sql-gen (" SELECT `token-key` "
                                 "      , `token-secret` "
                                 "   FROM `~a` "
                                 "  WHERE `parson-id` = '~a'; ")
                                (access-token-table oauth)
                                parson)))))
        (oauth:make-access-token :consumer (oauth:make-consumer-token
                                            :key    (consumer-key oauth)
                                            :secret (consumer-secret oauth))
                                 :key    (oauth:url-encode (cdr (assoc :|token-key| rec)))
                                 :secret (cdr (assoc :|token-secret| rec)))))))

(defun test-access-token (provider key secret )
  (let ((consumer  (oauth-get provider)))
    (assert consumer)
    (oauth:make-access-token :consumer (oauth:make-consumer-token
                                        :key    (consumer-key    consumer)
                                        :secret (consumer-secret consumer))
                             :key    (oauth:url-encode key)
                             :secret secret)))
