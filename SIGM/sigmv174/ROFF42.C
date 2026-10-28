/********************************************************/
/*							*/
/*		    ROFF4, Version 1.60			*/
/*							*/
/*(C) 1983,4 by Ernest E. Bergmann			*/
/*		Physics, Building #16			*/
/*		Lehigh Univerisity			*/
/*		Bethlehem, Pa. 18015			*/
/*							*/
/* Permission is hereby granted for all commercial and	*/
/* non-commercial reproduction and distribution of this	*/
/* material provided this notice is included.		*/
/*							*/
/********************************************************/
/*feb 19, 1984*/
/*Jan 14, 1984*/
#include "roff4.h"

insert()	/*takes a command line in LINE and adds its
		entry to the table; no space check is made of
		TRTBL*/
{int *pw;
char *pc,*s2,*s3,*fnd;
pw=TREND;
*pw=SLINK;
pc=pw+1;
gettl3(LINE,pc,&s2,&s3);
if(fnd=find2(pc,SLINK))
	{fprintf(STDERR,"%cWarning: <%s> was defined to be <%s>\n",BELL,pc,fnd);
	fprintf(STDERR,"...now it is defined to be <%s>\n",s2);
	}
SLINK=TREND;
TREND=s3;
}
/****************************************/
showit()	/* displays the list of entries in the string
		substitution table pointed to by HEAD. */
{int *pw;
char *pc;
fprintf(STDERR,"ENTRIES:\n");
pw=SLINK;
while(pw)
	{fprintf(STDERR,"%u: ",pw);
	pc=pw+1;
	fprintf(STDERR,"<%s>",pc);
	pc += strlen(pc); pc++;
	if(*pc) fprintf(STDERR," <%s>\n",pc);
	else fprintf(STDERR," <>\n"); /*'C' bug*/
	pw=*pw;
	}
dashes();
}
/****************************************/
putback(c)	/*cf K & P, p256*/
char c;
{if(++BINP >= BACKSIZE)
	{printf(STDERR,"Too many characters pushed back\n");
	exit();
	}
BACKBUF[BINP]=c;
}
/****************************************/
int ngetc(iobuf)	/*cf K & P p256*/
struct _buf *iobuf;	/*filters \r followed by \n,msb*/
{char c,kgetc();
if(BINP) c=BACKBUF[BINP];
else	{if(KEYBD) c=kgetc();
	else c=0x7f&getc(iobuf);
	BACKBUF[BINP=1]=c;
	}
if((c!=CPMEOF)&&c!=EOF) BINP--;
if(c=='\r')
	{c=ngetc(iobuf);
	if(c!='\n')
		{putback(c);
		return('\r');
		}
	}
return(c);
}
/****************************************/
char kgetc()	/*like getc(),from keyboard, line-buffered*/
{int i;
if(!*KPTR)
	{fprintf(STDERR,"%c",KEYBD);
	gets(KLINE);
	i=strlen(KLINE);
	KLINE[i++]='\n';
	KLINE[i]='\0';
	KPTR=KLINE;
	}
return(*(KPTR++));
}
/****************************************/
pbstr(s)	/*put back string on input;cf K&P,p257*/
char s[LSZ];
{int i;
for(i=strlen(s);i>0;) putback(s[--i]);
}
/****************************************/
minsert()	/*takes a .DM and following lines and places
		the information in the table;  no macro
		definition nesting permitted*/
{char c, *pc,*pc2;
int *pw1;
/*pass over command and following white space*/
for(pc=LINE,c=*pc; (c!=' ')&&(c!='\n')&&(c!='\t'); pc++)
	c=*pc;
for(; (c==' ')||(c=='\t'); pc++) c=*pc;
start();
if(c=='\n') {fprintf(STDERR,".DM is UNnamed\n"); }
else	{pw1=TREND;
	*(pw1++)=MLINK;
	MLINK=TREND;
	TREND=pw1;
	while(class(c)==BLACK)
		{*(TREND++)=c;
		c=*(pc++);
		}
	}
*(TREND++)='\0';
while(fgets2(LINE,IOBUF))	/*until EOF or CPMEOF*/
	{pw1=LINE;
	if((*LINE==COMMAND)&&(comtyp(LINE)==EM)) break;
	else	{transfer(&pw1,&TREND,0);
		*(TREND-1)='\n';
		}
	}
*(TREND++)='\0';
complete();
}
/****************************************/
showm()	/*lists macro definitions*/
{int *pw;
char *pc;
fprintf(STDERR,"MACROS DEFINED:\n");
pw=MLINK;
while(pw)
	{pc = pw+1;
	fprintf(STDERR,"%u  .%s\n",pw,pc);
	pc +=strlen(pc); pc++;
	fprintf(STDERR,"%s\n",pc);
	pw=*pw;
	}
dashes();
}
/****************************************/
char *macq(line)	/*looks up name to see if it is a macro
			definition.  If it is, returns the
			corresponding string, else returns
			FALSE.
			*/
char *line;
{char c,*pc,wb[LSZ],*find2();
pc=wb;
while(class(c=*(++line))==BLACK) *(pc++)=c;
*pc='\0';
return(find2(wb,MLINK));
}
/****************************************/
char *find2(s,link)	/*finds or doesn't find s in table
			of substitutions pointed to by link*/
char *s;
int *link;
{char *pc;
while(link)
	{if(!strcmp(s,link+1))
		{pc=link+1;
		pc += strlen(pc);
		pc++;
		return(pc);
		}
	link=*link;
	}
return(FALSE);
}
/****************************************/
/*from ndio.c*/
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
	}
}

/*
	This version of "putchar" replaces the regular version when using
	directed I/O:
*/

putchar(c)
char c;
{	if (SUPPRESS) return;
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

	_doflag = FALSE;  /* No directed /O by default   */
	_nullpos = &argv[argc];
	argcount = 1;

	for (i = 1; i < argc; i++)	/* Scan the command line for > and )*/
	{
		n=0;	/* start with first character */
getmore:	switch(argv[i][n++]) {

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
			
	     foo:   case '>':/*Check for directed output*/
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

	     movargv:	argc = argcount;
			argv[argc] = 0;
			break;

		    default:	/* handle normal arguments: */
				if (n!=1) goto movargv;
			argcount++;
		}
	}
}


#undef argc
rgcount = 1;

	for (i = 1; i < argc; i++)	/* Scan the command line for > and )*/
	{
		n=0;	/* start with fi