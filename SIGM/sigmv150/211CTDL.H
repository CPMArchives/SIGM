/************************************************************************/
/*				Ctdl210.h				*/
/*									*/
/*	#include file for all Citadel C files.				*/
/************************************************************************/

/************************************************************************/
/*				History 				*/
/*									*/
/* 83Mar03 CrT	Changed from 2 to 3 sectors / log-record (more mail)	*/
/* 83Feb23	termTab, TABMASK					*/
/* 82Dec16 dvm	Place for #defines added				*/
/* 82Dec06 CrT	2.00 release.						*/
/* 82Nov02 CrT	General cleanup begun, preparatory to V1.2 mods.	*/
/* 82Nov01 CrT	Proofread for distribution version.			*/
/* 82Oct05 dvm	distribution version mods begun 			*/
/* 82Jun03 dvm	MAXROOMS reduced to 64					*/
/* 82Apr22 dvm	mods for HiTech/NMI version completed			*/
/* 81Dec19 CrT	Rooms seem to be working...				*/
/* 81Dec12 CrT	Started.						*/
/************************************************************************/

/************************************************************************/
/*				#defines		82Dec10 dvm	*/
/*									*/
/* #defs supported in current system:					*/
/*									*/
/* #def FDC-1 for the TeleTek (dvm code)				*/
/* #def VFC-2 for the Big Board (dvm code)				*/
/*									*/
/* #def TEST for special small-scale test version			*/
/************************************************************************/


char firstExtern;	/* this should ALWAYS be the first declaration	*/

char mData;			/* Modem data port			*/

char megaHz;			/* Z80 clock rate (for wait loops)	*/

char *nodeName;
char *nodeTitle;
char *nodeId;

int  cryptSeed;
char rcpm;			/* TRUE to run in RCP/M mode		*/
char clock;			/* TRUE  if we have a hardware clock	*/

char homeDisk, homeUser, msgDisk;	/* where we keep our data files */
char ourDisk, ourUser;			/* where we are just now	*/

char unlogEnterOk;		/* TRUE if OK to enter messages anon	*/
char unlogReadOk;		/* TRUE if unlogged folks can read mess */
char unlogLoginOk;		/* TRUE if spontan. new accounts ok.	*/
char nonAideRoomOk;		/* TRUE general folks can make rooms	*/

/************************************************************************/
/*									*/
/*		!   !  !!!   !!!!!  !!!!!   !!				*/
/*		!!  ! !   !    !    !	    !!				*/
/*		! ! ! !   !    !    !!!     !!				*/
/*		!  !! !   !    !    !					*/
/*		!   !  !!!     !    !!!!!   !!				*/
/*									*/
/* Citadel programs use readSysTab() and writeSysTab() to write an	*/
/* image of the external variables in RAM to disk, and later restore	*/
/* it.	The image is stored in ctdlTabl.sys .  If ctdlTabl.sys is lost, */
/* sysop.com will automatically reconstruct the hard way when invoked,	*/
/* and write a new ctdlTabl.sys out when finished.  CtdlTabl.sys is	*/
/* always destroyed after reading, to minimize the possibility of	*/
/* reading an out-of-date version.  In general, the technique works	*/
/* well and saves time and head-banging on bootup.  You should, 	*/
/* however, note carefully the following cautions:			*/
/*  o  "char firstExtern;" should >always< be the first 		*/
/*     declaration in citadel.h 					*/
/*  o  "char lastExtern;"  shoule >always< be the last			*/
/*     declaration in citadel.h 					*/
/*  o  Whenever you change the declarations in 210Ctdl.h you should:	*/
/*   -->  destroy the current ctdlTabl.sys file 			*/
/*   -->  recompile and reload all citadel programs which access	*/
/*	  ctdlTabl.sys -- currently citadel.com & consifurg.com 	*/
/*   -->  use configur.com to build a new ctdlTabl.sys file		*/
/*									*/
/* If you ignore these warnings, little pixies will prick you in your	*/
/* sleep for the rest of your life.					*/
/************************************************************************/

/************************************************************************/
/*	stuff to distinguish the various Citadel programs		*/
/************************************************************************/
#define CITADEL 	0	/* prinipal program			*/
#define xxxxx		1	/* unused				*/
#define NET		2	/* network downloader	(future)	*/
#define ARCHIVE 	3	/* backup program	(future)	*/
char	weAre;			/* set first thing by main()		*/

/************************************************************************/
/*			Stuff to size system with:			*/
/************************************************************************/

/* WARNING!!! if you expand MAXROOMS beyond 128, horrible, horrible	*/
/* things will happen to the userlog entries, which will no longer	*/
/* fit in the assigned 256-byte records and will overwrite things	*/
/* with normally undesirable results. 82Nov10CrT			*/
#ifdef TEST
#define MAXROOMS	6
#define MAXLOGTAB	4
#else

