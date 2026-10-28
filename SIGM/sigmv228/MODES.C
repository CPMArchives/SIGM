

/*
**   modes.c
**
**       public domain use only   Mark Ellington   1984
**
**  This program provides easy menu selection of some options
**  of the Epson RX-80 and compatible printers.  
**
*/



/* printer modes */


main()
{
	char s[3];
        int n;

	putchar(0x1a);

	puts("Printer mode selection:\n\n");

	puts("0: Exit.\n");
	
	puts("1: Emphasized mode on.\n");

	puts("2: Emphasized mode off.\n");

	puts("3: Double-strike on.\n");

	puts("4: Double-strike off.\n");

	puts("5: Elite mode on.\n");

	puts("6: Elite mode off.\n");

	puts("7: Compressed mode on.\n");

	puts("8: Compressed mode off.\n");

	puts("9: Set tabs.\n");

	puts("10: Skip-over-perforation OFF.\n");

	puts("11: Graphics character set on.\n");

	puts("12: Graphics character set off.\n");

	puts("13: Reset.\n"); 

	n = 1;
        while (n != 0) {
		gets(s);
		n = atoi(s); 
		switch(n) {
			case 1: newmode('E');
				break;	
			case 2: newmode('F');
				break;	
			case 3: newmode('G');
				break;
			case 4: newmode('H');
				break;	
			case 5: newmode('M');
				break;	
			case 6: newmode('P');
				break;
			case 7: nbr(15);
				break;
			case 8: nbr(18);
				break;	
			case 9: tabs();
				break;
			case 10: newmode('O');
				break;
			case 11:  
                               	newmode('m');
				nbr(4);
				break;
			case 12:  
                               	newmode('m');
				nbr(0);
				break;
			case 13: newmode(64);
				break;
			default: break; 
	  	}
	}
}


/* single byte to printer */

nbr(n)
char n;
{
	bdos(5,n);
}



/* escape sequence to printer  "ESC byte" */

newmode(c)
char c;		/* byte */
{
	bdos(5,27);	/* ESC */
	bdos(5,c);	/* command char */
}




tabs()
{
	char n;
	char s[4];

	puts("\nEnter number spaces per tab: ");
	gets(s);
	n = atoi(s);

	bdos(5,27);		/* ESC */
	bdos(5,'e');		/* e */
	bdos(5,'0');		/* 0 */
	bdos(5,n);		/* n spaces */

}





/* get string of input into array */

gets(stri)
char stri[80];
{ 
char c;
int i;

	while ((c = getchar()) != '\n') {
		stri[i++] = c;
	}	
	stri[i] = '\0';

	return(stri[0]);    /* return 1st char */
}






/* convert byte string to integer */

atoi(s)  char s[8];  
{
	int i;
	unsigned int n;

	n = 0;
	for (i = 0; s[i] >= '0' && s[i] <= '9'; ++i)
		n = 10 * n + s[i] - '0';
	return(n);
}




/* CP/M direct system call routine */

bdos(funct,value)	
int funct, value;
{
funct;	/* pass C reg data */
#asm
;
;  machine code CP/M system BDOS call 
;
BDOS	EQU	0005H	;BDOS entry
;
	MOV	C,L
;
#endasm

value;
#asm
	MOV	E,L
	MOV	D,H
;
	CALL	BDOS	;CALL CP/M 
	MOV	L,A
	MVI	H,0	
	RET	
#endasm
}





/* string to console */

puts(s)
char *s;
{

	while (*s) putchar(*s++);

}







