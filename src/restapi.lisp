(in-package :etirwemos)


;;;
;;; macro
;;;
(defmacro webapi-response-json (&body body)
  "これだけのためにマクロを使う必要があるのかな。。。まぁ数が増えれば。。"
  `(list 200
         (list :content-type "application/json")
         (list (json:encode-json-to-string
                ,@body))))



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



(defun balus!! (env)
  "最小の完全数 6秒まって自壊(停止)する。"
  (declare (ignore env))
  (sb-thread:make-thread #'(lambda ()
                             (sleep 6)
                             (eti:stop))
                         :name "balus!!")
  (webapi-response-json
    (alist-hash-table
     `((:balus-time        . (get-universal-time))
       (:explode-plan-time . (+ (geft-universal-time) 6))))))



(defun search-www-json (env)
  "google customer search の結果を返すけぇ。"
  (let ((start (get-path-param env :start :integer)))
    (webapi-response-json
      (mapcar #'alist-hash-table
              (cdr (assoc :items (search-google "common lisp" :start start)))))))



(defun search-github-rep (env)
  ""
  (let ((start (get-path-param env :page :integer)))
    (webapi-response-json
      (mapcar #'github-rep-item2map
              (cdr (assoc :items (search-github :page start)))))))


(defun api-search-tweet (env)
  ""
  (declare (ignore env))
  (webapi-response-json
    (mapcar #'tweet-2-map (search-tweet))))
