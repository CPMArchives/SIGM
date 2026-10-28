/*

	WILDCARD FILE RENAME PROGRAM

	By David Brown, Australia

Version list, most recent version first
 
21/Jul/83
	Expanded usage message so that it gave meaningful help.
	Version list and this descriptive header added,
	Version 2.1, Bill Bolton

	Fixed initial bugs in version 1. Version 2, David Brown

	Initial implementation, placed on "Software Tools" RCPM.
	Version 1, David Brown

*/

#include <bdscio.h>
#include <bdos.h>

#define VERSION "2.1"	/* version 1 didn't work */
#define FCBSIZ 36	/* size of a CP/M File Control Block */
#define NAMLEN 20	/* should be plenty for a filename */


        char oldfcb[FCBSIZ], newfcb[FCBSIZ];

#define LIST struct lst_entry
#define LISTSIZ (NAMLEN+2)
LIST {
	char	name[NAMLEN];	/* name in CP/M format e.g. 1/B:FOO.BAR */
        LIST    *next;
};
	LIST *o_head, *n_head, *a_head;   /* lists of filenames */

	char	def_usr;	/* saves the current user area */
	char	def_drv;
	int	count;		/* counts how many renames were done */

main(argc, argv)
char **argv;
{

	char usr_new, usr_old;
	char drv_new, drv_old;

	count = 0;

	def_usr = bdos(USERCODE,0xff);
	def_drv = bdos(GETCURRENT);   /* 0=A 1=B ... */

	o_head = n_head = a_head = NULL;

	printf("\nCP/M 'Wildcard' File Rename Utility, Version %s\n",VERSION);
        if (argc != 3) {
		printf("\nUsage:\n");
		printf("\tRENAME filename1 filename2\n\n");
		printf("Where:\tfilename1\tis any legal CP/M 'ambiguous' file identifier\n");
		printf("\t\t\tand is the 'NEW' filename\n\n");
		printf("\tfilename2\tis any legal CP/M 'ambiguous' file identifier\n");
		printf("\t\t\twith the wildcard characters in the same place\n");
		printf("\t\t\tas filename1. It is the 'EXISTING' filename\n\n");
		printf("Note:\t? and * are wildcard characters in CP/M file indentifiers\n\n");
		printf("See RENAME.DOC for a full explanation of command line syntax\n\n");
		bye(ERROR);
        }

	usr_new = stripusr(&argv[1]);  /* remove user area prefix, */
	usr_old = stripusr(&argv[2]);  /*   if it is there.. */
	if (usr_new != usr_old) {
		printf("\nUser areas must be the same\n");
		bye(ERROR);
	}

	drv_new = stripdrv(&argv[1]);	/* remove drive prefixes */
	drv_old = stripdrv(&argv[2]);
	if (drv_new != drv_old) {
		printf("\nDrives must be the same\n");
		bye(ERROR);
	}

	setfcb(oldfcb,argv[2]); /* make up the fcb's */
	setfcb(newfcb,argv[1]);
	if (chkwild() == ERROR) {
		printf("\nNames must be 'ambiguous' in a reasonable way.\n\n");
		printf("See RENAME.DOC file for a definition of \"reasonable\"\n");
		bye(ERROR);
        }

	bdos(SELECTDISK,drv_new);  /* change to required drive */
	bdos(USERCODE,usr_new);   /* and user area	      */

        makeold();      /* generate list of old names */
        makenew();
        makeall();      /* generate list of all filenames */

	dorens();	/* rename all the files */

	if (count)
		printf("\n%d files renamed.\n",count);
	else
		printf("\nNo files renamed.\n");

	bye(OK);
}

bye(status)
{
	bdos(SELECTDISK,def_drv);	/* reset drive and user */
	bdos(USERCODE,def_usr);
	exit(status);
}

char stripusr(s)
char **s;	/* need ptr to ptr as will update it */
{

	char *t;	/* scan ptr */
	int  usr;

	t = *s;
	while (isdigit(*t))  /* advance to first non-numeric */
		t++;
	if (*t++ != '/')
		return def_usr; /* no user area prefix */

	usr = atoi(*s); /* get user area */

	if (usr > 31 || usr < 0)    /* not possible, thus must be part of */
		return def_usr;     /*	name, so go back with default */

	*s = t; 	/* delete prefix from our input string */
	return usr;
}

chkwild()	/* ensures that are wild in correct manner - see .DOC */
{
	char i;

	for (i=0; i<12; i++)
		if (oldfcb[i] != '?' && newfcb[i] == '?')
			return ERROR;
}

