(in-package :etirwemos)

#|

upanishad を利用するためのコードじゃけぇ。

|#


(defvar *data-stor* nil
  "upanishad がデータ(オブジェクト)をシリアライズしてファイルに保管するためのディレクトリ")


(defvar *pool* nil
  "shinrabanshou の banshou クラスを保管する定数になるけぇ。
banshou ってのは upanishad の poolクラスのサブクラスじゃけぇね。")


(defun start-up ()
  "upanishad の pool のインスタンスを作成して、upanishad を開始するけぇ。
この表現でええかいね？"
  (when *pool*
    (error "すでに起動しとるけぇ。pool=~a" *pool*))
  (setf *pool* (shinra:make-banshou 'shinra:banshou *data-stor*)))


(defun stop-up ()
  "upanishad の pool を停止させるけぇ。
*pool* はクローズ時に自動コミットするようにしとるけぇ。
選べるようにした方がええんじゃろうか。"
  (when *pool*
    (up:snapshot *pool*)
    (up:close-open-streams *pool*)
    (setf *pool* nil)))


