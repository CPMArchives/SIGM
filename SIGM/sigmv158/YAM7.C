/*
>>:yam7.c 12-16-83 for CI C86 under cp/m-86
 * File open and close stuff and more ...
 * This file assumes operation on a CP/M system
 */

#define EXTERN extern
#include "yamc86.h"
/* dpb dph blocks from CP/M Interface Guide Sect 6.5 */

struct dpb {			/* CP/M Version 2 Disk Parameter Block */
	unsigned dpb_spt;	/* sectors per track */
	unsigned char dpb_bsh;		/* block shift factor */
	unsigned char dpb_blm;
	unsigned char dpb_exm;		/* Extent Mask */
	unsigned dpb_dsm;	/* Highest block number on this disk */
	unsigned dpb_drm;	/* total number of directory entries -1 */
	unsigned dpb_al;	/* bit field corresponding to direc blocks */
	unsigned dpb_cks;	/* size of the directory check vector */
	unsigned dpb_off;	/* number of reserved tracks on this disk */
};



struct dph {			/* CP/M Version 2 Disk Parameter Header */
	char **dph_xlt;		/* logical to physical xlat vector */
	int dph_ooo;
	char *dph_dirbuf;	/* 128 byte scratchpad for directory use */
	struct dpb *dph_dpb;	/* disk param block for this type of disk */
	char **dph_csv;		/* scratch area for detecting changed disks */
	char *dph_alv;		/* pointer to bit vector alloc map for disk */
};

struct fcb {			/* CP/M Version 2 fcb AS SEEN BY THE USER */
	char	dr;		/* drive number */
	unsigned char fname[8];	/* fname[1] used by TAG2 */
	unsigned char ftype[3];	/* ftype[1] 8th bit set for $SYS */
	unsigned char ex;	/* file extent normally 0 */
	unsigned char s1;	/* reserved for bdos's benefit */
	unsigned char s2;	/* likewise, =0 on call to open,make,search */
	unsigned char rc;	/* record count for extent[ex]  0...128 */
	unsigned char dmap[16];
	unsigned char cr;	/* current record, initialized to 0 by usr */
	unsigned recn;		/* highest record number */
	unsigned char recovf;	/* overflow of above */
};

/* following are BDOS calls */
#define GETVRSN 12		/* cpm bdos version number */
#define SELDSK 14		/* bdos select disk 0=default disk */
#define SRCH 17 		/* bdos search for file pattern*/
#define SRCHNXT 18		/* search for next occurrence */
#define GETDEFDISK 25		/* get current disk  (0-15) */
#define SETDMA 26		/* set address for read, write, etc. */
#define GETALLOCP 27		/* get address of allocation vector */
#define SETATTRIB 30		/* update file attributes */
#define GETDPBP 31		/* get DPB address for disk */
#define SETGETUSER 32		/* set or get user number */
#define COMPFILSIZ 35		/* compute file size into recn and recovf */
#define GETSPACE 46		/* 3.0 call to return sectors free on disk */

#define UFNSIZE 15		/* a:foobar12.urk\0 is 15 chars */

openrx(name)
char *name;
{

	unsigned char option;
#ifdef RESTRICTED
	char *s;
	if(s=cisubstr(name, ".cmd"))	/* upload .cmd files as .obj */
		strcpy(s, ".OBJ");
	if(cisubstr(name, "$$$"))
		return ERROR;		/* don't allow upload of $$$.sub */
	for(s=name; *s; )
		if(*s++ > 'z')
			return ERROR;	/* no garbage names please */
#endif
	option='y'; unspace(name);
	lprintf("'%s' ", name);		/* show the name right away */
	if(!Creamfile && ((fout=fopen(name,"r")) != NULL)) {
		fclose(fout);
#ifdef XMODEM
		printf("Can't upload '%s': file exists\n", name);
		return ERROR;
#else
		printf("Exists ", name);
		printf("Replace/Append/Quit (r/a/q)??");
		if(!index(option=getopt(), "ary"))
			return ERROR;
		putchar('\n');
#endif
	}
	if((option=='a'?(fout=fopen(name,BAPPEND)):(fout=fopen(name,BWRITE)))==NULL){
		printf(" Can't create %s\n", name);
		return ERROR;
	}
	Rfile= TRUE;
	strcpy(Rname, name);
	Dumping= !Squelch;
	lprintf(" Open: Capture O%s\n", Dumping? "n" : "FF");
#ifdef STATLINE
	lpstat("Receiving %s", Rname);
#endif
	return OK;
}

