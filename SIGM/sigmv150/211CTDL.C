/************************************************************************/
/*				ctdl.c					*/
/*		Command-interpreter code for Citadel			*/
/************************************************************************/
#include "b:210ctdl.h"
/************************************************************************/
/*				history 				*/
/* 83Jul14 BAK	...							*/
/* 83Jun11 BAK  Edited to fix <typo>.hlp problem.  			*/
/* 83Mar08 CrT	Aide-special functions installed & tested...		*/
/* 83Feb24 CrT/SB Menus rearranged.					*/
/* 82Dec06 CrT	2.00 release.						*/
/* 82Nov05 CrT	removed main() from room2.c and split into sub-fn()s	*/
/************************************************************************/
/************************************************************************/
/*				Contents				*/
/*									*/
/*	doAide()		handles Aide-only commands		*/
/*	doChat()		handles C(hat)		command 	*/
/*	doEnter()		handles E(nter) 	command 	*/
/*	doGoto()		handles G(oto)		command 	*/
/*	doHelp()		handles H(elp)		command 	*/
/*	doKnown()		handles K(nown rooms)	command 	*/
/*	doLogin()		handles L(ogin) 	command 	*/
/*	doLogout()		handles T(erminate)	command 	*/
/*	doRead()		handles R(ead)		command 	*/
/*	doRegular()		fanout for above commands		*/
/*	doSysop()		handles sysop-only commands		*/
/*	getCommand()		prints prompt and gets command char	*/
/*	greeting()		System-entry blurb etc			*/
/*	main()			has the central menu code		*/
/************************************************************************/

/************************************************************************/
/*	doAide() handles the aide-only menu				*/
/*	    return FALSE to fall invisibly into default error msg	*/
/************************************************************************/
char doAide(moreYet, first)
char moreYet;
char first;	/* first parameter if TRUE		*/
{
    char oldName[NAMESIZE];
    int  rm;

    if (!aide)	 return FALSE;

    if (moreYet)   first = '\0';

    mprintf("ide special fn: ");

    if (first)	   oChar(first);

    switch (toUpper(   first ? first : iChar()	  )) {
    case 'D':
	mPrintf("elete empty rooms\n ");
	strCpy(oldName, roomBuf.rbname);
	indexRooms();

	if ((rm=roomExist(oldName)) != ERROR)	getRoom(rm,    &roomBuf);
	else					getRoom(LOBBY, &roomBuf);

	sprintf(msgBuf.mbtext, "Empty rooms deleted by %s", logBuf.lbname);
	aideMessage( /* noteDeletedMessage== */ FALSE );
	break;
    case 'E':
	mprintf("dit room\n  \n");
	strCpy(oldName, roomBuf.rbname);
	if (!renameRoom())   break;
	sPrintf(
	    msgBuf.mbtext,
	    "%s> edited to %s> by %s",
	    oldName,
	    roomBuf.rbname,
	    logBuf.lbname
	);
	aideMessage( /* noteDeletedMessage == */ FALSE);
	break;
    case 'I':
	mPrintf("nsert message\n ");
	if (
	    thisRoom   == AIDEROOM
	    ||
	    pulledMLoc == ERROR
	)   {
	    mPrintf("nope!");
	    break;
	}
	note2Message(pulledMId, pulledMLoc);
	putRoom(thisRoom, &roomBuf);
	noteRoom();
	sPrintf(
	    msgBuf.mbtext,
	    "Following message inserted in %s> by %s",
	    roomBuf.rbname,
	    logBuf.lbname
	);
	aideMessage( /* noteDeletedMessage == */ TRUE);
	break;
    case 'K':
	mPrintf("ill room\n ");
	if (
	    thisRoom == LOBBY
	    ||
	    thisRoom == MAILROOM
	    ||
	    thisRoom == AIDEROOM
	) {
	    mPrintf(" not here!");
	    break;
	}
	if (!getYesNo("confirm"))   break;

	sPrintf(
	    msgBuf.mbtext,
	    "%s> killed by %s",
	    roomBuf.rbname,
	    logBuf.lbname
	);
	aideMessage( /* noteDeletedMessage == */ FALSE);

	roomBuf.rbflags ^= INUSE;
	putRoom(thisRoom, &roomBuf);
	noteRoom();
	getRoom(LOBBY, &roomBuf);
	break;
    case '?':
	tutorial("aide.mnu");
	break;
    default:
	if (!expert)	mprintf(" ?(Type '?' for menu)\n "	);
	else		mprintf(" ?\n " 			);
	break;
    }
    return TRUE;
}

