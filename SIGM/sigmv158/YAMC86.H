/*
>>:yam.h 12-14-83
 *
 * Computer Innovations C86 version
 */
#include "yamsys.h"		/* installation specific stuff */

#ifndef XMODEM
#define lprintf printf
#endif
/*
 * yam	-Yet Another Modem program
 *		Chuck Forsberg 10-18-81
 *		(C86 conversion:  Paul Homchick 11-09-83)
 *
 *	Design goals: A general program performing the functions
 *	of MODEM and XMODEM, easily portable to non-timesharing
 *	computer systems. YAM facilitates communications and s/w exchange
 *	via timesharing, RCP/M, and Bulletin Board systems.
 *
 *	Coding style is/was aimed at portability and clarity.
 *	File transfer routines are written without timing assumptions
 *	allowing error free high speed operation even if view selected
 *
 *
 *    +++++++++++++++++++++++++++++++++++++++++++++++++
 *
 *	C86 conversion by:
 *		Paul Homchick
 *		Chimitt Gilman Homchick, Inc.
 *		One Radnor Station Suite 300
 *		Radnor, PA 19087
 *		Compuserve 71445,527
 *
 *    +++++++++++++++++++++++++++++++++++++++++++++++++
 *
 *
 *	Files:
 *		yam.h		header and globals
 *		yamsys.h	Modem port adresses, installation specific data
 *		yam1.c		First time initialization
 *					Main command decoding
 *		yam2.c		Christensen protocol handler
 *		yam3.c		Conversation with data capture
 *					File xmsn w/o error checking.
 *
 *		yam4.c		CIS A Protocol handler (see MYSYSYTEM below)
 *		yam5.c		Misc modem related functions, such as baudrate
 *				  (see yam5pmmi.c, yam5smi4.c, etc.)
 *		yam7.c		Disk i/o open,close, directory
 *					Wild card expansion, O/S related stuff
 *		crc.a86		CRCK calculation routine.
 *		updcrc.a86	CRC calculation routine, yterm().
 *		yam10.c		USQ and some time critical functions
 *
 *
 *		These files should be linked with yam10 first, because it
 *		the largest set of "local globals" (i.e., cheating!).
 */

#define TRUE	1
#define FALSE	0
#define ERROR  -1
#define OK	0

/* C86 fopen() definitions */

#define BREAD	"rb"		/* binary read */
#define BWRITE	"wb"		/* binary write */
#define BAPPEND	"ab"		/* binary append */

#ifdef CPM
EXTERN char defdisk;		/* default disk */
EXTERN char user;
#define PATHLEN 20	/* plenty long */
#endif

#define FLAG int
EXTERN FILE *fin,*fout;
EXTERN int logfd;		/* used by logfile */
EXTERN int cfast;
EXTERN unsigned char checksum;	/* delcared here for speed */
EXTERN unsigned oldcrc;	/* accumulates CRC checksum */
EXTERN int wcj, firstch, errors;
EXTERN FLAG firstsec;		/* first sector, C instead of NAK for crc */

#ifndef IOTYPE		/* may be char* or unsigned for memory mapped i/o */
#define IOTYPE int
#endif

#define CMDLEN 132
#define SNARFBUNCH 2056	/* minimum size of buffer arranged by snarfbuf() */
#define LOWWATER 2000	/* low water value causes term to send XOFF */
#define SOH 1
#define STX 2
#define ETX 3
#define EOT 4
#define ENQ 5
#define ACK 6
#define SO 016
#define SI 017
#define DLE 020
#define XON 021
#define XOFF 023
#define NAK 025
#define CAN 030
#define ESC 033
#define WANTCRC 0103	/* send C not NAK to get crc not checksum */
#define TIMEOUT (-2)
#define ERRORMAX 5
#define RETRYMAX 5
#define CPMEOF 0x1A
#define SECSIZ 128	/* Sector size for CP/M read/write calls */
#define KSIZE	1024	/* block length with k option */

