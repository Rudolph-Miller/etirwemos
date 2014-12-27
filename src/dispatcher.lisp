(in-package :etirwemos)

(defvar *dispach-table* nil)


(defun make-path-param (fields values)
  ""
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



;;;
;;; ファイルディスパッチャ
;;;
(defun file-data ()
  "ファイルのデータを返すんよ。"
  '(("/etirwemos.js"     (:js  #p"/home/yanqirenshi/prj/etirwemos/src/etirwemos.js"))
    ("/me.js"            (:js  #p"/home/yanqirenshi/prj/etirwemos/src/me.js"))
    ("/lib/glide.js"     (:js  #p"/home/yanqirenshi/prj/Glide.js/dist/jquery.glide.min.js"))
    ("/lib/glide.css"    (:css #p"/home/yanqirenshi/prj/Glide.js/dist/css/style.css"))
    ("/lib/format4js.js" (:js  #p"/home/yanqirenshi/prj/format4js/format4js.js"))
    ("/yzr.js"           (:js  #p"/home/yanqirenshi/prj/etirwemos/src/yzr.js"))
    ("/yzrHtml.js"       (:js  #p"/home/yanqirenshi/prj/etirwemos/src/yzrHtml.js"))))


(defun get-file-data (path)
  (second (assoc path (file-data) :test 'equalp)))


(defun get-mime-string (key)
  (cond ((eq key :js)  "application/x-javascript")
        ((eq key :css) "text/css")
        (t (error "この key は対応していません。key=~a" key))))


(defun file-dispatcher (env)
  (let ((file-data (get-file-data (getf env :path-info))))
    (if file-data
        `(200
          (:content-type ,(get-mime-string (first file-data)))
          ,(second file-data))
        (page-not-fund-reply env))))
