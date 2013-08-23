#include	<stdio.h>

static char	copyright[]	= "Copyright (C) Ken Yap 1988";

static long	position[10000];
#define	sizeoftab	(sizeof(position)/sizeof(position[0]))

scanfont(f)
	FILE		*f;
{
	register int	i, index;
	register long	pos;
	char		line[512];
	char		sindex[6];

	for (i = 0; i < sizeoftab; ++i)
		position[i] = -2;
	sindex[5] = '\0';
	pos = 0L;
	while (fgets(line, sizeof(line), f) != NULL)
	{
		(void)strncpy(sindex, line, 5);
		index = atoi(sindex);
		if (index < 0 || index >= sizeoftab)
		{
			(void)fprintf(stderr, "Bad char index %s\n", sindex);
			continue;
		}
		position[index] = pos;
		pos = ftell(f);
	}
	(void)fseek(f, 0L, 0);
}

int getline(f, index, buf, buflen)
	FILE		*f;
	int		index;
	char		*buf;
	int		buflen;
{
	register long	pos;

	if (index < 0 || index >= sizeoftab)
		return (0);
	if ((pos = position[index]) < 0)
		return (0);
	if (fseek(f, pos, 0) < 0)
		return (0);
	if (fgets(buf, buflen, f) == NULL)
		return (0);
	return (1);
}
