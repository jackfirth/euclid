#lang scribble/manual


@(require (for-label euclid/plane/angle
                     racket/base
                     racket/contract/base
                     racket/math)
          (submod euclid/private/scribble-evaluator-factory doc)
          scribble/example)


@(define make-evaluator
   (make-module-sharing-evaluator-factory
    #:public (list 'euclid/plane/angle
                   'racket/math)
    #:private (list 'racket/base)))


@title{Angles}
@defmodule[euclid/plane/angle]


An @deftech{angle} is a measure of rotation. Angles can be measured in degrees, where a full rotation
is 360 degrees, or radians, where a full rotation is 2π radians. Because turning more than a full
rotation leaves an object in the same orientation as if it had only fractionally rotated, angles of
equivalent rotations are always normalized to the smallest nonnegative rotation. That is,
@racket[(degrees 10)] and @racket[(degrees 370)] are @racket[equal?] and cannot be distinguished.


@defproc[(angle? [v any/c]) boolean?]{
 A predicate for @tech{angles}.}


@defproc[(degrees [d real?]) angle?]{
 Constructs the angle measuring @racket[d] degrees.

 @(examples
   #:eval (make-evaluator)
   (degrees 50)
   (degrees -10)
   (degrees 500))}


@defproc[(radians [r real?]) angle?]{
 Constructs the angle measuring @racket[r] radians. Note that because the mathematical value of π
 cannot be represented exactly as a @racket[real?], angles constructed with @racket[radians] may be
 less precise than expected.

 @(examples
   #:eval (make-evaluator)
   (radians pi)
   (radians (/ pi 4)))}


@defproc[(rotations [x real?]) angle?]{
 Constructs the angle measuring @racket[x] rotations.

 @(examples
   #:eval (make-evaluator)
   (rotations 1/4)
   (rotations 1/36))}


@defproc[(angle-degrees [a angle?]) (and/c (>=/c 0) (</c 360))]{
 Converts @racket[a] into degrees.

 @(examples
   #:eval (make-evaluator)
   (angle-degrees (degrees 20))
   (angle-degrees (degrees 380))
   (angle-degrees (rotations 1/4))
   (angle-degrees (radians pi)))}


@defproc[(angle-radians [a angle?]) (and/c (>=/c 0) (</c (* pi 2)))]{
 Converts @racket[a] into radians.

 @(examples
   #:eval (make-evaluator)
   (angle-radians (radians pi))
   (angle-radians (degrees 90))
   (angle-radians (rotations 1/4)))}


@defproc[(angle-rotations [a angle?]) (and/c (>=/c 0) (</c 1))]{
 Converts @racket[a] into a fraction of a rotation.

 @(examples
   #:eval (make-evaluator)
   (angle-rotations (degrees 90))
   (angle-rotations (rotations 1/4))
   (angle-rotations (radians pi)))}
