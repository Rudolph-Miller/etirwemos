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


(defgeneric get-path-param (env-or-request)
  (:method ((env list)) (getf env :path-param))
  (:method ((req <eti-request>)) (path-param req)))


(defun get-path-param-value (env-or-request name &optional type)
  "env or request から path-parameter を取得し type の値に変換します。"
  (let ((val (getf (get-path-param env-or-request) name)))
    (when val
      (cond ((or (eq type :string) (eq type :str))
             (format nil "~a" val))
            ((eq type :keyword)
             (intern-keyword val))
            ((or (eq type :integer) (eq type :int))
             (parse-integer val))
            (t (error "対応していないタイプです。type=~a,val=~a" type val))))))



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
  (let ((start (get-path-param-value env :start :integer)))
    (webapi-response-json
      (mapcar #'alist-hash-table
              (cdr (assoc :items (search-google "common lisp" :start start)))))))



(defun search-github-rep (env)
  ""
  (let ((start (get-path-param-value env :page :integer)))
    (webapi-response-json
      (mapcar #'github-rep-item2map
              (cdr (assoc :items (search-github :page start)))))))


(defun api-search-tweet (env)
  ""
  (declare (ignore env))
  (webapi-response-json
    (mapcar #'tweet-2-map (search-tweet))))
