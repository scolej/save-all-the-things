;;; save-all-the-things.el --- Save all the things mode.

;;; Commentary:

;; Auto save buffers while you're not doing anything.

;; A buffer is automatically saved a period of time after the user has
;; been inactive, even if the buffer is no longer the current buffer.

;;; Code:

(defvar-local satt--timer nil
  "Timer for each buffer to automatically save itself.")

(defvar-local satt--state 'pending
  "Indicator of the current save state.")

(defvar save-all-the-things-delay 1.0
  "Time to wait after a change before saving (seconds).")

(defun satt--timer-setter ()
  "Reset any existing save timer and set a new one."
  (when satt--timer
    (cancel-timer satt--timer))
  (setq-local satt--timer
              (run-at-time save-all-the-things-delay nil
                           'satt--saver
                           (current-buffer))))

(defun satt--saver (buffer)
  "Save BUFFER, if it still exists."
  (when buffer
    (with-current-buffer buffer
      (cond
       ((not (buffer-modified-p)) ;; No changes.
        (setq-local satt--state 'all-sweet))
       ((not (verify-visited-file-modtime))
        (message "File has been changed outside Emacs; not saving.")
        (setq-local satt--state 'badly-frustrated))
       (t
        (let ((inhibit-message t)) (basic-save-buffer nil))
        (setq-local satt--state 'all-sweet))))
    (force-mode-line-update)))

(defun satt-should-enable (buffer)
  "Decide if we should start saving for the given buffer."
  (with-current-buffer buffer
    (and (buffer-file-name)
         (locate-dominating-file default-directory ".git")
         (file-regular-p (buffer-file-name)))))

(defun satt-enable-or-disable ()
  "Activate or deactive save-all-the-things in the current buffer."
  (if (satt-should-enable (current-buffer))
      (progn (save-all-the-things-mode t))
    (save-all-the-things-mode -1)))

(defun satt--after-change (x y z)
  "Indicate that the buffer contents have changed."
  (setq-local satt--state 'pending))

(defun satt-mode-line-indicator ()
  "A mode-line element function to provide state indication.
Add it to your MODE-LINE-FORMAT list like so:
    (:eval (satt-mode-line-indicator))"
  (if save-all-the-things-mode
      (pcase satt--state
        ('pending ":|")
        ('all-sweet ":)")
        ('frustrated '(:propertize ":S" face compilation-warning))
        ('badly-frustrated '(:propertize ":( :( :(" face compilation-error))
        (other "bad state"))
    ;; save-all-the-things is not enabled! Just indicate the save state.
    (if (buffer-modified-p) '(:propertize "+++" face compilation-warning) "-")))

(define-minor-mode save-all-the-things-mode
  "Automatically save the buffer after there has been no input for a while."
  :lighter " satt"
  (if save-all-the-things-mode
      (progn (add-hook 'post-command-hook 'satt--timer-setter nil t)
             (add-hook 'after-change-functions 'satt--after-change nil t))
    (remove-hook 'post-command-hook 'satt--timer-setter t)
    (remove-hook 'after-change-functions 'satt--after-change t)))

(provide 'save-all-the-things)

;;; save-all-the-things.el ends here
