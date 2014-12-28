(in-package :etirwemos)

#|

clack を利用するためのコードじゃけぇ。

|#
(defvar *handler* nil "")


(defgeneric error-case-reply (env error)
  (:documentation "HTTPリクエスト処理中にエラーが発生した場合の reply じゃけぇ。
condition の種類でイロイロ盛れるようにしとるんじゃけど。
TODO:時間に余裕があったら凝ってみようかしら。"))
(defmethod error-case-reply (env error)
  (declare (ignore env error))
  '(500 (:content-type "text/plain") ("ごめんなさい Server Error です。")))


(defun page-not-found-reply (req)
  "ページが存在しない場合の reply じゃけぇ。
TODO:時間に余裕があったら盛ります。"
  (declare (ignore req))
  '(404 (:content-type "text/plain") ("Not found!!")))


(define-condition etirwemos-error (error)
  ((universal-time :initform (get-universal-time)
                   :accessor universal-time)))


(defun app (env)
  "clack に渡すアプリの関数じゃけぇ。"
  (multiple-value-bind (ret path-param func)
      (parse-path (getf env :path-info))
    (let ((request (make-request env path-param)))
      (if ret
          (handler-case (funcall func request)
            (etirwemos-error (e) (error-case-reply env e)))
          (page-not-found-reply env)))))


(defvar *etirwemos-log-dir* nil)
(defun error-log-file ()
  (pathname (concatenate 'string *etirwemos-log-dir* "error.log")))


(defvar *twitter-consumer-key* nil)
(defvar *twitter-consumer-secret* nil)
(defun twitter-oauth-authorized (req acc-token)
  (declare (ignore req acc-token))
  '(200
    (:content-type "text/plain")
    ("Authorized!")))


(defun start-clack ()
  "Http-serverを起動するための関数なんよ。
起動するときに dispatch-table はリフレッシュするようにしとるけぇ。"
  (when *handler* (error "前のんがまだ動いとるよ。"))
  (refresh-dispach-table)
  (setf *handler*
        (sb-thread:make-thread
         #'(lambda ()(clackup
                      (builder
                       <clack-middleware-accesslog>
                       (<clack-middleware-backtrace>
                        :output (error-log-file)
                        :result-on-error '(500 () ("Internal Server Error")))
                       (<clack-middleware-oauth>
                        :consumer-key      *twitter-consumer-key*
                        :consumer-secret   *twitter-consumer-secret*
                        :request-token-uri "https://api.twitter.com/oauth/request_token"
                        :authorize-uri     "https://api.twitter.com/oauth/authorize"
                        :access-token-uri  "https://api.twitter.com/oauth/access_token"
                        :path              "/auth/twitter"
                        :callback-base     "http://localhost:5000"
                        :authorized #'twitter-oauth-authorized)
                       #'app)
                      :server :woo :debug nil))
         :name "etirwemos")))



(defun stop-clack ()
  "Http-serverを停止する関数じゃけぇね。
ちょっと乱暴なやりかたじゃけど、こんど綺麗にするけぇ。
ゆるしてつかぁさい。"
  (when (and *handler* (eq 'SB-THREAD:THREAD (type-of *handler*)))
    (sb-thread:terminate-thread *handler*)
    (setf *handler* nil)))


(defun start! ()
  (refresh-dispach-table)
  (setf *handler*
        (clackup
         (builder
          <clack-middleware-accesslog>
          (<clack-middleware-backtrace>
           :output (error-log-file)
           :result-on-error '(500 () ("Internal Server Error")))
          (<clack-middleware-oauth>
           :consumer-key      *twitter-consumer-key*
           :consumer-secret   *twitter-consumer-secret*
           :request-token-uri "https://api.twitter.com/oauth/request_token"
           :authorize-uri     "https://api.twitter.com/oauth/authorize"
           :access-token-uri  "https://api.twitter.com/oauth/access_token"
           :path              "/auth/twitter"
           :callback-base     "http://localhost:5000"
           :authorized #'twitter-oauth-authorized)
          #'app)
         :server :woo :debug t)))

(defun stop! () (clack.handler:stop *handler*))