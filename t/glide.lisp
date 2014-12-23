(in-package :etirwemos)

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

(defun test-Glide.html (env)
  (declare (ignore env))
  (let ((css-list '("/test/glide.css" "/lib/glide.css"))
        (js-list  '("https://code.jquery.com/jquery-1.11.2.min.js"
                    ;;"https://code.jquery.com/jquery-2.1.3.min.js"
                    "https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.8.4/moment.min.js"
                    "/yzr.js"
                    "/yzrHtml.js"
                    "/lib/glide.js"
                    "/test/glide.js")))
    `(200
      (:content-type "text/html")
      ,(let ((out (make-string-output-stream)))
            (with-html-output (stream out :prologue t)
              (:html (:head
                      (:title "WCLR")
                      ;; CSS
                      (dolist (css css-list)
                        (htm (:link :rel "stylesheet" :type "text/css" :href css))))
                     (:body
                      (:section :class "slider"
                                (:section :class "slides slider__wrapper"
                                          (:article :class "slide slider__item" :id "google"  (:h1 "Google Costome Search") )
                                          (:article :class "slide slider__item" :id "twitter" (:h1 "Twitter"))
                                          (:article :class "slide slider__item" :id "github"  (:h1 "Github Repository"))))
                      ;; js lib
                      (dolist (js js-list)
                        (htm (:script :src js)))))
              (list (get-output-stream-string out)))))))


(defun test-Glide.css (env)
  (declare (ignore env))
  `(200
    (:content-type "text/css")
    (,(cl-css:css
       `((html :background ,(css.color :base))
         (* :margin 0px :padding 0px :color ,(css.color :font))
         ("html, body" :width 100% :height 100%)
         ;;("section,article,div" :box-sizing border-box :box-sizing border-box)
         )))))

(defun test-Glide.js (env)
  (declare (ignore env))
  '(200
    (:content-type "application/x-javascript")
    #p"/home/yanqirenshi/prj/etirwemos/src/test-glide.js"))
