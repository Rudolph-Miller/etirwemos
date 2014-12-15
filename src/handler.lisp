(in-package :etirwemos)

(defvar *handler* nil)

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

