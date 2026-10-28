/*	M6800 Cross Assembler				*/
/*	Overlay Segment SEG2.C		Version A.1	*/
/*	Pass Two of X68 M6800 cross assembler		*/

/*
 *	PERMISSION IS GRANTED FOR THE PUBLIC DOMAIN
 *	NON COMMERCIAL USE OF THIS SOFTWARE.
 *
 *	(C) CHRIS UNDERY 25th OCTOBER 1982
 *	11 MARGARET ST NEWTOWN 2042
 *	SYDNEY, AUSTRALIA
 */

/*
	This pass of X68 reads the UFN.TMP searching for
 undefined hex code signified by a '?' in the I2 field of
 and instruction. If the I3 field is also undefined, a word
 reference is assumed. The program looks up the operand in the
 symbol table and fills in the blanks. If the symbol is still
 undefined, a fatal error is assumed.

	This module is an overlay, loaded by the swapin function
in X68.c

*/
 
#include "x68.h"

main()
{

	struct nlist *lookup(), *install(), *ptr;
	char asfile[15], temp[150], listfile[15];
	char hbuf[BUFSIZ];

	pageno = linecnt = 0;
	printf("Pass two (Version A.1)\n");
	strcpy(asfile,filename);	/* get primary file name */
	strcat(asfile,".TMP");		/* add temp filetype	*/
	if (fopen(asfile,ibuf) == ERROR ) {
		printf("Cannot open %s\007\n",asfile);
		exit();			/* Halt progress 	*/
	}
	if (xing) {
		if (fcreat(hexname,hbuf) == ERROR) {
			printf("Disk probably full: Cannot create hex file\n");
			exit();
		}
	}
	if (listing) {
		if (fcreat(lstname,obuf) == ERROR ) {
			printf("Disk probably full: Cannot create %s\007\n",listfile);
			exit();
		}
	}
	lineno = 0;
	header();
	while (fgets(line,ibuf)) {
		pass2();		/* Do pass 2 */
		if (line[0] != ';') makeline();
		else {
			if (listing) {
				putc(TAB,obuf); /* Pretty up the listing */
				putc(TAB,obuf);
			}
			if (printing) printf("\t\t");
		}
		if (linecnt++ == 55) header();
		if (xing) wrhex(hbuf);		/* Write hex file */
		if (listing) fputs(line,obuf);
		if (printing) printf("%s",line);
	}
	putsym();				/* Write symbols to lst */
	if (listing) {
		fprintf(obuf,"\n\nEND OF ASSEMBLY ");
		fprintf(obuf,"%d FATAL ERROR(S) DETECTED\n",errors);
		putc(0x1a,obuf);
		fflush(obuf);
		fclose(obuf);
	}
	fclose(ibuf);
	if (xing) {
		fprintf(hbuf,":00000001FF\n");
		putc(0x1a,hbuf);
		fflush(hbuf);
		fclose(hbuf);
	}
	if (!debug) unlink(asfile);
}				/* PAss 2 done */


