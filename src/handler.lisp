(in-package :etirwemos)


(defvar *handler* nil)


(defun app (env)
  "404は関数かかんといけんねぇ。"
  (multiple-value-bind (ret path-param func)
      (parse-path (getf env :path-info))
    (if ret
        (funcall func (append env `(:path-param ,path-param)))
        '(404 (:content-type "text/plain") ("Not found")))))


(defun start ()
  "Http-serverを起動するんよ。起動するときに dispatch-table はリフレッシュするようにしとるけぇ。"
  (when *handler* (error "前のんがまだ動いとるよ。"))
  (refresh-dispach-table)
  (setf *handler*
        (sb-thread:make-thread
         #'(lambda ()(clack:clackup #'app :server :woo :debug nil))
         :name "etirwemos")))


(defun stop ()
  "Http-serverを停止するけぇね。ちょっと乱暴なやりかたじゃけど、こんど綺麗にするけぇ。
ゆるしてつかぁさい。"
  (when (and *handler* (eq 'SB-THREAD:THREAD (type-of *handler*)))
    (sb-thread:terminate-thread *handler*)
    (setf *handler* nil)))

