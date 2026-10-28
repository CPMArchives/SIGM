/********************************************************/
/*							*/
/*		    ROFF4, Version 1.60			*/
/*							*/
/*(C) 1983,4 by Ernest E. Bergmann			*/
/*		Physics, Building #16			*/
/*		Lehigh Univerisity			*/
/*		Bethlehem, Pa. 18015			*/
/*							*/
/* Permission is hereby granted for all commercial and	*/
/* non-commercial reproduction and distribution of this	*/
/* material provided this notice is included.		*/
/*							*/
/********************************************************/
/*FEB 19, 1984*/
/*Jan 15, 1984*/
#include "bdscio.h"
/*June 27, 1983 eliminate directed input*/
char _doflag;	/* flag if directed /O being used */
char  **_nullpos; /*???*/
char _dobuf[BUFSIZ];	/* /O buffer used for direction  */
char sav_out_file[20];	/*??? added to work with dioinit
				and dioflush() ???*/
int 	debug;
int PAGESTOP;
int JUSTIFY;
int FFEED;
int FIRSTPAGE,LASTPAGE;/*for selectively printing output*/
int SUPPRESS;/*if true,no output is passed by putchar()*/

#define STDERR		4
/* send error messages to console while in DIO */
#define STKSIZ		3
#define DEBUG		( debug != 0 )
#define HUGE		135	/* generally large number */
#define LSZ		255	/* line buffer size*/
#define	COMMAND		'.'	/* all commands starts with this */
#define	CONSOLE		-5	/* one of output options */
#define PRINTER 	-4	/* another */
#define FILE		-3	/* another */
#define	UNKNOWN		-1	/* returned if doesn't recg. command */
#define	NO_VAL		-32760	/* returned when no argument w/commad */
#define WE_HAVE_A_WORD   1       /* returned by getwrd func. */
#define	NO		0
#define	YES		1
#define UNDERLINE	'\137'
#define	CR		0x0D
#define BACKSPACE	'\b'
#define NUMSIGN		'#'	/* for title strings */
#define NEWLINE		'\n'
#define TAB		'\t'
#define BLANK		' '
#define FORMF		0x0C	/* formfeed for printer */
#define SQUOTE		0x27	/* single quote */
#define DQUOTE		0x22	/* double quote */
#define TRSIZ		2000	/*size of TRTBL*/

#define TRANSLATE 2	/* May 23, 1983*/
#define BLACK 1
#define WHITE 0
#define CONTROL -1
#define SENTINEL -2
#define HTAB	-3
#define OTHERS -4
#define XCHAR '-'
#define UCHAR '_'

#define FI		1	/* fill lines */
#define TI		2	/* temporary indent */
#define BP		3	/* begin page  */
#define BR		4	/* causes break */
#define CE		5	/* center line(s) */
#define IN		7	/* left indent */
#define LS		8	/* line spacing */
#define NF		9	/* no fill */
#define PL		10	/* set page length */
#define RM		11	/* set right margin */
#define SP		12	/* add blank line(s) */
#define ST		13	/* stop(pause) at page start?*/
#define FO		14	/* footer title */
#define HE		15	/* header title */
#define M1		16	/* top margin */
#define M2		17	/* second top margin */
#define M3		18	/* first bottom margin */
#define M4		19	/* bottom-most margin       */
#define IG		20	/* "ignore";comments,Nov 6,82*/
#define NE		21	/* "need";Nov 7,82*/
#define FF		22	/* "formfeed";Nov 10*/
#define SC		23	/* "space character";Nov13*/
#define OW		24	/* "output width";Nov 13*/
#define TS		25	/* "tabsize";Nov 13*/
#define EH		26	/* "even headers";Nov 14*/
#define OH		27	/* "odd headers"*/
#define EF		28	/* "even footers"*/
#define OF		29	/* "odd footers"*/
#define AB		30	/* "abort";Nov 15*/
#define DB		31	/* "debug"*/
#define TC		32	/* "translation flag char"*/
#define TR		33	/* "def translation string"*/
#define CF		34	/* Dec 4:control flag char*/
#define IC		35	/* insert character */
#define OU		36	/* output */
#define JU		37	/* right justify?*/
#define NJ		38	/* don't right justify*/
#define WH		39	/* whole line spacing code*/
#define FR		40	/* fractional spacing,code*/
#define DS		41	/*define string*/
#define DM		42	/*define macro*/
#define EM		43	/*end macro*/
#define RG		44	/*register variable*/
#define DI		45	/*diversion*/
#define ED		46	/*end diversion*/
#define SO		47	/*"source", include*/
#define PC		48	/*printer control definition*/
#define SA		49	/*"say" inline msg to console*/
#define BJ		50	/*break with rightjustification
				of current line*/
int FILL;	/* set to YES or NO */
int _FILL[STKSIZ];	/*convert global value to a stack*/
int LSVAL;	/* line spacing value -> default will be 1 */
int _LSVAL[STKSIZ];
int TIVAL;	/* temporary indent -> default  0 */
int INVAL;	/* left indent -> default  0 */
int _INVAL[STKSIZ];
int RMVAL;	/* right margin -> default  PAGEWIDTH */
int _RMVAL[STKSIZ];
int CEVAL;	/* set equal to number of lines to be centered	*/
int TCVAL;	/*translation flag char*/
int _TCVAL[STKSIZ];
		/* default is 0                                   */
int SPVAL;	/* blank lines to be spaced down */

