(require 'deft)
(require 'org)

(setq deft-default-extension "md")

(defun today-date-string ()
  (format-time-string "%F"))

(defun today-deft-journal-entry-name ()
  (concat "todo:" (today-date-string) ".org"))

(defun deft-journal-entry-p (file-name)
  (string-prefix-p "todo:" file-name))

(defun all-deft-journal-entry-names ()
  (cl-remove-if-not #'deft-journal-entry-p
                    (directory-files "~/.deft")))

(defun latest-deft-journal-entry-name ()
  (car (sort (all-deft-journal-entry-names) 'string>)))

(defun org-delete-all-matches (predicate)
  "Delete sublevels of the current tree that match PREDICATE.

PREDICATE is a function of two arguments, BEG and END, which
specify the beginning and end of the headline being considered.
It is called with point positioned at BEG.  The headline will be
deleted if PREDICATE returns non-nil.

If the cursor is not on a headline, try all level 1 trees.  If it
is on a headline, try all direct children."
  (let (re1
        (begm (make-marker))
        (endm (make-marker))
        beg end)
    (if (org-at-heading-p)
        (progn
          (setq re1 (concat "^" (regexp-quote
                                 (make-string
                                  (+ (- (match-end 0) (match-beginning 0) 1)
                                     (if org-odd-levels-only 2 1))
                                  ?*))
                            " "))
          (move-marker begm (point))
          (move-marker endm (org-end-of-subtree t)))
      (setq re1 "^* ")
      (move-marker begm (point-min))
      (move-marker endm (point-max)))
    (save-excursion
      (goto-char begm)
      (while (re-search-forward re1 endm t)
        (setq beg (match-beginning 0)
              end (save-excursion (org-end-of-subtree t) (point)))
        (goto-char beg)
        (if (not (funcall predicate beg end))
            (goto-char end)
          (goto-char beg)
          (if (org-entry-is-done-p)
              (org-cut-subtree)
            (org-delete-all-done)))))))

(defun org-delete-all-done ()
  "Delete sublevels of the current tree without open TODO items.
If the cursor is not on a headline, try all level 1 trees.  If
it is on a headline, try all direct children. "
  (let* ((org-done-regexp (regexp-opt org-done-keywords t))
         (org-done-heading-regexp (format org-heading-keyword-regexp-format org-done-regexp)))
    (org-delete-all-matches
     (lambda (_beg end)
       (let ((case-fold-search nil))
         (re-search-forward org-done-heading-regexp end t))))))

(defun copy-and-find-deft-todos (source destination)
  (copy-file (concat "~/.deft/" source)
             (concat "~/.deft/" destination))
  (find-file (concat "~/.deft/" destination))
  (goto-char (point-min))
  (search-forward "TODO:")
  (kill-line)
  (insert (today-date-string))
  (org-delete-all-done)
  (save-buffer))

(defun find-today-deft-log ()
  (interactive)
  (let ((today-entry (today-deft-journal-entry-name))
        (latest-entry (latest-deft-journal-entry-name)))
    (if (string= today-entry latest-entry)
        (find-file (concat "~/.deft/" today-entry))
      (copy-and-find-deft-todos latest-entry today-entry))))

(defun deft-first-filter-entry (filter)
  (if (null filter)
      ""
    (first filter)))

(defun deft-files-with-search-prefix-in-title (files)
  "If the deft search is for \"foo\", return files whose titles start with \"foo\"."
  (cl-remove-if-not #'(lambda (file)
                        (string-prefix-p (deft-first-filter-entry deft-filter-regexp)
                                         (deft-file-title file)))
                    files))

(defun deft-files-with-search-not-as-prefix-in-title (files)
  "If the deft search is for \"foo\", return files whose titles
include \"foo\" but do not start with \"foo\"."
  (cl-remove-if-not #'(lambda (file)
                        (let ((title (deft-file-title file)))
                          (and
                           (string-match-p (deft-first-filter-entry deft-filter-regexp)
                                           title)
                           (not (string-prefix-p (deft-first-filter-entry deft-filter-regexp)
                                                 title)))))
                    files))

(defun deft-custom-sort (files)
  (let* ((prefixed (deft-files-with-search-prefix-in-title files))
         (included (deft-files-with-search-not-as-prefix-in-title files))
         (therest  (set-difference (set-difference files
                                                   prefixed
                                                   :test 'equal)
                                   included
                                   :test 'equal)))
    (append (deft-sort-files-by-title prefixed)
            (deft-sort-files-by-title included)
            therest)))

(defun deft-filter-increment ()
  "Append character to the filter regexp and update `deft-current-files'."
  (interactive)
  (let ((char last-command-event))
    (if (= char ?\S-\ )
        (setq char ?\s))
    (setq char (char-to-string char))
    (if (and deft-incremental-search (string= char " "))
        (setq deft-filter-regexp (cons "" deft-filter-regexp))
      (progn
        (if (car deft-filter-regexp)
            (setcar deft-filter-regexp (concat (car deft-filter-regexp) char))
          (setq deft-filter-regexp (list char)))
        (setq deft-current-files (deft-filter-files deft-current-files))
        (setq deft-current-files (delq nil deft-current-files))
        (setq deft-current-files (deft-custom-sort deft-current-files))
        (deft-refresh-browser)
        (run-hooks 'deft-filter-hook)))))

(global-set-key (kbd "C-x C-l") 'find-today-deft-log)
(global-set-key [f12] 'deft)
