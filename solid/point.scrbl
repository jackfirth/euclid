#lang scribble/manual


@(require (for-label euclid/solid/point
                     racket/contract/base)
          (submod euclid/private/scribble-evaluator-factory doc)
          scribble/example)


@(define make-evaluator
   (make-module-sharing-evaluator-factory
    #:public (list 'euclid/solid/point)
    #:private (list 'racket/base)))


@title{3D Points}
@defmodule[euclid/solid/point]
