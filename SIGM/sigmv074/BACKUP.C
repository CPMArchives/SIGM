/*
	BACKUP is by Steve de Plater

	66 Priam St.
	Chester Hill, NSW, 2162, Australia
	Phone: (02) 644 4009

VERSION LIST - Most recent version first.

04/Jul/82 Added "usage" display when  a "?" is entered
	  on command line or in response to drive prompt.
	  Bill Bolton, Software Tools	


You may make as many copies of this programme in either
source or .COM forms as you like for your own use, or for
your friends, relatives, dogs, cats, mothers-in-law etc.
HOWEVER if I ever hear of anyone commercially marketing
this I'll come and find them and insert their heads
into an S-100 slot!!!

All I ask is that because I did the original work that
you leave my name where it is in the programme. After
all, nobody else should get the blame for my shoddy
programming!

The function of BACKUP is to copy files from one disk to
another much as PIP does. The difference is that BACKUP
normally will not make a copy when a filename is found on
the destination disk. Therefore, if this programme is used
then you can be sure that NO files will accidently be 
clobbered!

BACKUP also allows the following features:
(i)	many filename masks may be included together.
	They must be separated only by commas, NO SPACES!
	e.g. "*.com,backup.c"
(ii)	The NOT wildcard is supported when used as the first
	character of a filename mask.
	e.g. "!*.com" would match ALL the non .COM files.
(iii)	both source and destination disks may be changed
	many times during a run, as prompted by BACKUP.
(iv)	If required, existing files may be renamed as .BAK
	and then the copy will proceed.
(v)	If required, then ONLY existing files will be copied
	e.g. for installing an updated copy of a compiler etc.
(vi)	If required, the copy will be stopped at the first ^Z
	detected.
(vii)	If required, the VERIFY programme will be called
	automatically, and the BACKUP parameters will be
	passed to it.

CALLING PROCEDURE:

BACKUP may be called simply by typing BACKUP<cr>;
however, the following parameters may be included on the
CP/M command line:
(i)	mask(s)	This must be the first parameter and will
		control which files are copied.

ALL THE PARAMETERS WHICH FOLLOW MAY OCCUR IN ANY ORDER AT ALL
WITH OR WITHOUT SPACES BETWEEN THEM.

(ii)	<d	copy FROM drive 'd'
(iii)	>d	copy TO   drive 'd'
(iv)	n	Don't prompt for disk changes
(v)	b	If file exists rename to .BAK and then copy
(vi)	v	Run VERIFY after BACKUP is finished
(vii)	z	Copy only to the first CP/M EOF (^Z).
(viii)	i	Inverse mode. Copy ONLY files which exist on
		both source and destination disks.
(ix)	d	Debug mode. Show where everything is in RAM
		BACKUP configures itself to make the most of
		your system.
(x)	r	Remember which files have been backed up so
		that subsequent runs will not repeat.
		(Implies also the Check mode below.)
(xi)	c	Check (only) for previous backups
(xii)	p	Print out parameter settings

\*******************************************************/

#include	bdscio.h

#define		VERSION	"1.3"
#define		STACKSPACE	0x1000
#define		DATE	"July 5th, 1982"
#define		TIME	"14:00"

#define	V_DEFAULT FALSE		/* these default values	*/
#define	Z_DEFAULT FALSE		/* should be changed to	*/
#define	N_DEFAULT FALSE		/* configure any special*/
#define	B_DEFAULT FALSE		/* BACKUP for any	*/
#define	M_DEFAULT FALSE		/* particular application*/
#define	D_DEFAULT FALSE
#define	R_DEFAULT FALSE
#define C_DEFAULT FALSE
#define P_DEFAULT TRUE

char	mask	[50];		/* Buffer for filename masks */
char	pass_mask [50];		/* The masks passed to VERIFY*/
char	work_mask [16];
char	fcb1	[36];
char	fn	[14];
int	code;
int	files;
int	copies;
char	*dir;			/* Where to find DIR	*/
char	*databuf;		/* Where to buffer stuff */
unsigned stackspace;
int	sectors;		/* sectors to buffer	*/
char	id;
char	od;
char	ld;
char	fn1	[16];
char	fn2	[16];
char	fn3	[16];
char	fn4	[16];
char	temp	[20];
char	verify;
char	ctr_z;
int	found_eof;
int	no_wait;
int	debug;
int	bak;
int	mode;
int	remember;
int	check;
int	parm;
int	no_bak;
int	read_only;
int	system;
int	bak_flag;
int	not_mask;
char	mask2	[36];
int	masks;
int	matched;
int	total_matched;
int	total_copied;
int	no_questions;


