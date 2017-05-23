;; These are untouchable constants

(define device-info-size (c-sizeof "PaDeviceInfo"))
(define stream-params-size (c-sizeof "PaStreamParameters"))

(define float-size (c-sizeof "float"))
(define (float-peek float)
  (c-> float "float"))
(define (float-poke float value)
  (c->= float "float" value))

(define pointer-size (c-sizeof "*"))
(define (pointer-peek pointer)
  (c-> pointer "*"))
(define (pointer-poke pointer value)
  (c->= pointer "*" value))

(define types
  `((float ,float-size ,float-peek ,float-poke)
    (pointer ,pointer-size ,pointer-peek ,pointer-poke)
    (device-info ,device-info-size)
    (stream-params ,stream-params-size)))

(define (type-size type) 
  (cadr (assq type types)))
(define (type-peek type) 
  (caddr (assq type types)))
(define (type-poke type)
  (cadddr (assq type types)))

(define (peek type alien)
  ((type-peek type) alien))

(define (poke type alien value)
  ((type-poke type) alien value))