int CURPAG;	/* current output page number; init = 0 */
int NEWPAG;	/* next output page number; init = 1 */
int VLINENO;	/* virtual (intended) line advances on page,
			see vadv()*/
int FVLINENO;	/* + line fraction */
int PLINENO;	/* printer's actual line advances on page,
			see padv()*/
int FPLINENO;	/* + line fraction */
int PLVAL;	/* page length in lines */
int _PLVAL[STKSIZ];
int M1VAL;	/* margin before& including header in lines*/
int _M1VAL[STKSIZ];
int M2VAL;	/* margin after header in lines*/
int _M2VAL[STKSIZ];
int M3VAL;	/* margin after last text line in lines*/
int _M3VAL[STKSIZ];
int M4VAL;	/* bottom margin, including footer in lines*/
int _M4VAL[STKSIZ];
int BOTTOM;	/* end of text area in lines;start of M3+M4 */
int SCVAL;	/* space character*/
int _SCVAL[STKSIZ];
int OWVAL;	/* output device width*/
int _OWVAL[STKSIZ];
int TABSIZ;	/* spacing of tabstops*/
int _TABSIZ[STKSIZ];
int SENTENCE;	/* Nov 20*/
int CFVAL;	/*Dec 4:control flag character value*/
int _CFVAL[STKSIZ];
int ICVAL;	/*insert character*/
int _ICVAL[STKSIZ];

char LINE[ LSZ ];	/*input line buffer, Nov 26*/
char EHEAD[ LSZ ],*EH2,*EH3;	/* even header title */
char OHEAD[ LSZ ],*OH2,*OH3;	/* odd header title */
char EFOOT[ LSZ ],*EF2,*EF3;	/* even footer title */
char OFOOT[ LSZ ],*OF2,*OF3;	/* even footer title */


/* defaults for global parameters */

#define FI_DEF		1
#define	LS_DEF		1
#define	IN_DEF		0
#define	RM_DEF		60
#define	TI_DEF		0
#define	CE_DEF		1
#define	UL_DEF		-1
#define M1_DEF		2
#define M2_DEF		2
#define M3_DEF		2
#define M4_DEF		2
#define PL_DEF		66
#define FF_DEF		YES	/* .ff defaults to "on" */
#define FF_INI		NO	/* initial setting*/
#define SC_INI		BLANK
#define OW_INI		60	/*initial output width*/
#define TS_DEF		8	/*standard tabsize*/
#define TC_DEF		'~'	/*translation flag default*/
#define CF_DEF		'^'	/*Dec 4*/
#define IC_DEF		'\\'
#define CW_DEF		12	/* 12/120" */
#define JU_INI		YES	/*right justification*/
#define REGDEF 		1	/*default for register var.*/
				/*when .rg has no numeric arg*/

int DIR;	/* for "spreading" of lines    */
int OUTWRDS;	/* no. words in OUTBUF; init = 0 */
char OUTBUF[ LSZ ];	/*lines to be filled collected here */
int OUTW;	/*current display width of OUTBUF*/
int OUTPOS;	/* =strlen(OUTBUF) */
int WTOP,LTOP,OUTTOP;	/*zero|negative;levels of subscripts*/
int WBOT,LBOT,OUTBOT;	/*zero|positive;levels of subscripts*/
INT OLDLN;		/*position of previous main line*/
int OLDBOT;		/*OUTBOT for previous line;reset
			each page*/
int FRQ,FRVAL;	/* fractional line?, what fraction size*/
char *FRSTRING; /* ^ to code for fractional spacing*/
char *WHSTRING;	/* ^ to code for whole line spacing*/
char *CPTR[128-' '];	/*pointer table for print control*/
char *TPTR[128-' '];	/*pointer table for translation strings
			  for char; initialize to null */
char TRTBL[TRSIZ];	/*holds translation strings*/
char *TREND;		/*^to end of above;init = TRTBL*/
int DLINK;		/*^ head of diversion list*/
int *RLINK;		/*^ head of register variable list*/
int *SLINK,*MLINK;	/*points to head of linked
			string, macro lists*/
struct _buf *IOBUF;
/*following added for buffered and formatted output:  */
char OUTBUF2[LSZ];	/*for line to be output in fancy fmt*/
int BPOS,CP,PP;		/*buffer,column,printer positions*/
char XBUF[LSZ];		/*strikout buffer*/
int XF,XCOL;		/* " flag and column */
char UBUF[LSZ];		/*underline buffer*/
int UF,UCOL;		/* " flag and column */
int FIRST;		/*flag for first pass*/
char DBUF[LSZ];		/*double strike buffer*/
int DPOS;
int OCNT;
int MCNT;
int BLKCNT;

#define	REVSCROLL	FALSE
#define CANBS		FALSE

#define BACKSIZE	LSZ
char BACKBUF[BACKSIZE];
int BINP;	/*position in above;init to 0*/
#define BELL	'\007'
char KEYBD;		/*boolean & prompt for keyboard input*/
char KLINE[MAXLINE];	/*keyboard line input buffer*/
char *KPTR;		/*pointer for above*/

struct divfd
	{char *nm;	/*name*/
	int cs;		/*character count*/
	int ls;		/*line count*/
	struct _buf *bf; /*to iobuf if open, FALSE otherwise*/
};

#define FMAX		4	/* # of additional files open*/
int	FPTR;
struct _buf *FSTACK[FMAX];
int	TFLAG;/*added for start(), complete()*/
int XF2,UF2,MCNT2;
output:  */
char OUTBUF2[LSZ];	/*for line to be output in fancy fmt*/
int BPOS,CP,PP;