getopt()
{
	int c;
	c = tolower(getcty());
	putcty(c);
	return c;
}

closerx(pad)
{
	if(Rfile) {
#ifdef BDSC
		if(pad)
			do
				putc(CPMEOF, fout);
				while(fout._nleft % SECSIZ);
#endif
		fflush(fout); fclose(fout);
		Rfile=FALSE;
#ifdef LOGRX
		logfile(LOGRX, Rname, pad?'*':'R');	/* record file xmsn */
#endif
	}
}

opentx(name)
char *name;
{
	int printf();
#ifdef XMODEM
	int lprintf();
#endif
/*	struct fcb *fp, *fcbaddr(); */
	char *fcbp;
	int (*fnx)();
#ifndef CDOS
	unsigned spm, dminutes;
	struct fcb fstat;
	spm= Baudrate/23;
#endif
#ifdef XMODEM
	fnx=Batch? lprintf : printf;
#else
	fnx=printf;
#endif
	(*fnx)("'%s' ", name);
	unspace(name);


	if((fin=fopen(name,BREAD))==NULL){
		printf("Can't open %s\n", name);
		return ERROR;
	}
/*
 *	DOWLOADING CHECKING NOT IMPLEMENTED IN YAMC86
 *
 *#ifdef RESTRICTED
 *	if(cisubstr(name, ".bad")
 *	 || (fp=fcbaddr(fin._fd))==ERROR
 *	 || (fp->fname[1] & 0200) */	/* tag2 */
/*	 || (fp->ftype[1] & 0200) */	/* $SYS */
/*	 ) {
 *	 	fclose(fin); printf("\n'%s' Not for Distribution\n", name);
 *		return ERROR;
 *	}
 *#endif
 */
	Tfile= TRUE;
	strcpy(Tname, name);
#ifndef CDOS
	setfcb( &fstat, name);
	bdos(COMPFILSIZ, &fstat);
	dminutes= 1+((10*(1+fstat.recn))/spm)+(fstat.recn/20);
	(*fnx)("Open %u Sectors %dk %u.%u Minutes\n",
	  fstat.recn, fstat.recn>>3, dminutes/10, dminutes%10);
#ifdef STATLINE
	if (!UsePutchar)
		lpstat("%s %u Sectors %dk %u.%u Min",
		  Tname, fstat.recn, fstat.recn>>3, dminutes/10, dminutes%10);
#endif
#else
	(*fnx)("Open\n");
#endif
	return OK;
}

/* closetx(status) call with status != 0 if incomplete file xmsn */
closetx(status)
{
	if(Tfile) {
		fclose(fin);
#ifdef LOGTX
		if(!status)
			logfile(LOGTX, Tname, 's');	/* record file xmsn */
#endif
		Tfile=FALSE;
	}
}

#ifdef PHONES
/* search the phone file for name */
getphone(name, buffer)
char *name, *buffer;
{
	closetx(TRUE);

	if((fin=fopen(PHONES,"r"))==NULL) {
		printf("Cannot open %s\n", PHONES);
		return ERROR;
	} else {
		while(fgets(buffer, 100, fin))
			if(cmdeq(buffer, name)) {
				fclose(fin);
				return OK;
			}
	}
	printf("Can't find data for %s\n", name);
	fclose(fin);
	return ERROR;
}
#endif

/* channge default disk and optionally, user number */
chdir(p)
char *p;
{
	unsigned newuser;

	if(Rfile||Tfile) {
		printf("Must close files first");
		return ERROR;
	}
	newuser=user; *p=toupper(*p);
	if(index(*p, DISKS)) {
		defdisk= *p - 'A';
		bdos(SELDSK, defdisk);
#ifdef CDOS
		return OK;
#else
		printdfr();
		if(!isdigit(p[1]))
			return;
		if((newuser=atoi(p+1)) <= MAXUSER) {
			bdos(SETGETUSER, newuser);
			user=newuser;
			return OK;
		}
#endif
	}
	printf("Disk %c and/or User %d Illegal\n", *p, newuser);
	return ERROR;
}

