
/*
**    split.c
**             public domain use only 
**
**    copyright 1984  Mark Ellington
**
**    This program splits a large file into two smaller files. 
**    All input is on the command line;  the last argument is the
**    number of bytes to go into the first output file.  The remainder
**    of the input file goes into the second output file.  Study the code
**    to see how this works. 
**
*/

/*   split file into two smaller files  
*/


#include printf.c


int fptr, f1ptr, f2ptr;
char temp[30];
static char ins[100];
int nbytes;

main(argc,argv)
int argc; char *argv[];
{
char *s, *sc;
char sv[3];
char c;

	if (argc != 5) {
		printf("\nusage: split [infilename.ext] "); 
		printf("[outfile1.ext] [outfile2.ext] [# bytes]");
                exit();
	}

	if ((fptr = fopen(argv[1],"r")) == 0) {
		printf("\nCan't open %s\n",argv[1]);
		exit();
	}
	printf("\n%s open to read",argv[1]);

	if ((f1ptr = fopen(argv[2],"w")) == 0) {
		printf("\nCan't open %s\n",argv[2]);
		exit();
	}
	printf("\n%s open to write\n",argv[2]);

	if ((f2ptr = fopen(argv[3],"w")) == 0) {
		printf("\nCan't open %s\n",argv[3]);
		exit();
	}
	printf("\n%s open to write\n",argv[3]);

	if (atoi(argv[4]) <= 0) {
		printf("\n# bytes in first segment entered incorrectly");
		exit();
	}  

	filter(f1ptr,atoi(argv[4]));

	filter(f2ptr,30000);			

	printf("\n\nExiting split\n");

	fclose(fptr);
	fclose(f1ptr);
	fclose(f2ptr);

}




filter(ptr,nb)
int ptr; int nb;
{

	char *sptr;
        int n;
	int sumbytes = 0;

	while (fgets(fptr,ins) != 0) {
			
		for (n=0;n<100;n++) {
                        ++sumbytes;
	                if (ins[n] == '\0') break;
		} 
					
		puts(ins);
		fputs(ptr,ins);
		if (sumbytes >= nb) break;

	}

}





fgets(f,s)
int f; char *s;
{
	char ch;

	while ((ch = getc(f)) != -1) {
		*s++ = ch;
		if (ch == '\n') {
			*s = '\0';
			return(1);
		}
	}
	return(0);
}	
	



puts(s)
char *s;
{
	while (*s) putchar(*s++);
}




fputs(f,s)
int f; char *s;
{
	while(*s) putc(*s++,f);
}



strcat(s1,s2)     /* concatenate two strings */
char *s1, *s2;
{
	static char t[20]; 
	char *tp;
	tp = t;

	while (*s1) {
		*tp++ = *s1++;
	}
	
	do *tp++ = *s2; while (*s2++);

	return(t);

}



atoi(n) /* convert ascii string to integer */
char *n;
{
	int val; 
	char c;
	int sign;
	val=0;
	sign=1;
	while ((c = *n) == '\t' || c== ' ') ++n;
	if (c== '-') {sign = -1; n++;}
	while (isdigit(c = *n++)) val = val * 10 + c - '0';
	return(sign*val);
}


isdigit(c)
char c;
{
	return(c >= '0' && c <= '9');
}







