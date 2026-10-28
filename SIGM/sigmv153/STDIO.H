/*	standard i/o header file for c86
*/

#define NULL 0
#define EOF (-1)	/* standard end of file */
#define EOS '\0'	/* standard end of string */
#define stdin 0x8000	/* standard input */
#define stdout 0x8001	/* standard output */
#define stderr 0x8002	/* standard error */
#define AREAD 0		/* ascii read */
#define AWRITE 1	/* ascii write */
#define AUPDATE 2	/* ascii update (take care with this one) */
#define BREAD 4		/* binary update */
#define BWRITE 5	/* binary write */
#define BUPDATE 6	/* binary update */
typedef char FILE;
#define getchar() fgetc(stdin)
#define getc(x) fgetc(x)
#define putchar(x) fputc(x,stdout)
#define putc(x,y) fputc(x,y)
#define ungetch(c) ungetc(c,stdin)

/*	following definition for setjmp and longjmp
*/

typedef int jmp_buf[3];

/*	end of standard header file
*/
