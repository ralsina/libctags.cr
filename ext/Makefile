SOURCES = readtags.c readtags.h

all: build

build: $(SOURCES)
	$(CC) -c $(SOURCES)
	ar rcs libreadtags.a readtags.o

clean:
	rm -rf *.o *.a *.so
