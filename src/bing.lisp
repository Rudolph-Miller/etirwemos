(in-package :etirwemos)

#|
Bing Search API – Web Results Only を利用する。
<uri>
https://datamarket.azure.com/dataset/explore/bing/searchweb

<参考URL>
1. Schema Tabular Documentation for the Bing Search API
https://onedrive.live.com/view.aspx?resid=9C9479871FBFA822!109&app=Word&authkey=!ACvyZ_MNtngQyCU

2. bing search apiの使い方
http://qiita.com/ysks3n/items/c418919ca436f3104dbe
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

