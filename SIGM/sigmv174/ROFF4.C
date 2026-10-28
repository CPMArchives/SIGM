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
#include "roff4.h"
/*****************MAIN************MAIN*********/
main(argc, argv)
int argc;
char **argv;
{char option,*macq(),*pc;
char filename[20];
struct divfd *pd;
dioinit (&argc, argv);	/* directed I/O */
fprintf(STDERR,"ROFF4, version 1.60, Mar 10, 1984\n");
fprintf(STDERR,"        (c) 1983,4 by\n");
fprintf(STDERR,"E. E. Bergmann, Physics,Bldg. #16\n");
fprintf(STDERR,"Lehigh University, Bethlehem PA 18015\n");
debug = FALSE;
if(FALSE) putchar('\n');/*for linkage purposes only!*/
if (argc == 1)
      { fprintf(STDERR,"USAGE:  ROFF4 file1\n  more than one file OK\n");
	exit();
      }
argv++;
init_defaults();
while ( --argc > 0 )
      { strcpy (filename, *argv++);
	fprintf(STDERR,"Now processing <%s>\n",filename );
	if(filename[0]=='-')
		{option=filename[1];
		if(option=='M') showm();
		else if(option=='B') debug=TRUE;
		else if(option=='D') showd();
		else if(option=='F') putchar(FORMF);
		else if(option=='G') gloss();
		else if(option=='I') showit();
		else if(option=='R') showr();
		else if(option=='S') PAGESTOP=TRUE;
		else if(option=='O') range(&filename[2]);
		else	{KEYBD=option;
			dolns();
			fprintf(STDERR,"End of keyboard input <%c>\n",
				KEYBD);
			KEYBD=FALSE;
			}
		continue;
		}
	if(pd=find2(filename,DLINK)) dclose(pd);
	if (ERROR == fopen( filename,IOBUF))
		{fprintf(STDERR,"can't open <%s>\n",filename );
		continue;
		}
	else dolns();
	if(VLINENO>0||OUTBUF[0]) space(HUGE);
	fprintf(STDERR,"Done processing <%s>\n", filename );
	fclose(IOBUF);
      } 	/* end while (--argc > 0 ) */
dsclose();
dioflush();
}		/* end main()	       */
/****************************************/
dolns()	/*do processing of lines*/
{char *pc;
int typ;
int e;
  BINP=0;
   while((e=fgets2(LINE,IOBUF))||FPTR) /*until EOF or CPMEOF */
      {if(e) {if(LINE[0]==COMMAND)
		{if(pc=macq(LINE)) pbstr(pc);
		else comand(LINE);
		}
	      else text(LINE);
	     }
	else endso();
      }
}
/**************************************************************
initializes the global variables governing the execution of the
 format commands.
**************************************************************/
init_defaults()
{initsk(&FILL,FI_DEF);	/* yes we want filled lines */
initsk(&LSVAL,LS_DEF);	/* line spacing = 1 */
initsk(&INVAL,IN_DEF);	/* left margin indent  0 */
initsk(&RMVAL,RM_DEF);	/* right margin = page width  */
TIVAL = TI_DEF;	/* left margin temporary indent    0 */
CEVAL = 0;	/* next n lines to be centered -  0  */
PAGESTOP = FALSE;
FFEED = FF_INI;
FIRSTPAGE=1;
LASTPAGE=30000;/*infinite*/
JUSTIFY=JU_INI;
initsk(&PLVAL,PL_DEF);
initsk(&M1VAL,M1_DEF);
initsk(&M2VAL,M2_DEF);
initsk(&M3VAL,M3_DEF);
initsk(&M4VAL,M4_DEF);
initsk(&SCVAL,SC_INI);
initsk(&OWVAL,OW_INI);
initsk(&TABSIZ,TS_DEF);
initsk(&TCVAL,TC_DEF);
initsk(&CFVAL,CF_DEF);
initsk(&ICVAL,IC_DEF);
CURPAG = 0;
NEWPAG = 1;
FRQ=FRSTRING=WHSTRING=0;
FRVAL=1;
FVLINENO=FPLINENO = PLINENO = 0;VLINENO = -1;
BOTTOM = PLVAL - M3VAL - M4VAL;
OUTW=OUTPOS=OUTTOP=OUTBOT=OLDLN=OLDBOT=OUTWRDS = 0;
OUTBUF [0] = '\0';
DIR = 0;
EH2 = EH3 = EHEAD ;
OH2 = OH3 = OHEAD ;
*EHEAD = *OHEAD = '\0' ;
EF2 = EF3 = EFOOT ;
OF2 = OF3 = OFOOT ;
*EFOOT = *OFOOT = '\0' ;
setmem(CPTR,2*(128-' '),0);
setmem(TPTR,2*(128-' '),0);
TREND = TRTBL;
OUTBUF2[0]=BPOS=0;
initxu();
MCNT=1;
UF=XF=FALSE;
setmem(&DBUF,LSZ,FALSE);
DPOS=-1;
FPTR=DLINK=RLINK=SLINK=MLINK=0;
KPTR=KLINE;
*KLINE=0;
KEYBD=FALSE;
rsvstk(2000);
_allocp = NULL; /*needed for alloc() and free()*/
IOBUF = alloc(BUFSIZ);
complete();
}
/****************************************/

