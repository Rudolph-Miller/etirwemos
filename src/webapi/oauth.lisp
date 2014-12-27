(in-package :etirwemos)

#|

OAuth 用のライブラリなんよ。

ほとんど cl-oauth のラッパーじゃえけぇね。

|#


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
                       :accessor user-data-name     :initarg :user-data-name)))

(defgeneric get-oauth-provider (code &key pool object-class)
  (:documentation "oauth-provider を shinra から取得するよ。"))

(defmethod get-oauth-provider ((code symbol) &key (pool *pool*) (object-class 'oauth-provider))
  (first (up:find-object-with-slot pool object-class 'code code)))

(defmethod get-oauth-provider ((code string) &key (pool *pool*) (object-class 'oauth-provider))
  (get-oauth-provider (intern-keyword code) :pool pool :object-class object-class))



(defmethod tx-make-oauth-provider ((pool shinra:banshou)
                                   code consumer-key consumer-secret
                                   request-token-url authorize-url access-token-url
                                   user-data-id user-data-name
                                   &key (object-class 'oauth-provider))
  "森羅上に oauth-provider を保管します。"
  (shinra:tx-make-node pool object-class
                       'code               code
                       'consumer-key       consumer-key
                       'consumer-secret    consumer-secret
                       'request-token-url  request-token-url
                       'authorize-url      authorize-url
                       'access-token-url   access-token-url
                       'user-data-id       user-data-id
                       'user-data-name     user-data-name))



;;;;;
;;;;; OAuth リクエスト・トークン
;;;;;
(defvar *request-token-pool* nil
  "リクエストトークンを一時的に保管するためのリストです。
データ構造は '(:provider nil :token nil) です。")


(defgeneric save-request-token (provider request-token)
  (:documentation "リクエスト・トークンを一時的に保管するけぇ。"))

(defmethod save-request-token ((provider oauth-provider) (request-token cl-oauth:request-token))
  "重複防止のコードは今は先送り。"
  (push (list :provider provider :token request-token)
        *request-token-pool*)
  *request-token-pool*)

(defmethod save-request-token ((provider symbol) (request-token cl-oauth:request-token))
  (let ((prov (get-oauth-provider provider)))
    (when prov
      (save-request-token prov request-token))))



(defmethod get-request-token ((provider-code symbol) request-token-key)
  "保管したリクエスト・トークンを取得するんよ。"
  (getf
   (find-if #'(lambda (data)
                (let ((save-provider (getf data :provider))
                      (save-token    (getf data :token)))
                  (and (eq (code save-provider) provider-code)
                       (string= (cl-oauth:token-key save-token) request-token-key))))
            *request-token-pool*)
   :token))


(defmethod get-request-token ((provider-code string) request-token-key)
  "provider-code が文字の場合は キーワードに変換して get-request-token を呼ぶ。"
  (get-request-token (intern-keyword provider-code) request-token-key))




(defmethod obtain-request-token ((provider oauth-provider) callback-uri)
  "OAuthリクエストトークンを生成するけぇ。
リクエストトークンは cl-oauth:request-token クラスなんよ。"
  (cl-oauth:obtain-request-token (request-token-url provider)
                                 (cl-oauth:make-consumer-token :key    (consumer-key    provider)
                                                               :secret (consumer-secret provider))
                                 :callback-uri (format nil "~a/?oauth_searvice=~a" callback-uri (code provider))))

(defmethod obtain-request-token ((provider symbol) callback-uri)
  (let ((oauth-provider (get-oauth-provider provider)))
    (when oauth-provider
      (obtain-request-token oauth-provider callback-uri))))

(defmethod obtain-request-token ((provider string) callback-uri)
  (obtain-request-token (intern-keyword provider) callback-uri))


(defun authorize-request-token (request-token verification-code)
  "リクエスト・トークンを承認済の状態にします。
cl-oauth:authorize-request-token-from-request を利用するんじゃけど、この関数は hunchentoot を利用することが前提となっとるようじゃけぇ。
その具をとってきたいね。
"
  (cl-oauth:authorize-request-token request-token)
  (setf (cl-oauth:request-token-verification-code request-token) verification-code)
  ;; TODO:
  ;; これねぇ。。。クエリパラメータから OAuthのパラメータをカットしたやつをセットしとるみたいなんじゃけど。
  ;; 時間がないしスルーするわ。とりあえず問題ないはず。
  ;; (setf (token-user-data token) user-parameters)
  request-token)



;;;;;
;;;;; OAuth 承認画面のURI
;;;;;
(defmethod make-authorization-uri ((provider oauth-provider)
                                   (request-token cl-oauth:request-token)
                                   callback-uri)
  "OAuthプロバイダの認証画面のURIを生成するけぇ。"
  (format nil "~a" (puri:uri (cl-oauth:make-authorization-uri
                              (authorize-url provider)
                              request-token))))



;;;;;
;;;;; OAuth アスセストークン
;;;;;
;; これは どこで 使う？
(defmethod obtain-access-token ((provider oauth-provider) (request-token cl-oauth:request-token))
  "承認されたリクエストトークンを エンドポイント に遅り、アクセストークンを取得する。"
  (cl-oauth:obtain-access-token (access-token-url provider) request-token))
