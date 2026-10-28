/*
	Program to "scrub" a WordStar text file back to a
	standard ASCII file.

VERSION LIST, most recent version first

26/Sep/82
	Forces MSB of all characters to 0, then scans for control
	codes. TAB, CR and LF are passed unchanged to the output
	file. US (soft hyphen) is replaced by a hard hyphen.
	Checking for legal CP/M filename on destination file
	added. Expanded "usage" message. Added "working" messages.
	Bill Bolton. 

	This program was developed from a program called SCRUB
	on BDS "C" User Group disk "Utilities 2" (Volume 2 in
	the Software Tools RCPM BDSCAT.ALL).
*/

/*
	Macros for constant definitions
*/

#include <STDIO.H>

#define VERSION 1	/* main version number */
#define REVISION 1	/* sub version number */
#define DEL 0x7F	/* ASCII delete character */
#define WORKING 1024	/* number of chars between progress markers */
#define NEXTLINE (WORKING * 32) /* number of progess chars on a screen line */
#define CPMEOF 0x1A	/* CP/M-86 end of file marker */
#define ERROR 0		/* Normal file error condition */
#define FERROR -1	/* Flush file error */

/*
	Argument vector indices
*/

#define FROM_FILE 1
#define TO_FILE   2

/*
	main to open the files for scrub()
	and handle invocation errors.
*/

main(argc,argv)
int argc;
char *argv[];

{
	char *fdin,*fdout;
	char buf[12];

	printf("\nWordStar file Scrubber Version %d.%d\n",VERSION,REVISION);
	printf("Bill Bolton, Software Tools\n");
	if( argc != 3 )
			usage();
	else {
		if( (fdin = fopen(argv[FROM_FILE],"r")) == ERROR){
			printf("\nCannot find file %s\n",argv[FROM_FILE]);
			usage();
		}
		else {
			if( (fdout  = fopen(argv[TO_FILE],"w")) == ERROR )
				printf("\nCan't open %s\n",argv[TO_FILE]);
			else {
				printf("\nWorking ");
				scrub(fdin,fdout);
			}
		}
	}
	exit();
}

/*
	procedure scrub -- copy file to file deleting unwanted control chars
*/

scrub(fdin,fdout)
FILE *fdin;	/* the input file buffer */
FILE *fdout;	/* the output file buffer */

{
	int c;			/* 1 char buffer */
	long count;		/* count of characters processed */
	long killed;		/* numbers of bytes deleted */
	long hyphen;		/* number of soft hyphens replaced */

	count  = 0;
	killed = 0;
	hyphen = 0;

	while( (c = getc(fdin)) != EOF  && c != CPMEOF ){
		c &= 0x7F;
		count++;
		if (count % WORKING == 0)
			printf("*");		/* still alive */
		if (count % NEXTLINE == 0)
			printf("\n\t");		/* new line every so often */
		if( c >= ' ' && c < '\177' )	/* visable character ? */
			putc(c,fdout);
		else
			switch(c) {
				case '\r':
				case '\n':
				case '\t':
					putc(c,fdout); /* ok control chars */
					break;

				case '\037':	/* replace WS soft hyphen */
					putc('-',fdout);
					hyphen++;
					break;

				default:
					killed++;
					break;		 /* ignore it */
  			}
	}
	putc(CPMEOF,fdout);			 /* sent textual end of file */
	printf("\n");
	if( fflush(fdout) == FERROR)
		exit(puts("\nOutput file flush error\n"));
	printf("\n%ld characters processed\n",count);
	printf("%ld characters were deleted\n",killed);
	printf("%ld soft hyphens replaced\n",hyphen);
}

usage()

{
		printf("\nUsage:\n\n");
		printf("\tSCRUB d:file1 d:file2\n\n");
		printf("Where:\n");
		printf("\tfile1 = source file, (* and ? not allowed)\n");
		printf("\tfile2 = destination file, (* and ? not allowed)\n");
		printf("\td:    = optional drive identifier\n\n");
		printf("i.e.\tSCRUB A:FOOBAR.WST B:FUBAR.DOC\n");
}

/* end of scrub */
