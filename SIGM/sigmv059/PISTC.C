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

/* third module, February, 1982 */

#include "bdscio.h"
#include "pistol.h"

char *slit() /* emplaces string lit.,returns ^ to its start */
{char i,*start; /*Feb 13: elim. Pc2,len*/
	Pc=start=ram[-4].pc; Pc++;
	*start=*ram[-4].pc -1;
	Pc++; ram[-4].pc++;
	for(i=*start; i ; Pc++,ram[-4].pc++,i--)
		*ram[-4].pc=*Pc ;
	return(start);
}

char *longstring() /* Feb 13 eliminate Pc */
{char len,*start;
	if(*ram[-18].pc != '"') abort();
	Pc2=start=ram[-4].pc; Pc2++;
	len=0;
	ram[-15].pc=ram[-18].pc+1;
	while(*ram[-15].pc != NEWLINE && *ram[-15].pc != '"')
		{len++; *Pc2=*ram[-15].pc; Pc2++; nextch(); }
	nextch();
	*start=len;
	ram[-4].pc=Pc2;
	return(start);
}

int digit(d)
char d;
{if(d<='9') return(d-'0');
if(d<'A') return(-1);
if(d<='Z') return(10-'A'+d);
return(-1);
}

char convert(ptkn,base,Pval)
char *ptkn,base;
int *Pval;
{char *tend;
 int val,d;
	val=0; ram[-10].in=1; tend=*ptkn + ptkn +1;
	ptkn++ ;
	if(*ptkn=='+') ptkn++;
	else if(*ptkn=='-'){ptkn++; ram[-10].in=-1;}
	d=digit(*ptkn);
	while((d>-1)&&(ptkn<tend)&&(d<base))
	{	val=base*val+d;
		ptkn++;d=digit(*ptkn);
	}
	*Pval=ram[-10].in*val;
	if(ptkn==tend) return(TRU);
	else return(FALS);
}

compline() /* Feb 13 remove Pc */
{int *pad;
if((!ram[-11].in)||ram[-13].in) prompt();
if(ram[-11].in&&(ram[-11].in<MAXLINNO))
	{push(ram[-11].in);interpret(ram[-28].in);
	ram[-11].in++;
	}
else getline();
ignrblnks();
while(*ram[-15].pc != NEWLINE)
	{ram[-18].pc=ram[-15].pc;
intoken();
pad=find(ram[-4].in);
	if(pad) interpret(pad-1);
	else	{if(convert(ram[-4].in,ram[-1].in,&val))
			{compile(LIT);compile(val);}
		else	{if(Pc=ram[-4].pc+1,*Pc=='\'')
				{pad=slit();compile(STRLIT);
				compile(pad);}
			else if(*Pc=='"')
				{pad=longstring();
				compile(STRLIT);compile(pad);}
			else if(ram[-51].in)
				interpret(ram[51].in);
			else{/*token couldn't be deciphered*/
				ram[-14].in=TRU;
				if(ram[-11].in&&(!ram[-13].in))
				{if(ram[-24].in) carret();
				 message(&strings[LINEBUF]);
				}
				message(ram[-4].in);
				printf(" ?\n");
				if(ram[-12].in)fprintf(" ?\n",
						list);
				abort();
			    }
			}
		}
	ignrblnks();
	}
}

TRU);
	else return(FALS);
}

compline() /* Feb 13 remove Pc */
{int *