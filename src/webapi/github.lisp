(in-package :etirwemos)

(defvar *github-user*     nil "Githubユーザー")
(defvar *github-password* nil "Githubユーザーのパスワード")


(defun search-github (&key (page 1) (user *github-user*) (password *github-password*))
  "github-apiで lisp をつこぉとるリポジトリを取得するけぇ。"
  (multiple-value-bind (body status-code headers uri stream must-close reason-phrase)
      (drakma:http-request "https://api.github.com/search/repositories?"
                           :parameters `(("q"     . "language:lisp")
                                         ("sort"  . "updated")
                                         ("order" . "desc")
                                         ("page"  . ,(write-to-string page)))
                           :basic-authorization `(,user ,password))
    (declare (ignore headers uri stream must-close reason-phrase))
    (unless (= 200 status-code)
      (error "error. e=~a,body=~a" status-code (sb-ext:octets-to-string body)))
    (decode-body body)))



(defun github-rep-item2map (item)
  "github-apiから取得したリポジトリのitemをMap形式に変換するけぇね。
json形式に置き換えるためじゃけぇ。"
  (let ((hm (alist-hash-table item)))
    (setf (gethash :owner hm)
          (alist-hash-table (gethash :owner hm)))
    hm))
