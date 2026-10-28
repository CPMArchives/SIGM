/************************************************************************/
/*				confg.c 				*/
/*	configuration program for Citadel bulletin board system.	*/
/************************************************************************/
#include "b:210ctdl.h"
/************************************************************************/
/*				History 				*/
/*									*/
/* 82Nov20 CrT	Created.						*/
/************************************************************************/

/************************************************************************/
/*				Contents				*/
/*									*/
/*	init()			system startup initialization		*/
/*	main()								*/
/*	wrapup()		finishes and writes ctdlTabl.sys	*/
/************************************************************************/

/************************************************************************/
/*	init() -- master system initialization				*/
/************************************************************************/
init()
{
    char     getCh(), toUpper();
    unsigned codend(), endExt(), externs(), topOfMem();
    char     c, *msgFile;

    echo		= BOTH; 	/* echo input to console too	*/
    usingWCprotocol	= FALSE;

    printf("code ends ....at  %u\n", codend()  );
    printf("externs start at  %u\n", externs() );
    printf("externs end   at  %u\n", endext()  );
    printf("free RAM ends at  %u\n", topofmem());

    exitToCpm	= FALSE;		/* not time to quit yet!	*/
    sizeLTentry = sizeOf(logTab[0]);	/* just had to try that feature */
    outFlag	= OUTOK;		/* not p(ausing)		*/

    pullMessage = FALSE;		/* not pulling a message	*/
    pulledMLoc	= ERROR;		/* haven't pulled one either	*/
    pulledMId	= ERROR;

    debug	= FALSE;
    loggedIn	= FALSE;
    haveCarrier = FALSE;
    termWidth	= 79;
    termUpper	= FALSE;
    termTab	= FALSE;

    noChat	= FALSE;

    /* shave-and-a-haircut/two bits pause pattern for ringing sysop: */
    shave[0]	= 40;
    shave[1]	= 20;
    shave[2]	= 20;
    shave[3]	= 40;
    shave[4]	= 80;
    shave[5]	= 40;
    shave[6]	=250;

    /* initialize input character-translation table:	*/
    for (c=0;	   c<'\40';  c++) {
	filter[c] = '\0';		/* control chars -> nulls	*/
    }
    for (c='\40';  c<128;    c++) {
	filter[c] = c;			/* pass printing chars		*/
    }
    filter[SPECIAL]	= SPECIAL;
    filter[CNTRLp]	= CNTRLp;
    filter[DEL	    ]	= BACKSPACE;
    filter[BACKSPACE]	= BACKSPACE;
/*  filter[CNTRLI   ]	= CNTRLI   ;	*/
    filter[XOFF     ]	= 'P'	   ;
    filter['\r'     ]	= NEWLINE  ;
    filter[CNTRLO   ]	= 'N'	   ;

    /* check for CPM 2.x */
    if (!call(5, 0, 0, 12)) {
	printf(" Not CPM 2.x!! Citadel's random-access won't work!\n");
	exit();
    }

    setSpace(homeDisk, homeUser);

    /* open message file */
    msgFile	= "a:ctdlmsg.sys";
    *msgFile   += msgDisk;
    if ((msgfl = open(msgFile, 2)) == ERROR) {
	printf(" %s not found, creating new file. \n", msgFile);
	printf(" (Be sure to initialize it!)\n");
	if ((msgfl = creat("ctdlmsg.sys")) == ERROR) {
	    printf("?can't create ctdlmsg.sys!!\n");
	    exit();
	}
	close(msgfl);	/* can't create in mode 2! */
	msgfl = open("ctdlmsg.sys", 2);
    }
    rsrec(msgfl);	/* initialize for random io */

    /* open room file */
    if ((roomfl = open("ctdlroom.sys", 2)) == ERROR) {
	printf(" ctdlroom.sys not found, creating new file. \n");
	printf(" (Be sure to initialize it!)\n");
	if ((roomfl = creat("ctdlroom.sys")) == ERROR) {
	    printf("?can't create ctdlroom.sys!!\n");
	    exit();
	}
	close(roomfl);	 /* can't create in mode 2! */
	roomfl = open("ctdlroom.sys", 2);
    }
    rsrec(roomfl);	/* initialize for random io */

    /* open userlog file */
    if ((logfl = open("ctdllog.sys", 2)) == ERROR) {
	printf(" ctdlLog.sys not found, creating new file. \n");
	printf(" (Be sure to initialize it!)\n");
	if ((logfl = creat("ctdlLog.sys")) == ERROR) {
	    printf("?can't create ctdlLog.sys!!\n");
	    exit();
	}
	close(logfl);	/* can't create in mode 2! */
	logfl = open("ctdlLog.sys", 2);
    }
    rsrec(logfl);	/* initialize for random io */

    printf("\n Erase and initialize log, message and/or room files?");
    if (toUpper(getCh()) == 'Y') {
	/* each of these has an additional go/no-go interrogation: */
	zapMsgFile();
	zapRoomFile();
	zapLogFile();
    }

}

