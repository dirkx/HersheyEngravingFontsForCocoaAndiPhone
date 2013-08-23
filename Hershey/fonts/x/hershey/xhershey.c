#include	<stdio.h>

#ifndef	NO_X_WINDOW
#include	<X11/Xlib.h>
#include	<X11/Xatom.h>
#endif	NO_X_WINDOW

#include	"font.h"
#include	"parse.h"

#define		MAXPIXEL	25
#define		NORMALVOFF	9	/* Normal baseline for Hershey fonts */
#define		CTOI(c)		((c)-'R')

static char	copyright[]	= "Copyright (C) Ken Yap 1988";

static char	*progname;
static char	mfcode		= 1;	/* generate METAFONT code */
static char	xwin		= 1;	/* plot in X window */
static char	nums		= 0;	/* 0: none , 1: end points, 2: all */
static char	*fontlib	= "occidental";
static int	mag		= 2;
static int	xorg, yorg;
#ifndef	NO_X_WINDOW
Display 		*d;
Window			w;
XSetWindowAttributes	xswa;
Visual			visual;
GC			gc;
XGCValues		xgcv;
#endif	NO_X_WINDOW

main(argc, argv)
	int		argc;
	char		*argv[];
{
	register int	i;
	extern int	optind;
	extern char	*optarg;
	char		*rindex();

	if ((progname = rindex(argv[0], '/')) != NULL)
		++progname;
	else
		progname = argv[0];

	while ((i = getopt(argc, argv, "f:m:n:MX")) != EOF)
		switch (i)
		{
		case 'f':		/* different Hershey database */
			fontlib = optarg;
			break;
		case 'm':		/* magnification in window */
			mag = atoi(optarg);
			if (mag <= 0 || mag > 10)
				mag = 2;
			break;
		case 'n':		/* put numbers on points */
			nums = atoi(optarg);
			if (nums <= 0 || nums > 2)
				nums = 0;
			break;
		case 'M':		/* no METAFONT code */
			mfcode = 0;
			break;
		case 'X':		/* no X window */
			xwin = 0;
			break;
		default:
			usage();
			break;
		}

	argc -= optind;
	argv += optind;
	if (argc > 0)
	{
		if (freopen(argv[0], "r", stdin) == NULL)
		{
			perror(argv[0]);
			exit(1);
		}
	}

	xhershey(fontlib);
	exit(0);
}

static usage()
{
	(void)fprintf(stderr, "Usage: xhershey [-f fontlib] [-m mag] [-n annotelevel] [-M] [-X]\n");
	exit(1);
}

static xhershey(fontfilename)
	char		*fontfilename;
/*
**	Main loop, get user input, plot char, output code
*/
{
	register FILE	*fontfile;
	char		line[512];
	int		parsespecs();
	Window		makewindow();

	if ((fontfile = fopen(fontfilename, "r")) == NULL)
	{
		perror(fontfilename);
		return;
	}
#ifndef	NO_X_WINDOW
	if (xwin)
	{
		if ((w = makewindow(progname)) == (Window)0)
		{
			fprintf(stderr, "Can't make X11 window\n");
			exit(1);
		}
	}
#endif
	scanfont(fontfile);
	(void)fprintf(stderr, "Font file ready...\n");
	while (fgets(line, sizeof(line), stdin) != NULL)
	{
		if (parsespecs(line))
		{
			if (getline(fontfile, perchar.hersheyindex, line, sizeof(line)))
			{
#ifdef	PRINTDATA		/* see raw data */
				fputs(line, stderr);
#endif	PRINTDATA
				if (mfcode)
					genchar(line);
#ifndef	NO_X_WINDOW
				if (xwin)
					displaychar(line);
#endif	NO_X_WINDOW
			}
			else
				(void)fprintf(stderr, "Char %d not in font\n",
					perchar.hersheyindex);
		}
	}
	(void)fclose(fontfile);
}

#ifndef	NO_X_WINDOW
Window makewindow(title)
	char		*title;
{
	Window		w;
	register int		width, height;
	XEvent		event;

	xorg = MAXPIXEL * mag;
	yorg = MAXPIXEL * mag;
	width = xorg * 2;
	height = yorg * 2;

	if (!(d = XOpenDisplay((char *)0)))
		return ((Window)0);

	xswa.event_mask = ExposureMask | ButtonPressMask;
	xswa.background_pixel = WhitePixel(d, DefaultScreen(d));
	xswa.border_pixel = BlackPixel(d, DefaultScreen(d));
	visual.visualid = CopyFromParent;

	if ((w = XCreateWindow(d, RootWindow(d, DefaultScreen(d)),
		0, 0,
		width, height,
		1, 1,
		InputOutput, &visual,
		CWEventMask | CWBorderPixel | CWBackPixel,
		&xswa)) == (Window)0)
		return (0);

	XChangeProperty(d, w, XA_WM_NAME, XA_STRING, 8,
		PropModeReplace, title, strlen(title));

	XMapWindow(d, w);

	xgcv.foreground = BlackPixel(d, DefaultScreen(d));
	xgcv.background = WhitePixel(d, DefaultScreen(d));
	gc = XCreateGC(d, w, GCForeground | GCBackground, &xgcv);

	XNextEvent(d, &event);
	switch (event.type)
	{
	case Expose:
		while (XCheckTypedEvent(d, Expose, &event))
			;
		break;
	default:
		(void)fprintf(stderr, "Unknown event type %d\n", event.type);
		break;
	}
	return (w);
}

static displaychar(buf)
	char		*buf;