/*	July 1: \#\ replaced by current page number.
	June 8: concatenate lines with trailing '\'
	June 1, 1983 modified for macro string processing.
	fgets2:	(May 2, 1983 by EEB fix to reset parity)
	This next function is like "gets", except that
	a) the line is taken from a buffered input file instead
	of from the console, and b) the newline is INCLUDED in
	the string and followed by a null byte. 
	
	This one is a little tricky due to the CP/M convention
	of having a carriage-return AND a linefeed character
	at the end of every text line. In order to make text
	easier to deal with from C programs, ngetc()
	automatically strips off the CR from any CR-LF
	combinations that come in from the file. Any CR
	characters not immediately followed by LF are left
	intact. The LF is included as part of the string, and
	is followed by a null byte. (Note that LF equals
	"newline".) There is no limit to how long a line
	can be here; care should be taken to make sure the
	string pointer passed to fgets points to an area
	large enough to accept any possible line length
	(a line must be terminated by a newline (LF, or '\n')
	character before it is considered complete.)  The
	ngetc() also resets the parity bit.

	The value NULL (defined to be 0 here) is returned
	on EOF, whether it be a physical EOF (attempting to
	read past last sector of the file) OR a logical EOF
	(encountered a control-Z.) The 1.3 version didn't
	recognize logical EOFs, because I did't realize how
	SIMPLE it was to implement a buffered I/O "ungetc"
	function.
*/

char *fgets2(s,iobuf)
char *s;
struct _buf *iobuf;
{
	int count,c,i,*pw,pnum;
	char *cptr,*pc;
	char wbuf[LSZ],*fnd;
	count = MAXLINE;
	cptr = s;
	if ( (c=ngetc(iobuf))==CPMEOF || c==EOF)
		return NULL;

	do {	if(c==ICVAL)/*need macro substitution*/
		  {for(i=0;ICVAL!=(wbuf[i]=ngetc(iobuf));i++)
			{if(wbuf[i]=='\n')
				{if(i) putback('\n');
				break;
				}
			}
		  if(i) 
		   {wbuf[i]='\0';
		    if((*wbuf==NUMSIGN)&&(i==1))
			{if((VLINENO>=PLVAL)
				||(VLINENO<0)) pnum=NEWPAG;
			else pnum=CURPAG;
			itoc(pnum,wbuf,10);
			pbstr(wbuf);
			}
		    else if(pw=find2(wbuf,RLINK))
			{itoc(*pw,wbuf,10);
			pbstr(wbuf);
			}
		    else if(fnd=find2(wbuf,SLINK)) pbstr(fnd);
		    else{start();
		    	pc=wbuf;
			pw=TREND;
			*(pw++)=SLINK;
			transfer(&pc,&pw,'\0');
			fprintf(STDERR,"%cPlease define <%s>:",
						BELL,wbuf);
			gets(wbuf);
			pc=wbuf;
			transfer(&pc,&pw,'\0');
			SLINK=TREND;
			TREND=pw;
			complete();
			pbstr(wbuf);
			}
		    continue;
		    }
		   else if(*wbuf!='\n') putback(ICVAL); 
		   c=ngetc(iobuf);
		  }
		if ((*cptr++ = c) == '\n') break;

	 } while (count--&&(c=ngetc(iobuf))!=EOF&&c!=CPMEOF);

