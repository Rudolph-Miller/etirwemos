(in-package :etirwemos)

#|

upanishad を利用するためのコードじゃけぇ。

|#


(defvar *data-stor* nil
  "upanishad がデータ(オブジェクト)をシリアライズしてファイルに保管するためのディレクトリです。")


(defvar *pool* nil
  "shinrabanshou の banshou クラスを保管する定数です。")


(defun start-up ()
  "upanishad の pool のインスタンスを作成して、upanishad を開始します。"
  (when *pool*
    (error "すでに起動しとるけぇ。pool=~a" *pool*))
  (setf *pool* (shinra:make-banshou 'shinra:banshou *data-stor*)))


(defun stop-up ()
  "upanishad の pool を停止させます。
*pool* はクローズ時に自動コミットしています。"
  (when *pool*
    (up:snapshot *pool*)
    (up:close-open-streams *pool*)
    (setf *pool* nil)))


