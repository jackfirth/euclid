#lang info

(define collection "euclid")

(define scribblings
  (list (list "main.scrbl"
              (list 'multi-page)
              (list 'library)
              "euclid")))

(define deps
  (list "rebellion"
        "base"))

(define build-deps
  (list "racket-doc"
        "rackunit-lib"
        "scribble-lib"))