/* declare all globally used functions not returning int */
char getcty(), putcty(), *index(), *cisubstr();
unsigned getfree();
long getfre3();
FILE *fopen();

EXTERN char *Version;		/* version number and rev date, pointer to */
EXTERN FLAG Quiet;
EXTERN char Ttycol, Lpcol;	/* column for tab expansion */
EXTERN unsigned Numsecs; /* Number of 128 byte sectors, used by compsec */
EXTERN unsigned Numblks;	/* Number of CP/M blocks, used by compsec */
EXTERN unsigned Numfiles;	/* Total number of files expanded */
EXTERN unsigned Secpblk;	/* Number of sectors per block */
EXTERN FLAG Onetrip;		/* causes exit before next prompt */
EXTERN FLAG Rfile;		/* receiving into a file */
EXTERN FLAG Tfile;		/* transmitting from a file */
EXTERN FLAG Crcflg;		/* 1 if using crc, 0 otherwise */
EXTERN FLAG Batch;		/* Batch (multi-file) xfer */
EXTERN int Wcsmask;		/* 7 or 8 bit mask for Christensen Protocol */
EXTERN FLAG Creamfile;		/* true means o.k. to blast old file on rx */
EXTERN int blklen;		/* length of blocks for s and r, usually 128 */
EXTERN unsigned totsecs;	/* accumulator of number of sectors sent/received */
EXTERN unsigned toterrs;	/* total number of errors in xfer(s) */
EXTERN FLAG Txgo;		/* file sending start/stop (XON/XOFF) */
EXTERN FLAG Dumping;		/* not Squelched ^R */
EXTERN FLAG Pflag;		/* printing the rx stuff */
EXTERN FLAG Twxmode;		/* Respond to a/b requests */
EXTERN FLAG Cis02;		/* Special functions for CIS02 access to Compuserve */
EXTERN FLAG Ctlview;		/* Term function shows control chars as ^char */
EXTERN FLAG Jovemode;	/* EMACS compatible mode for term() */
EXTERN FLAG View;	/* View data being transmitted/received if file xfer */
EXTERN FLAG UsePutchar;	/* Putcty usees putchar, allowing ^P to LST:, etc. */
EXTERN FLAG Echo;	/* Echo modem data back to itself only in chat */
EXTERN FLAG Hdx;	/* Half Duplex connection -no echo from far end */
EXTERN FLAG Chat;	/* treat kbd \r as crlf when chatting */
EXTERN FLAG Gototerm;	/* go to term after file xfer */
EXTERN FLAG Exoneof;	/* exit from term() when finished with file */
/* Following flags affect data as it is written to file, not captured */
EXTERN FLAG Image;	/* Tell it like it is. */
EXTERN FLAG Zeof;	/* Terminate data capture & close file on ^Z */
EXTERN FLAG Squelch;	/* Turn capture on after ^R, off before ^T */
EXTERN char GOchar;	/* normally \n; resumes sending in EOL _ CRWAIT mode */
EXTERN char *Txmoname;		/* asciz string corresponding to Txeoln mode */
EXTERN FLAG Txeoln;	/* what to do at the end of a line */
#define EOL_NOTHING 0	/* send it all as is */
#define EOL_CR	1		/* send /r only */
#define EOL_NL	2		/* send \n only */
#define EOL_CRWAIT 3	/* send \r then wait for GOchar echo */
#define EOL_CRPROMPT 4	/* send \r then wait for silence. */
#define TX_BINARY 0200	/* don't stop on CPMEOF or whatever **/

/* For controls based on time since last RX char mostly */
EXTERN unsigned Timeout;	/* measure of how long since last rxchar */
EXTERN unsigned Tpause;	/* when ++Timeout==Tpause, do something ... */
EXTERN FLAG Xoffflg;		/* !=0 if we sent XOFF to stop the bubble machine */
EXTERN FLAG Waitecho;		/* Wait for echo to stop when sending file */

