/*
>>:yam2.c 9-6-83
 * Ward Christensen Protocol handler for sending and receiving
 * ascii and binary files.  Modified for choice of checksum or crc.
 */

#define EXTERN extern
#include "yamc86.h"
#define WCEOT (-10)

#ifdef DEFBYTL
long Modtime;		/* Unix style mod time for incoming file */
int Filemode;		/* Unix style mode for incoming file */
#endif

wcsend(argc, argp)
char **argp;
{
	int wcs();

	Crcflg=FALSE;
	firstsec=TRUE;
	if (Batch) {
#ifdef XMODEM
		printf("Sending in Batch Mode\n");
#endif
		if (expand(wcs, argc, argp)==ERROR)
			goto fubar;
		if (wctxpn("")==ERROR)
			goto fubar;
	}
	else {
		for (; --argc>=0;) {
			if (opentx(*argp++)==ERROR)
				goto fubar;
			if (wctx()==ERROR)
				goto fubar;
		}
	}
	return OK;
fubar:
	closetx(TRUE);
	canit();
	return ERROR;
}

wcs(name)
char *name;
{
	if (opentx(name)==ERROR)
		return OK;		/* skip over inaccessible files */
	if (wctxpn(name)== ERROR)
		return ERROR;
	if (wctx()==ERROR)
		return ERROR;
	return OK;
}


wcreceive(argc, argp)
char **argp;
{
	if (Batch || argc==0) {
		printf("Receiving in Batch Mode\n");
		for (;;) {
			if (wcrxpn(Utility.ubuf)== ERROR)
				goto fubar;
			if (Utility.ubuf[0]==0)
				return OK;
			procheader(Utility.ubuf);
			if (wcrx(Utility.ubuf)==ERROR)
				goto fubar;
		}
	}
	else
		for (; --argc>=0;) {
#ifdef DEFBYTL
			procheader(0);
#endif
#ifdef XMODEM
			printf("Receive:'%s' FILE OPEN\n", *argp);
#endif
			if (wcrx(*argp++)==ERROR)
				goto fubar;
		}
	return OK;
fubar:
	canit(); closerx(TRUE); return ERROR;
}
/*
 * Fetch a pathname from the other end as a C ctyle ASCIZ string.
 * Length is indeterminate as long as less than blklen
 * a null string represents no more files
 */
wcrxpn(rpn)
char *rpn;	/* receive a pathname */
{
	purgeline(); Crcflg = (Wcsmask==0377);
	firstsec=TRUE;
#ifdef STATLINE
	lpstat("Fetching pathname");
#else
	lprintf("Fetching pathname ");
#endif
	totsecs = -1;
	if (wcgetsec(rpn, 100, Crcflg?WANTCRC:NAK) != 0)
		return ERROR;
	sendline(ACK);
#ifndef STATLINE
	lprintf("\r                   \r");
#endif
	return OK;
}

wctxpn(name)
char *name;
{
	char *p, *q;

	totsecs = -1;
#ifdef STATLINE
	pstat("Awaiting pathname NAK");
#else
	lprintf("Awaiting pathname NAK ");
#endif
	if ((firstch=readline(400))==TIMEOUT)
		return ERROR;
	if (firstch==WANTCRC)
		Crcflg=TRUE;
	/* don't send drive specification */
	for(p=name, q=Utility.ubuf; *p; )
		if((*q++ = *p++) == ':')
			q = Utility.ubuf;
	while(q < Utility.ubuf + KSIZE)
		*q++ = 0;
	if (wcputsec(Utility.ubuf, 0, SECSIZ)==ERROR) {
		lprintf("Can't send pathname %s\n", name);
		return ERROR;
	}
#ifndef STATLINE
	lprintf("\r                               \r");
#endif
	return OK;
}

/*
 * Adapted from CMODEM13.C, written by
 * Jack M. Wierda and Roderick W. Hart
 */

