(in-package :etirwemos)

(defvar *dispach-table* nil)


(defun make-path-param (fields values)
  ""
  (print (and fields values))
  (when (and (and fields values)
	     (= (length fields) (length values)))
    (let ((len (length fields))
	  (out nil))
      (dotimes (i len)
	(setf out 
	      (append out (list (nth i fields) (aref values i)))))
      out)))


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
