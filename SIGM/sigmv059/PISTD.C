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

/* fourth module, February, 1982 */

#include "bdscio.h"
#include "pistol.h"

interpret(i)
unsigned i;
{	instr=i;
	do	{ip += W;
		if(instr<(RESTOR+1)) /*pint(instr);*/
				(*farray[instr])();
		else	{ rpush(ip); ip=instr;}
		Pw = ip;
		instr=*Pw;
		/* trace patch here */
		if(rptr==(ram[-19].in-2))
			{savinstr=instr;
			savlevel=rptr;
			instr=ram[-26].in;
			ip -= W;
			do	{ip += W;
				if(instr<(RESTOR+1))
					/*pint(instr);*/
					(*farray[instr])();
				else{rpush(ip); ip=instr;}
				Pw=ip; instr=*Pw;
				}
			while( rptr > savlevel);
			instr=savinstr;
			}
		}
	while (rptr >= 0);
	ip -= W;
}

fname(name)	/*name[0]=length,name[length+1]=0*/
char name[NAMESIZE];
{	drop(); Pc=stack[1+stkptr];
	movmem(1+Pc,1+name,*Pc); name[1+*Pc]='\0';
	name[0]=*Pc;
}

rewrit(name,iobuf)
char name[NAMESIZE],*iobuf;
{	if(stkptr<1)merr(undflo);
	if(name[0])
		{if(ram[-24].in) carret();
		message(redef);message(name);carret();
		closout(iobuf);
		}
	fname(name);
	if(0>fcreat(1+name,iobuf))
	{	if(ram[-24].in) carret();
		message(name);
		merr(nopen);
	}
}

beginop()
{ pushck('B'); push(ram[-2].in); }

endop()
{	if(strings[1+strings[1]]=='B')
		{dropck(); compile(PIF);
		compile(stack[stkptr]-ram[-2].in);
		drop();
		}
	else synterr();
}

repet()
{	Pc=&strings[1]+strings[1];Pc2=Pc-1;
	dropck();dropck();
	if((*Pc=='F') && (*Pc2=='B'))
		{compile(PELSE);
		compile(stack[stkptr-1]-ram[-2].in);
		touchup(); drop();
		}
	else synterr();
}

pdollar()
{	enter(); Pw=ip;
	move(ip+W,ram[-3].pw,*Pw-W);
	Pw=ip;ram[-3].in += *Pw-W;
	fenter(ram[-3].in-W);
	Pw=ram[-6].pw;Pw=*Pw;Pw--;
	*Pw=COMPME;
	permstrings();
	Pw=ip;ip += *Pw;
}

pcolon()
{	enter(); Pw=ip;
	move(ip+W,ram[-3].pw,*Pw-W);
	Pw=ip;ram[-3].in += *Pw-W;
	fenter(ram[-3].in-W);
	permstrings(); Pw=ip;
	ip += *Pw;
}

casat()
{	enter();
	if(cptr<stack[stkptr+1]) abort();
	push(cstack[cptr-stack[stkptr+1]]);
}

pploop()
{ drop(); lstack[lptr]+=stack[stkptr+1]; aloop(); }

plloop()
{	if(strings[1+strings[1]]=='D')
		{dropck(); compile(PPLOOP);
		compile(stack[stkptr]-ram[-2].in+W);
		touchup();
		}
	else synterr();
}

cat()
{ Pc=stack[stkptr];stack[stkptr]=*Pc; }

cstore()
{	Pc=stack[stkptr];drop();
	i=stack[stkptr];drop();
	*Pc=i;
}

ploop()
{ lstack[lptr]++;aloop(); }

gt()
{	drop();drop();
	if(stack[stkptr+1] >stack[stkptr+2]) push(TRU);
	else push(FALS);
}

semidol()
{	if(strings[1+strings[1]]=='$')
		{dropck(); compile(PSEMICOLON);
		touchup();
		}
	else synterr();
}

kernq()
{	drop();
	if(stack[stkptr+1]<ram[-55].in)	push(TRU);
	else push(FALS);
}

sat()
{	if(stack[stkptr]<stkptr-1)
		{stack[stkptr]=stack[stkptr-stack[stkptr]-1];}
	else merr(undflo);
}

findop()
{ drop();push(find(stack[1+stkptr])); }

listfil()
{ rewrit(listname,list); }

lat()
{	drop();
	if(lptr<stack[stkptr+1]) abort();
	push(lstack[lptr-stack[stkptr+1]]);
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
		{dropck();compile(ram[-25].in);touchup();}
	else synterr();
}

pofcas()
{	drop(); stkptr++; Pw=ip;
	cpush(ip+ *Pw);cpush(stack[stkptr]);
	ip += W;
}

strange()
{ Printf("strange opcode:%d\n",instr); abort(); }

pccol()
{	drop();
	if(stack[stkptr+1]) ip += W;
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
	if(fopen(1+namein,edin)==ERROR)
		{printf("\nCAN'T OPEN:%s",1+namein);abort();}
	ram[-30].in=0;
}

openw()
{	rewrit(namout,edout);
	ram[-31].in=0;
}

readl()
{	ram[-16].in=0; /* Feb 19 */
	ram[-15].pc=&strings[1+LINEBUF];
	if(ram[-30].in<0) merr(feof);
	finline(edin,&ram[-30].in);
	ram[-30].in++;
	if(eof(edin)) ram[-30].in=-ram[-30].in;
	if(ram[-13].in) message(&strings[LINEBUF]);
}

writl()
{	drop();
	if(ram[-31].in>0) merr(nopen);
	Pc=stack[1+stkptr]; Pc2=Pc+*Pc-1;
	while(Pc<Pc2) {Pc++;putc(*Pc,edout);}
	fprintf(edout,"\n");/*CPM newline*/
	ram[-31].in--;
}

cordmp()
{	fname(imagename);
	temp=creat(1+imagename);
	if(temp==ERROR) merr(nopen);
	write(temp,nram,NSAVE);
	close(temp);
}

restor()
{	fname(imagename);
	temp=open(1+imagename,0);
	if(temp==ERROR) merr(nopen);
	read(temp,nram,NSAVE);
}r+1])