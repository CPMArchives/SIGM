/* ED10.C */

#include b:ed0.c
#include b:ed1.ccc
int bufcflag;
char *bufp;
char *bufpmax;
char *bufend;
int bufline;
int bufmaxln;
/* mbuffer is external for Software Toolworks compiler to force it beyond
   code sections */
extern char mbuffer[1];
bufnew()
{
	bufp=bufpmax=mbuffer+1;
/* need more room for Software Toolworks stack and buffers */
	bufend=sysend()-1500;
	bufline=1;
	bufmaxln=0;
	mbuffer[0]=CR;
	bufcflag=NO;
}
bufln()
{
	return(bufline);
}
bufchng()
{
	return(bufcflag);
}
bufsaved()
{
	bufcflag=NO;
}
buffree()
{
	return(bufend-bufp);
}
bufgo(line) int line;
{
	line=min(bufmaxln+1,line);
	line=max(1,line);
	if (line==bufline) {
		return(OK);
	}
	while (line<bufline) {
		if (bufup()==ERR) {
			return(ERR);
		}
	}
	while (line>bufline) {
		if (bufdn()==ERR) {
			return(ERR);
		}
	}
	return(OK);
}
bufup()
{
char *oldbufp;
	oldbufp=bufp;
	if (bufattop()) {
		return(OK);
	}
	if (*--bufp!=CR) {
		syserr("bufup:	missing CR");
		bufp=oldbufp;
		return(ERR);
	}
	while (*--bufp!=CR) {
		;
	}
	bufp++;
	if (bufp<(mbuffer+1)) {
		syserr ("bufup: bufp underflow");
		bufp=oldbufp;
		return(ERR);
	}
	bufline--;
	return(OK);
}
bufdn()
{
char *oldbufp;
	oldbufp=bufp;
	if (bufatbot()) {
		return(OK);
	}
	while (*bufp++!=CR) {
		;
	}
	if (bufp>bufpmax) {
		syserr("bufdn: bufp overflow");
		bufp=oldbufp;
		return(ERR);
	}
	bufline++;
	return(OK);
}
bufins(p,n) char *p; int n;	/* altered: a full buffer does not truncate */
{				/*   line, but issues warning and returns   */
int k;			     /*   ERR - allows editing of large files	 */
	if(bufext(n+1)==ERR) {
		return(ERR);
	}
	k=0;
	while (k<n) {
		*(bufp+k)= *(p+k);
		k++;
	}
	*(bufp+k)=CR;
	bufmaxln++;
	if ((n==0)&(bufnrbot())) {
		;
	}
	else {
		bufcflag=YES;
	}
	return(OK);
}
buf1ins(p,n) char *p; int n;	 /* altered: a full buffer does not truncate */
{				/*   line, but issues warning and returns   */
int k, x;			/*   ERR - allows editing of large files    */
	x = 0;			/*   in pieces */
	if(bufstrch(n+1)==ERR) {
		x = 1;
	}
	k=0;
	while (k<n) {
		*(bufp+k)= *(p+k);
		k++;
	}
	*(bufp+k)=CR;
	bufmaxln++;
	if ((n==0)&(bufnrbot())) {
		;
	}
	else {
		bufcflag=YES;
	}
	if (x == 0) {
		return(OK);
	}
	else {
		return(ERR);
	}
}
bufdel()
{
	return(bufndel(1));
}
bufndel(n) int n;
{
int oldline;
int k;
char *oldbufp;
	oldline=bufline;
	oldbufp=bufp;
	k=0;
	while ((n--)>0) {
		if (bufatbot()) {
			break;
		}
		if (bufdn()==ERR) {
			bufline=oldline;
			bufp=oldbufp;
			return(ERR);
		}
		k++;
	}
	bufupmov(bufp,bufpmax-1,bufp-oldbufp);
	bufpmax=bufpmax-(bufp-oldbufp);
	bufp=oldbufp;
	bufline=oldline;
	bufmaxln=bufmaxln-k;
	bufcflag=YES;
	return(OK);
}
bufrepl(p,n) char *p; int n;
{
int oldlen, k;
char *nextp;
	if (bufatbot()) {
		return(bufins(p,n));
	}
	if (bufdn()==ERR) {
		return(ERR);
	}
	nextp=bufp;
	if (bufup()==ERR) {
		return(ERR);
	}
	n=n+1;
	oldlen=nextp-bufp;
	if (oldlen<n) {
		if (bufext(n-oldlen)==ERR) {
			return(ERR);
		}
	   /*	bufpmax=bufpmax+n-oldlen;   Note: Error in original listing */
	}
	else if (oldlen>n) {
		bufupmov(nextp,bufpmax-1,oldlen-n);
		bufpmax=bufpmax-(oldlen-n);
	}
	k=0;
	while (k<(n-1)) {
		bufp[k]=p[k];
		k++;
	}
	bufp[k]=CR;
	bufcflag=YES;
	return(OK);
}
bufgetln(p,n) char *p; int n;
{
int k;
	if (bufatbot()) {
		return(0);
	}
	k=0;
	while (k<n) {
		if (*(bufp+k)==CR) {
			return(k);
		}
		*(p+k)= *(bufp+k);
		k++;
	}
	while (*(bufp+k)!=CR) {
		k++;
	}
	return(k);
}
bufdnmov(from,to,length) char *from, *to; int length;
{
	sysdnmov(to-from+1,to+length,to);
}
bufupmov(from,to,length) char *from, *to; int length;
{
	sysupmov(to-from+1,from-length,from);
}
bufatbot()
{
	return(bufline>bufmaxln);
}
bufnrbot()
{
	return(bufline>=bufmaxln);
}
bufattop()
{
	return(bufline==1);
}
bufout(topline,topy,nlines) int topline, topy, nlines;
{
int l,p;
	l=bufline;
	p=bufp;
	while ((nlines--)>0) {
		outxy(0,topy++);
		buflnout(topline++);
	}
	bufline=l;
	bufp=p;
}
buflnout(line) int line;
{
int c;
	if (bufgo(line)==ERR) {
		fmtsout("disk error: line deleted",0);
		outdeol();
		return;
	}
	if (bufatbot()) {
		outdeol();
	}
	else {
		c=fmtsout(bufp,0);		/* c= added */
		if (c<SCRNW1) { 		 /* now allows full screen */
		outdeol();
		}
	}
}
bufext(length) int length;
{
	if ((bufpmax+length)>=bufend) {
		error("main buffer is full");
		return(ERR);
	}
	bufdnmov(bufp,bufpmax-1,length);
	bufpmax=bufpmax+length;
	return(OK);
}
/* bufstrch is bufext modifed to allow entering beyond buffer with warning */
bufstrch(length) int length;
{
	if ((bufpmax+length)>=bufend) {
		bufdnmov(bufp,bufpmax-1,length);
		bufpmax=bufpmax+length;
		message("Caution: main buffer is full");
		return(ERR);
	}
	bufdnmov(bufp,bufpmax-1,length);
	bufpmax=bufpmax+length;
	return(OK);
}
buflength(first,n) int first, n;   /* new: returns length of n lines from  */
{				   /* first line specified */
char *start;
int i,len,line;
	if (n<=0) {
		len=0;
		return(len);
	}
	if (bufgo(first)==ERR) {
		len=0;
		return(len);
	}
	start=bufp;
	i=1;
	line = first;
	while (i++<=n) {
		if (bufgo(++line)==ERR) {
			len=0;
			return(len);
		}
	}
	len=bufp-start;
	return(len);
}
bufcopy(from,to,n) int from,to,n;	/* new: copies "n" lines from "from"  */
{					/*	to "to" */
int length;
char *source,*dest;
	if (from==to){
		return;
	}
	if ((length=buflength(from,n))==0){
		return;
	}
	if (bufgo(from)==ERR){
		return;
	}
	source=bufp;
	if (bufgo(to)==ERR){
		return;
	}
	dest=bufp;
	if ((bufpmax+length)>=bufend) {
		message ("insufficient room in buffer for copy or move");
		return;
	}
	if (bufext(length)==ERR){
		return;
	}
	bufgo(1);
	bufmaxln=bufmaxln+n;
	if (from<to) {
		sysupmov(length,dest,source);
	}
	else {
		sysupmov(length,dest,source+length);
	}
}
e  {
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
int