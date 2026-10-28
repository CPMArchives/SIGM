/*
	Line printer formatter 

	Written by Leor Zolman
		   May 28, 1980

	-------------------------------------------------------------------
	Modifications by John Hastwell-Batten   16th January 1983

	1)	Includes line-printer configuration commands.  These are
		specific to Epson MX100 (& MX80) but could serve as an
		example for other printers.

	2)	Reads date from QT systems calendar/clock board.

	3)	WILDEXP and DIO added.


	PRINTER CONFIGURATION COMMANDS:

	A command-line or interactive entry prefixed with a hyphen (-) is
	treated as a set of printer configuration commands.  Each command
	is a single letter which may be followed by a number (must be non-
	zero to be effective).

	The commands implemented are:

		Bn	Set automatic skip-over-perforations (n lines),
		B	Cancel perforation skip,
		Cn	Select character set n
		F	Skip to new page on first file
		Hn	Enable page heading
		H	Suppress page heading
		In	Indent each data line n columns
		Ln	Set form length to n inches
		Nn	Turn on line numbering
		N	Suppress line numbers

	Examples:
		-b6fn1	specifies perforation skip of 6 lines, starts listing
			with a page throw and turns on line numbering.

		-i15h1	indents each line in the body of the listing by 15
			columns and prints a heading on each page.

	Defaults:
		A call on the printer configuration procedure is done by this
		program before any parameters are scanned.  The configuration
		is set to NH1I15C0, i.e. line-numbering off, page headings on,
		15-column indenting and character set 0 (USA) is selected.

		The defaults are easily modified by altering the parameter to
		the configuration procedure.

	---------------------------------------------------------------------

	First prints all files named on the command line, and then
	asks for names of more files to print until a null line is typed.
	Control-Q aborts current printing and goes to next file.

	Paper should be positioned ready to print on the first page.

	Tabs are expanded into spaces.	(NO! Tab stops are set on the MX100
					 and tabs in the text are NOT expanded.
					 John H-B.)

*/

#include "bdscio.h"
#include "dio.h"

#define FF 0x0C		/* formfeed character, or zero if not supported */
#define PGLEN 66	/* lines per lineprinter page */

char colno, linesleft;
char indenting, headings, numbering;
unsigned linenumber, charcount;

#include <clock.h>

main(argc,argv)
char **argv;
{
	int i, pgno, fd;
	char date[30], linebuf[135];	/* date and line buffers */
	char fnbuf[30], *fname;		/* filename buffer & ptr */
	char numbuf[8];			/* place to build line number */
	char ibuf[BUFSIZ];		/* buffered input buffer */
	char *gets();

	wildexp(&argc,&argv);
	dioinit(&argc,argv);
	pgno = colno = 0;
	linesleft = PGLEN; 
	clock(date);
	printf("Today's date is %s\n",date);
	setmem(numbuf,8,0);
	lpoption("NHI12C0");
	while (1)
	{
		if (argc-1) {
		  fname = *++argv;
		  argc--; }
		else {
		  printf("\nEnter file to print, or CR if done: ");
		  if (!*(fname = gets(fnbuf)))
		    break; }

		if (*fname == '-') {
		  lpoption(++fname);
		  continue; }
		else
		   if ((fd = fopen(fname,ibuf)) == ERROR) {
		     printf("\n<<< Can't open %s >>>\n",fname);
		     continue; }
		   else {
		     l_to_u(fname);
		     linenumber = charcount = 0;
		     printf("\n+++ Printing %s +++\n",fname); }

		for (pgno = 1; ; pgno++) {
		  putchar((pgno % 10) ? '-' : '+');
		  if (headings) {
		    sprintf(linebuf,
				"\016%-20s%5s%-3d%36s\023\n\n",
				fname,"Page ",pgno,date);
		    linepr(linebuf); }

	loop:	  if (!fgets(linebuf,ibuf)) {
		    Printf("\n+++ End of %s +++\n",fname);
		    printf("\t%d lines, %d characters\n",linenumber,charcount);
		    break; }
		  if (kbhit() && getchar() == 0x11) {
		    printf("\n+++ Skipping to next file +++\n");
		    break; }
		  if (indenting) putlpr('\t');
		  linenumber++;
		  if (numbering) {
		    sprintf(numbuf,"%5d:\t",linenumber);
		    if (linepr(numbuf)) continue; }
		  if (linepr(linebuf)) continue;
		  if (linesleft > 6)
		    goto loop;
		  formfeed(); }
		formfeed();
/*		if (pgno % 2) formfeed();	*/
		fabort(fd);
	}
	dioflush();
}

/*
	Print a line of text out on the list device, and
	return true if a formfeed was encountered in the
	text.
*/

