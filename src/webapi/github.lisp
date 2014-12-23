(in-package :etirwemos)

(defvar *github-user*     nil "Githubユーザー")
(defvar *github-password* nil "Githubユーザーのパスワード")


(defun search-github (&key (page 1) (user *github-user*) (password *github-password*))
  ""
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