#define MAXROOMS       64	/* number of rooms allowed in system	*/

#define MAXLOGTAB     180	/* number of log entries supported	*/

#endif

#define SECSPERROOM	2	/* sectors/room 			*/
#define ROOMSECTORS   (MAXROOMS*SECSPERROOM)
#define SECSPERLOG	3	/* three sectors per log record 	*/
#define LOGSECTORS    (MAXLOGTAB*SECSPERLOG)

/************************************************************************/
/*		Stuff nowadays usually in bdscio.h:			*/
/************************************************************************/

/* values for functions to return: */
#define TRUE		1
#define FALSE		0
#define ERROR	       -1

#define SAMESTRING	0	/* value for strcmp() & friend		*/

/* ASCII characters: */
#define NULL		0
#define SOH		1
#define CNTRLC		3
#define EOT		4
#define ACK		6
#define BELL		7
#define BACKSPACE	8
#define CNTRLI		9	/* aka tab				*/
#define TAB		9	/* aka ^I				*/
#define NEWLINE        10	/* "linefeed" to philistines.		*/
#define CNTRLO	       15
#define CNTRLp	       16
#define XOFF	       19	/* control-s				*/
#define NAK	       21
#define CNTRLZ	       26
#define CPMEOF	   CNTRLZ
#define ESC	       27	/* altmode				*/
#define DEL	     0x7F	/* delete char				*/

/* for packing & unpacking ints: */
#define BYTE	      256

/************************************************************************/
/*			Stuff for rooms:				*/
/************************************************************************/

#define LOBBY		0	/* Lobby> is >always< room 0.		*/
#define MAILROOM	1	/* Mail>  is >always< room 1.		*/
#define AIDEROOM	2	/* Aide> is >always< room 2.		*/

#define NAMESIZE       20	/* length of room names 		*/

#ifdef TEST
#define MSGSPERRM      58	/* should be >= MAILSLOTS		*/
#else
#define MSGSPERRM      58	/* roombuf must be 256 bytes or less.	*/
#endif

#define FILSPERRM      10	/* roombuf must be 256 bytes or less.	*/
#define SECTSIZE      128
char debug;			/* turns debug printout on and off	*/
int  roomfl;			/* file descriptor for ctdlRoom.sys	*/

#define INUSE		1	/* flags mask				*/
#define PUBLIC		2	/* flags mask				*/
#define CPMDIR		4	/* flags mask				*/
#define PERMROOM	8	/* flags mask				*/
struct {
    char     rtgen;		/* generation # of room 		*/
    char     rtflags;		/* public/private flag etc		*/
    char     rtname[NAMESIZE];	/* name of room 			*/
    unsigned rtlastMessage;	/* # of most recent message in room	*/
} roomTab[MAXROOMS];

struct {
    char     rbgen;		/* generation # of room 		*/
    char     rbflags;		/* same bits as flags above		*/
    char     rbname[NAMESIZE];	/* name of room 			*/
    char     rbdisk;		/* disk this rooms files are in 0=>none */
    char     rbuser;		/* user area for this rooms files	*/
    union {
	struct {
	    unsigned rbmsgNo;	/* every message gets unique#		*/
	    int      rbmsgLoc;	/* sector message starts in		*/
	} msg[MSGSPERRM];

	/* old idea, will probably drop: */
	struct {
	    unsigned rbfilNo;	/* files also get ID#s			*/
	    char rbfilNam[NAMESIZE];	/* name of file 		*/
	} fil[FILSPERRM];
    } vp;			/* variable-part			*/
#ifdef TEST
    char rbOverRun[256];
#else
    char rbOverRun[2];		/* actually unneeded just now -- roomBuf*/
#endif
				/* is exactly 256 at present		*/
} roomBuf;			/* buffer current room is held in	*/

char thisRoom;			/* room currently in roomBuf	*/

/************************************************************************/
/*			      userlog stuff				*/
/************************************************************************/
#define CRYPTADD      117	/*					*/

#define UCMASK		1	/* bit uppercase flag is in		*/
#define LFMASK		2	/* bitmask for linefeed flag		*/
#define EXPERT		4	/* bitmask for expert-user flag 	*/
#define TABMASK 	8	/* bitmask for tab flag 		*/
#define AIDE	       16	/* bitmask for aide flag		*/

#define MAILSLOTS      58	/* twiddle to fit logBuf in 384 bytes	*/

#define GENSHIFT	3	/* lbgen >> GENSHIFT gives generation	*/
#define CALLMASK	7	/* lbgen &  CALLMASK gives last visit	*/
#define MAXVISIT	8	/* #visits we remember old newestLo for */
#define MAXGEN	       32	/* six bits of generation => 64 of them */

