(define (frequency->wavelength frequency)
  (/ sample-rate frequency))
(define f->w frequency->wavelength)
(define (wavelength->frequency wavelength)
  (/ sample-rate wavelength))
(define w->f wavelength->frequency)

(define ((sample f start end wavelength) i)
  (f (+ start (/ (* i (- end start)) wavelength))))

(define ((wave-maker f s e) frequency)
  (let ((w (f->w (frequency-shim frequency))))
    (let ((c (make-initialized-circular-list (clip w) (sample f s e w))))
      (lambda () (car (set! c (cdr c)))))))

(define ** square)

(define sine (wave-maker sin 0 tau))
(define sawtooth (wave-maker identity -1 1))
(define triange (wave-maker (compose -1+ abs) -2 2))
(define square (wave-maker (compose -1+ *2 round) 0 1))

(define (null-wave)
  0)

(define middle-c 261.6)

(define ((wave:+ . waves))
  (/ (apply + (map fapply waves)) (length waves)))

(define (frequency-shim frequency)
  (cond
    ((symbol? frequency) (cadr (assq frequency notes)))
    ((number? frequency) (exact->inexact frequency))
    (else (error "invalid frequency"))))

(define (wave-shim wave)
  (cond
    ((procedure? wave) wave)
    (else (sine wave))))

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
