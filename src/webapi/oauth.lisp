(in-package :etirwemos)

#|

OAuth 用のライブラリなんよ。
主にデータ保管のコードです。
データ保管先は shinrabanshou を利用しています。

|#


;;;;;
;;;;; People Class
;;;;;
(defclass people (shinra:node)
  ((code :documentation ""
         :accessor code
         :initarg :code)
   (name :documentation ""
         :accessor name
         :initarg :name))
  (:documentation "OAuth に限らずユーザーを扱うクラスです。
どこのユーザーかは関係で表現しようと思います。"))


(defgeneric get-people (code &key pool object-class)
  (:documentation "pool から code の値で people を取得します。
将来的にpeople の居場所の指定が必須になります。")
  (:method ((code string) &key (pool *pool*) (object-class 'people))
    (first (up:find-object-with-slot pool object-class 'code code))))


(defgeneric tx-make-people (pool code name)
  (:documentation "森羅上に people を保管します。
ただ、people 単体で作成することはないので、一時的な内容です。")
  (:method ((pool shinra:banshou) code name)
    (shinra:tx-make-node pool 'people
                         'code code
                         'name name)))



;;;;;
;;;;; OAuth プロバイダ クラス
;;;;;
(defclass oauth-provider (shinra:node)
  ((code               :documentation ""
                       :accessor code               :initarg :code)
   (consumer-key       :documentation ""
                       :accessor consumer-key       :initarg :consumer-key)
   (consumer-secret    :documentation ""
                       :accessor consumer-secret    :initarg :consumer-secret)
   (request-token-url  :documentation ""
                       :accessor request-token-url  :initarg :request-token-url)
   (authorize-url      :documentation ""
                       :accessor authorize-url      :initarg :authorize-url)
   (access-token-url   :documentation ""
                       :accessor access-token-url   :initarg :access-token-url)
   (user-data-id       :documentation ""
                       :accessor user-data-id       :initarg :user-data-id)
   (user-data-name     :documentation ""
                       :accessor user-data-name     :initarg :user-data-name))
  (:documentation "OAuth のプロバイダの情報を保持するクラスです。
今後は cl-oauth の class:token を継承予定です。"))

(defgeneric get-oauth-provider (code &key pool object-class)
  (:documentation "oauth-provider を shinra から取得するよ。")
  (:method ((code symbol) &key (pool *pool*) (object-class 'oauth-provider))
    (first (up:find-object-with-slot pool object-class 'code code)))
  (:method ((code string) &key (pool *pool*) (object-class 'oauth-provider))
    (get-oauth-provider (intern-keyword code) :pool pool :object-class object-class)))


(defgeneric tx-make-oauth-provider (pool code consumer-key consumer-secret
                                         request-token-url authorize-url access-token-url
                                         user-data-id user-data-name
                                         &key object-class)
  (:documentation "森羅上に oauth-provider を保管します。")
  (:method ((pool shinra:banshou)
            code consumer-key consumer-secret
            request-token-url authorize-url access-token-url
            user-data-id user-data-name
            &key (object-class 'oauth-provider))
    (shinra:tx-make-node pool object-class
                         'code               code
                         'consumer-key       consumer-key
                         'consumer-secret    consumer-secret
                         'request-token-url  request-token-url
                         'authorize-url      authorize-url
                         'access-token-url   access-token-url
                         'user-data-id       user-data-id
                         'user-data-name     user-data-name)))



;;;;;
;;;;; OAuth アスセストークン
;;;;;
(defclass oauth-access-token (shinra:node)
  ((key    :documentation ""
           :accessor key    :initarg :key)
   (secret :documentation ""
           :accessor secret :initarg :secret))
  (:documentation "OAuth のアクセス・トークンの情報を保持するクラスです。
今後は cl-oauth の class:token を継承予定です。"))


(defgeneric get-oauth-access-token (pool people provider)
  (:documentation "")
  (:method (pool people provider)
    (list pool people provider)))


(defgeneric tx-make-oauth-access-token (pool people provider key secret)
  (:documentation "")
  (:method ((pool shinra:banshou)
            (people people)
            (provider oauth-provider)
            key secret)
    (let ((token (shinra:tx-make-node pool 'oauth-access-token
                                      'key key
                                      'secret secret)))
      (shinra:tx-make-edge *pool* 'shinra:edge provider token :issue)
      (shinra:tx-make-edge *pool* 'shinra:edge people token :have)
      token)))

(defgeneric tx-update-oauth-access-token (pool people provider key secret) (:documentation ""))
(defgeneric tx-save-oauth-access-token (pool people provider key secret) (:documentation ""))


(defgeneric gen-oauth-access-token (provider access-token)
  (:documentation "")
  (:method ((provider oauth-provider) (access-token oauth-access-token))
    (oauth:make-access-token :consumer (oauth:make-consumer-token
                                        :key    (consumer-key  provider)
                                        :secret (consumer-secret provider))
                             :key    (key access-token)
                             :secret (secret access-token))))



;;;;;
;;;;;
;;;;;
(defgeneric find-next-node (pool start node r-type next-node)
  (:documentation "TODO:コードが重複しとるが今度にしよう。")
  (:method  ((pool shinra:banshou)
             (start symbol)
             (node shinra:node)
             (r-type symbol)
             (next-node-class symbol))
    (labels ((_get-node (a) (getf a :node))
             (_eq-node (b)
               (and (eq r-type
                        (shinra:get-edge-type (getf b :edge)))
                    (eq next-node-class
                        (class-name (class-of (getf b :node)))))))
      (apply 'append
             (list
              (mapcar #'_get-node
                      (remove-if-not #'_eq-node
                                     (shinra:find-r pool 'shinra:edge start node)))))))
  (:method ((pool shinra:banshou)
            (start symbol)
            (node shinra:node)
            (r-type symbol)
            (next-node shinra:node))
    (labels ((_get-node (a) (getf a :node))
             (_eq-node (b)
               (and (eq r-type
                        (shinra:get-edge-type (getf b :edge)))
                    (eq next-node (getf b :node)))))
      (apply 'append
             (list
              (mapcar #'_get-node
                      (remove-if-not #'_eq-node
                                     (shinra:find-r pool 'shinra:edge start node))))))))



;; (get-access-token-at *pool* :twitter "114195568")
(defgeneric get-access-token-at (pool provider people)
  (:documentation "pool から アクセストークンを取得します。
取得は provide と people で取得します。")
  (:method ((pool shinra:banshou) (provider oauth-provider) (people people))
    (apply 'append
           (mapcar #'(lambda (token)
                       (if (find-next-node pool :to token :issue provider)
                           token
                           nil))
                   (find-next-node pool
                                   :from people
                                   :have 'oauth-access-token))))
  (:method ((pool shinra:banshou) (provider symbol) (people string))
    (get-access-token-at pool (get-oauth-provider provider) (get-people people))))
