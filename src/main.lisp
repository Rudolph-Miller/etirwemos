(in-package :etirwemos)

#|
ファイルの名前が気にいらんが。。。。。あとで修正するとして。
|#

(defun start ()
  (start-up)
  (start-clack))

(defun stop ()
  (stop-clack)
  (stop-up))
