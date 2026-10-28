/*********************************************************/
/*							 */
/* PISTOL-Portably Implemented Stack Oriented Language	 */
/*			Version 1.3			 */
/* (C) 1982 by	Ernest E. Bergmann			 */
/*		Physics, Building #16			 */
/*		Lehigh Univerisity			 */
/*		Bethlehem, Pa. 18015			 */
/*							 */
/* Permission is hereby granted for all reproduction and */
/* distribution of this material provided this notice is */
/* is included.						 */
/*							 */
/*********************************************************/

/* fifth module, February, 1982 */

#include "bdscio.h"
#include "pistol.h"

int *find(ptoken) /*returns address of dict'ary word or FALS*/
int *ptoken; /* string to be looked up;"int" more efficient*/
{int *loc,*v;
	for(loc=FALS,v=ram[-32].pw;(v>&ram[VBASE-1])
					&& !loc ;v--)
		loc=vfind(ptoken,v);
	return(loc);
}

int *vfind(ptoken,v)
int *ptoken,*v;
{/*vloc &vmatch are at end of pist.h*/
	vloc=*v; vloc=*vloc;
	if(vloc) do
	{vmatch=FALS;
	if(Pw=*(vloc-2),*Pw==*ptoken)
		vmatch=pstrcmp(ptoken);
	if(!vmatch)
		vloc=*(vloc-3);
	}
	while(vloc && !vmatch);
	return(vloc);
}

char pstrcmp(str2) /* returns FALS if not a PISTOL string
				match*/
char *str2;
{/*char pcount,*Pc3; is at end of pist.h*/
	Pc3=Pw;
	pcount=*Pc3; Pc3++ ; str2 ++ ;
	for(; pcount ; --pcount,++Pc3,++str2)
		if(*Pc3 != *str2) break;
	return( !pcount );
}

intoken() /* Feb 13 remove need for ptr,partly ptr2 */
{char count,*ptr2;
	ptr2=ram[-4].pc;
	for(count=0;!white(*ram[-15].pc);nextch())
	{	count++ ; ptr2++ ;
		if(ram[-17].in) *ptr2=toupper(*ram[-15].pc) ;
		else *ptr2 =*ram[-15].pc ;
	}
	*ram[-4].pc=count ;
}

nextch() /* Feb 13 removed Pc crutch */
{if (*ram[-15].pc != NEWLINE) ram[-15].pc++ ; }

ignrblnks() /* Feb 13 removed Pc crutch */
{	while((*ram[-15].pc==9)
		||(*ram[-15].pc==32)) ram[-15].pc++ ;
}

prompt()
{if(ram[-50].pw) interpret(ram[-50].pw);
else	{if(ram[-24].in) carret();
	if(ram[-14].in) putch(strings[0]);
	message(&strings[1]);
	if(ram[-14].in) puts("> ");
	if(ram[-12].in)fputs("> ",list);
	}
}

int white(c)	/* better than isspace(c) */
char c;
{	if(c==32) return(TRU);
	if(c==9)  return(TRU);
	if(c==NEWLINE)
		  return(TRU);
	return(c==0);
}

; is at end of pist.h*/
	Pc3=Pw