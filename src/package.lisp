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
  (:import-from "CL-JSON" "ENCODE-JSON-TO-STRING")
  (:import-from "CLACK.REQUEST" "QUERY-PARAMETER")
  (:import-from "CLACK.REQUEST" "MAKE-REQUEST")
  (:import-from "CLACK" "CLACKUP")
  (:import-from "CLACK.BUILDER" "BUILDER")
  (:import-from "CLACK.MIDDLEWARE.LOGGER" "<CLACK-MIDDLEWARE-LOGGER>")
  (:import-from "CLACK.MIDDLEWARE.ACCESSLOG" "<CLACK-MIDDLEWARE-ACCESSLOG>")
  (:import-from "CLACK.LOGGER.FILE" "<CLACK-LOGGER-FILE>")
  (:import-from "CLACK.MIDDLEWARE.OAUTH" "<CLACK-MIDDLEWARE-OAUTH>")
  (:import-from "CLACK.MIDDLEWARE.BACKTRACE" "<CLACK-MIDDLEWARE-BACKTRACE>")
  (:EXPORT #:*bing-primary-account-key*
           #:*bing-request-format*
           #:*bing-base-uri*
           #:*goole-public-api-key*
           #:*google-custom-search-engine-id*
           #:*github-user*
           #:*github-password*
           #:*twitter-consumer-key*
           #:*twitter-consumer-secret*
           #:*etirwemos-src-dir*
           #:*etirwemos-js-lib-dir*
           #:*etirwemos-log-dir*
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



