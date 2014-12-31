(in-package :etirwemos)

#|
ファイルの名前が気にいらんが。。。。。あとで修正するとして。
|#

(defun init-dispatch-data ()
  (setf *file-table*
        `(("/etirwemos.js"        (:js   ,(src-pathname    "etirwemos.js")))
          ("/etirwemos-anime.css" (:css  ,(src-pathname    "etirwemos-anime.css")))
          ("/me.js"               (:js   ,(src-pathname    "me.js")))
          ("/lib/glide.js"        (:js   ,(js-lib-pathname "Glide.js/dist/jquery.glide.min.js")))
          ("/lib/glide.css"       (:css  ,(js-lib-pathname "Glide.js/dist/css/style.css")))
          ("/lib/format4js.js"    (:js   ,(js-lib-pathname "format4js/format4js.js")))
          ("/yzr.js"              (:js   ,(src-pathname    "yzr.js")))
          ("/yzrHtml.js"          (:js   ,(src-pathname    "yzrHtml.js")))
          ("/img/cloud.png"       (:png  ,(img-pathname    "cloud.png")))
          ("/img/dodo.png"        (:png  ,(img-pathname    "dodo.png")))
          ("/img/gogo.png"        (:png  ,(img-pathname    "gogo.png")))))
  (setf *dispach-table*
        '((:regex    "/org-mode.css"        :fields nil :function org-mode.css)
          (:regex    "/etirwemos.html"      :fields nil :function etirwemos.html)
          (:regex    "/etirwemos.css"       :fields nil :function etirwemos.css)
          (:regex    "/etirwemos.js"        :fields nil :function file-dispatcher)
          (:regex    "/etirwemos-anime.css" :fields nil :function file-dispatcher)
          (:regex    "/me.html"             :fields nil :function me.html)
          (:regex    "/me.html/"            :fields nil :function me.html)
          (:regex    "/me.css"              :fields nil :function me.css)
          (:regex    "/me.js"               :fields nil :function file-dispatcher)
          (:regex    "/lib/glide.js"        :fields nil :function file-dispatcher)
          (:regex    "/lib/glide.css"       :fields nil :function file-dispatcher)
          (:regex    "/lib/format4js.js"    :fields nil :function file-dispatcher)
          (:regex    "/yzr.js"              :fields nil :function file-dispatcher)
          (:regex    "/yzrHtml.js"          :fields nil :function file-dispatcher)
          (:regex    "/img/cloud.png"       :fields nil :function file-dispatcher)
          (:regex    "/img/dodo.png"        :fields nil :function file-dispatcher)
          (:regex    "/img/gogo.png"        :fields nil :function file-dispatcher)
          (:regex    "/balus!!"             :fields nil :function balus!!)
          ;;;
          ;;; REST-API
          ;;;
          (:regex    "/etirwemos/search/www/google/start/(\\d+)"
           :fields   (:start)
           :function search-www-json)
          (:regex    "/etirwemos/github/repogitory/search/page/(\\d+)"
           :fields   (:page)
           :function search-github-rep)
          (:regex    "/etirwemos/search/tweet/start/(\\d+)"
           :fields   (:start)
           :function api-search-tweet))))

(defun start ()
  (init-dispatch-data)
  (start-up)
  (start-clack))

(defun stop ()
  (stop-clack)
  (stop-up))
