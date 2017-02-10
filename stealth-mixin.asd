(cl:in-package #:asdf-user)

(defsystem :stealth-mixin
  :depends-on (:closer-mop)
  :serial t
  :components
  ((:file "packages")
   (:file "stealth-mixin")))
