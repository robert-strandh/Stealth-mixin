(cl:in-package #:common-lisp-user)

(defpackage :stealth-mixin
  (:use #:common-lisp)
  (:export
   #:class-stealth-mixins
   #:define-stealth-mixin))
