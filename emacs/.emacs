;;---------------------------------
;; emacs 24 package manager
;;---------------------------------

(require 'package)
(add-to-list 'package-archives
	     '("marmalade" . "http://marmalade-repo.org/packages/") t)
(add-to-list 'package-archives
	     '("melpa-stable" . "http://stable.melpa.org/packages/") t)
(package-initialize)

;; refresh on start of emacs (which isn't often)
;;(package-refresh-contents)

(defun install-if-needed (package)
  (unless (package-installed-p package)
    (package-install package)))

;; vendor dir for non-package-managed third-party extensions
(add-to-list 'load-path "~/.emacs.d/vendor")

;;---------------------------------
;; better-defaults
;; https://github.com/technomancy/better-defaults
;;---------------------------------

(install-if-needed 'better-defaults)
(require 'better-defaults)

;;---------------------------------
;; evil
;;---------------------------------

;; don't clobber org-mode tab with evil
;; http://stackoverflow.com/questions/22878668/emacs-org-mode-evil-mode-tab-key-not-working
(setq evil-want-C-i-jump nil)

;; look for symbols instead of words with */#
;; (though this might not be necessary with underscore-is-word-char)
(setq evil-symbol-word-search t)

;; evil requires undo-tree
(install-if-needed 'undo-tree)
(require 'undo-tree)
(add-to-list 'load-path "~/.emacs.d/vendor/evil")
(require 'evil)

;; evil-leader provides the <leader> feature from Vim.
;; "You should enable global-evil-leader-mode before you enable evil-mode,
;; otherwise evil-leader won’t be enabled in initial buffers (*scratch*,
;; *Messages*, ...)"
;;(install-if-needed 'evil-leader)
(add-to-list 'load-path "~/.emacs.d/vendor/evil-leader")
(require 'evil-leader)
(global-evil-leader-mode)

(evil-mode t)

;; (install-if-needed 'evil-matchit)
;; (require 'evil-matchit)
;; (global-evil-matchit-mode 1)

(define-key evil-insert-state-map (kbd "C-u")
  (lambda ()
    (interactive)
    (evil-delete (point-at-bol) (point))))

(evil-leader/set-key
  "g" 'ag-project)

;;---------------------------------
;; ido
;;---------------------------------

(install-if-needed 'ido)
(install-if-needed 'flx-ido)
(require 'ido)
(require 'flx-ido)
(ido-mode 1)
(ido-everywhere 1)
(flx-ido-mode 1)
(setq ido-enable-flex-matching t)
;; disable ido faces to see flx highlights.
(setq ido-use-faces nil)

;;---------------------------------
;; projectile
;; http://batsov.com/projectile/#interactive-commands
;; prefix is C-c p
;; finding files is fast C-c p f
;; kill the cache before find with C-u C-c p f
;; searching in files is very slow C-c p g
;;---------------------------------

(install-if-needed 'projectile)
(require 'projectile)
(projectile-global-mode)

;;---------------------------------
;; helm
;;---------------------------------

;;(require 'helm)
;;(require 'helm-config)
;;
;;;; The default "C-x c" is quite close to "C-x C-c", which quits Emacs.
;;;; Change to "C-c h". Must set "C-c h" globally, because we cannot
;;;; change `helm-command-prefix-key' once `helm-config' is loaded.
;;(global-set-key (kbd "C-c h") 'helm-command-prefix)
;;(global-unset-key (kbd "C-x c"))
;;
;;(helm-mode 1)
;;
;;(global-set-key (kbd "M-x") 'helm-M-x)

;;---------------------------------
;; markdown
;;---------------------------------

(install-if-needed 'markdown-mode)
(require 'markdown-mode)
(add-to-list 'auto-mode-alist '("\\.txt$" . markdown-mode))

;;---------------------------------
;; python
;;---------------------------------

;; This is deprecated, it's already the default in Emacs 24.3+
;; (add-to-list 'load-path "~/.emacs.d/python.el")
;; (require 'python)

;; (add-to-list 'load-path "~/.emacs.d/python-django.el")
;; (require 'python-django)

;;(install-if-needed 'web-mode)
(add-to-list 'load-path "~/.emacs.d/vendor/web-mode")
(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.less\\'" . web-mode))
(setq web-mode-engines-alist
      '(("django" . "\\.html\\'"))
      )
(setq web-mode-content-types-alist
      '(("css" . "\\.less\\'"))
      )

;;---------------------------------
;; misc
;;---------------------------------

(add-to-list 'load-path "~/.emacs.d/vendor/vim-empty-lines-mode")
(require 'vim-empty-lines-mode)
(global-vim-empty-lines-mode)

(set-default 'truncate-lines t)

;; Include underscore as a word character.
;; http://daemianmack.com/?p=45 (though it doesn't get the hook
;; definition right) and comments in
;; https://gist.github.com/timcharper/5034251
(defun underscore-is-word-char ()
  (modify-syntax-entry ?_ "w"))

(add-hook 'change-major-mode-hook 'underscore-is-word-char)

;; http://emacswiki.org/emacs/AutoSave
(setq backup-directory-alist
      `((".*" . "/home/aron/tmp/")))
(setq auto-save-file-name-transforms
      `((".*" "/home/aron/tmp/" t)))

;;---------------------------------
;; themes
;;---------------------------------

(install-if-needed 'ujelly-theme)

(defun load-theme-only (new)
  (dolist (old custom-enabled-themes)
    (disable-theme old))
  (load-theme new)
  ;; Force the background color back to default, see
  ;; http://stackoverflow.com/questions/19054228/emacs-disable-theme-background-color-in-terminal
  (dolist (frame (frame-list))
    (unless (display-graphic-p frame)
      (set-face-background 'default "unspecified-bg" frame))))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("ec5e8299841078b6ff37596360623a5bf5abc9846de23ec8a743c7c68ce11c3e" "4a888176c950a6716b10312cf5878dfb01a57e1b8c0e902590fe9c00b4ab8955" "2d799a277574bd9b546a475deb6ece0668d9ca7ebc2cc6b39c636d8369304b3e" "967c58175840fcea30b56f2a5a326b232d4939393bed59339d21e46cf4798ecf" "72cc9ae08503b8e977801c6d6ec17043b55313cda34bcf0e6921f2f04cf2da56" "1e7e097ec8cb1f8c3a912d7e1e0331caeed49fef6cff220be63bd2a6ba4cc365" "fc5fcb6f1f1c1bc01305694c59a1a861b008c534cae8d0e48e4d5e81ad718bc6" "501caa208affa1145ccbb4b74b6cd66c3091e41c5bb66c677feda9def5eab19c" "d2622a2a2966905a5237b54f35996ca6fda2f79a9253d44793cfe31079e3c92b" default)))
 '(inhibit-startup-screen t)
 '(menu-bar-mode nil)
 '(safe-local-variable-values
   (quote
    ((python-shell-interpreter-args . "/home/aron/src/pp/ppshots.hg/manage.py shell")
     (python-shell-interpreter-args . "/home/aron/src/pp/pp.hg/manage.py shell")
     (python-shell-interpreter-args . "/home/aron/src/pp.hg/pp/manage.py shell")
     (python-shell-completion-string-code . "';'.join(get_ipython().Completer.all_completions('''%s'''))
")
     (python-shell-completion-module-string-code . "';'.join(module_completion('''%s'''))
")
     (python-shell-completion-setup-code . "from IPython.core.completerlib import module_completion")
     (python-shell-interpreter-args . "~/src/pp.hg/pp/manage.py shell")
     (python-shell-interpreter . "python"))))
 '(vc-follow-symlinks nil))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