char stripdrv(s)
char **s;	/* need ptr to ptr as will update it */
{

	int  drv;

	if ((*s)[1] != ':')	   /* no drive prefix if no colon */
		return def_drv;

	drv = toupper(**s) - 'A';
	if (drv < 0 || drv > 15)
		return def_drv;

	*s += 2;	/* advance past drive */

	return drv;

}

makeold()
{

	char dma[SECSIZ], nme[NAMLEN];
	char index;	/* returned by search function */

	bdos(SETADDRESS,dma);

	index = bdos(SEARCHFIRST,oldfcb);
	while (index != 255) {
		unsetfcb(dma+index*32,nme);
		addlst(&o_head,nme);
		index = bdos(SEARCHNEXT,oldfcb);
	}
}

makenew()
{
	char o_fcb[FCBSIZ];	/* holds ufn of current old file */
	char n_fcb[FCBSIZ];	/*  "	  "   "    "	new  "	 */
	char nme[NAMLEN];

	LIST *trav;
	int  i;

	trav = o_head;
	while (trav != NULL) {		/* traverse old names */
		setfcb(o_fcb,trav->name);
		for (i=1;i<12;i++) {	/* scan the wild version */
			if (oldfcb[i]=='?') {	    /* needs to change ? */
				if (newfcb[i] == '?')	   /* yes .. */
					n_fcb[i]=o_fcb[i];
				else
					n_fcb[i]=newfcb[i];
			} else
				n_fcb[i]=newfcb[i];  /* No, just copy */
		}
		unsetfcb(n_fcb,nme);
		addlst(&n_head,nme);
		trav = trav->next;
	}
}

makeall()
{

	char dma[SECSIZ], nme[NAMLEN], fcb[FCBSIZ];
	char index;	/* returned by search function */


	setfcb(fcb,"*.*");	/* all files */

	bdos(SETADDRESS,dma);

	index = bdos(SEARCHFIRST,fcb);
	while (index != 255) {
		unsetfcb(dma+index*32,nme);
		addlst(&a_head,nme);
		index = bdos(SEARCHNEXT,fcb);
	}
}

dorens()	/* do actual renames */
{

	char ch;

	while (o_head) {
		if (exists(n_head)) {	/* if exists, what do I do now ? */
			printf("%s to %s, exists - ",
				    o_head->name,n_head->name);
			printf("(Q)uit,(S)kip,(K)ill : ");
			scanf("%c",&ch);
			switch(toupper(ch)) {
				case 'Q' : bye(ERROR);
				case 'K' : unlink(n_head->name);
					   rename(o_head->name,n_head->name);
			}
		} else {
			rename(o_head->name,n_head->name);
			count++;
		}
		o_head = o_head->next;
		n_head = n_head->next;
	}
}

unsetfcb(f,n)	/* do opposite of "setfcb". This IGNORES the drive field */
char *f, *n;
{
	char *f_save;

	f_save = f++;	/* save initial pos and ignore drive */

	while (*f != ' ' && f < f_save+9)
		*n++ = *f++;	/* copy till a blank */
	*n++ = '.';
	f = f_save + 9; /* point at type */
	while (*f != ' ' && f < f_save+12)
		*n++ = *f++;
	*n = '\0';
}

addlst(h,n)
char **h, *n;
{

	char *trav;

	trav = *h;

	if (*h == NULL) {
		*h = getmem(LISTSIZ);
		(*h)->next = NULL;
		strcpy((*h)->name,n);
	} else {
		trav = *h;
		while (trav->next != NULL)
			trav = trav->next;
		trav->next = getmem(LISTSIZ);
		trav = trav->next;
		trav->next = NULL;
		strcpy(trav->name,n);
	}
}

char *getmem(n)
{
	char *s;
	s = alloc(n);
	if (!s) {
		printf("\nOut of memory - see notes RENAME.C source file\n");
		bye(ERROR);
		/* this will only happen if you have a lot of
			directory entries that need to be matched
			e.g. for 128 entries, need 20K free at MOST
			otherwise I have a bug
		*/
	}
	return s;
}

exists(n)	/* does n exist in list of all files in drive/user */
char *n;
{

	LIST *trav;

	trav = a_head;
	while (trav) {
		if (strcmp(trav->name,n) == 0)
			return TRUE;
		trav = trav->next;
	}
	return FALSE;
}