/************************************************************************/
/*	main() for confg.c						*/
/************************************************************************/
main() {
    char *fBuf;
    char *line;
    char *cmd, *var, *string;
/*  char fBuf[BUFSIZ];				*/
/*  char line[128];				*/
/*  char cmd[128], var[128], string[128];	*/
    int  arg, arg2, args;
    union {
	int  *pi;
	char *pc;
    } nextCode; 	/* where to deposit next code */

    /* icky-tricky to conserve RAM: */
    fBuf	= msgBuf;
    line	= fBuf + BUFSIZ;
    cmd 	= line + 128;
    var 	= cmd  + 128;
    string	= var  + 128;


    if (fOpen("ctdlcnfg.sys", fBuf) == ERROR) {
	printf("?Can't find ctdlCnfg.sys!\n");
	exit();
    }
    nextCode.pc = &codeBuf[0];
    while (fgets(line, fBuf)) {
	if (args = sscanf(line, "%s %s %x ", cmd, var, &arg)) {
	    if	      (strCmp(cmd, "#define" ) == SAMESTRING  &&  args==3) {
		printf("#define '%s' as %x\n", var, arg);
		       if (strCmp(var, "MDATA"	   )	== SAMESTRING) {
		    mData	= arg;
		} else if (strCmp(var, "MEGAHZ"    )	== SAMESTRING) {
		    megaHz	= arg;
		} else if (strCmp(var, "CRYPTSEED" )	== SAMESTRING) {
		    cryptSeed	= arg;
		} else if (strCmp(var, "RCPM"	   )	== SAMESTRING) {
		    rcpm	= arg;
		} else if (strCmp(var, "CLOCK"	   )	== SAMESTRING) {
		    clock	= arg;
		} else if (strCmp(var, "MESSAGEK"  )	== SAMESTRING) {
		    maxMSector	= arg*8;
		} else if (strCmp(var, "MSGDISK"   )	== SAMESTRING) {
		    msgDisk	= arg;
		} else if (strCmp(var, "HOMEDISK"  )	== SAMESTRING) {
		    homeDisk	= arg;
		} else if (strCmp(var, "HOMEUSER"  )	== SAMESTRING) {
		    homeUser	= arg;
		} else if (strCmp(var, "LOGINOK"   )	== SAMESTRING) {
		    unlogLoginOk= arg;
		} else if (strCmp(var, "ENTEROK"   )	== SAMESTRING) {
		    unlogEnterOk= arg;
		} else if (strCmp(var, "READOK"    )	== SAMESTRING) {
		    unlogReadOk = arg;
		} else if (strCmp(var, "ROOMOK"    )	== SAMESTRING) {
		    nonAideRoomOk=arg;
		} else {
		    printf("? -- no variable '%s' known! -- ignored.\n", var);
		}

	    } else if (strCmp(cmd, "#start"  ) == SAMESTRING) {
		printf("#start procedure '%s'\n", var);
		if	  (strCmp(var, "HANGUP"    ) == SAMESTRING) {
		    pHangUp	= nextCode.pc;
		} else if (strCmp(var, "INITPORT"  ) == SAMESTRING) {
		    pInitPort	= nextCode.pc;
		} else if (strCmp(var, "CARRDETECT") == SAMESTRING) {
		    pCarrDetect = nextCode.pc;
		} else if (strCmp(var, "MIREADY"   ) == SAMESTRING) {
		    pMIReady	= nextCode.pc;
		} else if (strCmp(var, "MOREADY"   ) == SAMESTRING) {
		    pMOReady	= nextCode.pc;
		} else if (strCmp(var, "INITDATE"  ) == SAMESTRING) {
		    pInitDate	= nextCode.pc;
		} else if (strCmp(var, "GETDAY"    ) == SAMESTRING) {
		    pGetDay	= nextCode.pc;
		} else if (strCmp(var, "GETMONTH"  ) == SAMESTRING) {
		    pGetMonth	= nextCode.pc;
		} else if (strCmp(var, "GETYEAR"   ) == SAMESTRING) {
		    pGetYear	= nextCode.pc;
		} else printf("?--no procedure '%s' known!\n", var);

	    } else if (strCmp(cmd, "#code"   ) == SAMESTRING) {
		printf("#code '%s'\n", var);
		if	  (strCmp(var, "LOAD"	   ) == SAMESTRING) {
		    *nextCode.pc++	= LOAD;
		    *nextCode.pi++	= arg;
		} else if (strCmp(var, "ANDI"	   ) == SAMESTRING) {
		    *nextCode.pc++	= ANDI;
		    *nextCode.pc++	= arg;
		} else if (strCmp(var, "ORI"	   ) == SAMESTRING) {
		    *nextCode.pc++	= ORI;
		    *nextCode.pc++	=arg;
		} else if (strCmp(var, "XORI"	   ) == SAMESTRING) {
		    *nextCode.pc++	= XORI;
		    *nextCode.pc++	= arg;
		} else if (strCmp(var, "STORE"	   ) == SAMESTRING) {
		    *nextCode.pc++	= STORE;
		    *nextCode.pi++	= arg;
		} else if (strCmp(var, "LOADI"	   ) == SAMESTRING) {
		    *nextCode.pc++	= LOADI;
		    *nextCode.pc++	= arg;
		} else if (strCmp(var, "RET"	   ) == SAMESTRING) {
		    *nextCode.pc++	= RET;
		} else if (strCmp(var, "INP"	   ) == SAMESTRING) {
		    *nextCode.pc++	= INP;
		    *nextCode.pc++	= arg;
		} else if (strCmp(var, "OUTP"	   ) == SAMESTRING) {
		    *nextCode.pc++	= OUTP;
		    *nextCode.pc++	= arg;
		} else if (strCmp(var, "PAUSEI"    ) == SAMESTRING) {
		    *nextCode.pc++	= PAUSEI;
		    *nextCode.pc++	= arg;
		} else if (strCmp(var, "ARRAY[]="  ) == SAMESTRING) {
		    *nextCode.pc++	= STOREX;
		    *nextCode.pc++	= arg;
		} else if (strCmp(var, "ARRAY[]"   ) == SAMESTRING) {
		    *nextCode.pc++	= LOADX;
		    *nextCode.pc++	= arg;
		} else if (strCmp(var, "OPR#"	   ) == SAMESTRING) {
		    *nextCode.pc++	= OPRNUMBER;

		    /* reparse to pick up string: */
		    sscanf(line, "%s %s \"%s\" %d %d",
			cmd, var, string, &arg, &arg2
		    );
		    /* copy string into code buffer: */
		    strCpy(nextCode.pc, string);
		    while (*nextCode.pc++);	/* step over string	*/
		    *nextCode.pc++	= arg;	/* lower limit		*/
		    *nextCode.pc++	= arg2; /* upper limit		*/

		} else if (strCmp(var, "OUTSTRING" ) == SAMESTRING) {
		    *nextCode.pc++	= OUTSTRING;

		    /* reparse to pick up string: */
		    sscanf(line, "%s %s \"%s\"", cmd, var, string);
		    /* copy string into code buffer: */
		    strCpy(nextCode.pc, string);
		    while (*nextCode.pc++);	/* step over string	*/
		    nextCode.pc--;
		    *nextCode.pc++	= '\r'; /* add a CR		*/
		    *nextCode.pc++	= '\0'; /* tie off with null	*/
		} else printf("?--no code '%s'!\n", var);

	    } else if (strCmp(cmd, "#nodeTitle") == SAMESTRING) {
		    /* reparse by ";" terminator: */
		    sscanf(line, "%s \"%s\"", cmd, string);
		    /* copy string into code buffer: */
		    strCpy(nextCode.pc, string);
		    nodeTitle	= nextCode.pc;
		    while (*nextCode.pc++);	/* step over string	*/
	    } else if (strCmp(cmd, "#nodeName" ) == SAMESTRING) {
		    /* reparse by ";" terminator: */
		    sscanf(line, "%s \"%s\"", cmd, string);
		    /* copy string into code buffer: */
		    strCpy(nextCode.pc, string);
		    nodeName	= nextCode.pc;
		    while (*nextCode.pc++);	/* step over string	*/
	    } else if (strCmp(cmd, "#nodeId"   ) == SAMESTRING) {
		    /* reparse by ";" terminator: */
		    sscanf(line, "%s \"%s\"", cmd, string);
		    /* copy string into code buffer: */
		    strCpy(nextCode.pc, string);
		    nodeId	= nextCode.pc;
		    while (*nextCode.pc++);	/* step over string	*/
	    } else if (strCmp(cmd, "#alldone") == SAMESTRING) {
		break;
	    } else if (cmd[0] == '#') printf("? -- no '%s' command!\n", cmd);
	}
    }
    if (nextCode.pc < &codeBuf[MAXCODE]) {
       init();
       wrapup();
    } else {
	printf("\7codeBuf[] overflow! Recompile with larger MAXCODE "	);
	printf("or reduce ctdlCnfg.sys\7"				);
    }
}

/************************************************************************/
/*	wrapup() finishes up and writes ctdlTabl.sys out, finally	*/
/************************************************************************/
wrapup() {
    printf("\ncreating ctdlTabl.sys table\n");
    msgInit();
    indexRooms();
    logInit();
    printf("writeSysTab =%d\n", writeSysTab());
}