/************************************************************************/
/*	doChat()							*/
/************************************************************************/
doChat(moreYet, first)
char moreYet;	/* TRUE to accept folliwng parameters	*/
char first;	/* first paramter if TRUE		*/
{
    if (moreYet)   first = '\0';

    if (first)	   oChar(first);

    mPrintf("hat ");

    if (noChat)   {
	tutorial("nochat.blb");
	return;
    }

    if (whichIO == MODEM)	ringSysop();
    else			interact() ;
}

/************************************************************************/
/*	doEnter() handles E(nter) command				*/
/************************************************************************/
doEnter(moreYet, first)
char moreYet;	/* TRUE to accept following parameters	*/
char first;	/* first parameter if TRUE		*/
{
#define CONFIGURATION	0
#define MESSAGE 	1
#define PASSWORD	2
#define ROOM		3
#define FILE		4
    char what;			/* one of above five */
    char abort, done, WC;
    char iChar(), toUpper();


    if (moreYet)   first = '\0';

    abort	= FALSE  ;
    done	= FALSE  ;
    WC		= FALSE  ;
    what	= MESSAGE;

    mprintf("nter ");

    if (!loggedIn  &&  !unlogLoginOk  &&  thisRoom!=MAILROOM)	{
	mprintf("--Must log in to enter (except in Mail>)\n ");
	return;
    }

    if (first)	   oChar(first);

    do	{
	outFlag = OUTOK;

	switch (toUpper(   first ? first : iChar()   )) {
	case '\r':
	case '\n':
	    moreYet	= FALSE;
	    break;
	case 'F':
	    if (roomBuf.rbflags & CPMDIR) {
		mprintf("ile upload ");
		what	= FILE;
		done	= TRUE;
		break;
	    }
	default:
	    mprintf("? ");
	    abort	= TRUE;
	    if (expert)  break;
	case '?':
	    tutorial("entopt.mnu");
	    abort	= TRUE;
	    break;
	case 'C':
	    mprintf("onfiguration ");
	    what	= CONFIGURATION;
	    done	= TRUE;
	    break;
	case 'F':
	    mprintf("ile upload "    );
	    WC		= TRUE;
	    done	= TRUE;
	    break;
	case 'M':
	    mprintf("essage "	   );
	    what	= MESSAGE      ;
	    done	= TRUE;
	    break;
	case 'P':
	    mprintf("assword "	   );
	    what	= PASSWORD     ;
	    done	= TRUE;
	    break;
	case 'R':
	    mprintf("oom "	   );
	    if (!nonAideRoomOk && !aide)   {
		mPrintf(" ?-- must be aide to create room\n ");
		abort	= TRUE;
		break;
	    }
	    what	= ROOM	       ;
	    done	= TRUE;
	    break;
	}
	first = '\0';
    } while (!done && moreYet && !abort);

    doCR();

    if (!abort) {
	switch (what) {
	case CONFIGURATION  :	configure()	;	break;
	case MESSAGE	    :	makeMessage(WC) ;	break;
	case PASSWORD	    :	newPW() 	;	break;
	case ROOM	    :	makeRoom()	;	break;
	case FILE	    :	upLoad()	;	break;
	}
    }
}

/************************************************************************/
/*	doGoto() handles G(oto) command 				*/
/************************************************************************/
doGoto(expand, first)
char expand;	/* TRUE to accept following parameters	*/
char first;	/* first parameter if TRUE		*/
{
    char roomName[NAMESIZE];

    mprintf("oto ");

    if (!expand) {
	gotoRoom("");
	return;
    }

    getString("", roomName, NAMESIZE);
    normalizeString(roomName);

    if (roomName[0] == '?')	listRooms(/* doDull== */ TRUE);
    else			gotoRoom(roomName);
}

/************************************************************************/
/*	doHelp() handles H(elp) command 				*/
/************************************************************************/
doHelp(expand, first)
char expand;	/* TRUE to accept following parameters	*/
char first;	/* first parameter if TRUE		*/
{
    char fileName[NAMESIZE];

    if (!expand) {
	mprintf("elp\n \n ");
	tutorial("dohelp.hlp");
	return;
    }

    mprintf("elp ");
    getString("", fileName, NAMESIZE);
    normalizeString(fileName);
    if (fileName[0] == '?'  || strLen(fileName) > 8 ) {
	/*  File names over 8 characters log clobbered bdos in version 2.1 */
	tutorial("helpopt.hlp");
   } else {
	/* adding the extention makes things look simpler for		*/
	/* the user... and restricts the files which can be read	*/
	strcat(fileName, ".hlp");
	tutorial(fileName);
    }
}

