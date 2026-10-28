/*
>>:yam1.c  12-14-83 (file revision date excluding VERSION)
 * Mainline for yam
 * CI C86 version
 */

#define VERSION "4.26x Rev 12-14-83"

#define EXTERN extern
#include "yamc86.h"
#define MAXARGS 20

main(argc, argv)
char **argv;
{
	int c, srstatus;
	char *args[MAXARGS], **argp, **argq, *nextcmd;
	char buffer[8];

	nextcmd=NULL;
	printf("Yet Another Modem by Chuck Forsberg\n");
	printf("%s %s\n", FLAVOR, Version=VERSION);
	printf("(C86 version by Paul Homchick)\n");
	onceonly();
	init();
	if(argc>MAXARGS)
		goto usage;
	/* copy given arguments to our own array */
	for(argp=argv,argq=args,c=argc; --c>=0;)
		*argq++ = *argp++;
	termreset();
	for(;;) {
		if(argc < 2) {
			if(nextcmd)
				cp=nextcmd;
			else {
				if(Onetrip) {
#ifdef USEREXIT
					userexit();
#endif
					exit(0);
				}
#ifdef XMODEM
				printf("\nxYAM(%c%d)", defdisk+'A', user);
#else
				printf("\n>>>%c%d:", defdisk+'a', user);
#endif
				gets(cmdbuf);
				termreset();
				cp=cmdbuf;
#ifdef SYSFUNC
				if(*cp=='!') {
					system(++cp);
					continue;
				}
#endif
/*
 * Check for *text... which sends the rest of the line to
 * the modem
 */
				if((*cp)=='*') {
					abptr= ++cp;
					abend= cp + strlen(cp);
/*  Add proper end of line stuff according to Txeoln */
					switch(Txeoln) {
					case EOL_CR:
					case EOL_CRWAIT:
					case EOL_CRPROMPT:
						*abend++ = '\r'; break;
					case EOL_NOTHING:
					case TX_BINARY:
						*abend++ = '\r';
					case EOL_NL:
						*abend++ = '\n'; break;
					}
					Exoneof=TRUE;
					term();
					continue;
				}
			}
			if(nextcmd=index(';', cp))
				*nextcmd++ =0;	/*  ; separates commands */
			else if(nextcmd=index('\\', cp))
				*nextcmd++ =0;	/*  \ separates commands */

			argp= &args[1]; argc=1;
			for(;;) {
				if(isgraphic(*cp)) {
					*argp++ = cp;
					argc++;
					while(isgraphic(*cp))
						cp++;
				}
				while(*cp==' ' || *cp=='\t')
					*cp++ =0;
				if(*cp > ' ')
					continue;
				*cp=0;
				break;
			}
		}
		for(argp= &args[1]; --argc>0; ) {
			uncaps(*argp);
			cp= *argp++;

			Gototerm=Batch=Crcflg=Creamfile=Echo=Ctlview=
			  Chat=UsePutchar=View=Quiet=FALSE;
			blklen=SECSIZ; Wcsmask = 0377;
#ifdef DEFBYTL
			Bytesleft=DEFBYTL;
#endif
#ifdef CPM
			if(index(':', cp)) {
				chdir(cp);
				continue;
			}
#endif
			switch(*cp++) {
			case 'b':
#ifdef BBSPROG
				if(cmdeq(cp, "bs")) {
					cp=4; *cp=0;	/* reset user/driv */
					exec(BBSPROG);
				}
#endif
				if(cmdeq(cp, "ye")) {
#ifdef BYEPROG
					cp=4; *cp=0;	/* reset user/driv */
					exec(BYEPROG);
#else
					bye();
					continue;
#endif
				}
				else if(*cp == 'r') {
					sendbrk(); continue;
				}
				else if(setbaud(atoi(cp)))
					goto usage;
				continue;
			case 'c':
#ifndef RESTRICTED
				if(cmdeq(cp, "all") && --argc >=1) {
					Jovemode=Exitchar=Pflag=FALSE;
					Cis02=Twxmode=Image=Waitbunch
					 =Exoneof=Hdx=Zeof=Squelch=FALSE;
					Txgo=TRUE;
					Txeoln=EOL_NOTHING;
					uncaps(*argp);	/* make name lcase */
					if(getphone(*argp++,Phone)==ERROR)
						goto usage;
					else if(dial(Phone)==ERROR)
						goto usage;
					continue;
				}
#endif
				if(cmdeq(cp, "hat")) {
					dochat();
					continue;
				}
#ifdef BIGYAM
				if(cmdeq(cp, "hek")) {
					docrc( --argc, argp);
					argc=0; continue;
				}
				if(cmdeq(cp, "rck")) {
					docrck( --argc, argp);
					argc=0; continue;
				}
#endif
				if(cmdeq(cp, "lose")) {
					dumprxbuff();
					closerx(TRUE); closetx(TRUE);
					continue;
				}
				goto usage;
			case 'd':
				if(cmdeq(cp, "ir")) {
#ifndef CDOS
					if(cp[2])
						docomp(--argc, argp);
					else
#endif
						dodir(--argc, argp);
					argc=0; continue;
				}
#ifdef BIGYAM
				else if (cmdeq(cp, "ump")) {
					dodumph( --argc, argp);
					argc=0; continue;
				}
#endif
				else if(setval(0)==ERROR)
					goto usage;
				continue;
			case '-':
			case 'e':
				if(cmdeq(cp, "ra")) {
#ifdef RESTRICTED
					goto nono;
#else
					doerase( --argc, argp); argc=0;
					continue;
#endif
				}
				if(setval(~0)==ERROR)
					goto usage;
				continue;
			case 'f':
#ifdef FLIP
				if(cmdeq(cp, "lip")) {
					if(flip( --argc, argp)==ERROR)
						goto usage;
					continue;
				}
#endif
				closetx(TRUE);
				if(setval(~0)==ERROR)
					goto usage;
				if(--argc<=0 || opentx(*argp++)==ERROR)
					goto usage;
#ifndef XMODEM
				if(Echo)
					psxfer(sendecho());
				else
#endif
				  if (Twxmode)
					Txgo = FALSE;
				else {
					/* frame file with ^R T if Squelch */
					if(Squelch)
						sendline(022);
					term();
					if(Squelch)
						sendline(024);
				}
				continue;
			case 'i':
				if(cmdeq(cp, "nit")) {
					init(); argc=0; nextcmd=0; continue;
				}
				else
					goto usage;
			case '?':
			case 'h':
				listfile(HELPFILE); continue;
			case 'k':
				if(cmdeq(cp, "ill")) {
					clearbuff();
					continue;
				}
				else
					goto usage;
			case 'l':
				if(cmdeq(cp, "ist")) {
					++UsePutchar;
listit:
					dolist( --argc, argp);
					termreset();
					argc=0; continue;
				}
#ifdef LINKPORT
				if(cmdeq(cp, "ink")) {
					dolink(); continue;
				}
#endif
				else
					goto usage;
#ifndef RESTRICTED
			case 'm':
#ifdef BBSPROG
				if(cmdeq(cp, "inirbbs")) {
					cp=4; *cp=0;	/* reset user/driv */
					exec(BBSPROG);
				}
#endif
				closetx(TRUE);
				if (chngport(atoi(cp))==ERROR)
					goto usage;
				continue;
#endif
			case 'o':
				termreset();
#ifdef BYEPROG
				cp=4; *cp=0;	/* reset user/driv */
#endif
				onhook();
				if(cmdeq(cp, "ff")) {
					dumprxbuff();
					closerx(TRUE); closetx(TRUE);
#ifdef USEREXIT
					/* we do not wany any interrupts */
					purgeline(); userexit();
#endif
					exit(0);
				}
				printf("On Hook"); continue;
			case 'p':
				if(setparm(cp)==ERROR)
					goto usage;
				continue;
			case 'r':
#ifdef BBSPROG
				if(cmdeq(cp, "bbs")) {
					cp=4; *cp=0;	/* reset user/driv */
					exec(BBSPROG);
				}
#endif
				if(cmdeq(cp, "eset")) {
					terminit();
					closetx(TRUE);
					dumprxbuff(); closerx(TRUE);
#ifdef CPM
					bdos(13,0);bdos(14,defdisk);
					printdfr();
#endif
					/* change buffer size for debugging */
					if(--argc>0) {
						bufend= bufst + atoi(*argp++);
						clearbuff();
						dostat();
					}
					continue;
				}
				if(cmdeq(cp, "ep")) {
					replot(argc>1 ? (--argc,atoi(*argp++)) : 0);
					continue;
				}
				if(cmdeq(cp, "ew")) {
					rewindcb(); continue;
				}
				if(chkbvq()==ERROR)
					goto usage;
				if(argc<2)
					Batch=TRUE;
				psxfer(srstatus=(wcreceive(--argc, argp)));
#ifdef RESTRICTED
				if(srstatus==ERROR) {
					unlink(Rname);
					printf("%s removed\n");
				}
#endif
				if(Gototerm)
					term();
				argc=0; continue;
			case 's':
#ifdef BIGYAM
				if (cmdeq(cp, "um")) {
					dosum( --argc, argp);
					argc=0; continue;
				}
#endif
				if(*cp == 0 && argc==1) {
					dostat();
					continue;
				}
				if(argc<2 || chkbvq()==ERROR)
					goto usage;
				if( argc > 2
				  || index('?',*argp) || index('*',*argp))
					Batch=TRUE;
#ifdef XMODEM
				/* tell 'em how long it will take! */
				if(Batch)
					docomp(argc-1, argp);
#endif
				psxfer(wcsend(--argc, argp));
				if(Gototerm)
					term();
				argc=0; continue;
#ifndef XMODEM
			case 'u':
				if(cmdeq(cp, "nix")) {
					term(); continue;
				}
				goto usage;	/* trap "user 0" */
#endif
			case 't':
				if(cmdeq(cp, "ype"))
					goto listit;
				if(--argc > 0) {
					if(opencapt(*argp++)==ERROR)
						goto usage;
				}
				switch(setval(~0)) {
				case ERROR:
					goto usage;
				case OK:
					term();
				case TRUE:
					break;
					/* remain in command mode if t..c  */
				}
				continue;
			/* note: case u precedes T */
			case 'w':
#ifdef BIGYAM
				if (cmdeq(cp, "c")) {
					dowc( --argc, argp);
					argc=0; continue;
				}
#endif
				dumprxbuff(); continue;
			case 'x':
				/* in case user typed "XMODEM ..." */
				if(*cp)
					continue;
				dumprxbuff();
				closerx(TRUE); closetx(TRUE);
#ifdef USEREXIT
				userexit();
#endif
				exit(0);
			case 0:
			default:
				goto usage;
			}
		}
		continue;
#ifdef RESTRICTED
nono:
		printf("Command not allowed\n");
#endif
usage:
		printf("Type HELP");
		nextcmd=0; argc=0; continue;
	}
}

