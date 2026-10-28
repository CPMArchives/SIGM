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
/* sixth code module for PISTOL v2.0 in BDS 'C' v1.45a */
/* March 10, 1983 */

#include "bdscio.h"
#include "pistol.h"

init()
{int psemcol(),wstore(),times(),plus(),subtract(),
	divmod(),pif(),wat(),abort(),sp(),
	load(),pelse(),wrd(),rp(),pop(),
	puser(),exec(),exitop(),lit(),rpop(),
	swap(),ttyi(),tyo(),rpsh(),semicf(),
	rat(),compme(),comphere(),dollarc(),colon(),
	semcol(),ifop(),elseop(),thenop(),doop(),
	loopop(),beginop(),endop(),repet(),geoln(),pdollar(),
	pcolon(),casat(),pdo(),pploop(),plloop(),
	cat(),cstore(),ploop(),dotdot(),semidol(),
	primq(),cordmp(),restor(),sat(),find(),
	listfil(),vfind(),lat(),ofcas(),ccolon(),
	semicc(),ndcas(),pofcas(),pccol(),psemicc(),
	getline(),intoken(),openr(),openw(),
	readl(),writl();

	keylen=0;/*March 10, 1983*/
	for (temp=0; temp<RAMSIZE; temp++)
		{ram[temp].in=10000;};
	stkptr=0;
	ram[-21].in=MININT;
	ram[-20].in=MAXLINNO;
	ram[-19].in=CHKLMT;
	ram[-18].pw=nram;
	ram[-17].pc=strings;
	ram[34].in=ram[33].in=ram[32].in=ram[30].in=
		ram[29].in=FALS;
	ram[-16].pc=strings+STRINGSSIZE;
	ram[-15].pw=&ram[VBASE];
	ram[-14].in=VSIZE;
	ram[-13].in=CSIZE;
	ram[-12].in=LSIZE;
	ram[-11].in=RSIZE;
	ram[-10].in=SSIZE;
	ram[-9].pc=&strings[LINEBUF];
	ram[-8].pw=&ram[COMPBUF];
	ram[-7].pw=&ram[RAMSIZE];
	ram[-6].in=MAXORD;
	ram[-5].in=MAXINT;
	ram[-4].in=VERSION;
	ram[-3].in=NEWLINE;
	ram[-2].in=RPROTECT;
	ram[-1].in=WPROTECT;
	ram[27].in=1;
	ram[26].in=ram[25].in=-1;
	ram[23].in=8;	/* init tabsize */
	ram[21].in=ABRT;	/* init endcase to abort */
	ram[19].in=TERMWIDTH;
	ram[17].in=TERMLENGTH;
	ram[16].in=ram[15].in=ram[9].in=ram[8].in=FALS;
	ram[13].in=TRU;
	ram[5].pw=&ram[29];
	ram[2].pw=&ram[45+VSIZE+RSIZE];
	ram[3].pc=ram[4].pc=&strings[CHKLMT+2];
	ram[0].in=10;	/* decimal mode */
	strings[0]='X';
	imagename[0]=namein[0]=namout[0]=listname[0]=
	infil[0]=strings[1]=0;
	readv=addstring(18,"**READ VIOLATION**");
	writv=addstring(19,"**WRITE VIOLATION**");
	divby0=addstring(16,"DIVISION BY ZERO");
	nopen=addstring(20,"*** FILE NOT OPENED*");
	feof=addstring(20,"*** EOF ENCOUNTERED*");
	id=addstring(18,"*** PISTOL 2.0 ***");
	synt=addstring(20,"*** SYNTAX ERROR ***");
	ovflo=addstring(19,"** STACK OVERFLOW *");
	undflo=addstring(19,"* STACK UNDERFLOW *");
	redef=addstring(16,"---REDEFINING---");

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
	farray[DROPOP]=pop;
	farray[PUSER]=puser;
	farray[EXEC]=exec;
	farray[EXITOP]=exitop;
	farray[STRLIT]=farray[LIT]=lit;
	farray[RPOP]=rpop;
	farray[SWP]=swap;
	farray[TYI]=ttyi;
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
	farray[DOTDOT]=dotdot;
	farray[SEMIDOL]=semidol;
	farray[PRMQ]=primq;
	farray[CORDMP]=cordmp;
	farray[RESTOR]=restor;
	farray[SAT]=sat;
	farray[FINDOP]=find;
	farray[LISTFIL]=listfil;
	farray[VFINDOP]=vfind;
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
	penter(2,"..",DOTDOT);
	penter(2,";$",-SEMIDOL);
	penter(10,"PRIMITIVE?",PRMQ);
	penter(8,"COREDUMP",CORDMP);
	penter(7,"RESTORE",RESTOR);
	penter(2,"S@",SAT);
	penter(4,"FIND",FINDOP);
	penter(8,"LISTFILE",LISTFIL);
	penter(5,"VFIND",VFINDOP);
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
}


/* addstring - convenience for initialization phase to emplace
	string and update ram[3]
*/
char *addstring(length,string)
int length;
char *string;
{
int i;
char *start;
	start=ram[3].pc++;
	movmem(string,ram[3].pc,length);
	ram[3].pc += length;
	permstrings();
	*start=length;
	return(start);
}


penter(length, name, opcode)
int	length,opcode;
char	*name;
{
	Pc=addstring(length,name);
	append(0);
	append((*ram[5].pw).in);
	append(Pc);
	if(opcode<0)
	{append(-opcode);append(PSEMICOLON);}
	else
	{append(COMPME);append(opcode);}
	(*ram[5].pw).pw = ram[2].pw - 1 ;
	push(ram[2].in);
	fenter();
}
8,"LISTFILE",LISTFIL);
	penter(5,"VFIND