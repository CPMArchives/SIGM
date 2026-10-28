/*
>>:yam3.c 8-12-83
 *
 * two-way conversation with remote -whatever.
 * Printer is buffered such that it needn't be as fast as the baudrate
 * as long as it eventually gets a chance to catch up.
 * This buffering also allows one to write the received data out to disk
 * after the conversation has started.
 */
#define EXTERN extern
#include "yamc86.h"

#define SAYTERM 2	/* doykbd returns this if sayterm needed */

term()
{
	register c, cc;
	unsigned charsent;

	Lskcnt=lkbufcq=0;
	sayterm();
	charsent=0;
#ifdef SCREAMER
	if (Baudrate>SCREAMER && !Tfile && !Rfile && !Ctlview && (abptr==0)) {
		yterm(Sport, Dport, &Lskcnt, &bufcq, bufst, bufend, &Wrapped);
		bufcdq=bufcq;
		return;
	}
#endif
	Waitecho=Txwait=FALSE;
	for (;;) {
#ifdef CDO
		if (CDO) {
			lprintf("\nCarrier Lost");
			return ERROR;
		}
#endif
		if (miready()) {
			*bufcq = michar();
			Timeout=0;
			if (++bufcq >= bufend)
				Wrapped=bufcq=bufst;
			if (!Jovemode) {
				if (--Nfree == LOWWATER)
					MODOUT(Xoffflg=XOFF);
				else if (Nfree==0)
					goto belch;
			}
			continue;
		}
		if (COREADY && bufcdq != bufcq) {
			switch((cfast=(checksum= *bufcdq) & 0177)) {
#ifdef EXPANDTABS
			case '\t':
				TTYOUT(' ');
				if (++Ttycol & 07)
					continue;
				else
					goto chuckit;
#endif
#ifdef MYSYSTEM
			case SI:
				if (Cis02) {

					if (++bufcdq >= bufend)
						bufcdq=bufst;
					cispa(); sayterm(); continue;
				}
				else
					goto showcc;
			case '\f':
				if (Cis02) {	/* clr screen on ff */
					lprintf(CLEARS);
					Ttycol=0; goto chuckit;
				}
				/* ####### FALL THRU TO ###### */
#endif
			case '\n':
				++Lskcnt;
				/* ####### FALL THRU TO ###### */
			case '\r':
				Ttycol=0; break;
			case XON:
				Txgo=TRUE; 
				if (Tfile) {
					sayterm();
					goto chuckit;
				}
				goto showcc;
			case XOFF:
				Txgo=FALSE;
				if (Tfile) {
					sayterm();
					goto chuckit;
				}
				goto showcc;
			case ENQ:
				if (Twxmode)
					setab();
				goto showcc;
#ifdef EXPANDTABS
			case '\b':
				if (Ttycol)
					--Ttycol;
				break;
#endif
#ifdef XMODEM
			case ETX:
			case EOT:
			case CPMEOF:
				if (++bufcdq >= bufend)	/* discard char */
					bufcdq=bufst;
				while (readline(3)!=TIMEOUT)
					;	/* discard anything else */
				dumprxbuff(); closerx(TRUE);
				printf("%d bytes received\n", bufcdq-bufst);
				clearbuff();
				return OK;
			case 007:
				break;
#endif
showcc:
			default:
				if (Ctlview) {
					if (checksum & 0200) { /* 8th bit */
						if (Ctlview>1) {
							TTYOUT('~');
#ifdef EXPANDTABS
							++Ttycol;
#endif
						}
					}
					if (cfast>='~') { /* for ~ and rub */
						TTYOUT('^');
						TTYOUT(cfast-0100);
#ifdef EXPANDTABS
						Ttycol += 2;
#endif
						goto chuckit;
					}
					else if (cfast<040) { /* control char */
						TTYOUT('^');
						TTYOUT(cfast|0100);
#ifdef EXPANDTABS
						Ttycol += 2;
#endif
						goto chuckit;
					}
				}
#ifdef EXPANDTABS
				if (cfast>037)
					++Ttycol;
#endif
				break;
			}
			if (cfast==GOchar && Txeoln==EOL_CRPROMPT)
				Waitecho=FALSE;

#ifdef RXNONO
			if ( !index(cfast, RXNONO))
#endif
				TTYOUT(cfast);
			if (Echo) {
				sendline(cfast);
				if (Chat && cfast== '\r') {
					TTYOUT('\n');
#ifndef XMODEM
					sendline('\n');
#endif
				}
			}
chuckit:
			if (++bufcdq >= bufend)
				bufcdq=bufst;
#ifndef KBDNOW
			continue;
#endif
		}
		if (CIREADY)
			switch(doykbd(CICHAR)) {
			case TRUE:
				return OK;
			case SAYTERM:
				sayterm();
			}
		if (Pflag && bufpcdq!=bufcq && POREADY) {
			LPOUT(*bufpcdq++ & 0177);
			if (bufpcdq >= bufend)
				bufpcdq=bufst;
		}
		if (MOREADY) {
			if (abptr && !Txwait && !Waitecho && (Txgo||Twxmode)) {
				if (abptr>=abend) {
					abptr=NULL;
					if (Exoneof && (!Twxmode))
						return OK;
				}
				else {
					c= *abptr++; goto offwithit;
				}
			}
			if (Tfile && !Txwait && !Waitecho && Txgo) {
				/*
				 * If receiving an echo term would emit dc3
				 * when the buffer fills up. Can't allow that.
				 */
				if (Nfree < (LOWWATER+50))
					dumprxbuff();
				c= getc(fin);
#ifdef CPM
				if (c==EOF || (c==CPMEOF && Txeoln != TX_BINARY))
#else
				if (c==EOF)
#endif
				{
					closetx(FALSE);
#ifdef XMODEM
					pstat(" "); return OK;
#else
					if (Exoneof)
						return OK;
					sayterm(); continue;
#endif
				}
				if (Twxmode)
					switch(c) {
					case ACK:
						setab();
					case CPMEOF:
						continue;
					case XOFF:
						Txgo = FALSE; sayterm(); break;
					case ENQ:
						/* force wait for response */
						Txgo = FALSE; break;
					}
offwithit:
				echochr(c);	/* handle local echo */
				if (Waitbunch && ++charsent==Waitnum) {
					charsent=0;
					if (Waitnum>1) {
						Waitecho=TRUE; Timeout=0;
					} else {
						Txwait=TRUE;
						Txtimeout=Throttle;
					}
				}

				if (c=='\r') {	/* end of line processing */
					switch(Txeoln) {
					case EOL_NL:
						continue;
					case EOL_CRPROMPT:
					case EOL_CRWAIT:
						Waitecho=TRUE; Timeout=0;
					case EOL_CR:
						if ((cc=getc(fin))!='\n')
							ungetc(cc, fin);
						break;
					}
				}
				MODOUT(c);
				continue;
			}
		}
		if (++Timeout == Tpause) {
			Waitecho=FALSE;
belch:
			if (Xoffflg) {
				dumprxbuff();
				if (miready()) {
					lprintf("\n\007OVERRUN: DATA LOST");
					return ERROR;
				}
				if (bufcdq != bufcq)
					continue;
				if (Pflag && bufpcdq != bufcq)
					continue;
				Xoffflg=FALSE;
				MODOUT(XON);
			}
		}
		if (--Txtimeout==0)
			Txwait=FALSE;
	}
}



