#|
This file is a part of etirwemos project.
Copyright (c) 2014 Satoshi Iwasaki (yanqirenshi@gmail.com)
|#

#|
Author: Satoshi Iwasaki (yanqirenshi@gmail.com)
|#

(in-package :cl-user)
(defpackage etirwemos-asd
  (:use :cl :asdf))
(in-package :etirwemos-asd)

(defsystem etirwemos
  :version "0.1"
  :author "Satoshi Iwasaki"
  :license "LLGPL"
  :depends-on (:upanishad
               :shinrabanshou
               :woo
               :clack
               :cl-ppcre
               :drakma
               :cl-json
               :cl-who
               :cl-css
               :cl-oauth)
  :components ((:module "src"
                        :components
                        ;;
                        ;; package
                        ;;    |
                        ;;    +-------------------------+
                        ;;    |                         |
                        ;; dispatcher                shinrabanshou
                        ;;    |                         |
                        ;;    +--------+                +------------------+------------+--------------+
                        ;;    |        |                |                  |            |              |
                        ;; etirwemos   me            webapi/oauth          |            |              |
                        ;;    |        |                |                  |            |              |
                        ;;    +--------+             webapi/twitter  webapi/bing  webapi/google  webapi/github
                        ;;    |                         :                  |            |              |
                        ;;  clack                       +------------------+------------+--------------+
                        ;;    |                         :
                        ;;    |                      restapi
                        ;;    |                         |
                        ;;    +-------------------------+
                        ;;    |
                        ;;  main
                        ;;
                        ((:file "package")
                         (:file "shinrabanshou"  :depends-on ("package"))
                         (:file "webapi/oauth"   :depends-on ("shinrabanshou"))
                         (:file "webapi/bing"    :depends-on ("shinrabanshou"))
                         (:file "webapi/google"  :depends-on ("shinrabanshou"))
                         (:file "webapi/github"  :depends-on ("shinrabanshou"))
                         (:file "webapi/twitter" :depends-on ("webapi/oauth"))
                         (:file "restapi"        :depends-on ("webapi/twitter" "webapi/bing" "webapi/google" "webapi/github"))
                         (:file "dispatcher"     :depends-on ("package"))
                         (:file "etirwemos"      :depends-on ("dispatcher"))
                         (:file "me"             :depends-on ("dispatcher"))
                         (:file "clack"          :depends-on ("etirwemos" "me"))
                         (:file "main"           :depends-on ("clack" "restapi")))))

  :description ""
  :long-description
  #.(with-open-file (stream (merge-pathnames
                             #p"README.markdown"
                             (or *load-pathname* *compile-file-pathname*))
                            :if-does-not-exist nil
                            :direction :input)
      (when stream
        (let ((seq (make-array (file-length stream)
                               :element-type 'character
                               :fill-pointer t)))
          (setf (fill-pointer seq) (read-sequence seq stream))
          seq)))
  :in-order-to ((test-op (test-op etirwemos-test))))