main (argc,argv)
char	**argv;

{
	int	x;
	int	p,z;
	char	*y;

	
	y = 0x501;	*y = 0x20;	/* modifies fn
					 'legfc' in RTP */
	stackspace = STACKSPACE;	/* configure	*/
	dir = endext ();		/* the RAM	*/

	printf ("\nBACKUP, Ver %s, ",VERSION);
	printf ("%s, by Steve de Plater\n\n",DATE);

	verify   = V_DEFAULT;
	ctr_z    = Z_DEFAULT;
	no_wait  = N_DEFAULT;
	bak      = B_DEFAULT;
	mode     = M_DEFAULT;
	debug    = D_DEFAULT;
	remember = R_DEFAULT;
	check    = C_DEFAULT;
	parm	 = P_DEFAULT;

	getclp (argc,argv,&id,&od,
		&verify,&ctr_z,&no_wait,&bak,&mode,&debug,
		&remember,&check,&parm);

	if (remember)
		check = TRUE;

	if (parm){
		printf ("Parameter flag settings for this run are:\n");
		printflg ("(i)    Run Verify   :",verify);
		printflg ("(ii)   Stop on ^Z   :",ctr_z);
		printflg ("(iii)  No-Waiting   :",no_wait);
		printflg ("(iv)   Backup file  :",bak);
		printflg ("(v)    Inverse mode :",mode);
		printflg ("(vi)   Debug mode   :",debug);
		printflg ("(vii)  Remember     :",remember);
		printflg ("(viii) Check prev.  :",check);
	  	putch ('\n');
	}

	if (argc < 2)
		getmask ();
	else
		strcpy (mask,argv[1]);
		strcpy (pass_mask,mask);

	ld=bdos(25) + 'A';

	matched = copies = total_matched = total_copied = 0;
	no_questions = TRUE;
	do_it ();

}

getmask ()

{
	int	x;

	printf ("Which files?       ");
	gets (mask);
	for (x=0; *(mask+x); x++)
		*(mask+x) = toupper (*(mask+x));
	no_questions = FALSE;
}

getdir (fcb)
char	*fcb;

{
	int	x,y,z;
	char	*s;

	y=files<<4;
	s=0x80+(code<<5);
	if (*(s+12))
		return;
	files++;
	for (x=0; x<16; x++){
	 	dir[y]=*(s+x);
		y++;
	}
}

match_mask (s)
char	*s;

{
	int	x,y;

	y=TRUE;
	for (x=1; x<12; x++){
	  	if (((*(s+x)&0x7f) != mask2[x]) &&
	      	(mask2[x]	     != '?'	)){
	    		y=FALSE;
		}
	}
	if (not_mask)
		return !y;
	else
		return y;
}

does_exist (s)
char	*s;

{
	char	fcb [36];

	setfcb (fcb,s);
	if (bdos (17,fcb) > 3)
		return FALSE;
	else
		return TRUE;
}

copy (s1,s2)
char	*s1,*s2;

{
	int	fd1,fd2;
	int	x,y,z;
	int	records;

	records=0;
	if ((fd1=open (s1,0)) == ERROR){
		printf (" OPEN ERROR: Can't open '%s\n",s1);
		quit (1);
	}

	if ((fd2=creat (s2)) == ERROR){
		change_disks (s2,fd1,fd2);
		return;
	}

	found_eof = FALSE;

	while (TRUE){
		x = read (fd1,databuf,sectors);
		if (!x)
		break;
		if (ctr_z)
			z = check_eof (databuf,x);	/* returns sector */
		else					/* which contains */
			z = x;				/* ^Z 		  */
		y = write (fd2,databuf,z);
		if (y != z){
			change_disks (s2,fd1,fd2);
			return;
		}
		records+=z;
		if (z < sectors)
			break;
		if (found_eof)
			break;
	}
	close (fd2);
	fabort (fd1);
	fabort (fd2);
	printf ("%4d records    ",records);
	if (read_only)
		printf ("R/O ");
	else
		printf ("    ");

	if (system)
		printf ("SYS ");
	else
		printf ("    ");

	if (bak_flag)
		printf ("BAK");
	putch ('\n');
	copies++;
}

quit (a)
int	a;

