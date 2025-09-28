;;; sticky-window.el --- Sticky (fixed) window management -*- lexical-binding: t; -*-

;; Copyright (C) 2025 ofnhwx

;; Author: ofnhwx
;; Version: 1.0
;; Package-Requires: ((emacs "28.1"))
;; Keywords: convenience, window
;; URL: https://github.com/ofnhwx/sticky-window
;; License: GPL-3.0-or-later

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;; This package provides a global minor mode to manage "sticky" windows.
;; Sticky windows:
;; - Are preserved during `delete-other-windows`
;; - Prevent deletion of the last non-sticky window
;; - Restore their size automatically when the frame changes
;;
;; Usage:
;; - Enable `sticky-window-mode`.
;; - Use `sticky-window-create` to display a buffer as sticky on a specified side.

;;; Code:

(require 'seq)

;;;; Custom variables

(defgroup sticky-window nil
  "Sticky window management."
  :group 'windows)

(defcustom sticky-window-default-size 0.3
  "Default size for sticky windows.
If the value is between 0.0 and 1.0, it represents a ratio of frame size.
If the value is greater than 1.0, it represents the size in pixels."
  :type 'number
  :group 'sticky-window)

;;;; Utility functions

(defun sticky-window-p (window)
  "Return non-nil if WINDOW is sticky."
  (window-parameter window 'sticky))

(defun sticky-window-list ()
  "Return a list of all sticky windows."
  (seq-filter #'sticky-window-p (window-list)))

(defun sticky-window-non-sticky-list ()
  "Return a list of all non-sticky windows."
  (seq-remove #'sticky-window-p (window-list)))

(defun sticky-window-first-non-sticky ()
  "Return the first non-sticky window, or nil if none exists."
  (car (sticky-window-non-sticky-list)))

;;;; Sticky window creation

;;;###autoload
(defun sticky-window-create (buffer side &optional size)
  "Create a sticky window displaying BUFFER on SIDE.
SIDE can be \='left, \='right, \='top, or \='bottom.
Optional SIZE specifies the window size:
- If SIZE is between 0.0 and 1.0 (exclusive), it's treated as a ratio
  of frame size.
- If SIZE is 1.0 or greater, it's treated as the size in pixels.
- If SIZE is nil, `sticky-window-default-size' is used.
For left/right windows, SIZE controls width.
For top/bottom windows, SIZE controls height."
  (let* ((actual-size (or size sticky-window-default-size))
         (win (display-buffer-in-side-window
               buffer
               `((side . ,side)
                 (slot . 0)
                 ,(if (memq side '(left right))
                      `(window-width . ,actual-size)
                    `(window-height . ,actual-size))))))
    ;; Mark window as sticky and store side/size for adjustment
    (set-window-parameter win 'sticky t)
    (set-window-parameter win 'sticky-side side)
    (set-window-parameter win 'sticky-size actual-size)
    ;; Prevent deletion by delete-other-windows
    (set-window-parameter win 'no-delete-other-windows t)
    ;; Dedicate window so other buffers don't replace it
    (set-window-dedicated-p win t)
    ;; Adjust size immediately to ensure correct width/height
    (sticky-window--adjust nil)
    win))

;;;; Window size adjustment

(defun sticky-window--adjust (_)
  "Restore size of all sticky windows according to stored parameters.
Intended for `window-size-change-functions` hook."
  (dolist (win (sticky-window-list))
    (when (window-live-p win)
      (if-let* ((side (window-parameter win 'sticky-side))
                (size (window-parameter win 'sticky-size)))
          (let* ((horizontal (memq side '(left right)))
                 (frame-size (if horizontal (frame-width) (frame-height)))
                 (target-size (if (< size 1.0) (round (* frame-size size)) (round size)))
                 (current-size (if horizontal (window-width win) (window-height win)))
                 (delta (- target-size current-size)))
            (when (/= delta 0)
              (condition-case err
                  (window-resize win delta horizontal)
                (error
                 (message "Failed to resize sticky window %s: %s"
                          (window-buffer win)
                          (error-message-string err))))))))))

;;;; Internal advice

(defun sticky-window--advice-delete-other-windows-before (&rest _args)
  "Ensure we are in a non-sticky window before `delete-other-windows`."
  (when (sticky-window-p (selected-window))
    (when-let* ((non-sticky (sticky-window-first-non-sticky)))
      (select-window non-sticky))))

(defun sticky-window--advice-delete-window-around (orig-fun &rest args)
  "Prevent deleting the last non-sticky window.
ORIG-FUN is the original `delete-window', called with ARGS."
  (let* ((target (or (car args) (selected-window)))
         (non-sticky (sticky-window-non-sticky-list)))
    (if (and (not (sticky-window-p target))
             (= (length non-sticky) 1)
             (eq target (car non-sticky)))
        (message "Cannot delete the last non-sticky window.")
      (apply orig-fun args))))

;;;; Minor mode

;;;###autoload
(define-minor-mode sticky-window-mode
  "Global minor mode to manage sticky windows.

When enabled:
- Advice is applied to `delete-other-windows` and `delete-window`
  to preserve sticky windows and prevent deletion of the last
  non-sticky window.
- Sticky windows restore their size automatically."
  :global t
  :lighter " StickyWin"
  :group 'sticky-window
  (if sticky-window-mode
      (progn
        (advice-add 'delete-other-windows :before #'sticky-window--advice-delete-other-windows-before)
        (advice-add 'delete-window :around #'sticky-window--advice-delete-window-around)
        (add-hook 'window-size-change-functions #'sticky-window--adjust))
    (advice-remove 'delete-other-windows #'sticky-window--advice-delete-other-windows-before)
    (advice-remove 'delete-window #'sticky-window--advice-delete-window-around)
    (remove-hook 'window-size-change-functions #'sticky-window--adjust)))

(provide 'sticky-window)

;;; sticky-window.el ends here
