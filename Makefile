VERSION   := git-20150819

PREFIX    := /usr/local
MANPREFIX := $(PREFIX)/share/man
DESTDIRICON := /usr/share/icons/hicolor

CC        ?= gcc
CFLAGS    += -std=c99 -Wall -pedantic
CPPFLAGS  += -I$(PREFIX)/include -D_XOPEN_SOURCE=500
LDFLAGS   += -L$(PREFIX)/lib
LIBS      := -lX11 -lImlib2

# optional dependencies:
# giflib: gif animations
	CPPFLAGS += -DHAVE_GIFLIB
	LIBS     += -lgif
# libexif: jpeg auto-orientation, exif thumbnails
	CPPFLAGS += -DHAVE_LIBEXIF
	LIBS     += -lexif


.PHONY: clean install uninstall

SRC := commands.c image.c main.c options.c thumbs.c util.c window.c
DEP := $(SRC:.c=.d)
OBJ := $(SRC:.c=.o)

all: config.h sxiv

$(OBJ): Makefile

-include $(DEP)

%.o: %.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -DVERSION=\"$(VERSION)\" -MMD -MP -c -o $@ $<

config.h:
	cp config.def.h $@

sxiv:	$(OBJ)
	$(CC) $(LDFLAGS) -o $@ $(OBJ) $(LIBS)

clean:
	rm -f $(OBJ) $(DEP) sxiv

install: all
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp sxiv $(DESTDIR)$(PREFIX)/bin/
	chmod 755 $(DESTDIR)$(PREFIX)/bin/sxiv
	mkdir -p $(DESTDIR)$(MANPREFIX)/man1
	sed "s!PREFIX!$(PREFIX)!g; s!VERSION!$(VERSION)!g" sxiv.1 > $(DESTDIR)$(MANPREFIX)/man1/sxiv.1
	chmod 644 $(DESTDIR)$(MANPREFIX)/man1/sxiv.1
	mkdir -p $(DESTDIR)$(PREFIX)/share/sxiv/exec
	cp exec/* $(DESTDIR)$(PREFIX)/share/sxiv/exec/
	chmod 755 $(DESTDIR)$(PREFIX)/share/sxiv/exec/*
	cp sxiv.desktop /usr/share/applications/
	cd icon/ &&  cp 128x128.png $(DESTDIRICON)/128x128/apps/sxiv.png &&  cp 32x32.png $(DESTDIRICON)/32x32/apps/sxiv.png &&  cp 48x48.png $(DESTDIRICON)/48x48/apps/sxiv.png &&  cp 64x64.png $(DESTDIRICON)/64x64/apps/sxiv.png &&  cp 16x16.png $(DESTDIRICON)/16x16/apps/sxiv.png && cd ../

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/sxiv
	rm -f $(DESTDIR)$(MANPREFIX)/man1/sxiv.1
	rm -rf $(DESTDIR)$(PREFIX)/share/sxiv
	rm -f /usr/share/applications/sxiv.desktop
	rm -f $(DESTDIRICON)/128x128/apps/sxiv.png &&rm -f $(DESTDIRICON)/32x32/apps/sxiv.png && rm -f $(DESTDIRICON)/48x48/apps/sxiv.png && rm -f $(DESTDIRICON)/64x64/apps/sxiv.png &&  rm -f $(DESTDIRICON)/16x16/apps/sxiv.png
