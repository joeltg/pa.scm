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

(define (plot win wave #!optional color)
  (let ((wave (wave-shim wave)))
    (let ((samples (wave-samples wave))
          (limit (get-right-limit win)))
      (graphics-operation win 'set-foreground-color 
        (if (default? color) default-foreground-color color))
      (let iter ((cycle samples) (i 0))
        (plot-point win i (car cycle))
        (if (< i limit)
          (iter (cdr cycle) (+ i 1))
          (graphics-operation win 
            'set-foreground-color 
            default-foreground-color))))))
