#lang racket/base


(require racket/contract/base)


(provide
 (struct-out ray)
 (contract-out
  [ray-between (-> point? point? ray?)]))


(require euclid/plane/angle
         euclid/plane/point)


(module+ test
  (require (submod "..")
           rackunit))


;@----------------------------------------------------------------------------------------------------


(struct ray (initial-point direction)
  #:transparent
  #:guard (struct-guard/c point? angle?)
  #:property prop:custom-print-quotable 'never)


(define (ray-between initial-point target-point)
  (ray initial-point (polar-point-azimuth (point-subtract target-point initial-point))))


(module+ test
  (test-case "ray-between"
    (check-equal? (ray-between origin (point 20 20)) (ray origin (degrees 45)))
    (check-equal? (ray-between (point 100 0) (point 120 20)) (ray (point 100 0) (degrees 45)))
    (check-equal? (ray-between (point 0 100) (point 20 120)) (ray (point 0 100) (degrees 45)))
    (check-equal? (ray-between (point 100 100) (point 120 120)) (ray (point 100 100) (degrees 45)))))
