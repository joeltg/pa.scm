(define frame-iterator (iota frames-per-buffer))
(define reverse-frame-iterator (iota frames-per-buffer (-1+ frames-per-buffer) -1))
(define output-channel-iterator (iota output-channel-count))
(define input-channel-iterator (iota input-channel-count))

(define (buffer-size channel-count)
  (* float-size frames-per-buffer channel-count))

(define (make-buffer channel-count)
  (malloc (buffer-size channel-count) 'float))

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
             (samples '())
             (buffers (seconds->buffers seconds)))
    (read-stream stream buffer)
    (if (< 0 buffers)
      (loop
        buffer
        (cons (read-wave-buffer buffer) samples)
        (- buffers 1))
      (begin
        (stop-stream stream)
        samples))))

;; Input streams are also circular.
;; The "tail" of (input-stream) is (essentially) a promise of (delay (input-stream)).
;; The stream is cons-ed up by making delays of individual samples.
;; So the stream has a circumference of the buffer size.
;; "oh damn"
(define (input-stream)
  (let pool ((buffer (make-buffer input-channel-count)))
    (read-stream stream buffer)
    (alien-byte-increment! buffer (buffer-size input-channel-count) 'float)
    (let iter ((i frames-per-buffer) (circle (delay (pool buffer))))
      (let loop ((j input-channel-count) (samples '()))
        (alien-byte-increment! buffer (- float-size) 'float)
        (let ((samples (cons (c-> buffer "float") samples)))
          (if (< 1 j)
            (loop (-1+ j) samples)
            (let ((circle (delay (cons samples circle))))
              (if (< 1 i)
                (iter (-1+ i) circle)
                (force circle)))))))))

(define (output-stream circle)
  (let pool ((buffer (make-buffer output-channel-count)) (circle circle))
    (let iter ((i 0) (circle circle))
      (let loop ((samples (stream-car circle)))
        (c->= buffer "float" (car samples))
        (alien-byte-increment! buffer float-size 'float)
        (if (pair? (cdr samples))
          (loop (cdr samples))
          (if (< i frames-per-buffer)
            (iter (1+ i) (stream-cdr circle))
            (begin
              (alien-byte-increment! buffer (- (buffer-size output-channel-count)) 'float)
              (write-stream stream buffer)
              (pool buffer (stream-cdr circle)))))))))

(define (play seconds waves)
  (start-stream stream)
  (let ((buffer (make-buffer output-channel-count))
        (waves (map wave-shim waves)))
    (let loop ((waves (write-wave-buffer buffer waves))
               (buffers (seconds->buffers seconds)))
      (write-stream stream buffer)
      (if (< 0 buffers)
        (loop
          (write-wave-buffer buffer waves)
          (- buffers 1))
        (stop-stream stream)))))