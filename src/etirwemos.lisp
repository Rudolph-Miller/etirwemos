(in-package :etirwemos)

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




(defun test.html (env)
  (declare (ignore env))
  `( 200
     (:content-type "text/html")
     ,(let ((out (make-string-output-stream)))
           (with-html-output (stream out :prologue t)
             (:html (:head (:title "clr")
                           (:link :rel "stylesheet"
                                  :type "text/css"
                                  :href "/etirwemos.css"))
                    (:body
                     (:section :id "background" :style "z-index:-999;"
                               (:p "World Common Lisp reports"))
                     (:section :id "reports"    :style "z-index:999;"
                               (dotimes (i 30)
                                 (htm (:article :class "report" (:div (fmt "~a" i))))))))
             (list (get-output-stream-string out))))))


(defun test.css (env)
  (declare (ignore env))
  `(200
    (:content-type "text/css")
    (,(cl-css:css
       `((* :margin 0px :padding 0px)
         (html :background ,(css.color :base))
         ("html, body, body > section"
          :width 100% :height 100%)
         ("section,article,div" :box-sizing border-box :box-sizing border-box)
         ("body > section" :position fixed)
         ("section#background" :padding 88px)
         ("section#background > p" :font-size 222px
                                   :color ,(css.color :font))
         ("section#reports" :background ,(css.color :base 0.88)
                            :overflow auto)
         ("article.report" :padding 11px
                           :float left)
         ("article.report > div" :background ,(css.color :contents 0.33)
                                 :width 222px :height 222px
                                 :border-radius 3px
                                 :padding 22px)
         ("article.report > div:hover" :background ,(css.color :contents 1))
         )))))



(defun test-path-param.html (env)
  (declare (ignore env))
  '(200
    (:content-type "text/html")
    ("<html><head></head><body>Hello hanage2</body></html>")))


(defun refresh-dispach-table ()
  "これ、まぁ仮設じゃけぇ。重複とかエエ感じにせにゃぁいけんね。"
  (setf *dispach-table*
        '((:regex    "/org-mode.css"
           :fields   nil
           :function org-mode.css)
          (:regex    "/etirwemos.html"
           :fields   nil
           :function test.html)
          (:regex    "/etirwemos.css"
           :fields   nil
           :function test.css)
          (:regex    "/etirwemos/(\\d+).html"
           :fields   (:code)
           :function test-path-param.html))))