wcrx(name)
char *name;
{
	int sendchar, sectnum, sectcurr;
#ifdef DEFBYTL
	int cblklen;			/* bytes to dump this block */
#endif

	if (openrx(name)==ERROR)
		return ERROR;
	firstsec=TRUE; totsecs=sectnum=0; sendchar=Crcflg?WANTCRC:NAK;

	for (;;) {
#ifdef STATLINE
		if (!Quiet)
			pstat("Sector %3d %2dk", totsecs, totsecs/8 );
#else
		if (!Quiet && !View)
			lprintf("\rSector %3d %2dk ", totsecs, totsecs/8 );
#endif
		purgeline();
		sectcurr=wcgetsec(Utility.ubuf, (sectnum&0177)?70:130,
		  sendchar);
		if (sectcurr==(sectnum+1 &Wcsmask)) {

			sectnum++;
/*
 * if the compiler supports longs && the o/s records the
 *  exact length of files then and only then use the file length
 *  info (if transmitted).
 */
#ifdef DEFBYTL
#ifdef BYTEFLENGTH
			wcj = cblklen = Bytesleft>blklen ? blklen:Bytesleft;
#else
			wcj = cblklen = blklen;
#endif
#else
			wcj = blklen;
#endif
			for (cp=Utility.ubuf; --wcj>=0; )
				if (fputc(*cp++, fout)==ERROR) {
					lprintf("\nDisk Full\n");
					return ERROR;
				}
#ifndef XMODEM
			if (View) {
#ifdef DEFBYTL
				wcj = cblklen;
#else
				wcj = blklen;
#endif
				for (cp=Utility.ubuf;--wcj>=0;)
					putchar(*cp++);
			}
#endif
#ifdef DEFBYTL
			if ((Bytesleft -= cblklen) < 0)
				Bytesleft = 0;
#endif
			totsecs += blklen/128; sendchar=ACK;
		}
		else if (sectcurr==sectnum) {
			wcperr("received dup Sector\n");
			sendchar=ACK;
		}
		else if (sectcurr==WCEOT) {
			sendline(ACK);
			/* don't pad the file any more than it already is */
			closerx(FALSE);
			return OK;
		}
		else if (sectcurr==ERROR)
			return ERROR;
		else {
			lprintf(" Sync Error: got %d\n", sectcurr);
			return ERROR;
		}
	}
}

/*
 * wcgetsec fetches a Ward Christensen type sector.
 * Returns sector number encountered or ERROR if valid sector not received,
 * or CAN CAN received
 * or WCEOT if eot sector
 * time is timeout for first char, set to 4 seconds thereafter
 ***************** NO ACK IS SENT IF SECTOR IS RECEIVED OK **************
 *    (Caller must do that when he is good and ready to get next sector)
 */

wcgetsec(rxbuf, time, sendchar)
char *rxbuf;
int time;
{
	int sectcurr;

	for (Lastrx=errors=0; errors<RETRYMAX; ++errors, ++toterrs) {
		if(CIREADY && getcty()==CAN)
			return ERROR;

		sendline(sendchar);	/* send it now, we're ready! */
		purgeline();

		if ((firstch=readline(time))==STX) {
			blklen=KSIZE; goto get2;
		}
		if (firstch==SOH) {
			blklen=SECSIZ;
get2:
			sectcurr=readline(50);
			if ((sectcurr+readline(50))==Wcsmask) {
				oldcrc=checksum=0;
				for (cp=rxbuf,wcj=blklen; --wcj>=0; ) {
					if ((firstch=readline(50)) < 0)
						goto bilge;
					oldcrc=updcrc(firstch, oldcrc);
					checksum += (*cp++ = firstch);
				}
				if ((firstch=readline(50)) < 0)
					goto bilge;
				if (Crcflg) {
					oldcrc=updcrc(firstch, oldcrc);
					if ((firstch=readline(50)) < 0)
						goto bilge;
					oldcrc=updcrc(firstch, oldcrc);
					if (oldcrc)
						wcperr("Bad CRC=0%o\n",
						  oldcrc);
					else {
						firstsec=FALSE;
						return sectcurr;
					}
				}
				else if (((checksum-firstch)&Wcsmask)==0) {
					firstsec=FALSE;
					return sectcurr;
				}
				else
					wcperr("Checksum Bad rx=0%o cx=0%o\n",
					 firstch, checksum);
			}
			else
				wcperr("Sector number garbled\n");
		}
		/* make sure eot really is eot and not just mixmash */
		else if (firstch==EOT && readline(2)==TIMEOUT)
			return WCEOT;
		else if (firstch==CAN) {
			if (Lastrx==CAN) {
				wcperr("Sender CANcelled\n");
				return ERROR;
			} else {
				Lastrx=CAN;
				continue;
			}
		}
		else if (firstch==TIMEOUT) {
bilge:
			wcperr("Timeout\n");
		}
		else if (firstch==ERROR)
			wcperr("Modem SR=0%o\n", Mstatus);
		else
			wcperr("Got 0%o sector header\n", firstch);
		Lastrx=0;
		while (readline(2)!=TIMEOUT)
			;
		if (firstsec)
			sendchar = Crcflg?WANTCRC:NAK;
		else {
			time=40;
			sendchar = NAK;
		}
	}
	/* try to stop the bubble machine. */
	canit(); return ERROR;
}