/* logbuf must be 384 bytes or less... including lbOverFlow, 384 or MORE*/
struct logBuffer {
    char      lbnulls;		/* #nulls, lCase, lFeeds		*/
    char      lbflags;		/* UCMASK, LFMASK, EXPERT, TABMASK, AIDE*/
    char      lbwidth;		/* terminal width			*/
    char      lbname[NAMESIZE]; /* caller's name			*/
    char      lbpw[NAMESIZE];	/* caller's password			*/
    char      lbgen[MAXROOMS];	/* 6 bits gen, two bits lastvisit	*/
    int       lbvisit[MAXVISIT];/* newestLo for this and 3 prev. visits */
    int       lbslot[MAILSLOTS];/* for private mail			*/
    unsigned  lbId[MAILSLOTS];	/* for private mail			*/
#ifdef TEST
    char      lbOverFlow[256];
#else
    char      lbOverFlow[84];
#endif
} logBuf;

int thisLog;			/* entry currently in logBuf		*/
int thisSlot;			/* logTab slot logBuf was found via	*/

int logfl;			/* log file fd				*/

struct {
    int  ltpwhash;		/* hash of password			*/
    int  ltnmhash;		/* hash of name 			*/
    int  ltlogSlot;		/* location in userlog.buf		*/
    int  ltnewest;		/* last message on last call		*/
} logTab[MAXLOGTAB];
int sizeLTentry;		/* contains size of a logTab entry	*/

char loggedIn;			 /* global have-caller flag		 */

/************************************************************************/
/*			terminal stuff					*/
/************************************************************************/
#define SPECIAL        27	/* <ESC>	console escape char	*/

#define MONTHOFFSET    32	/* for packing month and year in a byte */
char *monthTab[13];		/* month names (we don't use loc 0)	*/
char filter[128];		/* input character translation table	*/

char prevChar;			/* for EOLN/EOParagraph stuff		*/
char expert;			/* true to suppress hints & noise	*/
char termWidth; 		/* width to format output to		*/
char termUpper; 		/* uppercase-only flag			*/
char termLF;			/* LF-after-CR flag			*/
char termTab;			/* has-tabs flag			*/
char aide;			/* aide-privileges flag 		*/
char termNulls; 		/* #nulls to send at eoln		*/
char justLostCarrier;		/* room2.c / rmmodem.c	communication	*/
char crtColumn; 		/* current position on screen		*/

char newCarrier;
char onConsole;
#define MAXTEXT      3500	/* maximum chars in edit buffer 	*/

/************************************************************************/
/*			message stuff					*/
/************************************************************************/
struct {
    char mbtext[MAXTEXT]  ;	/* buffer text is edited in		*/

    int  mbheadChar	  ;	/* start of message			*/
    int  mbheadSector	  ;	/* start of message			*/

    char mbauth[ NAMESIZE];	/* name of author			*/
    char mbdate[ NAMESIZE];	/* creation date			*/
    char mbId[	 NAMESIZE];	/* local number of message		*/
    char mboname[NAMESIZE];	/* short human name for origin system	*/
    char mborig[ NAMESIZE];	/* US 206 633 3282 style ID		*/
    char mbroom[ NAMESIZE];	/* creation room			*/
    char mbsrcId[NAMESIZE];	/* message ID on system of origin	*/
    char mbto[	 NAMESIZE];	/* private message to			*/
} msgBuf;

int msgfl;		/* message file fd--packed leaky circular queue */

char sectBuf[SECTSIZE]; 	/* temporary buffer for random access	*/

char GMCCache;			/* to unGetMsgChar() into		*/

int oldChar;			/* old value of thisChar		*/
int oldSector;			/* old value of thisSector		*/

int thisChar;			/* next char in sectBuf 		*/
int thisSector; 		/* next sector in msgfl 		*/

int catChar;		/* as in cat-and-mouse queue, or conCATenation. */
int catSector;			/* where to write next message		*/

unsigned oldestLo, oldestHi;	/* 32-bit ID# of first message in system*/
unsigned newestLo, newestHi;	/* 32-bit ID# of last  message in system*/

int maxMSector; 		/* # sectors (used) in ctdlmsg.sys	*/


/* values for showMess routine */
#define NEWoNLY 	0
#define OLDaNDnEW	1
#define OLDoNLY 	2
#define GLOBALnEW	3

/************************************************************************/
/*			modem stuff					*/
/************************************************************************/
/* somestuff readfile() and sendfile() like:	*/
#define LOOPSPERSEC  5000
#define ERRORMAX       10
#define RETRYMAX       10

/* sendFile() globals because BDS C lacks coroutines and statics alike: */
char SFcheckSum, SFeofSeen, SFRunning;
int  SFi, SFthisChar, SFthisSector, SFerrorCount, SFtries;
char SFBuf[SECTSIZE];

