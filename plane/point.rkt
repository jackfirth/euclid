#lang racket/base


(require racket/contract/base)


(provide
 (struct-out point)
 (contract-out
  [origin point?]
  [point-add (-> point? ... point?)]
  [point-negate (-> point? point?)]
  [point-subtract (-> point? point? ... point?)]
  [point-sum (-> (sequence/c point?) point?)]
  [into-point-sum (reducer/c point? point?)]
  [point-distance (-> point? point? (and/c (>=/c 0) (not/c infinite?)))]
  [polar-point (-> (and/c (>=/c 0) (not/c infinite?)) angle? point?)]
  [polar-point-radius (-> point? (and/c (>=/c 0) (not/c infinite?)))]
  [polar-point-azimuth (-> point? angle?)]))


(require euclid/plane/angle
         racket/match
         racket/math
         racket/sequence
         rebellion/base/option
         rebellion/streaming/reducer
         rebellion/streaming/transducer)


(module+ test
  (require (submod "..")
           rackunit))


;@----------------------------------------------------------------------------------------------------


(struct point (x y)
  #:transparent
  #:guard
  (struct-guard/c
   (and/c real? (not/c infinite?) (not/c nan?))
   (and/c real? (not/c infinite?) (not/c nan?)))

  #:methods gen:custom-write
  [(define (write-proc this out mode)
     (define write-mode? (equal? mode #true))
     (when write-mode?
       (write-string "#<point:" out))
     (write-string "(" out)
     (write-string (number->string (point-x this)) out)
     (write-string "," out)
     (write-string (number->string (point-y this)) out)
     (write-string ")" out)
     (when write-mode?
       (write-string ">" out)))]

  #:property prop:custom-print-quotable 'never)


(define origin (point 0 0))


(define (polar-point radius azimuth)
  (point (* (angle-cos azimuth) radius) (* (angle-sin azimuth) radius)))


(define (polar-point-radius p)
  (match-define (point x y) p)
  (sqrt (+ (sqr x) (sqr y))))


(define (polar-point-azimuth p)
  (match-define (point x y) p)
  (option-get (arctan y x) (degrees 0)))


(module+ test
  (test-case "polar-point"

    (test-case "cardinal directions"
      (check-equal? (polar-point 6 (degrees 0)) (point 6 0))
      (check-equal? (polar-point 6 (degrees 90)) (point 0 6))
      (check-equal? (polar-point 6 (degrees 180)) (point -6 0))
      (check-equal? (polar-point 6 (degrees 270)) (point 0 -6)))

    (test-case "diagonal directions"
      (define 3root3 (* 3 (sqrt 3)))
      (define 3root2 (* 3 (sqrt 2)))
      (define tolerance 0.0000000000001)

      (test-begin
       (define p (polar-point 6 (degrees 30)))
       (check-= (point-x p) 3root3 tolerance)
       (check-equal? (point-y p) 3))

      (test-begin
       (define p (polar-point 6 (degrees 45)))
       (check-= (point-x p) 3root2 tolerance)
       (check-= (point-y p) 3root2 tolerance))

      (test-begin
       (define p (polar-point 6 (degrees 60)))
       (check-equal? (point-x p) 3)
       (check-= (point-y p) 3root3 tolerance)))))


(define (point-add . points)
  (point-sum points))


(define (point-sum points)
  (transduce points #:into into-point-sum))


(define into-point-sum
  (reducer-zip
   point
   (reducer-map into-sum #:domain point-x)
   (reducer-map into-sum #:domain point-y)))


(define (point-negate p)
  (match-define (point x y) p)
  (point (- x) (- y)))


(define (point-subtract p . qs)
  (point-add p (point-negate (point-sum qs))))


(module+ test
  (test-case "point-add"
    (check-equal? (point-add) origin)
    (check-equal? (point-add (point 1 2)) (point 1 2))
    (check-equal? (point-add (point 1 2) (point 3 4)) (point 4 6))
    (check-equal? (point-add (point 1 2) (point 3 4) (point 5 6)) (point 9 12))))


(define (point-distance p q)
  (match-define (point x1 y1) p)
  (match-define (point x2 y2) q)
  (sqrt (+ (sqr (- x2 x1)) (sqr (- y2 y1)))))


(module+ test
  (test-case "point-distance"
    (check-equal? (point-distance origin (point 3 4)) 5)
    (check-equal? (point-distance (point 3 4) origin) 5)
    (check-equal? (point-distance (point 10 10) (point 13 14)) 5)))
