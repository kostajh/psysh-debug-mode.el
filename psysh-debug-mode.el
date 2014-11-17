;;; psysh-debug-model.el -- Minor mode to use psysh for debugging PHP apps

;; Copyright © 2014 Kosta Harlan <kosta@kostaharlan.net>

;; Author: Kosta Harlan <kosta@kostaharlan.net>
;; Maintainer: Kosta Harlan <kosta@kostaharlan.net>
;; URL: https://github.com/kostajh/psysh-debug-mode.el
;; Keywords: php, debug
;; Created: 17th November 2014

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by the Free
;; Software Foundation; either version 3, or (at your option) any later
;; version.
;;
;; This program is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
;; FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
;; more details.
;;
;; You should have received a copy of the GNU General Public License along with
;; GNU Emacs; see the file COPYING.  If not, write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301,
;; USA.

;;; Commentary:

;;; This library provides a minor mode for debugging PHP scripts with Psysh.

;;; Code:

(require 'thingatpt)

(defgroup psysh-debug nil
  "Debug PHP scripts with Psysh"
  :group 'tools
  :group 'convenience)

(defcustom psysh-debug-bin-path "~/.composer/vendor/bin/psysh"
  "Define the path to the `psysh` binary."
  :group 'psysh-debug
  :type 'symbol)

(defcustom psysh-debug-default-object "get_defined_vars()"
  "Define the default object passed to Psy\\Shell::debug()."
  :group 'psysh-debug
  :type 'symbol)

(defcustom psysh-debug-keymap-prefix (kbd "C-c d")
  "The psysh-debug keymap prefix."
  :group 'psysh-debug
  :type 'string)

(defvar psysh-debug-mode-map
  (let ((map (make-sparse-keymap)))
    (let ((prefix-map (make-sparse-keymap)))
      (define-key prefix-map (kbd "tb") 'psysh-debug--toggle-breakpoint)
      (define-key prefix-map (kbd "cb") 'psysh-debug--clear-all-breakpoints)
      (define-key map psysh-debug-keymap-prefix prefix-map))
    map)
  "Keymap for psysh-debug mode.")


;;;###autoload
(define-minor-mode psysh-debug-mode
  "Minor mode to debug PHP scripts with Psysh"
  nil " Psysh debug" psysh-debug-mode-map)

(defun psysh-debug--toggle-breakpoint()
  "Add a break point, highlight it. Remove if already set."
  (interactive)
  (let ((trace (concatenate 'string "require_once '" psysh-debug-bin-path "'; Psy\\Shell::debug(" psysh-debug-default-object ");"))
        (line (thing-at-point 'line)))
    ;; FIXME: The string-match toggle doesn't work.
    (if (and line (string-match "Shell::debug" line))
        (kill-whole-line))
      (progn
        (back-to-indentation)
        (insert trace)
        (insert "\n")
        (highlight-lines-matching-regexp "Shell::debug")
        )))

(defun psysh-debug--clear-all-breakpoints()
  "Clear all breakpoints from active buffer."
  (interactive)
  ;; TODO: Retain cursor position.
  (delete-matching-lines "Shell::debug" (beginning-of-buffer))
  )

(provide 'psysh-debug-mode)

;;; psysh-debug-mode.el ends here
