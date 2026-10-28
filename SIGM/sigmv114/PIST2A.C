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
/* second module for PISTOL v2.0 in BDS 'C', v1.45a */
/* August 30, 1982 */
#include "bdscio.h"
#include "pistol.h"

ttyi()	/* inputs character from keyboard, buffered by line */
{	/* static char keycurs,keylen,keystring[MAXORD]; */
	if(keycurs>keylen)
		{keylen=strlen(gets(keystring));
		if(ram[8].in)
			{fputs(keystring,list);
			fputs("\n",list);
			}
		keycurs=0;
		keystring[keylen]=NEWLINE;
		}
	push(keystring[keycurs++]);
}

pop()
{	if(stkptr<1) merr(undflo);
	else return(stack[stkptr--]);
}

carret()
{	if(ram[10].in)
		{if(ram[17].in==++ram[18].in)
			{ttyi();ram[18].in=0;
			if('Q'==toupper(pop()) ) abort();
			}
		ram[20].in=0;
		printf("\n");
		}
	if(ram[8].in) fprintf(list,"\n");
}

spaces(num)
char num;
{	while(num) { chout(' '); num-- ; }
}

tab()
{	if(ram[23].cr)
		spaces(ram[23].cr-ram[20].in%ram[23].cr);
}

chout(ch)
char ch;
{	if(ch==NEWLINE) carret();
	else if (ch==9) tab();
	else {	if(ram[20].in==ram[19].in) carret();
		ram[20].in++;
		if(ram[10].in) putc(ch,1);
		if(ram[8].in)putc(ch,list);
		}
}

message(st)
char *st;
{char *last;
char len;
	len=*st;
	last=st + *st;
	while(st < last){st++; chout(*st);}
}


interpret()
{	do	{ip += W;
		if(instr<NFUNCS) (*farray[instr])();
		else  {if((instr<&ram)||(instr>&ram[RAMSIZE]))
				merr(readv);
			rpush(ip); ip=instr;
			}
		Pw = ip;
		instr=*Pw;
		/* trace patch here */
		if(rptr==(ram[15].in-2))
			{savinstr=instr;
			savlevel=rptr;
			instr=ram[22].in;
			ip -= W;
			do	{ip += W;
				if(instr<NFUNCS)
					(*farray[instr])();
				else	{
					if((instr<&ram)||
					(instr>&ram[RAMSIZE]))
						merr(readv);
					rpush(ip); ip=instr;
					}
				Pw=ip; instr=*Pw;
				}
			while( rptr > savlevel);
			instr=savinstr;
			}
		}
	while (rptr >= 0);
	ip -= W;
}

merr(m)
char *m;
{	ram[10].in=TRU;
	if(ram[20].in) carret();
	message(m);
	abort();
}

synterr()
{ram[10].in=TRU;if(ram[20].in)carret();
	if((ram[7].in) && (ram[9].in==FALS))
		message(&strings[LINEBUF]);
	merr(synt);
}

push(item)
int item;
{	if(++stkptr >= SSIZE) merr(ovflo);
	stack[stkptr]=item;
}

rpush(item)
int item;
{	if(++rptr >= RSIZE) merr(ovflo);
	rstack[rptr]=item;
}


lpush(item)
int item;
{if(LSIZE<= ++lptr) merr(ovflo); lstack[lptr]=item;}

cpush(item)
int item;
{if(CSIZE<= ++cptr) merr(ovflo); cstack[cptr]=item; }


pushck(chkch)
char chkch;
{ if(CHKLMT>(++strings[1])) strings[1+strings[1]]=chkch;
else{ram[10].in=TRU; message(ovflo); synterr();}
}

append(item)	/* place item at end of dictionary */
int	item;
{
	(*ram[2].pw).in=item;
	ram[2].pw++;
	if( ram[2].pw>=&ram[COMPBUF] ) merr(writv);
}

aloop()
{if(lstack[lptr]<lstack[lptr-1]){Pw=ip;ip += *Pw; }
else{lptr -=3; if(lptr<0) merr(undflo); ip +=W ; }
}

pdo()
{/* static int start,nd; */
	start=pop(); nd=pop();
	if(start<nd)
		{lpush(start);
		lpush(nd);
		lpush(start);/* init iteration var.*/
		ip += W;
		}
	else	{Pw=ip; ip += *Pw ; }
}


dropck()
{if(strings[1]) strings[1]--; else synterr(); }


int *vfind()/*??? cleanup variable names and static*/
{char *str2;
/*ptoken,vloc,vmatch,prev,pcount,*Pc3 are "static"*/
	vloc=pop(); prev=vloc=*vloc;
	ptoken=pop();
	if((ptoken<&strings)||(ptoken>=&strings[LINEBUF]))
		merr(readv);
	if(vloc) do
	{vmatch=TRU;
	if(Pw=*(vloc-2),*Pw==*ptoken)
		for(Pc3=Pw,vmatch=*Pc3,str2=ptoken;
		vmatch&&(*++Pc3 == *++str2) ; --vmatch);
	if(vmatch)
		{prev=vloc;vloc=*(vloc-3);}
	}
	while(vloc && vmatch);
	push(vloc);
	ram[6].pw=prev;
}

find()
{int *ptoken,*loc,*v;
	ptoken=pop();
	for(loc=FALS,v=ram[28].pw;(v>=&ram[VBASE])&& !loc; v--)
		{push(ptoken);push(*v);vfind();loc=pop();}
	push(loc);
}

enter()
{int ptoken;
	ptoken=stack[stkptr];
	find();
	if(pop())
		{message(redef);
		spaces(3);
		message(ptoken);
		carret();
		}
	append(0);
	append((*ram[5].pw).in);
	append(ptoken);
	append(COMPHERE);
	(*ram[5].pw).in=ram[2].in;
}

fenter()
{Pw=(*ram[5].pw).pw-4; *Pw=pop(); }

geoln()
{ram[11].pc=&strings[LINEBUF]+strings[LINEBUF];}

getline()
{if(ram[7].in) finline(ldfil);
else cinline();
if(ram[9].in&&ram[7].in) message(&strings[LINEBUF]);
}


cinline()	/*input line from console*/
{	keycurs=1+keylen; /* for emptying ttyi() buffer */
	ram[11].pc=&strings[LINEBUF+1];
	ram[12].in=1+strlen(gets(&strings[LINEBUF+1]));
	Pc=&strings[LINEBUF];
	*Pc=ram[12].in;
	Pc += ram[12].in;
	*Pc=NEWLINE; Pc++ ;
	*Pc = 0;/* for 'C' string terminator*/
	if(ram[8].in)fputs(ram[11].pc,list);
}

finline(iobuf)
char *iobuf;
{	ram[11].pc=fgets(&strings[LINEBUF+1],iobuf);
	if(!ram[11].in) merr(feof);
	ram[12].in=strlen(ram[11].pc);
	Pc=&strings[LINEBUF];
	*Pc=ram[12].in;
	Pc += ram[12].in;
	*Pc=NEWLINE; Pc++ ;
	*Pc=0 ; /*???? should echo to list? */
	if(ram[8].in&&ram[9].in)fputs(ram[11].pc,list);
}

ret();
		}
	append(0);
	append((*ram[5].pw).in);
	app