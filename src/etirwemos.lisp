(in-package :etirwemos)

;;;
;;; Utility
;;;
(defun css.rgba (r g b a) (format nil "rgba(~a,~a,~a,~a)"  r g b a))
(defun css.color (type &optional (a 1.0))
  (cond ((eq :active         type) (css.rgba 220  89  95 a)) ;; DC595F
        ((eq :font           type) (css.rgba  95  95  95 a)) ;; 5f5f5f
        ((eq :border         type) (css.rgba 198 198 198 a)) ;; c6c6c6
        ((eq :base           type) (css.rgba 238 238 238 a)) ;; eeeeee
        ((eq :contents       type) (css.rgba 255 255 255 a)) ;; ffffff
        ((eq :hilight-yellow type) (css.rgba 224 195  37 a)) ;;
        ((eq :hilight-blue   type) (css.rgba 120 192 250 a)) ;; 78C0FA
        ((eq :hilight-greenl type) (css.rgba 187 213  42 a)) ;; BBD52A
        (t (error "なんじゃいこのtypeは!! type=~a" type))))

(defun css.border (type &optional (size 1) (border-type :solid))
  (cond ((eq :normal type)          (format nil "~apx ~a ~a" size border-type (css.color :border)))
        ((eq :light type)           (format nil "~apx ~a ~a" size border-type (css.color :base)))
        ((eq :font type)            (format nil "~apx ~a ~a" size border-type (css.color type)))
        ((eq :hilight-blue    type) (format nil "~apx ~a ~a" size border-type (css.color type)))
        ((eq :hilight-greenl  type) (format nil "~apx ~a ~a" size border-type (css.color type)))
        ((eq :hilight-yeallow type) (format nil "~apx ~a ~a" size border-type (css.color type)))
        ((eq :active type)       (format nil "~apx solid ~a" size (css.color :active)))
        (t (error "なんじゃいこのtypeは!! type=~a" type))))

