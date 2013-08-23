/*
**	The information is specified in one line per char like this:
**	'\033',2501,hoff=2,voff=1,hratio=10/14,vratio=10/14
**	The first parameter is in C char constant syntax, the
**	second is an unsigned integer.
**	hoff and voff are added to the numerator in the above
**	coordinates.
**	hratio and vratio control the size of the characters in
**	the generated font.
**
**	Named parameters not specified default to the global
**	values which are (re)set by lines without the first two
**	parameters.
*/

typedef struct charinfo {
	int	asciiindex;		/* '\0' to '\377' */
	int	hersheyindex;		/* Hershey index number */
	char	*hoff,*voff;		/* offset to add to origin */
	char	*hratio, *vratio;	/* conversion from Hershey to mf */
} charinfo;

extern charinfo	global, perchar;

extern int	parsespecs();