/************************************************************************/
/*	doKnown() handles K(nown rooms) command.			*/
/************************************************************************/
doKnown(expand, first)
char expand;	/* TRUE to accept following parameters	*/
char first;	/* first parameter if TRUE		*/
{
    mprintf("nown rooms\n ");
    listRooms(/* doDull== */ TRUE);
}

/************************************************************************/
/*	doLogin() handles L(ogin) command				*/
/************************************************************************/
doLogin(moreYet, first)
char moreYet;	/* TRUE to accept following parameters	*/
char first;	/* first parameter if TRUE		*/
{
    char passWord[NAMESIZE];

    mprintf("ogin ");
    if (!moreYet)   mPrintf("\n");
    if (loggedIn)   {
	mprintf("\n ?Already logged in!\n ");
	return;
    }
    echo	= CALLER;
    getString(moreYet ? "" : " password", passWord, NAMESIZE);
    normalizeString(passWord);
    echo	= BOTH;
    login(passWord);
}

/************************************************************************/
/*	doLogout() handles T(erminate) command				*/
/************************************************************************/
doLogout(expand, first)
char expand;	/* TRUE to accept following parameters	*/
char first;	/* first parameter if TRUE		*/
{
    char iChar(), toUpper();

    if (expand)   first = '\0';

    mprintf("erminate ");

    if (first)	 oChar(first);

    switch (toUpper(	first ? first : iChar()    )) {
    case '?':
	mprintf("\n Logout options:\n \n ");

	mprintf("Quit-also\n "		);
	mprintf("Stay\n "		);
	break;
    case 'Q':
	mprintf("uit-also\n ");
	if (!expand)   {
	   if (!getYesNo("confirm"))   break;
	}
	terminate( /* hangUp == */ TRUE);
	break;
    case 'S':
	mprintf("tay\n ");
	terminate( /* hangUp == */ FALSE);
	break;
    }
}

/************************************************************************/
/*	doRead() handles R(ead) command 				*/
/************************************************************************/
doRead(moreYet, first)
char moreYet;	/* TRUE to accept following parameters	*/
char first;	/* first parameter if TRUE		*/
{
    char iChar(), toUpper();
    int  fileDir(), transmitFile();
    char abort, doDir, done, hostFile, whichMess, revOrder, status, WC;
    char fileName[NAMESIZE];


    if (moreYet)   first = '\0';

    mprintf("\bread ");

    if (!loggedIn  &&  !unlogReadOk)   {
	mPrintf("Must log in to read\n ");
	return;
    }

    if (first)	   oChar(first);

    abort	= FALSE;
    doDir	= FALSE;
    done	= FALSE;
    hostFile	= FALSE;
    revOrder	= FALSE;
    status	= FALSE;
    WC		= FALSE;
    whichMess	= NEWoNLY;

    do {
	outFlag = OUTOK;

	switch (toUpper(   first ? first : iChar()   )) {
	case '\n':
	case '\r':
	    moreYet	= FALSE;
	    break;
	case 'A':
	    mprintf("ll ");
	    whichMess	= OLDaNDnEW;
	    break;
	case 'F':
	    mprintf("orward ");
	    revOrder	= FALSE;
	    whichMess	= OLDaNDnEW;
	    break;
	case 'G':
	    mPrintf("lobal new-messages ");
	    whichMess	= GLOBALnEW;
	    break;
	case 'N':
	    mprintf("ew ");
	    whichMess	= NEWoNLY;
	    break;
	case 'O':
	    mPrintf("ld ");
	    revOrder	= TRUE;
	    whichMess	= OLDoNLY;
	    break;
	case 'R':
	    mprintf("everse ");
	    revOrder	= TRUE;
	    whichMess	= OLDaNDnEW;
	    break;
	case 'S':
	    mprintf("tatus ");
	    status	= TRUE;
	    done	= TRUE;
	    break;
	case 'W':
	    mprintf("C protocol ");
	    WC		= TRUE;
	    break;
	case 'B':
	    if (roomBuf.rbflags & CPMDIR)   {
		mprintf("inary file(s) ");
		done		= TRUE ;
		hostFile	= TRUE ;
		textDownload	= FALSE;
		break;
	    }
	case 'D':
	    if (roomBuf.rbflags & CPMDIR)   {
		mprintf("irectory ");
		doDir	= TRUE;
		done	= TRUE;
		break;
	    }
	case 'T':
	    if (roomBuf.rbflags & CPMDIR)   {
		mprintf("extfile(s) ");
		done		= TRUE;
		hostFile	= TRUE;
		textDownload	= TRUE;
		break;
	    }
	default:
	    mprintf("? ");
	    abort	= TRUE;
	    setUp(FALSE);
	    if (expert)   break;
	case '?':
	    tutorial("readopt.mnu");
	    abort	= TRUE;
	    break;
	}
	first = '\0';
    } while (!done && moreYet && !abort);

    if (abort) return;

    if (status) {
	systat();
	return;
    }

    if (doDir) {
	FDSectCount	= 0;	/* global fileDir() totals sectors in	*/

	getString("", fileName, NAMESIZE);

	normalizeString(fileName);

	if (strLen(fileName))	wildCard(fileDir, fileName);
	else			wildCard(fileDir, "*.*"   );

	mprintf("\n %d sectors total\n ", FDSectCount);
	return;
    }

    if (hostFile) {
	getString("afn", fileName, NAMESIZE);
	normalizeString(fileName);
	usingWCprotocol = WC;
	wildCard(transmitFile, fileName);
	usingWCprotocol = FALSE;
	return;
    }

    doCR();
    if (WC) {
	download(whichMess, revOrder);
	return;
    }

    if (whichMess != GLOBALnEW)   {
	showMessages(whichMess, revOrder);
    } else {
	while (outFlag != OUTSKIP   &&	 gotoRoom(""))	 {
	    givePrompt();
	    mPrintf("read new\n ");
	    showMessages(NEWoNLY, revOrder);
	}
    }
}

