(defun mailapp-sort-choice (choices)
  (interactive "sSort string: ")
  (setq last-list-sort (mailapp-sort-string->list choices))
  (setq last-viewed-message-count nil)
  (mailapp-goto-last-list last-list-sort))

(defun mailapp-sort-string->list (sort-str)
  (let ((choices (string-to-list sort-str))
        (sort '()))
    (dolist (c choices sort)
      (cond
       ((= c ?a)
        (add-to-list 'sort "account" t))
       ((= c ?A)
        (add-to-list 'sort "account-desc" t))
       ((= c ?d)
        (add-to-list 'sort "date" t))
       ((= c ?D)
        (add-to-list 'sort "date-desc" t))
       ((= c ?f)
        (add-to-list 'sort "from" t))
       ((= c ?F)
        (add-to-list 'sort "from-desc" t))
       ((= c ?s)
        (add-to-list 'sort "subject" t))
       ((= c ?S)
        (add-to-list 'sort "subject-desc" t))))))

(defun mailapp-sort (msgs sort)
  (let ((sorted (list))
        (count 0)
        temp)
      (if (= count (1- (length sort)))
          (setq temp (mailapp-sort-list msgs (nth count sort)))
        (setq temp (mailapp-sort-list msgs (nth count sort) (nthcdr (1+ count) 
                                                                    sort))))
      (setq sorted (append sorted temp))
      (setq count (1+ count))
    sorted))

(defun mailapp-sort-split (msg-list sort &optional nextsort)
  (let ((sorted-split (list))
        (sort-key (first (split-string sort "-")))
        (values (list))
        temp)
    (dolist (msg msg-list)
      (unless (find (cdr (assoc sort-key msg)) values :test 'equal)
        (setq values (add-to-list 'values (cdr (assoc sort-key msg)) t))))
    (dolist (value values)
      (setq temp (list))
      (dolist (msg msg-list)
        (unless (or (find msg sorted-split :test 'equal)
                    (find msg temp :test 'equal))
          (when (equal (cdr (assoc sort-key msg)) value)
            (setq temp (append temp (list msg))))))
      (when nextsort
        (setq temp (mailapp-sort temp nextsort)))
      (setq sorted-split (append sorted-split temp)))
    sorted-split))

(defun mailapp-sort-list (msg-list sort &optional nextsort)
  (let ((func (concat "mailapp-sort-" sort))
        sorted
        (sorted-split (list)))
    (setq sorted (sort msg-list (intern func)))
    (setq sorted-split (mailapp-sort-split sorted sort nextsort))
    sorted-split))

(defun mailapp-sort-text (arg1 arg2 key &optional desc prep-func)
  (let ((val1 
         (if prep-func 
             (funcall prep-func (cdr (assoc key arg1))) 
           (cdr (assoc key arg1))))
        (val2 
         (if prep-func 
             (funcall prep-func (cdr (assoc key arg2))) 
           (cdr (assoc key arg2)))))
    (if desc
        (if (string< val2 val1) t nil)
      (if (string< val1 val2) t nil))))

(defun mailapp-sort-account (val1 val2 &optional desc)
  (mailapp-sort-text val1 val2 'account desc 'downcase))

(defun mailapp-sort-account-desc (val1 val2)
  (mailapp-sort-account val1 val2 t))

(defun mailapp-sort-date (val1 val2 &optional desc)
  (mailapp-sort-text val1 val2 'date desc 'format-date-for-sort))

(defun mailapp-sort-date-desc (val1 val2)
  (mailapp-sort-date val1 val2 t))

(defun mailapp-sort-from (val1 val2 &optional desc)
  (mailapp-sort-text val1 val2 'from desc 'downcase))

(defun mailapp-sort-from-desc (val1 val2)
  (mailapp-sort-from val1 val2 t))

(defun mailapp-sort-subject (val1 val2 &optional desc)
    (mailapp-sort-text val1 val2 'subject desc 'downcase))

(defun mailapp-sort-subject-desc (val1 val2)
  (mailapp-sort-subject val1 val2 t))

(defun format-date-for-sort (date-string)
  (let ((day-string "Monday, \\|Tuesday, \\|Wednesday, \\|Thursday, \\|Friday, \\|Saturday, \\|Sunday, "))
    (setq date-string (replace-regexp-in-string day-string "" date-string)))
  (setq date-string (replace-regexp-in-string "January " "01-" date-string))
  (setq date-string (replace-regexp-in-string "February " "02-" date-string))
  (setq date-string (replace-regexp-in-string "March " "03-" date-string))
  (setq date-string (replace-regexp-in-string "April " "04-" date-string))
  (setq date-string (replace-regexp-in-string "May " "05-" date-string))
  (setq date-string (replace-regexp-in-string "June " "06-" date-string))
  (setq date-string (replace-regexp-in-string "July " "07-" date-string))
  (setq date-string (replace-regexp-in-string "August " "08-" date-string))
  (setq date-string (replace-regexp-in-string "September " "09-" date-string))
  (setq date-string (replace-regexp-in-string "October " "10-" date-string))
  (setq date-string (replace-regexp-in-string "November " "11-" date-string))
  (setq date-string (replace-regexp-in-string "December " "12-" date-string))

  (setq date-string (replace-regexp-in-string "-\\([1-9]\\), " "-0\\1-" date-string))
  (setq date-string (replace-regexp-in-string ", " "-" date-string))
  (setq date-string (replace-regexp-in-string " \\([1-9]\\):" " 0\\1:" date-string))
  (setq date-string (replace-regexp-in-string " 12:" " 00:" date-string))
  (setq date-string (replace-regexp-in-string " \\(.*\\) \\([AP]M\\)" " \\2 \\1" date-string))
  (setq date-+string (replace-regexp-in-string "\\(.*\\)-\\([0-9]\\{4,4\\}\\)\\(.*\\)" "\\2-\\1\\3" date-string))
  (setq date-string (replace-regexp-in-string "-\\([1-9]\\) " "-0\\1 " date-string))
  date-string)
 
(provide 'mailapp-sort)