/* fetch default disk and user number */
initdd()
{
	defdisk= bdos(GETDEFDISK,0);
#ifdef CDOS
	Secpblk=SECPBLK;
	user=0;
#else
	user=bdos(SETGETUSER, 0377);
	printdfr();
#endif
	Phone[0] = 0;			/* initialize Phone to blank line */
#ifdef XMODEM
	bdos(SETGETUSER, LOGUSER);	/* read user's name to Phone */
	if((fin=fopen(LASTCALR,"r"))!=NULL) {
		fgets(Phone, 100, fin);
		fclose(fin);
	}
	bdos(SETGETUSER, user);
#endif
}

/*
 * Z19 gets to use it's 25th line. pstat starts at 48th char
 * note that a call to lpstat will erase what pstat displays
 */
/*VARARGS*/
pstat(a,b,c)
char *a, *b, *c;
{
	char pbuf[40];
#ifdef Z19
	lputs("\033x1\033j\033Y8P");
#endif
	sprintf(pbuf, a,b,c);
	lputs(pbuf);
#ifdef Z19
	lputs("\033K\033k");
#else
	lprintf("\n");
#endif
}

/*
 * Z19 gets to use it's 25th line. lpstat starts at col 1
 * Rest of line is erased
 */
/*VARARGS*/
lpstat(a,b,c,d,e,f,g)
char *a, *b, *c, *d, *e, *f, *g;
{
#ifdef Z19
	lputs("\033x1\033j\033Y8 ");
#endif
	lprintf(a,b,c,d,e,f,g);
#ifdef Z19
	lputs("\033K\033k");
#else
	lprintf("\n");
#endif
}

dolist(argc, argp)
char **argp;
{
	int listfile();
#ifdef XMODEM
	printf("^S pauses, ^K skips to next file, ^X terminates\n");
#endif
	expand(listfile, argc, argp);
}

dodir(argc, argp)
char **argp;
{
	int pdirent();
	cfast=0;		/* counter for 4 across format */
	expand(pdirent, argc, argp);
#ifndef CDOS
	printdfr();
#endif
}
pdirent(name)
{
	printf("%-14s%c", name, (++cfast&03)?' ':'\n');
}
#ifndef CDOS
/* docomp does a directory listing showing sectors for each matched file
 * and computes total transmission time of matched files in batch mode
 * time is sum of:
 * 	number of files * open/close time (assumed 5 seconds)
 *	time to xmit and ACK each sector assuming no path delay or error
 *	disk i/o time at each end, not dependent on baud rate
 */
docomp(argc,argp)
char **argp;
{
	unsigned compsecs();
	unsigned spm;	/* sectors per minute-baud */
	unsigned dminutes;	/* tenths of minutes */
	cfast=Numsecs=Numblks=0;
	expand(compsecs, argc, argp);
	/* (Baudrate*60)/(10 bits each char * 136 chars) */
	spm= Baudrate/23;
	dminutes= Numfiles+((10*(Numfiles+Numsecs))/spm)+(Numsecs/20);
	printf("\n%u Files %u Blocks %u K\n",
	  Numfiles, Numblks, (Numblks*(Secpblk>>3)));
	printf("%u Sectors %u.%u Minutes Xmsn Time at %u Baud\n",
	  Numsecs, dminutes/10, dminutes%10, Baudrate);

}
/* add file length (in CP/M 128 byte records) to Numsecs */
unsigned compsecs(ufn)
char *ufn;
{
	struct fcb fstat;
	char *fcbp;
	printf("%-14s", ufn);
	unspace(ufn);
	setfcb( &fstat, ufn);
	bdos(COMPFILSIZ, &fstat);
	Numsecs += fstat.recn;
	Numblks += (fstat.recn+Secpblk-1)/Secpblk;
	if(CIREADY)
		return ERROR;
	printf("%4u%c",fstat.recn, (++cfast&03)?' ':'\n');
	return fstat.recn;
}
#endif

expand(fnx, argc, argp)
int (*fnx)();
char **argp;
{
	char name[PATHLEN], *s;
	Numfiles=0;

	if(argc<=0)
		return e1xpand(fnx, "????????.???");
	else
		while(--argc>=0) {
			/* change b: to b:*.*     */
			strcpy(name, *argp++);
			if((s=index(':', name)) && *++s == 0)
				strcpy(s, "????????.???");
			if(e1xpand(fnx, name)==ERROR)
				return ERROR;
		}
	return OK;
}

