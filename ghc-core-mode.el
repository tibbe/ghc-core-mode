;;; ghc-core-mode.el --- Syntax highlighting module for GHC Core

;; Copyright (C) 2010  Johan Tibell

;; Author: Johan Tibell <johan.tibell@gmail.com>

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; Purpose:
;;
;; To make it easier to read GHC Core output by providing highlighting
;; and removal of commonly ignored annotations.

;;; Code:

(require 'haskell-mode)
(require 'haskell-font-lock)

(defun ghc-core-clean-region (start end)
  "Remove commonly ignored annotations and namespace
prefixes in the given region."
  (interactive "r")
  (save-restriction
    (narrow-to-region start end)
    (goto-char (point-min))
    (while (search-forward-regexp "GHC\.[^\.]*\." nil t)
      (replace-match "" nil t))
    (goto-char (point-min))
    (while (flush-lines "^Rec {$" nil))
    (goto-char (point-min))
    (while (flush-lines "^end Rec }$" nil))
    (goto-char (point-min))
    (while (flush-lines "^ *GblId\\(\\[[^]]+\\]\\)? *$" nil))
    (goto-char (point-min))
    (while (flush-lines "^ *LclId *$" nil))
    (goto-char (point-min))
    (while (flush-lines "^ *LclIdX\\(\\[[^]]+\\]\\)? *$" nil))
    (goto-char (point-min))
    (while (flush-lines (concat "^ *\\[\\(?:Arity [0-9]+\\|NoCafRefs\\|"
                                "Str: DmdType\\|Worker \\)"
                                "\\([^]]*\\n?\\).*\\] *$") nil))
    (goto-char (point-min))
    (while (search-forward "Main." nil t) (replace-match "" nil t))
    (goto-char (point-min))
    (while (search-forward "`cast`" nil t) (kill-sexp))
    ;; Must come after the kill-sexp above.
    (goto-char (point-min))
    (while (search-forward "`cast`" nil t) (replace-match "" nil t))
    (goto-char (point-min))
    (while (search-forward-regexp "\(\\([a-z_][a-zA-Z_'0-9]*\\)[ \n]*\)" nil t)
      (replace-match "\\1" t nil))
    ))

(defun ghc-core-clean-buffer ()
  "Remove commonly ignored annotations and namespace
prefixes in the current buffer."
  (interactive)
  (ghc-core-clean-region (point-min) (point-max)))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.hcr\\'" . ghc-core-mode))

;;;###autoload
(define-derived-mode ghc-core-mode haskell-mode "GHC-Core"
  "Major mode for GHC Core files.")

(defun ghc-core-set-keys ()
  (local-set-key "\C-c\C-c" 'ghc-core-clean-buffer))

(add-hook 'ghc-core-mode-hook 'ghc-core-set-keys)

(provide 'ghc-core-mode)
;;; ghc-core-mode.el ends here
