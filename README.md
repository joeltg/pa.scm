# pa.scm
MIT Scheme bindings for PortAudio

## Building and Installation
I've only tested this on Linux.

First build and install PortAudio (http://portaudio.com/docs/v19-doxydocs/compile_mac_coreaudio.html for Mac or http://portaudio.com/docs/v19-doxydocs/compile_linux.html for Linux).

Then cd into the `pa.scm` directory and build the MIT Scheme bindings:

```bash
make
sudo make install
```

Then load PortAudio with scheme's FFI and play around:
```scheme
(load-option 'ffi)
(c-include "portaudio")

(load "load.scm")
(play 'a 3)
(define win (window))
(plot win 'a)
(plot win 'c "red")
(plot win (wave:+ 'a 'c) "blue")
(plot win (wave:normalize (wave:+ 'a 'c)) "orange")
```