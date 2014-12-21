(in-package :etirwemos)

#|

|#
(defvar *bing-primary-account-key* nil "from https://datamarket.azure.com/dataset/explore/bing/searchweb")
(defvar *bing-request-format* "json")
(defvar *bing-base-uri* "https://api.datamarket.azure.com/Bing/SearchWeb/v1/Web")


(defun bing-search-result2list (format body)
  "bing-search で検索して返ってきた bodyを listに変えるけぇ。"
  (cond ((string= format "json")
         (cl-json:decode-json-from-string (sb-ext:octets-to-string body :external-format :utf-8)))
        (t (error "このフォーマットはまだサポートしとらんけぇ。すまんのぉ。format=~a" format))))


(defun search-bing (keyword &key
                              (skip "0")
                              (base-uri *bing-base-uri*)
                              (format *bing-request-format*)
                              (auth-key *bing-primary-account-key*))
  (cond ((null keyword)  (error "keyword くらい何か入れんさいや。"))
        ((null auth-key) (error "auth-key 忘れとりゃせんかね。")))
  (multiple-value-bind (body-or-stream status-code headers uri stream must-close reason-phrase)
      (drakma:http-request base-uri
                           :method :get
                           :parameters `(("Query"   . ,(concatenate 'string "'" keyword "'"))
                                         ("$skip"   . ,skip)
                                         ("$format" . ,format))
                           :basic-authorization `(,auth-key ,auth-key))
    (unless (= status-code 200)
      (error "リクエストに失敗したわ。responce=~a"
             (list :body-or-stream body-or-stream
                   :status-code status-code
                   :headers headers
                   :uri uri
                   :stream stream
                   :must-close must-close
                   :reason-phrase reason-phrase)))
    (bing-search-result2list format body-or-stream)))

