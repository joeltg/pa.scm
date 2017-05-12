(load-option 'ffi)
(c-include "portaudio")

(load "utils")

(define num-seconds 5)
(define sample-rate 44100)
(define frames-per-buffer 1024)
(define table-size 200)

(c-call "Pa_Initialize")

(define device (c-call "Pa_GetDefaultOutputDevice"))
(define device-info 
  (c-call "Pa_GetDeviceInfo" 
    (malloc (c-sizeof "PaDeviceInfo") 'PaDeviceInfo) 
    device))
(define latency 
  (c-> device-info "PaDeviceInfo defaultLowOutputLatency"))

(define params
    (malloc (c-sizeof "PaStreamParameters") 'PaStreamParameters))
(c->= params "PaStreamParameters device" device)
(c->= params "PaStreamParameters channelCount" 2)
(c->= params "PaStreamParameters sampleFormat" 1)
(c->= params "PaStreamParameters suggestedLatency" latency)
(c->= params "PaStreamParameters hostApiSpecificStreamInfo" null-alien)

(define stream )
(define stream (malloc pointer-size '(* PaStream)))
(c-call "Pa_OpenStream"
  stream
  null-alien
  params
  sample-rate
  frames-per-buffer
  1
  null-alien
  null-alien)

(define float-size (c-sizeof "float"))
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
          (c->= (index buffer (* float-size (+ 0 (* 2 j)))) "float"
            (vector-ref sine left-phase))
          (c->= (index buffer (* float-size (+ 1 (* 2 j)))) "float"
            (vector-ref sine right-phase))
          (set! left-phase (modulo (+ left-phase left-inc) table-size))
          (set! right-phase (modulo (+ right-phase right-inc) table-size))
          (forj (+ j 1)))
        (begin
          (c-call "Pa_WriteStream" stream buffer frames-per-buffer)
          (fori (+ i 1)))))))