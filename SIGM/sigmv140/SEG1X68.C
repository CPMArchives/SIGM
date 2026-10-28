/*	X68 Cross Assembler Overlay Segment SEG1	*/
/*	Pass One of assembly.				*/

/*
 *	PERMISSION IS GRANTED FOR THE PUBLIC DOMAIN
 *	NON COMMERCIAL USE OF THIS SOFTWARE.
 *
 *	(C) CHRIS UNDERY 25th OCTOBER 1982
 *	11 MARGARET ST NEWTOWN 2042
 *	SYDNEY, AUSTRALIA
 */

/*	NOTE

	Parts of this program were translated from a Reality
	DATA/BASIC program .In particular, it was necessary 
	to keep some `line numbers`. These are used as goto 
	labels , passed to functions and returned as values
	from functions. The latter useage is somewhat obscure
	but should become apparent upon studying the functions.

	Major Changes from Data Basic Version

	1.	Allowed use of Tektronix mnemonics

	2.	Hash group linked symbol table (fast)

	3.	Expression evaluator

	4.	BIAS psuedo op for ROM system development

	5.	Origin of assembly can be set by console command

	6.	Symbol table dump to file and listing device

	7.	Intel hex output with adjustable address field

	8.	Optional pre-processor overlay

	9.	listing controls inlc titles 

	10.	single level include operation

	11.	symbol table can be purged of local symbols  

*/

#include "x68.h"
#define COMMENT ';'

main()
{
	char temp[150], ip_name[20], op_name[20];
	int opc;			/* Result code */

	strcpy(title,"\t\t\t\t");
	including = bias = 0;			/* clear rom bias */
	printf("Pass one (Version A.1)\n");
	strcpy(ip_name,filename);	/* Get input file name	*/
	if (index(ip_name,".") < 0 ) strcat(ip_name,".ASM");
	strcpy(iname,ip_name);
	if (fopen(ip_name,ibuf) == ERROR) {
		printf("Cannot open: %s\007\n",ip_name);
		exit();
	}
	strcpy(op_name,filename);	/* Create UFN.TMP	*/
	strcat(op_name,".TMP");
	if (fcreat(op_name,obuf) == ERROR ) {
		printf("DISK FULL: %s\007\n",op_name);
		exit();
	}
	lineno = errors = 0;
aloop:	if (!including) {		/* if doing single level include */
	       	if (fgets(line,ibuf)) {
			if (line[0] == '\n') {	/* cater for blank lines */
				fprintf(obuf,";\n");
			}
			else {
				opc = assemble();
				if (opc == 33) goto endop;
				if (opc != 10) fputs(line,obuf);
				numbytes += nb;
			}
			goto aloop;  /* get another load of code */
		}
		else goto endop;     /* have eof in primary source file */
	}
	else {			/* we are including */
		while (fgets(line,ifile)) {
			if (line[0] == '\n') {
				fprintf(obuf,";\n");
			}
			else {
				opc = assemble();
				numbytes += nb;
				if (opc == 33) goto incend;
				if (opc != 10) fputs(line,obuf);
			}
	
		}
incend:	including = 0;	/* no longer including */
	fclose(ifile);	/* close the file buffer for next include */
	goto aloop;	/* get next load from primary instead */
	}
endop:	numlines = lineno;		/* For statistics */
	fclose(ibuf);
	putc(0x1a,obuf);
	fflush(obuf);			/* Flush all buffers	*/
	fclose(obuf);			/* And terminate pass1  */
	return(1);
}

/*	Assemble Next line of source code from LINE	*/
/*	placing output to UFN.TMP			*/

