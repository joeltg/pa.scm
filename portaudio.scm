(load-option 'ffi)
(c-include "portaudio")

;; Misc utils
(load "utils")
(load "circular-list")

(load "stream")
(load "wave")

(load "buffer")
(load "plot")

;; These are untouchable constants
(define device-info-size (c-sizeof "PaDeviceInfo"))
(define stream-params-size (c-sizeof "PaStreamParameters"))
(define float-size (c-sizeof "float"))
(define pointer-size (c-sizeof "*"))

;; These are sensible defaults
(define sample-rate 44100)
(define sample-format 1)
(define stream-flags 1)
(define frames-per-buffer 1024)

;; These are totally up to you
(define input-channel-count 1)
(define output-channel-count 1)


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
(define (buffer-size channel-count)
  (* float-size frames-per-buffer channel-count))

(define (make-buffer channel-count)
  (malloc (buffer-size channel-count) 'float))

(define (buffer-ref buffer index)
  (c-> (alien-byte-increment buffer (* float-size index) 'float) "float"))

;; Errors
(define (error-text err)
  (let ((text (malloc pointer-size '(* (const char)))))
    (c-call "Pa_GetErrorText" text err)
    (c-peek-cstring text)))