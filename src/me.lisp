(in-package :etirwemos)


(defun me.html (env)
  (declare (ignore env))
  (gen-html "Yanqirenshi"
      '("/me.css")
      '("https://code.jquery.com/jquery-2.1.3.min.js"
        "https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.8.4/moment.min.js"
        "/lib/format4js.js"
        "/yzr.js"
        "/yzrHtml.js"
        "/me.js")
    (:section :id "background" :style "z-index:-999;")
    (:section :id "setting"    :style "z-index:0;"
              (:h1 "Yanqirenshi")
              (:div :style "clear:both;")
              (:article :class "card basic"
                        (:h2 "Basic")
                        (:p "岩崎仁是")
                        (:p "yanqirenshi@gmail.com")
                        (:p "Poor Lisper"))
              (:article :class "card twitter"
                        (:h2 "twitter")
                        (:p "Auth time : 9999/99/99 99:99:99")
                        (:p "Name : yanqirenshi")
                        (:div (:a :href "/auth/twitter" "Sing In")
                              (:a "Sing Out"))))))



(defun me.css (env)
  (declare (ignore env))
  `(200
    (:content-type "text/css")
    (,(cl-css:css
       `((* :margin 0px :padding 0px :color ,(css.color :font))
         (html :background ,(css.color :base))
         ("html, body, body > section" :width 100% :height 100% :position fixed :top 0 :left 0)
         ("section,article,div" :box-sizing border-box :box-sizing border-box)
         ;;;
         ;;; setting
         ;;;
         ("section#setting" :padding 33px :overflow hidden)
         ("section#setting > h1" :margin-bottom 33px  :font-size 48px)
         ("article.card" :padding 22px
                         :background ,(css.color :contents 0.33)
                         :border-radius 3px
                         :float left
                         :width 333px :height 333px
                         :margin-right 11px
                         :margin-bottom 11px)
         )))))