linepr(string)
char *string;
{
	char c, ffflag;
	ffflag = 0;
	while (c = *string++) {
	  charcount++;
	  switch (c) {
	    case FF:
		ffflag = 1;
		break;
	    case '\n':	
		putlpr('\r');
		putlpr('\n');
		colno = 0;
		linesleft--;
		break;
/*
	    case '\t':
		do {
		  putlpr(' ');
		  colno++;
		} while (colno % 8);
		break;
*/
	    default:					
		putlpr(c);
		colno++;
	} }
	if (ffflag) formfeed();
	return ffflag;
}

putlpr(c)
char c;
{
	bios(5,c);
}

formfeed()
{
	if (FF) putlpr(FF);
	else while (linesleft--) putlpr('\n');
	linesleft = PGLEN;
}

/* LPOPTION:	This routine interprets a string as a series of commands
		to set up an Epson MX100 for subsequent printing.

		The commands implemented are:

			Bn	Set automatic skip-over-perforations,
			Cn	Select character set n
			F	Skip to new page on first file
			Hn	Enable page heading
			H	Suppress page heading
			I	Indent each data line n columns
			Ln	Set form length to n inches
			Nn	Turn on line numbering
			N	Suppress line numbers
									*/
lpoption(opts)		char *opts;
{
	char	c, v, stops;

	while (c=*opts++)
	    {
		switch (toupper(c))
		    {
case 'B':
			v = atoi(*opts);
			while (isdigit(*opts++));
			--opts;
			putlpr('\033');
			putlpr('N');
			putlpr(v);
			printf("- End-of-page skip set to %d lines\n",v);
			break;
case 'C':
			putlpr('\033');
			putlpr('R');
			if (isdigit(*opts))
			    putlpr(v=*opts++ & 7);
			printf("- Character set %d selected\n",v);
			break;
case 'F':
			v = formfeed();
			printf("- Advancing to new page\n");
			break;
case 'H':
			if (headings = atoi(opts))
				printf("- Page headings enabled\n");
			else
				printf("- Page headings suppressed\n");
			while (isdigit(*opts++));
			--opts;
			break;
case 'I':
			indenting = atoi(opts);
			while (isdigit(*opts++));
			--opts;
			putlpr('\033');
			putlpr('D');
			stops = 12;
			printf("- Indenting set to %d columns\n",indenting);
			for (v=(indenting ? (indenting+1) : 9); stops--; v=v+8)
				putlpr(v);
			putlpr(0);
			break;
case 'L':
			if (!(v=atoi(opts)))
			  v = 11;
			while (isdigit(*opts++));
			--opts;
			putlpr('\033');
			putlpr('C');
			putlpr('\0');
			putlpr(v);
			printf("- Page length set to %d inches\n",v);
			break;
case 'N':
			if (numbering = atoi(opts))
				printf("- Line numbering enabled\n");
			else
				Printf("- Line numbering suppressed\n");
			while (isdigit(*opts++));
			--opts;
			break;
default:
			printf("- Invalid format specifier: %c\n",*opts);
		    }
	 }
}

l_to_u(string)	char *string;
{	while (toupper(*string++)) ; }

clock(date)

	char *date;
{
	struct _time tick ;
	struct _date tock ;
	char *days[7], *months[12] ;
	char   *suffix[3];
	int    dd;	
	suffix[0] = "th";		suffix[1] = "st";
	suffix[2] = "nd";		suffix[3] = "rd";
	months[0] = "January";		months[1] = "February";
	months[2] = "March";		months[3] = "April";
	months[4] = "May";		months[5] = "June";
	months[6] = "July";		months[7] = "August";
	months[8] = "September";	months[9] = "October";
	months[10] = "November";	months[11] = "December";
	days[0] = "Sun";		days[1] = "Mon";
	days[2] = "Tues";		days[3] = "Wednes";
	days[4] = "Thurs";		days[5] = "Fri";
	days[6] = "Satur";

		getdate(&tock) ;
		if ((tock.day / 10 == 1) | (tock.day % 10 > 4))
			dd = 0;
		else
			dd = tock.day % 10;
		sprintf(date,"%sday %2d%s %s 19%02d\0",
			days[tock . weekday], tock.day, suffix[dd],
			months[tock.month], tock.year) ;
	}

getdate(now) struct _date *now; {
	char i, time[7] ;

	outp(CLDATA, CLHOLD) ;
	for (i = 0; i < 7; i++)
		time[i] = getclock(i + 6) ;
	outp(CLDATA, CLREL) ;
	now -> day = time[1] + 10 * (time[2] & CLOMASK) ;
	now -> month = time[3] + 10 * time[4] - 1 ;
	now -> year = time[5] + 10 * time[6] ;
	now -> weekday = *time ;
	}

char getclock(reg) char *reg; {
	char x ;

	outp(CLADDR, reg + CLOFF) ;
	x = inp(CLADDR) & CLMASK ;
	return x ;
	}
