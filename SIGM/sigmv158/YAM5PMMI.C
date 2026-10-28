/*
>>:yam5pmmi.c 12-14-83
 *
 * PMMI MM-103 routines installed.  These routines will:
 * 		* Dial the telephone
 *		* Dial the telephone with ringback protocol
 *		  (no ring detect, just waits 8.5 seconds)
 *		* Set baud rate
 *		* Flip between answer and originate mode
 *		* Hang up phone when appropriate
 *
 * Use b command (set buad) to turn on modem when dialing manually
 * (for MCI, SPRINT, etc.) (works like modem7 excpt ans/org is sep
 * command)
 *
 * 12-14-83 Moved bios() to yam7.c
 *
 * 10-14-83 converted to C86 syntax for 16 bit, updated to 4.26 (pjh)
 *
 * 8-22-83 Finally fixed ringback bug thanks to steve passe. (pjh)
 *
 * 7-23-82 changed to count down in "Waiting for answer" routine. (pjh)
 *
 * 7-10-82 Fixed error handling in waiting-for-answer routine. (pjh)
 *
 * 7-09-82 changed autodial routine to call terminal function directly
 * after successful call. Changed set baud routine to support all baud
 * rates between 61 and 710 ala cnode baud code. Fix error in dtdet()
 * that caused no return. (pjh)
 *
 * 6-27-82 added .7 sec delay in ringback to futher try to fix bug;
 * removed extra readline() code to shorten file. (pjh)
 *
 * 6-17-82 removed mysleep(); cleaned-up file; fixed parameter passing
 * in flip(); lengthened wait time at on-hook to fix bug in ringback
 * dial. (pjh)
 *
 * 6-13-82 added XMODEM conditional assembly defines for pause when
 * flipping modem modes. Added reset to default baud in bye(). (pjh)
 *
 * 6-12-82 added OK and ERROR on return to yam from flip.  Deleted
 * unnecessary code. (caf)
 *
 * based on yam5pmmi.c by joe shannon.
 */

/*
 * setbaud(nbaud) If legal rate, set modem registers and Baudrate
 */
#define EXTERN extern
#include "yamc86.h"

#ifdef PMMI
#define MODEMSTUFF

setbaud(nbaud)
unsigned nbaud;
{
	if ((nbaud < 61) || (nbaud >710 )) {
		printf("baudrate out of range (61-710)\n");
		return(ERROR);
	}
	outportb(Sport+2, 15625/nbaud);

	 /* turn on data terminal below 300 */
	if(nbaud<301)
		outportb(Sport+3,0x7F);
	else	 /* above 300 baud */
		outportb(Sport+3,0x5F);
	Baudrate=nbaud;
	if(Originate) outportb(Sport,0x1D);  /* off hook originate mode */
	else outportb(Sport,0x1E);	/* off hook answer mode */
	sleep(CLKMHZ/2);  /*wait at least 51 msec */
	outportb(Sport,0x5C); /*setup uart - 8 bits; no parity; 2 stop bits*/
	return(0);
}
onhook()
{
	outportb(Sport+3,0x3F); /* idle modem */
	outportb(Sport,0);      /* go onhook */
	sleep(19 * CLKMHZ); 	/* 3.8 sec(s) to go on */
}
sendbrk()
{
	outportb(Sport+3, 0x7B);	/* request transmit break */
	sleep(CLKMHZ/2);
	outportb(Sport+3, 0x7F);	/* return to normal */ 
	setbaud(Baudrate);
}
bye()
{
	onhook();
#ifdef DEFBAUD
	Baudrate=(DEFBAUD);
#else
	readbaud();
#endif
	setbaud(Baudrate);
}
readbaud()
{
#ifdef XMODEM
	Baudrate=(15625/peek(0x0040)); /* use with special bye prog */
#else
	Baudrate=DEFBAUD;
#endif
}

/*
 *  flip - toggle pmmi org/ans mode
 *  adapted from steve passe's cnode flip
 *  Returns OK is successful, ERROR otherwise
 */