#ifdef LINKPORT
/*
 * The term function stripped down for top speed at max baudrate
 *  to allow linking of two computers.
 */

dolink()
{
	chngport(LHPORT);
	lpstat("Linking 0%o to 0%o", Dport, LIDPORT);
	for (;;) {
#ifndef REALSLOWKB
		if (CIREADY)
			switch(doykbd(CICHAR)) {
			case TRUE:
				return OK;
			}
#endif
#ifdef LCDO
		if (LCDO) {
			purgeline(); LICHAR;
			continue;
		}
#endif
checkrx:
		while (miready()) {
			*bufcq = michar();
			if (++bufcq >= bufend)
				Wrapped=bufcq=bufst;
		}
		if (LOREADY && bufcdq != bufcq) {
#ifndef REALSLOWKB
			TTYOUT(*bufcdq);
#endif
			LOUT(*bufcdq);
			if (++bufcdq >= bufend)
				bufcdq=bufst;
			goto checkrx;
		}
		if (LIBREAK) {
			clearbuff();
			sendbrk();
			CLRLIBREAK;
		}
		if (LIREADY) {
			sendline(cfast=LICHAR);
			switch (cfast) {
			case 0177:
			case 003:
				clearbuff();
			}
		}
	}
}
#endif

setab()
{
	abptr = ANSWERBACK;
	abend = abptr + strlen(abptr);
	Waitecho = Txwait = FALSE;
}

