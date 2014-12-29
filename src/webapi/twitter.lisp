(in-package :etirwemos)

#|

OAuth で twitter にアクセスします。
oauth-user-access-token

baihu で利用しとったコードなんじゃけど、これを流用しよう。

|#


;;;
;;; Search Tweet
;;; (mapcar #'tweet-2-map (search-tweet))
;;;
(defun search-tweet ()
  (cdr (assoc :STATUSES
              (json:decode-json-from-string
               (sb-ext:octets-to-string
                (oauth:access-protected-resource
                 "https://api.twitter.com/1.1/search/tweets.json"
                 (gen-oauth-access-token (get-oauth-provider :twitter)
                                         (get-access-token-at *pool* :twitter "114195568"))
                 :user-parameters '(("q" . "common lisp"))))))))

(defun tweet-map-2-map (map)
  (maphash #'(lambda (k v)
               (setf (gethash k map)
                     (if (and v (listp v) (atom (first v)))
                         (tweet-map-value-2-map (alist-hash-table v))
                         v)))
           map)
  map)


(defun tweet-2-map (tweet)
  (tweet-map-2-map (alist-hash-table tweet)))




;;
;; 以下サンプル & 実装予定
;;
;; ;;(tweet "yanqirenshi@gmail.com" "TEST: Common Lisp から cl-oauth で ツイート。")
;; (defun tweet (parson message)
;;   "tweet します。"
;;   (json:decode-json-from-string
;;    (sb-ext:octets-to-string
;;     (oauth:access-protected-resource
;;      "https://api.twitter.com/1.1/statuses/update.json"
;;      (oauth-user-access-token :twitter parson)
;;      :request-method :post
;;      :user-parameters (list (cons "status" message))))))


;; (defun retweet (parson id)
;;   "id の tweet を retweet します。"
;;   (json:decode-json-from-string
;;    (sb-ext:octets-to-string
;;     (oauth:access-protected-resource
;;      (format nil "https://api.twitter.com/1.1/statuses/retweet/~a.json" id)
;;      (oauth-user-access-token :twitter parson)
;;      :request-method :post))))
