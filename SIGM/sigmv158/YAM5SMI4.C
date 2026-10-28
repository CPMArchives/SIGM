/*
>>:yam5smdm.c 12-14-83
 *
 * Smartmodem routines by Herb Schultz
 *
 * CompuPro Interfacer 3 / 4 serial board routines by Paul Homchick
 *
 * Computer Innovations C86 Version
 */

#define EXTERN extern
#include "yamc86.h"

#define MODEMSTUFF
/*
 * setbaud(nbaud) If legal rate, set modem registers and Baudrate
 */
setbaud(nbaud)
unsigned nbaud;
{
	int command, baudcmd, mode0, mode1;
	mode0=0xee;	/* 16x rate 2 stop bits below 300bps */
	mode1=0x6e;	/* 16x rate 1 stop bit at and above 300bps */
	command=0x27;
	switch(nbaud) {
	case   50: baudcmd=0x30;break;
	case   75: baudcmd=0x31;break;
	case  110: baudcmd=0x32;break;
	case  134: baudcmd=0x33;break;
	case  150: baudcmd=0x34;break;
	case  300: baudcmd=0x35;break;
	case  600: baudcmd=0x36;break;
	case 1200: baudcmd=0x37;break;
	case 1800: baudcmd=0x38;break;
	case 2000: baudcmd=0x39;break;
	case 2400: baudcmd=0x3A;break;
	case 3600: baudcmd=0x3B;break;
	case 4800: baudcmd=0x3C;break;
	case 7200: baudcmd=0x3D;break;
	case 9600: baudcmd=0x3E;break;
	case 19200: baudcmd=0x3F;break;
	default:
		return ERROR;
	}
	outportb(GBI4U,MDMU);
	if(nbaud<300)
		outportb(GBI4M,mode0);
	else
		outportb(GBI4M,mode1);
	outportb(GBI4M,baudcmd);
	outportb(GBI4C,command);
	Baudrate=nbaud;
	return OK;
}
/* fetch the baudrate from the modem port */
readbaud()
{
unsigned inbyt;
	outportb(GBI4U,MDMU);
	inportb(GBI4M)&0xFF;
	inbyt=(inportb(GBI4M)&0x0f);
	switch(inbyt) {
	case   0: Baudrate=50;break;
	case   1: Baudrate=75;break;
	case   2: Baudrate=110;break;
	case   3: Baudrate=134;break;
	case   4: Baudrate=150;break;
	case   5: Baudrate=300;break;
	case   6: Baudrate=600;break;
	case   7: Baudrate=1200;break;
	case   8: Baudrate=1800;break;
	case   9: Baudrate=2000;break;
	case  10: Baudrate=2400;break;
	case  11: Baudrate=3600;break;
	case  12: Baudrate=4800;break;
	case  13: Baudrate=7200;break;
	case  14: Baudrate=9600;break;
	case  15: Baudrate=19200;break;
	default:
		break;
	}
	return Baudrate;
}

/* Bye hangs up the line and then resets for another call */

bye()
{
	onhook();
	sleep(10*CLKMHZ);
	setbaud(Baudrate);
}


sendbrk()
{
	unsigned char dp3;

	outportb(GBI4U,MDMU);
	dp3=inportb(GBI4C);
	outportb(GBI4C, 0x2f);	/* set line to spacing */
	sleep(CLKMHZ);
	outportb(GBI4C, dp3);	/* return to marking */
}

#define AUTODIAL
sendcmd(cp)
char *cp;
{
	while (*cp)
		sendline(*cp++);
}

onhook()
{
	sleep(8 * CLKMHZ);
	sendcmd(SMATTN);
	sleep(8 * CLKMHZ);
	purgeline();
	sendcmd(SMHUP);
}

/*
 *  flip - toggle Smodem to auto-answer mode
 *  Not the original intention of flip. This routine
 *  hasn't been tested so tread with care.
 */
flip(argc,argp)
int argc;
char **argp;
{
	int rcnt,r;

	if (argc != 1) {
oops:		printf("\007usage: flip [org | ans | auto]\n");
		return ERROR;
	}
	if(strcmp("org", argp[0]) == 0 || strcmp("ans", argp[0]) == 0) {
		printf("Sorry: this version of flip can't do that");
		return(OK);
	}
	else if (strcmp("auto", argp[0]) == 0) {
		puts("(^X Aborts) Waiting for Ring: ");
		for (rcnt = 0; ++r <= NRING;)
			if (result() > 0)
				printf("\nRing #%d", r);
			else
				return(OK);
		/* got the rings, go on line */
		sendcmd(SMTOANS);
		if (result() != OK) {
			puts("\nAnswer Error\n");
			return(OK);
		}
		Originate = FALSE;
		/* You may want to turn on echo here, I haven't (yet?) */
		term();
		return(OK);
	}
	else
		goto oops;
	return OK;
}

