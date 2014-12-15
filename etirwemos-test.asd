#|
  This file is a part of etirwemos project.
  Copyright (c) 2014 Satoshi Iwasaki (yanqirenshi@gmail.com)
|#

(in-package :cl-user)
(defpackage etirwemos-test-asd
  (:use :cl :asdf))
(in-package :etirwemos-test-asd)

(defsystem etirwemos-test
  :author "Satoshi Iwasaki"
  :license "LLGPL"
  :depends-on (:etirwemos
               :prove)
  :components ((:module "t"
                :components
                ((:test-file "etirwemos"))))

  :defsystem-depends-on (:prove-asdf)
  :perform (test-op :after (op c)
                    (funcall (intern #.(string :run-test-system) :prove-asdf) c)
                    (asdf:clear-system c)))
