(in-package :etirwemos)

#|

upanishad を利用するためのコードじゃけぇ。

|#


(defvar *data-stor* nil 
  "upanishad がデータ(オブジェクト)をシリアライズしてファイルに保管するためのディレクトリ")


(defvar *pool* nil 
  "upanishad の pool クラスを保管する定数になるけぇ。")


(defun start-up ()
  "upanishad の pool のインスタンスを作成して、upanishad を開始するけぇ。
この表現でええかいね？"
  (when *pool*
    (error "すでに起動しとるけぇ。pool=~a" *pool*))
  (setf *pool* (up:make-pool *data-stor*)))


(defun stop-up ()
  "upanishad の pool を停止させるけぇ。"
  (when *pool*
    (up:close-open-streams *pool*)
    (setf *pool* nil)))


