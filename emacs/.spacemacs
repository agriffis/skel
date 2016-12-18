;; -*- mode: emacs-lisp -*-

(defun dotspacemacs/layers ()
  "Configuration Layers declaration."

  (setq-default
   ;; List of additional paths where to look for configuration layers.
   ;; Paths must have a trailing slash (ie. `~/.mycontribs/')
   dotspacemacs-configuration-layer-path '()

   ;; List of configuration layers to load. If it is the symbol `all' instead
   ;; of a list then all discovered layers will be installed.
   dotspacemacs-configuration-layers
   '(
     auto-completion
     better-defaults

     git
     github
     ;; version-control

     (clojure :variables
              clojure-enable-fancify-symbols t)
     django
     emacs-lisp
     html
     javascript
     markdown
     org
     python
     react
     ruby
     vimscript
     yaml

     (syntax-checking :variables
                      syntax-checking-enable-by-default nil)
     )

   ;; List of additional packages that will be installed wihout being
   ;; wrapped in a layer. If you need some configuration for these
   ;; packages then consider to create a layer, you can also put the
   ;; configuration in `dotspacemacs/config'.
   dotspacemacs-additional-packages
   '(
     editorconfig
     ;org-journal
     color-theme-solarized ;; https://github.com/syl20bnr/spacemacs/issues/1269#issuecomment-198309213
     )

   ;; A list of packages and/or extensions that will not be install and loaded.
   dotspacemacs-excluded-packages
   '(
     eldoc        ; too slow
     smartparens
     toxi-theme   ; broken
     rainbow-delimeters  ; gets confused by unbalanced parens in html
     org-bullets  ; prefer plain-jane asterisks
     )

   ;; If non-nil spacemacs will delete any orphan packages, i.e. packages that
   ;; are declared in a layer which is not a member of
   ;; the list `dotspacemacs-configuration-layers'
   dotspacemacs-delete-orphan-packages t))

