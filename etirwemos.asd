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
  :depends-on (:woo
               :clack)
  :components ((:module "src"
                :components
                ((:file "package")
		 (:file "dispatcher" :depends-on ("package"))
		 (:file "etirwemos"  :depends-on ("dispatcher"))
		 (:file "handler"    :depends-on ("etirwemos")))))
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
