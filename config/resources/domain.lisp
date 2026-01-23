    (in-package :mu-cl-resources)

(defparameter *cache-count-queries* nil)
(defparameter *supply-cache-headers-p* t
  "when non-nil, cache headers are supplied.  this works together with mu-cache.")
(setf *cache-model-properties-p* t)
(defparameter *include-count-in-paginated-responses* t
  "when non-nil, all paginated listings will contain the number
   of responses in the result object's meta.")
(defparameter *max-group-sorted-properties* t)
(defparameter sparql:*experimental-no-application-graph-for-sudo-select-queries* t)

;; from lmb
(setf *fetch-all-types-in-construct-queries* t)

(read-domain-file "master-harvest-domain.lisp")
(read-domain-file "master-file-domain.lisp")
(read-domain-file "master-job-domain.lisp")
(read-domain-file "master-scheduled-domain.lisp")
(read-domain-file "dcat.json")

;; lmb
(read-domain-file "lmb/concept-scheme.lisp")
(read-domain-file "lmb/user.lisp")
(read-domain-file "lmb/external-besluit.lisp")
(read-domain-file "lmb/external-contact.lisp")
(read-domain-file "lmb/external-mandaat.lisp")
(read-domain-file "lmb/forms.lisp")
(read-domain-file "lmb/verkiezingen.lisp")
(read-domain-file "lmb/system-notification.lisp")
(read-domain-file "lmb/shacl-report.lisp")

;; Extra security layer to return 403 on GET /files
;; It should be ok for mu-auth; but devs can make bugs and add files to the wrong graph (i.e. public)
(before (:list file) (resource)
  (let ((request-filters-on-uri
          (some (lambda (args)
                  (let ((components (getf args :components)))

                    ;;matches /files?filter[data-container][input-from-tasks][:id:]=''
                    (or
                      (and (= 3 (length components))
                           (string= (elt components 2)
                                    ":id:"))

                     ;;matches /files?filter[:uri:]=''
                       (and (= 1 (length components))
                           (string= (elt components 0)
                                    ":uri:")))
                    ))
                (extract-filters-from-request))))
    (if request-filters-on-uri
        resource
        (error 'access-denied :operation :list :resource resource :id :none))))
