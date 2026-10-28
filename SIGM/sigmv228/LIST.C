

/*
**    list.c
**
**    for public domain use only      by Mark Ellington
**
**   
**    This program accepts filenames as arguments from the command line
**    and prints the file contents to the LST: device.  You can list
**    as many files as will fit on the command line, one file after
**    another.
**
**
*/



#define ASCIEOF -1
#define NULL 0


char linbuf[130];
int *inptr, *outptr;

/* files to LST: line at a time */

main(argc,argv)
char *argv[];
{
int n;
	
    n = 0;	
    while(n < argc) {

	++n;
	inptr = fopen(argv[n],"r");
	if (!inptr) {
		puts(argv[n]);
		puts(" finished or error opening input file\n");
		exit();
	}

	outptr = fopen("LST:","w");
	if (!outptr) {
		puts("error opening list device\n");
		exit();
	}

        /* list filename */

	puts("\nListing file:  "); 
	fputs("\nListing file:  ",outptr);
	puts(argv[n]);
	fputs(argv[n],outptr);
	puts("\n\n");
	fputs("\n\n",outptr);
	
	/* file to lst line at a time */
	
	while (fgets(linbuf,inptr)) {
		puts(linbuf);
		fputs(linbuf,outptr);
	}
	
	fclose(inptr);
	
	/* ff */

	putc(12,outptr);    
	putc(0,outptr);
	

    }	/* while until all args read */

}



/* read string of input from a file */

fgets(ptr,infile)
char *ptr;
int infile;
{
	int n,c;
	char *cs;

	n = 120;   /* max length */
	cs = ptr;
	while ( (--n > 0) && ((c = getc(infile)) != ASCIEOF) )
		if ((*cs++ = c) == '\n') break;
	*cs = '\0';	
	return((c == ASCIEOF && cs == ptr) ? NULL : ptr);
}

		
/* send string to console and list device */

fputs(s,outfile)
char *s;
{
	while (*s) 
		putc(*s++,outfile);
}
		

/* send string to console */

puts(s)
char *s;
{
	while (*s) 
		putchar(*s++);
}






