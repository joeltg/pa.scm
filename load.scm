(load-option 'ffi)
(c-include "portaudio")

(load "utils")
(load "pa")
(load "stream")
(load "wave")
(load "buffer")

(define table-size 200)

(initialize)

(define stream (open-default-stream))
(start-stream stream)

(define buffer (make-buffer))
(define buffer-count (seconds->buffers 5))
