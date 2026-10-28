
/*
**   CFLOW.C : find module call structure of c program
**   refer to cflow.doc for how to use
**	
**		 copyright 1984 by Mark Ellington
**
**     released for public domain use only
**     
*/

#define TRUE	1
#define	FALSE	0
#define	ERROR	-1
#define	EOF	-1	

#include printf.c
#include b:cflolib.c80   /* not needed with BDS? */ 

int fptr;       /* input file pointer */ 
int level;      /* keep track of level of open "{"s */
char name[100]; /* module name buffer */

char ins[100];  /* source input line buffer */
int curchar;	/* current character in input line buffer
		   array subscript */ 	

main(argc,argv)
int argc; char *argv[];
{

	printf("\nCFLOW --> \n");

	if (argc != 2) {
		printf("\nusage: cflow [infilename.ext] "); 
                exit();
	}

	if ((fptr = fopen(argv[1],"r")) == FALSE) {
		printf("\nCan't open %s\n",argv[1]);
		exit();
	}

	printf("\nSource file: %s",argv[1]);

	modules(); 

	fclose(fptr);
}


modules()    /* find function declarations and calls */
{
	int j;
	char c;
	int incom;	/* comment flag */
	int decl;	/* module declaration line flag */
	int lastlin;	/* last line of file flag */
	int quoted;	/* within " quotes */
	int header;	/* within function header (before 1st '{') */

	incom = lastlin = quoted  = header = FALSE;

	level = 0;

	do {

		lastlin = fgets();    /* read a line of source */
		
		decl = FALSE;  /* assume nothing */
		curchar = 0;
		while (curchar < 100) {/* read for significant characters */

			if (skipline()) break;

			quotes();	/* skip single quoted character */

			incom = comment(incom);	/* true if in comment */

			c = ins[curchar];
		
			/* read for significant characters */

			if (!incom) {

				/* skip double quoted strings */
			
				if (c == '\042') quoted = !quoted;
				
				if (!quoted) {
			
				    switch(c) { 

					case '{' :	
						level++;
						header = FALSE;
						break;

					case '}' :	
						level--;
						break;	

					/* "(" always follows function call */
            				/* or declaration */
			
					case '(' :	

					if (!ischar(ins[curchar-1])) 
						break;
					lookbak(curchar);
					j = modname();
					if (!j) break;
					else decl = TRUE;
					if (j == 2) 
						header = TRUE;	
					break;


       		   			default : 
						  break;
				    }
				}
			}
		
			++curchar;     /* next character */
		}
		
	        /* display argument declarations */
		comout(ins); 			
		if (header && !decl) printf("%s",ins);

	} while (lastlin);    /*  = 0 if last line */

}

/* skip this line ? */

skipline()
{
char c;
	c = ins[curchar];

	if (c == '\0') return(TRUE);	/* end of line */

	else if (c == '#')    		/* skip macro defs */
		if (curchar < 5)	/* at beginning of line */
			if (!strcmp("define",&ins[curchar+1])) 
				return(TRUE); 

	else return(FALSE);    		/* no */

}


/* skip characters quoted (for instance '}' would throw off level count */

quotes()
{  
	if (flowchar(ins[curchar]))	    /* test critical chars only */
	    if (ins[curchar+1] == '\047')   /* next char single quote? */
		if (curchar+2 < 100)	    /* don't pass end of string */
			curchar = curchar + 2; /* skip past quote */
}


/* return TRUE if entering comment, FALSE if exiting */

comment(incom)
int incom;
{
	if (ins[curchar] == '/') {
		if (ins[curchar+1] == '*') 
			if (curchar + 1 < 100)	/* stay within string */ 
				return(TRUE);
		else if (ins[curchar-1] == '*')
			if (curchar - 1 >= 0)   /* stay within string */
				return(FALSE);
	}
	else return(incom);  /* unchanged */
}


/* look back from position n in string.  called with n indicating '('.
   determine function name  */

lookbak(n)
int n;
{
	int i;

	while (!ischar(ins[n])) {
		if (n == 0) break;
		--n;
	}

	/* find leading blank */
	while (ischar(ins[n-1])) {
		if (n == 0) break;
		--n;
	}

	/* save name */
	/* include variable declarations if module declaration */

	i = 0;
	if (level == 0) {
		while (ins[n]) 		    /* full line if declaration */
			name[i++] = ins[n++];
	}
	else {
		while (ischar(ins[n]))      /* function call within function */
			name[i++] = ins[n++];
	}

	name[i] = '\0';

	comout(name);	/* remove comment from name string */
		
}


/* terminate string at comment */

comout(s)
char *s;
{
char c;	
	
	while(c = *s++) 
		if (c == '/')
			if (*s == '*') {
				--s;
				*s++ = '\n';
				*s = '\0';
				break;
			}

}



/* display module name with indentation according to { level */
/* returns 0 if not module, 1 if call within module, 2 if    */
/* module declaration  */

modname()
{
	int j;

	if (unreserved()) {		/* test if builtin like while */
	    	if (level == 0) {
			printf("\n\n\n");
			printf("**\n");
			comout(ins);
			printf("%s",ins);
			return(2);
                }
		else {
			printf("\n");
			for (j=0; j < level; ++j) 
				putchar('\t');
			printf("%s()",name);
			return(1);
		}
        }
	return(0);
	
}

/* test for names that are operators not functions */

unreserved()
{

	if (!strcmp(name,"return")) return(0);
	else if (!strcmp(name,"if")) return(0);
	else if (!strcmp(name,"while")) return(0);
	else if (!strcmp(name,"for")) return(0);
	else if (!strcmp(name,"switch")) return(0);

	else return(1);

}


/* test if character is one that program tracks */

flowchar(c)
char c;
{
	if (c == '{' || c == '}' || c == '\"') return(TRUE);
	else return(FALSE);
} 
	


/* test for character */

ischar(c)
char c;
{
	if (isalpha(c) || isdigit(c)) return(TRUE);
	else return(FALSE);
}


/* read a line of source */

fgets()
{
	char ch, *s;
	s = ins;
	while ((ch = getc(fptr)) != EOF) {
		*s++ = ch;
		if (ch == '\n') {
			*s = '\0';
			return(TRUE);
		}
	}
	*s = '\0';
	return(FALSE);

}	
	


