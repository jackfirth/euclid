#lang scribble/manual


@(require (for-label euclid/plane/angle
                     euclid/plane/point
                     euclid/plane/ray
                     racket/base
                     racket/contract/base)
          (submod euclid/private/scribble-evaluator-factory doc)
          scribble/example)


@(define make-evaluator
   (make-module-sharing-evaluator-factory
    #:public (list 'euclid/plane/point
                   'euclid/plane/ray)
    #:private (list 'racket/base)))


@title{2D Rays}
@defmodule[euclid/plane/ray]


A @deftech{2D ray} is half of a line. A ray starts at an initial point and continues infinitely in a
single direction.


@defstruct*[ray
            ([initial-point point?]
             [direction angle?])
            #:transparent]{
 A @tech{2D ray} structure starting at @racket[initial-point] and pointed in @racket[direction].}


@defproc[(ray-between [initial point?] [target point?]) ray?]{
 Returns the ray starting at @racket[initial] and pointed towards @racket[target].

 @(examples
   #:eval (make-evaluator)
   (ray-between (point 1 1) (point 5 5))
   (ray-between (point 4 8) (point 4 0)))}