chkbvq()
{
	while(*cp)
		switch(*cp++) {
		case '7':
			Wcsmask = 0177; break;
		case 'b':
			Batch=TRUE; break;
		case 'c':
			Crcflg=TRUE; break;
		case 'k':
			blklen=KSIZE; break;
		case 'q':
			Quiet=TRUE; break;
#ifndef RESTRICTED
		case 't':
			Gototerm=TRUE; break;
		case 'v':
			View=TRUE; break;
		case 'y':
			Creamfile=TRUE; break;
#endif
		default:
			return ERROR;
		}
	return FALSE;
}
setval(value)
unsigned value;
{
	FLAG dumped;
	dumped=FALSE;
	while(*cp)
		switch(*cp++) {
		case '!':
			value = 0; break;
		case '2':
			Cis02=value; break;
		case 'a':
			Chat=value; break;
		case 'b':
			Txeoln= value&TX_BINARY; Txmoname="BINARY"; break;
		case 'c':
			dumprxbuff(); closerx(dumped=TRUE); break;
		case 'd':
			Dumping= !Squelch || value; break;
		case 'e':
			Echo=value; break;
		case 'f':
			Hdx= !value; break;
		case 'g':
			Txgo= value; break;
		case 'h':
			Hdx=value; break;
		case 'i':
			Image=value; break;
		case 'j':
			if (value && Exitchar==0)
				Exitchar = 037;
			if (!value)
				Exitchar = 0;
			Jovemode=value; break;
		case 'k':
			blklen=KSIZE; break;
		case 'l':
			Pflag=value; break;
		case 'n':
			Txeoln =value&EOL_NL; Txmoname="NL ONLY"; break;
		case 'o':
			Onetrip=value; break;
		case 'p':
			Txeoln =value&EOL_CRPROMPT;
			Txmoname="WAIT FOR PROMPT"; break;
		case 'q':
			Twxmode = value; break;
		case 'r':
			Txeoln =value&EOL_CR; Txmoname="CR ONLY"; break;
		case 's':
			Dumping = !(Squelch=value); break;
		case 't':
			Waitbunch=value; break;
		case 'v':
			Ctlview++; break;
		case 'w':
			Txeoln= value&EOL_CRWAIT;
			Txmoname="CR WAIT FOR NL"; break;
		case 'x':
			Exoneof=value; break;
		case 'z':
			Zeof=value; break;
		default:
			return ERROR;
		}
	return dumped;
}

