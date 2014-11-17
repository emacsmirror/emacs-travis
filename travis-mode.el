;; travis-mode.el --- Mode for Travis

;; Copyright (C) 2014 Nicolas Lamirault <nicolas.lamirault@gmail.com>

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 2
;; of the License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
;; 02110-1301, USA.

;;; Commentary:

;; A major mode for Travis

;;; Code:

;;; Code:

(require 'ansi-color)
(require 'browse-url)
(require 'tabulated-list)

;; Travis library

(require 'travis-repos)
(require 'travis-ui)


;; Projects

(defvar travis--projects-mode-history nil)

(defun travis-show-projects (slug)
  "Show Travis projects using user request SLUG."
  (interactive
   (list (read-from-minibuffer "Projects: "
                               (car travis--projects-mode-history)
                               nil
                               nil
                               'travis--projects-mode-history)))
  (pop-to-buffer "*Travis projects*" nil)
  (travis-projects-mode)
  (setq tabulated-list-entries
        (create-projects-entries (travis--get-repository slug)))
  (tabulated-list-print t))

(defun create-projects-entries (projects)
  "Create entries for 'tabulated-list-entries from PROJECTS."
  (mapcar (lambda (p)
            (let ((id (number-to-string (cdr (assoc 'id p)))))
              (list id
                    (vector ;id
                     ;;(cdr (assoc 'last_build_state p))
                     (colorize-build-state (cdr (assoc 'last_build_state p)))
                     (cdr (assoc 'slug p))
                     (cdr (assoc 'description p))))))
          (cdar projects)))

;; Travis projects mode

(defvar travis-projects-mode-hook nil)

(defvar travis-projects-mode-map
  (let ((map (make-keymap)))
    (define-key map (kbd "w") 'travis-goto-project)
    map)
  "Keymap for `travis-projects-mode' major mode.")

(define-derived-mode travis-projects-mode tabulated-list-mode "Travis projects"
  "Major mode for browsing Travis projects."
  :group 'travis
  (setq tabulated-list-format [;("ID" 5 t)
                               ("Status" 10 t)
                               ("Name"  25 t)
                               ("Description"  0 nil)
                               ])
  (setq tabulated-list-padding 2)
  (setq tabulated-list-sort-key (cons "Name" nil))
  (tabulated-list-init-header))



(provide 'travis-mode)
;;; travis-mode.el ends here