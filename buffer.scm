(define frame-iterator (iota frames-per-buffer))
(define channel-iterator (iota output-channel-count))

(define (make-buffer)
  (malloc (* float-size frames-per-buffer output-channel-count) 'float))

(define (buffer-ref buffer frame channel)
  (alien-byte-increment
    buffer
    (* float-size (+ channel (* output-channel-count frame)))
    'float))

(define (seconds->buffers seconds)
  (clip (/ (* seconds sample-rate) frames-per-buffer)))

(define ((write-wave-channel! buffer frame) wave channel)
  (c->= (buffer-ref buffer frame channel) "float" (car wave))
  (cdr wave))

(define ((write-wave-frame! buffer) waves frame)
  (map
    (write-wave-channel! buffer frame)
    waves
    channel-iterator))

(define (write-wave-buffer! buffer waves)
  (fold-left
    (write-wave-frame! buffer) 
    waves
    frame-iterator))

(define (play stream waves seconds)
  (let loop ((buffer (make-buffer))
             (waves waves)
             (buffers (seconds->buffers seconds)))
    (write-stream stream buffer)
    (if (< 0 buffers)
      (loop
        buffer
        (write-wave-buffer! buffer waves)
        (- buffers 1)))))