assemble()
{
	int result;			/* Operation result handshake */
	char c;
	tokenise();			/* Next TOKENS please	*/
	c = label[0];			/* Test for comment and null */
	if ( c == ';' || c == '*' ) return(1);
	if (index(mnem,"END") >=0 ) return(33); /* End of processing */
	if (index(mnem,"INCLUDE") >= 0) {
		including = 1;		/* start including */
		iname[0] = '\0';
		strcat(iname,operand);	/* open file */
		strcat(iname,".ASM");
		printf("Including %s\n",iname);
		if (fopen(iname,ifile) == ERROR) {
			printf("\nCannot open include file\n");
			exit();
		}
		label[0] = ';';		/* make into a comment */
		return(10);
	}
	if (index(mnem,"SPACE") >= 0) return(1);
	if (index(mnem,"NOLIST") >= 0) return(1);
	if (index(mnem,"LIST") >= 0) return(1);
	if (index(mnem,"PAGE") >= 0) return(1);
	if (index(mnem,"TITLE") >= 0) return(1);
	if (index(mnem,"PURGE") >= 0) { /* purge local symbols */
		purge(operand);
		return(10);		/* dont write to listing file */
	}
	blankem();			/* Initialise assy registers	*/
	if (newlab() == 90) {		/* New label handler	*/
		wrapup();
		return(1);		/* error so write line as is */
		}
	if (index(mnem,"EQU") >= 0 ) {	/* Piss off easy ones	*/
		wrapup();
		return(1);
		}
	if (index(mnem,"ORG") >= 0 ) {	/* set location counter */
		wrapup();
		return(1);
		}
	if (index(mnem,"BLOCK") >= 0 ) {	/* reserve memory space */
		wrapup();
		return(1);
		}
	if (index(mnem,"ASCII") >= 0 ) {	/* inline string */
		return(fcc());
		}
	if (index(mnem,"BYTE") >= 0 ) {		/* form constant byte */
		return(fcb('b'));
		}
	if (index(mnem,"HALT") >= 0 ) {	/* Do adm special instruction */
		halt();
		return(10);
		}
	if (index(mnem,"WORD") >= 0 ) {
		return(fcb('w'));	/* word sized operation */
		}
	if (index(mnem,"BIAS") >=0 ) {	/* get prolog m980 buffer offset */
		if (!evaluate(operand)) {
			fault(600);
		}
		nb = 0;			/* Dont generate code */
		bias = dec;
		strcpy(i1,"  ");
		wrapup();
		return(1);
	}		
	idecode();			/* Do Instruction decode */
	wrapup();			/* Create *.TMP record */
}

newlab()	/* Extract label and put in symbol table	*/
{
	struct nlist *sp, *lookup(), *install();
	char ind_ref[16];		/* trick string */

	if (index(mnem,"ORG") >= 0) {	/* Handle new origin */
		if (!evaluate(operand)) fault(600);
		decad = dec;		/* get result */
		nb = 0;
		strcpy(i1,"  ");
		}
	tohex(hexad,decad);
	if (label[0] == '\0') goto N15;	/* But must check for RMB */
	if ((sp = lookup(label)) == NULL) goto N15; /* if new pass over here */
	strcpy(labrec,sp->def);		/* Move out of dynamic store */
	if (labrec[0] != '?') {		/* A duplicity of labels */
		fault(14);
		return(90);		/* Tell proc above we fucked out */
		}
	strcpy(labrec,hexad);		/* else copy address to symbol def */
  N15:  if (index(mnem,"BLOCK") >= 0) {	/* reserve space operation */
		if (!evaluate(operand)) fault(600);
		nb = dec;		/* Get result */
		strcpy(i1,"  ");	/* no machine code to generate */
		}
	if (label[0] == NULL ) return(1); /* Fix bug in original vers */
	if (index(mnem,"EQU") < 0 ) {	/* Perform EQUATE operation */
		strcpy(labrec,hexad);
		goto N18;
		}
	if (evaluate(operand)) {	/* dont be fooled by this */
		tohex(labrec,dec);	/* assume good operation */
		getsub(operand);	/* if either = ?? ng */
		if ((sp = lookup(xp1)) != NULL) {
			if (index(sp->def,"??") >= 0) goto NG;
		}
		if ((sp = lookup(xp2)) != NULL) {
			if (index(sp->def,"??") >= 0) goto NG;
		}
	}
	else {				/* we have complex on pass 1 */
	NG:	strcpy(labrec,"????");
		strcpy(i1,"  ");
		strcpy(i2,"??");
		strcpy(i3,"??");	/* throw unresolved label into st */
		if ((sp = install(label,labrec)) == NULL) {
			printf("SYMBOL TABLE FULL\n");
			exit();
		}
		nb = 0;			/* dont increment address cntr */
		return(1);		/* dont install complex exp ! */
	}
  N16:  strcpy(i1,"  ");		/* Now fix up assy registers */
	strcpy(brad,labrec);
	nb = 0;
	strcpy(hexad,"    ");
  N18:	if ((sp = install(label,labrec)) == NULL ) {
		printf("\nLine %d SYMBOL TABLE OVERFLOW\007\n",lineno);
		exit();			/* TERMINATE OVERLAY */
		}
	return(1);			/* Else good result */
}


