(define frame-iterator (iota frames-per-buffer))
(define reverse-frame-iterator (iota frames-per-buffer (-1+ frames-per-buffer) -1))
(define output-channel-iterator (iota output-channel-count))
(define input-channel-iterator (iota input-channel-count))

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

;; Input streams are also circular.
;; The "tail" of (input-stream) is (essentially) a promise of (delay (input-stream)).
;; The stream is cons-ed up by making delays of individual samples.
;; So the stream has a circumference of the buffer size.
;; "oh damn"
(define (input-stream)
  (if (stream-stopped? stream) (start-stream stream))
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

(define wave-sample car)
(define wave-next cdr)

(define (wave-sample w)
  (/ (apply + (map car w)) (length w)))

(define (wave-next w)
  (map cdr w))

(define (output-stream circle)
  (if (stream-stopped? stream) (start-stream stream))
  (let pool ((buffer (make-buffer output-channel-count)) (circle circle))
    (let iter ((i 1) (circle circle))
      (let loop ((j 1) (samples (wave-sample circle)))
        (let ((sample (if (pair? samples) (car samples) samples))
              (lampes (if (pair? samples) (cdr samples) samples)))
          (c->= buffer "float" sample)
          (alien-byte-increment! buffer float-size 'float)
          (if (< j input-channel-count)
            (loop (1+ j) lampes)
            (if (< i frames-per-buffer)
              (iter (1+ i) (wave-next circle))
              (begin
                (alien-byte-increment! buffer (- (buffer-size output-channel-count)) 'float)
                (write-stream stream buffer)
                (pool buffer (wave-next circle))))))))))

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