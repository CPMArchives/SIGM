/********************************************************/
/*							*/
/*		    ROFF4, Version 1.50			*/
/*							*/
/* (C) 1983 by	Ernest E. Bergmann			*/
/*		Physics, Building #16			*/
/*		Lehigh Univerisity			*/
/*		Bethlehem, Pa. 18015			*/
/*							*/
/* Permission is hereby granted for all commercial and	*/
/* non-commercial reproduction and distribution of this	*/
/* material provided this notice is included.		*/
/*							*/
/********************************************************/
/*June 27, 1983*/
#include "roff4.h"
/****************************************/
puttl3(s1,s2,s3,pageno)
char *s1,*s2,*s3;
int pageno;		/*put out three part title, none
			containing '\n', with
			optional page numbering; aligning
			with page margins,0 & OWVAL;*/
{int size1,gap1,size2,gap2,size3,gaps,remain;
	size1 =strln3(s1,FALSE,pageno);
	OUTTOP=LTOP;OUTBOT=LBOT;
	size2 =strln3(s2,FALSE,pageno);
	if(LTOP<OUTTOP) OUTTOP=LTOP;
	size3 =strln3(s3,FALSE,pageno);
	if(LTOP<OUTTOP) OUTTOP=LTOP;
	gaps = max(0,OWVAL-size1-size2-size3);
	gap1 = gaps/2;
	gap2 = gaps-gap1;
	remain=OWVAL;
	if(size1<=remain){puttl(s1,pageno);remain-=size1;}
	if(gap1<remain){blanks(gap1);remain-=gap1;}
	if(size2<=remain){puttl(s2,pageno);remain-=size2;}
	if(gap2<remain){blanks(gap2);remain-=gap2;}
	if(size3<=remain){puttl(s3,pageno);remain-=size3;}
	printout();
	putchar('\r');
}
/****************************************/
blanks(i)
int i;	/*sends i blanks to OUTBUF2*/
{	if(i<0) return;
	for( ; i ; i--) putout( BLANK );
}
/****************************************/
gettl3(sl,ttl1,ttl2,ttl3)
char *sl,ttl1[MAXLINE],**ttl2,**ttl3;
	/* Gets from source line three part title that it
	transfers to buffer delineated by ttl1 which has
	capacity for all three strings; none of the strings
	will contain '\n' */
{char c, cc, *dp;
if DEBUG fprintf(STDERR,"\n\nGETTL3 sl =<%s>",sl);
	/*pass over command*/
	for(c=*sl;c!=' '&&c!='\n'&&c!='\t';sl++)c=*sl;
	/*advance to first non-blank or '\n' */
	for(;c==' '||c=='\t';sl++)c=*sl;
	/*advance beyond delim. if present:*/
	if(c!='\n'&&!c) sl++;
	dp=ttl1;
	transfer(&sl,&dp,c);
	*ttl2=dp;
	transfer(&sl,&dp,c);
	*ttl3=dp;
	transfer(&sl,&dp,c);
if DEBUG
   fprintf(STDERR,"\ndelim=<%c>\nT1=<%s>\nT2=<%s>\nT3=<%s>;\n",
			      c,ttl1,*ttl2,*ttl3);
}
/****************************************/
transfer(s,d,c)
char c;		/*terminal character*/
char **s;	/*source string*/
char **d;	/*destination string*/
/* Copy string from source to destination.  Original delim.
can be \0, \n, or char.  The pointer to the source is updated
to point at the \0, \n, or past char.  In destination, delim.
is always replaced by \0.  The destination pointer always
points past this \0. */
{char a;
	a=**s;
	while(a!=c && a!='\n' && a)
		{**d = a;  (*d)++;
		(*s)++;  a=**s;
		}
	**d='\0';
	(*d)++;
	if(a!='\n' && a!='\0') (*s)++;
}
/**********************************************************
		centers a line of text
**********************************************************/
center (line)
char *line;
{TIVAL = max(( RMVAL+TIVAL-strln3(line,FALSE,1))/2, 0 );
OUTTOP=LTOP;OUTBOT=LBOT;
return;
}
/************************************************************
Revised April 24,83.Transfers next word from in to out.  Scans
off leading white space from in.  If there is no word, returns
FALSE.  Otherwise, input is truncated on left of word which is
transfered to out without leading or trailling blanks.
WE_HAVE_A_WORD will be returned.  If the transfered word
terminates a sentence then SENTENCE is set to 1, otherwise it
is reset to FALSE.
**************************************************************/
int getwrd (in,  out )
char *in, *out;
{char *pin,*pout,c,cm,cp;
	skip_blanks(in);
	replace_char(in,TAB,BLANK);
	pin=in;
	pout=out;
	c=*pin;
	SENTENCE=FALSE;
	if(c==NEWLINE || c=='\0')
		{*out='\0';
		if DEBUG fprintf(STDERR,"\ngetwrd=<%s>",out);
		return(FALSE);
		}
	while(c!=BLANK && c!=NEWLINE && c)
		{*(pout++)=c;
		*pin=BLANK;
		c=*(++pin);
		}
	*pout='\0';	/*terminate out string*/
	cm=*(pout-1);
	cp=*(pin+1);
	switch (cm)
		{case ':' :
		case ';' :
		case '?' :
		case '!' :
			SENTENCE=1;
			break;
		case '.' :
			if(cp==BLANK||cp==NEWLINE||c==NEWLINE)
				SENTENCE=1;
		}
	if DEBUG fprintf("\ngetwrd=<%s>",out);
	return(WE_HAVE_A_WORD);
}
/*******************************************************
Truncates white-space characters at the end of a string.
********************************************************/
trunc_bl (string)
char *string;
{char *ptr;
int k;
k = strlen (string);
ptr = &string[ k-1 ];	/* char before terminating nul */
while (*ptr==BLANK || *ptr==TAB || *ptr==NEWLINE)	
	*ptr--  = '\0';
}
/*********************************************
	distribute words evenly across a line
**********************************************/
spread ( line, nextra, no_words)
char *line;
int nextra;	/* no. extra places left in line */
int no_words;   /* no. words in the line         */
{int i, j, nblanks, nholes;
if DEBUG fprintf(STDERR,"spread:line=<%s>,\nnextra=%d, no_words=%d\n",
                          line,      nextra,    no_words   );
if (nextra <= 0 || no_words <= 1)	return;
DIR = !(DIR);
nholes = no_words - 1;
trunc_bl (line);
i = strlen(line) - 1 ; /* last character of string */
j = min(MAXLINE-2,i+nextra);	/* last  position in output */
line[j+1] = '\0';
for ( ; i<j ; i--, j-- )
      { line[j] = line[i];
	if ( line[i] == BLANK)
	      { if (DIR == 0) nblanks=(nextra-1)/nholes+1;
		else		nblanks = nextra/nholes;
		nextra = nextra - nblanks;
		nholes = nholes - 1;
		for ( ; nblanks > 0;  nblanks-- )
			line[--j] = BLANK;
	      }
      }
}
/************************************************
place portion of title line with optional page no. in OUTBUF2
*************************************************/
puttl ( str, num )
char *str;
int num;
{int i;
char c;
for (i=0;c= *str; str++)
	{if ( c != NUMSIGN ) putout(c);
	else putnum(num);
	}
}
/*******************************************
	put out num to OUTBUF2 (conversion)
********************************************/
putnum ( num, w )
int num;
{int i, nd;
char chars[10];
nd = itoc ( num, chars, 10 );
for ( i=0;i<nd; i++) putout(chars[i]);
}
/************************************************
	convert int num to char string in numstr
*************************************************/
itoc ( num, numstr, size )
int num;
char *numstr;
int size;	/* largest size of numstr */
{int absnum, i, j, k, d;
absnum = abs (num);
numstr[0] = '\0';
i = 0;
do      { i++;
	d = absnum % 10;
	numstr[i] = d + '0';
	absnum = absnum/10;
	}
while ( absnum != 0 && i<size );
if ( num < 0 && i<size )
      { i++;
	numstr[i] = '-';
      }
for( j=0; j<i; j++ )
      { k = numstr[i];
	numstr[i] = numstr[j];
	numstr[j] = k;
	i--;
      }
return ( strlen(numstr) );
}
/****************************************/
putout(c)	/*places c in OUTBUF2[]*/
char c;
{if(c==SCVAL) c= BLANK;
if(c==NEWLINE)c='\0';
OUTBUF2[BPOS++]=c;
OUTBUF2[BPOS]='\0';/*safty net*/
}
/************************************
	replace c1 in string with c2
*************************************/
replace_char (string, c1, c2)
char *string, c1, c2;
{int i;
for (i=0; string[i]; i++)
	if (string[i] == c1)	string[i] = c2;
}
*
	convert 