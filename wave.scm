(define ((sample f period frequency) i)
  (f (/ (* i period frequency) sample-rate)))
(define (make-wave f period frequency)
  (let ((wave-length (clip (/ sample-rate frequency)))
        (sampler (sample f period frequency)))
    (let ((wave (make-initialized-list wave-length sampler)))
      (set-cdr! (last-pair wave) wave)
      wave)))

(define (make-sine frequency)
  (make-wave sin tau frequency))
(define null-wave (circular-list 0))

(define wave? circular-list?)

(define middle-c 261.6)
