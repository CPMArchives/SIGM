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

/* main PISTOL v2.0 module for BDS 'C' v1.45a */
/* September 5, 1982 */
#include "bdscio.h"
#include "pistol.h"

/* CONSTANTS:
	ram[..rammin-1]=future constants
	ram[-21]=MININT
	ram[-20]=MAXLINNO
	ram[-19]=CHKLMT
	ram[-18]=RAMMIN
	ram[-17]=STRINGSMIN
	ram[-16]=STRINGSMAX
	ram[-15]=VBASE
	ram[-14]=VSIZE
	ram[-13]=CSIZE
	ram[-12]=LSIZE
	ram[-11]=RSIZE
	ram[-10]=SSIZE
	ram[-9]=LINEBUF
	ram[-8]=COMPBUF
	ram[-7]=RAMMAX
	ram[-6]=MAXORD
	ram[-5]=MAXINT
	ram[-4]=VERSION
	ram[-3]=NEWLINE
	ram[-2]=READ PROTECTION BOOLEAN
	ram[-1]=WRITE PROTECTION BOOLEAN
VARIABLES:
	ram[0]=RADIX
	ram[1]=.C
	ram[2]=.D
	ram[3]=CURRENT END OF STRINGS
	ram[4]=OLD END OF STRINGS
	ram[5]=CURRENT
	ram[6]=PREV(VFIND)
	ram[7]=INPUT FILE
	ram[8]=LIST OUT BOOLEAN
	ram[9]=ECHO OUT BOOLEAN
	ram[10]=CONSOLE OUT BOOLEAN
	ram[11]=NEXTCHAR POINTER
	ram[12]=LINELENGTH
	ram[13]=RAISE BOOLEAN lc -> UC
	ram[14]=HEAD OF TOKEN IN LINE
	ram[15]=TRACE BOOLEAN AND LEVEL
	ram[16]=COMPILE END PATCH
	ram[17]=TERMINAL PAGE LENGTH
	ram[18]=#LINE OUTPUT TO CONSOLE
	ram[19]=TERMINAL WIDTH
	ram[20]=COLUMN
	ram[21]=ENDCASE PATCH ADDRESS
	ram[22]=TRACE PATCH ADDRESS
	ram[23]=TABSIZE
	ram[24]=#GETLINE PATCH ADDRESS
	ram[25]=FILE STATUS FOR LDFIL
	ram[26]=FILE STATUS FOR EDIN
	ram[27]=FILE STATUS FOR EDOUT
	ram[28]=^ VSTACK
	ram[29]=^PISTOL<
	ram[30]=NIL,TERMINATES VLIST
	ram[31]=SESSION DONE BOOLEAN
	ram[32]=PROMPT PATCH ADDRESS
	ram[33]=CONVERSION PATCH
	ram[34]=ABORT PATCH
	ram[35..VBASE+1]=FUTURE VARIABLES EXPANSION
	ram[VBASE..VBASE+VSIZE]=VSTACK
*/

main()
{
/*??? doc the uses of ram[-20..?] */
	init();	/*contains penter and fills farray */
	setjmp(jbuf);	/* initialize return point */
	/*reseting stacks returns i/o to tty: produces signon*/
	ip=&ram;	/*so ram[ip] is in range*/
	ram[15].in=ram[7].in=ram[31].in=FALS;
	ram[28].pw=&ram[VBASE];
	ram[5].pw=ram[VBASE].pw=&ram[29];
	stkptr=cptr=lptr=0;
	rptr=-1;
	strings[1]='\0';
	ram[10].in=TRU;
	if (listname[0]=='\0') ram[8].in=FALS;
	/*turns off listing if no listfile is open*/
	message(id);
	/* ifcr */
	if (ram[20].in) carret();
	if (ram[34].pw) {instr=ram[34].un;interpret();}
	/* user supplied supplement to ABORT */
	goto L99;
	do{	ram[1].pw=&ram[COMPBUF];
		do compline();
		 while(strings[1]);
		compile(PSEMICOLON);
		if(ram[16].pw) {instr=ram[16].un;interpret();}
		if(ram[10].in&&(!ram[7].in||ram[9].in))
			ram[20].in=ram[18].in=FALS;
		instr=&ram[COMPBUF];
		interpret();

L99:		ram[3].pc=ram[4].pc;
	}
	while( !ram[31].in );
	
	printf("\nPISTOL NORMAL EXIT\n");
	if(ram[8].in) fprintf(list,"\nPISTOL NORMAL EXIT\n");
	if(listname[0]) closout(list);
	if(namout[0]) closout(edout);

	exit(); /*files need to be flushed and closed */
}

closout(iobuf)
char *iobuf;
{	putc(CPMEOF,iobuf);
	fflush(iobuf); fclose(iobuf);
}

abort()
{ longjmp(jbuf); }


compline()
{/* static int inf,*pad; */
inf=ram[7].in;
if((!inf)||ram[9].in) prompt();
if((inf>0)&&(inf<MAXLINNO))
	{push(inf);
	instr=ram[24].un;
	interpret();
	ram[7].in++;
	}
else getline();
ignrblnks();
while(*ram[11].pc != NEWLINE)
	{ram[14].pc=ram[11].pc;
intoken();
push(ram[3].pc);
find(); pad=pop();
	if(pad) {instr=pad-1;interpret();}
	else	{if(convert(ram[3].in,ram[0].in,&val))
			{compile(LIT);compile(val);}
		else	{if(Pc=ram[3].pc+1,*Pc=='\'')
				{pad=slit();compile(STRLIT);
				compile(pad);}
			else if(*Pc=='"')
				{pad=longstring();
				compile(STRLIT);compile(pad);}
			else if(ram[33].in)
				{instr=ram[33].un;interpret();}
			else{/*token couldn't be deciphered*/
				ram[10].in=TRU;
				if(ram[7].in&&(!ram[9].in))
				{if(ram[20].in) carret();
				 message(&strings[LINEBUF]);
				}
				message(ram[3].in);
				printf(" ?\n");
				if(ram[8].in)
					fprintf(list," ?\n");
				abort();
			    }
			}
		}
	ignrblnks();
	}
}
t()
{ longjmp(jbuf); }


compline()
{/* sta