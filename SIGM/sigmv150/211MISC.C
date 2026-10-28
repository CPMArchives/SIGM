/************************************************************************/
/*				misc.c					*/
/*									*/
/*	Random functions...						*/
/************************************************************************/

/************************************************************************/
/*				history 				*/
/* 83Jul13 BAK  Looking for Rcpm bug					*/
/* 83Jun11 BAK  Correcting userlog error - forces write of data.	*/
/* 83Mar12 CrT	from msg.c						*/
/* 83Mar03 CrT & SB   Various bug fixes...				*/
/* 83Feb27 CrT	Save private mail for sender as well as recipient.	*/
/* 83Feb23	Various.  transmitFile() won't drop first char on WC... */
/* 82Dec06 CrT	2.00 release.						*/
/* 82Nov05 CrT	Stream retrieval.  Handles messages longer than MAXTEXT.*/
/* 82Nov04 CrT	Revised disk format implemented.			*/
/* 82Nov03 CrT	Individual history begun.  General cleanup.		*/
/************************************************************************/

#include "b:210ctdl.h"

/************************************************************************/
/*				contents				*/
/*									*/
/*	configure()		sets terminal parameters via dialogue	*/
/*	doCR()			newline on modem and console		*/
/*	download()		menu-level routine for WC-protocol sends*/
/*	patchDebug()		display/patch byte			*/
/*	printDate()		prints out date 			*/
/*	putFlChar()		readFile() -> disk file interface	*/
/*	putWCChar()		filter[]s, readFile() to putMsgChar()	*/
/*	transmitFile()		send a host file, no formatting 	*/
/*	tutorial()		prints a .hlp file			*/
/*	upload()		menu-level read-via-WC-protocol fn	*/
/*	visible()		convert control chars to letters	*/
/************************************************************************/

/************************************************************************/
/*	configure() sets up terminal width etc via dialogue		*/
/************************************************************************/
configure() {
   termWidth	= getNumber(" Screen width",	      10, 255);
   termNulls	= getNumber(" #Nulls",		       0, 255);
   termUpper	= getYesNo(" Uppercase only"		    ) ?  UCMASK  :  0;
   termLF	= getYesNo(" Linefeeds" 		    ) ?  LFMASK  :  0;
   termTab	= getYesNo(" Tabs"			    ) ?  TABMASK :  0;
   expert	=!getYesNo(" Helpful hints"		    ) ?  EXPERT  :  0;
   Storelog();
/* Forces write to eliminate phantom configurations... */  
}

/************************************************************************/
/*	doCR() does a newline on modem and console			*/
/************************************************************************/
doCR() {
    int i;

    crtColumn	= 1;
    if (outFlag) return;	/* output is being s(kip)ped	*/

    if (whichIO==CONSOLE || echo==BOTH)   putCh(NEWLINE);
    if (haveCarrier) {
	if (!usingWCprotocol) {
	    outmod('\r');
	    for (i=termNulls;  i;  i--) outmod(0);
	    if (termLF) outmod('\n');
	} else {
	    sendWCChar('\r');
	    if (termLF) sendWCChar('\n');
	}
    }
#ifdef XYZZY
/* test code only */
    else {
	if (usingWCprotocol) {
	    sendWCChar('\r');
	    if (termLF) sendWCChar('\n');
	}
    }
#endif
    prevChar	= ' ';
}

/************************************************************************/
/*	download() is the menu-level send-message-via-WC-protocol fn	*/
/************************************************************************/
download(whichMess, revOrder)
char whichMess, revOrder;
{
    outFlag	= OUTOK;
    if (!expert)   tutorial("wcdown.blb");

    outFlag	= OUTOK;
    if (!getYesNo("Ready"))  return;

    /* here we go: */
    echo		= NEITHER;
    usingWCprotocol	= TRUE	 ;	/* all points bulletin		*/

    SFRunning	= TRUE; 		/* init sendWCChar coroutine	*/
    showMessages(whichMess, revOrder);

    while (sendWCChar(ERROR) == FALSE); /* fill last 128-byte block	*/

    setUp(FALSE);
    usingWCprotocol	= FALSE  ;
}


/************************************************************************/
/*	patchDebug()							*/
/************************************************************************/
patchDebug() {
    unsigned  i, j, page;
    char c, finished, *pc;

    mPrintf("\bpatch\n ");
    page = getNumber("page", 0, 255);
    finished = FALSE;
    do {
	for (i=16, pc= (page*256);  i;	i--)   {
	    mPrintf("%d ", pc);
	    for (j=16;	j;  j--)   {
		mPrintf("%c", visible(*pc++));
	    }
	    mPrintf("\n ");
	}
	switch (toLower(iChar()))   {
	case 'r':
	    pc	= getNumber("adr", 0, 65355);
	    *pc = getNumber("val", 0, 255);
	    break;
	case 'n':	page++; 		break;
	case 'p':	page--; 		break;
	default:	finished = TRUE;	break;
	}
    } while (!finished);
}