/* display the appropriate status information */
sayterm()
{
	termreset();
	if (Tfile)
		lpstat("Sending '%s' %s", Tname, Txgo?"":"Stopped by XOFF");
	if (Rfile) {
		pstat("Term Receiving '%s'", Rname); Jovemode=FALSE;
	}
	else if (Jovemode)
		pstat("Term: Jove Mode");
	else
		pstat("Term Function  ");
#ifdef XMODEM
	if (Rfile) {
		printf("Transmit File. Characters will NOT be echoed\n");
		printf("When file has been sent, close it by typing ^Z\n");
	}
#endif
}

/* open a capture file and set the removal pointer to get max goods */
opencapt(name)
char *name;
{
	if (Rfile) {
		dumprxbuff(); closerx(TRUE);
	}
	if (openrx(name)==ERROR)
		return ERROR;
	if (buffcdq<bufst)
		buffcdq=bufst;
	if (Wrapped)
		buffcdq=bufcq+1;
	if (buffcdq >= bufend)
		buffcdq=bufst;
/*	dumprxbuff(); */
	return OK;
}


/*
 * Dump the contents of capture buffer to receive file (if any).
 */
dumprxbuff()
{
	Nfree=Bufsize-1;
	if (!Rfile || buffcdq==NULL)
		return OK;
	while (buffcdq != bufcq) {
		Lastrx= *buffcdq++;
		if (buffcdq >= bufend)
			buffcdq=bufst;
		if (!Image) {
			switch(Lastrx &= 0177) {
			case 0:
				continue;
			case '\n':
				putc( '\r', fout); break;
			case '\r':
				continue;
			case 032:		/* ^Z or CPMEOF */
				if (Zeof) {
					closerx(TRUE);
					return OK;
				}
				else
#ifdef CPM
					continue;
#else
					break;
#endif
			case 022:
				if (Squelch) {
					Dumping=TRUE;
					continue;
				}
				break;
			case 024:
				if (Squelch) {
					Dumping=FALSE;
					continue;
				}
				break;
			default:
				break;
			}
		}
		if (Dumping || Image)
			if (fputc(Lastrx, fout)==ERROR) {
				lprintf("\nDisk Full");
				closerx(FALSE);
				return ERROR;
			}
	}
	return OK;
}

rewindcb()
{
	bufcdq=buffcdq=bufpcdq=Wrapped?bufcq+1:bufst;
}

/*
 * replot redisplays the buffer contents thru putcty allowing XOFF
 * number will represent how many lines to go back first 
 */
