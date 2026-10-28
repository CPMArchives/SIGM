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

/* second pistol module, February, 1982 */

#include "bdscio.h"
#include "pistol.h"

init()
{int psemcol(),wstore(),times(),plus(),subtract(),
	divmod(),pif(),wat(),abort(),sp(),
	load(),pelse(),wrd(),rp(),drop(),
	puser(),exec(),exitop(),lit(),rpop(),
	swap(),tyi(),tyo(),rpsh(),semicf(),
	rat(),compme(),comphere(),dollarc(),colon(),
	semcol(),ifop(),elseop(),thenop(),doop(),
	loopop(),beginop(),endop(),repet(),geoln(),pdollar(),
	pcolon(),casat(),pdo(),pploop(),plloop(),
	cat(),cstore(),ploop(),gt(),semidol(),
	kernq(),strange(),sat(),findop(),listfil(),
	lat(),ofcas(),ccolon(),semicc(),ndcas(),
	pofcas(),pccol(),psemicc(),getline(),intoken(),
	openr(),openw(),readl(),writl(),cordmp(),
	restor();

	farray[PSEMICOL]=psemcol;
	farray[WSTORE]=wstore;
	farray[TIMES]=times;
	farray[PLUS]=plus;
	farray[SUBTRACT]=subtract;
	farray[DIVMOD]=divmod;
	farray[PIF]=pif;
	farray[WAT]=wat;
	farray[ABRT]=abort;
	farray[SP]=sp;
	farray[LOAD]=load;
	farray[PELSE]=pelse;
	farray[WRD]=wrd;
	farray[RP]=rp;
	farray[DROPOP]=drop;
	farray[PUSER]=puser;
	farray[EXEC]=exec;
	farray[EXITOP]=exitop;
	farray[STRLIT]=farray[LIT]=lit;
	farray[RPOP]=rpop;
	farray[SWP]=swap;
	farray[TYI]=tyi;
	farray[TYO]=tyo;
	farray[RPSH]=rpsh;
	farray[SEMICF]=semicf;
	farray[RAT]=rat;
	farray[COMPME]=compme;
	farray[COMPHERE]=comphere;
	farray[DOLLARC]=dollarc;
	farray[COLON]=colon;
	farray[SEMICOLON]=semcol;
	farray[IFOP]=ifop;
	farray[ELSEOP]=elseop;
	farray[THENOP]=thenop;
	farray[DOOP]=doop;
	farray[LOOPOP]=loopop;
	farray[BEGINOP]=beginop;
	farray[ENDOP]=endop;
	farray[REPET]=repet;
	farray[PERCENT]=geoln;
	farray[PDOLLAR]=pdollar;
	farray[PCOLON]=pcolon;
	farray[CASAT]=casat;
	farray[PDOOP]=pdo;
	farray[PPLOOP]=pploop;
	farray[PLLOOP]=plloop;
	farray[CAT]=cat;
	farray[CSTORE]=cstore;
	farray[PLOOP]=ploop;
	farray[GT]=gt;
	farray[SEMIDOL]=semidol;
	farray[KRNQ]=kernq;
	farray[53]=farray[54]=strange;
	farray[SAT]=sat;
	farray[FINDOP]=findop;
	farray[LISTFIL]=listfil;
	farray[58]=strange;
	farray[LAT]=lat;
	farray[OFCAS]=ofcas;
	farray[CCOLON]=ccolon;
	farray[SEMICC]=semicc;
	farray[NDCAS]=ndcas;
	farray[POFCAS]=pofcas;
	farray[PCCOL]=pccol;
	farray[PSEMICC]=psemicc;
	farray[GTLIN]=getline;
	farray[WORD]=intoken();
	farray[OPENR]=openr;
	farray[OPENW]=openw;
	farray[READL]=readl;
	farray[WRITL]=writl;
	farray[CORDMP]=cordmp;
	farray[RESTOR]=restor;

	penter(2,"W!",WSTORE);
	penter(1,"*",TIMES);
	penter(1,"+",PLUS);
	penter(1,"-",SUBTRACT);
	penter(4,"/MOD",DIVMOD);
	penter(2,"W@",WAT);
	penter(5,"ABORT",ABRT);
	penter(2,"SP",SP);
	penter(4,"LOAD",LOAD);
	penter(1,"W",WRD);
	penter(2,"RP",RP);
	penter(4,"DROP",DROPOP);
	penter(4,"USER",PUSER);
	penter(4,"EXEC",EXEC);
	penter(4,"EXIT",EXITOP);
	penter(2,"R>",RPOP);
	penter(4,"SWAP",SWP);
	penter(3,"TYI",TYI);
	penter(3,"TYO",TYO);
	penter(2,"<R",RPSH);
	penter(2,";F",SEMICF);
	penter(2,"R@",RAT);
	penter(2,"$:",-DOLLARC);
	penter(1,":",-COLON);
	penter(1,";",-SEMICOLON);
	penter(2,"IF",-IFOP);
	penter(4,"ELSE",-ELSEOP);
	penter(4,"THEN",-THENOP);
	penter(2,"DO",-DOOP);
	penter(4,"LOOP",-LOOPOP);
	penter(5,"BEGIN",-BEGINOP);
	penter(3,"END",-ENDOP);
	penter(6,"REPEAT",-REPET);
	penter(1,"%",-PERCENT);
	penter(5,"CASE@",CASAT);
	penter(5,"+LOOP",-PLLOOP);
	penter(2,"C@",CAT);
	penter(2,"C!",CSTORE);
	penter(2,"GT",GT);
	penter(2,";$",-SEMIDOL);
	penter(7,"KERNEL?",KRNQ);
	penter(2,"S@",SAT);
	penter(4,"FIND",FINDOP);
	penter(8,"LISTFILE",LISTFIL);
	penter(2,"L@",LAT);
	penter(6,"OFCASE",-OFCAS);
	penter(2,"C:",-CCOLON);
	penter(2,";C",-SEMICC);
	penter(7,"ENDCASE",-NDCAS);
	penter(4,"(;C)",PSEMICC);
	penter(7,"GETLINE",GTLIN);
	penter(4,"WORD",WORD);
	penter(5,"OPENR",OPENR);
	penter(5,"OPENW",OPENW);
	penter(8,"READLINE",READL);
	penter(9,"WRITELINE",WRITL);
	penter(8,"COREDUMP",CORDMP);
	penter(7,"RESTORE",RESTOR);
}