/************************************************************************/
/*	printDate() prints out a date packed in two-byte format 	*/
/************************************************************************/
printDate(year, month, day)
char year, month, day;
{
    mprintf("%d%s%02d ", year, monthTab[month], day);
}

/************************************************************************/
/*	putFlChar() is used to upload files				*/
/*	returns: ERROR on problems else TRUE				*/
/*	Globals: msgBuf.mbtext is used as a buffer, to save space	*/
/************************************************************************/
putFlChar(c)
char c;
{
    return  putC(c, msgBuf.mbtext) != ERROR;
}

/************************************************************************/
/************************************************************************/
/*	putWCChar() filter[]s from readFile() to putMsgChar()		*/
/*	Returns: ERROR if problems, else TRUE				*/
/*	Globals: outFlag is set to OUTSKIP when an ascii EOF (^Z) is	*/
/*	    encountered, and no further text is written to disk.	*/
/************************************************************************/
int putWCChar(c)
int c;
{
    if (outFlag)	return TRUE;	/* past ascii EOF.  ignore.	*/

    if (c == ERROR) {
	/* EOF.  Note for overkill:	*/
	outFlag = OUTSKIP;
	return TRUE;
    }

    c	&= 0x7F;	/* cut high stuff off	*/

    if (c == CPMEOF) {
	/* ascii EOF.  Ignore rest of file:	*/
	outFlag = OUTSKIP;
	return TRUE;
    }

    return  putMsgChar(filter[c]);
}

/************************************************************************/
/*	transmitFile() dumps a host file with no formatting		*/
/************************************************************************/
transmitFile(filename)
char *filename;
{
    char mAbort();
    int  getc(), sendWCChar();
    char fbuf[BUFSIZ], fname[NAMESIZE];
    int  c;

    outFlag	= OUTOK;

    unspace(filename, fname);

    if(fopen(fname, fbuf) == ERROR) {
	mprintf("\n No %s.\n", fname);
	return(ERROR);
    }

    doCR();
    if (usingWCprotocol)   {
	SFRunning   = TRUE;
	sendWCChar('\0');	/* warm up routine	*/
    }

    while ((c=getc(fbuf)) != ERROR)  {
	putCh(c);
	if (whichIO == MODEM) {
	    if (!usingWCprotocol)	outMod(c)    ;
	    else			sendWCChar(c);
	}
	if (textDownload  &&  c==CPMEOF)   break;
	if (textDownload  &&  mAbort() )   break;
    }

    if (usingWCprotocol)   while (sendWCChar(ERROR) == FALSE);

    fClose(fbuf);
}

/************************************************************************/
/*	tutorial() prints file <filename> on the modem & console	*/
/*	Returns:	TRUE on success else ERROR			*/
/************************************************************************/
#define MAXWORD 256
tutorial(filename)
char *filename;
{
    char fbuf[BUFSIZ];
    char line[MAXWORD];
    int  toReturn;

    toReturn	= TRUE;

    outFlag	= OUTOK;
    if(fopen(filename, fbuf) == ERROR) {
	mPrintf("\n No %s.\n", filename);
	toReturn	= ERROR;
    } else {
	if (!expert)   mPrintf("\n <J>ump <P>ause <S>top\n");
	mPrintf(" \n");
	while (fGetS(line, fbuf))   mPrintf("%s", line);
	fClose(fbuf);
    }

    return   toReturn;
}

/************************************************************************/
/*	upLoad() enters a file into current directory			*/
/************************************************************************/
upLoad() {
    char fileName[NAMESIZE], *s;
    int putFlChar();

    getString("filename", fileName, NAMESIZE);
    normalizeString(fileName);

    if (fileName[1] != ':')   s = &fileName[0];
    else		      s = &fileName[2];


    setSpace(roomBuf.rbdisk, roomBuf.rbuser);

    if(fOpen(s, msgBuf.mbtext) != ERROR) {
	mprintf("\n A %s already exists.\n", s);
    } else {
	if (!expert) {
	    setSpace(homeDisk, homeUser);
	    tutorial("wcupload.blb");
	    setSpace(roomBuf.rbdisk, roomBuf.rbuser);
	}
	if (fCreat(s, msgBuf.mbtext) == ERROR) {
	    mprintf("\n Can't create %s!\n", s);
	} else {

	    readFile(putFlChar);

	    fFlush(msgBuf.mbtext);
	    fClose(msgBuf.mbtext);
	}
    }
    setSpace(homeDisk, homeUser);
}

/************************************************************************/
/*	visible() converts given char to printable form if nonprinting	*/
/************************************************************************/
char visible(c)
char c;
{
    if (c==0xFF)  c = '$'	;   /* start-of-message in message.buf	*/
    c		    = c & 0x7F	;   /* kill high bit otherwise		*/
    if ( c < ' ') c = c + 'A' -1;   /* make all control chars letters	*/
    if (c== 0x7F) c = '~'	;   /* catch DELETE too 		*/
    return(c);
}