/*VARAGRS*/
wcperr(s,p)
char *s, *p;
{
	lprintf("Sector %3d error %d: ", totsecs, errors);
	lprintf(s, p);
}

wctx()
{
	int sectnum;

	firstsec=TRUE; totsecs=0;
#ifdef STATLINE
	pstat("Awaiting initial NAK");
#else
	lprintf("Awaiting NAK");
#endif
	while ((firstch=readline(400))!=TIMEOUT && firstch != WANTCRC
	  && firstch!=NAK && firstch!=CAN)
		lprintf("%c", firstch);	/* let user see it if strange char */
	if (firstch==CAN)
		return ERROR;
	if (firstch==WANTCRC)
		Crcflg=TRUE;
	sectnum=1;
	while (filbuf(Utility.ubuf, blklen)) {
		totsecs += (blklen/128);
		if (!Quiet
#ifdef STATLINE
		)
			pstat("Sector %3d %2dk", totsecs, totsecs/8 );
#else
		&& !View)
			lprintf("\rSector %3d %2dk ", totsecs, totsecs/8 );
#endif
		if (wcputsec(Utility.ubuf, sectnum, blklen)==ERROR) {
			return ERROR;
		} else {
			if (View)	/* View can't be set in xyam */
				for (cp=Utility.ubuf,wcj=blklen;--wcj>=0;)
					putchar(*cp++);
			sectnum++;
		}
	}
	closetx(FALSE);
	for (errors=0; ++errors<RETRYMAX; ) {
		sendline(EOT);
		purgeline();
		if(readline(100) == ACK)
			return OK;
	}
	wcperr("No ACK on EOT\n");
	return ERROR;
}

wcputsec(txbuf, sectnum, cseclen)
char *txbuf;
int sectnum;
int cseclen;	/* data length of this sector to send */
{
	firstch=0;	/* part of logic to detect CAN CAN */

	for (errors=0; errors <= RETRYMAX; ++errors, ++toterrs) {
		Lastrx= firstch;
		sendline(cseclen==KSIZE?STX:SOH);
		sendline(sectnum);
		sendline(-sectnum-1);
		oldcrc=checksum=0;
		for (wcj=cseclen,cp=txbuf; --wcj>=0; ) {
			sendline(*cp);
			oldcrc=updcrc(*cp, oldcrc);
			checksum += *cp++;
		}
		if (Crcflg) {
			oldcrc=updcrc(0,updcrc(0,oldcrc));
			sendline(oldcrc>>8);sendline(oldcrc);
		}
		else
			sendline(checksum);
		if(CIREADY && getcty()==CAN)
			goto cancan;
		purgeline();

		/* ignore bullshit line noise, esp. braces from 212's */
		switch(firstch=readline(100)) {
		case CAN:
			if(Lastrx==CAN) {
cancan:
				lprintf("\nReceiver CANcelled\n");
				return ERROR;
			}
			break;
		case ACK|0200: 
		case ACK: 
			firstsec=FALSE;
			return OK;
		case TIMEOUT:
			wcperr("Timeout on sector ACK\n"); break;
		case WANTCRC:
			if (firstsec)
				Crcflg=TRUE;
		case NAK:
			wcperr("NAK on sector\n"); break;
		default:
			wcperr("Got 0%o for sector ACK\n", firstch); break;
		}
		for (;;) {
			Lastrx=firstch;
			if ((firstch=readline(3))==TIMEOUT)
				break;
			if (firstch==CAN && Lastrx==CAN)
				goto cancan;
			/* let user see it if strange char */
			lprintf("%c", firstch);
		}
	}
	wcperr("No ACK on sector; Abort\n");
	return ERROR;

}
/* send 10 CAN's to try to get the other end to shut up */
canit()
{
	for (wcj=10; --wcj>=0; )
		sendline(CAN);
}

/*
 * process incoming header
 */
procheader(name)
char *name;
{
	register char *p;

#ifdef DEFBYTL
	/* set default parameters */
	Bytesleft = DEFBYTL; Filemode = 0666; Modtime = 0L;
#endif

	if (name) {
		p = name + 1 + strlen(name);
		if (*p) { 	/* file coming from Unix type system */
#ifdef DEFBYTL
			sscanf(p, "%ld%lo%o", &Bytesleft, &Modtime, &Filemode);
#else
			lprintf("%s ", p);
#endif
		}
	}
	return OK;
}
                                                                                                                         