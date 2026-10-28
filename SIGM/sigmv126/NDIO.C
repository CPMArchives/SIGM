/* June 18, 1983 */
#include "macro.h"	/*June 18, 1983*/



#define CON_INPUT 1			/* BDOS call to read console	   */
#define CON_OUTPUT 2			/* BDOS call to write to console   */
#define CON_STATUS 11			/* BDOS call to interrogate status */

#define CONTROL_C 3			/* Quit character		   */
#define INPIPE 2			/* bit setting to indicate directed
					   input from a temp. pipe fil     */
#define VERBOSE 2			/* bit setting to indicate output is to
					   go to console AND directed output */
#define DIRECTED_OUT 1
#define CONS_TOO 2
#define CPM_LIST_OUT 4
#define PRINTER_OUT 8
#define ROBOTYPE_OUT 16
#define CONSOLE_ONLY 0

/* 
	The "dioinit" function must be called at the beginning of the
	"main" function:
*/

dioflush()
{
	if (_diflag)
	{
		fclose(_dibuf);
		if (_diflag & INPIPE) unlink("tempin.$$$");
	}

	if (_doflag)
	{
		putc(CPMEOF,_dobuf);
		fflush(_dobuf);
		fclose(_dobuf);
		if (OK != strcmp ("TEMPOUT.$$$", sav_out_file))
		      { unlink (sav_out_file);
			rename ("TEMPOUT.$$$", sav_out_file);
		      }
		rename("tempout.$$$","tempin.$$$");
		if (_pipef) 
		{
			*_savei = "<TEMPIN.$$$";
			*_nullpos = NULL;
			execv(_pipedest,_savei);
		}
	}
}


/*
	This version of "getchar" replaces the regular version when using
	directed I/O:
*/

getchar()
{
	char c;

	if (_diflag) {
		if ((c = getc(_dibuf)) == '\r') c = getc(_dibuf);
	} else
		if ((c = bdos(CON_INPUT)) == CONTROL_C) exit();

	if (c == CPMEOF) return EOF;	     /* Control-Z is EOF key 	*/
	if (c == '\r') 
	{
		c = '\n';
		if (!_diflag) bdos(2,'\n');  /* echo LF after CR to console */
	}
	return c;
}


/*
	This version of "putchar" replaces the regular version when using
	directed I/O:
*/

putchar(c)
char c;
{
	if (_doflag & DIRECTED_OUT)
	{
		if (c == '\n') putc('\r',_dobuf);
		if(putc(c,_dobuf) == ERROR)
		{
			fprintf(STDERR,"File output error; disk full?\n");
			exit();
		}
	}

	if (_doflag==0 || _doflag & CONS_TOO)
	{
	if (bdos(CON_STATUS) && bdos(CON_INPUT) == CONTROL_C) exit();
	if (c == '\n') bdos(CON_OUTPUT,'\r');
	bdos(CON_OUTPUT,c);
	}

	if (_doflag & CPM_LIST_OUT)
	{
		bdos(5,c);
		if (c=='\n') bdos(5,'\r');
	}
	if (_doflag & PRINTER_OUT)
	{
		bdos(5,c);
	}
	if (_doflag & ROBOTYPE_OUT)
	{
		fprintf(STDERR,"sending ROBO <%c>	",c);
	}
}
/****************************************/
#define argc *argcp
dioinit(argcp,argv)
int *argcp;
char **argv;
{
	int i,j, argcount;
	int n;	/* this keeps track of location in argument */

	_diflag = _doflag = _pipef = FALSE;  /* No directed I/O by default   */
	_nullpos = &argv[argc];
	argcount = 1;

	for (i = 1; i < argc; i++)	/* Scan the command line for > and < */
	{
		if (_pipef) break;
		n=0;	/* start with first character */
getmore:	switch(argv[i][n++]) {

		   case '<':		/* Check for directed input: */
			if (!argv[i][n]) goto barf;
			if (fopen(&argv[i][n], _dibuf) == ERROR)
			{
				fprintf(STDERR,"Can't open %s\n",&argv[i][n]);
				exit();
			}
			_diflag = TRUE;
			if (strcmp(argv[i],"<TEMPIN.$$$") == 0)
				 _diflag |= INPIPE;
			goto movargv;

		   case '|':	/* Check for pipe: */
			_pipef++;
			_pipedest = &argv[i][n]; /* save prog name for execl */
			if (argv[i][n]) 
			{
				argv[i] = ".TEMPOUT.$$$";  /* temp. output */
				_savei = &argv[i];
			}
			goto foo;

		   case '+': 
			_doflag |= VERBOSE;
			goto getmore;
		   case ')':
			_doflag |= CPM_LIST_OUT;
			goto getmore;
		   case '}':
			_doflag |= PRINTER_OUT;
			goto getmore;
		   case ']':
			_doflag |= ROBOTYPE_OUT;
			goto getmore;
			
	     foo:   case '>':	/* Check for directed output	*/
		
			if (!argv[i][n]) 
			{
		    barf:   fprintf(STDERR,"Bad redirection/pipe specifier");
			    exit();
			}
			strcpy (sav_out_file, &argv[i][n] );
			if (fcreat("TEMPOUT.$$$", _dobuf) == ERROR)
			{
				fprintf(STDERR,"\nCan't create <%s>\n",
                                                     "TEMPOUT.$$$");
			       exit();
			}
			_doflag++;

	     movargv:	if (!_pipef) {
				for (j = i; j < argc; j++) argv[j] = argv[j+1];
				(argc)--;
				i--;
				_nullpos--;
			 } else {
				argc = argcount;
				argv[argc] = 0;
			 }
			break;

		    default:	/* handle normal arguments: */
				if (n!=1) goto movargv;
			argcount++;
		}
	}
}


#undef argc


			goto foo;

		   case '+': 
			_doflag |= VERBOSE;
			goto getmore;
		   ca