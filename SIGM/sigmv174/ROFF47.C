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
/*Feb 15, 1984*/
/*January 9, 1984*/
#include "roff4.h"
/*assuming REVSCROLL is FALSE*/
/*output OUTBUF2 whith the vertical height of the mainline
specified by VLINENO,FVLINENO[they must not be changed here].
Excessive superscripting will be pushed down.*/

printout()
{int level,top,bot;	/*"up" is negative;units fractional*/
int lsave,fsave;

OUTBUF2[BPOS]='\0';
fsave=FVLINENO;
lsave=VLINENO;
level=FRVAL*(PLINENO-VLINENO)+FPLINENO-FVLINENO;
if(!OLDBOT) level++;
excurs(&OUTBUF2[0],&top,&bot);
if(top>level) level=top;

if(!REVSCROLL) FVLINENO += level;
padv();
for(;level<=bot;level++)
	{OCNT=0;
	do {OCNT++; flp(level,FALSE); }
	while(retype());
	if(level<bot)
		{fraction();
		putchar('\n');
		FPLINENO++;
		}
	}
flp(level,TRUE);	/*update UF, XF, MCNT*/
OUTBUF2[0]=BPOS=0;
OLDLN=VLINENO=lsave;
OLDBOT=bot;
FVLINENO=fsave;
}
/****************************************/
/*moves printer vertically so that its position is specified
by VLINENO,FVLINENO*/
padv()
{int w,f;	/*whole,fractional lines*/
w=VLINENO-PLINENO;
f=FVLINENO-FPLINENO;
while(f<0) {w--; f += FRVAL; }
while(f>=FRVAL)	{w++; f -= FRVAL; }
if(w<0){fprintf(STDERR,"padv():VL=%d,PL=%d\n",
			VLINENO,PLINENO);
	if(REVSCROLL) backup(w*FRVAL+f);
	else {VLINENO +=w;
	      FVLINENO +=f;
	      while(FVLINENO<0){VLINENO++;FVLINENO+=FRVAL;}
	      while(FVLINENO<FRVAL){VLINENO--;FVLINENO-=FRVAL;}
	      return;
	     }
	}
if(FRQ)	{while(f--){putchar('\n'); FPLINENO++; }
	if(w){whole();while(w--){putchar('\n');PLINENO++;}}
	}
else	{while(w--){putchar('\n'); PLINENO++; }
	if(f){fraction();while(f--){putchar('\n');FPLINENO++;}}
	}
while(FPLINENO>=FRVAL) {PLINENO++; FPLINENO -= FRVAL; }
}
/****************************************/
backup(i)	/*not yet implemented*/
int i;		/*# of fractional lines(probably negative)*/
{fprintf(STDERR,"\nCan't back up yet\n");
}
/**************************************************/
excurs(str,t,b) /*finds the topmost and bottommost line
		positions of str*/
char *str;
int *t,*b;
{int l;
char c;
*t=*b=l=0; /*current line position */
c=*str;
while(c){if(c==CFVAL){if(c=*(++str))
			switch(c)
			{case '+':l--; if(l<*t) *t=l;
				c=*(++str); break;
			case '-':l++; if(l>*b) *b=l;
				c=*(++str); break;
			default : c=*(++str); break;
			}
		    }
	else c=*(++str);
	}
}

/**************************************************/
flp(level,updat)/*fancy line print at a given vertical level
		the string in OUTBUF2[] with backspacing,
		underlining, and strikout.  To permit boldface
		it modifies DBUF[],DPOS so that retype can be
		used to patch up OUTBUF2 for resubmittal to
		flp()*/
int level;	/* current vertical level to print*/
int updat;	/* boolean for update of UF,XF,MCNT*/
{int i;
	BLKCNT=lbc(level,OUTBUF2);
	FIRST=TRUE;
	while((BLKCNT>0)||updat)
		{prpass(level,updat); putchar('\r');
		updat=FIRST=FALSE;
		}
	if(XCOL>-1){for(i=0;i<=XCOL;i++)
			putchar(XBUF[i]);
			putchar('\r');
		   }
	if(UCOL>-1){for(i=0;i<=UCOL;i++)
			putchar(UBUF[i]);
			putchar('\r');
		   }
	if((UCOL>-1)||(XCOL>-1)) initxu();
}

/**************************************************/
retype()	/*restores characters into OUTBUF2 from DBUF
		that need to be overstruck again*/
{int i;
if(DPOS==-1) return(FALSE);
else	{for(i=0;i<=DPOS;i++)
		{if(DBUF[i])
			{OUTBUF2[i]=DBUF[i];
			DBUF[i]=FALSE;
			}
		}
	DPOS=-1;
	return(TRUE);
	}
}

/**************************************************/
int lbc(lev,str) /*counts printable chars in line level and
		above; parity must be reset*/
int lev; /*=0 main line,=-1 superscripts,=+1 subscripts, etc.*/
char *str;
{char c,n;
int l;
l=n=0;
c=*str;
while(c){if(c==CFVAL){if(c=*(++str))
			switch(c)
			{case '+':l--;c=*(++str);break;
			case '-':l++;c=*(++str);break;
			default: c=*(++str);break;
		    }	}
	else	{if((c>' ')&&(l<=lev)) if(c!=TCVAL) n++;
		c=*(++str);
		}
	}
return(n);
}

