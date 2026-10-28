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
/* fifth code module for PISTOL v2.0 in BDS 'C' v1.45a */
/* September 5, 1982 */
#include "bdscio.h"
#include "pistol.h"
/* continuation of interpreter primitives */

beginop()
{ pushck('B'); push(ram[1].in); }

endop()
{	if(strings[1+strings[1]]=='B')
		{dropck(); compile(PIF);
		compile(pop()-ram[1].in);
		}
	else synterr();
}

repet()
{	Pc=&strings[1]+strings[1];Pc2=Pc-1;
	dropck();dropck();
	if((*Pc=='F') && (*Pc2=='B'))
		{compile(PELSE);
		compile(stack[stkptr-1]-ram[1].in);
		touchup(); pop();
		}
	else synterr();
}

pdollar()
{	enter(); Pw=ip;
	push(ip+W);push(ram[2].pw);push(*Pw-W);
	move();
	Pw=ip;ram[2].in += *Pw-W;
	push(ram[2].in-W);
	fenter();
	Pw=ram[5].pw;Pw=*Pw;Pw--;
	*Pw=COMPME;
	permstrings();
	Pw=ip;ip += *Pw;
}

pcolon()
{	enter(); Pw=ip;
	push(ip+W);push(ram[2].pw);push(*Pw-W);
	move();
	Pw=ip;ram[2].in += *Pw-W;
	push(ram[2].in-W);
	fenter();
	permstrings(); Pw=ip;
	ip += *Pw;
}

casat()
{	tos=pop();
	if(cptr<tos) abort();
	push(cstack[cptr-tos]);
}

pploop()
{ lstack[lptr]+=pop(); aloop(); }

plloop()
{	if(strings[1+strings[1]]=='D')
		{dropck(); compile(PPLOOP);
		compile(stack[stkptr]-ram[1].in+W);
		touchup();
		}
	else synterr();
}

cat()
{	Pc=pop();
	if((Pc<&strings)||(Pc>&strings[STRINGSSIZE]))
		merr(readv);
	push(*Pc);
}

cstore()
{	Pc=pop();
	if((Pc<&strings)||(Pc>&strings[STRINGSSIZE]))
		merr(readv);
	*Pc=pop();
}

ploop()
{ lstack[lptr]++;aloop(); }

dotdot()
{/* int tos,ntt,param; */
	tos=pop();ntt=pop();param=pop();
	if(ntt<=tos)
		{if((ntt<=param)&&(param<=tos)) push(TRU);
		 else push(FALS);
		}
	else	{if((ntt<=param)||(param<=tos)) push(TRU);
		 else push(FALS);
		}
}

semidol()
{	if(strings[1+strings[1]]=='$')
		{dropck(); compile(PSEMICOLON);
		touchup();
		}
	else synterr();
}

primq()
{	tos=pop();
	if((tos<0)||(tos>=NFUNCS)) push(FALS);
	else push(TRU);
}

cordmp()
{	fname(imagename);
	temp=creat(imagename);
	if(temp==ERROR) merr(nopen);
	write(temp,nram,NSAVE);
	close(temp);
}

restor()
{	fname(imagename);
	temp=open(imagename,0);
	if(temp==ERROR) merr(nopen);
	read(temp,nram,NSAVE);
}

sat()
{	tos=pop();
	temp=stkptr-tos;
	if((tos<0)||(temp<=0)) merr(readv);
	else push(stack[temp]);
}

listfil()
{ rewrit(listname,list); }

rewrit(name,iobuf)
char name[NAMESIZE],*iobuf;
{	if(stkptr<1)merr(undflo);
	if(name[0])
		{if(ram[20].in) carret();
		message(redef);printf(name);carret();
		closout(iobuf);
		}
	fname(name);
	if(0>fcreat(name,iobuf))
	{	if(ram[20].in) carret();
		printf(name);
		merr(nopen);
	}
}

lat()
{	tos=pop();
	if((lptr<tos)||(lptr<0)) merr(readv);
	push(lstack[lptr-tos]);
}

ofcas()
{ pushck('C'); compile(POFCAS);	fwdref(); }

ccolon()
{	if(strings[1+strings[1]]=='C')
		{pushck('c');compile(PCCOL);fwdref();}
	else synterr();
}

semicc()
{	if(strings[1+strings[1]]=='c')
		{dropck();compile(PSEMICC);touchup();}
	else synterr();
}

ndcas()
{	if(strings[1+strings[1]]=='C')
		{dropck();compile(ram[21].in);touchup();}
	else synterr();
}

pofcas()
{	if(stkptr<1) merr(undflo);
	Pw=ip; cpush(ip+ *Pw);
	cpush(stack[stkptr]);
	ip += W;
}

pccol()
{	if(pop()) ip += W;
	else	{push(cstack[cptr]);
		Pw=ip; ip += *Pw;
		}
}

psemicc()
{	cptr -= 2;
	if(cptr<0) abort();
	ip=cstack[cptr+1];
}

openr()
{	fname(namein);
	if(fopen(namein,edin)==ERROR)
		{printf("\nCAN'T OPEN:%s",namein);abort();}
	ram[26].in=0;
}

openw()
{	rewrit(namout,edout);
	ram[27].in=0;
}

readl()
{int c;
	ram[12].in=0;
	ram[13].pc=&strings[1+LINEBUF];
	if(ram[26].in<0) merr(feof);
	finline(edin,&ram[26].in);
	ram[26].in++;
	c=getc(edin);
	if((c == ERROR) || (c== CPMEOF))
		 ram[26].in=-ram[26].in;
	ungetc(c,edin);
	if(ram[9].in) message(&strings[LINEBUF]);
}

writl()
{	if(ram[27].in>0) merr(nopen);
	Pc=pop(); Pc2=Pc+*Pc-1;
	while(Pc<Pc2) {Pc++;putc(*Pc,edout);}
	fprintf(edout,"\n");/*CPM newline*/
	ram[27].in--;
}

}

ndcas()
{	if(strings[1+strings[1]]=='C')
