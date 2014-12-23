(in-package :baihu)

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
                       :accessor user-data-name     :initarg :user-data-name)
   (access-token-table :documentation "これも何じゃったかいね？ アクセストークンはユーザー固有じゃけぇ不要じゃろうじゃ。"
                       :accessor access-token-table :initarg :access-token-table)
   (callback-url       :documentation "これはプロバイダ固有の情報じゃないけぇ不要じゃねぇ。いつか削除しよ。"
                       :accessor callback-url       :initarg :callback-url)))


(defun oauth-provider (code &key (pool *pool*) (object-class 'oauth-provider))
  "oauth-provider を shinra から取得するよ。"
  (first (up:find-object-with-slot pool object-class 'code code)))

(defmethod tx-make-oauth-provider ((pool shinra:banshou)
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
                       'user-data-name     user-data-name))




(defmethod obtain-request-token ((provider oauth-provider) callback-uri)
  "OAuthリクエストトークンを生成するけぇ。
リクエストトークンは cl-oauth:request-token クラスなんよ。"
  (cl-oauth:obtain-request-token (request-token-url provider)
                                 (cl-oauth:make-consumer-token :key    (consumer-key    provider)
                                                               :secret (consumer-secret provider))
                                 :callback-uri (format nil "~a/?oauth_searvice=~a" callback-uri (code provider))))


(defmethod make-authorization-uri ((provider oauth-provider) callback-uri)
  "OAuthプロバイダの認証画面のURIを生成するけぇ。"
  (let ((request-token (obtain-request-token provider callback-uri)))
    (format nil "~a" (puri:uri (cl-oauth:make-authorization-uri
                                (authorize-url provider)
                                request-token)))))


(defmethod obtain-access-token ((provider oauth-provider) (request-token cl-oauth:request-token))
  "承認されたリクエストトークンを エンドポイント に遅り、アクセストークンを取得する。"
  (cl-oauth:obtain-access-token (access-token-url provider) request-token))
