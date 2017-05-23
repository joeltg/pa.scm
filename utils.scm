(define (clip float)
  (inexact->exact (ceiling float)))

(define (fapply f . args)
  (apply f args))

(define (identity a)
  a)

(define (*2 a)
  (* 2 a))

(define ((compose . fs) arg)
  (fold-right fapply arg fs))

(define (print . args)
  (let ((string (open-output-string)))
    (for-each 
      (lambda (arg)
        (cond
          ((circular-list? arg)
            (write-string "circular: " string)
            (write (list-head arg 10) string))
          (else (write arg string)))
        (write-char #\space string))
      args)
    (write-char #\newline string)
    (write-string (get-output-string string))))

(define (& alien)
  (let ((pointer (malloc pointer-size `(* ,(alien/ctype alien)))))
    (c-poke-pointer pointer alien)
    pointer))

(define pi (* 2 (acos 0)))
(define tau (* 4 (acos 0)))