tokenise()	/* Break down line into TOKENS	*/
{
	lineno++;
	getok(label,line,1,8);	/* Parse input line */
	getok(mnem,line,2,9);
	getok(operand,line,3,16); /* Could be complex expr */
	getcomment(line);
	if (index(comment,"\n") < 0) strcpy(comment,"\n");
	return(1);
}

blankem()	/* Clear assembler registers */
{
	strcpy(i1,"??");	/* Indicate unresolved instruction */
	strcpy(i2,"  ");	/* and clear other registers	*/
	strcpy(i3,"  ");
	strcpy(brad,"    ");
	nb = 3;			/* Assume 3 byte instruction	*/
}

wrapup()	/* Recombine Tokens and new data for output line */
{
	tohex(hexad,decad);	/* Calculate HEXaddress */
	strcpy(line,hexad);	/* Hex address first */
	strcat(line," ");
	strcat(line,i1);	/* Machine instruction 1 */
	strcat(line," ");
	strcat(line,i2);	/* Machine instruction 2 */
	strcat(line,i3);	/* Machine instruction 3 */
	strcat(line," ");
	strcat(line,brad);	/* Branch address */
	strcat(line," ");
	strcat(line,label);	/* Label must LEFT JUSTIFY IT LATER */
	strcat(line,"\t");	/* TAB will do just fine */
	strcat(line,mnem);	/* Mnemonic */
	strcat(line,"\t");
	strcat(line,operand);	/* Operand */
	strcat(line,"\t");
	strcat(line,comment);	/* Comments fill up remainder */
	decad += nb;		/* Adjust PC for next line through */
}

idecode()	/* INSTRUCTION DECODER LOGIC	*/
{
	char x;

	if (!binary(mnem)) {	/* Mnemonic not found in table */
		fault(20);	/* Error code 20 */
		return(90);	/* Indicate error to procs above */
	}
	strcpy(i1,inst);	/* Get instruction from table */
	
	switch(dest[0])	{	/* Use steering logic from table */

		case '1': { 
			if (operand[0] != '\0') {
				strcpy(temp," ");
				strcat(temp,operand);
				strcat(temp,comment);
				strcpy(comment,temp); /* moove it back */
				operand[0] = '\0';
				} /* Second space forgotten */
			nb = 1; /* Single byte instruction */
			return(45);
			}
		case '2': return(regadr(200)); /* Register and address */
		case '3':
	        case '4': {
	I24:		if (operand[0] == '#' ) {
				fault(23);
				return(90);
				}
			return(regadr(200));   /* Register etc */
			}
		case '5': {
			strcpy(m4,"A");
			return(regadr(200));   /* Reg decode */
			}
		case '6': {
			strcpy(m4,"B");
			return(regadr(200));   /* Reg decode */
			}
		case '7': {
			strcpy(m4,"A");
			return(regadr(200));
			}
		case '8': {
			strcpy(m4,"B");
			return(regadr(200));
			}
		case '9': return(regadr(201));	/* Branch instruction */

		}	/* End case switch */

	printf("\"Opcodes\" file is corrupted\7\n");

}	/* End Instruction Decoder Logic */


/* Regadr is passed the old DATA BASIC line number in order */
/* to force entry at the correct point */