{
	char	t1[5],t2[5];

	if (!a){
		printf ("%d file",matched);
		if (matched != 1)
			putch ('s');
		printf (" matched, %d copied\n",copies);
	}
	total_matched += matched;
	matched = 0;
	total_copied += copies;
	copies = 0;

	if (!no_wait){
		printf ("\nMore ? ");
		if (toupper (getchar ()) == 'Y'){
			printf ("\n\n");
			getmask ();
			id = od = FALSE;
			do_it ();
		}
		printf ("\nTotal Matched %d, Total Copied %d",
		total_matched,total_copied);
		printf ("\nMount system disk on drive '%c'\n",ld);
		printf ("  press <CR> to continue: ");
		bios (3);	putch ('\n');
	}

	temp[0]=ld;
	temp[1]=':';
	temp[2]=0;
	strcat (temp,"verify.com");
	if (verify)
		if (does_exist (temp)){
			t1[0]=id;
			t2[0]=od;
			t1[1]=0;
			t2[1]=0;
			strcpy (temp,"<");
			strcat (temp,t1);
			strcat (temp,">");
			strcat (temp,t2);
			if (ctr_z)
				strcat (temp,"Z");
			if (no_wait)
				strcat (temp,"N");
			if (debug)
				strcat (temp,"D");
			execl ("verify",pass_mask,temp,0);
	}
	else
	  	  printf ("\nVERIFY.COM not on logged disk\n");
	exit (0);
}

trim_mask (s)
char	*s;

{
	char	*x;
	char	t[16];

	x=s;
	if (*(x+1) == ':')
		x+=2;
	strcpy (t,x);
	strcpy (s,t);
}

check_eof (s,a)
int	a;
char	*s;

{
	int	x,y;

	y=a<<7;
	for (x=0; x<y; x++)
		if (*(s+x) == CPMEOF){
			return ((x>>7)+1);
			found_eof = TRUE;
		}
	return a;
}

getclp (argc,argv,i,o,v,z,n,b,m,d,r,c,p)
int	argc;
char	**argv;
char	*i;		/* source disk			*/
char	*o;		/* destination disk		*/
int	*v;		/* verify flag			*/
int	*z;		/* CP/M EOF (^Z) flag		*/
int	*n;		/* no stop for disk change flag */
int	*b;		/* >> to 'file'.BAK		*/
int	*m;		/* mode flag, 'i' for inverse	*/
int	*d;		/* debug mode flag		*/
int	*r;		/* Remember (f4) flag		*/
int	*c;		/* Check the (f4) flag		*/
int	*p;		/* Print out Parameter settings	*/

{
	char	line [100];
	int	x;

	*i=*o=FALSE;
	if (argc<3){
		if (*argv[1] == '?'){
			usage();
			exit(0);
		}
		return;
	}
	strcpy (line,argv[2]);
	for (x=3; x<argc; x++)
		strcat (line,argv[x]);
	for (x=0; x<strlen(line); x++)
		switch (line[x])
		{
		case '<': {
			*i=line[x+1];
			x++;
			break; }
		case '>': {
			*o=line[x+1];
			x++;
			break; }
	    	case '(': {
			*i=line[x+1];
			x++;
			break; }
	    	case ')': {
			*o=line[x+1];
			x++;
			break; }
	    	case 'V': {
			*v=!(*v);
			break; }
	    	case 'Z': {
			*z=!(*z);
			break; }
	    	case 'N': {
			*n=!(*n);
			break; }
	    	case 'B': {
			*b=!(*b);
			break; }
		case 'I': {
			*m=!(*m);
			break; }
		case 'D': {
			*d=!(*d);
			break; }
		case 'R': {
			*r=!(*r);
			break; }
		case 'C': {
			*c=!(*c);
			break; }
		case 'P': {
			*p=!(*p);
			break; }
		case '?': {
			usage();
			exit(0); }
		}
}

bak_file ()

{
	int	z;

	if (check)
		if (marked (fn1)){
			printf ("Not copying: %-14.14s - previously backed up\n",fn1);
			return;
		}
	printf ("Copying    : %-14.14s - ",fn1);
	copy (fn1,fn2);
	if (read_only || system){
		strcpy (fn1,fn2);
		for (z=0; z<14; z++){
			if (fn2[z] != '.')
				continue;
			z++;
			if (read_only)
				fn2[z]=fn2[z]|0x80;
			z++;
			if (system)
				fn2[z]=fn2[z]|0x80;
	 	}
		rename (fn1,fn2);
	}
	if (remember)
		mark (fn1);
}

cant_kill (fn)
char	*fn;

