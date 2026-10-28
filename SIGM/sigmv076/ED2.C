/* ED2.C */

#include ed0.c
#include ed1.ccc
#define SIGNON "E.K. Ream/Dr Dobb's Editor - H89/H19 enhancement: July 20, 1982"
#define CMNDMODE	1
#define INSMODE 	2
#define EDITMODE	3
#define EXITMODE	4
main()
{
int mode;
	syscout(ESC1); /*alternate keyboard mode*/
	syscout('=');
	fmtassn(NO);
	fmtset(8);
	outclr();
	outxy(0,SCRNL1);
	message(SIGNON);
	outxy(0,1);
	fileclear();	/* make sure no read or write files indicated */
	bufnew();
	mode=CMNDMODE;
	edgetln();
	while(1){
		if (mode ==EXITMODE) {
			break;
		}
		else if (mode==CMNDMODE) {
			mode=command();
		}
		else if (mode==EDITMODE) {
			mode=edit();
		}
		else if (mode==INSMODE) {
			mode=insert();
		}
		else {
			syserr("main: no mode");
			mode=EDITMODE;
		}
	}
}
edit()
{
char sbuffer[SCRNW1];
int v;
int x,y;
char c;
	pmtedit();
	while(1){
		c=syscin();	/* tolower eliminated */
		if (c==ESC1) {		/* enter command mode */
			return(CMNDMODE);
		}
		else if (c==INS1) {	/* enter insert mode */
			return(INSMODE);
		}
		else if (special(c)==YES) {
			if (c==UP1){	/* DOWN1 now treated separately */
				return(INSMODE);
			}
			else {
				continue;
			}
		}
		else if (c==DOWN1) {	/* DOWN1 now does not	 */
			eddn(); 	/* enter insert mode but */
			pmtline();	/* just advances to next line */
			edbegin();
			pmtcol();
		}
		else if (c==RIGHT1) {	/* go to end of line */
			edright();
			pmtcol();
		}
		else if (c==ERASE) {	/* erase to end of line */
			ederase();
			pmtcol();
		}
		else if (c==HOME) {	/* move cursor alternatingly to */
			edhome();	/* top and bottom of screen */
			pmtline();
		}
		else if (c==LSTRT) {	/* move to beginning of line */
			edbegin();
			pmtcol();
		}
		else if (c==DSCROL) {	/* scroll down */
			pmtmode("edit: scroll");
			while (bufnrbot()==NO) {
				if (chkkey()==YES) {
					break;
				}
				if (eddn()==ERR) {
					break;
				}
			}
			pmtedit();
		}
		else if (c==LEND){	/* move to end of line */
			edend();
			pmtcol();
		}
		else if (c==GOTO){	/* go to line entered */
			x=outxget();
			y=outyget();
			pmtcmnd("edit: goto: ",sbuffer);
			if(number(sbuffer,&v)) {
				edgo(v,0);
			}
			else {
				outxy(x,y);
			}
			pmtedit();
		}
		else if (c==DTOCH){	/* kill to character entered */
			pmtmode("edit:	kill");
			c=syscin();
			if ((special(c)==NO) &
			    (control(c)==NO)) {
				edkill(c);
			}
			pmtedit();
		}
		else if (c==GTOCH){	/* search to character entered */
			pmtmode("edit: search");
			c=syscin();
			if ((special(c)==NO) &
			    (control(c)==NO)) {
				edsrch(c);
			}
			pmtedit();
		}
		else if (c==USCROL) {	/* scroll up */
			pmtmode("edit: scroll");
			while (bufattop()==NO) {
				if (chkkey()==YES) {
					break;
				}
				if (edup()==ERR) {
					break;
				}
			}
			pmtedit();
		}
		else {		/* editor now exchanges any other character */
			if ((special(c)==NO) &	/* with cursor */
			    (control(c)==NO)) {
				edchng(c);
			}
			pmtedit();
		}
	}
}
insert()
{
char c;
	pmtmode("insert");
	while(1) {
		c=syscin();
		if (c==ESC1) {
			return(CMNDMODE);
		}
		else if (c==EDIT1) {
			return(EDITMODE);
		}
		else if (c==INS1) {
			;
		}
		else if (c==DOWN1) {	/* in insert mode DOWN1 treated  */
			ednewdn();	/* differently from edit mode	 */
			pmtline();	/* inserts new line */
			continue;
		}
		else if (special(c)==YES) {
			if ((c==UP2)|(c==DOWN2)) {
				return(EDITMODE);
			}
			else {
				continue;
			}
		}
		else if (control(c)==YES) {
			continue;
		}
		else {
			edins(c);
			pmtcol();
		}
	}
}
control(c) char c;
{
	if (c==TAB) {
		return(NO);
	}
	else if (c>=127) {
		return(YES);
	}
	else if (c<32) {
		return(YES);
	}
	else {
		return(NO);
	}
}
special(c) char c;
{
int k;
	if (c==JOIN1) {
		edjoin();
		pmtline();
		return(YES);
	}
	if (c==SPLT1) {
		edsplit();
		pmtline();
		return(YES);
	}
	if (c==ABT1) {
		edabt();
		pmtcol();
		return(YES);
	}
	else if (c==LFTDEL) {		/* delete to left of cursor */
		edldel();
		pmtcol();
		return(YES);
	}
	else if (c==DEL1) {		/* delete at cursor */
		edcdel();
		pmtcol();
		return(YES);
	}
	else if (c==ZAP1) {
		edzap();
		pmtline();
		return(YES);
	}
	else if (c==UP2) {
		edup();
		pmtline();
		return(YES);
	}
	else if (c==UP1) {
		ednewup();
		pmtline();
		return(YES);
	}

/* DOWN1 (CR) is no longer a special character */

	else if (c==DOWN2) {
		eddn();
		pmtline();
		return(YES);
	}
	else if (c==LEFT1) {
		edleft();
		pmtcol();
		return(YES);
	}
	else if (c==RIGHT1) {
		edright();
		pmtcol();
		return(YES);
	}
	else  {
		return(NO);
	}
}
command()
{
int v;
char c;
char args[SCRNW1];
char *argp;
int topline;
int ypos;
int oldline;
int k;
	edrepl();
	oldline=bufln();
	ypos=outyget();
	topline=oldline-ypos+1;
	while(1) {
		outxy(0,SCRNL1);
		fmtcrlf();
		pmtmode("command:");
		getcmnd(args,0);
		fmtcrlf();
		pmtline();
		c=args[0];
		if ((c==EDIT1)|(c==INS1)) {
			if (oldline==bufln()) {
				edgetln();
				bufout(topline,1,SCRNL1);
				outxy(0,ypos);
			}
			else {
				edgo(bufln(),0);
			}
			if (c==EDIT1) {
				return(EDITMODE);
			}
			else {
				return(INSMODE);
			}
		}
		else if (tolower(args[0])=='g'){
			argp=skipbl(args+1);
			if (argp[0]==EOS) {
				edgo(oldline,0);
				return(EDITMODE);
			}
			else if (number(argp,&v)==YES) {
				edgo(v,0);
				return(EDITMODE);
			}
			else {
				message("bad line number");
			}
		}
		else if (lookup(args,"append")) {
			append(args);
		}
		else if (lookup(args,"change")) {
			change(args);
		}
		else if (lookup(args,"clear")) {
			clear();
		}
		else if (lookup(args,"delete")) {
			delete(args);
		}
		else if (lookup(args,"dos")) {
			if (chkbuf()==YES) {
				closewrite();	/* write file closed on exit */
				syscout(ESC1); /*exit alternate keyboard mode*/
				syscout('>');
				syscout(ESC1); /*clear display*/
				syscout('E');
				return(EXITMODE);
			}
		}
		else if (lookup(args,"find")) {
			if ((k=find()) >= 0) {
				edgo(bufln(),k);
				return(EDITMODE);
			}
			else {
				bufgo(oldline);
				edgetln();
				message("pattern not found");
			}
		}
		else if (lookup(args,"list")) {
			list(args);
		}
		else if (lookup(args,"open")) { 	/* new */
			open(args);
		}
		else if (lookup(args,"load")) { 	/* changed */
			open(args);
			rest(args);
		}
		else if (lookup(args,"name")) {
			name(args);
		}
		else if (lookup(args,"write")) {	/* new */
			writel(args);
		}
		else if (lookup(args,"rename")) {	/* new */
			rename(args);
		}
		else if (lookup(args,"delname")) {	/* new */
			delname(args);
		}
		else if (lookup(args,"closewrite")) {	/* new */
			closewrite(args);
		}
		else if (lookup(args,"closeread")) {	/* new */
			closeread(args);
		}
		else if (lookup(args,"save")) {
			save(args);
		}
		else if (lookup(args,"read")) { 	 /* new */
			getit(args);
		}
		else if (lookup(args,"move")) { 	/* new */
			moveit(args);
		}
		else if (lookup(args,"copy")) { 	/* new */
			copyit(args);
		}
		else if (lookup(args,"search")) {
			search(args);
		}
		else if (lookup(args,"tabs")) {
			tabs(args);
		}
		else if (lookup(args,"rest")) { 	/* new */
			rest(args);
		}
		else if (lookup(args,"extract")) {	/* new */
			extract(args);
		}
		else {
			message("command not found");
		}
	}
}
lookup(line,command) char *line, *command;
{
	while(*command) {
		if (tolower(*line++)!=*command++) {
			return(NO);
		}
	}
	if((*line==EOS)|(*line==' ')|(*line==TAB)) {
		return(YES);
	}
	else {
		return(NO);
	}
}
getcmnd(args,offset) char *args; int offset;
{
int j,k;
char c;
	outxy(offset,outyget());
	outdeol();
	k=0;
	while ((c=syscin())!=CR) {
		if ((c==EDIT1)|(c==INS1)) {
			args[0]=c;
			return;
		}
		if ((c==DEL1)|(c==LEFT1)) {
			if (k>0) {
				outxy(offset,outyget());
				outdeol();
				k--;
				j=0;
				while (j<k) {
					outchar(args[j++]);
				}
			}
		}
		else if (c==ABT1) {
			outxy(offset,outyget());
			outdeol();
			k=0;
		}
		else if ((c!=TAB)&((c<32)|(c==127))) {
			continue;
		}
		else {
			if ((k+offset)<SCRNW1) {
				args[k++]=c;
				outchar(c);
			}
		}
	}
	args[k]=EOS;
}
ÿÿÿÿÿÿÿÿÿÿÿ                                                                