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

/* sixth and final module in BDS 'C', February, 1982 */

#include "bdscio.h"
#include "pistol.h"

synterr()
{ram[-14].in=TRU;if(ram[-24].in)carret();
	if((ram[-11].in) && (ram[-13].in==FALS))
		message(&strings[LINEBUF]);
	merr(synt);
}

pushck(chkch)
char chkch;
{ if(CHKLMT>(++strings[1])) strings[1+strings[1]]=chkch;
else{ram[-14].in=TRU; message(ovflo); synterr();}
}

aloop()
{if(lstack[lptr]<lstack[lptr-1]){Pw=ip;ip += *Pw; }
else{lptr -=3; if(lptr<0) merr(undflo); ip +=W ; }
}

pdo()
{drop(); drop();
	if(stack[stkptr+2]<stack[stkptr+1])
	{lpush(stack[stkptr+2]);
	lpush(stack[stkptr+1]);
	lpush(stack[stkptr+2]); ip += W;
	}
	else{ Pw=ip; ip += *Pw; }
}

dropck()
{if(strings[1]) strings[1]--; else synterr(); }

geoln() /* Feb 17 */
{	while(*ram[-15].pc != NEWLINE) ram[-15].pc++;
}

move(as,ad,nowd)
int as,ad,nowd;
{int endaddr;
	endaddr=as+nowd; Pw=as; Pw2=ad;
	while(Pw <= endaddr)
	{ *Pw2=*Pw ; Pw++; Pw2++;}
}

swap() /* Feb 17 */
{Pc=stack[stkptr];stack[stkptr]=stack[stkptr-1];
	stack[stkptr-1]=Pc;
}

permstrings()
{	if(ram[-5].pc<ram[-4].pc) ram[-5].pc=ram[-4].pc;
}

enter() /* Feb 17 eliminate Pw */
{drop();temp=find(stack[stkptr+1]);
if(temp){message(redef);spaces(3);
	message(stack[stkptr+1]);carret();
	}append(0);
	append((*ram[-6].pw).in);
	append(stack[stkptr+1]);
	append(COMPHERE);
	(*ram[-6].pw).in=ram[-3].in;
}

fenter(i) /* Feb 17, shortened */
int i;
{ Pw = (*ram[-6].pw).pw - 4 ; *Pw = i ; }

getline()
{if(!ram[-11].in)
	{/* input from console*/
	cinline();
	}
else
	{/*input from file*/
	finline(ldfil1,&Pc);	/*Pc can get*/
	}			/*clobbered if eof*/
if(ram[-13].in&&ram[-11].in) message(&strings[LINEBUF]);
}

lpush(item)
int item;
{if(LSIZE<= ++lptr) merr(ovflo); lstack[lptr]=item;}

cpush(item)
int item;
{if(CSIZE<= ++cptr) merr(ovflo); cstack[cptr]=item; }

touchup()
{int val;
	Pw=val=stack[stkptr];drop();*Pw=ram[-2].in-val; }

fwdref()
{ push(ram[-2].in); compile(0); }

compile(address) /* Feb 17 */
int address;
{ if(ram[-2].pw >= &ram[RAMSIZE-2]) merr(ovflo);
 Pw=ram[-2].pw++ ; *Pw=address;
}



/* addstring - convenience for initialization phase to emplace
	string and update ram[-4]
*/
char *addstring(length,string)
int length;
char *string;
{
int i;
char *start;
	start=ram[-4].pc++;
	movmem(string,ram[-4].pc,length);
	ram[-4].pc += length;
	permstrings();
	*start=length;
	return(start);
}

append(item)	/* place item at end of dictionary */
int	item;	/* doesn't check for overflow yet, Feb 17 */
{
	(*ram[-3].pw).in=item;
	ram[-3].pw++;
}

penter(length, name, opcode) /* Feb 17 */
int	length,opcode;
char	*name;
{
	Pc=addstring(length,name);
	append(0);
	append((*ram[-6].pw).in);
	append(Pc);
	if(opcode<0)
	{append(-opcode);append(PSEMICOLON);}
	else
	{append(COMPME);append(opcode);}
	(*ram[-6].pw).pw = ram[-3].pw - 1 ;
	fenter(ram[-3].in);
}

carret()	/* outputs the CR-LF sequence*/
{	if(ram[-14].in)
	{	if(ram[-21].in == ++ram[-22].in)
		{ram[-22].in=0;
		cinline(); Pc =ram[-15].pc;
		if('Q' == toupper(*Pc)) abort();
		}
		ram[-24].in=0;
		printf("\n");
	}
	if(ram[-12].in) fprintf(list,"\n");
}

merr(m)
char *m;
{	ram[-14].in=TRU;
	if(ram[-24].in) carret();
	message(m);
	abort();
}

message(st)
char *st;
{char *last;
char len;
	len=*st;
	last=st + *st;
	while(st < last){st++; chout(*st);}
}

drop()
{	if(stkptr<1)merr(undflo);
	else stkptr--;
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

chout(ch)
char ch;
{	if(ch == 13) carret();
	else if(ch == 9) tab();
	else{if(ram[-24].in==ram[-23].in)carret();
		ram[-24].in++;
		if(ram[-14].in)putc(ch,1);
		if(ram[-12].in)putc(ch,list);
	}
}

tab()
{	if(ram[-27].in>0)
	spaces(ram[-27].in-ram[-24].in%ram[-27].in);
}

spaces(num)
int num;
{	while(num>0){chout(' ');num--;}
}

cinline()	/*input line from console*/
{	ram[-15].pc=&strings[LINEBUF+1];
	ram[-16].in=1+strlen(gets(&strings[LINEBUF+1]));
	Pc=&strings[LINEBUF];
	*Pc=ram[-16].in;
	Pc += ram[-16].in;
	*Pc=NEWLINE; Pc++ ;
	*Pc=10 ; Pc++ ;
	*Pc = 0;
	if(ram[-12].in)fputs(ram[-15].pc,list);
}

finline(iobuf,iostat)
char *iobuf;
int *iostat;	/*not used anymore ???*/
{	ram[-15].pc=fgets(&strings[LINEBUF+1],iobuf);
	if(!ram[-15].in) merr(feof);
	ram[-16].in=strlen(ram[-15].pc);
	Pc=&strings[LINEBUF];
	*Pc=ram[-16].in;
	Pc += ram[-16].in;
	*Pc=NEWLINE; Pc++ ;
	*Pc=10; Pc++ ;
	*Pc=0 ;
}

eof(iobuf)	/* used to test for eof status on */
char *iobuf;	/* buffered i/o in analogy to PASCAL*/
{int c;
	c=getc(iobuf);
	if((c == ERROR) || (c== CPMEOF)) return(TRU);
	ungetc(c,iobuf);
	return(FALS);
}

ram[-14].in)putc(ch,1);
		if(ram[-12].in)putc(ch,list);
	}
}

tab()
{	if(ram[-27].in>0)
	spaces(ram[-27].in-ram[-24].in