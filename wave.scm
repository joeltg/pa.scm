;; Waves are streams. Yay!

(define (frequency->wavelength frequency)
  (/ sample-rate frequency))
(define f->w frequency->wavelength)
(define (wavelength->frequency wavelength)
  (/ sample-rate wavelength))
(define w->f wavelength->frequency)

(define ((sample f start end wavelength) i)
  (f (+ start (/ (* i (- end start)) wavelength))))

(define ((wave-maker f start end) frequency)
  (let ((wavelength (frequency->wavelength frequency)))
    (list->stream
      (make-initialized-circular-list
        (clip wavelength)
        (sample f start end wavelength)))))

(define ** square)

(define wave-sample stream-car)
(define wave-next stream-cdr)

(define sine (wave-maker sin 0 tau))
(define sawtooth (wave-maker identity -1 1))
(define triange (wave-maker (compose -1+ abs) -2 2))
(define square (wave-maker (compose -1+ *2 round) 0 1))

(define null-wave (list->stream (circular-list 0)))

(define middle-c 261.6)

(define ((wave-operator operator) wave . waves)
  (apply stream-map
    (lambda samples
      (/ (apply operator samples) (+ 1 (length waves))))
    wave
    waves))

(define wave:+ (wave-operator +))
(define wave:* (wave-operator *))

(define (wave-shim wave)
  (cond
    ((stream-pair? wave) wave)
    ((symbol? wave) (sine (cadr (assq wave notes))))
    ((number? wave) (sine wave))
    (else (error "invalid wave"))))

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

(define (chord . waves)
  (apply wave:+ (map wave-shim waves)))