(defun yzr.js (env)
  (declare (ignore env))
  '(200
    (:content-type "application/x-javascript")
    #p"/home/yanqirenshi/prj/etirwemos/src/yzr.js"))

(defun yzrHtml.js (env)
  (declare (ignore env))
  '(200
    (:content-type "application/x-javascript")
    #p"/home/yanqirenshi/prj/etirwemos/src/yzrHtml.js"))

(defun format4js.js (env)
  (declare (ignore env))
  '(200
    (:content-type "application/x-javascript")
    #p"/home/yanqirenshi/prj/format4js/format4js.js"))

;;;
;;; Test Glide.js
;;; https://github.com/jedrzejchalubek/Glide.js
;;;
(defun glide.js (env)
  (declare (ignore env))
  '(200
    (:content-type "application/x-javascript")
    #p"/home/yanqirenshi/prj/Glide.js/dist/jquery.glide.min.js"))


(defun glide.css (env)
  (declare (ignore env))
  '(200
    (:content-type "text/css")
    #p"/home/yanqirenshi/prj/Glide.js/dist/css/style.css"))


;;;
;;; test
;;;
(defun test-path-param.html (env)
  (declare (ignore env))
  '(200
    (:content-type "text/html")
    ("<html><head></head><body>Hello hanage2</body></html>")))


;;;
;;; org mode
;;;
(defun org-mode.css (env)
  (declare (ignore env))
  `(200
    (:content-type "text/css")
    (,(cl-css:css
       `((* :margin 0px :padding 0px)
         (html :background ,(css.color :base))
         ("html, body"
          :width 100% :height 100%)
         ("ul" :margin-left 22px)
         ("div#table-of-contents" :clear both :padding 22px)
         ("div#content" :margin-top 88px)
         ("div#content > h1" :width 100%
                             :position fixed
                             :top 0px
                             :left 0px
                             :box-sizing border-box
                             :padding 11px
                             :background ,(css.color :base 0.88))
         ("div#content > p" :padding 22px)
         ("div#content > div.outline-2" :padding 33px
                                        :margin 33px
                                        :background ,(css.color :contents 0.33)
                                        :border-radius 3px
                                        :box-sizing border-box)
         ("div#content > div.outline-2:hover" :background ,(css.color :contents))
         ("div#postamble" :clear both)
         ("div.outline-2 > h2" :margin-bottom 22px)
         ("div.outline-3 > h3" :margin-bottom 11px)
         ("div.outline-3" :margin "22px 0px 22px 11px")
         ("div.outline-text-3" :margin-left 22px)
         ("div.outline-4" :margin "11px 0px 22px 22px")
         ("div.outline-text-3" :margin-left 33px)
         ("div.outline-text-4" :margin-left 33px))))))



;;;
;;; main page
;;;
(defun etirwemos.html (env)
  (declare (ignore env))
  (let ((css-list '("/lib/glide.css" "/etirwemos.css"))
        (js-list  '("https://code.jquery.com/jquery-2.1.3.min.js"
                    "https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.8.4/moment.min.js"
                    "/yzr.js"
                    "/yzrHtml.js"
                    "/lib/format4js.js"
                    "/lib/glide.js"
                    "/etirwemos.js")))
    `( 200
       (:content-type "text/html")
       ,(let ((out (make-string-output-stream)))
             (with-html-output (stream out :prologue t)
               (:html (:head (:title "WCLR")
                             ;; CSS
                             (dolist (css css-list)
                               (htm (:link :rel "stylesheet" :type "text/css" :href css))))
                      (:body
                       (:section :id "background" :style "z-index:-999;"
                                 (:p "World Common Lisp Reports"))
                       (:section :id "reports" :style "z-index:999;"
                                 (:section :class "slider__wrapper"
                                           (:section :class "slider__item" :id "google"
                                                     (:section :class "pool"))
                                           (:section :class "slider__item" :id "twitter"
                                                     (:section :class "pool"))
                                           (:section :class "slider__item" :id "github"
                                                     (:section :class "pool"))))
                       ;; js lib
                       (dolist (js js-list)
                         (htm (:script :src js)))))
               (list (get-output-stream-string out)))))))


(defun etirwemos.css (env)
  (declare (ignore env))
  `(200
    (:content-type "text/css")
    (,(cl-css:css
       `((* :margin 0px :padding 0px
            :color ,(css.color :font))
         (html :background ,(css.color :base))
         ("html, body, body > section"
          :width 100% :height 100%)
         ("section,article,div" :box-sizing border-box :box-sizing border-box)
         ("body > section" :position fixed)
         ("section#background" :padding 88px)
         ("section#background > p" :font-size 222px
                                   :color ,(css.color :font))
         ("section#background.start > p" :color ,(css.color :active))
         ("section#reports" :background ,(css.color :base 0.95))
         ("section.slider__item > .pool" :padding 55px :overflow auto
                                         :height 100%)
         ;;;
         ;;; card report
         ;;;
         ("article.report" :padding 11px
                           :float left)
         ("article.report > div" :background ,(css.color :contents 0.33)
                                 :width 466px ;;:width 222px
                                 :height 222px
                                 :border-radius 3px
                                 :padding 22px)
         ("article.report > div:hover" :background ,(css.color :contents 1))
         ("article.report > div p.title" :margin-bottom 22px)
         ("article.next-load" :padding 11px
                              :float left)
         ("article.next-load > div" :background ,(css.color :active 0.11)
                                    :width 222px
                                    :height 222px
                                    :border-radius 3px
                                    :padding 22px
                                    :font-size 55px
                                    :text-align center
                                    :padding-top 33px
                                    )
         ("article.next-load > div:hover" :background ,(css.color :active 0.22))
         ("article.next-load > div:active" :background ,(css.color :active)
                                           :color "#fff")
         ;;;
         ;;; card report github
         ;;;
         ("article.report.github table.timestamp" :margin "8px 0px 8px 0px")
         ("article.report.github table.timestamp td" :font-size 80%)
         ("article.report.github table.timestamp img.icon" :margin-right 11px)
         ("article.report.github p.title" :font-weight bold
                                          :text-overflow ellipsis
                                          :white-space nowrap
                                          :overflow hidden)
         ("article.report.github p.description" :height 66px :overflow-y auto)

         )))))


(defun etirwemos.js (env)
  (declare (ignore env))
  '(200
    (:content-type "application/x-javascript")
    #p"/home/yanqirenshi/prj/etirwemos/src/etirwemos.js"))


;;;
;;; setting function
;;;
(defun refresh-dispach-table ()
  "これ、まぁ仮設じゃけぇ。重複とかエエ感じにせにゃぁいけんね。"
  (setf *dispach-table*
        '((:regex    "/org-mode.css"     :fields nil :function org-mode.css)
          (:regex    "/etirwemos.html"   :fields nil :function etirwemos.html)
          (:regex    "/etirwemos.css"    :fields nil :function etirwemos.css)
          (:regex    "/etirwemos.js"     :fields nil :function etirwemos.js)
          (:regex    "/me.html"          :fields nil :function me.html)
          (:regex    "/me.css"           :fields nil :function me.css)
          (:regex    "/me.js"            :fields nil :function me.js)
          (:regex    "/lib/glide.js"     :fields nil :function glide.js)
          (:regex    "/lib/glide.css"    :fields nil :function glide.css)
          (:regex    "/lib/format4js.js" :fields nil :function format4js.js)
          (:regex    "/yzr.js"           :fields nil :function yzr.js)
          (:regex    "/yzrHtml.js"       :fields nil :function yzrHtml.js)
          ;;;
          ;;; REST-API
          ;;;
          (:regex    "/etirwemos/(.+)\\.js"
           :fields   (:code)
           :function test-path-param.html)
          (:regex    "/etirwemos/search/www/google/start/(\\d+)"
           :fields   (:start)
           :function search-www-json)
          (:regex    "/etirwemos/github/repogitory/search/page/(\\d+)"
           :fields   (:page)
           :function search-github-rep))))
