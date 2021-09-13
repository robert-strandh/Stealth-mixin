(cl:in-package #:common-lisp-user)

(defpackage :stealth-mixin
  (:use #:common-lisp)
  (:export
   #:class-stealth-mixins
   #:add-mixin
   #:define-stealth-mixin))
