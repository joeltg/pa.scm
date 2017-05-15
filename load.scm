(load-option 'ffi)
(c-include "portaudio")

(load "utils")
(load "pa")
(load "stream")
(load "wave")
(load "buffer")
(load "plot")

(initialize)

(define stream (open-default-stream))
(start-stream stream)

(define (exit)
  (stop-stream stream)
  (close-stream stream)
  (terminate)
  (%exit))