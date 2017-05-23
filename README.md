# portaudio.scm
MIT Scheme bindings for PortAudio

## Building and Installation
I've only tested this on Linux.

First build and install PortAudio (http://portaudio.com/docs/v19-doxydocs/compile_mac_coreaudio.html for Mac or http://portaudio.com/docs/v19-doxydocs/compile_linux.html for Linux).

Then cd into the `portaudio.scm` directory and build the MIT Scheme bindings:

```bash
make
sudo make install
```

Then load PortAudio with scheme's FFI and play around:
```scheme
(load "load.scm")
(define win (window))

;; Input streams
(plot win (input-stream) "black" 50 25)

;; Output streams
(clear win)

(define a (sine 'a))
(define c (sine 'c))
(plot win (splice a c) "black" 1 0.5)

(define ac (splice (wave:+ a c)))
(plot win ac "red" 1 0.5)

(output-stream ac)
```
