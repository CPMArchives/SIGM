/* 

word count program which also calculates column centimetres 
of magazine (or newspaper) copy for would-be contributors. 
Set up for Helvetica Medium phototype which is the body copy 
used in Your Computer magazine, but can be easily changed 
for others. Original structure taken from `The C Programming 
Language', and substantially modified since then by Les Bell and
Matt Whelan...

Version 1.02, 20/7/82
*/


#include	<b:bdscio.h>

#define	YES	1
#define	NO	0
#define	EOF	0x1a
#define ERROR	-1
#define MASK	0x7f

char toupper();		

main(argc,argv)	/* count lines, words, chars in input file */
char	**argv;
{
	int c, nl, nw, nc, inword, fd, m;
	char	buf[BUFSIZ];

	if(argc != 2) {
		printf("Usage: wc filename\n");
		exit();
	}

	if((fd = fopen(argv[1],buf)) == ERROR) {
		printf("cannot open: %s\n",argv[1]);
		exit();
	}
	inword = NO;
	nl = nw = nc = 0;
	while ((c = (getc(buf) & MASK)) != EOF)
	{
		++nc;
		if (c == '\n')
			++nl;
		if (c == ' ' || c == '\n' || c == '\t' || c == 0x0d)
			inword = NO;
		else if (inword == NO) {
			inword = YES;
			++nw;
		}
	}
	menu();
	while (m != "5") {                 /* the m!=5 is irrelevant, but at
					      least sets up the loop */
	printf("\n\nWhich would you like?   : ");
	m = getchar();
		switch (toupper(m)) {

		case '1':
			printf("\n\n\n");
			printf("\t\tnumber of chars = %d\n",nc);
			printf("\t\tnumber of lines = %d\n",nl);
			printf("\t\tnumber of words = %d\n",nw);
			printf("\t\tcolumn centimetres = %d\n",nw/20);
			break;
		case '2':
			printf("\n\n\n");
			printf("\t\tnumber of chars = %d\n",nc);
			printf("\t\tnumber of lines = %d\n",nl);
			printf("\t\tnumber of words = %d\n",nw);
			printf("\t\tcolumn centimetres = %d\n",nw/24);
			break;
		case '3':
			printf("\n\n\n");
			printf("\t\tnumber of chars = %d\n",nc);
			printf("\t\tnumber of lines = %d\n",nl);
			printf("\t\tnumber of words = %d\n",nw);
			printf("\t\tcolumn centimetres = %d\n",nw/12);
			break;
		case '4':
			printf("\n\n\n");
			printf("\t\tnumber of chars = %d\n",nc);
			printf("\t\tnumber of lines = %d\n",nl);
			printf("\t\tnumber of words = %d\n",nw);
			printf("\t\tcolumn centimetres = %d\n",nw/28);
			break;
		case 'X':
			printf("\n\n\n");
			printf("\t\tnumber of chars = %d\n",nc);
			printf("\t\tnumber of lines = %d\n",nl);
			printf("\t\tnumber of words = %d\n",nw);
			printf("\n\nbibi\n");
			exit();
		case 'M':
			menu();
			break;
		default:
			putch(7);
			printf("\n\nEnter 1-4 for measure, M for menu");
			break;
			}
		}
}

menu()
{
	printf(CLEARS);		/* Hope you have screen-clear defined
				   in bdscio.h			    */ 
	printf("\n\n\n\n");
	printf("\t\tSELECT:\n");
	printf("\n\n");

	printf("\t\t<1> ---> 9/10 x 13 1/2 ems\n");   /*9point type, 1point
						    leading - the standard 
						    3-column type used in the
						    magazine                */

	printf("\t\t<2> --->  8/9 x 13 1/2 ems\n");   /*slightly smaller type 
							over same column with 
							- used for copy with 
							"pocket programs"*/

	printf("\t\t<3> ---> 9/10 x  9 1/2 ems\n");   /*normal type size, 
							narrow column width 
							for news and "clinic" 
							pages */

	printf("\t\t<4> ---> 9/10 x 20 1/2 ems\n");   /* 2-column (1/2-page) 
							 width*/

	printf("\t\t<X> ---> ++ eXit ++\n");

}
