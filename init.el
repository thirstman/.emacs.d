;; (package-initialize)

(prefer-coding-system 'utf-8)

;; Set frame size
(when window-system
  (setq default-frame-alist `((width . 160)
                              (height . 47)))
  (add-to-list 'exec-path "/usr/local/bin"))

(load "~/.emacs.d/packages.el")
(aggressive-indent-global-mode t)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(auto-save-file-name-transforms (list (list "^.*/\\([^/]+\\)$" "~/.emacs.d/backups/\\1")))
 '(backup-by-copying t)
 '(backup-directory-alist (list (cons "." "~/.emacs.d/backups")))
 '(column-number-mode 1)
 '(create-lockfiles nil)
 '(custom-safe-themes
   (quote
    ("f9aede508e587fe21bcfc0a85e1ec7d27312d9587e686a6f5afdbb0d220eab50" default)))
 '(delete-old-versions t)
 '(flycheck-disabled-checkers (quote (emacs-lisp-checkdoc)))
 '(indent-tabs-mode nil)
 '(inhibit-startup-screen t)
 '(kept-new-versions 20)
 '(kept-old-versions 5)
 '(magit-log-arguments (quote ("--graph" "--color" "--decorate" "-n256")))
 '(package-selected-packages
   (quote
    (yaml-mode which-key uuidgen restclient projectile neotree markdown-mode magit kibit-helper flycheck-pos-tip flycheck-clojure flycheck monokai-theme clj-refactor cider beacon auto-highlight-symbol auto-complete aggressive-indent)))
 '(save-place-mode t)
 '(scroll-bar-mode nil)
 '(show-paren-mode t)
 '(show-trailing-whitespace t)
 '(tool-bar-mode nil)
 '(uniquify-buffer-name-style (quote forward) nil (uniquify))
 '(version-control t)
 '(whitespace-style
   (quote
    (face trailing tabs indentation space-after-tab space-before-tab tab-mark)))
 '(woman-bold-headings t)
 '(woman-fill-column 100)
 '(woman-fill-frame t))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 140 :width normal :family "Fira Code")))))

(server-start)

(mapc (lambda (custom-init-package)
        (load (concat "~/.emacs.d/" custom-init-package ".el")))
      '("auto-complete"
        "auto-highlight-symbol"
        "beacon"
        "clojure"
        "color-theme"
        "elisp"
        "elixir"
        "evil"
        "flycheck"
        "multiple-cursors"
        "restclient"))

(add-hook 'prog-mode-hook 'linum-mode)
