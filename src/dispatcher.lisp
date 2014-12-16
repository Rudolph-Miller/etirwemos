(in-package :etirwemos)

(defvar *dispach-table* nil)
'((:regex    "/etirwemos.html"
   :fields   nil
   :function test.html)
  (:regex    "/etirwemos.css"
   :fields   nil
   :function test.css)
  (:regex    "/etirwemos/(\\d+).html"
   :fields   (:code)
   :function test-path-param.html)))


(defun make-path-param (fields values)
  "パスパラメータを作るんじゃけど、今すぐ必要じゃないけぇ後まわしにするわ。2014-12-16"
  (list fields values))

(defun supplement-path-regex (reg)
  "あとで盛るかもしれんし。関数化しとくわ。"
  (concatenate 'string "^" reg "$"))


(defun parse-path (uri &key (table *dispach-table*))
  "uri の パスをパースして、パスパラメータとuriに割り当てられた関数を変えすけぇ。
複数値で返すんじゃけど、最初のんはパスに割り当てられた関数があったかどうかじゃけぇ。"
  (when table
    (let ((item (car table)))
      (multiple-value-bind (ret arr)
          (cl-ppcre:scan-to-strings
           (supplement-path-regex (getf item :regex)) uri)
        (if ret
            (values t
                    (make-path-param (getf item :fields) arr)
                    (getf item :function))
            (parse-path uri :table (cdr table)))))))
