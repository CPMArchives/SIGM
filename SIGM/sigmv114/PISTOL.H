/*********************************************************/
/*							 */
/* PISTOL-Portably Implemented Stack Oriented Language	 */
/*			Version 2.0			 */
/* (C) 1983 by	Ernest E. Bergmann			 */
/*		Physics, Building #16			 */
/*		Lehigh Univerisity			 */
/*		Bethlehem, Pa. 18015			 */
/*							 */
/* Permission is hereby granted for all reproduction and */
/* distribution of this material provided this notice is */
/* included.						 */
/*							 */
/*********************************************************/
/* for PISTOL v2.0 in BDS 'C' v1.45a */
/* September 5, 1982 */

#define	W		2
#define VERSION		20
#define	RAMSIZE		5000
#define RAMMIN		-21	/* most negative constant */
#define COMPBUF		RAMSIZE-W*200
#define NSAVE		124	/* used by coredump&restore */
#define STRINGSSIZE	NSAVE*128-W*RAMSIZE+W*RAMMIN
#define LINEBUF		3300
#define NFUNCS		73

#define	SSIZE		200
#define LSIZE		30
#define CSIZE		30
#define	RSIZE		30
#define	VBASE		41
#define VSIZE		8
#define CHKLMT		20
#define MAXORD		128
#define	MAXINT		32767
#define MININT		-32768
#define MAXLINNO	300
#define NAMESIZE	20

#define	FALS		0
#define TRU		-1
#define NEWLINE		10	/* for 'C' */
#define RPROTECT	TRU
#define WPROTECT	TRU

#define TERMWIDTH	64
#define TERMLENGTH	20

#define PSEMICOLON	0
#define WSTORE		1
#define TIMES		2
#define	PLUS		3
#define	SUBTRACT	4
#define	DIVMOD		5
#define PIF		6
#define WAT		7
#define ABRT		8
#define SP		9
#define LOAD		10
#define	PELSE		11
#define WRD		12
#define RP		13
#define DROPOP		14
#define PUSER		15
#define EXEC		16
#define EXITOP		17
#define LIT		18
#define STRLIT		19
#define RPOP		20
#define SWP		21
#define TYI		22
#define TYO		23
#define RPSH		24
#define SEMICF		25
#define RAT		26
#define COMPME		27
#define COMPHERE	28
#define DOLLARC		29
#define COLON		30
#define SEMICOLON	31
#define IFOP		32
#define ELSEOP		33
#define THENOP		34
#define DOOP		35
#define LOOPOP		36
#define BEGINOP		37
#define ENDOP		38
#define REPET		39
#define PERCENT		40
#define PDOLLAR		41
#define PCOLON		42
#define CASAT		43
#define PDOOP		44
#define PPLOOP		45
#define PLLOOP		46
#define CAT		47
#define CSTORE		48
#define PLOOP		49
#define DOTDOT		50
#define SEMIDOL		51
#define PRMQ		52
#define CORDMP		53
#define RESTOR		54
#define SAT		55
#define FINDOP		56
#define LISTFIL		57
#define VFINDOP		58
#define LAT		59
#define OFCAS		60
#define CCOLON		61
#define SEMICC		62
#define NDCAS		63
#define POFCAS		64
#define PCCOL		65
#define PSEMICC		66
#define GTLIN		67
#define WORD		68
#define OPENR		69
#define OPENW		70
#define READL		71
#define WRITL		72

char ldfil[BUFSIZ],list[BUFSIZ]; /* will overlay init() */

union word
	{int in;
	char cr;
	unsigned un;
	char *pc;
	union word *pw;
	};

char jbuf[JBUFSIZE]; /* to use in setjmp(),longjump() */

unsigned ip;	/* but can be used for machine addresses */
unsigned instr;
int	temp;
int	savlevel,savinstr;	/*for trace in interpret();*/

int	stkptr;
int	rptr;
int	lptr;
int	cptr;

int	*Pw,*Pw2;	/* needed for pointer conversions */
char	*Pc,*Pc2;	/* needed for pointer conversions */

int	(*farray[NFUNCS])(); /* to hold pointers to interpreted
				primitive functions */
int	mstack[3];	/* extra padding */
int	stack[SSIZE];
int	pstack[3];	/* extra padding */
int	lstack[LSIZE];
int	rstack[RSIZE];
int	cstack[CSIZE];

char	imagename[NAMESIZE];
char	namein[NAMESIZE];
char	namout[NAMESIZE];
char	infil[NAMESIZE];
char	listname[NAMESIZE];
char	c;/*??? assignable to eof()?*/
char	nullname;

char	*feof;
char	*nopen;
char	*id;
char	*synt;
char	*ovflo;
char	*undflo;
char	*redef;
char	*divby0;
char	*readv;
char	*writv;

int	addr;
int	val;
int	i,j;

union word nram[-RAMMIN]; /* space for negative args for ram */
union word ram[RAMSIZE];
char	strings[STRINGSSIZE];

char edin[BUFSIZ],edout[BUFSIZ];/*for editor file i/o buffs */
/*"static variables" for vfind,pstrcmp*/
int *ptoken;
int *vloc;
char vmatch;
char pcount,*Pc3;
int *prev;

/* "static" for ttyi() */
char keycurs,keylen,keystring[MAXORD];

/* "static" for pdo() */
int start,nd;

/* "static" for move() */
char *as,*ad,*endaddr;
int nowd;

/* "static" for swap() */
int hold;

/* "static" for many interpreter functions */
int tos,ntt,param;

/* "static" for compline() */
int inf,*pad;

/* "static" for slit() and longstring() */
char ic, *sstart;

/* "static" for intoken() */
char count, *ptr2;

/* "static" for convert() */
char *tend;

/* "static" for touchup() */
int ref;
ar	nullname;

char	*feof;
char	*nopen;
char	*id;
char	*synt;
char	*ovflo;
char	*undflo;
char	*redef;
char	*divby