;;; init.el -- Ross A. Baker's Emacs Configuration

;;; Commentary:

;; Tastes great with ./default.nix.

;;; Code:

(eval-when-compile
  (defvar use-package-hook-name-suffix)
  (setq use-package-hook-name-suffix nil)
  (require 'use-package))

;;; State

(defconst ross/is-mac (eq system-type 'darwin))

;;; Things to run early

(use-package emacs
  :no-require
  :custom
  ;; These are duplicated with the git config in Nix...
  (user-full-name "Ross A. Baker")
  (user-mail-address "ross@rossabaker.com"))

(use-package no-littering
  :ensure
  :defines no-littering-etc-directory no-littering-var-directory
  :init
  (setq no-littering-etc-directory "~/.cache/emacs/etc/"
	no-littering-var-directory "~/.cache/emacs/var/"))

(use-package exec-path-from-shell
  :ensure
  :functions exec-path-from-shell-initialize
  :if ross/is-mac
  :config
  (exec-path-from-shell-initialize))

;;; Core

(use-package emacs
  :no-require
  :custom
  (create-lockfiles nil)
  (echo-keystrokes 0.01)
  :config
  (defun ross/show-trailing-whitespace ()
    (setq show-trailing-whitespace t))
  (defun ross/scratch ()
    "Pop to the scratch buffer, receating it if necessary."
    (interactive)
    (pop-to-buffer (get-buffer-create "*scratch*")))
  :hook
  ((prog-mode-hook text-mode-hook conf-mode-hook) . ross/show-trailing-whitespace)
  :bind
  ("C-c b x" . ross/scratch))

(use-package advice
  :custom
  (ad-redefinition-action 'accept))

(use-package auth-source
  :custom
  ;; .gpg suffix encrypts it.  The default uses plaintext ~/.authinfo.  Yuck!
  (auth-sources (list (expand-file-name "authinfo.gpg" no-littering-etc-directory))))

(use-package delsel
  :config
  (delete-selection-mode))

(use-package files
  :custom
  (confirm-kill-emacs 'yes-or-no-p))

(use-package gcmh
  :ensure
  :hook
  (after-init-hook . gcmh-mode))

(use-package minibuf-eldef
  :config
  (minibuffer-electric-default-mode))

(use-package savehist
  :config
  (savehist-mode))

(use-package simple
  :requires cl-lib
  :functions ross/ad-keyboard-escape-quit
  :config
  (defun ross/ad-keyboard-escape-quit (fun &rest args)
    (cl-letf (((symbol-function 'one-window-p) (lambda (&rest _) t)))
      (apply fun args)))
  (advice-add 'keyboard-escape-quit :around #'ross/ad-keyboard-escape-quit)
  :bind
  ("<escape>" . keyboard-escape-quit))

(use-package whole-line-or-region
  :ensure
  :functions whole-line-or-region-global-mode
  :config
  (whole-line-or-region-global-mode))

(use-package ws-butler
  :ensure
  :hook
  ((prog-mode-hook text-mode-hook conf-mode-hook) . ws-butler-mode))

;;; UI

(use-package emacs
  :no-require
  :custom
  (cursor-type 'bar)
  (fast-but-imprecise-scrolling t)
  (frame-inhibit-implied-resize t)
  (scroll-conservatively 101)
  (scroll-margin 2)
  (use-dialog-box nil)
  (visible-bell nil)
  (window-combination-resize t)
  :custom-face
  (default ((t :height 140))))

(use-package default-text-scale
  :ensure
  :functions default-text-scale-mode
  :config
  (default-text-scale-mode))

(use-package display-line-numbers
  :custom
  (display-line-numbers-widen t)
  :hook
  ((prog-mode-hook conf-mode-hook) . display-line-numbers-mode))

(use-package faces
  :custom
  (ring-bell-function 'ross/flash-mode-line)
  :config
  (defun ross/flash-mode-line ()
    (let ((old-fg (face-foreground 'mode-line)))
      (set-face-foreground 'mode-line "red")
      (run-with-idle-timer 0.1 nil
			   (lambda (fg) (set-face-foreground 'mode-line fg))
			   old-fg))))

(use-package frame
  :config
  (blink-cursor-mode -1)
  :bind
  ("C-z" . nil)				; Previously suspend-frame
  )

(use-package hl-line
  :config
  (global-hl-line-mode))

(use-package minibuf
  :custom
  (minibuffer-prompt-properties '(read-only t cursor-intangible t face minibuffer-prompt))
  :hook
  (minibuffer-setup-hook . cursor-intangible-mode))

(use-package modus-themes
  :ensure
  :functions modus-themes-load-themes modus-themes-load-operandi
  :init
  (modus-themes-load-themes)
  :config
  (modus-themes-load-operandi)
  :bind
  ("C-c T t" . modus-themes-toggle))

(use-package scroll-bar
  :config
  (scroll-bar-mode -1))

(use-package simple
  :no-require
  :config
  (column-number-mode)
  (size-indication-mode))

(use-package startup
  :no-require
  :custom
  (initial-scratch-message nil)
  (inhibit-startup-echo-area-message t)
  (inhibit-startup-screen t))

(use-package tool-bar
  :config
  (tool-bar-mode -1))

;;; Completion

(use-package consult
  :ensure
  :functions consult-completing-read-multiple
  :custom
  (consult-narrow-key (kbd "C-+"))
  (xref-show-xrefs-function #'consult-xref)
  (xref-show-definitions-function #'consult-xref)
  :config
  (advice-add #'completing-read-multiple :override #'consult-completing-read-multiple)
  :bind
  ([remap switch-to-buffer] . consult-buffer)
  ([remap switch-to-buffer-other-window] . consult-buffer-other-window)
  ([remap switch-to-buffer-other-frame] . consult-buffer-other-frame)
  ([remap yank-pop] . consult-yank-pop)
  ([remap goto-line] . consult-goto-line)
  ([remap repeat-complex-command] . consult-history)
  ([remap apropros] . consult-apropos)
  ([remap man] . consult-man)
  ([remap isearch-edit-string] . consult-isearch-history))

(use-package orderless
  :ensure
  :custom
  (completion-styles '(orderless)))

(use-package vertico
  :ensure
  :functions vertico-mode
  :config
  (vertico-mode))

;;; Tools

(use-package helpful
  :ensure
  :bind
  ([remap describe-command] . helpful-command)
  ([remap describe-function] . helpful-callable)
  ([remap describe-key] . helpful-key)
  ([remap describe-symbol] . helpful-symbol)
  ([remap describe-variable] . helpful-variable)
  ([remap Info-goto-emacs-command-node] . helpful-function)
  ("C-h (" . helpful-macro))

(use-package flycheck
  :ensure
  :functions global-flycheck-mode
  :config
  (global-flycheck-mode))

(use-package magit
  :ensure)

(use-package restclient
  :ensure)

;;; Languages

;;;; Git

(use-package git-modes
  :ensure)

;;;; Groovy

(use-package groovy-mode
  :ensure
  :hook
  (groovy-mode-hook . subword-mode))

(use-package jenkinsfile-mode
  :ensure)

;;;; JSON

(use-package json-mode
  :ensure
  :mode
  ("/flake\\.lock\\'" . json-mode))

;;;; Markdown

(use-package markdown-mode
  :ensure)

;;;; Nix

(use-package nix-mode
  :ensure
  :hook
  (nix-mode-hook . subword-mode))

;;;; Scala

(use-package hocon-mode
  :mode
  ("/application\\.conf\\'" . hocon-mode)
  ("/reference\\.conf\\'" . hocon-mode)
  ("/scala-steward.conf\\'" . hocon-mode))

(use-package sbt-mode
  :ensure
  :hook
  (sbt-mode-hook . subword-mode))

(use-package scala-mode
  :ensure
  :hook
  (scala-mode-hook . subword-mode))

(provide 'init)
;;; init.el ends here