/**************************************************/
prpass(lev,updat) /*printer pass initial cr; no lf anywhere*/
int lev; /*=0 main line,=-1 superscripts,=+1 subscripts, etc.*/
int updat;/*boolean to update UF,XF,MCNT*/
{char ch;
int l;
int xfs,ufs,mcnts;	/*save variables*/
int p1,p2,p3;		/*position holders*/
int cp2;	/*for tabulation calculation*/
xfs=XF; ufs=UF; mcnts=MCNT;
p1=p2=p3=l=BPOS=CP=PP=0;
while(ch=OUTBUF2[BPOS])
	{switch (class(ch))
	{case	BLACK:/*print it if posssible*/
		if((PP>CP)||(l>lev)){CP++;BPOS++;break;}
		else	{while(CP>PP){putchar(' ');PP++;}
			if(ch==SCVAL)putchar(' ');
			else putchar(ch);PP++;
			if(MCNT>OCNT)
				{DBUF[BPOS]=OUTBUF2[BPOS];
				if(BPOS>DPOS) DPOS=BPOS;
				}
			OUTBUF2[BPOS++]=' ';
			if(UF&&FIRST)UBUF[UCOL=CP]=UCHAR;
			if(XF&&FIRST)XBUF[XCOL=CP]=XCHAR;
			BLKCNT--; CP++;
			} break;
	case	WHITE:/*assume blank*/ CP++;BPOS++;break;
	case	TRANSLATE:/*similar to BLACK and WHITE*/
			ch=OUTBUF2[++BPOS];
			if((PP>CP)||(l>lev)||(ch==' '))
				{CP++;BPOS++;break;}
			else
			  {while(CP>PP){putchar(' ');PP++;}
			trch(ch);PP++;
			if(MCNT>OCNT)
				{DBUF[BPOS]=OUTBUF2[BPOS];
				DBUF[BPOS-1]=OUTBUF2[BPOS-1];
				if(BPOS>DPOS) DPOS=BPOS;
				}
			OUTBUF2[BPOS++]=' ';
			if(UF&&FIRST)UBUF[UCOL=CP]=UCHAR;
			if(XF&&FIRST)XBUF[XCOL=CP]=XCHAR;
			BLKCNT--; CP++;
			} break;
	case	CONTROL:/*decode on following letter*/
			ch=OUTBUF2[++BPOS];
			if(CPTR[ch-' ']) pcont(ch);
			else switch(ch)
			{case 'h':
			case 'H':/*backspace*/
				if(CP)CP--;break;
			case '+': l--; break;
			case '-': l++; break;
			case 'U': UF=TRUE;break;
			case 'u': UF=FALSE;break;
			case 'X': XF=TRUE;break;
			case 'x': XF=FALSE;break;
			case 'B': MCNT *=3;break;
			case 'b': if(!(MCNT /=3))MCNT=1;
					break;
			case 'D': MCNT *=2;break;
			case 'd': if(!(MCNT /=2))MCNT=1;
					break;
			case '(': p1=CP;break;
			case ')': CP=p1;break;
			case '[': p2=CP;break;
			case ']': CP=p2;break;
			case '{': p3=CP;break;
			case '}': CP=p3;break;
			default:/*?,ignore*/;break;
			} BPOS++; break;
	case	SENTINEL: OUTBUF2[BPOS]=0;break;
	case	HTAB: for(cp2=0;CP>=0;cp2+=TABSIZ)CP-=TABSIZ;
			CP=cp2; BPOS++; break;
	case	OTHERS:
       fprintf(STDERR,"\nweird character value: %o\n",ch);
		BPOS++;
		break;
	}}
if(!updat){/*restore original values*/
	XF=xfs;
	UF=ufs;
	MCNT=mcnts;
	}
}
/**************************************************/
int class(c)
char c;
{if(c==TCVAL) return(TRANSLATE);
if (c==CFVAL) return(CONTROL);
if(c>' ') return(BLACK);
if(c==' ') return(WHITE);
if(c=='\n') return(SENTINEL);
if(c=='\r') return(SENTINEL);
if(c==TAB) return(HTAB);
if(!c) return(SENTINEL);
return(OTHERS);
}
/**************************************************/
fraction()	/*put printer in fractional spcing mode;
			set FRQ*/
{if(!FRQ && FRSTRING && (FRVAL!=1))
	{outstr(FRSTRING);
	FRQ = TRUE;
	}
}
/**************************************************/
whole()		/*put printer in whole line spacing;
			reset FRQ */
{if(FRQ && WHSTRING)
	{outstr(WHSTRING);
	FRQ = FALSE;
	}
}
/**************************************************/
trch(c)	/*output string translation of c*/
char c;
{char *p;
	if(c<' ') {putchar(TCVAL);putchar(c);return;}
	p = TPTR[c-' '];
	if(p) outstr(p);
	else	{/*not initialized*/
		putchar(TCVAL);
		putchar('?');
		}
}
/****************************************/
pcont(c) /*output printer control string for c*/
char c;
{char *p;
	if(c<' ') {putchar(CFVAL);putchar(c);return;}
	p = CPTR[c-' '];
	if(p) outstr(p);
	else	{/*not initialized*/
		putchar(CFVAL);
		putchar('?');
		}
}
 return(SENTINEL);
if(c==TAB) return(