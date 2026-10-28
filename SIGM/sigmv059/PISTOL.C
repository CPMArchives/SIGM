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

/* main pistol module, February 1982 */

#include "bdscio.h"
#include "pistol.h"

main()
{	for (temp=0; temp<RAMSIZE; temp++)
		{ram[temp].in=10000;};
	ram[-57].in=MAXLINNO;
	ram[-56].in=CHKLMT;
	ram[-55].pw=nram;
	ram[-54].pc=strings;
	ram[-53].in=FALS;	/*bell*/
	ram[-52].in=FALS;	/* abort patch */
	ram[-51].in=FALS;	/* conversion patch */
	ram[-50].in=FALS;	/* standard prompt */
	ram[-49].pc=strings+STRINGSSIZE;
	ram[-48].pw=&ram[VBASE];
	ram[-47].in=VSIZE;
	ram[-46].in=CSIZE;
	ram[-45].in=LSIZE;
	ram[-44].in=RSIZE;
	ram[-43].in=SSIZE;
	ram[-42].pc=strings+2800;
	ram[-41].pw=&ram[RAMSIZE-250];
	ram[-40].pw=&ram[RAMSIZE];
	ram[-39].in=MAXORD;
	ram[-38].in=MAXINT;
	/*ram[-37]=*/
	ram[-36].in=VERSION;
	ram[-34].in=0;
	ram[-33].in=FALS;	/* nil link for PISTOL< */
		/* initializing file status */
	ram[-27].in=8;	/* init tabsize */
	ram[-25].in=ABRT;	/* init endcase to abort */
	ram[-24].in=0;	/*reset column location */
	ram[-23].in=TERMWIDTH;
	ram[-21].in=TERMLENGTH;
	ram[-20].in=FALS;	/* compile-end-patch */
	ram[-19].in=FALS;	/* init TRACE off */
	ram[-17].in=TRU;	/* raise on */
	ram[-13].in=FALS;	/* echo off */
	ram[-6].pw=&ram[-34];
	ram[-5].pc=&strings[CHKLMT+2];
	ram[-4].pc=ram[-5].pc;
	ram[-3].pc=&ram[80];

	divby0=addstring(16,"DIVISION BY ZERO");
	nopen=addstring(20,"*** FILE NOT OPENED*");
	feof=addstring(20,"*** EOF ENCOUNTERED*");
	id=addstring(18,"*** PISTOL 1.3 ***");
	synt=addstring(20,"*** SYNTAX ERROR ***");
	ovflo=addstring(19,"** STACK OVERFLOW *");
	undflo=addstring(19,"* STACK UNDERFLOW *");
	redef=addstring(16,"---redefining---");

	init();	/*contains penter and fills farray */

	ram[-1].in=10;	/* DECIMAL MODE :*/
	strings[0]='X';

	ram[-31].in=1;	/* edout */
	ram[-30].in=-1;	/* edin */
	ram[-29].in=-1;	/* ldfil1 */
	namein[0]=namout[0]=listnamef[0]=ram[-12].in=FALS;

	abort();	/* initialize return point */
	/*reseting stacks returns i/o to tty: produces signon*/
	ip=&ram;	/*so ram[ip] is in range*/
	ram[-35].in=FALS;
	ram[-32].pw=&ram[VBASE];
	ram[VBASE].pw=&ram[-34];
	ram[-6].pw=&ram[-34];
	stkptr=0;
	rptr=-1;
	cptr=0;
	lptr=0;
	strings[1]='\0';
	ram[-11].in=FALS;
	ram[-14].in=TRU;
	if (listname[0]=='\0') ram[-12].in=FALS;
	/*turns off listing if no listfile is open*/
	message(id);
	/* ifcr */
	if (ram[-24].in) carret();
	ram[-19].in=FALS;	/* turn off trace */
	if (ram[-52].pw) interpret(ram[-52].pw);
	/* user supplied supplement to ABORT */
	goto L99;
	do{	ram[-2].pw=&ram[COMPBUF];
		do compline(); while(strings[1]);
		compile(PSEMICOLON);

		if(ram[-20].pw) interpret(ram[-20].pw);
		if(ram[-14].in&&(!ram[-11].in||ram[-13].in))
			ram[-24].in=ram[-22].in=FALS;
		interpret(&ram[COMPBUF]);

L99:		ram[-4].pc=ram[-5].pc;
	}
	while( !ram[-35].in );
	
	printf("\nPISTOL NORMAL EXIT\n");
	if(listname[0]) closout(list);
	if(namout[0]) closout(edout);

	exit(); /*files need to be flushed and closed */
}

closout(iobuf)
char *iobuf;
{	putc(CPMEOF,iobuf);
	fflush(iobuf); fclose(iobuf);
}
ram[-32].pw=&ram[VBASE];
	ram[VBASE].pw=&ram[-34];
	ram[-6].pw=&ram[-34];
	stkptr=0;
	rptr=-1;
	cptr=0;
	l