/*
 * e1xpand expands ambiguous pathname afnp
 * calling fnx for each.
 * Modified from: Parameter list builder by Richard Greenlaw
 *                251 Colony Ct. Gahanna, Ohio 43230
 */
e1xpand(fnx, afnp)
int (*fnx)();
char *afnp;	/* possible ambiguous file name*/
{
	struct fcb sfcb, *pfcb;
	int bdoscmd;
	char *p, *q;
	int i, byteaddr;
	int filecount, m;
	char tbuf[SECSIZ];
	struct {
		char xYxx[UFNSIZE];		/* unambiguous file name */
	} *fp;
	int strcmp();
	char *fcbp;

	/* build CPM fcb   */
	unspace(afnp);
	if(setfcb(&sfcb,afnp) == NULL) {
		printf("%s is bad pattern\n", afnp);
		return ERROR;
	}
	snarfbuf();	/* get some buffer */
	/* Search disk directory for all ufns which match afn*/
	for(fp=bufmark,filecount=0,bdoscmd=SRCH;; fp++,filecount++) {
tryanother:
		bdos(SETDMA, tbuf);
		/* seems CP/M outta know whether to use SRCH or SRCHNXT !! */
		byteaddr=bdos(bdoscmd, &sfcb); bdoscmd=SRCHNXT;
		if(byteaddr==255)
			break;
		/* calculate pointer to filename fcb returned by bdos */
		pfcb = (tbuf + 32 * (byteaddr % 4));
/*
 *#ifdef RESTRICTED
 */
	/* check for $SYS or tag bit on 2nd byte of filename (TAG2) */
/*		if((pfcb->fname[1]&0200) ||(pfcb->ftype[1]&0200))
 *			goto tryanother;
 *#endif
 */
		Numfiles++;
		p = fp;
		if(fp>bufend) {	/* Note: assumes some slop after bufend! */
			printf("Out of Memory\n");
			return ERROR;
		}
		if(*(afnp+1) == ':') {
			/* Drive spec.*/
			*p++ = *afnp;
			*p++ = ':';
		}

		/*Copy filename from directory*/
		q = pfcb;
		for(i =8; i; --i)
			*p++ = (0177& *++q);
		*p++ = '.' ;

		/*Copy file extent*/
		for(i = 3; i; --i)
			*p++ = (0177& *++q);
		*p = '\0' ;

	}
	if(filecount==0) {
		printf("'%s' NOT FOUND\n", afnp);
		return ERROR;
	}

	qsort(bufmark, filecount, UFNSIZE, strcmp);

	for(fp=bufmark; --filecount>=0;) {
		p=fp++;
		/* execute desired function with real pathname */
		if((*fnx)(p)==ERROR)
			return ERROR;
	}
	return OK;
}

/*
 * snarfbuf "guarantees" that bufmark points to at least SNARFBUNCH bytes
 * of "unused" space in the big circular buffer
 */
snarfbuf()
{
	if(Wrapped || (bufend-bufcq)<SNARFBUNCH) {
		dumprxbuff();
		clearbuff();	/* so the printer won't try to list dir's */
		bufmark=bufst;
	} else
		bufmark=bufcq;
}

/*
 * cisubstr(string, token) searches for lower case token in string s
 * returns pointer to token within string if found, NULL otherwise
 * ignore parity in strings s
 */
char *cisubstr(s, t)
char *s,*t;
{
	char *ss,*tt;
	/* search for first char of token */
	for(ss=s; *s; s++)
		if(tolower(*s & 0177)==*t)
			/* compare token with substring */
			for(ss=s,tt=t; ;) {
				if(*tt==0)
					return s;
				if(tolower(*ss++ & 0177) != *tt++)
					break;
			}
	return NULL;
}
#ifdef XMODEM

/*
 * lprintf is like regular printf but uses direct output to console
 * This prevents status printouts from disrupting file transfers, etc.
 */

