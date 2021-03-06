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
           #:*oauth-callback-base*
           #:*etirwemos-src-dir*
           #:*etirwemos-img-dir*
           #:*etirwemos-js-lib-dir*
           #:*etirwemos-log-dir*
           #:*data-stor*
           #:start
           #:stop))
(in-package :etirwemos)



;;;
;;; setting cl-who
;;;
(setf (html-mode) :html5)



;;;
;;; clack の拡張
;;; clack.request:request に パス・パラメータを追加。
;;;
(in-package :clack.request)
(defun make-request (env &key (request-class '<request>))
  "上書きしてまおう。
でも、ここまでしたパス・パラメータ使いたいんかいね。"
  (apply #'make-instance request-class
         :allow-other-keys t
         :raw-body (shared-raw-body env)
         env))

(defun split-cookie (cookie)
  "cookie の文字列をlispに変換しています。"
  (let ((pos (search "=" cookie)))
    `((,(subseq cookie 0 pos) . ,(subseq cookie (+ 1 pos))))))

(defmethod initialize-instance :after ((this <request>) &rest env)
  "cookie をパース出来ないケースがあったので split-cookie でバイパスしています。"
  (remf env :allow-other-keys)
  (setf (slot-value this 'env) env)

  ;; cookies
  (when-let (cookie (gethash "cookie" (headers this)))
    (setf (slot-value this 'http-cookie)
          (loop for kv in (ppcre:split "\\s*[,;]\\s*" cookie)
             append (split-cookie kv))))

  ;; GET parameters
  (when (and (not (slot-boundp this 'query-parameters))
             (query-string this))
    (setf (slot-value this 'query-parameters)
          (quri:url-decode-params (query-string this))))

  ;; POST parameters
  (when (and (not (slot-boundp this 'body-parameters))
             (raw-body this))
    (setf (slot-value this 'body-parameters)
          (parse (content-type this) (raw-body this)))))


(in-package :etirwemos)
(defclass <eti-request> (clack.request:<request>)
  ((path-param ;;:type string
    :initarg :path-param
    :reader path-param
    :documentation "")))


(defun make-request (env path-param)
  "clack.request:make-request をラッピングして path-param に対応しています。"
  (clack.request:make-request (append env `(:path-param ,path-param))
                              :request-class '<eti-request>))



;;;
;;; Utility
;;;
(defun intern-keyword (name)
  (when name
    (intern (string-upcase name) (find-package "KEYWORD"))))
