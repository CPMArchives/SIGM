/*********************************************************/
/*							 */
/* PISTOL-Portably Implemented Stack Oriented Language	 */
/*			Version 1.3			 */
/* (C) 1982 by	Ernest E. Bergmann			 */
/*		Physics, Building #16			 */
/*		Lehigh Univerisity			 */
/*		Bethlehem, Pa. 18015			 */
/*							 */
/* Permission is hereby granted for all reproduction and */
/* distribution of this material provided this notice is */
/* is included.						 */
/*							 */
/*********************************************************/
/* February 24, 1982 */

#define VERSION		13
#define	RAMSIZE		4000
#define COMPBUF		RAMSIZE-250
#define STRINGSSIZE	5196	/* chosen to even out blocks */
#define NSAVE		104	/* used by coredump&restore */
#define LINEBUF		2800
#define NFUNCS		75
#define	W		2

#define	SSIZE		200
#define LSIZE		30
#define CSIZE		30
#define	RSIZE		30
#define	VBASE		1
#define VSIZE		8
#define CHKLMT		20
#define MAXORD		128
#define	MAXINT		32767
#define MAXLINNO	300
#define NAMESIZE	20

#define	FALS		0
#define TRU		-1
#define NEWLINE		13

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
#define GT		50
#define SEMIDOL		51
#define KRNQ		52
#define SAT		55
#define FINDOP		56
#define LISTFIL		57
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
#define CORDMP		73
#define RESTOR		74

union word
	{int in;
	unsigned un;
	char *pc;
	union word *pw;
	};
int	ip;	/* but can be used for machine addresses */
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

char	imagename[NAMESIZE];	/*name[0]=length*/
char	namein[NAMESIZE];	/*name[length+1]=0*/
char	namout[NAMESIZE];
char	infil1[NAMESIZE];
char	listname[NAMESIZE];
char	c;
char	nullname;

char	*feof;
char	*nopen;
char	*id;
char	*synt;
char	*ovflo;
char	*undflo;
char	*redef;
char	*divby0;

int	addr;
int	val;
int	i,j;

union word nram[58];	/* space for negative args for ram */
union word ram[RAMSIZE];
char	strings[STRINGSSIZE];

char ldfil1[BUFSIZ],list[BUFSIZ],edin[BUFSIZ],
	edout[BUFSIZ];
/*"static variables" for vfind,pstrcmp*/
int *vloc;
char vmatch;
char pcount,*Pc3;
 in inter