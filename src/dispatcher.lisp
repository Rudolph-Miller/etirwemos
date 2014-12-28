(in-package :etirwemos)


;;;
;;; URIパスと関数との関連付け。
;;;
(defvar *dispach-table* nil)

(defun get-mime-string (key)
  (cond ((eq key :js)  "application/x-javascript")
        ((eq key :css) "text/css")
        (t (error "この key は対応していません。key=~a" key))))


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
(defvar *etirwemos-src-dir* nil
  "etirwemosのソースファイルが配置されているディレクトリを指定する。")
(defvar *etirwemos-js-lib-dir* nil
  "javascript のライブラリが配置されているルート・ディレクトリを指定する。")

(defun js-lib-pathname (path)
  "TODO: これ、src-pathname と統合できそうじゃね。"
  (pathname (concatenate 'string *etirwemos-js-lib-dir* path)))

(defun src-pathname (path)
  (pathname (concatenate 'string *etirwemos-src-dir* path)))

(defun file-data ()
  "ファイルのデータを返すんよ。"
  `(("/etirwemos.js"     (:js  ,(src-pathname    "etirwemos.js")))
    ("/me.js"            (:js  ,(src-pathname    "me.js")))
    ("/lib/glide.js"     (:js  ,(js-lib-pathname "Glide.js/dist/jquery.glide.min.js")))
    ("/lib/glide.css"    (:css ,(js-lib-pathname "Glide.js/dist/css/style.css")))
    ("/lib/format4js.js" (:js  ,(js-lib-pathname "format4js/format4js.js")))
    ("/yzr.js"           (:js  ,(src-pathname    "yzr.js")))
    ("/yzrHtml.js"       (:js  ,(src-pathname    "yzrHtml.js")))))


(defun get-file-data (path)
  (second (assoc path (file-data) :test 'equalp)))

(defun file-dispatcher (req)
  (let ((file-data (get-file-data (clack.request:path-info req))))
    (if file-data
        `(200
          (:content-type ,(get-mime-string (first file-data)))
          ,(second file-data))
        (page-not-found-reply req))))
