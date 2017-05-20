(define frame-iterator (iota frames-per-buffer))
(define output-channel-iterator (iota output-channel-count))
(define input-channel-iterator (iota input-channel-count))

(define (make-buffer channel-count)
  (malloc (* float-size frames-per-buffer channel-count) 'float))

(define (buffer-ref buffer frame channel channel-count)
  (alien-byte-increment
    buffer
    (* float-size (+ channel (* channel-count frame)))
    'float))

(define (seconds->buffers seconds)
  (clip (/ (* seconds sample-rate) frames-per-buffer)))

(define ((write-wave-channel buffer frame) wave channel)
  (c->= 
    (buffer-ref buffer frame channel output-channel-count) 
    "float" 
    (wave-sample wave))
  (wave-next wave))

(define ((write-wave-frame buffer) waves frame)
  (map
    (write-wave-channel buffer frame)
    waves
    output-channel-iterator))

(define (write-wave-buffer buffer waves)
  (fold-left
    (write-wave-frame buffer) 
    waves
    frame-iterator))

(define ((read-wave-channel buffer frame) channel)
  (c-> (buffer-ref buffer frame channel output-channel-count) "float"))

(define ((read-wave-frame buffer) frame)
  (map
    (read-wave-channel buffer frame)
    input-channel-iterator))

(define (read-wave-buffer buffer)
  (map
    (read-wave-frame buffer)
    frame-iterator))

(define (listen seconds)
  (start-stream stream)
  (let loop ((buffer (make-buffer input-channel-count))
             (waves (make-list input-channel-count '()))
             (buffers (seconds->buffers seconds)))
    (read-stream stream buffer)
    (if (< 0 buffers)
      (loop
        buffer
        (cons (read-wave-buffer buffer) waves)
        (- buffers 1))
      (begin
        (stop-stream stream)
        waves))))

(define (play seconds waves)
  (start-stream stream)
  (let ((buffer (make-buffer output-channel-count))
        (waves (map wave-shim waves)))
    (let loop ((waves (write-wave-buffer buffer waves))
               (buffers (seconds->buffers seconds)))
      (write-stream stream buffer)
      (if (< 0 buffers)
        (loop
          buffer
          (write-wave-buffer buffer waves)
          (- buffers 1))
        (stop-stream stream)))))