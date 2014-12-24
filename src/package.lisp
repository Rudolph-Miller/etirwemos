(in-package :cl-user)
(defpackage etirwemos
  (:use :cl :cl-who :cl-css)
  (:nicknames :eti)
  (:import-from "ALEXANDRIA" "ALIST-HASH-TABLE")
  (:import-from "ALEXANDRIA" "PLIST-HASH-TABLE")
  (:import-from "ALEXANDRIA" "HASH-TABLE-PLIST")
  (:import-from "ALEXANDRIA" "HASH-TABLE-ALIST")
  (:import-from "ALEXANDRIA" "HASH-TABLE-KEYS")
  (:import-from "ALEXANDRIA" "HASH-TABLE-VALUES")
  (:export #:*bing-primary-account-key*
           #:*bing-request-format*
           #:*bing-base-uri*
           #:*goole-public-api-key*
           #:*google-custom-search-engine-id*
           #:*github-user*
           #:*github-password*
           #:*data-stor*))
(in-package :etirwemos)


;;;
;;; setting cl-who
;;;
(setf (html-mode) :html5)


;;;
;;; Utility
;;;
(defun intern-keyword (name)
  (when name
    (intern (string-upcase name) (find-package "KEYWORD"))))