tyi()	/* inputs a character from the keyboard,buffered line*/
{	if(*ram[-15].pc == NEWLINE) cinline();
	else nextch();
	push(*ram[-15].pc);
}

psemcol()
{ ip=rstack[rptr--]; 
}

wstore()
{	drop(); drop(); Pw=stack[2+stkptr];
			*Pw=stack[1+stkptr];
}

times()
{	drop(); stack[stkptr] *= stack[1+stkptr];
}

plus()
{	drop(); stack[stkptr] += stack[1+stkptr];
}

subtract()
{	drop();stack[stkptr] -= stack[1+stkptr];
}

divmod()
{	if(stack[stkptr])
		{stack[1+stkptr]=
			stack[stkptr-1]/stack[stkptr];
		stack[stkptr]=
			stack[-1+stkptr]%stack[stkptr];
		stack[stkptr-1]=stack[stkptr+1];
		}
	else merr(divby0);
}

pif()
{	drop();
	if(stack[1+stkptr]) ip+=W;
	else{Pw=ip;ip+=*Pw;}
}

wat()
{ Pw=stack[stkptr]; stack[stkptr]=*Pw;
}

sp()
{ push(stkptr); }

load()
{	drop();
	ram[-11].in=stack[stkptr+1];
	if(ram[-11].in>MAXLINNO)
		{movmem(ram[-11].pc+1,infil1,
				*ram[-11].pc);
		infil1[*ram[-11].pc]='\0';
		if(fopen(infil1,ldfil1) == ERROR)
			{printf("can't open %s\n",
				infil1);
			abort();
			}
		ram[-29].in=0;
		}
}

pelse()
{ Pw=ip; ip += *Pw;}

wrd()
{ push(W); }

rp()
{ push(rptr); }

puser()
{ push(ram); }

exec()
{	instr=stack[stkptr]; drop();
	if(instr<(RESTOR+1)) (*farray[instr])();
	else {rpush(ip);ip=instr;}
}

exitop()
{	if(lptr<3) abort();
	else lstack[lptr]=lstack[lptr-1];
}

lit()
{ Pw=ip; push(*Pw); ip +=W; }

rpop()
{ push(rstack[rptr]);rptr--; }

tyo()
{ drop(); chout(stack[stkptr+1]); }

rpsh()
{ rpush(stack[stkptr]);drop(); }

semicf()
{	if(ram[-24].in) carret();
	if((ram[-11].in<MAXLINNO)&&(ram[-11].in>0))
		{ram[-11].in--;
		printf("\n THROUGH LINE %d(DECIMAL) LOADED\n",
			ram[-11].in);
		if(ram[-12].in)
		fprintf(list,
			"\n THROUGH LINE %d(DECIMAL) LOADED\n",
			ram[-11].in);
		}
	if(ram[-11].in>=MAXLINNO)
		{printf("%s LOADED\n",infil1);
		if(ram[-12].in)
			fprintf(list,"%s LOADED\n",infil1);
		}
	ram[-11].in=0;
}

rat()
{	drop();
	if(rptr<stack[1+stkptr])merr(undflo);
	push(rstack[rptr-stack[stkptr+1]]);
}

compme()
{	Pw2=ip;Pw2 -= 4; j=*Pw2; Pw2=ip;
	while(Pw2<j)	{compile(*Pw2);Pw2++;}
	ip=rstack[rptr--];
}

comphere()
{	compile(ip);
	ip=rstack[rptr--];
}

dollarc()
{	pushck('$');compile(PDOLLAR);
	fwdref();
}

colon()
{	pushck(':'); compile(PCOLON);
	fwdref();
}

semcol()
{	if(strings[1+strings[1]]==':')
		{dropck();compile(PSEMICOLON);touchup();}
	else synterr();
}

ifop()
{ pushck('F');compile(PIF);fwdref(); }

elseop()
{	if(strings[1+strings[1]]=='F')
		{strings[1+strings[1]]='E';
		compile(PELSE);fwdref();
		swap();touchup();
		}
	else synterr(); 
}

thenop()
{	Pc= &strings[1]; Pc += *Pc;
	if((*Pc=='F')||(*Pc=='E'))
		{dropck();touchup();}
	else synterr(); 
}

doop()
{ pushck('D');compile(PDOOP);fwdref(); }

loopop()
{	if(strings[1+strings[1]]=='D')
		{dropck(); compile(PLOOP);
		compile(stack[stkptr]-ram[-2].in+W);
		touchup();
		}
	else synterr();
}rat()
{	drop();
	if(rptr<stack[1+stkptr])merr(undf