;;; -*- Mode: Lisp; Package: CLIMACS-GUI -*-

;;;  (c) copyright 2004-2005 by
;;;           Robert Strandh (strandh@labri.fr)
;;;  (c) copyright 2004-2005 by
;;;           Elliott Johnson (ejohnson@fasl.info)
;;;  (c) copyright 2005 by
;;;           Matthieu Villeneuve (matthieu.villeneuve@free.fr)
;;;  (c) copyright 2005 by
;;;           Aleksandar Bakic (a_bakic@yahoo.com)

;;; This library is free software; you can redistribute it and/or
;;; modify it under the terms of the GNU Library General Public
;;; License as published by the Free Software Foundation; either
;;; version 2 of the License, or (at your option) any later version.
;;;
;;; This library is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;; Library General Public License for more details.
;;;
;;; You should have received a copy of the GNU Library General Public
;;; License along with this library; if not, write to the
;;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;;; Boston, MA  02111-1307  USA.

;;; File commands for the Climacs editor. 

(in-package :gautowrite)

(defun filename-completer (so-far mode)
  (flet ((remove-trail (s)
	   (subseq s 0 (let ((pos (position #\/ s :from-end t)))
			 (if pos (1+ pos) 0)))))
    (let* ((directory-prefix
	    (if (and (plusp (length so-far)) (eql (aref so-far 0) #\/))
		""
		(namestring #+sbcl *default-pathname-defaults*
                            #+cmu (ext:default-directory)
                            #-(or sbcl cmu) *default-pathname-defaults*)))
	   (full-so-far (concatenate 'string directory-prefix so-far))
	   (pathnames
	    (loop with length = (length full-so-far)
		  and wildcard = (concatenate 'string (remove-trail so-far) "*.*")
		  for path in
		  #+(or sbcl cmu lispworks) (directory wildcard)
		  #+openmcl (directory wildcard :directories t)
		  #+allegro (directory wildcard :directories-are-files nil)
		  #+cormanlisp (nconc (directory wildcard)
				      (cl::directory-subdirs dirname))
		  #-(or sbcl cmu lispworks openmcl allegro cormanlisp)
		    (directory wildcard)
		  when (let ((mismatch (mismatch (namestring path) full-so-far)))
			 (or (null mismatch) (= mismatch length)))
		    collect path))
	   (strings (mapcar #'namestring pathnames))
	   (first-string (car strings))
	   (length-common-prefix nil)
	   (completed-string nil)
	   (full-completed-string nil))
      (unless (null pathnames)
	(setf length-common-prefix
	      (loop with length = (length first-string)
		    for string in (cdr strings)
		    do (setf length (min length (or (mismatch string first-string) length)))
		    finally (return length))))
      (unless (null pathnames)
	(setf completed-string
	      (subseq first-string (length directory-prefix)
		      (if (null (cdr pathnames)) nil length-common-prefix)))
	(setf full-completed-string
	      (concatenate 'string directory-prefix completed-string)))
      (case mode
	((:complete-limited :complete-maximal)
	 (cond ((null pathnames)
		(values so-far nil nil 0 nil))
	       ((null (cdr pathnames))
		(values completed-string t (car pathnames) 1 nil))
	       (t
		(values completed-string nil nil (length pathnames) nil))))
	(:complete
	 (cond ((null pathnames)
		(values so-far t so-far 1 nil))
	       ((null (cdr pathnames))
		(values completed-string t (car pathnames) 1 nil))
	       ((find full-completed-string strings :test #'string-equal)
		(let ((pos (position full-completed-string strings :test #'string-equal)))
		  (values completed-string
			  t (elt pathnames pos) (length pathnames) nil)))
	       (t
		(values completed-string nil nil (length pathnames) nil))))
	(:possibilities
	 (values nil nil nil (length pathnames)
		 (loop with length = (length directory-prefix)
		       for name in pathnames
		       collect (list (subseq (namestring name) length nil)
				     name))))))))

;; (define-presentation-method present (object (type pathname)
;;                                             stream (view climacs-textual-view) &key)
;;   (princ (namestring object) stream))

(define-presentation-method accept ((type pathname) stream (view textual-view)
                                    &key (default nil defaultp) (default-type type))
  (multiple-value-bind (pathname success string)
      (complete-input stream
		      #'filename-completer
		      :allow-any-input t)
    (cond (success
	   (values pathname type))
	  ((and (zerop (length string))
		defaultp)
	   (values default default-type))
	  (t (values string 'string)))))

(defun filepath-filename (pathname)
  (if (null (pathname-type pathname))
      (pathname-name pathname)
      (concatenate 'string (pathname-name pathname)
		   "." (pathname-type pathname))))

;; (defun syntax-class-name-for-filepath (filepath)
;;   (or (climacs-syntax::syntax-description-class-name
;;        (find (or (pathname-type filepath)
;; 		 (pathname-name filepath))
;; 	     climacs-syntax::*syntaxes*
;; 	     :test (lambda (x y)
;; 		     (member x y :test #'string-equal))
;; 	     :key #'climacs-syntax::syntax-description-pathname-types))
;;       'basic-syntax))

;; Adapted from cl-fad/PCL
(defun directory-pathname-p (pathspec)
  "Returns NIL if PATHSPEC does not designate a directory."
  (let ((name (pathname-name pathspec))
	(type (pathname-type pathspec)))
    (and (or (null name) (eql name :unspecific))
	 (or (null type) (eql type :unspecific)))))

;; (defun find-file (filepath)
;;   (cond ((null filepath)
;; 	 (display-message "No file name given.")q
;; 	 (beep))
;; 	((directory-pathname-p filepath)
;; 	 (display-message "~A is a directory name." filepath)
;; 	 (beep))
;; 	(t
;; 	 (let ((existing-buffer (find filepath (buffers *application-frame*)
;; 			       :key #'filepath :test #'equal)))
;; 	   (if existing-buffer
;; 	       (switch-to-buffer existing-buffer)
;; 	       (let ((buffer (make-buffer))
;; 		     (pane (current-window)))
;; 		 (setf (offset (point (buffer pane))) (offset (point pane)))
;; 		 (setf (buffer (current-window)) buffer)
;; 		 (setf (syntax buffer)
;; 		       (make-instance (syntax-class-name-for-filepath filepath)
;; 			  :buffer (buffer (point pane))))
;; 		 ;; Don't want to create the file if it doesn't exist.
;; 		 (when (probe-file filepath)
;; 		   (with-open-file (stream filepath :direction :input)
;; 		     (input-from-stream stream buffer 0)))
;; 		 (setf (filepath buffer) filepath
;; 		       (name buffer) (filepath-filename filepath)
;; 		       (needs-saving buffer) nil)
;; 		 (beginning-of-buffer (point pane))
;; 		 ;; this one is needed so that the buffer modification protocol
;; 		 ;; resets the low and high marks after redisplay
;; 		 (redisplay-frame-panes *application-frame*)
;; 		 buffer))))))

(defun directory-of-buffer (buffer)
  "Extract the directory part of the filepath to the file in BUFFER.
   If BUFFER does not have a filepath, the path to the users home 
   directory will be returned."
  (make-pathname
   :directory
   (pathname-directory
    (or (filepath buffer)
	(user-homedir-pathname)))))

;; (define-command (com-find-file :name t :command-table buffer-table) ()
;;   (let* ((filepath (accept 'pathname :prompt "Find File"
;; 			   :default (directory-of-buffer (buffer (current-window)))
;; 			   :default-type 'pathname
;; 			   :insert-default t)))
;;     (find-file filepath)))

;; (set-key 'com-find-file
;; 	 'buffer-table
;; 	 '((#\x :control) (#\f :control)))

;; (defun find-file-read-only (filepath)
;;   (cond ((null filepath)
;; 	 (display-message "No file name given.")
;; 	 (beep))
;; 	((directory-pathname-p filepath)
;; 	 (display-message "~A is a directory name." filepath)
;; 	 (beep))
;; 	(t
;; 	 (let ((existing-buffer (find filepath (buffers *application-frame*)
;; 				      :key #'filepath :test #'equal)))
;; 	   (if (and existing-buffer (read-only-p existing-buffer))
;; 	       (switch-to-buffer existing-buffer)
;; 	       (if (probe-file filepath)
;; 		   (let ((buffer (make-buffer))
;; 			 (pane (current-window)))
;; 		     (setf (offset (point (buffer pane))) (offset (point pane)))
;; 		     (setf (buffer (current-window)) buffer)
;; 		     (setf (syntax buffer)
;; 			   (make-instance (syntax-class-name-for-filepath filepath)
;; 			      :buffer (buffer (point pane))))
;; 		     (with-open-file (stream filepath :direction :input)
;; 		       (input-from-stream stream buffer 0))
;; 		     (setf (filepath buffer) filepath
;; 			   (name buffer) (filepath-filename filepath)
;; 			   (needs-saving buffer) nil
;; 			   (read-only-p buffer) t)
;; 		     (beginning-of-buffer (point pane))
;; 		     ;; this one is needed so that the buffer modification protocol
;; 		     ;; resets the low and high marks after redisplay
;; 		     (redisplay-frame-panes *application-frame*)
;; 		     buffer)
;; 		   (progn
;; 		     (display-message "No such file: ~A" filepath)
;; 		     (beep)
;; 		     nil)))))))

;; (define-command (com-find-file-read-only :name t :command-table buffer-table) ()
;;   (let ((filepath (accept 'pathname :Prompt "Find file read only"
;; 			  :default (directory-of-buffer (buffer (current-window)))
;; 			  :default-type 'pathname
;; 			  :insert-default t)))
;;     (find-file-read-only filepath)))

;; (set-key 'com-find-file-read-only
;; 	 'buffer-table
;; 	 '((#\x :control) (#\r :control)))

;; (define-command (com-read-only :name t :command-table buffer-table) ()
;;   (let ((buffer (buffer (current-window))))
;;     (setf (read-only-p buffer) (not (read-only-p buffer)))))

;; (set-key 'com-read-only
;; 	 'buffer-table
;; 	 '((#\x :control) (#\q :control)))

;; (defun set-visited-file-name (filename buffer)
;;   (setf (filepath buffer) filename
;; 	(name buffer) (filepath-filename filename)
;; 	(needs-saving buffer) t))

;; (define-command (com-set-visited-file-name :name t :command-table buffer-table) ()
;;   (let ((filename (accept 'pathname :prompt "New file name"
;; 			  :default (directory-of-buffer (buffer (current-window)))
;; 			  :default-type 'pathname
;; 			  :insert-default t)))
;;     (set-visited-file-name filename (buffer (current-window)))))

;; (define-command (com-insert-file :name t :command-table buffer-table) ()
;;   (let ((filename (accept 'pathname :prompt "Insert File"
;; 			  :default (directory-of-buffer (buffer (current-window)))
;; 			  :default-type 'pathname
;; 			  :insert-default t))
;; 	(pane (current-window)))
;;     (when (probe-file filename)
;;       (setf (mark pane) (clone-mark (point pane) :left))
;;       (with-open-file (stream filename :direction :input)
;; 	(input-from-stream stream
;; 			   (buffer pane)
;; 			   (offset (point pane))))
;;       (psetf (offset (mark pane)) (offset (point pane))
;; 	     (offset (point pane)) (offset (mark pane))))
;;     (redisplay-frame-panes *application-frame*)))

;; (set-key 'com-insert-file
;; 	 'buffer-table
;; 	 '((#\x :control) (#\i :control)))

;; (define-command (com-revert-buffer :name t :command-table buffer-table) ()
;;   (let* ((pane (current-window))
;; 	 (buffer (buffer pane))
;; 	 (filepath (filepath buffer))
;; 	 (save (offset (point pane))))
;;     (when (accept 'boolean :prompt (format nil "Revert buffer from file ~A?"
;; 					   (filepath buffer)))
;;       (cond ((directory-pathname-p filepath)
;; 	   (display-message "~A is a directory name." filepath)
;; 	   (beep))
;; 	  ((probe-file filepath)
;; 	   (erase-buffer buffer)
;; 	   (with-open-file (stream filepath :direction :input)
;; 	     (input-from-stream stream buffer 0))
;; 	   (setf (offset (point pane))
;; 		 (min (size buffer) save)))
;; 	  (t
;; 	   (display-message "No file ~A" filepath)
;; 	   (beep))))))

;; (defun save-buffer (buffer)
;;   (let ((filepath (or (filepath buffer)
;; 		      (accept 'pathname :prompt "Save Buffer to File"))))
;;     (cond
;;       ((directory-pathname-p filepath)
;;        (display-message "~A is a directory." filepath)
;;        (beep))
;;       (t
;;        (when (probe-file filepath)
;; 	 (let ((backup-name (pathname-name filepath))
;; 	       (backup-type (concatenate 'string (pathname-type filepath) "~")))
;; 	   (rename-file filepath (make-pathname :name backup-name
;; 						:type backup-type))))
;;        (with-open-file (stream filepath :direction :output :if-exists :supersede)
;; 	 (output-to-stream stream buffer 0 (size buffer)))
;;        (setf (filepath buffer) filepath
;; 	     (name buffer) (filepath-filename filepath))
;;        (display-message "Wrote: ~a" (filepath buffer))
;;        (setf (needs-saving buffer) nil)))))

;; (define-command (com-save-buffer :name t :command-table buffer-table) ()
;;   (let ((buffer (buffer (current-window))))
;;     (if (or (null (filepath buffer))
;; 	    (needs-saving buffer))
;; 	(save-buffer buffer)
;; 	(display-message "No changes need to be saved from ~a" (name buffer)))))

;; (set-key 'com-save-buffer
;; 	 'buffer-table
;; 	 '((#\x :control) (#\s :control)))

;; (defmethod frame-exit :around ((frame climacs))
;;   (loop for buffer in (buffers frame)
;; 	when (and (needs-saving buffer)
;; 		  (filepath buffer)
;; 		  (handler-case (accept 'boolean
;; 					:prompt (format nil "Save buffer: ~a ?" (name buffer)))
;; 		    (error () (progn (beep)
;; 				     (display-message "Invalid answer")
;; 				     (return-from frame-exit nil)))))
;; 	  do (save-buffer buffer))
;;   (when (or (notany #'(lambda (buffer) (and (needs-saving buffer) (filepath buffer)))
;; 		    (buffers frame))
;; 	    (handler-case (accept 'boolean :prompt "Modified buffers exist.  Quit anyway?")
;; 	      (error () (progn (beep)
;; 			       (display-message "Invalid answer")
;; 			       (return-from frame-exit nil)))))
;;     (call-next-method)))

;; (define-command (com-write-buffer :name t :command-table buffer-table) ()
;;   (let ((filepath (accept 'pathname :prompt "Write Buffer to File"
;; 			  :default (directory-of-buffer (buffer (current-window)))
;; 			  :default-type 'pathname
;; 			  :insert-default t))
;; 	(buffer (buffer (current-window))))
;;     (cond
;;       ((directory-pathname-p filepath)
;;        (display-message "~A is a directory name." filepath))
;;       (t
;;        (with-open-file (stream filepath :direction :output :if-exists :supersede)
;; 	 (output-to-stream stream buffer 0 (size buffer)))
;;        (setf (filepath buffer) filepath
;; 	     (name buffer) (filepath-filename filepath)
;; 	     (needs-saving buffer) nil)
;;        (display-message "Wrote: ~a" (filepath buffer))))))

;; (set-key 'com-write-buffer
;; 	 'buffer-table
;; 	 '((#\x :control) (#\w :control)))

