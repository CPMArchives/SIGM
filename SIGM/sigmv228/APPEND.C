
/*
**    append.c    
**
**    public domain use only    Mark Ellington 
**
**    This program appends two files to make a third, larger file.
**    Arguments are taken from the command line.  Text files only. 
**
*/

/*
   append two files into destination file  
*/

#include printf.c


int fptr, f1ptr, f2ptr;
char temp[30];
static char ins[100];


main(argc,argv)
int argc; char *argv[];
{
char *s, *sc;
char sv[3];
char c;

	if (argc != 4) {
		printf("\nusage: append [infilename1.ext] "); 
		printf("[infilename2.ext] [outfile.ext]");
                exit();
	}

	if ((f1ptr = fopen(argv[1],"r")) == 0) {
		printf("\nCan't open %s\n",argv[1]);
		exit();
	}
	printf("\n%s open to read",argv[1]);


	if ((f2ptr = fopen(argv[2],"r")) == 0) {
		printf("\nCan't open %s\n",argv[2]);
		exit();
	}
	printf("\n%s open to read\n",argv[2]);


	if ((fptr = fopen(argv[3],"w")) == 0) {
		printf("\nCan't open %s\n",argv[3]);
		exit();
	}
	printf("\n%s open to write\n",argv[3]);


	transfer(f1ptr);

	transfer(f2ptr);

	printf("\n\nExiting append\n");

	fclose(fptr);
	fclose(f1ptr);
	fclose(f2ptr);
}


transfer(ptr)
int ptr; 
{
	while (fgets(ptr) != 0) {
		fputs(fptr);
	} 
	fputs(fptr);
}


fgets(f)
int f; 
{
	char ch, *s;
	s = ins;
	while ((ch = getc(f)) != -1) {
		*s++ = ch;
		if (ch == '\n') {
			*s = '\0';
			return(1);
		}
	}
	*s = '\0';
	return(0);
}	
	

fputs(f)
int f;
{
	char *s;
	s = ins;
	while(*s) putc(*s++,f);
}