dial(name)
char *name;
{
	char *ncp,*s,*n, num[40];
	unsigned nbaud;

	Originate = TRUE;
	ncp = name;
	n=cisubstr(name, "\t")+1;

	/* I have a line "*SmodemPhones\t*" in my PHONES.T which allows me to
	 * do a 'call *' from the command line to have it ask for the number
	 */
	if (*n == '*') { 
		puts("Number to dial: ");
		gets(num);
		if (!*num)
			return (OK);
	}
	else {
		for (s = num; (*s = *n++) != '\t' && *s; ++s)
			;
		*s = '\0';
	}
	
	/* dial a * option number at the set baud rate! */
	nbaud = ((s = cisubstr(name, "\tb")) ? atoi(s + 2) : Baudrate);
	/* dial at 300 unless baud rate >= 1200 */
	setbaud((nbaud < 1200) ? 300 : nbaud);
	
	purgeline();		/* dump any garbage */
	sendcmd(SMATTN);
	sendcmd(SMCMD);		/* use extended command set */
	sendcmd(SMDIAL);
	sendcmd(num);
	sendline('\r');
	printf("(^X aborts) Dialing -> %s\n", num);
	if (result() != OK)
		return (OK);
	if (nbaud < 1200 && nbaud > 300)
		setbaud(nbaud);	/* reset to desired baud rate */
	printf("\n++ On Line ++ Baudrate = %d ++\n\7", Baudrate);
	if(cmdeq(ncp,"cis")) Cis02=TRUE;
	term();
	return (OK);
}

result()
{
	unsigned char rcode;
	unsigned nbaud;
	
	sleep(10 * CLKMHZ); /* let the dial get out before allowing abort */
	while (!MIREADY) {
		if (CIREADY && CICHAR == '\30') {
			puts("Aborting");
			sendline('\r');
			return (ERROR);
		}
	}	
	switch ((rcode = MICHAR)) {
	  case '5':
		nbaud = 1200;
		setbaud(1200);
	  case '1':
		readline(2 * CLKMHZ);	/* get rid of extra '\r' */
		return (OK);
	  case '3':
		puts("No Carrier\n");
		return (ERROR);
	  case '2':
		return (1);	/* if (result() > 0) then ring */
	  default:
		printf("Dial error, return code = %c\n", rcode);
		return (ERROR);
	}
}


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
	if((Mstatus=i4rs(MDMU))&MIREADYMASK)
		goto getit;
	while(--decisecs>=0) {
		if((Mstatus=i4rs(MDMU))&MIREADYMASK)
			goto getit;
#ifdef CDO
		if(CDO)
			return TIMEOUT;
#endif
		if((Mstatus=i4rs(MDMU))&MIREADYMASK)
			goto getit;
#ifndef REALSLOWKB
		if(CIREADY) {
			CICHAR;		/* dismiss character */
			return TIMEOUT;
		}
#endif
		if((Mstatus=i4rs(MDMU))&MIREADYMASK)
			goto getit;
		for(Timeout=T1pause; --Timeout; )
			if((Mstatus=i4rs(MDMU))&MIREADYMASK) {
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

/*
 * change modem port to n
 */
chngport(n)
int n;
{
	if(n < 0 || n > 7) {
		printf("\7User request for %d out of range (0 - 7).  ",n);
		return(ERROR);
	}
	MDMU=n;
	readbaud();
}

/*
 * Routines to handle modem status checking and i/o
 * when using Godbout Interfacer 4 board
 */

#ifdef CDO
/* value = 0 if carrier there
 * set up to use parallel port on if4
 * to monitor Cx line from modem
 */

i4cd()
{
	outportb(GBI4U,0x06);
	return((inportb(GBI4M)&0x01)-0x01);
}
#endif

/* read status */

i4rs(puser)
unsigned char puser;
{
	outportb(GBI4U,puser);
	return(inportb(MSTAT));
}

/* read data */

i4rd(puser)
unsigned char puser;
{
	outportb(GBI4U,puser);
	return(inportb(MDATA));
}

/* send data */

i4sd(puser,x)
unsigned char puser,x;
{
	outportb(GBI4U,puser);
	outportb(MDATA, x);
}

#ifdef USERINIT

/* initialize special externals */

userinit()
{
	MDMU=MUSER;
#ifdef IF3CON
	CONU=CUSER;
#endif
}
#endif

/* return <> 0 if modem has character(s) ready */
miready()
{
	return MIREADY;
}

/* return next modem character assuming miready <> 0 */
michar()
{
	return MICHAR;
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
              