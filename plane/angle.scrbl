#lang scribble/manual


@(require (for-label euclid/plane/angle
                     racket/base
                     racket/contract/base
                     racket/match
                     racket/math)
          (submod euclid/private/scribble-evaluator-factory doc)
          scribble/example)


@(define make-evaluator
   (make-module-sharing-evaluator-factory
    #:public (list 'euclid/plane/angle
                   'racket/match
                   'racket/math)
    #:private (list 'racket/base)))


@title{Angles}
@defmodule[euclid/plane/angle]


An @deftech{angle} is a measure of rotation. Angles can be measured in degrees, where a full rotation
is 360 degrees, or radians, where a full rotation is 2π radians.

Because turning more than a full rotation leaves an object in the same orientation as if it had only
fractionally rotated, angles of equivalent rotations are always normalized to the smallest nonnegative
rotation. That is, @racket[(degrees 10)] and @racket[(degrees 370)] are @racket[equal?] and cannot be
distinguished.

Like numbers, angles can be either exact or inexact. The @racket[degrees] and @racket[rotations]
constructors always return exact angles when given exact inputs. However, the @racket[radians]
constructor never returns exact angles, with the exception of @racket[(radians 0)]. Exactness
primarily matters when using the trigonometric functions on angles such as @racket[angle-sin], which
make an effort to produce exact results from exact angles when possible. For example,
@racket[(angle-sin (degrees 30))] produces @racket[1/2] whereas @racket[(sin (degrees->radians 30))]
produces @racket[0.49999999999999994].


@defproc[(angle? [v any/c]) boolean?]{
 A predicate for @tech{angles}.}


@defproc[(degrees [d real?]) angle?]{
 Constructs the angle measuring @racket[d] degrees.

 @(examples
   #:eval (make-evaluator)
   (degrees 50)
   (degrees -10)
   (degrees 500))

 The @racket[degrees] constructor can also be used as a match expander. The pattern
 @racket[(degrees pat)] matches any @racket[angle?] whose measure in degrees matches @racket[pat].

 @(examples
   #:eval (make-evaluator)
   (eval:no-prompt
    (define (north? a)
      (match a
        [(degrees 90) #true]
        [_ #false])))

   (north? (degrees 90))
   (north? (degrees 270))
   (north? (rotations 1/4)))}


@defproc[(radians [r real?]) angle?]{
 Constructs the angle measuring @racket[r] radians. Note that because the mathematical value of π
 cannot be represented exactly as a @racket[real?], angles constructed with @racket[radians] may be
 less precise than expected.

 @(examples
   #:eval (make-evaluator)
   (radians pi)
   (radians (/ pi 4)))

 The @racket[radians] constructor can also be used as a match expander. The pattern
 @racket[(radians pat)] matches any @racket[angle?] whose measure in radians matches @racket[pat].

 @(examples
   #:eval (make-evaluator)
   (eval:no-prompt
    (define (small-acute-angle? a)
      (match a
        (code:comment @#,elem{Note that 1 radian is a little less than 60 degrees.})
        [(radians x) #:when (<= 0 x 1) #true]
        [_ #false])))

   (small-acute-angle? (radians 0))
   (small-acute-angle? (radians 1/2))
   (small-acute-angle? (degrees 50))
   (small-acute-angle? (degrees 80)))}


@defproc[(rotations [x real?]) angle?]{
 Constructs the angle measuring @racket[x] rotations.

 @(examples
   #:eval (make-evaluator)
   (rotations 1/4)
   (rotations 1/36))

 The @racket[rotations] constructor can also be used as a match expander. The pattern
 @racket[(rotations pat)] matches any @racket[angle?] whose measure in fractions of a rotation matches
 @racket[pat].

 @(examples
   #:eval (make-evaluator)
   (eval:no-prompt
    (define (north? a)
      (match a
        [(rotations 1/4) #true]
        [_ #false])))

   (north? (rotations 1/4))
   (north? (degrees 90))
   (north? (degrees 270)))}


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


@section{Trigonometric Functions}


@defproc[(angle-sin [a angle?]) (real-in -1 1)]{
 Returns the sine of @racket[a]. The result is exact when @racket[a] is exact and when the sine of
 @racket[a] is a rational number.

 @(examples
   #:eval (make-evaluator)
   (angle-sin (degrees 30))
   (angle-sin (degrees 45))
   (angle-sin (degrees 60)))}


@defproc[(angle-cos [a angle?]) (real-in -1 1)]{
 Returns the cosine of @racket[a]. The result is exact when @racket[a] is exact and when the cosine of
 @racket[a] is a rational number.

 @(examples
   #:eval (make-evaluator)
   (angle-cos (degrees 30))
   (angle-cos (degrees 45))
   (angle-cos (degrees 60)))}


@defproc[(angle-tan [a angle?]) (and/c real? (not/c nan?))]{
 Returns the tangent of @racket[a]. The result is exact when @racket[a] is exact and when the tangent
 of @racket[a] is either a rational number or infinity.

 @(examples
   #:eval (make-evaluator)
   (angle-tan (degrees 30))
   (angle-tan (degrees 45))
   (angle-tan (degrees 60))
   (angle-tan (degrees 90)))}
