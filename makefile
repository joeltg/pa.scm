all: build

install:
	echo '(install-shim "$(DESTDIR)" "portaudio")' | mit-scheme --batch-mode

clean:
	rm portaudio-const* portaudio-types* portaudio-shim* 

build: portaudio-shim.so portaudio-types.bin portaudio-const.bin

portaudio-shim.so: portaudio-shim.o
	echo "(link-shim)" | mit-scheme --batch-mode -- -o $@ $^ -L/usr/local/lib -lportaudio

portaudio-shim.o: portaudio-shim.c
	echo '(compile-shim)' | mit-scheme --batch-mode -- -I/usr/local/include -c $<

portaudio-shim.c portaudio-const.c portaudio-types.bin: portaudio.cdecl
	echo '(generate-shim "portaudio" "#include <portaudio.h>")' | mit-scheme --batch-mode

portaudio-const.bin: portaudio-const.scm
	echo '(sf "portaudio-const")' | mit-scheme --batch-mode

portaudio-const.scm: portaudio-const
	./portaudio-const

portaudio-const: portaudio-const.o
	$(CC) -o $@ $^ $(LDFLAGS) -L/usr/local/lib -lportaudio

portaudio-const.o: portaudio-const.c
	$(CC) -I/usr/local/include $(CFLAGS) -o $@ -c $<