lprintf(a,b,c,d,e,f)
char *a, *b, *c, *d, *e, *f;
{
	char lbuf[CMDLEN], *s;
	/* format data into lbuf */
	sprintf(lbuf, a,b,c,d,e,f);
	/* now send lbuf to console directly */
	for(s=lbuf; *s; ) {
		if(*s=='\n') {
			while(!COREADY)		/* expand \n to \r\n */
				;
			TTYOUT('\r');
		}
		while(!COREADY)
			;
		TTYOUT(*s++);
	}
}
#endif

/* copy string s onto itself deleting spaces "hello there" > "hellothere" */
unspace(s)
char *s;
{
	char *p;
	for(p=s; *s; s++)
		if(*s != ' ')
			*p++ = *s;
	*p++ =0;
}

#ifdef LOGFILE
/*
 * logfile keeps a record of files transmitted.
 */
logfile(log, name, mode)
char *log, *name;
unsigned char mode;
{
	int thedisk;
	char *i;

	/* find out what disk was used */
	thedisk=defdisk + 'a';
	if(i=index(':', name)) {
		thedisk = *name;
		name= ++i;
	}
	if(i=index('\t', Phone))	/* keep just the system name */
		*i = 0;
#ifdef XMODEM
	if(i=index('\r', Phone))	/* keep just user's name */
		*i = 0;
	if(i=index('\n', Phone))	/* keep just user's name */
		*i = 0;
#endif

	bdos(SETGETUSER, LOGUSER);	/* get it from user 0 */
	if(fin=fopen(log,"a")!=NULL) {
		fprintf(fin, "%c %5u	%c%02d:%-14s %s\n",
		 mode, Baudrate, thedisk, user, name, Phone);
		putc(CPMEOF, fin); fflush(fin); fclose(fin);
	}
	bdos(SETGETUSER, user);
}
#endif

#ifdef BIGYAM
crcfile(name)
char *name;
{
	unspace(name);
	oldcrc = 0; wcj = 0;
	if ((Utility.ufbuf=fopen(name,BREAD))==NULL)
		return ERROR;
	while ((firstch=getc(Utility.ufbuf))!=EOF) {
		++wcj;
		oldcrc = updcrc(firstch, oldcrc);
	}
	oldcrc=updcrc(0,updcrc(0,oldcrc));
	fclose(Utility.ufbuf);
	if(CIREADY)
		return ERROR;
	printf("%04x %7u %s\n", oldcrc, wcj, name);
	return OK;
}

docrc(argc, argp)
char **argp;
{
	expand(crcfile, argc, argp);
}

docrck(argc, argp)
char **argp;
{
	int crckfile();

	expand(crckfile, argc, argp);
}

/* Accumulate and print a "crck" for a file */
crckfile(name)
char *name;
{
	unsigned crck();
	char crbuf[SECSIZ]; int fd, st, nsec;

	unspace(name);
	if((fd=open(name,BREAD))==ERROR)
		return ERROR;

	nsec=oldcrc=0;
	while((st=read(fd, crbuf, 128)) ==128) {
			++nsec;
			oldcrc=crck(crbuf, SECSIZ, oldcrc);
	}
	close(fd);
	if(CIREADY)
		return ERROR;
	if(st != 0)
		printf("READ ERROR");
	else
		printf("%04x %4d ", oldcrc, nsec);
	printf(" %s\n", name);
	return OK;
}
#endif

/* print number of free blocks on default disk */
printdfr()
{
	unsigned dseg, dpbbx, dpbes;
	struct dpb dpbloc;
	struct dpb *dp;

	struct regval {	int ax, bx, cx, dx, si, di, ds, es;};

	struct regval srv,rrv;

	srv.cx = GETDPBP;
	sysint(224,&srv,&rrv);
	dpbbx = rrv.bx;
	dpbes = rrv.es;
	segread(&rrv);
	dseg = rrv.cx;
	dp = &dpbloc;
	movblock(dpbbx,dpbes,dp,dseg,15); /* move a copy of dpb local */
	Secpblk= 1 << dp->dpb_bsh;
	printf("%u kb Free on %c  ", getfree(defdisk), defdisk+'A');
}

