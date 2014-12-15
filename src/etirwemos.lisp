(in-package :etirwemos)

(defun hanage ()
  (format nil "はなげ。"))

(defun app (env)
  (declare (ignore env))
  '(200
    (:content-type "text/plain")
    ("はなげ。")))
