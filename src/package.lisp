(in-package :cl-user)
(defpackage etirwemos
  (:use :cl))
(in-package :etirwemos)

(defvar *handler* nil)

(defun hanage ()
  (format nil "はなげ。"))

(defun app (env)
  (declare (ignore env))
  '(200
    (:content-type "text/plain")
    ("はなげ。")))


(defun start ()
  (when *handler* (error "前のんがまだ動いとるよ。"))
  (setf *handler*
	(sb-thread:make-thread 
	 #'(lambda ()(clack:clackup #'app :server :woo :debug nil))
	 :name "etirwemos")))

(defun stop ()
  (when (and *handler* (eq 'SB-THREAD:THREAD (type-of *handler*)))
    (sb-thread:terminate-thread *handler*)
    (setf *handler* nil)))