replot(number)
{
	char doexit;
	int count, shorts;
	char *smark, *p;

	doexit=FALSE;
	termreplot();
	if (lkbufcq && (Lskcnt >= (TLENGTH-2))) {
		number=3; shorts=0; reptr=bufmark=lkbufcq; goto f2;
	}
fromtop:
	smark=bufmark=Wrapped?bufcq+1:bufst;
	shorts=0;

	if (number) {
		reptr=bufcq;
f2:
backsome:
		for (;;) {
			--reptr;
			if (reptr<bufst) {
				if (Wrapped)
					reptr= bufend-1;
				else {
					reptr=bufst;
					break;
				}
			}
			if (reptr==bufcq)
				break;
			if (((cfast=(*reptr&0177))=='\n' || cfast==ESC)
			 && --number<=0)
				break;
		}
		bufmark=reptr;
	}
	reptr=bufmark;
	/* backing up is confusing unless screen is cleared first */
	termreplot();
nextscreen:
#ifdef T4014
	/* Do the big flash on the 4014 or 4012 */
	lputs("\033\014");
	sleep(CLKMHZ * 5);
#endif
	count=TLENGTH - shorts -1;
	shorts =0;
nextline:
	while (reptr != bufcq) {
		if ((cfast=(*reptr & 0177))==ESC && --count<0 && !doexit)
			break;
		if (++reptr >= bufend)
			reptr=bufst;
		if (Lastrx=putcty(cfast))
			goto choose;
		if (cfast=='\n' && --count<=0 && !doexit)
			break;
	}

	if (doexit) {
#ifdef STATLINE
		return SAYTERM;
#else
		termreset();
		return FALSE;
#endif
	}
#ifdef STATLINE
	pstat("%s Replot cmd? %s", INTOREV, OUTAREV);
#else
#ifdef INTOREV
	lprintf("%s Replot cmd? %s", INTOREV, OUTAREV);
#else
	lputs("Replot cmd? ");
#endif
#endif
	Lastrx=getcty();
#ifdef STATLINE
	pstat(" ");
#else
	lputs(CLEARL);
#endif
choose:
	/* Treat Control chars and letters the same */
	switch((Lastrx|0140)&0177) {
	case 'x':
		doexit=TRUE;
#ifdef NOSCROLL
		number=(TLENGTH+2);
#else
		number=(TLENGTH<<2);
#endif
		reptr=bufcq; goto backsome;
	case 'v':	/* control-v or v */
	case 'h':	/* backspace */
		number=(TLENGTH-2); reptr=bufmark; goto backsome;
	case 0140:		/* space bar */
		shorts=2; bufmark=reptr; goto nextscreen;
	case 'o':
		pstat(" "); putcty('/'); smark=reptr;
		gets(Utility.ubuf); uncaps(Utility.ubuf);
		/* FALL THROUGH TO */
	case 'n':
		if ((p=cisubstr(smark, Utility.ubuf)) && p<bufend) {
			smark = 1+ (bufmark=reptr=p);	/* +1 so n can work */
			number=1;
			goto backsome;
		} else
			putcty(007);
		/* FALL THROUGH TO */
	case 'b':
		number=0; goto fromtop;
	case 'p':
		number=1; reptr=bufmark; goto backsome;
	case 'k':
		clearbuff(); lprintf(CLEARS); return SAYTERM;
	case 'z':
		/*
		 * kill the "rest" of the buffer
		 * N.B.: if buffcdq or bufpcdq is between reptr and bufcq,
		 * yam will try to output the whole memory space
		 * when use of these pointers resumes.
		 */
		bufcdq=bufcq=reptr; return SAYTERM;
	case 'j':	/* linefeed */
		bufmark=reptr; count=1; goto nextline;
	default:
		return SAYTERM;
	}
}

/*
 * moment waits a moment and returns FALSE, if no character keyboarded in
 * the meantime, otherwise returns TRUE.
 */