flip(argc,argp)
int argc;
char **argp;
{
	if (argc != 1) {
		printf("\007usage: flip 'org' or 'ans'\n");
		return(ERROR);
	}
	if(strcmp("org", argp[0]) == 0) {
		printf("changing to originate mode");
#ifdef XMODEM
		sleep(15*CLKMHZ/2);	/* wait a sec before you do it */
#endif
		outportb(Sport, 0x1d);
		sleep(CLKMHZ/2);	/* kill at least 51ms. */
		outportb(Sport, 0x1c);	/* enable auto hangup */
		Originate = TRUE;
	}
	else if(strcmp("ans", argp[0]) == 0) {
		printf("changing to answer mode");
#ifdef XMODEM
		sleep(15*CLKMHZ/2);	/* wait a sec before you do it */
#endif
		outportb(Sport, 0x1e);
		sleep(CLKMHZ/2);	/* kill at least 51ms. */
		outportb(Sport, 0x1c);	/* enable auto hangup */
		Originate = FALSE;
	}
	else {
		printf("\007? looking for 'org' or 'ans'. No action.\n");
		return(ERROR);
	}
	return(OK);
}
#endif

/*
 * Readline from MODEM13.C rewritten to allow much higher
 * baud rates.
 * Timeout is in deciseconds (1/10th's)
 * For top speed, character ready is checked in many places.
 * returns TIMEOUT if kbd character is ready.
 *
 * There are three versions of readline, the first is used if
 * there is a separate register for error conditions. The second
 * is used if error condx are in the same register asrx data ready.
 * The last, and quickest, does not check error conditions.
 */

#ifdef MIREADYERROR
/* Version for 8250, 8251, 2651, etc. with all bits in one register */
readline(decisecs)
{
	if((Mstatus=inportb(Sport))&MIREADYMASK)
		goto getit;
	while(--decisecs>=0) {
		if((Mstatus=inportb(Sport))&MIREADYMASK)
			goto getit;
		if(CDO)
			return TIMEOUT;
		if((Mstatus=inportb(Sport))&MIREADYMASK)
			goto getit;
#ifndef REALSLOWKB
		if(CIREADY) {
			CICHAR;		/* dismiss character */
			return TIMEOUT;
		}
#endif
		if((Mstatus=inportb(Sport))&MIREADYMASK)
			goto getit;
		for(Timeout=T1pause; --Timeout; )
			if((Mstatus=inportb(Sport))&MIREADYMASK) {
getit:
				if(Mstatus&MIERRORMASK) {
					michar();		/* chuck it */
					inportb(Sport);	/* reset err bits */
					return ERROR;
				}
				else
					return michar()&Wcsmask;
			}
	}
	return TIMEOUT;
}
#define READLINE
#endif

#ifndef READLINE
readline(decisecs)
{
	if(miready())
		return michar()&Wcsmask;
	while(--decisecs>=0) {
		if(miready())
			return michar()&Wcsmask;
		if(CIREADY) {
			CICHAR;		/* dismiss character */
			return TIMEOUT;
		}
		if(miready())
			return michar()&Wcsmask;
		for(Timeout=T1pause; --Timeout; )
			if(miready())
				return michar()&Wcsmask;
	}
	return TIMEOUT;
}
#endif

sendline(data)
char data;
{
	while(!MOREADY)
		;
	outportb(MODATA, data&Wcsmask);
}
purgeline()
{
#ifdef MOEMPTY
	while(!MOEMPTY)
		;
#endif
	while(miready())
		michar();
}

/* pmmi autodial routines */

