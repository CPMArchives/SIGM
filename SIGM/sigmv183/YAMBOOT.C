/* YAMBOOT.C by Steve Passe (Cnode SYSOP), 1981
	
   Modifications for Australian
   conditions by Bill Bolton (Software Tools SYSOP), 1982

This program uses the "Christensen" MODEM7/YAM protocol for file
transfers.  To receive a  type '<esc>', you will be prompted for
the file name. (<esc> is the ASCII escape character: ^[).

Add whatever code necessary to the initialize_port() function (setup your
port for 8 bits, 1 stop bit, baud rate of 300 if necessary, etc.).
Using a serial modem you will have to make changes of port addresses and
masks in the #ifdef modem area. There is a define CLKMHZ which should
be set to the clock rate for your CPU.

This program uses large chunks of the YAM package for file transfers, 
(thanks Chuck).

If you feel you need additional documentation try looking at the start
of CMODEM.C which you may find relevant (or not). YAMBOOT should
come straight up if you have BDSCIO.H set up correctly for your
hardware, certainly if you have TELNET running. 

The strange stuff you see on the screen while it is running is normal,
I didn't say it was pretty, only that it works!!!

*/

#include "bdscio.h"		/* Must have modem defines setup */

#define SOH 0x01
#define EOT 0x04
#define ACK 0x06
#define NAK 0x15
#define CAN 0x18
#define RETRYMAX 10
#define TIMEOUT (-1)
#define PATHLEN 20
#define WCEOT (-2)
#define CLKMHZ 4		/* CPU speed in Mhz */

#define CONSTAT 2
#define CONIN 3
#define DIR_IO 0x06		/* You have to have CP/M 2.2 */
#define INPUT 0xff
#define FLAG char

int Baud;
FLAG Rfile;
char Rname[PATHLEN];
unsigned T1pause, Timeout;
char File_buf[BUFSIZ];
char Checksum, Lastrx;
int Wcj, Firstch;

main()
{
	char received, to_send, in_modem(), getch(), escflag;
	Rfile = FALSE;
	T1pause = 311*CLKMHZ;
	escflag = NULL;
	Baud = 300;
	initialize_port();
	printf("\n\tYAMBOOT in the style of MBOOT.\n\n");
	while (TRUE) {
		if (received = in_modem()) putch(received);
		else if (to_send = getch())
			(to_send == ESC) ? download():out_modem(to_send);
	}
}
char
in_modem()
{
	if (inp(MSTAT) & MIMASK) return inp(MDATA);
	else return FALSE;
}
out_modem(out_char)
char out_char;
{
	while (!(inp(MSTAT) & MOMASK))	;
	outp(MDATA, out_char);
}
char
getch()
{
	return bdos(DIR_IO, INPUT);
}

/*

	Most of the following functions taken from YAM package by
Chuck Forsberg, BDS C UG disk Utilities 3, some modifications made for
compatibility with cnode code.

*/

download(filename)
char *filename;
{
	printf("\n\n\tReceive: ");
	scanf("%s", Rname);
	printf("ready to receive '%s'\n", Rname);
	if(wcrx(Rname)==ERROR) {
		abort();
	}
	return OK;
}

/* Adapted from CMODEM13.C, by Jack M. Wierda and Roderick W. Hart */
wcrx(name)
char *name;
{
	int sectnum, sectcurr, sectcomp;
	char *cp, rxbuf[128], sendchar;
	if(openrx(name)==ERROR)
		return ERROR;
	sectnum=0;
	sendchar=NAK;
	for(;;) {
		out_modem(sendchar);
		sectcurr=wcgetsec(rxbuf, (sectnum & 0x7f) ? 50 : 130);
		if(sectcurr==(sectnum+1 & 0xff)) {
			sectnum++;
			for(cp=rxbuf,Wcj=128; --Wcj>=0; )
				if(putc(*cp++, File_buf)==ERROR) {
					printf("\nDisk Full\n");
					return ERROR;
				}
			sendchar=ACK;
		}
		else if(sectcurr==sectnum) {
			printf("\nReceived dup Sector %d",sectcurr);
			sendchar=ACK;
		}
		else if(sectcurr==WCEOT) {
			out_modem(ACK);
			closerx(FALSE);
			return OK;
		}
		else {
			printf(" Sync Error\n");
			return ERROR;
		}
	}
}
wcgetsec(rxbuf, time)
char *rxbuf;
int time;
{
	int sectcurr,errors;
	char *cp;

	for(Lastrx=errors=0; errors<RETRYMAX; errors++) {
		do {
			Firstch=readbyt(time);
		}
		while(Firstch != SOH && Firstch != TIMEOUT && Firstch != EOT
			  && Firstch != CAN);	/* wait for one of these */
		if(Firstch==SOH) {
			sectcurr=readbyt(1);
			if((sectcurr+readbyt(1))==255) {
				Checksum=0;
				for(cp=rxbuf,Wcj=128; --Wcj>=0; ) {
					isprint(*cp = readbyt(1)) ? putchar(*cp) : putchar('.');
					Checksum += (*cp++);
				}
				if(((Checksum-readbyt(1))& 0xff)==0)
					return sectcurr;
				else
					printf("Checksum Error #%d", errors);
			}
			else
				printf("Sector number garbled #%d", errors);
		}
		else if(Firstch==EOT)
			return WCEOT;
		else if(Firstch==CAN) {
			if(Lastrx==CAN) {
				printf("\nSender CANcelled");
				return ERROR;
			} else {
				Lastrx=CAN;
				continue;
			}
		}
		else if(Firstch==TIMEOUT)
			printf("\nSOH Timeout #%d", errors);
		Lastrx=0;
		while(readbyt(1)!=TIMEOUT)
			;
		out_modem(NAK);
		time=40;
	}
	out_modem(CAN);out_modem(CAN);out_modem(CAN);
	return ERROR;
}
openrx(name)
char *name;
{
	printf("\nSaving it as '%s'", name);
	if(fopen(name, File_buf) != ERROR) {
		fclose(File_buf);
		printf("\nI already have one, try another name");
		return ERROR;
	}
	if(fcreat(name, File_buf)==ERROR){
		printf("\nCan't create '%s'", name);
		return ERROR;
	}
	Rfile= TRUE;
	return OK;
}
readbyt(decisecs)
int decisecs;
{
	if (inp(MSTAT) & MIMASK)
		return inp(MDATA);
	while (--decisecs >= 0) {
		if (inp(MSTAT) & MIMASK)
			return inp(MDATA);
		if (bdos(DIR_IO, INPUT))
			return TIMEOUT;
		if (inp(MSTAT) & MIMASK)
			return inp(MDATA);
		for (Timeout = T1pause; --Timeout; )
			if (inp(MSTAT) & MIMASK)
				return inp(MDATA);
	}
	return TIMEOUT;
}
abort()
{
	out_modem(CAN);out_modem(CAN);out_modem(CAN);
	return ERROR;
}
closerx()
{
	if(Rfile) {
		fflush(File_buf);
		fclose(File_buf);
		printf("\n\n%s closed", Rname);
		Rfile=FALSE;
	}
}
purgeline()
{
	while (inp(MSTAT) & MIMASK)
		inp(MDATA);
}

/* end of code from yam */

initialize_port()
{
	/* put your modem port intialisation code here, you may NOT need
	   it if you are CERTAIN that the port will be initialised
	   correctly before entering BOOTMODM */
}

isprint(c)
char c;
{
  return (c >= ' ' && c <= '~') || (c == 0x0d) || (c == 0x0a) || (c==0x09);
}

/* END OF YAMBOOT */