regadr(n)	/* Register and Address decoder */
int n;					/* DATA BASIC line number */
{
	struct nlist *symptr, *lookup(), *install();

	if (n == 201) goto R201;	/* Its the only way */
	if (operand[0] == '#') goto R210;
	if (operand[0] == 'X') {
		if (!isalpha(operand[1])) goto R230;
	}
	if (index(operand,",X") >= 0 ) goto R230; /* Index inst */

 R201:	if ((symptr = lookup(operand)) == NULL) goto R202;
	strcpy(labrec,symptr->def);	/* Get definition */
	if (labrec[0] == '?') goto R203;
	goto R205;			/* This really sucks badly */
 R202:	if (!evaluate(operand)) {   	/* might just be num literal */
		strcpy(labrec,"????");	/* nope.. stash it charlie */
		goto R203;
	}
	else {
		tohex(labrec,dec);
	}
	goto R205;
 R203:	strcpy(i2,"??");
 R204:	if ((symptr = install(operand,labrec)) == NULL) {
		printf("SYMBOL TABLE OVERFLOW\007\n");
		exit();			/* ABORT ABORT ABORT ABORT */
		}
 noput:	if (dest[0] == '9') {
		nb = 2;
		return(45);		/* Another line number */
		}
	strcpy(i3,"??");
	goto R241;
  R205:	if ((symptr = install(operand,labrec)) == NULL) {
		printf("SYMBOL TABLE OVERFLOW\007\n");
		exit();
		}
	smov(labad,labrec,4);		/* get first 4 bytes of labrec */
	dlabad = todec(labad,16);	/* Convert to decimal */
	if (dest[0] == '9') goto R250;	/* Relative address */
	if (dest[0] == '3') goto R240;	/* Extended */
	if (m4[0] == SP) goto R240;	/* Extended */
	if (dest[0] == '7') goto R240;	/* cannot have 2byte jsr */
	if (dlabad > 256 || dlabad < 0) goto R240;	/* Extended */
	if (m4[0] == '\0') goto R240;	/* Hope to trap nasties */
	goto R220;			/* Direct addressing */
 R210:	nb = 2;
	class[0] = operand[1];	/* Determine operand class */
	if (m4[0] == 'A') insert(i1,'8');
	if (m4[0] == 'B') insert(i1,'C');
	if (dest[0] > '4') goto R215;	/* CPX LDX or LDS */
	if (!evaluate(operand)) {
		fault(210);
		return(90);
	}
	tohex(hex,dec);			/* Convert result to hex */
	smov(i2,&hex[2],2);
	return(45);
 R215:	nb = 3;
	strcpy(i3,"  ");
	if (!evaluate(operand)) {	/* assume pass 2 will fix it */
		strcpy(i2,"??");strcpy(i3,"??");
		return(90);
	}
	tohex(hex,dec);		/* Get result of op */
	smov(i2,&hex[0],2);
	smov(i3,&hex[2],2);	/* fix bug with lds ldx etc vers a.1 */
	return(45);
 R220:	nb = 2;
	smov(i2,&labad[2],2);
 	if (m4[0] == 'A') {
		insert(i1,'9');
		return(45);
		}
	if (m4[0] == 'B') {
		insert(i1,'D');
		return(45);
		}
	fault(220);
	return(90);
 R230:	nb = 2;
	if (!getexp(temp,operand)) dec = 0;
	else evaluate(temp);
	tohex(hex,dec);
	smov(i2,&hex[2],2);
	if (m4[0] == '\0') {
		insert(i1,'6');
		return(45);
		}
	if (m4[0] == 'A') {
		insert(i1,'A');
		return(45);
		}
	if (m4[0] == 'B') {
		insert(i1,'E');
		return(45);
		}
	fault(231);
	return(90);
 R240:	strcpy(i2,labad);
	i3[0] = '\0';
 R241:	if (m4[0] == '\0') {		/* Label not known */
		insert(i1,'7');
		return(45);
		}
	if (m4[0] == 'A') {
		insert(i1,'B');
		return(45);
		}
	if (m4[0] == 'B') {
		insert(i1,'F');
		return(45);
		}
	fault(241);
	return(90);
 R250:	dec = dlabad - decad + 254;	/* Label known */
	if (dec < 128 ) {
		fault(250);
		return(90);
		}
	if (dec > 383) {
		fault(251);
		return(90);
		}
	tohex(hex,dec);
	smov(i2,&hex[2],2);
	nb = 2;
	strcpy(brad,labad);
	return(45);
}

getexp(to,from)		/* Get expression delimted by COMMA */
char *to, *from;
{
	while (*to = *from) {	/* Move characters */
		if (*to == COMMA) {
			*++to = NULL;
			return(1);
		}
		to++;
		from++;
	}
	return(0);
}

