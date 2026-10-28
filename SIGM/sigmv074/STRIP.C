/*
Usage: STRIP <infile> <outfile>

This program strips the high order bit from each byte in <infile> and
creates <outfile> from the stripped data.

Modifications:

15/Jun/1982
Originally from BDS "C" UG but took forever to run due to printing
a running total of characters processed. Modified to print only a
total character count at the end. Bill Bolton, Softwate Tools,
Australia. 

*/

#include bdscio.h
#define INFILE 1
#define OUTFILE 2

main(argc, argv)

int argc;
char *argv[];

{
int i;
int input;
char wrkbuf[BUFSIZ];
char wrkbuf2[BUFSIZ];

i=0;


if (argc!=3) {
	prtuse();
	return;
	}

if (fopen(argv[INFILE],wrkbuf)==ERROR){
	printf("\nCan't open %s",argv[INFILE]);
	prtuse();
	return;
	}
if (fcreat(argv[OUTFILE],wrkbuf2)==ERROR){
	printf("\nCan't open %s",argv[OUTFILE]);
	prtuse();
	return;
	}
while(((input=getc(wrkbuf))>0)&&(putc((input & 0x7f), wrkbuf2)!=ERROR)){
		++i;
	}
printf("\n%d characters processed.\n",i);
if (putc(CPMEOF,wrkbuf2)<0){ 
	printf("\nCan't write end of file marker in %s",argv[INFILE]);
	}
if((fclose(wrkbuf)<0)) {
	printf("\nCan't close %s",argv[INFILE]);
	}
if(((fflush(wrkbuf2)<0)||(fclose(wrkbuf2)<0))){
	printf("\nCan't close %s",argv[OUTFILE]);
	}
}

prtuse()
{
printf("\nUSAGE: strip <infile> <outfile>");
}
