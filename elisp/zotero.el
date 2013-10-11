(require 'url-util)
(require 'url-handlers)
(require 'json)

(defvar zotero-default-bibliography-style
  "http://www.zotero.org/styles/chicago-note-bibliography"
  "Default bibliography style to use.")

(defun zotero-url-retrieve (raw-url)
  (save-excursion
    (let* ((url (url-encode-url raw-url))
           (buff (url-retrieve-synchronously url)))
      (set-buffer buff)
      (url-http-parse-response)
      (if (not (eq 200 url-http-response-status))
          nil
        (with-temp-buffer
          (url-insert buff)
          (beginning-of-buffer)
          (json-read))))))

(defun zotero-clean-bib-entry (entry)
  "Clean up a bibliography entry as returned by Zotero."
  (let ((retval entry))
    (setq retval (replace-regexp-in-string "\n" "" retval))
    (setq retval (replace-regexp-in-string "\" "“" retval))
    (setq retval (replace-regexp-in-string "\" "’" retval))
    (setq retval (replace-regexp-in-string "\^]" "”" retval))
    retval))

(defun zotero-generate-bib-entry-from-id (item-id &optional style bib-format)
  (let* ((url (format "http://localhost:23119/zotxt/items?key=%s&format=bibliography&style=%s"
                      item-id (or style zotero-default-bibliography-style)))
         (results (zotero-url-retrieve url))
         (first (elt results 0))
         (text (cdr (assq 'text first))))
    (zotero-clean-bib-entry text)))

(defun zotero-get-selected-item-ids ()
  (zotero-url-retrieve "http://localhost:23119/zotxt/items?selected=selected&format=key"))

(provide 'zotero)
