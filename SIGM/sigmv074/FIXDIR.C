/*	FIXDIR.C 22nd Jan 1981

	This program will "clean" a CP/M directotry of illegal file
	names. The user is given the option of erasing or renaming
	the illegal file. The program is fast, even on big directories.
	See the accompanying FIXDIR.DOC for a full discussion.

	By	Bill Bolton,
		Software Tools,
		P.O. Box 80,
		Newport Beach,
		NSW, 2106
		Australia

*/

#define VERSION 12
#define OPEN 15
#define SEARCH_FIRST 17
#define SEARCH_NEXT 18
#define DELETE 19
#define RENAME 23
#define SETDMA  26
#define SEC_BUF 0X80
#define DEL 0X7F

int	space;		/* Count of spaces found in file name */
int	error_count;	/* Count of bad file names found in directory */
int	pass;		/* Number of recursions */
char	drive[1];	/* Storage for drive identifier */

main (argc,argv)	/* Search CP/M directory for bad file names */

int	argc;
char	*argv[];

{
	pass = 0;
	printf("\tFIXDIR version 1.00 \n");
	printf("\t(C) 1981, Software Tools - Sydney, Australia.\n");
	printf("\tCorrects illegal file names in a CP/M disk directory.\n\n");
	dir_check(argc,argv);
	printf("\n\tNo illegal file names in directory on this pass.\n\n");
	if (pass > 1)
		printf("\tThere were %d passes performed.\n",pass);
	exit();
}

dir_check(argc,argv)

int	argc;
char	*argv[];

{
	int	n;
	char	filename[15];
	char	*buf;
	char	fcb1[36];

	error_count = 0;		/* Initialise some variables */
	space = 0;
	buf = SEC_BUF;
	pass++;

	if (argc > 2){			/* Too many command line args ? */
		command_error(argv[2]);
		}
	strcpy(filename,"");
	strcpy(drive,"");
	if (argc == 2)
		if (strlen(argv[1]) == 2 && isdrive(argv[1])){
			strcpy(filename,argv[1]);
			strcpy(drive,argv[1]);
			}
		else{
			command_error(argv[1]);
		}
	strcat(filename,"????????.???");
	setfcb(fcb1,filename);
	bdos(SETDMA,buf);
	n = bdos(SEARCH_FIRST,fcb1);
	valid_check(n,buf);
	while ((n = bdos(SEARCH_NEXT,fcb1)) != 255){
		if(valid_check(n,buf)){
			while(action(n,buf));
		}
	}
	if (error_count){
		printf("\t\nPerforming another pass.\n\n");
		dir_check(argc,argv);
	}
}

/* Checks for legal CP/M drive identifier in range A: through P: */

int isdrive(s)

char *s;

{
	toupper(*s);
	return (*s >= 'A' && *s <= 'P' && *++s == ':');
}

/* Checks for legal CP/M directory entry, if illegal entry found prompts
   for erase or rename */

int valid_check(n,buf)

int	n;
char	*buf;

{
	int	i;

	if (n == 255)			/* Error indicator from caller */
		return(n);
	buf += (n * 32);
	for (i = 1; i < 12; ++i){
		if (bad_char(i,buf))
			return(-1);
	}
	return(0);
}

/* Checks if a character is legal in a CP/M directory entry or file control
   block */

int bad_char(i,buf)

int	i;
char	*buf;

{
	char	temp[0];		/* Transient storage for > del test */

	if (i == 1 || i == 9)		/* Reset at start of filename & typ */
		space = 0;		 
	switch (buf[i]){
	case  '*':
	case  ',':
	case  '.':
	case  ':':
	case  ';':
	case  '<':
	case  '=':
	case  '>':
	case  '?':
	case  '[':
	case  ']':
	case  DEL:
		return(-1);
	case  ' ':			/* Space is conditionally illegal */
		if (space == 7)		/* Filename is all spaces is a */
			return(-1);	/* definite error */
		space++;		/* Else just keep track of how many */
		return(0);
	}
	if (buf[i] < ' ' || (buf[i] >= 'a' && buf[i] <= 'z'))
		return(-1);
	if (buf[i] > DEL){		/* Bit 7 set may be legal attribute */
		*temp = buf[i] & DEL; 	/* so force it to 0 and try again */
		return (bad_char(0,temp));
	}
	else
		return(space);		 /* Space preceeding char IS illegal */
}

/* Erases or renames a file in CP/M directory */

int	action(n,buf)

int	n;
char	*buf;

{
	char	temp_buf[36];
	char	fcb[36];
	
	buf += (n *32);
	setmem(temp_buf,36,0);
	movmem(buf+1,temp_buf+1,11);
	error_count++;

	printf("\07\n\tIllegal CP/M file name : %.8s.%.3s\n\n\07",
		buf+1,buf+9);
	printf("\t%s\n\t\t%s\n\t%s",
		"Press 'E' to erase file",
		"Or",
		"Press 'R' to rename file : ");
	if (toupper(getchar()) == 'E')
		return(erase(temp_buf));
	else
		return(rename(temp_buf));
}

/* Erases a file from CP/M directory */

int erase(buf)

char	*buf;

{
	printf("\n\n\tDELETING %.8s.%.3s\n",buf+1,buf+9);
	makefcb(buf,drive);
	if(bdos(DELETE,buf) == 255){
		printf("\07\n\tBDOS DELETE ERROR\n\07");
		return(-1);
	}
	return(0);
}
			
/* Renames a file in  CP/M directory with file name supplied from console */

int rename(buf)

char	*buf;

{
	char	fcb[36];

	get_name(fcb);
	if (strlen(drive))
		*fcb = *drive - '@';		/* Put drive into fcb */
	if(bdos(OPEN,fcb) != 255){
		printf("\07\n\tFilename entered ALREADY EXISTS !\n\07");
		return(-1);
	}
	makefcb(buf,drive);
	strcpy(buf+17,fcb+1);
	printf("\n\tRENAMING %.8s.%.3s to %.8s.%.3s\n",
		buf+1,buf+9,buf+17,buf+25);
	if(bdos(RENAME,buf) == 255){
		printf("\07\n\tBDOS RENAME ERROR\n\07");
		return(-1);
	}
	return(0);
}

/* Makes a valid CP/M file control block from name supplied from console */

int get_name(fcb)

char	*fcb;

{
	char	new_name[43];		/* Make big for bullet proofing */

	printf("\n\n\tEnter new file name :");
	gets(new_name);
	setfcb(fcb,new_name);
	while(valid_check(0,fcb)){
		printf("\07\n\tBAD FILENAME entered as new name !\n\07");
		get_name(fcb);
		}
}

/* Makes a CP/M file control block from a CP/M directory entry */

int makefcb(buf,ident)

char	*buf;
char	*ident;

{
	if (strlen(ident))
		*buf = *ident - '@';	/* Put drive into fcb */
	else
		*buf = 0;		/* Use auto disk select */
	setmem(buf+12,24,00);		/* Initialise rest of fcb */
}

/* Displays an error message showing incorrect command line argument */

int command_error(s)

char	*s;

{
	printf("\07Command line error : %s\n\n\07",s);
	printf("USAGE :\n\tFIXDIR\n\tFIXDIR B:\n\n");
	printf("\tExiting to CP/M\n");
	exit();
}