/************************************************************************/
/*	doRegular()							*/
/************************************************************************/
char doRegular(x, c)
char x, c;
{
    char toReturn;

    toReturn = FALSE;

    switch (c) {

    case 'C': doChat(  x, '\0');		    break;
    case 'E': doEnter( x, 'm' );		    break;
    case 'F': doRead(  x, 'f' );		    break;
    case 'G': doGoto(  x, '\0');		    break;
    case 'H': doHelp(  x, '\0');		    break;
    case 'K': doKnown( x, '\0');		    break;
    case 'L': doLogin( x, '\0');		    break;
    case 'N': doRead(  x, 'n' );		    break;
    case 'O': doRead(  x, 'o' );		    break;
    case 'R': doRead(  x, 'r' );		    break;
    case 'T': doLogout(x, 'q' );		    break;

    case 0:
	if (newCarrier)   {
	    greeting();
	    newCarrier	= FALSE;
	}
	if (justLostCarrier) {
	    justLostCarrier = FALSE;
	    if (loggedIn) terminate(FALSE);
	}
	break;	/* irrelevant value */
    case '?':
	tutorial("mainopt.mnu");
	if (whichIO == CONSOLE)   mprintf(" ^p: privileged fns\n ");
	break;

    case 'A': if (!doAide(x, 'E'))  toReturn=TRUE;    break;
    default:
	toReturn=TRUE;
	break;
    }
    return  toReturn;
}

