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
/* fourth code module for PISTOL v2.0 in BDS 'C' v1.45a */
/*Feb 19,'83: fix load() when tos<1 */
/* August 28, 1982 */
#include "bdscio.h"
#include "pistol.h"

/* primitive interpreter functions */
/* static int tos; */

psemcol()
{ ip=rstack[rptr--]; }

wstore()
{	Pw=pop();
	if((Pw<ram)||(Pw>&ram[RAMSIZE])) merr(writv);
	*Pw = pop();
}

times()
{ push( pop()*pop() ); }

plus()
{ push( pop()+pop() ); }

subtract()
{ tos=pop(); push( pop()-tos ); }

divmod()
{	tos=pop();
	temp=pop();
	if(tos)
		{push(temp/tos);
		push(temp%tos);
		}
	else merr(divby0);
}

pif()
{	if(pop()) ip += W;
	else { Pw=ip; ip += *Pw; }
}

wat()
{	Pw=pop();
	if((Pw<&ram[RAMMIN])||(Pw>&ram[RAMSIZE]))
		 merr(readv);
	push( *Pw );
}

sp()
{ push(stkptr); }

load()
{	ram[7].pc=tos=pop();
	if((tos>MAXLINNO)||(tos<1))
		{push(tos); fname(infil);
		if(fopen(infil,ldfil) == ERROR)
			{printf("can't open %s\n",infil);
			/*????*/ abort();
			}
		ram[25].in=0;
		}
}

pelse()
{ Pw=ip; ip += *Pw; }

wrd()
{ push(W); }

rp()
{ push(rptr); }

puser()
{ push(ram); }

exec()
{	instr=pop();
	if(instr<NFUNCS) (*farray[instr])();
	else	{if((instr<&ram)||(instr>&ram[RAMSIZE]))
			merr(readv);
		rpush(ip); ip=instr;
		}
}

exitop()
{	if(lptr<3) abort();
	else lstack[lptr]=lstack[lptr-1];
}

lit()
{ Pw=ip; push(*Pw); ip+=W ; }

rpop()
{ push(rstack[rptr]); rptr--; }

tyo()
{ chout(pop()) ; }

rpsh()
{ rpush( pop() ); }

semicf()
{	if(ram[20].in) carret();
	if((ram[7].in<MAXLINNO)&&(ram[7].in>0))
		{ram[7].in--;
		printf("\n THROUGH LINE %d(DECIMAL) LOADED\n",
			ram[7].in);
		if(ram[8].in)
			fprintf(list,
			"\n THROUGH LINE %d(DECIMAL) LOADED\n",
			ram[7].in);
		}
	if(ram[7].in>=MAXLINNO)
		{printf("%s LOADED\n", infil);
		if(ram[8].in) fprintf(list,
				"%s LOADED\n",infil);
		}
	ram[7].in=0;
}

rat()
{	tos=rptr-pop();
	if(tos<0) merr(readv);
	push(rstack[tos]);
}

compme()
{	Pw2=ip;Pw2 -=4; j=*Pw2;Pw2=ip;
	while(Pw2<j) {compile(*Pw2); Pw2++; }
	ip=rstack[rptr--];
}

comphere()
{	compile(ip);
	ip=stack[rptr--];
}

dollarc()
{	pushck('$');compile(PDOLLAR);
	fwdref();
}

colon()
{	pushck(':');compile(PCOLON);
	fwdref();
}

semcol()
{	if(strings[1+strings[1]]==':')
		{dropck();compile(PSEMICOLON);touchup(); }
	else synterr();
}

ifop()
{ pushck('F'); compile(PIF); fwdref(); }

elseop()
{	if(strings[1+strings[1]]=='F')
		{strings[1+strings[1]]='E';
		compile(PELSE); fwdref();
		swap(); touchup();
		}
	else synterr();
}

thenop()
{	Pc= &strings[1]; Pc += *Pc;
	if((*Pc=='F')||(*Pc=='E')) {dropck();touchup();}
	else synterr();
}

doop()
{ pushck('D');compile(PDOOP);fwdref(); }

loopop()
{	if(strings[1+strings[1]]=='D')
		{dropck();compile(PLOOP);
		compile(stack[stkptr]-ram[1].in+W);
		touchup();
		}
	else synterr();
}

		}
	ram[7].in=0;
}

