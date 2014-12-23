(in-package :etirwemos)

(defvar *goole-public-api-key*           nil)
(defvar *google-custom-search-engine-id* nil)


(defun decode-body (body &key (format "json") (external-format :utf-8))
  (cond ((string= "json" format)
         (cl-json:decode-json-from-string
          (sb-ext:octets-to-string body :external-format external-format)))
        (t (error "このフォーマットは対応しとらんよ。format=~a" format))))


(defun search-www (keyword &key (start 1) (num 10) (format "json"))
  ""
  (multiple-value-bind (body-or-stream status-code headers uri stream must-close reason-phrase)
      (drakma:http-request "https://www.googleapis.com/customsearch/v1"
                           :parameters `(("key" . ,*goole-public-api-key*)
                                         ("cx"  . ,*google-custom-search-engine-id*)
                                         ;;("sort" . "item:cacheId")
                                         ("lr"  . "lang_ja")
                                         ("alt" . ,format)
                                         ("num" .   ,(write-to-string num))
                                         ("start" . ,(write-to-string start))
                                         ("q"   . ,keyword)))
    (declare (ignore headers uri stream must-close reason-phrase))
    (unless (= 200 status-code)
      (error "error. e=~a,body=~a" status-code (sb-ext:octets-to-string body-or-stream)))
    (decode-body body-or-stream)))