pass2()
{
	struct nlist *ptr, *alt, *lookup();
	unsigned current, branch, relative;
	char swopper[16], fiddled;

	current = branch = relative = 0;
	lineno++;
	tokenise();		/* Get tokens */
	if (temp[8] != '?') return(1);	/* No wuckers */

/* Version A.1 has expression evaluator in root module x68.com */
/* the old version was in seg1 overlay and as result, seg2 could */
/* not be very intelligent. This version can evaluate failed */
/* operand complexes from pass 1 */

	fiddled = 0;	
	if (operand[0] == '#') {
		strcpy(swopper,&operand[1]);
		strcpy(operand,swopper);
		fiddled = 1;
	}
	getsub(operand);	/* split operand down the middle */
	if ((ptr = lookup(xp1)) != NULL) goto itil;
	if ((alt = lookup(xp2)) == NULL) {
		B1090();	/* Total failure undefined symbol */
		return(1);
	}
itil:	if ((index(alt->def,"??") >=0) || (index(ptr->def,"??") >= 0)) {
		B1090();	/* trap unresolved references */
		return(1);
	}
	if (!evaluate(operand)) { /* only now is it safe to evaluate it */
		B1090();
		return(1);
	}

/* if this line has a label then install the label now in case further */
/* references are made to it, this takes care of foward refs on an equ */

	getok(label,&line[18],1,16);	/* extract label from line */
	tohex(labrec,dec);	/* convert result to hex string */
	if (label[0] != '\0') { /* install label reference */
		if ((alt = install(label,labrec)) == NULL) {
			printf("I just creamed the symbol table boss!\n");
			exit();
		}
	}
	if (fiddled) {
		strcpy(swopper,"#");
		strcat(swopper,operand);
		strcpy(operand,swopper);
	}
	strcpy(labad,labrec);
	if (line[10] == '?' ) {		/* Word reference eg JMP */
		if (index(mnem,"EQU") >= 0) {
			temp[13] = labrec[0];
			temp[14] = labrec[1];
			temp[15] = labrec[2];
			temp[16] = labrec[3];
			temp[8] = ' ';
			temp[9] = ' ';
			temp[10] = ' '; temp[11] = ' ';
		}
		else {
			temp[8] = labrec[0];
			temp[9] = labrec[1];
			temp[10] = labrec[2];
			temp[11] = labrec[3];
		}
	return(1);
	}
	smov(hex,&temp[0],4); 		/* Rel brnch, get current address */
	current = todec(hex,16);		/* Convert to hex	*/
	branch = todec(labrec,16);		/* ready for diff test  */
	relative = branch - current + 254;
	if (relative < 128 ) B1095();
	if (relative > 383 ) B1095();
	tohex(hex,relative);		/* convert back to hex   */
	temp[8] = hex[2];
	temp[9] = hex[3];		/* Replace ?? with result */
	temp[13] = labad[0];		/* Now pretty up with label addr */
	temp[14] = labad[1];
	temp[15] = labad[2];
	temp[16] = labad[3];
	return(1);
}				/* While not end of file 	*/

B1090()
{
	printf("Variable <%s> not defined at line <%u> in module %s\n",operand,lineno,title);
	printf("%s\n",line);
	if (listing) fprintf(obuf,"*** ERROR *** UNDEFINED VARIABLE: %s \n",operand);
	errors++;
	if (lineno++ == 55) header();
	return(1);
}


B1095()
{	
	printf("Branch out of range at line <%u> in module %s\n",lineno,title);
	printf("%s\n",line);
	if (listing) fprintf(obuf,"*** ERROR ***  BRANCH DISPLACEMENT OUT OF RANGE \n");
	errors++;
	if (lineno++ == 55) header();
	return(1);
}

/*	Get set of tokens from temporary pass 1 file */

tokenise()
{
	int slew_count;

	getok(temp,line,1,30);	/* Will also get LABEL code field */
	getok(mnem,line,2,9);	/* Get mnemonic field */
	getok(operand,line,3,80);	/* Get operand field */
	getcomment(line);
	if (index(mnem,"TITLE") >= 0) smov(title,operand,32);
	if (index(mnem,"PAGE") >= 0) header();
	if (index(mnem,"NOLIST") >= 0) printing = 0;
	if (index(mnem,"LIST") >= 0) printing = 1;
	if (index(mnem,"SPACE") >= 0) {	/* accomodate excesses of tek ass */
		if (evaluate(operand)) {
			slew_count = 0;
			while (slew_count++ < dec) {
				if (listing) fprintf(obuf,"\n");
				if (printing) printf("\n");
				if (lineno++ == 55) header();
			}
		}
	}
}

makeline()		/* Build up output line */
{
	int adjuster;


	strcpy(line,temp);	/* First stuff incl label */
	adjuster = 30 - strlen(temp);
	while (adjuster--) strcat(line," ");
	strcat(line,"\t");
	strcat(line,mnem);
	strcat(line,"\t");
	strcat(line,operand);
	strcat(line,"\t");
	strcat(line,comment);
}

header()		/* Produce page header */
{
	if (listing) {
		putc(0x0c,obuf);	/* Form feed */
		fprintf(obuf,"X68 Motorola 6800 Cross Assembler Version A.1");
		fprintf(obuf,"           Page # %5d  File: %s ",++pageno,filename);
		fprintf(obuf,"Module name: %s\n\n",title);
		fprintf(obuf,"Addr Code			Source Statement\n\n");
		linecnt = 0;
	}
	if (printing) {
		if (!listing) pageno++;	/* dont double up page numbering */
		putc(0x0c,1);
		printf("X68 Motorola 6800 Cross Assembler Version A.1");
		printf("           Page # %5d File: %s ",pageno,filename);
		printf("Module name: %s\n\n",title);
		printf("Addr Code		Source Statement\n\n");
		if (!listing) linecnt = 0;
	}
}

