(define ((sample f period frequency) i)
  (f (/ (* i period frequency) sample-rate)))
(define (cycle-length->frequency cycle-length)
  (clip (/ sample-rate cycle-length)))
(define (frequency->cycle-length frequency)
  (clip (/ sample-rate frequency)))
(define (generate-wave f period frequency)
  (let ((frequency (if (symbol? frequency) (cadr (assq frequency notes)) frequency)))
    (let ((cycle-length (frequency->cycle-length frequency))
          (sampler (sample f period frequency)))
      (let ((cycle (make-initialized-list cycle-length sampler)))
        (set-cdr! (last-pair cycle) cycle)
        (make-wave frequency cycle-length cycle)))))

(define-structure wave frequency cycle-length samples)

(define (waves-sample waves)
  (fold-left + 0 (map wave-sample waves)))
(define (waves-next waves)
  (map wave-next waves))
(define (wave-sample wave)
  (car (wave-samples wave)))
(define (wave-next wave)
  (make-wave
    (wave-frequency wave)
    (wave-cycle-length wave)
    (cdr (wave-samples wave))))

(define ((wave:selector f) wave)
  (apply f
    (list-head
      (wave-samples wave)
      (wave-cycle-length wave))))

(define wave:min (wave:selector min))
(define wave:max (wave:selector max))

(define (sine frequency)
  (generate-wave sin tau))

(define (sawtooth frequency)
  (generate-wave (compose identity -1+) 2 frequency))

(define (square frequency)
  (generate-wave (compose -1+ *2 round) 1 frequency))

(define (triangle frequency)
  (generate-wave (compose -1+ *2 abs -1+) 2 frequency))

(define null-wave
  (make-wave (cycle-length->frequency 1) 1 (cons 1 (circular-list 0))))

(define middle-c 261.6)

; there's got to be a better way
; (define lcm-error 2)
; (define (wave:lcm . waves)
;   (clip
;     (reduce-left
;       (real-lcm 2)
;       1
;       (map clip (map wave-cycle-length waves)))))

(define (wave:lcm . waves)
  (apply lcm (map clip (map wave-cycle-length waves))))

(define ((wave:map f) . waves)
  (let ((waves (map wave-shim waves)))
    (let ((cycle-length (apply wave:lcm waves)))
      (let iter ((cycle '()) (waves waves) (i cycle-length))
        (if (< 0 i)
          (iter
            (cons (apply f (map wave-sample waves)) cycle)
            (map wave-next waves)
            (- i 1))
          (let ((samples (reverse cycle)))
            (set-cdr! (last-pair samples) samples)
            (make-wave
              (cycle-length->frequency cycle-length) 
              cycle-length
              samples)))))))

(define wave:+ (wave:map +))
(define wave:* (wave:map *))

(define ((normalizer x1 x2) sample)
  (-1+ (* (- sample x1) (/ 2 (- x2 x1)))))
(define (wave:normalize wave)
  ((wave:map (normalizer (wave:min wave) (wave:max wave))) wave))

(define (wave-shim wave)
  (cond
    ((wave? wave) wave)
    ((symbol? wave) (sine (cadr (assq wave notes))))
    ((number? wave) (sine wave))
    (else (error "invalid wave"))))

(define (waves-shim waves)
  (if (list? waves)
    (map wave-shim waves)
    (make-list output-channel-count (wave-shim waves))))

(define notes
  '((b 493.883)
    (bf 466.164)
    (as 466.164)
    (a 440.0)
    (af 415.305)
    (gs 415.305)
    (g 391.995)
    (gf 369.994)
    (fs 369.994)
    (f 349.228)
    (e 329.628)
    (ef 311.127)
    (ds 311.127)
    (d 293.665)
    (df 293.665)
    (cs 277.183)
    (c 261.626)))

(define (chord . names)
  (let ((fs (map (lambda (name) (cadr (assq name notes))) names)))
    (wave:normalize 
      (reduce-left
        wave:+
        null-wave
        (map sine fs)))))