/************************************************************************/
/*	doSysop() handles the sysop-only menu				*/
/*	    return FALSE to fall invisibly into default error msg	*/
/************************************************************************/
char doSysop(c, first)
char c;
char first;	/* first parameter if TRUE		*/
{
    char		who[NAMESIZE];
    struct logBuffer	lBuf;
    int 		logNo, ltabSlot;

    if (!onConsole)   return TRUE;

    while (TRUE)   {

	mprintf("\n privileged fn: ");

	switch (toUpper(   first ? first : iChar()    )) {
	case 'A':
	    mPrintf("bort\n ");
	    return FALSE;
	case 'C':
	    mprintf("hat mode %sabled\n ",
		(noChat = !noChat)
		?
		"dis"
		:
		"en"
	    );
	    break;
	case 'D':
	    debug = !debug;
	    mprintf("ebug switch=%d\n \n", debug);
	    break;
	case 'K':
	    mPrintf("ill account\n ");
	    if (!getYesNo("Confirm"))	break;
	    getString("who", who, NAMESIZE);
	    normalizeString(who);
	    logNo   = findPerson(who, &lBuf);
	    if (logNo == ERROR)   {
		mPrintf("No such person\n ");
		break;
	    }
	    mPrintf(
		"%s deleted\n ",
		who
	    );
	    ltabSlot = PWSlot(lBuf.lbpw);
	    lBuf.lbname[0] = '\0';
	    lBuf.lbpw[0  ] = '\0';

	    putLog(&lBuf, logNo);

	    logTab[ltabSlot].ltpwhash	    = 0;
	    logTab[ltabSlot].ltnmhash	    = 0;

	    break;
	case 'M':
	    mprintf("\bSystem now on MODEM\n ");
	    whichIO = MODEM;
	    setUp(FALSE);
	    mprintf("Chat mode %sabled\n ", noChat  ?  "dis"  :  "en");
	    if (debug)	     mPrintf("Debug mode on\n "  );
	    if (visibleMode) mPrintf("Visible mode on\n ");
	    return FALSE;
	case 'P':
	    mPrintf("\baide privilege set/clear\n ");
	    getString("who", who, NAMESIZE);
	    normalizeString(who);
	    logNo   = findPerson(who, &lBuf);
	    if (logNo == ERROR)   {
		mPrintf("No such person\n ");
		break;
	    }

	    lBuf.lbflags ^= AIDE;
	    mPrintf(
		"%s %s aide privileges\n ",
		who,
		(lBuf.lbflags & AIDE)  ?  "gets"  :  "loses"
	    );
	    if (!getYesNo("Confirm"))	break;

	    putLog(&lBuf, logNo);

	    /* see if it is us: */
	    if (loggedIn  &&  strCmpU(logBuf.lbname, who)==SAMESTRING)	 {
		aide = lBuf.lbflags & AIDE;
	    }
	    break;
	case 'R':
	    patchDebug();
	    break;
	case 'S':
	    mprintf("et date\n \n");
	    interpret(pInitDate);
	    break;
	case 'V':
	    mprintf(" VisibleMode==%d\n ",  visibleMode = !visibleMode);
	    break;
	case 'X':
	    mprintf("\bexit to CP/M\n \n");
	    exitToCpm = TRUE;
	    return FALSE;
	case '?':
	    tutorial("ctdlopt.mnu");
	    break;
	default:
	    if (!expert)    mprintf(" ?(Type '?' for menu)\n "	    );
	    else	    mprintf(" ?\n "			    );
	    break;
	}
    }
}

/************************************************************************/
/*	getCommand() prints menu prompt and gets command char		*/
/*	Returns: char via parameter and expand flag as value  --	*/
/*		 i.e., TRUE if parameters follow else FALSE.		*/
/************************************************************************/
char getCommand(c)
char *c;
{
    char BBSCharReady(), iChar(), toUpper();
    char expand;

    outFlag = OUTOK;

  /*if (*c)*/ givePrompt();
    while (BBSCharReady())   iChar();	      /* eat type-ahead       */

    *c = toUpper(iChar());

    expand  = (
	*c == ' '
	||
	*c == '.'
	||
	*c == ','
	||
	*c == '/'
    );
    if (expand) *c = toUpper(iChar());

    if (justLostCarrier) {
	justLostCarrier = FALSE;
	if (loggedIn) terminate(FALSE);
    }
    return expand;
}

/************************************************************************/
/*	greeting() gives system-entry blurb etc 			*/
/************************************************************************/
greeting() {
    if (loggedIn) terminate(FALSE);

    setUp(TRUE);     pause(10);

    mprintf("\n Welcome to the %S \n ", nodeTitle );
    mprintf("\n node of Citadel Version 2.1\n \n ");
    printDate(
	interpret(pGetYear ),
	interpret(pGetMonth),
	interpret(pGetDay  )
    );
    mprintf("\n H for Help\n ");
    Mprintf("\n L for Login\n");
    printf("\n 'MODEM' mode.\n "	 );
    printf("(<ESC> for CONSOLE mode.)\n ");

    gotoRoom("Lobby");
}

/************************************************************************/
/*	main() contains the central menu code				*/
/************************************************************************/
main() {
    char c, x;
    char getCommand(), init();
    
    if (FALSE) putChar();	/* pick up our own in modem.c	*/
    if (FALSE)	 getNumber();	/* dummy to force load */

    /* don't put any code above init()... readSysTab() will defeat it.	*/
    init();
    initCitadel();
    weAre	= CITADEL;
    greeting();

    while (!exitToCpm) {
	x	= getCommand(&c);

	outFlag = OUTOK;

	if ((c==CNTRLp)  ?  doSysop(0, '\0')  :  doRegular(x, c))  {
	    if (!expert)    mprintf(" ? (Type '?' for menu)\n \n"   );
	    else	    mprintf(" ?\n \n"			    );
	}
    }
    if (loggedIn) terminate( /* hangUp == */ TRUE);
    writeSysTab(); 
}