(defun dotspacemacs/init ()
  "Initialization function.
This function is called at the very startup of Spacemacs initialization
before layers configuration."
  ;; This setq-default sexp is an exhaustive list of all the supported
  ;; spacemacs settings.
  (setq-default
   ;; Either `vim' or `emacs'. Evil is always enabled but if the variable
   ;; is `emacs' then the `holy-mode' is enabled at startup.
   dotspacemacs-editing-style 'vim

   ;; If non nil output loading progress in `*Messages*' buffer.
   dotspacemacs-verbose-loading nil

   ;; Specify the startup banner. Default value is `official', it displays
   ;; the official spacemacs logo. An integer value is the index of text
   ;; banner, `random' chooses a random text banner in `core/banners'
   ;; directory. A string value must be a path to an image format supported
   ;; by your Emacs build.
   ;; If the value is nil then no banner is displayed.
   dotspacemacs-startup-banner 'official

   ;; List of items to show in the startup buffer. If nil it is disabled.
   ;; Possible values are: `recents' `bookmarks' `projects'."
   dotspacemacs-startup-lists '(recents projects)

   ;; List of themes, the first of the list is loaded when spacemacs starts.
   ;; Press <SPC> T n to cycle to the next theme in the list (works great
   ;; with 2 themes variants, one dark and one light)
;; dotspacemacs-themes '(spacemacs-light
;;                       spacemacs-dark
;;                       ;; inkpot
;;                       ;; ujelly
;;                       ;; flatui
;;                       )
   ;; If non nil the cursor color matches the state color.
   dotspacemacs-colorize-cursor-according-to-state t

   ;; Default font. `powerline-scale' allows to quickly tweak the mode-line
   ;; size to make separators look not too crappy.
   dotspacemacs-default-font '("DejaVu Sans Mono"
                               :size 10
                               :weight normal
                               :width normal
                               :powerline-scale 1.1)

   ;; The leader key
   dotspacemacs-leader-key "SPC"
   ;; The leader key accessible in `emacs state' and `insert state'
   dotspacemacs-emacs-leader-key "M-m"
   ;; Major mode leader key is a shortcut key which is the equivalent of
   ;; pressing `<leader> m`. Set it to `nil` to disable it.
   dotspacemacs-major-mode-leader-key ","
   ;; Major mode leader key accessible in `emacs state' and `insert state'
   dotspacemacs-major-mode-emacs-leader-key "C-M-m"
   ;; The command key used for Evil commands (ex-commands) and
   ;; Emacs commands (M-x).
   ;; By default the command key is `:' so ex-commands are executed like in Vim
   ;; with `:' and Emacs commands are executed with `<leader> :'.
   dotspacemacs-command-key ":"
   ;; If non nil then `ido' replaces `helm' for some commands. For now only
   ;; `find-files' (SPC f f) is replaced.
   dotspacemacs-use-ido nil
   ;; If non nil the paste micro-state is enabled. When enabled pressing `p`
   ;; several times cycle between the kill ring content.
   dotspacemacs-enable-paste-micro-state nil
   ;; Guide-key delay in seconds. The Guide-key is the popup buffer listing
   ;; the commands bound to the current keystrokes.
   dotspacemacs-guide-key-delay 0.4
   ;; If non nil a progress bar is displayed when spacemacs is loading. This
   ;; may increase the boot time on some systems and emacs builds, set it to
   ;; nil ;; to boost the loading time.
   dotspacemacs-loading-progress-bar t
   ;; If non nil the frame is fullscreen when Emacs starts up.
   ;; (Emacs 24.4+ only)
   dotspacemacs-fullscreen-at-startup nil
   ;; If non nil `spacemacs/toggle-fullscreen' will not use native fullscreen.
   ;; Use to disable fullscreen animations in OSX."
   dotspacemacs-fullscreen-use-non-native nil
   ;; If non nil the frame is maximized when Emacs starts up.
   ;; Takes effect only if `dotspacemacs-fullscreen-at-startup' is nil.
   ;; (Emacs 24.4+ only)
   dotspacemacs-maximized-at-startup nil
   ;; A value from the range (0..100), in increasing opacity, which describes
   ;; the transparency level of a frame when it's active or selected.
   ;; Transparency can be toggled through `toggle-transparency'.
   dotspacemacs-active-transparency 90
   ;; A value from the range (0..100), in increasing opacity, which describes
   ;; the transparency level of a frame when it's inactive or deselected.
   ;; Transparency can be toggled through `toggle-transparency'.
   dotspacemacs-inactive-transparency 90
   ;; If non nil unicode symbols are displayed in the mode line.
   dotspacemacs-mode-line-unicode-symbols t
   ;; If non nil smooth scrolling (native-scrolling) is enabled. Smooth
   ;; scrolling overrides the default behavior of Emacs which recenters the
   ;; point when it reaches the top or bottom of the screen.
   dotspacemacs-smooth-scrolling nil
   ;; If non-nil smartparens-strict-mode will be enabled in programming modes.
   dotspacemacs-smartparens-strict-mode nil
   ;; Select a scope to highlight delimiters. Possible value is `all',
   ;; `current' or `nil'. Default is `all'
   dotspacemacs-highlight-delimiters 'all
   ;; If non nil advises quit functions to keep server open when quitting.
   dotspacemacs-persistent-server t
   ;; List of search tool executable names. Spacemacs uses the first installed
   ;; tool of the list. Supported tools are `ag', `pt', `ack' and `grep'.
   dotspacemacs-search-tools '("rg" "ag" "pt" "ack" "grep")
   ;; The default package repository used if no explicit repository has been
   ;; specified with an installed package.
   ;; Not used for now.
   dotspacemacs-default-package-repository nil

   )
  ;; User initialization goes here
  (setq-default
   evil-escape-key-sequence "~!"
   web-mode-enable-auto-closing t
   )
  )

(defun dotspacemacs/user-config ()
  "Configuration function.
 This function is called at the very end of Spacemacs initialization after
layers configuration."
  ;; Don't use unicode symbols for diminished minor modes
  (setq dotspacemacs-mode-line-unicode-symbols nil)

  ;; https://github.com/syl20bnr/spacemacs/issues/6097
  (setq scroll-conservatively 101
        scroll-margin 0
        scroll-preserve-screen-position 't)

  (global-hl-line-mode -1)
  (set-default 'truncate-lines t)
  (setq evil-move-beyond-eol nil)
  ;; (global-diff-hl-mode -1)

  ;; customize company-mode to avoid idle completion, and start manual
  ;; completion with C-space
  (setq company-idle-delay nil)  ; no idle completion
  (define-key evil-insert-state-map (kbd "C-@") 'company-complete)

  ;; don't intercept clicks
  (xterm-mouse-mode -1)

  ;; https://github.com/syl20bnr/spacemacs/issues/3064
  ;; now default in Emacs 25
  ;; https://github.com/emacs-mirror/emacs/blob/master/etc/NEWS.25
  ;(require 'bracketed-paste)
  ;(bracketed-paste-enable)

  (require 'editorconfig)
  (editorconfig-mode 1)

  ;; https://www.emacswiki.org/emacs/OrgJournal
  ;(require 'org-journal)
  ;(setq org-journal-dir "~/Dropbox/Journal"
  ;      org-journal-file-format "%Y%m%d.org")
  ;(evil-leader/set-key
  ;  "jj" 'org-journal-new-entry)

  ;; Copy the Spacemacs bindings for org-mode to org-journal-mode. This has to
  ;; happen before adding new entries, since spacemacs//init-leader-mode-map
  ;; checks to see if the map exists already.
  (setq spacemacs-org-journal-mode-map (copy-keymap spacemacs-org-mode-map))
  (spacemacs//init-leader-mode-map 'org-journal-mode 'spacemacs-org-journal-mode-map)

  (evil-leader/set-key-for-mode 'org-journal-mode
    "jn" 'org-journal-open-next-entry
    "jp" 'org-journal-open-previous-entry)

  ;; Prefer the unindented original presentation
  (setq org-startup-indented nil)

  ;; Assume text files are markdown
  (add-to-list 'auto-mode-alist '("\\.txt\\'" . markdown-mode))

  ;; Don't highlight smartparens overlays, because they seem to use the same
  ;; fg/bg so it's just unreadable.
  (setq sp-highlight-pair-overlay nil)
  (setq sp-highlight-wrap-overlay nil)
  (setq sp-highlight-wrap-tag-overlay nil)

  ;; Assume JS files are react, since this does ES6
  (add-to-list 'auto-mode-alist '("\\.js\\'" . react-mode))

  ;; These are defaults. They can be overridden if there's a .editorconfig
  ;; present.
  (setq web-mode-markup-indent-offset 4)
  (setq web-mode-css-indent-offset 4)
  (setq web-mode-code-indent-offset 4)
  (setq web-mode-style-padding 4)
  (setq web-mode-script-padding 4)
  (setq web-mode-block-padding 4)
  (setq web-mode-comment-style 2)  ; server comment
  (setq web-mode-engines-alist '(("django" . "\\.html\\'")))
  (setq js2-strict-missing-semi-warning nil)
  (setq js-switch-indent-offset 2)

  ;; Include underscore as a word character.
  ;; http://daemianmack.com/?p=45 (though it doesn't get the hook
  ;; definition right) and comments in
  ;; https://gist.github.com/timcharper/5034251
  (defun underscore-is-word-char ()
    (modify-syntax-entry ?_ "w"))

  (add-hook 'change-major-mode-hook 'underscore-is-word-char)
)

;; (defun frame-restore-background (frame)
;;   (unless (display-graphic-p frame)
;;     ;; Force the background color back to default, see
;;     ;; http://stackoverflow.com/questions/19054228/emacs-disable-theme-background-color-in-terminal
;;     (set-face-background 'default "unspecified-bg" frame)))
;; (defun restore-background (orig-fun &rest args)
;;   (let ((res (apply orig-fun args)))
;;     (dolist (frame (frame-list))
;;       (frame-restore-background frame))
;;     res))
;; (advice-add 'load-theme :around #'restore-background)
;; (add-hook 'after-make-frame-functions 'frame-restore-background)

;; http://emacs.stackexchange.com/questions/3112/how-to-reset-color-theme
(defadvice load-theme (before theme-dont-propagate activate)
  (mapcar #'disable-theme custom-enabled-themes))

;; Do not write anything past this comment. This is where Emacs will
;; auto-generate custom variable definitions.
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["#bcbcbc" "#d70008" "#5faf00" "#875f00" "#268bd2" "#800080" "#008080" "#5f5f87"])
 '(custom-safe-themes
   (quote
    ("a276998eb08b2d51d1b4fe74e885c56e33124a44e56b9276e670a61f694f03a4" "016d14b6ac7cac14a33979d4d56bd15f5ae98db28f251ad85686373f4606431d" "be4025b1954e4ac2a6d584ccfa7141334ddd78423399447b96b6fa582f206194" "45712b65018922c9173439d9b1b193cb406f725f14d02c8c33e0d2cdad844613" "8db4b03b9ae654d4a57804286eb3e332725c84d7cdab38463cb6b97d5762ad26" "4aee8551b53a43a883cb0b7f3255d6859d766b6c5e14bcb01bed572fcbef4328" "4cf3221feff536e2b3385209e9b9dc4c2e0818a69a1cdb4b522756bcdf4e00a4" "bffa9739ce0752a37d9b1eee78fc00ba159748f50dc328af4be661484848e476" "fa2b58bb98b62c3b8cf3b6f02f058ef7827a8e497125de0254f56e373abee088" "3f78849e36a0a457ad71c1bda01001e3e197fe1837cb6eaa829eb37f0a4bdad5" "c35c0effa648fd320300f3d45696c640a92bdc7cf0429d002a96bda2b42ce966" "8aebf25556399b58091e533e455dd50a6a9cba958cc4ebb0aab175863c25b9a4" "d725097d2547e9205ab6c8b034d6971c2f0fc64ae5f357b61b7de411ca3e7ab2" "3038a172e5b633d0b1ee284e6520a73035d0cb52f28b1708e22b394577ad2df1" default)))
 '(diff-hl-margin-mode nil)
 '(evil-want-Y-yank-to-eol nil)
 '(global-diff-hl-mode t)
 '(global-git-gutter-mode t)
 '(highlight-changes-colors (quote ("#d33682" "#6c71c4")))
 '(highlight-symbol-colors
   (--map
    (solarized-color-blend it "#002b36" 0.25)
    (quote
     ("#b58900" "#2aa198" "#dc322f" "#6c71c4" "#859900" "#cb4b16" "#268bd2"))))
 '(highlight-symbol-foreground-color "#93a1a1")
 '(highlight-tail-colors
   (quote
    (("#073642" . 0)
     ("#546E00" . 20)
     ("#00736F" . 30)
     ("#00629D" . 50)
     ("#7B6000" . 60)
     ("#8B2C02" . 70)
     ("#93115C" . 85)
     ("#073642" . 100))))
 '(hl-bg-colors
   (quote
    ("#7B6000" "#8B2C02" "#990A1B" "#93115C" "#3F4D91" "#00629D" "#00736F" "#546E00")))
 '(hl-fg-colors
   (quote
    ("#002b36" "#002b36" "#002b36" "#002b36" "#002b36" "#002b36" "#002b36" "#002b36")))
 '(js-switch-indent-offset 2)
 '(magit-diff-use-overlays nil)
 '(magit-use-overlays nil)
 '(package-selected-packages
   (quote
    (powerline spinner org highlight gh multiple-cursors inflections anzu async dash minitest hide-comnt helm-purpose window-purpose imenu-list yaml-mode yasnippet magit-popup clojure-mode pug-mode ac-ispell ace-jump-helm-line ace-link ace-window adaptive-wrap afternoon-theme aggressive-indent alect-themes ample-theme ample-zen-theme anaconda-mode anti-zenburn-theme apropospriate-theme auto-compile auto-complete auto-highlight-symbol auto-yasnippet badwolf-theme birds-of-paradise-plus-theme bracketed-paste bubbleberry-theme buffer-move bundler busybee-theme cherry-blossom-theme chruby cider cider-eval-sexp-fu clean-aindent-mode clj-refactor clojure-snippets clues-theme coffee-mode color-theme color-theme-sanityinc-solarized color-theme-sanityinc-tomorrow color-theme-solarized colorsarenice-theme column-enforce-mode company company-anaconda company-quickhelp company-statistics company-tern company-web cyberpunk-theme cython-mode dactyl-mode dakrone-theme darkburn-theme darkmine-theme darkokai-theme darktooth-theme dash-functional define-word django-theme dracula-theme dumb-jump editorconfig elisp-slime-nav emmet-mode espresso-theme evil evil-anzu evil-args evil-ediff evil-escape evil-exchange evil-iedit-state evil-indent-plus evil-lisp-state evil-magit evil-matchit evil-mc evil-nerd-commenter evil-numbers evil-search-highlight-persist evil-surround evil-tutor evil-unimpaired evil-visual-mark-mode evil-visualstar exec-path-from-shell expand-region eyebrowse f fancy-battery farmhouse-theme fill-column-indicator firebelly-theme flatland-theme flatui-theme flx-ido flycheck flycheck-pos-tip gandalf-theme gh-md gist git-commit git-link git-messenger git-timemachine gitattributes-mode gitconfig-mode github-browse-file github-clone github-search gnuplot golden-ratio google-translate gotham-theme grandshell-theme gruber-darker-theme gruvbox-theme hc-zenburn-theme helm helm-ag helm-c-yasnippet helm-company helm-core helm-css-scss helm-descbinds helm-flx helm-gitignore helm-make helm-mode-manager helm-projectile helm-pydoc helm-swoop helm-themes help-fns+ hemisu-theme heroku-theme highlight-indentation highlight-numbers highlight-parentheses hl-todo ht htmlize hungry-delete hy-mode hydra ido-vertical-mode iedit indent-guide inf-ruby info+ inkpot-theme ir-black-theme jade-mode jazz-theme jbeans-theme js-doc js2-mode js2-refactor json-mode json-reformat json-snatcher less-css-mode leuven-theme light-soap-theme link-hint linum-relative live-py-mode livid-mode lorem-ipsum lush-theme macrostep magit magit-gh-pulls magit-gitflow majapahit-theme markdown-mode markdown-toc material-theme minimal-theme mmm-mode moe-theme molokai-theme monochrome-theme monokai-theme move-text mustang-theme mwim naquadah-theme neotree niflheim-theme noctilux-theme obsidian-theme occidental-theme oldlace-theme omtose-phellack-theme open-junk-file org-download org-journal org-plus-contrib org-pomodoro org-present org-projectile org-repo-todo organic-green-theme orgit page-break-lines paradox pastels-on-dark-theme pcre2el persp-mode phoenix-dark-mono-theme phoenix-dark-pink-theme pip-requirements planet-theme pony-mode popwin professional-theme projectile purple-haze-theme py-isort py-yapf pyenv-mode pytest pyvenv quelpa railscasts-theme rainbow-delimiters rake rbenv request restart-emacs reverse-theme robe rspec-mode rubocop ruby-test-mode ruby-tools rvm s sass-mode scss-mode seti-theme simple-httpd skewer-mode slim-mode smartparens smeargle smooth-scrolling smyx-theme soft-charcoal-theme soft-morning-theme soft-stone-theme solarized-theme soothe-theme spacegray-theme spaceline spacemacs-theme stekene-theme subatomic-theme subatomic256-theme sublime-themes sunny-day-theme tagedit tango-2-theme tango-plus-theme tangotango-theme tao-theme tern toc-org tronesque-theme twilight-anti-bright-theme twilight-bright-theme twilight-theme ujelly-theme underwater-theme undo-tree use-package uuidgen vi-tilde-fringe vimrc-mode volatile-highlights web-beautify web-mode which-key window-numbering with-editor ws-butler yapfify zen-and-art-theme zenburn-theme zonokai-theme)))
 '(pos-tip-background-color "#073642")
 '(pos-tip-foreground-color "#93a1a1")
 '(ring-bell-function (quote ignore))
 '(safe-local-variable-values
   (quote
    ((python-shell-virtualenv-path . "/home/aron/.virtualenvs/pp")
     (python-shell-virtualenv-path . "/home/aron/.virtualenvs/fec-cms")
     (encoding . utf-8))))
 '(smartrep-mode-line-active-bg (solarized-color-blend "#859900" "#073642" 0.2))
 '(term-default-bg-color "#002b36")
 '(term-default-fg-color "#839496")
 '(vc-annotate-background nil)
 '(vc-annotate-color-map
   (quote
    ((20 . "#f36c60")
     (40 . "#ff9800")
     (60 . "#fff59d")
     (80 . "#8bc34a")
     (100 . "#81d4fa")
     (120 . "#4dd0e1")
     (140 . "#b39ddb")
     (160 . "#f36c60")
     (180 . "#ff9800")
     (200 . "#fff59d")
     (220 . "#8bc34a")
     (240 . "#81d4fa")
     (260 . "#4dd0e1")
     (280 . "#b39ddb")
     (300 . "#f36c60")
     (320 . "#ff9800")
     (340 . "#fff59d")
     (360 . "#8bc34a"))))
 '(vc-annotate-very-old-color nil)
 '(weechat-color-list
   (quote
    (unspecified "#002b36" "#073642" "#990A1B" "#dc322f" "#546E00" "#859900" "#7B6000" "#b58900" "#00629D" "#268bd2" "#93115C" "#d33682" "#00736F" "#2aa198" "#839496" "#657b83"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:background nil))))
 '(company-tooltip-common ((t (:inherit company-tooltip :weight bold :underline nil))))
 '(company-tooltip-common-selection ((t (:inherit company-tooltip-selection :weight bold :underline nil))))
 '(diff-hl-change ((t (:foreground "yellow"))))
 '(diff-hl-delete ((t (:inherit diff-removed :foreground "red"))))
 '(diff-hl-insert ((t (:inherit diff-added :foreground "blue")))))
(defun dotspacemacs/emacs-custom-settings ()
  "Emacs custom settings.
This is an auto-generated function, do not modify its content directly, use
Emacs customize menu instead.
This function is called at the very end of Spacemacs initialization."
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["#bcbcbc" "#d70008" "#5faf00" "#875f00" "#268bd2" "#800080" "#008080" "#5f5f87"])
 '(custom-safe-themes
   (quote
    ("a276998eb08b2d51d1b4fe74e885c56e33124a44e56b9276e670a61f694f03a4" "016d14b6ac7cac14a33979d4d56bd15f5ae98db28f251ad85686373f4606431d" "be4025b1954e4ac2a6d584ccfa7141334ddd78423399447b96b6fa582f206194" "45712b65018922c9173439d9b1b193cb406f725f14d02c8c33e0d2cdad844613" "8db4b03b9ae654d4a57804286eb3e332725c84d7cdab38463cb6b97d5762ad26" "4aee8551b53a43a883cb0b7f3255d6859d766b6c5e14bcb01bed572fcbef4328" "4cf3221feff536e2b3385209e9b9dc4c2e0818a69a1cdb4b522756bcdf4e00a4" "bffa9739ce0752a37d9b1eee78fc00ba159748f50dc328af4be661484848e476" "fa2b58bb98b62c3b8cf3b6f02f058ef7827a8e497125de0254f56e373abee088" "3f78849e36a0a457ad71c1bda01001e3e197fe1837cb6eaa829eb37f0a4bdad5" "c35c0effa648fd320300f3d45696c640a92bdc7cf0429d002a96bda2b42ce966" "8aebf25556399b58091e533e455dd50a6a9cba958cc4ebb0aab175863c25b9a4" "d725097d2547e9205ab6c8b034d6971c2f0fc64ae5f357b61b7de411ca3e7ab2" "3038a172e5b633d0b1ee284e6520a73035d0cb52f28b1708e22b394577ad2df1" default)))
 '(diff-hl-margin-mode nil)
 '(evil-want-Y-yank-to-eol nil)
 '(global-diff-hl-mode t)
 '(global-git-gutter-mode t)
 '(highlight-changes-colors (quote ("#d33682" "#6c71c4")))
 '(highlight-symbol-colors
   (--map
    (solarized-color-blend it "#002b36" 0.25)
    (quote
     ("#b58900" "#2aa198" "#dc322f" "#6c71c4" "#859900" "#cb4b16" "#268bd2"))))
 '(highlight-symbol-foreground-color "#93a1a1")
 '(highlight-tail-colors
   (quote
    (("#073642" . 0)
     ("#546E00" . 20)
     ("#00736F" . 30)
     ("#00629D" . 50)
     ("#7B6000" . 60)
     ("#8B2C02" . 70)
     ("#93115C" . 85)
     ("#073642" . 100))))
 '(hl-bg-colors
   (quote
    ("#7B6000" "#8B2C02" "#990A1B" "#93115C" "#3F4D91" "#00629D" "#00736F" "#546E00")))
 '(hl-fg-colors
   (quote
    ("#002b36" "#002b36" "#002b36" "#002b36" "#002b36" "#002b36" "#002b36" "#002b36")))
 '(js-switch-indent-offset 2)
 '(magit-diff-use-overlays nil)
 '(magit-use-overlays nil)
 '(package-selected-packages
   (quote
    (alert log4e gntp parent-mode haml-mode gitignore-mode marshal logito pcache pos-tip flx goto-chg diminish web-completion-data edn paredit peg eval-sexp-fu seq queue pkg-info epl bind-map bind-key packed pythonic avy popup package-build powerline spinner org highlight gh multiple-cursors inflections anzu async dash minitest hide-comnt helm-purpose window-purpose imenu-list yaml-mode yasnippet magit-popup clojure-mode pug-mode ac-ispell ace-jump-helm-line ace-link ace-window adaptive-wrap afternoon-theme aggressive-indent alect-themes ample-theme ample-zen-theme anaconda-mode anti-zenburn-theme apropospriate-theme auto-compile auto-complete auto-highlight-symbol auto-yasnippet badwolf-theme birds-of-paradise-plus-theme bracketed-paste bubbleberry-theme buffer-move bundler busybee-theme cherry-blossom-theme chruby cider cider-eval-sexp-fu clean-aindent-mode clj-refactor clojure-snippets clues-theme coffee-mode color-theme color-theme-sanityinc-solarized color-theme-sanityinc-tomorrow color-theme-solarized colorsarenice-theme column-enforce-mode company company-anaconda company-quickhelp company-statistics company-tern company-web cyberpunk-theme cython-mode dactyl-mode dakrone-theme darkburn-theme darkmine-theme darkokai-theme darktooth-theme dash-functional define-word django-theme dracula-theme dumb-jump editorconfig elisp-slime-nav emmet-mode espresso-theme evil evil-anzu evil-args evil-ediff evil-escape evil-exchange evil-iedit-state evil-indent-plus evil-lisp-state evil-magit evil-matchit evil-mc evil-nerd-commenter evil-numbers evil-search-highlight-persist evil-surround evil-tutor evil-unimpaired evil-visual-mark-mode evil-visualstar exec-path-from-shell expand-region eyebrowse f fancy-battery farmhouse-theme fill-column-indicator firebelly-theme flatland-theme flatui-theme flx-ido flycheck flycheck-pos-tip gandalf-theme gh-md gist git-commit git-link git-messenger git-timemachine gitattributes-mode gitconfig-mode github-browse-file github-clone github-search gnuplot golden-ratio google-translate gotham-theme grandshell-theme gruber-darker-theme gruvbox-theme hc-zenburn-theme helm helm-ag helm-c-yasnippet helm-company helm-core helm-css-scss helm-descbinds helm-flx helm-gitignore helm-make helm-mode-manager helm-projectile helm-pydoc helm-swoop helm-themes help-fns+ hemisu-theme heroku-theme highlight-indentation highlight-numbers highlight-parentheses hl-todo ht htmlize hungry-delete hy-mode hydra ido-vertical-mode iedit indent-guide inf-ruby info+ inkpot-theme ir-black-theme jade-mode jazz-theme jbeans-theme js-doc js2-mode js2-refactor json-mode json-reformat json-snatcher less-css-mode leuven-theme light-soap-theme link-hint linum-relative live-py-mode livid-mode lorem-ipsum lush-theme macrostep magit magit-gh-pulls magit-gitflow majapahit-theme markdown-mode markdown-toc material-theme minimal-theme mmm-mode moe-theme molokai-theme monochrome-theme monokai-theme move-text mustang-theme mwim naquadah-theme neotree niflheim-theme noctilux-theme obsidian-theme occidental-theme oldlace-theme omtose-phellack-theme open-junk-file org-download org-journal org-plus-contrib org-pomodoro org-present org-projectile org-repo-todo organic-green-theme orgit page-break-lines paradox pastels-on-dark-theme pcre2el persp-mode phoenix-dark-mono-theme phoenix-dark-pink-theme pip-requirements planet-theme pony-mode popwin professional-theme projectile purple-haze-theme py-isort py-yapf pyenv-mode pytest pyvenv quelpa railscasts-theme rainbow-delimiters rake rbenv request restart-emacs reverse-theme robe rspec-mode rubocop ruby-test-mode ruby-tools rvm s sass-mode scss-mode seti-theme simple-httpd skewer-mode slim-mode smartparens smeargle smooth-scrolling smyx-theme soft-charcoal-theme soft-morning-theme soft-stone-theme solarized-theme soothe-theme spacegray-theme spaceline spacemacs-theme stekene-theme subatomic-theme subatomic256-theme sublime-themes sunny-day-theme tagedit tango-2-theme tango-plus-theme tangotango-theme tao-theme tern toc-org tronesque-theme twilight-anti-bright-theme twilight-bright-theme twilight-theme ujelly-theme underwater-theme undo-tree use-package uuidgen vi-tilde-fringe vimrc-mode volatile-highlights web-beautify web-mode which-key window-numbering with-editor ws-butler yapfify zen-and-art-theme zenburn-theme zonokai-theme)))
 '(pos-tip-background-color "#073642")
 '(pos-tip-foreground-color "#93a1a1")
 '(ring-bell-function (quote ignore))
 '(safe-local-variable-values
   (quote
    ((python-shell-virtualenv-path . "/home/aron/.virtualenvs/pp")
     (python-shell-virtualenv-path . "/home/aron/.virtualenvs/fec-cms")
     (encoding . utf-8))))
 '(smartrep-mode-line-active-bg (solarized-color-blend "#859900" "#073642" 0.2))
 '(term-default-bg-color "#002b36")
 '(term-default-fg-color "#839496")
 '(vc-annotate-background nil)
 '(vc-annotate-color-map
   (quote
    ((20 . "#f36c60")
     (40 . "#ff9800")
     (60 . "#fff59d")
     (80 . "#8bc34a")
     (100 . "#81d4fa")
     (120 . "#4dd0e1")
     (140 . "#b39ddb")
     (160 . "#f36c60")
     (180 . "#ff9800")
     (200 . "#fff59d")
     (220 . "#8bc34a")
     (240 . "#81d4fa")
     (260 . "#4dd0e1")
     (280 . "#b39ddb")
     (300 . "#f36c60")
     (320 . "#ff9800")
     (340 . "#fff59d")
     (360 . "#8bc34a"))))
 '(vc-annotate-very-old-color nil)
 '(weechat-color-list
   (quote
    (unspecified "#002b36" "#073642" "#990A1B" "#dc322f" "#546E00" "#859900" "#7B6000" "#b58900" "#00629D" "#268bd2" "#93115C" "#d33682" "#00736F" "#2aa198" "#839496" "#657b83"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:background nil))))
 '(company-tooltip-common ((t (:inherit company-tooltip :weight bold :underline nil))))
 '(company-tooltip-common-selection ((t (:inherit company-tooltip-selection :weight bold :underline nil))))
 '(diff-hl-change ((t (:foreground "yellow"))))
 '(diff-hl-delete ((t (:inherit diff-removed :foreground "red"))))
 '(diff-hl-insert ((t (:inherit diff-added :foreground "blue")))))
)
