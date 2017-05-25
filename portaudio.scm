(load-option 'ffi)
(c-include "portaudio")

;; Misc utils
(load "utils")
(load "circular-list")

;; These are sensible defaults
(define sample-rate 44100)
(define sample-format 2147483649)
(define stream-flags 1)
(define frames-per-buffer 1024)

;; These are totally up to you
(define input-channel-count 1)
(define output-channel-count 1)

;; Real Things (TM)
(load "types")
(load "stream")


(define (initialize)
  (c-call "Pa_Initialize"))
(define (terminate)
  (c-call "Pa_Terminate"))

;; Devices
(define (get-default-device)
  (c-call "Pa_GetDefaultOutputDevice"))

(define (get-device-info device)
  (c-call "Pa_GetDeviceInfo"
    (malloc device-info-size 'PaDeviceInfo)
    device))

;; Buffers
(define (buffer->vector buffer type vector)
  (let ((k (vector-length vector)) (size (type-size type)) (peek (type-peek type)))
    (let iter ((i (-1+ k)) (buffer (alien-byte-increment! buffer (* size (-1+ k)))))
      (vector-set! vector i (peek buffer))
      (if (> i 0) (iter (-1+ i) (alien-byte-increment! buffer (- size))) vector))))

(define (vector->buffer vector buffer type)
  (let ((k (vector-length vector)) (size (type-size type)) (poke (type-poke type)))
    (let iter ((i (-1+ k)) (buffer (alien-byte-increment! buffer (* size (-1+ k)))))
      (poke buffer (vector-ref vector i))
      (if (> i 0) (iter (-1+ i) (alien-byte-increment! buffer (- size))) buffer))))

(define float-buffer (malloc (* float-size frames-per-buffer) 'float))
(define pointer-buffer (& float-buffer))

(define float-vector (make-vector frames-per-buffer))
(define pointer-vector (vector float-vector))

(define (buffer? v)
  (and (vector? v) (= frames-per-buffer (vector-length v))))

;; I/O
(define (output stream)
  (vector->buffer float-vector float-buffer 'float)
  (write-stream stream pointer-buffer))

(define (input stream)
  (read-stream stream pointer-buffer)
  (buffer->vector float-buffer 'float float-vector))

;; Errors
(define (error-text err)
  (let ((text (malloc pointer-size '(* (const char)))))
    (c-call "Pa_GetErrorText" text err)
    (c-peek-cstring text)))