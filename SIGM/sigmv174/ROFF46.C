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
/*Jan 14, 1984*/

#include "roff4.h"
/**************************************************/
int value(base,string)	/*unsigned conversion*/
int base;		/*radix for conversion*/
char *string;		/*no leading blanks please!*/
			/*trailing whitespace or '\0'*/
{int val,d;
char c;
	val=0;
	for(d=digit(*string);d>=0 && d<base ; d=digit(*string))
		{val = val*base + d;
		string++;
		}
	c=*string;
	if(!c || c==' ' || c==TAB || c=='\n') return(val);
	else return(-1);	/*error return is -1*/
}
/**************************************************/
int digit(d)
char d;
{	d=toupper(d);
	if(d<='9') return(d-'0');
	if(d<'A') return(-1); /*error return is negative val*/
	if(d<='Z') return(10-'A'+d);
	return(-1);	/*error*/
}
/**************************************************/
strln3(s,word,num)
 /*returns printed string length; checks legality of
		word function;keeps track of vertical
		excursions; records them in globals*/
char *s;
int word;	/* boolean, if true, check is made for none
		black characters in the string*/
int num;	/* for expansion of NUMSIGN;set 1 to ignore*/
{int i,i2,p1,p2,p3;
int t,b,h;	/*vertical vars*/
char c, *ss;
ss=s;
t=b=h=0;
p3=p2=p1=-LSZ;
for(c=*s,i2=i=0;c;c=*(++s))
	{if(c==NUMSIGN)
		{i++;
		if(num>9) i++;
		if(num>99) i++;
		if(num>999) i++;
		}
	else if((c!=TCVAL)&&(c!=CFVAL))
		{if((c<=' ')&&(word)) goto error;
		else i++;
		}
	else if(c==CFVAL)
		{c=*(++s);
		if(c==TCVAL) goto error;/*both CFVAL,TCVAL*/
		switch(c)
		{case 'h':
		case 'H':if(i>i2) i2=i;
			 if(i) i--;
			else goto error;/*before start*/
			break;
		case '+': h--; if(h<t) t=h; break;
		case '-': h++; if(h>b) b=h; break;
		case 'B':
		case 'b':
		case 'D':
		case 'd':
		case 'u':
		case 'U':
		case 'X':
		case 'x': break;
		case '(': p1=i; break;
		case '[': p2=i; break;
		case '{': p3=i; break;
		case ')': if(i>i2) i2=i; i=p1; break;
		case ']': if(i>i2) i2=i; i=p2; break;
		case '}': if(i>i2) i2=i; i=p3; break;
		default: if(CPTR[c-' ']) break;
		goto error;	/*undecipherable*/
		}}
	else/*c==TCVAL*/
		{if(class(*(s+1))!=BLACK)
		goto error;	/*illegal translation*/
		}
	}
if(h) goto error;
if(word){WTOP=t;
	WBOT=b;
	}
else	{LTOP=t;
	LBOT=b;
	}
if(i>=i2)return(i);
/* else prints beyond last character: */
error:
	/*should be fprint -> STDERR*/
	fprintf(STDERR,"STRLN3:<%s> is illegally formed\n",
				ss);
	return(strlen(ss));
}
/* A properly formed token string has its first printable
character indicating the lefthand edge and the last printable
character at the right hand edge.  Only legal control pairs
accepted.  It must consist of printable symbols. */
/************************************
set stack like set() sets a variable
*************************************/
setS(param,val,arg_typ,defval,minval,maxval)
int param[STKSIZ+1],val,defval,minval,maxval;
char arg_typ;
{int i;
	if(val==NO_VAL)
		{for(i=0;i<STKSIZ;i++)	/*pop*/
		param[i]=param[i+1];
		param[STKSIZ]=defval;
		}
	else	{for(i=STKSIZ;i;i--)	/*push*/
		param[i]=param[i-1];
		if (arg_typ=='+') *param+=val;
		else if (arg_typ=='-') *param-=val;
		else *param=val;
		}
	*param=min(max(*param,minval),maxval);
if DEBUG fprintf(STDERR,"\n  setS: *param = %d",*param);
}
/******************************************
initialize stack type variable, st, with v
*******************************************/
initsk(st,v)
int st[STKSIZ+1],v;
{int i;
	for(i=STKSIZ+1;i;st[--i]=v);
}
/**************************************************/
gettr()	/*process .tr */
{char chr,*pchr,getcode();
char wrdbuf[MAXLINE];
	getwrd(LINE,wrdbuf);	/*remove .tr*/
	if(getwrd(LINE,wrdbuf)==WE_HAVE_A_WORD)chr=*wrdbuf;
	else return;	/*error: missing args*/

	pchr = TREND;
	if('.'==getcode())
		TPTR[chr-' ']=pchr;	/*record pointer*/
	else	{TREND=pchr;
	fprintf(STDERR,"\nError for .TR; error in line:\n%s",
		LINE);
	}
}
/**************************************************/
getpc()	/*process .pc, printer control */
{char chr,*pchr,getcode();
char wrdbuf[MAXLINE];
	getwrd(LINE,wrdbuf);	/*remove .pc*/
	if(getwrd(LINE,wrdbuf)==WE_HAVE_A_WORD)chr=*wrdbuf;
	else return;	/*error: missing args*/

	pchr = TREND;
	if('.'==getcode())
		CPTR[chr-' ']=pchr;	/*record pointer*/
	else	{TREND=pchr;
	fprintf(STDERR,"\nError for .PC; error in line:\n%s",
		LINE);
	}
}
/**************************************************/
/*added start() and complete() to avoid contention on TRTBL*/
char getcode()	/*LINE must contain the radix as the first
		token and it and the following lines then
		contain code values finally delimited by a
		token that starts with a '.' ; comments can
		be at the end of any of these lines, set off by
		" ;" */
{int base,code;	/*conversion radix, value*/
char *pcode,ncode;
char wrdbuf[MAXLINE];
	if(TREND>(&TRTBL[TRSIZ-128]))
		fprintf(STDERR,"\nTR table full");
	if(getwrd(LINE,wrdbuf)==WE_HAVE_A_WORD)
	   {switch(toupper(*wrdbuf))
		{case 'B': base=2;break;
		case 'O':
		case 'Q': base=8;break;
		case 'D': base=10;break;
		case 'H': base=16;break;
		default: return(FALSE);	/*error*/
		}
	if DEBUG
	fprintf(STDERR,"\nGETCODE:radix token=<%s>,base=<%d>",
					wrdbuf, base);
	   }
	else return(FALSE);	/*error: missing arg*/
start();
	pcode =TREND++;
	*pcode=ncode = 0;
	while(ncode<127)
	{while(getwrd(LINE,wrdbuf)!=WE_HAVE_A_WORD)
		fgets2(LINE,IOBUF);
	if DEBUG fprintf(STDERR,"\nGETTR: next token is <%s>",
				wrdbuf);
	 if(';'==*wrdbuf) fgets2(LINE,IOBUF);/*comment*/
	 else if('.'==*wrdbuf)
		{*pcode = ncode;		/*save #*/
		complete();
		return(*wrdbuf);
		}
	 else	{
		if((code=value(base,wrdbuf)) > -1)
			{*(TREND++) = code;
			 ncode++ ;
			}
		else {complete();
		     return(*wrdbuf);	/*conversion error*/
		     }
		}
	}
	complete();
	fprintf(STDERR,"\nGETCODE: code sequence too long");
	return(FALSE);
}
/**************************************************/
ocode()	/*process .ou*/
{char wrdbuf[MAXLINE],*pcode,*p;
	getwrd(LINE,wrdbuf);	/*remove .ou*/
	p=pcode=TREND;
	if('.'==getcode()) outstr(p);
	else fprintf(STDERR,"\nOCODE: error in:\n%s",LINE);
	TREND=pcode;
}
/**************************************************/
outstr(p)	/*print string whose bytecount is *p */
char *p;
{int i;
for(i=*(p++); i; i--) putchar(*(p++));
}
/**************************************************/
getfr()	/*process .FR ;cf. ocode() */
{char *pchr,getcode(),wrdbuf[MAXLINE];
	getwrd(LINE,wrdbuf);
	if(getwrd(LINE,wrdbuf)==WE_HAVE_A_WORD)
		FRVAL = atoi(wrdbuf);
	else return;
	FRVAL=max(1,FRVAL); FRVAL=min(FRVAL,4);
	pchr=TREND;
	if('.'==getcode()) FRSTRING=pchr;
	else	{TREND = pchr;
		fprintf(STDERR,"\nError for .FR in:\n%s\n",
			LINE);
		}
}
/**************************************************/
getwh()	/*process .WH ;cf. gettr() */
{char *pcode, getcode(), wrdbuf[MAXLINE];
	getwrd(LINE,wrdbuf);
	pcode = TREND;
	if('.'==getcode()) WHSTRING=pcode;
	else	{TREND = pcode;
		fprintf(STDERR,"\nError for .WH in:\n%s\n",
			LINE);
		}
}
*remove .ou*/
	p=pcode=TREND;
	if('.'==getcode()) outstr(p);
	else fprintf(STDERR,"\nOCO