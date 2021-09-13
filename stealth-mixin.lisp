(cl:in-package :stealth-mixin)

;;;; The following hack is due to Gilbert Baumann.  It allows us to
;;;; dynamically mix in classes into a class without the latter being
;;;; aware of it.

;;; Mixins are not intended to be directly instantiated, and instead are used as superclasses to "normal" classes in order to capture common things between several "normal" classes.

;;; First of all we need to keep track of added mixins, we use a hash
;;; table here. Better would be to stick this information to the
;;; victim class itself.

(defvar *stealth-mixins* (make-hash-table))

(defmacro class-stealth-mixins (class)
  `(gethash ,class *stealth-mixins*))

;;; The 'direct-superclasses' argument to ensure-class is a list of
;;; either classes or their names. Since we want to avoid duplicates,
;;; we need an appropriate equivalence predicate:

(defun class-equalp (c1 c2)
  (when (symbolp c1) (setf c1 (find-class c1)))
  (when (symbolp c2) (setf c2 (find-class c2)))
  (eq c1 c2))

(defun add-mixin (mixin-name victim-class)
  "Add the mixin to the superclasses of the victim"
  (closer-mop:ensure-class victim-class
			   :direct-superclasses (adjoin mixin-name
							(and (find-class victim-class nil)
							     (closer-mop:class-direct-superclasses
							      (find-class victim-class)))
							:test #'class-equalp)
			   :metaclass (class-of (find-class victim-class)))

  ;; Register it as a new mixin for the victim class
  (pushnew mixin-name (class-stealth-mixins victim-class))

  ;; When one wants to [re]define the victim class the new mixin
  ;; should be present too. We do this by 'patching' ensure-class:
  (defmethod closer-mop:ensure-class-using-class :around
      (class (name (eql victim-class))
       &rest arguments
       &key (direct-superclasses nil direct-superclasses-p)
       &allow-other-keys)
    (cond (direct-superclasses-p
           ;; Silently modify the super classes to include our new
           ;; mixin.
           (dolist (k (class-stealth-mixins name))
             (pushnew k direct-superclasses
                      :test #'class-equalp))
           (apply #'call-next-method class name
                  :direct-superclasses direct-superclasses
                  arguments))
          (t
           (call-next-method))))
  mixin-name)

(defmacro define-stealth-mixin (name super-classes victim-class
                                &rest for-defclass)
  "Like DEFCLASS but adds the newly defined class to the super classes
of 'victim-class'."
  `(progn
     ;; First define the class we talk about
     (defclass ,name ,super-classes ,@for-defclass)
     ;; Add the class to the mixins of the victim
     (add-mixin ',name ',victim-class)))
