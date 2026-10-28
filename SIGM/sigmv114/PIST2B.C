/*********************************************************/
/*							 */
/* PISTOL-Portably Implemented Stack Oriented Language	 */
/*			Version 2.0			 */
/* (C) 1983 by	Ernest E. Bergmann			 */
/*		Physics, Building #16			 */
/*		Lehigh Univerisity			 */
/*		Bethlehem, Pa. 18015			 */
/*							 */
/* Permission is hereby granted for all reproduction and */
/* distribution of this material provided this notice is */
/* included.						 */
/*							 */
/*********************************************************/
/* third code module for PISTOL v2.0 in BDS 'C' v1.45a */
/* August 28, 1982 */
#include "bdscio.h"
#include "pistol.h"

move()
{/* static char *as,*ad,*endaddr;int nowd; */
	nowd=pop();
	ad=pop();
	as=pop();
	endaddr=as+nowd;
	if((as<&ram[RAMMIN])||(endaddr>&ram[RAMSIZE]))
		merr(readv);
	if((ad<&ram[0])||((ad+nowd)>&ram[RAMSIZE]))
		merr(writv);
	for(;as<=endaddr;++ad,++as) *ad=*as;
}


char *slit() /* emplaces string lit.,returns ^ to its start */
{/* shared with longstring() static char ic,*sstart; */
	Pc=sstart=ram[3].pc; Pc++;
	*sstart=*ram[3].pc -1;
	Pc++; ram[3].pc++;
	for(ic=*sstart; ic ; Pc++,ram[3].pc++,ic--)
		*ram[3].pc=*Pc ;
	return(sstart);
}

swap()
{/* static int hold; */
	hold=stack[stkptr];
	stack[stkptr]=stack[stkptr-1];
	stack[stkptr-1]=hold;
}


nextch()
{if (*ram[11].pc != NEWLINE) ram[11].pc++ ; }


prompt()
{if(ram[32].pw) {instr=ram[32].un;interpret();}
else	{if(ram[20].in) carret();
	chout(strings[0]);
	message(&strings[1]);
	chout('>');
	}
}


ignrblnks()
{	while((*ram[11].pc==9)
		||(*ram[11].pc==32)) ram[11].pc++ ;
}

char *longstring()
{/*shared with slit() static char ic,*sstart; */
	if(*ram[14].pc != '"') abort();
	Pc2=sstart=ram[3].pc; Pc2++;
	ic=0;
	ram[11].pc=ram[14].pc+1;
	while(*ram[11].pc != NEWLINE && *ram[11].pc != '"')
		{ic++; *Pc2=*ram[11].pc; Pc2++; nextch(); }
	nextch();
	*sstart=ic;
	ram[3].pc=Pc2;
	return(sstart);
}


intoken()
{/* static char count,*ptr2; */
	ptr2=ram[3].pc;
	for(count=0;!white(*ram[11].pc);nextch())
	{	count++ ; ptr2++ ;
		if(ram[13].in) *ptr2=toupper(*ram[11].pc) ;
		else *ptr2 =*ram[11].pc ;
	}
	*ram[3].pc=count ;
}

int white(c)	/* better than isspace(c) */
char c;
{	if(c==32) return(TRU);
	if(c==9)  return(TRU);
	if(c==NEWLINE)
		  return(TRU);
	return(c==0);
}

int digit(d)
char d;
{if(d<='9') return(d-'0');
if(d<'A') return(-1);
if(d<='Z') return(10-'A'+d);
return(-1);
}


compile(address)
int address;
{ if(ram[1].pw >= &ram[RAMSIZE-2]) merr(writv);
 Pw=ram[1].pw++ ; *Pw=address;
}


fwdref()
{ push(ram[1].in); compile(0); }


char convert(ptkn,base,Pval)
char *ptkn,base;
int *Pval;
{char *tend;
 int sign,val,d;
	val=0; sign=1; tend=*ptkn + ptkn +1;
	ptkn++ ;
	if(*ptkn=='+') ptkn++;
	else if(*ptkn=='-'){ptkn++; sign=-1;}
	d=digit(*ptkn);
	while((d>-1)&&(ptkn<tend)&&(d<base))
	{	val=base*val+d;
		ptkn++;d=digit(*ptkn);
	}
	*Pval=sign*val;
	if(ptkn==tend) return(TRU);
	else return(FALS);
}


touchup()
{/* static int ref; */
	Pw=ref=pop(); *Pw=ram[1].in-ref; }


permstrings()
{	if(ram[4].pc<ram[3].pc) ram[4].pc=ram[3].pc;
}


fname(name)	/*name[length]=0 for 'C'*/
char name[NAMESIZE];
{	Pc=pop();
	if((Pc<&strings)||(Pc>&strings[STRINGSSIZE-NAMESIZE]))
		merr(readv);
	if(*Pc>=NAMESIZE) merr(writv);
	movmem(1+Pc,name,*Pc); name[*Pc]='\0';
}

') return(d-'0');