moment()
{
	int c;
	for (c=MOMCAL; --c>0;)
		if (CIREADY) {
			getcty(); return TRUE;
		}
	return FALSE;
}
dochat()
{
#ifdef XMODEM
	printf("Ring My Chimes, Maybe I'll Come\n");
	printf("Exit chat with ^Z\n");
#endif
	Chat=Ctlview=Hdx=Echo=TRUE;
	term();
}

echochr(c)
{
	if (Hdx) {
		while (!COREADY)
			;
		TTYOUT(c);
	}
	if (Twxmode && Hdx) {
		if (Rfile) {
			dumprxbuff();
			if (fputc(c, fout)==ERROR) {
				lprintf("\nDisk Full");
				closerx(FALSE);
			}
		}
		if (Pflag)
			LPOUT(c);
	}
}

/*
 * Handle keyboarded character. Returns TRUE iff caller should return to
 *  command mode.
 */
doykbd(cf)
{
	cf &= KBMASK;
#ifdef FNXEXT
	switch (cf) {
		case FNXEXT:
			pstat(" "); return TRUE;
		case FNXREP:
			return replot((TLENGTH<<1)-1);
	}
#endif
	if (Exitchar) {
		if (Exitchar==cf)
			return TRUE;
		Lskcnt=0; lkbufcq=bufcq;
	}
	else switch (cf) {
#ifdef ESCCAL
		case ESC:		/* buffer rapid escape sequences */
			abend = abptr = Utility.ubuf;
			for (Lskcnt=ESCCAL; --Lskcnt;)
				if (CIREADY) {
					*abend++ = CICHAR;
					Lskcnt=ESCCAL;
				}
			sendline(ESC);  return(Waitecho = Txwait = FALSE);
#endif
		case ENQ:
			if (moment())	/* ^E exits [y]term */
				break;
			pstat(" "); return TRUE;
		case 026:
			if (moment())
				break;
			return replot((TLENGTH<<1)-1);
		case BRKKEY:		/* BRK KEY sends break */
			sendbrk();
			while (CIREADY)
				getcty();	/* discard garbage */
			return FALSE;
		case ACK:
			if (Twxmode) {
				setab(); return FALSE;
			}
			break;
		case XON:
			if (Tfile && !Txgo) {
				Txgo=TRUE; return SAYTERM;
			}
			break;
		case XOFF:
			if (Tfile && Txgo) {
				Txgo=FALSE; return SAYTERM;
			}
			break;
		case '\r':
			Lskcnt=0; lkbufcq=bufcq;
			if (Txeoln==EOL_NL)
				cf = '\n';
			else {
				echochr('\r');
				sendline('\r');
				echochr('\n');
				if (Chat)
					sendline('\n');
				return FALSE;
			}
			break;
		case 0177:
		case 003:
			break;	/* don't set lkbufcq, etc. */
		default:
			Lskcnt=0; lkbufcq=bufcq; break;
		}
	sendline(cf);  echochr(cf);  return FALSE;
}

/*
 * send a file (ascii) waiting Throttle/10 seconds for an echo
 *  to each character.  Useful for sending files to pip file=tty:
 */
sendecho()
{
	for (;;) {
		purgeline();
		switch (firstch=getc(fin)) {
		case EOF:
			closetx(FALSE);
			return OK;
		case '\r':
			if (Txeoln == EOL_NL) {
				putcty('\r'); continue;
			}
			break;
		case '\n':
			if (Txeoln == EOL_CR) {
				putcty('\n'); continue;
			}
			break;
		case CPMEOF:
			if (Txeoln == TX_BINARY)
				break;
			if (Txeoln != EOL_NL)
				sendline(CPMEOF);
			return OK;
		}
		sendline(firstch);
		while ((wcj=readline(Throttle)) != firstch) {
			if (wcj == ' ' && firstch == '\t' ) {
				while (readline(1) != TIMEOUT)
					;
				break;
			}
			if (CIREADY || wcj == TIMEOUT) {
				closetx(TRUE); return ERROR;
			}
		}
		putcty(wcj);
	}
}
                                                                                                           