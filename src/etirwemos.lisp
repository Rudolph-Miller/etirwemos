(in-package :etirwemos)

(defun test.html (env)
  (declare (ignore env))
  '(200
    (:content-type "text/html")
    ("<html><head></head><body>Hello hanage1</body></html>")))

(defun test.css (env)
  (declare (ignore env))
  '(200
    (:content-type "text/css")
    ("* {padding:0px;margin:0px}")))


(defun test-path-param.html (env)
  (declare (ignore env))
  '(200
    (:content-type "text/html")
    ("<html><head></head><body>Hello hanage2</body></html>")))


(defun refresh-dispach-table ()
  "これ、まぁ仮設じゃけぇ。重複とかエエ感じにせにゃぁいけんね。"
  (setf *dispach-table*
        '((:regex    "/etirwemos.html"
           :fields   nil
           :function test.html)
          (:regex    "/etirwemos.css"
           :fields   nil
           :function test.css)
          (:regex    "/etirwemos/(\\d+).html"
           :fields   (:code)
           :function test-path-param.html))))
