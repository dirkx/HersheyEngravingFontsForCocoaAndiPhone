DBUG		= -g
CFLAGS		= -I/usr/staff/include $(DBUG)
LIBRARIES	= -L/usr/staff/lib -lX11

.SUFFIXES:	.spec .mf .300pk

xhershey:	xhershey.o font.o parse.o
	$(CC) $(DBUG) -o $@ xhershey.o font.o parse.o $(LIBRARIES)

xhershey.o:	xhershey.c font.h parse.h

font.o:		font.c

parse.o:	parse.c parse.h

.spec.mf:
		xhershey -X $*.spec > $*.mf

.mf.300pk:
		cmmf '\mode=localfont; input $*'
		gftopk $*.300gf
		rm $*.300gf

hscs10:		hscs10.300pk

hscs10.300pk:	hershey10.mf hscs.mf hscs10.mf

hgoe10:		hgoe10.300pk

hgoe10.300pk:	hershey10.mf hgoe.mf hgoe10.mf

backup:
		ctar README *.c *.h *.icn *.spec *.mf *.1 Makefile | rsh can 'cd Src/Window/X11/Xhershey; vtar'
