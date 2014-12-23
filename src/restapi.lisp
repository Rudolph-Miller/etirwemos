(in-package :etirwemos)

(defun search-www-json (env)
  (let ((start (parse-integer (getf (getf env :path-param) :start))))
    `(200
      (:content-type "application/json")
      (,(cl-json:encode-json-to-string
         (mapcar #'alexandria:alist-hash-table
                 (cdr (assoc :items (search-google "common lisp" :start start)))))))))
