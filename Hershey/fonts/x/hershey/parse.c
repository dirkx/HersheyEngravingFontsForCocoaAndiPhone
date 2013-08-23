#include	<stdio.h>
#include	<ctype.h>
#include	"parse.h"

static char	copyright[]	= "Copyright (C) Ken Yap 1988";

static char	zerostring[]	= "0";
static char	onestring[]	= "1";
charinfo	global		= {
	-1, -1,
	onestring, onestring,
	};
charinfo	perchar;

static char *skipblanks(p)
	char		*p;
{
	while (isspace(*p) || *p == ',')	/* , is also space */
		++p;
	return (p);
}

static char *skipnonblanks(p)
	char		*p;
{
	while (*p != '\0' && !(isspace(*p) || *p == ','))
		++p;
	return (p);
}

static char *skippast(p, c)
	char		*p, c;
{
	while (*p != '\0' && *p != c)
		++p;
	return (*p == c ? p + 1 : p);
}

static int match(p, word)
	char		*p, *word;
{
	register int	l;

	l = strlen(word);
	return (strncmp(p, word, l) == 0);
}

static int getparams(p, ci)
	char		*p;
	charinfo	*ci;
{
	if (*p == '\'')			/* collect ascii index */
	{
		if (*++p != '\\')
			ci->asciiindex = (int)*p;
		else if (*++p == '\\')
			ci->asciiindex = (int)*p;
		else if (sscanf(p, "%o", &ci->asciiindex) != 1)
		{
			(void)fprintf(stderr, "Bad char index spec %s", p);
			return (0);
		}
		p = skippast(p+1, ',');
		p = skipblanks(p);
		if (!isdigit(*p))
		{
			(void)fprintf(stderr, "Missing Hershey index %s", p);
			return (0);
		}
		ci->hersheyindex = atoi(p);
		p = skippast(p, ',');
	}
	else if (isdigit(*p))
	{
		if (*p == '0')
		{
			if (sscanf(p, "%o", &ci->asciiindex) != 1)
			{
				(void)fprintf(stderr, "Bad char index spec %s", p);
				return (0);
			}
		}
		else
		{
			if (sscanf(p, "%d", &ci->asciiindex) != 1)
			{
				(void)fprintf(stderr, "Bad char index spec %s", p);
				return (0);
			}
		}
		p = skippast(p+1, ',');
		p = skipblanks(p);
		if (!isdigit(*p))
		{
			(void)fprintf(stderr, "Missing Hershey index %s", p);
			return (0);
		}
		ci->hersheyindex = atoi(p);
		p = skippast(p, ',');
	}
	p = skipblanks(p);
	while (*p != '\0')
	{
		if (match(p, "hoff"))
		{
			p = skippast(p, '=');
			p = skipblanks(p);
			ci->hoff = p;
		}
		if (match(p, "voff"))
		{
			p = skippast(p, '=');
			p = skipblanks(p);
			ci->voff = p;
		}
		if (match(p, "hratio"))
		{
			p = skippast(p, '=');
			p = skipblanks(p);
			ci->hratio = p;
		}
		if (match(p, "vratio"))
		{
			p = skippast(p, '=');
			p = skipblanks(p);
			ci->vratio = p;
		}
		p = skipnonblanks(p);
		if (*p != '\0')
		{
			*p = '\0';
			p = skipblanks(p+1);
		}
	}
	return (1);
}

int parsespecs(line)
	char		*line;
{
	register int	l;
	register char	*p;
	char		*malloc();

	line = skipblanks(line);
	if (*line == '\'')
	{
		perchar = global;		/* copy globals */
		return (getparams(line, &perchar));
	}
	else
	{
		l = strlen(line) + 1;
		if ((p = malloc(l)) == NULL)
		{
			perror("malloc");
			exit(1);
		}
		(void)strcpy(p, line);
		if (!getparams(p, &global))
			(void)fprintf(stderr, "Bad global spec %s", line);
		return (0);
	}
	/*NOTREACHED*/
}

#ifdef	STANDALONE
main()
{
	char		line[256];

	while (fgets(line, sizeof(line), stdin) != NULL)
		parsespecs(line);
	exit(0);
}
#endif	STANDALONE