clearbuff()
{
	lkbufcq=abptr=NULL;
	Xoffflg=Wrapped= FALSE;
	buffcdq=bufcq=bufcdq=bufpcdq=bufmark= bufst;
	Bufsize=Nfree= bufend-bufst-1;
}

dostat()
{

		printf("Yam %s Capture %s Receiving %s ",
		 Version, Dumping?"ON":"SQUELCHED", Rfile?Rname:"<nil>");
		if(Image)
			printf("Transparency mode ");
		if(Squelch)
			printf("^R ^T Squelch ");
		if(Zeof)
			printf("EOF on ^Z");
		printf("\n");

	if(Txeoln==EOL_NOTHING)
		Txmoname="normal";

	printf("%sSending %s in %s mode\n",
	 Txgo? "" : "Pausing in ", Tfile?Tname:"<nil>", Txmoname);
	printf("%sWaiting %d loops every %u chars  Pause=%u GOchar=0%o\n",
	 Waitbunch?"":"NOT ",Throttle, Waitnum, Tpause, GOchar);

	printf("Printer %s  ", Pflag?"ON":"OFF");
	if(Hdx)
		printf("Half Duplex ");
#ifdef INT3
	printf("At %u baud data port %u, rel user %u\n", Baudrate, Dport, MDMU);
#else
	printf("At %u baud data port %u\n", Baudrate, Dport);
#endif
	printf("%u of %u chars used %u free%s\n",
	  Bufsize-Nfree, Bufsize, Nfree, Wrapped?" POINTERS WRAPPED":"");
/*
	printf("bufst=%x bufcq=%x bufcdq=%x buffcdq=%x bufpcdq=%x bufend=%x\n",
	 bufst, bufcq, bufcdq, buffcdq, bufpcdq, bufend);
*/
	if (toterrs) {
		printf("%u Total errors detected\n", toterrs);
		toterrs = 0;
	}
#ifndef CDOS
	printdfr();
#endif
}

