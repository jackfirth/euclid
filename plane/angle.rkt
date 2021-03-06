#lang racket/base


(require racket/contract/base)


(provide
 rotations
 degrees
 radians
 (contract-out
  [angle? predicate/c]
  [angle-degrees (-> angle? (and/c (>=/c 0) (</c 360)))]
  [angle-radians (-> angle? (and/c (>=/c 0) (</c (* 2 pi))))]
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


(require (for-syntax racket/base
                     racket/syntax)
         racket/match
         racket/math
         racket/sequence
         rebellion/base/option
         rebellion/streaming/reducer
         rebellion/streaming/transducer
         syntax/parse/define)


(module+ test
  (require (submod "..")
           rackunit))


;@----------------------------------------------------------------------------------------------------


;; This macro is for defining the (degrees d), (radians r), and (rotations x) forms which double as
;; constructors with contracts and match expanders.
(define-syntax-parse-rule
  (define-contracted-match-constructor name:id
    (~alt
     (~once (~seq #:constructor private-constructor:id))
     (~once (~seq #:predicate predicate:expr))
     (~once (~seq #:field-accessor private-accessor:id))
     (~once (~seq #:field-contract field-contract:expr)))
    ...)
  #:with contracted-constructor (format-id #'here "contracted:~a" #'name)
  (begin
    (define-module-boundary-contract contracted-constructor private-constructor
      (-> field-contract predicate)
      #:name-for-blame name)
    (define-match-expander name
      (syntax-parser [(_ pat:expr) #'(? predicate (app private-accessor pat))])
      (make-rename-transformer #'contracted-constructor))))


(struct angle (rotations)
  #:constructor-name unchecked:rotations
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


(define-contracted-match-constructor rotations
  #:constructor unchecked:rotations
  #:predicate angle?
  #:field-accessor angle-rotations
  #:field-contract (and/c real? (not/c infinite?) (not/c nan?)))


(define (angle-degrees a)
  (* (angle-rotations a) 360))


(define (unchecked:degrees d)
  (unchecked:rotations (/ d 360)))


(define-contracted-match-constructor degrees
  #:constructor unchecked:degrees
  #:predicate angle?
  #:field-accessor angle-degrees
  #:field-contract (and/c real? (not/c infinite?) (not/c nan?)))


(define (angle-radians a)
  (* (angle-rotations a) 2 pi))


(define (unchecked:radians r)
  (unchecked:rotations (/ r 2 pi)))


(define-contracted-match-constructor radians
  #:constructor unchecked:radians
  #:predicate angle?
  #:field-accessor angle-radians
  #:field-contract (and/c real? (not/c infinite?) (not/c nan?)))

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
  (match a
    [(degrees 0) 0]
    [(degrees 30) 1/2]
    [(degrees 90) 1]
    [(degrees 150) 1/2]
    [(degrees 180) 0]
    [(degrees 210) 1/2]
    [(degrees 270) -1]
    [(degrees 330) -1/2]
    [(radians r) (sin r)]))


(define (angle-cos a)
  (match a
    ;; For exact angles whose sine and cosine should be the same, we have to make sure to always use
    ;; the sine function. Racket's built-in sine and cosine implementations have slightly different
    ;; rounding behavior so if we don't choose the same function, then sin(45 degrees) and
    ;; cos(45 degrees) won't be equal.
    [(degrees 0) 1]
    [(degrees 45) (angle-sin a)]
    [(degrees 60) 1/2]
    [(degrees 90) 0]
    [(degrees 120) -1/2]
    [(degrees 135) (angle-sin a)]
    [(degrees 180) -1]
    [(degrees 225) (angle-sin a)]
    [(degrees 240) -1/2]
    [(degrees 270) 0]
    [(degrees 300) 1/2]
    [(degrees 315) (angle-sin a)]
    [(radians r) (cos r)]))


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
  (match a
    [(degrees 0) 0]
    [(degrees 45) 1]
    [(degrees 90) +inf.0]
    [(degrees 135) -1]
    [(degrees 180) 0] 
    [(degrees 225) 1]
    [(degrees 270) -inf.0]
    [(degrees 315) -1]
    [(radians r) (tan r)]))


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
     (present (arctan1 (/ y x)))
     #;(present (angle-add (arctan1 (/ y x)) (if (negative? y) (degrees -180) (degrees 180))))]
    [(positive? y) (present (degrees 90))]
    [(negative? y) (present (degrees 270))]
    [else absent]))


(define (angle-add . angles)
  (angle-sum angles))


(define (angle-sum angles)
   (transduce angles #:into into-angle-sum))


(define into-angle-sum
  (reducer-map
   into-sum
   #:domain angle-rotations
  ;; Can't eta-reduce this lambda because it interacts weirdly with
  ;; define-contracted-match-constructor and causes use-before-definition errors.
   #:range (λ (r) (rotations r))))