/* return total free kilobytes of disk */
unsigned getfree(disk)
int disk;
{
	struct dpb dpbloc;	/* local structure */
	struct dpb *dp;
	unsigned char v, *s;
	int c;
	unsigned char vec[512];
	unsigned total, count, dseg, dpbbx, dpbes, alvbx, alves;
	
	struct regval {	int ax, bx, cx, dx, si, di, ds, es;};

	struct regval srv,rrv;

	bdos(SELDSK, disk);
	srv.cx = GETVRSN;
	sysint(224,&srv,&rrv);
	if(((rrv.bx)&0x00FF) >= 0x30) {		/* if version >= 3.0 */
		return(getfre3(disk) >> 3);
	} else					/* if not */
		{
		srv.cx = GETDPBP;
		sysint(224,&srv,&rrv);
		dpbbx = rrv.bx;
		dpbes = rrv.es;
		segread(&rrv);
		dseg = rrv.cx;
		dp = &dpbloc;
		movblock(dpbbx,dpbes,dp,dseg,15); /* move a copy of dpb local */
		srv.cx = GETALLOCP;
		sysint(224,&srv,&rrv);
		alvbx = rrv.bx;
		alves = rrv.es;
		movblock(alvbx,alves,vec,dseg,512); /* make local copy of allocation vec */
		total=0;
		s = vec;
		count=dp->dpb_dsm+1;
		for(;;) {
			v= *s++;
			for(c=0200; c; c>>=1) {
				if((v & c)==0)
					++total;
				if(--count ==0) {
					bdos(SELDSK, defdisk);
					return(total << ((dp->dpb_bsh)-3));
				}
			}
		}
	}
}


/*  Get free sectors left on disk
 *  Uses 3.0 BDOS #46 call
 */

long getfre3(disk)
{
	long lspace = 0;

	bdos(SETDMA,0x0080);		/* c86 always resets dma address
					   b4 read/write, so ok to set here */
	movmem(&lspace,0x0080,4);	/* zero out dma area */
	bdos(GETSPACE,disk);		/* get free sectors on disk */
	movmem(0x0080,&lspace,4);	/* move answer from dma area */
	return(lspace);
}

doerase(argc, argp)
char **argp;
{
	int erasefile();
	expand(erasefile, argc, argp);
#ifndef CDOS
	printdfr();
#endif
}

erasefile(ufn)
char *ufn;
{
	unspace(ufn);
	printf("Erase %s (y/n/q)? ",ufn);

	switch(getopt()) {
	case 'y':
		unlink(ufn);
	case 'n':
		putchar('\n');
		return FALSE;
	}
	return ERROR;
}

#ifdef BIGYAM

/*
 * Sum bytes in file mod 2^16 discard CR and CPMEOF+junk
 */
sumfile(name)
char *name;
{
	unsigned nbytes;

	oldcrc = 0; nbytes = 0;
	unspace(name);
	if ((Utility.ufbuf=fopen(name,BREAD))==NULL) {
		fprintf(stderr, "Can't open %s\n", name);
		return ERROR;
	}
	for (; (cfast=getc(Utility.ufbuf))!=EOF && cfast!=032; ) {
		if (cfast=='\r')
			continue;
		++nbytes;
		if (oldcrc&01)
			oldcrc = (oldcrc>>1) + 0x8000;
		else
			oldcrc >>= 1;
		oldcrc += cfast;
	}
	fclose(Utility.ufbuf);
	if(CIREADY)
		return ERROR;
	printf("%5u%7u %s\n", oldcrc, nbytes, name);
	return OK;
}
dosum(argc, argp)
char **argp;
{
	int sumfile();
	expand(sumfile, argc, argp);
}


/*
 * count lines words bytes and carriage returns in file
 */
wcfile(name)
char *name;
{
	unsigned lines, words, ncr;

	unspace(name);
	if ((Utility.ufbuf=fopen(name,BREAD))==NULL)
		return ERROR;
	lines = words = firstch = ncr = 0; checksum = 0;
	for (;;) {
		cfast = getc(Utility.ufbuf);
		if (cfast == EOF || cfast == 032)
			break;
		++firstch;
		if (cfast>040 && cfast<0177) {
			if (!checksum) {
				++words; ++checksum;
			}
			continue;
		}
		if (cfast=='\n')
			++lines;
		else if (cfast=='\r')
			++ncr;
		else if (cfast!=' ' && cfast!='\t')
			continue;
		checksum = 0;
	}
	fclose(Utility.ufbuf);
	if(CIREADY)
		return ERROR;
	printf("%7u%7u%7u%7u %s\n", lines,words, firstch-ncr, firstch, name);
	return OK;
}
dowc(argc, argp)
char **argp;
{
	expand(wcfile, argc, argp);
}