	if(c==CPMEOF)putback(c);	/*push back control-Z*/
	*cptr = '\0';
	return s;
}
/**************************************************************
performs the formatting command returned by comtyp -sets global
  variables ( indenting, underlining, etc. )
**************************************************************/
comand ( line )
char *line;
{int c_type;	/* command type  */
int arg_val;	/* argument value, if any */
char arg_typ;	/* relative (+ or -) or absolute */
char wbuf[20];
int i;
c_type = comtyp (line);
if DEBUG fprintf(STDERR,"COMAND %d,",c_type);
if (c_type == UNKNOWN)
	{fprintf(STDERR, "UNKNOWN COMMAND: <%s>\n", line);
	return;
	}
arg_val = get_val ( line, &arg_typ );
if DEBUG
fprintf(STDERR,"get_val returned arg_val=%d,arg_typ=%c\n",
				   arg_val,    arg_typ   );
switch (c_type)
	{case IG : break;/* ignore remark */

	case FI :	/* filled lines  */
		brk();
		FILL = YES;
		break;

	case NF :	/* non-filled lines */
		brk();
		FILL = NO;
		break;

	case NJ :	/* non-justified lines */
		JUSTIFY = NO;
		break;

	case JU :	/* justified lines  */
		JUSTIFY = YES;
		break;

	case BR :	/* just cause a break */
		brk();
		break;

	case LS :	/* set line spacing value */
		setS(&LSVAL, arg_val, arg_typ, LS_DEF, 1, HUGE );
		break;

	case TI :	/* set temporary left indent */
		brk();
		set ( &TIVAL, arg_val, arg_typ, TI_DEF, 0, RMVAL );
		break;

	case IN :	/* set left indent */
		setS( &INVAL, arg_val, arg_typ, IN_DEF, 0, RMVAL-1 );
		TIVAL = INVAL;
		break;

	case RM:	/* set right margin */
		setS( &RMVAL, arg_val, arg_typ, RM_DEF, TIVAL+1, OWVAL );
		break;
	case M1:	/* set topmost margin */
		setS( &M1VAL, arg_val, arg_typ, M1_DEF,0,HUGE);
		break;

	case M2:	/* set second top margin */
		setS( &M2VAL, arg_val, arg_typ, M2_DEF,0,HUGE);
		break;

	case M3:	/* set first bottom margin */
		setS( &M3VAL, arg_val, arg_typ, M3_DEF,0,HUGE);
		BOTTOM = PLVAL - M3VAL - M4VAL;
		break;

	case M4:	/* set bottom-most margin */
		setS(&M4VAL, arg_val, arg_typ, M4_DEF,0,HUGE);
		BOTTOM = PLVAL - M3VAL - M4VAL;
		break;

	case CE :	/* center next arg_val lines */
		brk();
		set ( &CEVAL, arg_val, arg_typ,CE_DEF,0, HUGE);
		break;

	case HE :	/* get header title for pages */
		gettl3 ( line, EHEAD, &EH2, &EH3 );
		gettl3 ( line, OHEAD, &OH2, &OH3 );
		break;

	case OH :	/*get odd header title*/
		gettl3 ( line, OHEAD, &OH2, &OH3 );
		break;

	case EH :	/*get even header title*/
		gettl3 ( line, EHEAD, &EH2, &EH3 );
		break;

	case FO :	/* get footer title for pages */
		gettl3 ( line, EFOOT, &EF2, &EF3 );
		gettl3 ( line, OFOOT, &OF2, &OF3 );
		break;

	case OF :	/* get odd page footer title*/
		gettl3 ( line, OFOOT, &OF2, &OF3 );
		break;

	case EF :	/* get even page footer title*/
		gettl3 ( line, EFOOT, &EF2, &EF3 );
		break;

	case SP :	/* space down arg_val blank lines */
		set (&SPVAL, arg_val, arg_typ, 1, 0, HUGE);
		space ( SPVAL );
		break;

	case ST :	/* stop(pause) at each page?*/
		set(&PAGESTOP,arg_val,'0',YES,NO,YES);
		break;
	case BP :	/* set pageno arg_val - begin page */
		brk();
		if(((VLINENO<=0)||(VLINENO>=BOTTOM))&&
			(arg_val==NO_VAL)) break;
		if ( VLINENO > 0 )	space (HUGE);
		set(&CURPAG,arg_val,arg_typ,CURPAG+1,0,9999);
		NEWPAG = CURPAG;
		break;
	case NE :	/*"need"*/
		if (arg_val==NO_VAL) arg_val=2;/*default*/
		need(arg_val);
		break;

	case PL :	/* set page length */
		setS(&PLVAL, arg_val, arg_typ, PL_DEF,
		  M1VAL+M2VAL+M3VAL+M4VAL+1,HUGE);
		BOTTOM = PLVAL - M3VAL - M4VAL;
		break;

	case FF :	/*formfeed*/
		set(&FFEED,arg_val,'0',FF_DEF,NO,YES);
		break;

	case SC :	/*space character*/
		if(arg_typ) arg_val=arg_typ;
		setS(&SCVAL,arg_val,'0',SC_INI,BLANK,127);
		break;

	case OW :	/*output device width*/
		setS(&OWVAL,arg_val,'0',OW_INI,RMVAL,HUGE);
		break;
	case TS :	/*tabsize*/
		setS(&TABSIZ,arg_val,'0',TS_DEF,1,HUGE);
		break;

	case AB :	/*abort*/
		fprintf(STDERR,"\n***USER ABORT***\n");
		exit();

	case DB :	/*debug*/
		setS(&debug,arg_val,'0',NO,NO,YES);
		if DEBUG fprintf(STDERR,"\nDEBUG ON...\n");
		else fprintf(STDERR,"\n...END OF DEBUG\n");
		break;

	case TC :	/*translate character flag*/
		if(arg_typ) arg_val=arg_typ;
		setS(&TCVAL,arg_val,'0',TC_DEF,BLANK+1,127);
		break;

	case CF :	/*translate character flag*/
		if(arg_typ) arg_val=arg_typ;
		setS(&CFVAL,arg_val,'0',CF_DEF,BLANK+1,127);
		break;

	case IC :	/*insert character for macro replace*/
		if(arg_typ) arg_val=arg_typ;
		setS(&ICVAL,arg_val,'0',IC_DEF,BLANK+1,127);
		break;

	case TR :	/*translation string defined here*/
		gettr(); break;

	case OU :	/*output code string*/
		ocode(); break;

	case FR :	/*define fractional spacing code*/
		getfr(); break;

	case WH :	/*define whole line spacing code*/
		getwh(); break;

	case DS :	/*define string*/
		insert(); break;

	case DM :	/*define macro*/
		minsert(); break;

	case RG :	/*register variable*/
		dovar(); break;

	case DI :	/*diversion to file*/
		dodiv(); break;

	case SO :	/*source from file*/
		source(); break;

	case PC :	/*printer control*/
		getpc(); break;

	case SA :	/*"say" to console*/
		getwrd(LINE,wbuf);	/*skip command*/
		skip_blanks(LINE);
		trunc_bl(LINE);
		fprintf(STDERR,"<%s>\n",LINE);
		break;

	case BJ :	/*break with right justification*/
		if(FILL)/*not applicable otherwise*/
		{spread(OUTBUF,
			min(RMVAL-TIVAL,MAXLINE-1)-OUTW+1,
			OUTWRDS);
		brk();
		}
		break;
      }
}

start()/*to insure only one entry into TRTBL at a time*/
{if(TFLAG)
	{fprintf(STDERR,"ILLEGAL double access of TRTBL\n");
	fprintf(STDERR,"Simultaneous creation of two definitions not possible");
	exit();
	}
else	TFLAG=TRUE;
}

complete()/*to insure only one entry into TRTBL at a time*/
{TFLAG=FALSE;
}

range(s)
char *s;
{int num;
num=0;
while(isdigit(*s)) num=num*10+(*(s++)-'0');
if(num) FIRSTPAGE=num;
if(*s=='-')
	{s++; num=0;
	while(isdigit(*s)) num=num*10+(*(s++)-'0');
	if(num) LASTPAGE=num;
	}
else	LASTPAGE=FIRSTPAGE;
}

	case SO :	/*source from file*/
		source(); break;

	case PC :	/*printer control*/
		getpc(); break;

	case SA :