/*
**	Plot char in window
*/
{
	register int	i, npoints, oxpos, oypos, xpos, ypos, xmin, xmax;
	register char	*p;
	char		spoints[4];
	XEvent		event;

	XClearWindow(d, w);
	spoints[3] = '\0';
	(void)strncpy(spoints, &buf[5], 3);
	p = &buf[8];

	/* first point fixes origin of char */
	xmin = CTOI(*p++) * mag + xorg;
	xmax = CTOI(*p++) * mag + xorg;
	ypos = NORMALVOFF * mag + yorg;
	XDrawLine(d, w, gc, 0, ypos, xorg*2-1, ypos);
	XDrawLine(d, w, gc, xmin, 0, xmin, yorg*2-1);
	XDrawLine(d, w, gc, xmax, 0, xmax, yorg*2-1);

	npoints = atoi(spoints) - 1;
	/* get first point */
	oxpos = CTOI(*p++) * mag + xorg;
	oypos = CTOI(*p++) * mag + yorg;
	if (nums > 0)
		XDrawString(d, w, gc, oxpos + 2, oypos, "0", 1);
	for (i = 1; i < npoints; ++i)
	{
		/* lift pen */
		if (*p == ' ')
		{
			p += 2;
			++i;
			oxpos = CTOI(*p++) * mag + xorg;
			oypos = CTOI(*p++) * mag + yorg;
			if (nums > 0)
			{
				sprintf(spoints, "%d", i);
				XDrawString(d, w, gc, oxpos + 2, oypos,
					spoints, strlen(spoints));
			}
		}
		else
		{
			xpos = CTOI(*p++) * mag + xorg;
			ypos = CTOI(*p++) * mag + yorg;
			XDrawLine(d, w, gc, oxpos, oypos, xpos, ypos);
			if (nums == 2 || nums == 1
				&& (*p == ' ' || i == npoints - 1))
			{
				sprintf(spoints, "%d", i);
				XDrawString(d, w, gc, xpos + 2, ypos,
					spoints, strlen(spoints));
			}
			oxpos = xpos;
			oypos = ypos;
		}
	}
	for (;;)
	{
		XNextEvent(d, &event);
		switch (event.type)
		{
		case Expose:
			while (XCheckTypedEvent(d, Expose, &event))
				;
			break;
		case ButtonPress:
			return;
			break;
		default:
			(void)fprintf(stderr, "Unknown event type %d\n", event.type);
			break;
		}
	}
}
#endif	NO_X_WINDOW

static genchar(buf)
	char		*buf;
/*
**	Generate METAFONT code for char
*/
{
	register int	i, npoints, oxpos, oypos, xpos, ypos;
	register char	*p;
	int		x0, y0, start, width, ymax = 0, ymin = 256;
	char		spoints[4];

	spoints[3] = '\0';
	(void)strncpy(spoints, &buf[5], 3);
	npoints = atoi(spoints) - 2;
	p = &buf[8];

	/* first two numbers are xmin and xmax */
	x0 = CTOI(*p++);
	width = CTOI(*p++) - x0;
	x0 += atoi(perchar.hoff);
	y0 = NORMALVOFF + atoi(perchar.voff);
	/* find height and depth */
	for (i = 0; i < npoints; ++i, p += 2)
	{
		if (*p != ' ')
		{
			ypos = y0 - CTOI(p[1]);
			if (ypos > ymax)
				ymax = ypos;
			if (ypos < ymin)
				ymin = ypos;
		}
	}
	if (ymin > 0)
		ymin = 0;

	/* output header */
	(void)printf("x#:=%su#; y#:=%su#;\n", perchar.hratio, perchar.vratio);
	if ('!' <= perchar.asciiindex && perchar.asciiindex <= '~' && perchar.asciiindex != '"')
		(void)printf("beginchar(\"%c\",%dx#,%dy#,%dy#); \"The letter %c\";\n",
			perchar.asciiindex, width, ymax, -ymin,
			perchar.asciiindex);
	else
		(void)printf("beginchar(char %d,%dx#,%dy#,%dy#); \"The letter '\\%03o'\";\n",
			perchar.asciiindex, width, ymax, -ymin,
			perchar.asciiindex);
	(void)printf("adjust_fit(0,0); pickup plotter_pen;\n");
	(void)printf("x:=%su; y:=%su;\n", perchar.hratio, perchar.vratio);

	p = &buf[10];
	/* get first point */
	start = 0;
	oxpos = CTOI(*p++) - x0;
	oypos = y0 - CTOI(*p++);
	(void)printf("z%d=(%dx,%dy);\n", start, oxpos, oypos);
	for (i = 1; i <= npoints; ++i)
	{
		/* lift pen */
		if (*p == ' ')
		{
			outlist(start, i-1);
			p += 2;
			++i;
			oxpos = CTOI(*p++) - x0;
			oypos = y0 - CTOI(*p++);
			start = i;
			(void)printf("z%d=(%dx,%dy);\n", i, oxpos, oypos);
		}
		else
		{
			xpos = CTOI(*p++) - x0;
			ypos = y0 - CTOI(*p++);
			(void)printf("z%d=(%dx,%dy);\n", i, xpos, ypos);
			oxpos = xpos;
			oypos = ypos;
		}
	}
	outlist(start, i-1);
	(void)printf("endchar;\n");
}

static outlist(start, end)
	int		start, end;
/*
**	Output a list of points to join with curve
*/
{
	register int	i;

	/* null case? */
	if (start == end)
		return;
	(void)printf("draw ");
	for (i = start; i < end; ++i)
		(void)printf("z%d--", i);
	(void)printf("z%d;\n", end);
}