#ifdef AUTODIAL
dial(name)
char *name;
{
	char *s,*n, *cp, c, conflg, ringbk, rung1;
	int chinp, pause;
	cp = name;
	ringbk = FALSE; /* ringback desired */
	rung1 = FALSE;	/* if true, means we've already called once */
	conflg= FALSE;
dagain:	n=cisubstr(name, "\t")+1;
	if((s=cisubstr(name, "\tb"))) {
		printf("\n%s", name);
		printf("\n<Use Control-X to abort>\n");
	}
	else return;
	printf("Waiting for dial tone");
	if(!dtdet()){
		printf(" No dial tone\n");
		onhook();
		return;
	}
	printf("\nDialing -> ");
	while((c=*n) != 'b') {
		printf("%c",c);
		if (c== 'r') ringbk = TRUE;
		if (isdigit(c)) {
			if(click(c) == ERROR) {
			pause = 0;
			goto quitnow;
			}
		}
		++n;
	}

/* if ringback desired let ring only once (more or (less)) */

	if(ringbk && !rung1) {
		printf("  One ringy dingy...\n");
		/* wait 8.5 seconds for ring */
		if(timer(85) == ERROR) {
			setbaud(Baudrate);
			goto quitnow;
		}
		onhook();
		rung1 = TRUE;
		sleep(7); /* wait a sec before dialing again */
		pause = 0;
		goto dagain;
	}

/* number has been dialed now check for an answer */

	printf("\nWaiting for answer ");
	pause=27;		/* 27 seconds */
	outportb(Sport+3,0x7f);
	timer(2);
	outportb(Sport,0x5d);
	while(inportb(Sport+2)&4) {
		printf("\rWaiting for answer: %d ",pause);
		if(timer(10)==ERROR) goto quitnow;
		else pause--;
		if (pause==0) break;
	}
	if(pause == 0) {
		rung1 = FALSE;
		ringbk = FALSE;
		printf("\rHanging up...        ");
		onhook();
		printf("\rNo Answer !! ");
		if (conflg) goto dagain;
		printf(" Call again (Y/N/C)? ");
		chinp=tolower(getchar());
		if (chinp == 'c') {
			conflg = TRUE;
			goto dagain;
		}
		else if (chinp == 'y') goto dagain;
		else return;
	}
	
	printf("\7\n+++ Communications Established +++\7");
	Originate = TRUE;
	if(!setbaud(atoi(s+2)))
		printf("\nBaudrate set to: %u\n", Baudrate);
	if(cmdeq(cp, "cis")) Cis02=TRUE;
	term();
	return(OK);

quitnow: onhook();
	return(OK);
}	

dtdet(){
	int pause;
	pause=20;
	outportb(Sport,1);  /* off hook */
	outportb(Sport+3,0x2f); /* set det filters */
	while(inportb(Sport+2)&1){
		printf(".");
		if(timer(3) == ERROR) pause=0;
		else --pause;
		if(pause==0) return(FALSE);
	}
	return(TRUE);
}

click(num)
char num;
{
unsigned number;
	number = num - '0';
	if (number == 0) number = 10;
	outportb(Sport+2,PPS);
	while(inportb(Sport+2) & 0x80);
	while((inportb(Sport+2)&0x80)^0x80);
	while (number-- ) {
		outportb(Sport,1);
		while(inportb(Sport+2) & 0x80);
		outportb(Sport,0);
		while((inportb(Sport+2)&0x80)^0x80);
	}
	outportb(Sport,1);
	if(CIREADY) {
		if((CICHAR) == 0x18) return(ERROR);
	}
	if(timer(5)==ERROR) return(ERROR);
	return(OK);
}
#endif

/* uses pmmi timer function for delays.  if control-x typed while
 * here, stops and returns with ERROR.
 */

timer(tenths)
int tenths;
{
int pause;
		outportb(Sport+2,0xfa);  /* value for .1 sec timer pulse */
		for(pause = 0;pause < tenths;pause++) {

			/* wait for timer to go low */
			while(!(inportb(Sport+2)&0x80));

			if(CIREADY)
				if((CICHAR) == 0x18) return(ERROR);

			/* wait for timer to go high */
			while(inportb(Sport+2)&0x80);
		}
		return(OK);
}

/* return <> 0 if modem has character(s) ready */
miready()
{
	return(MIREADY);
}

/* return next modem character assuming miready <> 0 */
michar()
{
	return(MICHAR);
}

/* functions to output control strings to terminal */
termreset()
{
	lputs(TERMRESET);
}
terminit()
{
	lputs(TERMINIT);
}
termreplot()
{
	lputs(TERMREPLOT);
}

/*
 * change modem port to n
 */
chngport(n)
{
	printf("PMMI does not support port changes.  ");
	return(ERROR);
}
                                              