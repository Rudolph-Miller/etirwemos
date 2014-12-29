(in-package :etirwemos)

#|

clack を利用するためのコードじゃけぇ。

|#
(defvar *handler* nil "")


;;;
;;; アプリ部分
;;;
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


;;;
;;; clack:<component> を利用してみます。
;;; 現在のレベルでは必要とはしとらんけど clack を使うのんが目的の一つなんで。
;;;
(defclass <etirwemos> (clack:<component>) ())
(defmethod clack:call ((this <etirwemos>) env)
  (multiple-value-bind (ret path-param func)
      (parse-path (getf env :path-info))
    (let ((request (make-request env path-param)))
      (if ret
          (handler-case (funcall func request)
            (etirwemos-error (e) (error-case-reply env e)))
          (page-not-found-reply env)))))



;;;
;;; ログ関連
;;;
(defvar *etirwemos-log-dir* nil)
(defun error-log-file ()
  (pathname (concatenate 'string *etirwemos-log-dir* "error.log")))



;;;
;;; OAuth (Twitter) 関連
;;;
(defvar *oauth-callback-base* nil)
(defun twitter-oauth-authorized (req acc-token)
  (declare (ignore req acc-token))
  '(200
    (:content-type "text/plain")
    ("Authorized!")))



;;;
;;; Clack の開始と終了
;;;
(defun start-clack ()
  (when *handler* (error "前のんがまだ動いとるよ。"))
  (refresh-dispach-table)
  (let ((twitter-provider (get-oauth-provider :twitter)))
    (unless twitter-provider (error "not exist oauth provider. name=~a":twitter))
    (setf *handler*
          (clackup
           (builder
            <clack-middleware-accesslog>
            (<clack-middleware-backtrace>
             :output (error-log-file)
             :result-on-error '(500 () ("Internal Server Error")))
            (<clack-middleware-oauth>
             :consumer-key      (consumer-key      twitter-provider)
             :consumer-secret   (consumer-secret   twitter-provider)
             :request-token-uri (request-token-url twitter-provider)
             :authorize-uri     (authorize-url     twitter-provider)
             :access-token-uri  (access-token-url  twitter-provider)
             :path              "/auth/twitter"
             :callback-base     *oauth-callback-base*
             :authorized #'twitter-oauth-authorized)
            (make-instance '<etirwemos>))
           ;; :server :woo
           :debug t))))



(defun stop-clack ()
  (when *handler*
    (clack.handler:stop *handler*)
    (setf *handler* nil)))