/* fiddle factor to timeout on no input: */
#define HITIMEOUT	2	/* count seems to be about 30 sec	*/

#define NEWCARRIER   0x01	/* returned to main prog on login	*/

#define MODEM		0	/* current user of system is		*/
#define CONSOLE 	1	/* one of these 			*/
char modStat;			/* whether modem was on line		*/
				/* LAST time it was checked		*/

char noChat;			/* TRUE to suppress chat attempts	*/
char whichIO;			/* CONSOLE or MODEM			*/
char visibleMode;		/* make non-printables visible? 	*/
char haveCarrier;		/* set if DCD == TRUE			*/
char exitToCpm; 		/* system is being brought down 	*/

char textDownload;		/* read host files, TRUE => ASCII	*/

/*  output XON/XOFF etc flag... */
#define OUTOK		0	/* normal output			*/
#define OUTPAUSE	1	/* a pause has been requested		*/
#define OUTNEXT 	2	/* quit this message, get the next	*/
#define OUTSKIP 	3	/* stop current process 		*/
#define OUTPARAGRAPH	4	/* skip to next paragraph		*/
char outFlag;			/* will be one of the above		*/

#define NEITHER 	0	/* don't echo input			*/
#define CALLER		1	/* echo to caller only --passwords etc	*/
#define BOTH		2	/* echo to caller and console both	*/

char echo;			/* will be one of above three		*/

/* scratch externals for speed-critical code:	*/
char *fpc1, *fpc2, *fpc3;
char   fc1,   fc2,   fc3;
int    fi1,   fi2,   fi3;

char usingWCprotocol;		/* true during Ward Christensen-	*/
				/* protocol file/message transfers.	*/

/************************************************************************/
/*	stuff for the mini-INTRPreter that drives the modem:		*/
/************************************************************************/
/* opcodes for the interpreter: */
#define ANDI		1
#define INP		2
#define LOAD		3
#define LOADI		4
#define ORI		5
#define OUTP		6
#define OUTSTRING	7
#define PAUSEI		8
#define RET		9
#define STORE	       10
#define XORI	       11
#define STOREX	       12
#define LOADX	       13
#define OPRNUMBER      14
#define TOBDC	       15
#define TODEC	       16

#define MAXCODE       512
char codeBuf[MAXCODE];	/* buffer for configuration routines	*/
char scratch[40];	/* scratch space for config routines	*/
char shave[8];		/* shave-and-a-haircut/2 bits pauses	*/

/* routine addresses in codeBuf: */
char *pHangUp, *pCarrDetect, *pMIReady, *pMOReady, *pInitPort;
char *pInitDate, *pGetDay, *pGetMonth, *pGetYear;

/************************************************************************/
/*		get/put message stuff					*/
/************************************************************************/
char pullMessage;		/* true to pull current message 	*/
int  pulledMLoc;		/* loc of pulled message		*/
int  pulledMId; 		/* id number of message to be pulled	*/


/************************************************************************/
/*		buffered file I/O stuff 				*/
/************************************************************************/
#define NSECTS		8	/*  8 sectors == 1024 byte buffer	*/

#define BUFSIZ		(NSECTS * SECTSIZE + 6)

struct	_buf {
	int  _fd;
	int  _nleft;
	char *_nextp;
	char _buff[NSECTS * SECTSIZE];
};

/* file control block structure, for doing directories: */
struct fcb {
    char	fcbDr;		/* drive number 			*/
    char	fcbfName[8];	/* file name				*/
    char	fcbfExt[3];	/* file extention			*/

    char	fcbEx;		/* file extent -- usually 0		*/

    char	fcbS1;		/* mysterious BDOS byte 		*/
    char	fcbS2;		/* same, zero for open, make, search	*/

    char	fcbRC;		/* record count in this extent, 0-128	*/

    char	fcbdMap[16];	/* bitmap?				*/

    char	fcbCr;		/* current record -- initialize to 0	*/

    unsigned	fcbRecn;	/* highest record number		*/
    char	fcbRecOvfl;	/* overflow of above			*/
};

/* some more stuff for doing directories: */
#define FINDfIRST      17	/* BDOS call to find first match	*/
#define FINDnEXT       18	/* BDOS call for next directory match	*/

#define SETdMA	       26	/* BDOS call				*/

#define SETdISK        14	/* BDOS call				*/
#define SETuSER        32	/* BDOS call				*/

#define GETfILEsIZE    35	/* BDOS call				*/

int  FDSectCount;		/* fileDirectory() keeps a count here	*/

char lastExtern;       /* this should ALWAYS be the last declaration  */
claration  */
ÿÿÿÿÿÿÿÿÿý) ÃÆÿ÷ÿŽÿÿÿÿÿÆÿ÷ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