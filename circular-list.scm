(define (make-initialized-circular-list k procedure)
  (let ((circle (make-initialized-list k procedure)))
    (set-cdr! (last-pair circle) circle)
    circle))

(define (circular-list-length circle)
  (if (null? circle)
    0
    (let iter ((c (cdr circle)) (i 1))
      (if (eq? c circle)
        i
        (if (pair? c)
          (iter (cdr c) (+ i 1))
          (error:wrong-type-datum circle "circular list"))))))

(define (circular-list-map procedure first . rest)
  (assert (not (any null? rest)))
  (if (null? first)
    '()
    (let iter ((circle (list (apply f (car first) (map car rest)))) 
               (circles (cons (cdr first) (map cdr rest))))
      (if (eq? (car circles) first)
        circle
        (if (pair? (car circles))
          (iter (cons (apply f (map car circles))) (map cdr circles))
          (error:wrong-type-datum circle "circular list"))))))

(define (circular-list->list circle)
  (list-head circle (circular-list-length circle)))
  
(define (list->circular-list list)
(apply circular-list list))