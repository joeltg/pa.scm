(load-option 'ffi)
(c-include "portaudio")

(load "utils")
(load "pa")
(load "stream")
(load "wave")
(load "buffer")
(load "plot")
(load "circular-list")

(initialize)

(define stream (open-default-stream))

(define (exit)
  (close-stream stream)
  (terminate)
  (%exit))