{
	int	x,y,z;
	char	myfcb [36];
	char	*dma;

	setfcb (myfcb,fn);
	x = bdos (17,myfcb);
	if (x>3)
		return FALSE;
	x=x<<5;
	dma=0x80;
	return *(dma+x+9)&0x80;
}

bak_nor ()

{
	if (does_exist (fn2)){
		if ((bak) && (!no_bak)){
			unlink (fn3);
			rename (fn2,fn3);
			bak_flag=TRUE;
			bak_file ();
		}
		else{
			printf ("File exists: %-14.14s",fn2);
			if ((bak) && (no_bak))
				printf (" -      Read Only!");
			putch ('\n');
		}
	}
	else
		bak_file ();
}

bak_inv ()

{
	if (!does_exist (fn2))
		return;
	if (bak && !no_bak){
		unlink (fn3);
		rename (fn2,fn3);
		bak_flag=TRUE;
	}
	else{
		if (cant_kill (fn2)){
			printf ("FILE EXISTS: %-14.14s",fn2);
			printf (" -      Read Only!\n");
			return;
		}
		unlink (fn2);
	}
	bak_file ();
}

block_copy (s)
char	*s;

{
	int	x,z,p;
	char	*y;
	int	block_size;

	printf ("Matching mask '%s'\n\n",s);

	block_size=0;
	for (x=0; x<files; x++){
		y=dir+(x<<4);
		if (!match_mask (y))
			continue;
		if (*y == 0xe5)
			continue;
		*y=0xe5;
		matched++;
		block_size++;
		for (z=0; z<20; z++)
			temp[z]=NULL;

		for (z=1,p=0; z<9; z++,p++)
			temp[p] = *(y+z)&0x7f;
		while (temp[strlen(temp)-1]==0x20)
			temp[strlen(temp)-1]=NULL;

		strcat (temp,".");
		p=strlen (temp);

		for (z=9; z<12; z++,p++)
			temp[p] = *(y+z)&0x7f;

		read_only = *(y+9)&0x80;
		system = *(y+10)&0x80;

		fn1[0]=id;
		fn2[0]=od;
		fn1[1]=':';
		fn2[1]=':';
		fn1[2]=0;
		fn2[2]=0;
		strcat (fn1,temp);
		strcat (fn2,temp);
		strcpy (fn3,fn2);
		for (z=0; z<13; z++)
			if (fn3[z]=='.')
				fn3[z+1]=NULL;

			strcat (fn3,"BAK");
			bak_flag=FALSE;
			if (cant_kill (fn2) || cant_kill(fn3))
				no_bak=TRUE;
			else
				no_bak=FALSE;

			if (!mode)
				bak_nor ();
			else
				bak_inv ();
	}
	if (!block_size)
		printf ("NO FILE\n");
	printf ("\n");
}

mask_num (a)
int	a;

{
	int	x,y,z;

	y=z=0;
	for (x=0; x<16; x++)
		work_mask[x] = NULL;
	for (x=0; x<strlen(mask); x++){
		if (mask[x] == ',')
			y++;
		if (y==a)
			break;
	}
	if (x >= strlen(mask))
		return;
	if (x)
		x++;
	for (y=x; y<strlen(mask); y++,z++){
		if (mask[y] == ',')
			break;
		work_mask[z] = mask[y];
	}
	trim_mask (work_mask);
	if (work_mask[0]=='!'){
		for (x=0; x<13; x++)
			work_mask[x]=work_mask[x+1];
		not_mask=TRUE;
	}
	else
		not_mask=FALSE;
	setfcb (mask2,work_mask);	
}

do_it ()

{
	int	x,p,z;
	char	*y;

	if (!id){
		printf ("Source Drive:      ");
		id = toupper (bios (3));
		if (id != '\r')
			if (id == '?'){
				printf("\n\n");
				usage();
				exit(0);
			}
			putch (id);
		putch ('\n');
		no_questions = FALSE;
	}

	if (!od){
		printf ("Destination Drive: ");
		od = toupper (bios (3));
		if (od != '\r')
			if (od == '?'){
				printf("\n\n");
				usage();
				exit(0);
			}
			putch (od);
		putch ('\n');
		no_questions = FALSE;
	}

	if (id == '\r')
		id=ld;
	if (od == '\r')
		od=ld;
	if (id == od){
		printf ("\nINPUT & OUTPUT DRIVES MUST DIFFER!\n");
		exit (1);
	}
	if ((id < 'A') || (id > 'P') ||
	    (od < 'A') || (od > 'P')){
		printf ("\nINVALID DRIVE NAME!\n");
		exit (1);
	}

	if (!no_questions)
		printf ("\n");

	if (!no_wait){
		printf ("Mount disks, <CR> to continue: ");
		bios (3);
		printf ("\n\n");
		bdos (13);
	}

	files = 0;
	temp[0]=id;
	temp[1]=':';
	temp[2]=0;
	strcat (temp,"*.*");
	setfcb (fcb1,temp);

	code = bdos (17,fcb1);	/* search for first	*/
	if (code > 3){
		printf ("NO FILE\n");
		quit (1);
	}
	getdir (fcb1);
	while (TRUE){
		code = bdos (18);
		if (code > 3)
			break;
		getdir (fcb1);
	}


	config2();
	masks=0;
	mask_num (0);
	while (strlen(work_mask)){
		block_copy (work_mask);
		masks++;
		mask_num (masks);
	}
	quit (0);
}

