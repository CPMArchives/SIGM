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
/*FEB 18, 1984*/
/*JAN 15, 1984*/
#include "roff4.h"

/**************************************************
handles case of leading blanks or tabs; empty lines 
***************************************************/
leadbl (line)
char *line;
{int i, j, white;
brk();
/* figure out white space Nov 13*/
for (white=0, i=0; line[i] == ' ' || line[i] == '\t'; i++ )
	{if(line[i]==' ') white++;
	else white=min(RMVAL,TABSIZ*(1+white/TABSIZ));
	}
if ( line[i] != NEWLINE ) TIVAL += white;
/* move line to left */
for(j=0;(line[j]=line[i])!='\0';j++,i++);
}
/*****************************************
		puts out page header
******************************************/
phead()
{exchange();
UF=XF=FALSE;
MCNT=1;
CURPAG = NEWPAG++;
if((CURPAG<FIRSTPAGE)||(CURPAG>LASTPAGE)) SUPPRESS=TRUE;
else SUPPRESS=FALSE;
OLDLN=-1;
if(PAGESTOP)
	{bdos(2,7);	/*ring bell*/
	bdos(1);	/*wait til char typed at console*/
	}
PLINENO=0;FPLINENO=0;
if (M1VAL > 0 )
      { VLINENO = M1VAL-1;
	if (CURPAG % 2) puttl3 ( OHEAD, OH2, OH3, CURPAG );
	else puttl3 ( EHEAD, EH2, EH3, CURPAG );
      }
VLINENO = M1VAL+M2VAL; FVLINENO=0;
exchange();
}
/**************************************
		puts out page footer
***************************************/
pfoot()
{exchange();
UF=XF=FALSE;
MCNT=1;
VLINENO = BOTTOM+M3VAL; FVLINENO=0;
if ( M4VAL > 0 )
      { if(CURPAG % 2)puttl3 ( OFOOT,OF2,OF3, CURPAG );
	else puttl3(EFOOT,EF2,EF3,CURPAG);
      }
VLINENO = PLVAL;FVLINENO=0;
if (FFEED) putchar(FORMF);
else padv();
whole();
OLDBOT=PLINENO=FPLINENO=0;/*printer at start of newpage*/
OLDLN=-1;
exchange();
}
/**********************************************
	space n lines or to bottom of the page
***********************************************/
space (n)
int n;
{brk();	/* flush out last unfilled line */
if (VLINENO >= BOTTOM)	return;	/* end of page */
if (VLINENO<0) phead();	/* top of page */
VLINENO += n;
if (VLINENO >= BOTTOM) pfoot(); /* print footer if bottom */
}
/*******************************************************/
text (line)
char *line;
{char wrdbuf [LSZ];
int i, j, k;
char *p1, *p2;
if DEBUG fprintf(STDERR,"\n\nTEXT:<%s>", line);
if (line[0] == BLANK || line[0]==NEWLINE || line[0] == TAB)
	leadbl (line);
if (CEVAL > 0)
      { center(line);
	put(line);
	CEVAL--;
      }
else if(line[0]==NEWLINE) space(LSVAL);
else if(!FILL) put(line);
else while (WE_HAVE_A_WORD == getwrd (line, wrdbuf))
	putwrd (wrdbuf);
}
/******************************************************
	put out a line of text with correct indentation
	underlining if specified
*******************************************************/
put (line)
char *line;
{int i,fs,minfs;
if ((VLINENO < 0)||(VLINENO >= BOTTOM)) phead();
fs=(VLINENO-OLDLN)*FRVAL;
minfs=OLDBOT-OUTTOP; if(!(OLDBOT&&OUTTOP)) minfs++;
while(fs<minfs) {fs+=FRVAL; VLINENO++;}
need(0);
putline(line);
TIVAL = INVAL;
VLINENO += LSVAL;
if (VLINENO >= BOTTOM) pfoot();
}
/***********************************************************
concatenates the word onto the end of OUTBUF for filled text
************************************************************/
putwrd (wrdbuf)	/*Nov 22: SENTENCE*/
char *wrdbuf;
{int i, j, k;
char s[MAXLINE], ch;
int line_len, new_out_width, wid;
int nextra;
skip_blanks (wrdbuf); trunc_bl (wrdbuf);
wid =1+SENTENCE+strln3(wrdbuf,TRUE,1);/*sets WTOP,WBOT*/
line_len = RMVAL - TIVAL;
new_out_width = OUTW+wid;
if (new_out_width > min (line_len, MAXLINE-1))
      { nextra = min(line_len, MAXLINE-1)-OUTW+1;
	if(OUTBUF[OUTPOS-2]==BLANK) nextra++;
	if(JUSTIFY) spread(OUTBUF,nextra,OUTWRDS);
	brk();
      }
OUTW += wid;
OUTcat(wrdbuf);
OUTSP(); if(SENTENCE) OUTSP();
OUTWRDS++;
if(WTOP<OUTTOP) OUTTOP=WTOP;
if(WBOT>OUTBOT) OUTBOT=WBOT;
}
/**********************************************************
	a new putline routine; sends line to  OUTPUT2
***********************************************************/
putline (line)
char *line;
{char c;
blanks(TIVAL);
for(;c=*line;line++) putout(c);
putout('\0');
printout();
}
/****************************************/
OUTcat(str)	/*appends string to OUTBUF*/
char *str;
{while(OUTBUF[OUTPOS]=*(str++))
	OUTPOS++;
}
/****************************************/
OUTSP()		/*appends BLANK to OUTBUF*/
{OUTBUF[OUTPOS++]=BLANK;
OUTBUF[OUTPOS]='\0';
}
/****************************************/
gloss()	/*prints on STDOUT a glossary of .tr chars*/
{int i;
char line[20],tcs;
put("GLOSSARY:");
put("USE     <GET>");
tcs=TCVAL;
TCVAL |= 128; /*set most significant bit*/
for(i=1;i<19;i++) line[i]=' ';
line[0]=tcs;
line[8]='<';
line[9]=TCVAL;
line[11]='>';
line[12]='\0';
for(i=' ';i<127;i++)
	{if(TPTR[i-' '])
		{line[1]=line[10]=i;
		put(line);
		}
	}
TCVAL=tcs;
SPACE(HUGE);
}
/***************************************/
exchange() /*maintain separate environment for headers and
		footers*/
{int i;
i=MCNT2; MCNT2=MCNT; MCNT=i;
i=XF2; XF2=XF; XF=i;
i=UF2; UF2=UF; UF=i;
}
;
{char c;
blanks(TIVAL);
for(;c=*line;line++) putout(c);
putout('\0');
printout();
}