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



;;;
;;; macro
;;;
(defmacro gen-html (title css-list js-list &body body)
  `(list 200
         '(:content-type "text/html")
         `(,(with-html-output-to-string
             (s)
             (:html (:head (:title ,title)
                           ;; CSS
                           (dolist (css ,css-list)
                             (htm (:link :rel "stylesheet" :type "text/css" :href css))))
                    (:body
                     ,@body
                     ;; js lib
                     (dolist (js ,js-list)
                       (htm (:script :src js)))))))))



(defmacro gen-css (&body body)
  "これだけのためにマクロを使う必要があるのかな。。。まぁ数が増えれば。。"
  `(list 200
         '(:content-type "text/css")
         (list ,@body)))


;;;
;;; main page
;;;
(defun etirwemos.html (env)
  (declare (ignore env))
  (gen-html "CLWR"
      '("/lib/glide.css" "/etirwemos.css" "/etirwemos-anime.css")
      '("https://code.jquery.com/jquery-2.1.3.min.js"
        "https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.8.4/moment.min.js"
        "/yzr.js"
        "/yzrHtml.js"
        "/lib/glide.js"
        "/etirwemos.js")
    (:section :id "background":style "z-index:-999;"
              (:p "Common Lisp World Reports"))
    (:section :id "sky" :style "z-index:-888;")
    (:section :id "start-page"
              :style "z-index:99999;background:#eee"
              (:div
               (:p :class "start-title" "Common Lisp")
               (:p :class "start-title" "World Reports")
               (:button :id "start-button" "START")))
    (:section :id "reports" :style "z-index:999;"
              (:section :class "slider__wrapper"
                        (:section :class "slider__item" :id "google"
                                  (:section :class "container"
                                            (:section :class "pool")))
                        (:section :class "slider__item" :id "twitter"
                                  (:section :class "container"
                                            (:section :class "pool")))
                        (:section :class "slider__item" :id "github"
                                  (:section :class "container"
                                            (:section :class "pool")))))))



(defun etirwemos.css (env)
  (declare (ignore env))
  (gen-css
    (cl-css:css
     `((* :margin 0px :padding 0px
          :color ,(css.color :font))
       (html :background ,(css.color :base)
             :-webkit-animation "myani 60s linear infinite")
       ("html, body, body > section" :width 100% :height 100%)
       ("section,article,div" :box-sizing border-box :box-sizing border-box)
       ("body > section" :position fixed)
       ("section#background" :padding 88px)
       ("section#background > p" :height 100%
                                 :width 100%
                                 :font-size 222px
                                 :color ,(css.color :font))
       ("section#background.start > p" :color ,(css.color :active))
       ("section#reports" :background ,(css.color :base 0.11))
       ("section.slider__item > .container" :padding "33px 11px" :overflow auto
                                            :height 100%)
       ("section.slider__item .pool" :width 1416px
                                     :overflow hidden
                                     :margin-left auto
                                     :margin-right auto)
       ("section#start-page > div" :position fixed
                                   :top 50%
                                   :width 100%
                                   :height 300px
                                   :margin-top "-150px")
       ("p.start-title" :font-size 77px
                        :text-align center
                        :line-height 88px)
       ("button#start-button" :background none
                              :border none
                              :outline none
                              :font-size 33px
                              :line-height 88px
                              :margin auto
                              :display block)
       ("button#start-button:hover" :color ,(css.color :active))
       ("button#start-button:active" :color ,(css.color :active 0.33))
         ;;;
         ;;; card report
         ;;;
       ("article.report" :padding 11px
                         :float left)
       ("article.report > div" :width 450px ;;:width 222px
                               :height 225px
                               :border-radius 3px
                               :padding 22px)
       ("article.report > div"       :background ,(css.color :contents 0.95))
       ("article.report > div:hover" :background ,(css.color :contents 1))
       ("article.report > div.weak"       :background none)
       ("article.report > div.weak:hover" :background ,(css.color :contents 0.2))
       ("article.report > div.weak img" :opacity 0.2)
         ;;; report timestamp
       ("article.report table.timestamp" :margin "8px 0px 8px 0px")
       ("article.report table.timestamp td" :font-size 80%)
       ("article.report table.timestamp tr > td.title" :text-align right)
       ("article.report table.timestamp img.icon" :margin-right 11px)
         ;;; operator card
       ("article.operator" :padding 11px
                           :float left)
       ("article.operator > div" :width 214px
                                 :height 225px
                                 :border-radius 3px
                                 :padding 22px
                                 :font-size 55px
                                 :text-align center
                                 :padding-top 33px)
       ("article.next-load > div"        :background ,(css.color :active 0.11))
       ("article.next-load > div:hover"  :background ,(css.color :active 1)
                                         :color      ,(css.color :contents))
       ("article.next-load > div:active" :background ,(css.color :active 0.33))
       ("article.clear-load > div"        :background ,(css.color :hilight-blue 0.11))
       ("article.clear-load > div:hover"  :background ,(css.color :hilight-blue 1)
                                          :color      ,(css.color :contents))
       ("article.clear-load > div:active" :background ,(css.color :hilight-blue 0.33))
         ;;; google report card
       ("article.report.google p.title" :height 40px
                                        :margin-bottom 11px)
       ("article.report.google p.snippet" :height 125px
                                          :font-size 15px)
         ;;; github report card
       ("article.report.github p.title" :font-weight bold
                                        :text-overflow ellipsis
                                        :white-space nowrap
                                        :overflow hidden
                                        :margin-bottom 11px)
       ("article.report.github p.description" :height 66px :overflow-y auto
                                              :height 91px)
         ;;; twitter report card
       ("article.report.tweet p.text" :height 122px
                                      :overflow hidden)
       ;; glider
       (".slider__arrows-item"        :font-weight bold
                                      :border-radius 3px)
       (".slider__arrows-item"        :background ,(css.color :hilight-greenl 0.11) :padding 20px)
       (".slider__arrows-item:hover"  :background ,(css.color :hilight-greenl 1))
       (".slider__arrows-item:active" :background ,(css.color :hilight-greenl 0.33))
       (".slider__arrows-item--right" :right 3px)
       (".slider__arrows-item--left"  :left 3px)
       ))))
