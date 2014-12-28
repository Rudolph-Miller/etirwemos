(in-package :etirwemos)



(defgeneric get-path-param (env name &optional type)
  (:documentation "TODO:内容は不十分じゃねぇ。
上と下はいっしょじゃし非効率じゃねぇ。まぁ後回し作戦で。")
  (:method (env name &optional (type :string))
    "env から path-parameter を取得し type の値に変換するんじゃけど。"
    (let ((val (getf (getf env :path-param) name)))
      (when val
        (cond ((eq type :string)
               (format nil "~a" val))
              ((eq type :keyword)
               (intern-keyword val))
              ((eq type :integer)
               (parse-integer val))
              (t (error "対応していないタイプです。type=~a,val=~a" type val))))))
  (:method ((req <eti-request>) name &optional (type :string))
    ""
    (let ((val (getf (path-param req) name)))
      (when val
        (cond ((eq type :string)
               (format nil "~a" val))
              ((eq type :keyword)
               (intern-keyword val))
              ((eq type :integer)
               (parse-integer val))
              (t (error "対応していないタイプです。type=~a,val=~a" type val)))))))



(defun search-www-json (env)
  "google customer search の結果を返すけぇ。"
  (let ((start (get-path-param env :start :integer)))
    `(200
      (:content-type "application/json")
      (,(encode-json-to-string
         (mapcar #'alist-hash-table
                 (cdr (assoc :items (search-google "common lisp" :start start)))))))))



(defun search-github-rep (env)
  ""
  (let ((start (get-path-param env :page :integer)))
    `(200
      (:content-type "application/json")
      (,(json:encode-json-to-string
         (mapcar #'github-rep-item2map
                 (cdr (assoc :items (search-github :page start)))))))))
