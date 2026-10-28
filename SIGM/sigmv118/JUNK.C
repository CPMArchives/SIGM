#include "a:stdio.h"
#include "xlisp.h"

int getch(fp)
  FILE *fp;
{
	int ch;

	if ((ch = agetc(fp)) == '\032')
		return (EOF);
	else
		return (ch);
}

char *calloc(n,size)
  unsigned n,size;
{
	char *str;
	unsigned nsize,i;

	if ((str = malloc(nsize = n * size)) == NULL)
		return (NULL);
	for (i = 0; i < nsize; i++)
		str[i] = 0;
	return (str);
}
 ((str 