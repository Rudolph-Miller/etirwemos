(in-package :etirwemos)


;;;
;;; URIパスと関数との関連付け。
;;;
(defvar *dispach-table* nil)

(defun get-mime-string (key)
  (cond ((eq key :js)  "application/x-javascript")
        ((eq key :css) "text/css")
        ((eq key :png) "image/png")
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
(defvar *etirwemos-img-dir* nil
  "etirwemosで利用する画像が配置されているディレクトリを指定する。")
(defvar *etirwemos-js-lib-dir* nil
  "javascript のライブラリが配置されているルート・ディレクトリを指定する。")
(defvar *file-table* nil
  "uri のパスとファイルの関連付けを管理します。
書き方は main.lisp 参照。")

(defun js-lib-pathname (path)
  "TODO: これ、src-pathname と統合できそうじゃね。"
  (pathname (concatenate 'string *etirwemos-js-lib-dir* path)))

(defun src-pathname (path)
  (pathname (concatenate 'string *etirwemos-src-dir* path)))

(defun img-pathname (path)
  (pathname (concatenate 'string *etirwemos-img-dir* path)))

(defun get-file-data (path)
  (second (assoc path *file-table* :test 'equalp)))

(defun file-dispatcher (req)
  (let ((file-data (get-file-data (clack.request:path-info req))))
    (if file-data
        `(200
          (:content-type ,(get-mime-string (first file-data)))
          ,(second file-data))
        (page-not-found-reply req))))
