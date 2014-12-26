(in-package :etirwemos)

(defun get-path-param (env name &optional (type :string))
  "env から path-parameter を取得し type の値に変換するんじゃけど。
TODO:内容は不十分じゃねぇ。"
  (let ((val (getf (getf env :path-param) name)))
    (when val
      (cond ((eq type :string)
             (format nil "~a" val))
            ((eq type :keyword)
             (intern-keyword val))
            ((eq type :integer)
             (parse-integer val))
            (t (error "対応していないタイプです。type=~a,val=~a" type val))))))



(defun search-www-json (env)
  "google customer search の結果を返すけぇ。"
  (let ((start (parse-integer (getf (getf env :path-param) :start))))
    `(200
      (:content-type "application/json")
      (,(cl-json:encode-json-to-string
         (mapcar #'alexandria:alist-hash-table
                 (cdr (assoc :items (search-google "common lisp" :start start)))))))))



(defun search-github-rep (env)
  ""
  (let ((start (parse-integer (getf (getf env :path-param) :page))))
    `(200
      (:content-type "application/json")
      (,(json:encode-json-to-string
         (mapcar #'github-rep-item2map
                 (cdr (assoc :items (search-github :page start)))))))))



(defun get-oauth-provider-uri (env)
  ""
  (let ((provider (get-path-param env :provider :keyword))
        ;; TODO: これは クエリパラムから取得しよう。
        (callback-uri "http://localhost:5000/me.html"))
    `(200
      (:content-type "text/plain")
      (,(let ((request-token (obtain-request-token provider callback-uri)))
             ;; リクエスト・トークンを一時的に保管します。
             (save-request-token provider request-token)
             ;; プロバイダの承認urlを取得します。
             (make-authorization-uri (get-oauth-provider provider)
                                     request-token
                                     callback-uri))))))
