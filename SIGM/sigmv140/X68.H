/*	Global variable header file for X68 Assembler	*/
/*
 *	PERMISSION IS GRANTED FOR THE PUBLIC DOMAIN
 *	NON COMMERCIAL USE OF THIS SOFTWARE.
 *
 *	(C) CHRIS UNDERY 25th OCTOBER 1982
 *	11 MARGARET ST NEWTOWN 2042
 *	SYDNEY, AUSTRALIA
 */

#include "bdscio.h"
#define NUL '\0'		/* null string definition		*/
#define COMMA ','		/* Comma delimiter			*/
#define TAB '\t'		/* white space character		*/
#define SP " "			/* single space				*/
#define SP2 "  "		/* two spaces				*/
#define SP4 "    "		/* four spaces				*/
#define QUOTE 0x27		/* ASCII Quote				*/
#define LINELEN 150		/* maximum length of source line	*/
#define SYMSIZE 8		/* maximum # of characters in a symbol	*/
char obuf[BUFSIZ];		/* GP input buffer			*/
char ibuf[BUFSIZ];		/* GP output buffer			*/
char ifile[BUFSIZ];		/* include file 			*/
int lineno;			/* current line number of source file	*/
int numlines;			/* total number of lines assembled	*/
int decad;			/* assembler location counter		*/
int dec;			/* temp global variable			*/
int dlabad;			/* Decimal copy of branch addresss	*/
int sourcef, prnf;		/* FCB pointers				*/
int symf, hexf, nemf;		/* FCB pointers				*/
int errors;			/* Total errors count			*/
int useage;			/* Symbol table useage			*/
int nb;				/* Number of bytes in this expansion	*/
int offset;			/* Offset for Relative addresses	*/
int colum1, colum2;		/* For use with field function		*/
int indx1,indx2,indx3;		/* String operation indices		*/
int linecnt, pageno;		/* Listing control variables		*/
int bcc;			/* Intel checksum			*/
int xptr;			/* Expresssion evaluation pointer	*/
int bias;			/* Prom burner bias factor		*/
int numbytes;			/* number of bytes of code produced	*/
int checksum;			/* assembler generated global checksum  */
char xp1[20], xp2[20];		/* Sub-sub expression registers		*/
char operator, hex[5];		/* Hex conversion buffer		*/
char line[LINELEN+100];		/* source file input line buffer	*/
char title[64];			/* title of listing 			*/
char symn[16];			/* Symbol file name			*/
char hexname[16];		/* Hex file name buffer			*/
char label[SYMSIZE];		/* label field				*/
char mnem[SYMSIZE];		/* mnemonic field			*/
char subexp[LINELEN];		/* Sub-expression for opnd evaluation   */
char operand[LINELEN];		/* operand field			*/
char comment[LINELEN];		/* comment field			*/
char hexad[SYMSIZE];		/* hex result field			*/
char labrec[SYMSIZE];		/* symbol tree search key field		*/
char inst[SYMSIZE];		/* 6800 Hex inst from OPTAB table	*/
char class[SYMSIZE];		/* Operand Class descriptor		*/
char dest[4];			/* Mnemonic lookup descriptor		*/
char temp[LINELEN];		/* String op scratch buffer		*/
char hexrec[50];		/* Intel hex file record		*/
char binrec[25];		/* as above				*/
char i1[4];			/* Instruction byte 1			*/
char i2[4];			/* Instruction byte 2			*/
char i3[4];			/* Instruction byte 3			*/
char m4[4];			/* Instruction byte 4			*/
char brad[5];			/* Branch address 			*/
char labad[5];			/* Relative branch offset		*/
char filename[16];		/* Primary file name of job 		*/
char symname[16];		/* Symbol file name			*/
char lstname[16];		/* List file name			*/
char printing;			/* True if outputting to printer	*/
char iname[16];			/* include file name			*/
char syming;			/* True if outputting symbol table 	*/
char xing;			/* True if writing HEX file 		*/
char mloading;			/* True if including OBJECT code	*/
char including;			/* True if including source code	*/
char yanking;			/* True if using old symbol table	*/
char listing;			/* True if writing .PRN file		*/
char debug;			/* True if .TMP file not to be erased	*/

#define HASHSIZE 100		/* Modulo of hash bucket pointer list   */
#define NKEYS 108		/* Number of entries in OPTAB+1		*/

/*	Prototypical symbol table definition	*/

struct nlist {
	char *name;		/* Symbol name string 	*/
	char *def;		/* Numeric value of symbol	*/
	struct nlist *next;	/* Hash group chain pointer	*/
};

/*	Prototypical opcode binary lookup table	*/

struct key {
	char keyword[5];	/* Motorola 6800 mnemonics list	*/
	char hexcode[3];	/* Hex value of mnemonic	*/
	char use[2];		/* Steering byte		*/
};

struct key v[NKEYS];		/* Mnemonic lookup table	*/
struct nlist *hashtab[HASHSIZE]; /* HASHSIZE bucket pointers	*/

struct nlist *last;		/* keeps track of last node read */