getnxtp(to, from, n)
char *to, *from;
int n;
{
	int count;
	count = 0;
	while (count != n) {
		if (*from == COMMA) count++;
		if (*from == NULL) {
			*to = NULL;
			return(0);
		}
		from++;
	}
	getexp(to, from);
}


insert(s,c)	/* Insert character in front of string */
char s[], c;
{
	s[1] = s[0];	/* move first character back one space */
	s[0] = c;	/* plonk character in front */
	s[2] = '\0';	/* terminate the string */
}

fcc()		/* STRING psuedo op */
{
	int byteno, i;
	int j;
	char up;
	int commacnt;
	up = 1;
	 commacnt = 0;
	byteno = j = 0;
	while (up) {
		if ((operand[j] == 0x22) || (operand[j] == 0x27)) {
			j++;
			commacnt++;
			if (commacnt == 2) up = 0;
		}
		else {
			temp[0] = 0x22;
			temp[1] = operand[j];
			temp[2] = '\0';
			evaluate(temp);
			tohex(hex,dec);
			smov(i1,&hex[2],2);
			buildline(++byteno,'b');
			j++;
		}
	}
	return(10);
}

fcb(n)		/* byte or word psuedo operations */
char n;
{
	int byteno, i, j;

	indx1 = indx2 = 0;
	i = byteno = 0;		/* Assume no bytes ! */
	j = numargs(operand);
	while (i++ < j) {	/* Loop through arguments */
		movenxt();
		if (n == 'b') {	/* do byte specifics */
			if (!evaluate(temp)) {
				 strcpy(i1,"??");
			}
			else {
				tohex(hex,dec);	/* Extract value */
				smov(i1,&hex[2],2);
			}
		}
		else {	 /* word operation */
			if (!evaluate(temp)) {
				strcpy(i1,"   ");
				strcpy(i2,"??");
				strcpy(i3,"??");
			}
			else {
				tohex(hex,dec);
				smov(i2,&hex[0],2);
				smov(i3,&hex[2],2);
			}
		}
	buildline(++byteno,n);
	}
	return(10);
}

movenxt()		/* Move next argument into temp string */
{
	int i;		/* String index */
	char movf;	/* boolean control flg */

	i =  0;
	movf = 1;
	while (movf)	{
		temp[i] = operand[indx1];	/* Use global for memory */
		if ((temp[i] == NULL) || (temp[i] == ',')) {
			indx1++;	/* Crank index for next */
			temp[i] = NULL;
			movf = 0;	/* Make flag false */
		}
		else {
			i++;	/* BUmp pointers */
			indx1++;
		}
	}
}	

buildline(bn,n)		/* Build output line for BYTE, STRING */
int bn,n;
{
	if (bn == 1) {	/* First time into this shit */
		tohex(hexad,decad);
		strcpy(line,hexad);	/* wish I had good cat function */
		strcat(line," ");
		if (n == 'b') {
			strcat(line,i1);
		        strcat(line,"           ");
		}
		else {
			strcat(line,"   ");
			strcat(line,i2);
			strcat(line,i3);
			strcat(line,"       ");
		}
		strcat(line,label);
		strcat(line,"\t");
		strcat(line,mnem);
		strcat(line,"\t");
		strcat(line,operand);
		strcat(line,"\t");
		strcat(line,comment);
	}
	else {
		tohex(hexad,decad);	/* Bump address */
		strcpy(line,hexad);
		strcat(line," ");
		if (n != 'b') {
			strcat(line,"   ");
			strcat(line,i2);
			strcat(line,i3);
		}
		else strcat(line,i1);
		strcat(line,"\n");	/* Add newline character */
	}
	fputs(line,obuf);		/* Internal write */
	if (n == 'b') decad += 1;
	else decad += 2; /* for word operation */
}

/* this function handles the macro instruction HALT which */
/* is used by the ADM31/32 firmware. The instruction is added */
/* as a `built-in' */

halt()		
{
	tohex(hexad,decad);
	strcpy(line,hexad);
	strcat(line,"+B7 7000 ####\tHALT\t");
	fputs(line,obuf);
	fputs(comment,obuf);		/* for user noise */
	decad += 3;
	tohex(hexad,decad);
	strcpy(line,hexad);
	strcat(line,"+01      ####\n");
	fputs(line,obuf);
	decad++;
}
