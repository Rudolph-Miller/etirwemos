(in-package :cl-user)
(defpackage etirwemos
  (:use :cl :cl-who :cl-css)
  (:nicknames :eti)
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
;;; import...とりあえず仮設で.... defpackage に入れますんで。
;;;
(mapcar #'import
        '('alexandria:alist-hash-table
          'alexandria:plist-hash-table
          'alexandria:hash-table-plist
          'alexandria:hash-table-alist
          'alexandria:hash-table-keys
          'alexandria:hash-table-values))


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



