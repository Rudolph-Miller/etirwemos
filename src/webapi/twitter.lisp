(in-package :etirwemos)

#|

OAuth で twitter にアクセスします。
oauth-user-access-token

baihu で利用しとったコードなんじゃけど、これを流用しよう。

|#



;; (timeline :twitter "yanqirenshi@gmail.com" :type :home)
;; (timeline :twitter "yanqirenshi@gmail.com" :type :home :since-id 382685697775132700)
(defun timeline (service parson &key (type :home) (since-id nil) (count 20))
  "タイムラインを取得します。"
  (unless (member service '(:twitter)))
  (let ((uri (second (assoc type '((:mentions       "https://api.twitter.com/1.1/statuses/mentions_timeline.json")
                                   (:user           "https://api.twitter.com/1.1/statuses/user_timeline.json")
                                   (:home           "https://api.twitter.com/1.1/statuses/home_timeline.json")
                                   (:retweets-of-me "https://api.twitter.com/1.1/statuses/retweets_of_me.json"))))))
    (json:decode-json-from-string
     (sb-ext:octets-to-string
      (oauth:access-protected-resource
       (if since-id
           (format nil "~a?since_id=~a&count=~a" uri since-id count)
           (format nil "~a?count=~a"             uri          count))
       (oauth-user-access-token service parson))))))


;;(tweet "yanqirenshi@gmail.com" "TEST: Common Lisp から cl-oauth で ツイート。")
(defun tweet (parson message)
  "tweet します。"
  (json:decode-json-from-string
   (sb-ext:octets-to-string
    (oauth:access-protected-resource
     "https://api.twitter.com/1.1/statuses/update.json"
     (oauth-user-access-token :twitter parson)
     :request-method :post
     :user-parameters (list (cons "status" message))))))

(defun retweet (parson id)
  "id の tweet を retweet します。"
  (json:decode-json-from-string
   (sb-ext:octets-to-string
    (oauth:access-protected-resource
     (format nil "https://api.twitter.com/1.1/statuses/retweet/~a.json" id)
     (oauth-user-access-token :twitter parson)
     :request-method :post))))


(defun hateb-tag (parson)
  (json:decode-json-from-string
   (sb-ext:octets-to-string
    (oauth:access-protected-resource
     "http://api.b.hatena.ne.jp/1/my/tags"
     (oauth-user-access-token :hatena parson)))))
