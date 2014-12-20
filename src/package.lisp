(in-package :cl-user)
(defpackage etirwemos
  (:use :cl :cl-who :cl-css)
  (:nicknames :eti)
  (:export #:*bing-primary-account-key*
           #:*bing-request-format*
           #:*bing-base-uri*))
(in-package :etirwemos)

;; setting cl-who
(setf (html-mode) :html5)




