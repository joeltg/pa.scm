(define env (the-environment))
(define pointer-size (c-sizeof "*"))

(define (error-text err)
  (let ((text (malloc pointer-size '(* (const char)))))
    (c-call "Pa_GetErrorText" text err)
    (c-peek-cstring text)))

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