isgraphic(c)
{
	if(c>' ' && c<0177)
		return TRUE;
	else
		return FALSE;
}

/*
 * index returns a pointer to the first occurrence of c in s,
 * NULL otherwise.
 */
char *index(c, s)
char c,*s;
{
	for(; *s; s++)
		if(c== *s)
			return s;
	return NULL;
}
psxfer(status)
{
#ifdef XREM
	printf("File transfer(s) ");
#else
	printf("\007File transfer(s) ");
#endif
	if (status==ERROR)
		printf("ABORTED BY ERROR\n\007");
	else {
		printf("successful\n");
		termreset();
	}
#ifndef CDOS
	printdfr();
#endif
}

setparm(p)
char *p;
{
	if ( !isdigit(p[1]))
		return ERROR;
	firstch = atoi(p + 1);		
	switch(*p) {
	case 'e':
		Exitchar= firstch; break;
	case 'g':
		GOchar= firstch; break;
	case 'p':
		Tpause=firstch; break;
	case 't':
		Throttle=firstch; break;
	case 'w':
		Waitnum=firstch; break;
	default:
		return ERROR;
	}
	return 0;
}

/* make string s lower case */
uncaps(s)
char *s;
{
	for( ; *s; ++s)
		*s = tolower(*s);
}
                                                                                                                             