config2()

{
	unsigned	x,p,z;
	char		*y,*top;

	top = (topofmem() - stackspace) & 0xff00;
	x = 16*files;
	p = (dir + x + 0x101);
	databuf = p & 0xff00;
	sectors = (top - databuf) >> 7;

	if (sectors < 8){
		printf ("NOT ENOUGH RAM TO RUN THIS PROGRAMME\n");
		quit (1);
	}
	if (debug){
		printf ("Compiled on %s, at %s\n\n",DATE,TIME);
		printf ("Directory assigned at: %04x\n",dir);
		printf ("Entries found:         %4d\n", files);
		printf ("Buffer assigned at:    %04x\n",databuf);
		printf ("Max. Records buffered: %4d\n", sectors);
		printf ("Stackspace Reserved:   %04x\n",stackspace);
		printf ("Top of Buffer at:      %04x\n\n",top);
	}
}

marked (s)
char	*s;

{
	char	fcb [36];
	int	c;
	char	*p;

	setfcb (fcb,s);
	c = bdos (17,fcb);
	p = 0x80 + 32*c + 4;
	if ((*p) & 0x80)
		return TRUE;
	else
		return FALSE;
}

mark (s)
char	*s;

{
	char	fcb [36];

	setfcb (fcb,s);
	fcb[4] = fcb[4] | 0x80;
	bdos (30,fcb);
}

change_disks (s2,fd1,fd2)
char	*s2;
int	fd1;
int	fd2;

{
	char	fcb [36];
	int	x;

	setfcb (fcb,s2);
	for (x=1; x<13; x++)
		fcb[x]=fcb[x]&0x7f;
	bdos (30,fcb);	/* reset flags (R/O etc), and	*/
	bdos (19,fcb);	/* delete incomplete copy	*/
	fabort (fd1);	/* and free up the fds in	*/
	fabort (fd2);	/* the rtp			*/

	printf ("DESTINATION DISK IS FULL,\n\n");
	printf ("  Change disk on drive '%c',\n",od);
	printf ("  press <CR> to continue: ");
	bios (3);
	printf ("\n\n");

	bdos (13);
	if (!mode)		/* check inverse mode		*/
		bak_nor ();	/* and try again		*/
	else
		bak_inv ();
}

printflg (s,a)
char	*s;
int	a;

{
	printf ("  %s ",s);
	if (a)
		printf ("ON\n");
	else
		printf ("OFF\n");
}

usage()

{
	printf("Usage : \t BACKUP parameters\n\n");
	printf("Where valid parameters are:\n\n");
	printf("(i)\tmask(s)\tThis must be the first parameter and will\n");
	printf("\t\tcontrol which files are copied.\n\n");
	printf("ALL THE PARAMETERS WHICH FOLLOW MAY OCCUR IN ANY ORDER\n\n");
	printf("(ii)\t<d\tcopy FROM drive 'd'\n");
	printf("(iii)\t>d\tcopy TO   drive 'd'\n");
	printf("(iv)\tn\tDon't prompt for disk changes\n");
	printf("(v)\tb\tIf file exists rename to .BAK and then copy\n");
	printf("(vi)\tv\tRun VERIFY after BACKUP is finished\n");
	printf("(vii)\tz\tCopy only to the first CP/M EOF (^Z).\n");
	printf("(viii)\ti\tCopy ONLY files which exist on source and dest\n");
	printf("(ix)\td\tDebug mode. Show where everything is in RAM\n");
	printf("(x)\tr\tTag files as they are backed up\n");
	printf("(xi)\tc\tCheck (only) for previous backups\n");
	printf("(xii)\tp\tPrint out parameter settings\n");
}