/* If Waitbunch, Wait for Throttle loops each waitnum txchars */
EXTERN FLAG Waitbunch;
EXTERN unsigned Waitnum;	/* do Waitecho each time chars_sent == Waitnum */
EXTERN unsigned Throttle;
EXTERN FLAG Txwait;		/* used with throttle */
EXTERN unsigned Txtimeout;	/* counted down to 0, then Txwait becomes false */

EXTERN unsigned T1pause;	/* for setting 0.1 second timeout for readline */
EXTERN int Exitchar;		/* 0 or special character for exiting from term */
EXTERN int Lastrx;		/* last char received, for detecting CAN CAN */

/*
 * start, end, input, output, printer-output pointers and marker
 * used with data capture
 */
EXTERN char *bufst, *bufend, *bufcq, *bufcdq, *buffcdq, *bufpcdq, *bufmark;
EXTERN char *lkbufcq;		/* value of bufcq when last kbd char sent */
EXTERN char *reptr;		/* local used by replot for speed */
EXTERN char *abptr;		/* pointer to string to be sent, else 0 */
EXTERN char *abend;		/* first character after string to be sent */
EXTERN unsigned Lskcnt;	/* Count of lines received since last kbdchar */
EXTERN unsigned Nfree;		/* Number of characters free in capture buf */
EXTERN unsigned Bufsize;
EXTERN FLAG Wrapped;		/* Buffer insertion pointer has wrapped around */
EXTERN IOTYPE Dport;		/* data port address */
EXTERN IOTYPE Sport;		/* status port address */
EXTERN unsigned char Mstatus;		/* contents of modem error register if modem error */
EXTERN unsigned Baudrate;  /* current baudrate */
EXTERN FLAG Originate;	/* Originate mode requested */
EXTERN FLAG Parity;
#define SEND8 0	/* RAW on Unix */
#define NORMAL 1	/* cooked o.k. on Unix */
	/* following would be CBREAK on Unix */
#define EVEN7 2
#define ODD7 3
#define EVEN8 4
#define ODD8 5

#ifndef KBMASK
#define KBMASK 0177	/* default strip parity bits from console kbd */
#endif


EXTERN unsigned char cmdbuf[CMDLEN+2], *cp;  /* for commands entered directly (not argv) */
EXTERN char Rname[PATHLEN], Tname[PATHLEN];	/* saved file names */

/* Some declarations for USQ feature */
#define SQMAGIC 0xFF76	/* SQueezed file prefix */
#define NUMVALS 257	/* 256 data values plus SPEOF*/
EXTERN union {
	FILE *ufbuf;
	char ubuf[KSIZE];
	/* Decoding tree for usq feature */
	struct {
		int children[2];	/* left, right */
	} dnode[NUMVALS - 1];
} Utility;

EXTERN char Phone[80];		/* phone number read in from file */
/*
 * Unix is a trademark of Western Electric
 * CP/M, Digital Research
 * Coherent, Mark Willams Co., Chicago IL
 * IDRIS, Whitesmiths Co.
 */

/*
Some #DEFINES you should know about:
	USERINIT this generates a call to userinit() from init()
	IOBYTE define this unsigned to point to memory mapped ports
	DEFBAUD if not defined, baudrate is read from the port
	USQ includes code to automatically type SQUEEZED files
	RESTRICTED disallows downloading of $SYS|TAG2 files, upload .cmd>.obj
	LOGTX log file name for completed file transmissions omit for no log
	LOGRX likewise, for files received omit for no log
	LOGFILE must be defined if logrx or logtx is defined.
	LOGUSER user number for log and lastcalr
	LASTCALR pathname for current caller (lastcalr with entbbs)
	TERMINIT string initializes terminal to default mode.
	TERMREPLOT string sets mode for replot; should disable line wrap.
	TERMRESET string sets terminal to mode for conversation with remote.
	PHONES file with phone numbers
	MYSYSTEM is string required by CIS A protocol ESC I request. If not
		defined, yam4 is not needed.
	FLIP define this if you have a "flip" routine (see yam5pmmi.c)
*/
