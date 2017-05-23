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

Then load PortAudio and play around:
```scheme
(load "portaudio.scm")
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

## Usage

See http://portaudio.com/docs/v19-doxydocs/api_overview.html

PortAudio can be used synchronously with read-stream and write-stream
or asynchronously with read and write callbacks.
Callbacks are messy and the FFI trampolines are slow; stick to sync for now.

If you desperately want to use callbacks, switch the commenting in `stream.scm` 
and in `portaudio.cdecl` and rebuild the whole project.
Then you can pass callbacks (procedures of five arguments) into `(open-stream)`.

Synchonous read/write:
```
(define stream (open-default-stream))
(start-stream stream)
...
(write-stream stream buffer)
(read-stream stream)
```
Asynchronous read/write with callbacks:
```
(define (kappa input output frame-count time-info status-flags)
  ...)
(define stream (open-default-stream kappa))
(start-stream)
```