gethex()		/* Get hex record from output line */
{			/* Returning numberof data bytes */
	int count;
	int k, i;
	char fudge[10];

	count = i = 0;
	hexrec[0] = '0';
	hexrec[1] = '0';
	hexrec[2] = NULL;
	smov(fudge,temp,4);
	k = todec(fudge,16);	/* convert address to dec */
	k = (k - bias);
	tohex(fudge,k);
	hexrec[2] = fudge[0];
	hexrec[3] = fudge[1];
	hexrec[4] = fudge[2];
	hexrec[5] = fudge[3];
	hexrec[6] = '\0';
	i = 6;
	strcat(hexrec,"00");	/* record type */
	i += 2;
	if (!isspace(temp[5])) {
		hexrec[i++] = temp[5];
		hexrec[i++] = temp[6];
		count++;
	}
	if (!isspace(temp[8])) {
		hexrec[i++] = temp[8];
		hexrec[i++] = temp[9];
		count++;
	}
	if (!isspace(temp[10])) {
		hexrec[i++] = temp[10];
		hexrec[i++] = temp[11];
		count++;
	}
	hexrec[i] = '\0';
	hexrec[1] = (0x30 + count);
	return(count);	/* one more for checksum */
}

genbin(c)		/* Generate binary image of hex record */
int c;		/* Count for countfield */
{
	int m, i, g, j, k;	/* Indices	*/
	char tb[5];
	bcc = i = j = k = m = 0;
	g = (strlen(hexrec)-1);
	while (m < g) {		/* Loop converting hexrec to binary */
		tb[0] = hexrec[m++];
		tb[1] = hexrec[m++];
		tb[2] = '\0';
		k = todec(tb,16);
		bcc += k;	/* update checksum */
	}
	bcc=(~bcc)+1;		/* Take twos complement */
	return(1);		/* number of characters to send */
}

wrhex(h)				/* Write hex record */
char *h;
{
	int c, e, d;

	d = 0;
	if (temp[0] == ';' || temp[0] == '*') return(1);
	if (index(mnem,"SPACE") >= 0) return(1);  /*PA - return if directive*/
	if (index(mnem,"NOLIST") >= 0) return(1);
	if (index(mnem,"LIST") >= 0) return(1);
	if (index(mnem,"PAGE") >= 0) return(1);
	if (index(mnem,"TITLE") >= 0) return(1);
	if (index(mnem,"PURGE") >= 0) return(1);
	if (!gethex()) return(0);	/* no stuff to write */
	c = genbin(e);
	fprintf(h,":");
	fprintf(h,"%s",hexrec);
	tohex(temp,bcc);
	putc(temp[2],h);
	putc(temp[3],h);
	fprintf(h,"\n");
}

/*	Write symbol table to listing device */

putsym()
{
	struct nlist *tp, *lookup();
	int bucket, num;

	bucket = num = 0;
	if ((!listing) && (!printing)) return(1);
	if (listing) {
		putc(0x0c,obuf);
		fprintf(obuf,"Symbols:\n\n");
	}
	if (printing) {
		putc(0x0c);
		printf("Symbols:\n\n");
	}
	while (bucket < HASHSIZE) {
		for (tp = hashtab[bucket]; tp != NULL; tp = tp->next) {
			if (listing) {
				fprintf(obuf,"%s\t%s\t",tp->name,tp->def);
				if (num == 5) {
					 fprintf(obuf,"\n");
	 				 if (linecnt++ == 55)  header();
					 num = 0;
				}
			}
			if (printing) {	/* to console or printer */
				printf("%s\t%s\t",tp->name,tp->def);
				if (num == 4) {
					 printf("\n");
					 if (linecnt++ == 55) header();
					 num = 0;
				}
			}
			num++;
		}
	bucket++;
	}
	if (printing) putc(0x0c,1);
}
