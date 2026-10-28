/* program to edit DDT disassembly listing
	- 4 digit hex values converted to labels
	- 2 digit hex values converted to 000H format
	- addresses stripped from instructions
	- lines not commencing with an address commented out
	- labels in assembly range included with instructions
	- labels out of range set by EQU statements */

#include <bdscio.h>
#define TAB 0x09
#define HEX "%x"
#define OUTRANGE 1
#define INRANGE 0
#define ENTER 1
#define SEEK 0
#define STMAX 1024
#define BUFFER struct _buf

BUFFER	ib,ob,*inbuf,*outbuf;	/* file buffers */
char	*infile,*outfile,	/* file names */
	linebuffer[80],		/* space for line string */
	*line, *linept,		/* line and pointer */
	tokenbuffer[80],	/* space for token string */
	*token,			/* last token read */
	delim;			/* token delimiter */
int	labval,opval,		/* label and operand values */
	disk;			/* write to disk flag */
int	st[STMAX],stp;		/* symbol table and index */
char	stf[STMAX];		/* symbol defined flags */

main(argc,argv)
	int	argc;
	char	*argv[];
{
	printf("\nDDTTOMAC version 1.0");
	printf("\n(C) 1981 FBN Software");
	if (argc > 3)
		error("too many parameters");
	if (argc < 2)
		error("no source file specified");
	infile = argv[1];
	if (disk = (argc == 3)) outfile = argv[2];
	inbuf = & ib;
	outbuf = & ob;
	line = &(linebuffer[0]);
	token = &(tokenbuffer[0]);
	stp = 1;
	edit();
	printf("function complete");
}


edit()
{	/* process passes */
	if (fopen(infile,inbuf) == -1)
		error("source file not found");
	pass1();
	fclose(inbuf);
	if (fopen(infile,inbuf) == -1)
		error("cannot reopen source");
	if (disk)
		if (fcreat(outfile,outbuf) == -1)
			error("no directory space");
	pass2();
	if (disk){
		putc(CPMEOF,outbuf);
		fflush(outbuf);
		fclose(outbuf);
		}
}


pass1()
{	/* scan through file building symbol table */
	printf("\npass 1\n");
	while (fgets(line,inbuf))
		if (argscan())
			stsearch(opval,ENTER);
}


pass2()
{	/* rescan using symbol table to perform editing */
	int	i;
	printf("\npass 2\n");
	for (i = 0; i < stp; stf[i++] = OUTRANGE);
	while (fgets(line,inbuf)){
		linept = line;
		gettoken();
		if (isword(&labval)){
			label();
			opcode();
			operand();
			}
		else{
			if (disk) putc(";",outbuf);
			else putchar(';');
			if (disk){
				if (fputs(line,outbuf) == -1)
					error("disk full");
				}
			else puts(line);
			}
		}
	for (i = 1; i < stp; i++)
		if (stf[i] == OUTRANGE) eqline(i);
}


argscan()
{	/* scan line for hex operand */
	linept = line;
	do gettoken(); while (delim != '\n');
	return isword(&opval);
}


label()
{
	int	i;
	if (i = stsearch(labval,SEEK)){
		stf[i] = INRANGE;
		makelab(token,i);
		if (disk) fputs(token,outbuf);
		else puts(token);
		if (disk) putc(':',outbuf);
		else putchar(':');
		}
}


opcode()
{
	if (disk) putc(TAB,outbuf);
	else putchar(TAB);
	gettoken();
	if (match(token,"??")) strcpy(token,"DB");
	if (disk) fputs(token,outbuf);
	else puts(token);
}


operand()
{
	int	i;
	if (delim != '\n'){
		if (disk) putc(TAB,outbuf);
		else putchar(TAB);
		gettoken();
		if (delim == ','){
			if (disk) fputs(token,outbuf);
			else puts(token);
			if (disk) putc(',',outbuf);
			else putchar(',');
			gettoken();
			}
		if (isbyte(&opval)){
			if (disk) putc('0',outbuf);
			else putchar('0');
			if (disk) fputs(token,outbuf);
			else puts(token);
			if (disk) putc('H',outbuf);
			else putchar('H');
			}
		else{
			if (isword(&opval)){
				i = stsearch(opval,SEEK);
				makelab(token,i);
				}
			if (disk) fputs(token,outbuf);
			else puts(token);
			}
		}
	if (disk){
		if (putc('\n',outbuf) == -1)
			error("disk full");
		}
	else putchar('\n');
}


gettoken()
{	/* get token from line at linept.  Step linept to
	   start of next token.  Set delim. */
	char	c,*tokpt;
	tokpt = token;
	while (*linept == ' ') linept++;
	while (isidchar(c = *(linept++)))
		*(tokpt++) = c;
	*tokpt = 0;
	delim = c;
	while ((c = *linept) == ' ') linept++;
	if (c == '\n') delim = c;
}


isidchar(c)
	char	c;
{
	if (isalpha(c)) return 1;
	if (isdigit(c)) return 1;
	if (c == '?') return 1;
	return 0;
}


isword(val)
	int	*val;
{	/* return true & set val if token is a 4 digit hex */
	if (strlen(token) == 4)
		return sscanf(token,HEX,val);
	else return 0;
}


isbyte(val)
	int	*val;
{	/* return true & set val if token is a 2 digit hex */
	if (strlen(token) == 2)
		return sscanf(token,HEX,val);
	else return 0;
}


eqline(i)
	int	i;
{	/* symbol i out of label range, generate equate */
	makelab(line,i);
	makehex(token,st[i]);
	if (disk){
		fputs(line,outbuf);
		putc(':',outbuf);
		putc(TAB,outbuf);
		fputs("EQU",outbuf);
		putc(TAB,outbuf);
		fputs(token,outbuf);
		if (putc('\n',outbuf) == -1)
			error("disk full");
		}
	else	{
		puts(line);
		putchar(':');
		putchar(TAB);
		puts("EQU");
		putchar(TAB);
		puts(token);
		putchar('\n');
		}
}


match(seq,str)
	char	*seq,*str;
{	/* match char sequence against string */
	char	c;
	while (c = *(str++))
		if (c != *(seq++)) return 0;
	return 1;
}


stsearch(val,insert)
	int	val,insert;
{	/* search symbol table for val returning 0 if not
	   found or index to table otherwise. If insert true
	   place in table if not there already */
	int	i;
	st[0] = val;
	for (i = stp - 1; ; i--)
		if (val == st[i]) break;
	if (i > 0) return i;
	if (insert == 0) return i;
	st[stp++] = val;
	if (stp > STMAX) error("table full");
	return i;
}


makehex(str,val)
	char	*str;
	int	val;
{	/* insert val in str in 0nnnH format */
	char	space[8],*sp;
	sp = &(space[1]);
	space[0] = '0';
	sprintf(sp,"%-4x",val);
	while (*sp != ' ') sp++;
	*(sp++) = 'H';
	*sp = 0;
	strcpy(str,&(space[0]));
}	


makelab(str,val)
	char	*str;
	int	val;
{	/* insert val in str in Lnnn: format */
	char	space[8],*sp;
	sp = &(space[1]);
	space[0] = 'L';
	sprintf(sp,"%-4u",val);
	while (*sp != ' ') sp++;
	*sp = 0;
	strcpy(str,&(space[0]));
}	


error(msg)
	char	*msg;
{
	printf("\n *** error: ");
	puts(msg);
	exit();
}
