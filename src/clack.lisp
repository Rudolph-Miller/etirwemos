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


(defun page-not-fund-reply (env)
  "ページが存在しない場合の reply じゃけぇ。
TODO:時間に余裕があったら盛ります。"
  (declare (ignore env))
  '(404 (:content-type "text/plain") ("Not found!!")))


(defun app (env)
  "clack に渡すアプリの関数じゃけぇ。"
  (multiple-value-bind (ret path-param func)
      (parse-path (getf env :path-info))
    (if ret
        (handler-case
            (funcall func (append env `(:path-param ,path-param)))
          (error (e) (error-case-reply env e)))
        (page-not-fund-reply env))))



(defun start-clack ()
  "Http-serverを起動するための関数なんよ。
起動するときに dispatch-table はリフレッシュするようにしとるけぇ。"
  (when *handler* (error "前のんがまだ動いとるよ。"))
  (refresh-dispach-table)
  (setf *handler*
        (sb-thread:make-thread
         #'(lambda ()(clack:clackup #'app :server :woo :debug nil))
         :name "etirwemos")))


(defun stop-clack ()
  "Http-serverを停止する関数じゃけぇね。
ちょっと乱暴なやりかたじゃけど、こんど綺麗にするけぇ。
ゆるしてつかぁさい。"
  (when (and *handler* (eq 'SB-THREAD:THREAD (type-of *handler*)))
    (sb-thread:terminate-thread *handler*)
    (setf *handler* nil)))

