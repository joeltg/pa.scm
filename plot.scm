(define default-coordinate-limits (list 0 -2 1024 2))
(define default-window-size (list 1516 512))
(define default-background-color "white")
(define default-foreground-color "black")
(define (get-right-limit win)
  (call-with-values
    (lambda ()
      (graphics-coordinate-limits win))
    (lambda (x-left y-bottom x-right y-top)
      x-right)))

(define (get-right-device-limit win)
  (call-with-values
    (lambda ()
      (graphics-device-coordinate-limits win))
    (lambda (x-left y-bottom x-right y-top)
      x-right)))

(define (window)
  (let ((win (make-graphics-device #f)))
    (graphics-operation win 'set-background-color default-background-color)
    (graphics-operation win 'set-foreground-color default-foreground-color)
    (apply x-graphics/resize-window win default-window-size)
    (apply graphics-set-coordinate-limits win default-coordinate-limits)
    (graphics-clear win)
    win))

(define clear graphics-clear)

(define point-radius 3)
(define (plot-point win x y)
  ; (graphics-operation win 'fill-circle x y point-radius)
  (graphics-draw-point win x y))

(define (plot win thing #!optional color)
  (graphics-operation win 'set-foreground-color 
    (if (default? color) default-foreground-color color))
  (if (stream-pair? thing)
    (plot-wave win thing)
    (plot-samples win thing))
  (graphics-operation win 'set-foreground-color
    default-foreground-color))

(define (plot-samples win samples #!optional color)
  (let ((samples (fold-left append '() samples)))
    (for-each
      (lambda (channels i)
        (for-each
          (lambda (channel) (plot-point win i channel))
          channels))
      samples
      (iota (length samples)))))

(define (plot-wave win wave #!optional color)
  (let ((wave (wave-shim wave))
        (limit (get-right-limit win)))
    (let iter ((stream wave) (i 0))
      (plot-point win i (stream-car stream))
      (if (< i limit)
        (iter (stream-cdr stream) (+ i 1))))))

(define scale 5)
(define (listen-plot win)
  (start-stream stream)
  (let ((limit (get-right-device-limit win)))
    (graphics-set-coordinate-limits win 0 -1 (* scale limit) 1)
    (let ((buffers (clip (/ (* scale limit) frames-per-buffer))))
      (let loop ((buffer (make-buffer input-channel-count))
                 (samples '())
                 (buffer-count 0))
        (read-stream stream buffer)
        (if (< buffer-count buffers)
          (let ((frame (read-wave-buffer buffer)))
            (for-each
              (lambda (sample i)
                (for-each
                  (lambda (channel) (plot-point win i channel))
                  sample))
                frame
                (iota (length frame) (* frames-per-buffer buffer-count)))
            (loop buffer (cons frame samples) (+ buffer-count 1)))
          (stop-stream stream))))))