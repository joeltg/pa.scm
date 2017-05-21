(load-option 'ffi)
(c-include "portaudio")

(load "utils")

(load "portaudio")
(load "stream")
(load "wave")
(load "buffer")
(load "plot")
(load "circular-list")

(define sample-rate 44100)
(define sample-format 1) ; paFloat32
(define stream-flags 1) ; paClipOff
(define frames-per-buffer 1024)
(define input-channel-count 2)
(define output-channel-count 2)

(initialize)

(define stream (open-default-stream))

(define (exit)
  (close-stream stream)
  (terminate)
  (%exit))