(define delta 512)
(define ((sample f period) i)
  (f (* period (/ i delta))))
(define (wave f period)
  (let ((cycle (make-initialized-list delta (sample f period))))
    (set-cdr! (last-pair cycle) cycle)
    cycle))

(define sine-wave (wave sin tau))

(define (wave? wave)
  (and (circular-list? wave) (= (circular-length wave) delta)))

