(cl:in-package #:asdf-user)

(defsystem :stealth-mixin
  :description "Library for creating stealth mixin classes."
  :author "Robert Strandh <robert.strandh@gmail.com>"
  :license "FreeBSD, see file LICENSE.text"
  :depends-on (:closer-mop)
  :serial t
  :components
  ((:file "packages")
   (:file "stealth-mixin")))