dodumph() {}	/* requres non BDS-C features */

#endif

/*
 * Perform various operating systetm dependent initializations that should
 *  be performed but once.
 */
onceonly()
{
	unsigned core;
	core = coreleft()-12000;
	if(core < 5000) {	/* check for enough memory */
		printf("urk"); exit();				
	}							
	bufst = alloc(core);
	bufend = bufst + core;
	T1pause=290*CLKMHZ;	/* calibration for deciseconds in readline() */
}

/*
 * init resets all variables to their "standard" values (whatever that
 *  is ...).  Init is called at the beginning of yam and when the "init"
 *  command is given.
 */
init()
{
#ifdef USERINIT
	userinit();	/* allows extra user externs' to be initialized */
#endif
	initdd();		/* fetch default disk and user number */
	Dport=DPORT; Sport=SPORT;
#ifndef DEFBAUD
	readbaud();
#else
	Baudrate=DEFBAUD;
#endif
#ifdef INITBAUD
	setbaud(Baudrate);
#endif
	Mstatus=0;	
	Onetrip=Exitchar=Rfile=Tfile=Pflag=FALSE;
	Cis02=Twxmode=Image=Waitbunch=Exoneof=Hdx=Zeof=Squelch=FALSE;
	Txgo=TRUE;
	Parity= NORMAL;
	Originate= TRUE;
	Txeoln= EOL_NOTHING;
	Tpause=1500*CLKMHZ; Throttle=22*CLKMHZ;
	Waitnum=1;
	GOchar= '\n';
	clearbuff();
}

/* pause n 1/10s of a sec */

sleep(n)
int n;
{
	int i,j;
	for(i=0; i<n; i++) for(j=0;j<(LOOPS);j++);
}

#ifdef C86		

gets(buffer)
char buffer[];
{
	register char *cp;
	register int i = 0;
  /* open con: as non-binary read for buffered input */
 	fclose(stdin);
	fopen("CON:","r");
	cp = buffer;
	while ((i = getchar()) != EOF && i != '\n')
		*cp++ = i;
	*cp = 0;
	if (i == EOF && cp == buffer) {
		fclose(stdin);
		fopen("CON:",BREAD);
		return NULL;
	}
  /* reopen con: as binary read for character by character input */
	fclose(stdin);
	fopen("CON:",BREAD);
	return buffer;
}

#endif

/*	make a cp/m file control block
*/

setfcb(fcb,filename)
struct fcb *fcb;
unsigned char *filename;
{
  int u;

  setmem(fcb,36,0);
  if(filename[1]==':'){
    u=toupper(*filename);
    if(u>='A' && u<='P')fcb->dr=u-('A'-1);	/* set drive number */
    else goto error;
    filename+=2;
  }
  setmem(fcb->fname,11,' ');			/* space fill fn and ft */
  if(_setfcb(fcb->fname,8,&filename)||_setfcb(fcb->ftype,3,&filename))
    goto error;
  return(1);			/* all ok */

error:
err01:
  return 0;
}

/*	a service routine for setfcb
*/

_setfcb(outstr,outlen,filename)
unsigned char *outstr,**filename;
int outlen;
{
  unsigned char *cp;
  int u;

  for(cp=*filename;*cp;){		/* do file name */
    u=toupper(*cp++)&0x7f;
    if(u=='.')break;			/* that part done */
    if(u<0x21)return 1;			/* some protection */
    if(u=='*'){
      while(outlen){
         *outstr++='?';
         --outlen;
      }
   }
    if(outlen){
      --outlen;
      *outstr++=u;
    }
  }
  *filename=cp;
  return 0;
}

/* direct bios call through bdos */

bios(func,arg1,arg2)
int func,arg1,arg2;
{
unsigned char params[5];

	params[0] = func&0xFF;		/* bios function number */
	params[1] = arg1&0x00FF;	/* register CL		*/
	params[2] = arg1&0xFF00;	/* register CH		*/
	params[3] = arg2&0x00FF;	/* register DL		*/
	params[4] = arg2&0xFF00;	/* register DH		*/

	return(bdos(50,params));
}
