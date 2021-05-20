#lang racket/base


(require racket/contract/base)


(provide
 (contract-out
  [angle? predicate/c]
  [degrees (-> (and/c real? (not/c infinite?) (not/c nan?)) angle?)]
  [radians (-> (and/c real? (not/c infinite?) (not/c nan?)) angle?)]
  [rotations (-> (and/c real? (not/c infinite?) (not/c nan?)) angle?)]
  [angle-degrees (-> angle? (and/c (>=/c 0) (</c 360)))]
  [angle-radians (-> angle? (and/c (>=/c 0) (</c tau)))]
  [angle-rotations (-> angle? (and/c (>=/c 0) (</c 1)))]
  [angle-sin (-> angle? (real-in -1 1))]
  [angle-cos (-> angle? (real-in -1 1))]
  [angle-tan (-> angle? (and/c real? (not/c nan?)))]
  [arctan
   (case->
    (-> (and/c real? (not/c nan?)) angle?)
    (-> (and/c real? (not/c nan?)) (and/c real? (not/c nan?)) (option/c angle?)))]
  [angle-add (-> angle? ... angle?)]
  [angle-sum (-> (sequence/c angle?) angle?)]
  [into-angle-sum (reducer/c angle? angle?)]))


(require racket/match
         racket/math
         racket/sequence
         rebellion/base/option
         rebellion/streaming/reducer
         rebellion/streaming/transducer)


(module+ test
  (require (submod "..")
           rackunit))


;@----------------------------------------------------------------------------------------------------


(define tau (* 2 pi))


(struct angle (rotations)
  #:constructor-name rotations
  #:transparent
  #:guard (λ (r _) (- r (floor r)))

  #:methods gen:custom-write
  [(define (write-proc this out mode)
     (define write-mode? (equal? mode #true))
     (when write-mode?
       (write-string "#<angle:" out))
     (write-string (number->string (angle-degrees this)) out)
     (write-string "°" out)
     (when write-mode?
       (write-string ">" out)))]

  #:property prop:custom-print-quotable 'never)


(define (degrees d)
  (rotations (/ d 360)))


(define (radians r)
  (rotations (/ r 2 pi)))


(define (angle-degrees a)
  (* (angle-rotations a) 360))


(define (angle-radians a)
  (* (angle-rotations a) 2 pi))


(module+ test
  (test-case "rotations"
    (check-equal? (rotations 0) (rotations 0))
    (check-not-equal? (rotations 0) (rotations 0.0))
    (check-equal? (rotations 0) (rotations 1))
    (check-equal? (rotations 0) (rotations -1))
    (check-not-equal? (rotations 0) (rotations 1/10))
    (check-equal? (rotations 1/10) (rotations 11/10))
    (check-equal? (rotations 1/10) (rotations -9/10))
    (check-equal? (rotations 1/10) (rotations 100000000000000000000000000000000001/10))
    (check-equal? (rotations 1/10) (rotations -99999999999999999999999999999999999/10))))


(define (angle-sin a)
  (match (angle-rotations a)
    [0 0]
    [1/12 1/2]
    [1/4 1]
    [5/12 1/2]
    [1/2 0]
    [7/12 1/2]
    [3/4 -1]
    [11/12 -1/2]
    [x (sin (* x 2 pi))]))


(define (angle-cos a)
  (match (angle-rotations a)
    ;; For exact angles whose sine and cosine should be the same, we have to make sure to always use
    ;; the sine function. Racket's built-in sine and cosine implementations have slightly different
    ;; rounding behavior so if we don't choose the same function, then sin(45 degrees) and
    ;; cos(45 degrees) won't be equal.
    [0 1]
    [1/8 (angle-sin a)]
    [1/6 1/2]
    [1/4 0]
    [1/3 -1/2]
    [3/8 (angle-sin a)]
    [1/2 -1]
    [5/8 (angle-sin a)]
    [2/3 -1/2]
    [3/4 0]
    [5/6 1/2]
    [7/8 (angle-sin a)]
    [x (cos (* x 2 pi))]))


(module+ test
  (test-case "angle-cos"

    (test-case "exact answers"
      (check-equal? (angle-cos (degrees 0)) 1)
      (check-equal? (angle-cos (degrees 60)) 1/2)
      (check-equal? (angle-cos (degrees 90)) 0)
      (check-equal? (angle-cos (degrees 120)) -1/2)
      (check-equal? (angle-cos (degrees 180)) -1)
      (check-equal? (angle-cos (degrees 240)) -1/2)
      (check-equal? (angle-cos (degrees 270)) 0)
      (check-equal? (angle-cos (degrees 300)) 1/2))

    (test-case "consistency with sin"
      (check-equal? (angle-cos (degrees 45)) (angle-sin (degrees 45)))
      (check-equal? (angle-cos (degrees 135)) (angle-sin (degrees 135)))
      (check-equal? (angle-cos (degrees 225)) (angle-sin (degrees 225)))
      (check-equal? (angle-cos (degrees 315)) (angle-sin (degrees 315))))))


(define (angle-tan a)
  (match (angle-rotations a)
    [0 0]
    [1/8 1]
    [1/4 +inf.0]
    [3/8 -1]
    [1/2 0] 
    [5/8 1]
    [3/4 -inf.0]
    [7/8 -1]
    [x (cos (* x 2 pi))]))


(define arctan (case-lambda [(x) (arctan1 x)] [(y x) (arctan2 y x)]))


(define (arctan1 x)
  (match x
    [0 (degrees 0)]
    [1 (degrees 45)]
    [-1 (degrees 315)]
    [+inf.0 (degrees 90)]
    [-inf.0 (degrees 270)]
    [_ (radians (atan x))]))


(define (arctan2 y x)
  (cond
    [(positive? x) (present (arctan1 (/ y x)))]
    [(negative? x)
     (present (angle-add (arctan1 (/ y x)) (if (negative? y) (degrees -180) (degrees 180))))]
    [(positive? y) (present (degrees 90))]
    [(negative? y) (present (degrees 270))]
    [else absent]))


(define (angle-add . angles)
  (angle-sum angles))


(define (angle-sum angles)
   (transduce angles #:into into-angle-sum))


(define into-angle-sum
  (reducer-map into-sum #:domain angle-rotations #:range rotations))
