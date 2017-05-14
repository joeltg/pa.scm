(define env (the-environment))
(define default? default-object?)

(define (clip float)
  (inexact->exact (ceiling float)))

(define (print . args)
  (let ((string (open-output-string)))
    (for-each 
      (lambda (arg) 
        (write arg string) 
        (write-char #\space string))
      args)
    (write-string (get-output-string string))))

(define (circular-length wave)
  (let loop ((l1 wave) (l2 wave) (count 1))
    (if (pair? l1)
      (let ((l1 (cdr l1)))
        (cond
          ((eq? l1 l2) count)
          ((pair? l1) (loop (cdr l1) (cdr l2) (+ count 1)))
          (else (error "invalid circular list"))))
      0)))

(define (& alien)
  (let ((pointer (malloc pointer-size `(* ,(alien/ctype alien)))))
    (c-poke-pointer pointer alien)
    pointer))

(define (index alien offset)
  (alien-byte-increment alien offset (alien/ctype alien)))

(define (integer->alien integer)
  (let ((alien (malloc (c-sizeof "int") 'int)))
    (c->= alien "int" integer)
    alien))

(define pi (* 2 (acos 0)))
(define tau (* 4 (acos 0)))
(define (mod a b)
  (- a (* b (floor (/ a b)))))
