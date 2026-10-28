/*------------------------------------------------------------
A program to translate those .WPF files on this system
into a format more amenable to normal program text
editors.

Quick, dirty and VERY data-dependent.  Will probably
screw up (slightly) if it encounters two adjacent quote
marks and you'll probably want to go through the output
file anyway to line up the comments.  Nevertheless the
output looks reasonable.

Command format:
	WPF <input file> <output file>

Sorry, but you must specify the full names, e.g.
	WPF LOCK.WPF LOCK.MAC
but what do you expect for half an hour's effort while
waiting to log on to this system, perfection?

Written for & compiled with BDS C 1.46 (I haven't put 1.5
on my YAM/RCPM disk yet).

				John Hastwell-Batten.

--------------------------------------------------------*/

#include "bdscio.h"
#define SINGLEQ 0x2C
#define DOUBLEQ 0x21
char ibuf[BUFSIZ], obuf[BUFSIZ];
main(argc,argv)  char **argv;
{ int c;
  char inquote, incomment, colons;
  if (argc != 3) {
	printf("Usage: CR infile outfile\n");
	exit();		}
  if (fopen(argv[1],ibuf) == ERROR) {
	printf("Can't open %s\n",argv[1]);
	exit();			    }
  if (fcreat(argv[2],obuf) == ERROR) {
	printf("Can't create %s\n",argv[2]);
	exit();			}
  inquote = incomment = FALSE;
  while ((c=getc(ibuf)) != EOF && c != CPMEOF)	{
	if (!incomment)
		if (c==SINGLEQ || c==DOUBLEQ)
			inquote = !inquote;
	if (!incomment && !inquote)
		incomment = c==';';
	if (!incomment && !inquote)	{
		if (c==' ')
			emit('\t');
		else				{
			emit(c);
			if (c==':')			{
				if (++colons == 2)		{
					emit('\r');
					emit('\n');	}	}
			else
				colons = 0;
					}	}
	else
		emit(c);
	if (c==0x0D) 	{
		emit('\n');
		incomment = inquote = FALSE;
			}			}
  emit(CPMEOF);
  fflush(obuf);
  fclose(obuf);
  fclose(ibuf);
}
emit(c)  char c;
{	if (putc(c,obuf) == ERROR) {
		printf("Disk probably full\n");
		exit();	}
}
