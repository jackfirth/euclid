#lang scribble/manual


@(require (for-label euclid/plane/angle
                     euclid/plane/point
                     racket/base
                     racket/contract/base
                     racket/math
                     racket/sequence
                     rebellion/streaming/reducer
                     rebellion/streaming/transducer)
          (submod euclid/private/scribble-evaluator-factory doc)
          scribble/example)


@(define make-evaluator
   (make-module-sharing-evaluator-factory
    #:public (list 'euclid/plane/angle
                   'euclid/plane/point
                   'rebellion/streaming/transducer)
    #:private (list 'racket/base)))


@title{2D Points}
@defmodule[euclid/plane/point]


A @deftech{2D point} is an exact location in the @tech{Euclidean plane}, and has no length, width, or
thickness.


@defstruct*[point
            ([x (and/c real? (not/c infinite?) (not/c nan?))]
             [y (and/c real? (not/c infinite?) (not/c nan?))])
            #:transparent]{
 A @tech{2D point} structure with coordinates @racket[x] and @racket[y].}


@defthing[origin point? #:value (point 0 0)]{
 The @deftech{origin}, which is the point located at coordinates (0,0).}


@defproc[(point-add [p point?] ...) point?]{
 Adds each @racket[p] together and returns a point representing their sum.

 @(examples
   #:eval (make-evaluator)
   (point-add (point 2 3) (point 1 5)))}


@defproc[(point-sum [points (sequence/c point?)]) point?]{
 Returns the sum of @racket[points].

 @(examples
   #:eval (make-evaluator)
   (point-sum (list (point 1 1) (point 2 2) (point 3 3))))}


@defthing[into-point-sum (reducer/c point? point?)]{
 A reducer that adds together a sequence of points.

 @(examples
   #:eval (make-evaluator)
   (transduce (in-range 0 5)
              (mapping (λ (x) (point x 0)))
              #:into into-point-sum))}


@defproc[(point-distance [p point?] [q point?]) (and/c (>=/c 0) (not/c infinite?))]{
 Returns the distance between @racket[p] and @racket[q].

 @(examples
   #:eval (make-evaluator)
   (point-distance (point 1 1) (point 4 5)))}


@section{2D Polar Coordinates}


@defproc[(polar-point [radius (and/c (>=/c 0) (not/c infinite?))] [azimuth angle?]) point?]{
 Constructs a point represented by the @emph{polar coordinates} @racket[radius] and @racket[azimuth],
 where @racket[radius] is the point's distance from the origin and @racket[azimuth] is the angle of
 direction from the origin.

 @(examples
   #:eval (make-evaluator)
   (polar-point 6 (degrees 0))
   (polar-point 6 (degrees 30))
   (polar-point 6 (degrees 45))
   (polar-point 6 (degrees 60))
   (polar-point 6 (degrees 90)))}


@defproc[(polar-point-radius [p point?]) (and/c (>=/c 0) (not/c infinite?))]{
 Returns the distance from the @tech{origin} to @racket[p].

 @(examples
   #:eval (make-evaluator)
   (polar-point-radius (point 3 4))
   (polar-point-radius (point 10 0)))}


@defproc[(polar-point-azimuth [p point?]) angle?]{
 Returns the angle of direction from the @tech{origin} to @racket[p]. If @racket[p] @emph{is} the
 origin, then an angle of zero degrees is returned.

 @(examples
   #:eval (make-evaluator)
   (polar-point-azimuth (point 5 0))
   (polar-point-azimuth (point 5 5))
   (polar-point-azimuth (point 0 5)))}
