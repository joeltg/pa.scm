(load-option 'ffi)
(c-include "portaudio")

(load "utils")
(load "pa")
(load "stream")
(load "waves")
(define err)

(define num-seconds 5)
(define table-size 200)

(initialize)

(define stream (open-default-stream))
(start-stream stream)
; (define device (c-call "Pa_GetDefaultOutputDevice"))
; (print "device:" device)
; (define device-info
;   (c-call "Pa_GetDeviceInfo"
;     (malloc (c-sizeof "PaDeviceInfo") 'PaDeviceInfo) 
;     device))
; (print "device name:" (c-peek-cstring (c-> device-info "PaDeviceInfo name")))
; (define latency
;   (c-> device-info "PaDeviceInfo defaultLowOutputLatency"))

; (define params
;     (malloc (c-sizeof "PaStreamParameters") 'PaStreamParameters))
; (c->= params "PaStreamParameters device" device)
; (c->= params "PaStreamParameters channelCount" 2)
; (c->= params "PaStreamParameters sampleFormat" 1)
; (c->= params "PaStreamParameters suggestedLatency" latency)
; (c->= params "PaStreamParameters hostApiSpecificStreamInfo" null-alien)

; (define stream-pointer (malloc pointer-size '(* PaStream)))
; (c-call "Pa_OpenStream"
;       stream-pointer
;       null-alien
;       params
;       sample-rate
;       frames-per-buffer
;       1
;       null-alien
;       null-alien)
; (define stream (c-> stream-pointer "*"))
; (print "stream:" stream)

; (set! err (c-call "Pa_StartStream" stream))
; (print "Start stream:" err)
; (print "Stream stopped:" (c-call "Pa_IsStreamStopped" stream))


(define buffer (malloc (* float-size frames-per-buffer 2) 'float))
(define buffer-count (/ (* num-seconds sample-rate) frames-per-buffer))
(define sine
  (make-initialized-vector
    table-size
    (lambda (i)
      (sin (* tau (/ i table-size))))))
(define left-inc 1)
(define right-inc 3)
(define left-phase 0)
(define right-phase 0)
(let fori ((i 0))
  (if (< i buffer-count)
    (let forj ((j 0))
      (if (< j frames-per-buffer)
        (begin
          (c->= (index buffer (* float-size (+ 1 (* 2 j)))) "float"
            (vector-ref sine left-phase))
          (c->= (index buffer (* float-size (+ 0 (* 2 j)))) "float"
            (vector-ref sine right-phase))
          (set! left-phase (modulo (+ left-phase left-inc) table-size))
          (set! right-phase (modulo (+ right-phase right-inc) table-size))
          (forj (+ j 1)))
        (begin
          (write-stream stream buffer)
          (fori (+ i 1)))))))