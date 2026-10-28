/*******************************************************\
*							*
*	VERIFY: by Steve de Plater			*
*							*
*	66 Priam St.					*
*	Chester Hill NSW, 2224, Australia		*
*	Phone (02) 644 4009				*
*							*
\*******************************************************/


#include	bdscio.h

#define		VERSION	"1.1"
#define		STACKSPACE	0x1000
#define		DATE	"28 Sep 81"
#define		TIME	"17:37"


char	mask	[50];		/* File match mask	*/
char	work_mask [16];
int	masks;
int	matched;
char	mask2	[36];		/* to expand masks into */
int	not_mask;		/* flag for '!' 	*/
char	fcb1	[36];		/* used for bdos calls	*/
char	fn	[14];
char	fnp	[12];		/* fn for display	*/
int	code;
int	files;
int	copies;
char	*dir;			/* Where the DIR goes	*/
char	*dbuf1;			/* First Buffer pointer */
char	*dbuf2;			/* 2nd   Buffer pointer	*/
unsigned stackspace;
int	sectors;		/* buffer size		*/
char	id;			/* assorted disk drive	*/
char	od;			/* specifiers..		*/
char	ld;
char	fn1	[16];
char	fn2	[16];
char	temp	[20];
int	errors;
int	ctr_z;
int	no_wait;
int	debug;
int	dummy;		/* not used - just to stay the	*/
			/* same as backup.c (getclp())	*/
char	found_eof;
int	total_found;
int	total_copied;
int	no_questions;


main (argc,argv)
char	**argv;

{
	int	x;
	int	p,z;
	char	*y;

	y = 0x501;	*y = 0x20;

	stackspace = STACKSPACE;
	dir = endext ();

	printf ("\nVERIFY, ver %s, ",VERSION);
	printf ("1981, by Steve de Plater\n\n");

	if (argc < 2)
	  getmask ();
	else
	  strcpy (mask,argv[1]);
	ld=bdos(25) + 'A';

	getclp (argc,argv,
		&id,&od,&dummy,&ctr_z,&no_wait,&debug);
	total_found = total_copied = matched = copies = 0;
	no_questions = TRUE;
	do_it ();
}

getmask ()

{
	int	x;

	printf ("Which files?  ");
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
	if (*(s+12)) return;
	files++;
	for (x=0; x<16; x++)
	{
	  dir[y]=*(s+x);
	  y++;
	}
}

match_mask (s)
char	*s;

{
	int	x,y;

	y=TRUE;
	for (x=1; x<12; x++)
	  if (((*(s+x)&0x7f) != mask2[x]) &&
	      (mask2[x]	     != '?'	))
	    y=FALSE;
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

check (s1,s2)
char	*s1,*s2;

{
	int	fd1,fd2;
	int	x,y,z,size_err;
	int	records;

	errors =0;
	records=0;
	found_eof = size_err = FALSE;

	if ((fd1=open (s1,0)) == ERROR)
	{
	  printf (" FATAL ERROR: Can't find '%s'\n",s1);
	  quit (1);
	}
	if ((fd2=open (s2,0)) == ERROR)
	{
	  printf (" FATAL ERROR: Can't find '%s'\n",s2);
	  quit (1);
	}

	while (TRUE)
	{
	  x = read (fd1,dbuf1,sectors);
	  if (!x)
	    break;
	  y = read (fd2,dbuf2,sectors);
	  if (!y)
	    break;
	  if (y != x)
	    size_err = TRUE;
	  records += compare (dbuf1,dbuf2,x);
	  if (x < sectors) break;
	  if (found_eof) break;
	}
	fabort (fd1);
	fabort (fd2);
	if (!errors)
	{
	  printf ("%5d records checked (OK)\n",records);
	  copies++;
	}
	else
	  if ((size_err) && (!found_eof))
	    printf ("      SIZE ERROR\n");
	  else
	    printf ("%5d ERRORS FOUND (BYTES)\n",errors);
}

quit (a)
int	a;

{
	if (!a)
	{
	  printf ("%d file",matched);
	  if (matched != 1)
	    putch ('s');
	  printf (" checked, %d verified\n",copies);
	}
	total_found += matched;	matched = 0;
	total_copied += copies;	copies = 0;

	if (!no_wait)
	{
	  printf ("\nMore ? ");
	  if (toupper (getchar ()) == 'Y')
	  {
	    printf ("\n\n");
	    getmask ();
	    id = od = FALSE;
	    do_it ();
	  }
	  printf ("\n\nTotal Matched %d, Total verified %d",
			total_found,total_copied);
	  printf ("\nMount system disk on drive '%c'\n",ld);
	  printf ("  press <CR> to continue: ");
	  bios (3);	putch ('\n');
	}
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

compare (s1,s2,a)
char	*s1;
char	*s2;
int	a;

{
	int	x,y;

	y=a<<7;			/* y = a * 128	*/
	if (ctr_z)
	  for (x=0; x<y; x++)
	  {
	    if ((*(s1+x) == CPMEOF) ||
	        (*(s2+x) == CPMEOF))
	    {
	      found_eof = TRUE;
	      return ((x>>7)+1);
	    }
	    if (*(s1+x) != *(s2+x))
	      errors++;
	  }
	else
	  for (x=0; x<y; x++)
	    if (*(s1+x) != *(s2+x))
	      errors++;
	return a;
}

getclp (argc,argv,i,o,v,z,n,d)
int	argc;
char	**argv;
char	*i;		/* source disk			*/
char	*o;		/* destination disk		*/
int	*v;		/* verify flag			*/
int	*z;		/* CP/M EOF (^Z) flag		*/
int	*n;		/* no stop for disk change flag */
int	*d;		/* debug flag			*/

{
	char	line [50];
	int	x;

	*i=*o=*v=*z=*n=*d=FALSE;
	if (argc<3) return;
	strcpy (line,argv[2]);
	for (x=3; x<argc; x++)
	  strcat (line,argv[x]);
	for (x=0; x<strlen(line); x++)
	  switch (line[x])
	  {
	    case '<': { *i=line[x+1]; x++;  break; }
	    case '>': { *o=line[x+1]; x++;  break; }
	    case '(': { *i=line[x+1]; x++;  break; }
	    case ')': { *o=line[x+1]; x++;  break; }
	    case 'V': { *v=TRUE;	    break; }
	    case 'Z': { *z=TRUE;	    break; }
	    case 'N': { *n=TRUE;	    break; }
	    case 'D': { *d=TRUE;	    break; }
	  }
}

block_check (s)
char	*s;

{
	int	x,z,p;
	char	*y;
	int	block_size;

	printf ("Matching mask '%s'\n\n",s);

	block_size=0;
	for (x=0; x<files; x++)
	{
	  y=dir+(x<<4);
	  if (!match_mask (y))
	    continue;
	  if (*y == 0xe5)
	    continue;
	  block_size++;
	  *y = 0xe5;

	  for (z=0; z<20; z++)	temp[z]=NULL;

	  for (z=1,p=0; z<9; z++,p++)
	    temp[p] = *(y+z);
	  while (temp[strlen(temp)-1]==0x20)
	    temp[strlen(temp)-1]=NULL;

	  strcat (temp,".");	p=strlen (temp);

	  for (z=9; z<12; z++,p++)
	    temp[p] = *(y+z)&0x7f;

	  fn1[0]=id;	fn2[0]=od;
	  fn1[1]=':';	fn2[1]=':';
	  fn1[2]=0;	fn2[2]=0;
	  strcpy (fnp,temp);
	  for (z=0; z<12; z++)
	    fnp[z]=fnp[z]&0x7f;
	  strcat (fn1,temp);
	  strcat (fn2,temp);
	  if (does_exist (fn2))
	  {
	    printf ("Verifying %-12.12s - ",fnp);
	    check (fn1,fn2);
	    matched++;
	  }
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
	for (x=0; x<strlen(mask); x++)
	{
	  if (mask[x] == ',')
	    y++;
	  if (y==a)
	    break;
	}
	if (x >= strlen (mask))
	  return;
	if (x)
	  x++;
	for (y=x; y<strlen(mask); y++,z++)
	{
	  if (mask[y] == ',')
	    break;
	  work_mask[z] = mask[y];
	}
	trim_mask (work_mask);
	if (work_mask[0]=='!')
	{
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


	if (!id)
	{
	  printf ("First Drive:  ");
	    id = toupper (bios (3));
	  if (id != '\r')
	    putch (id);
	  putch ('\n');
	  no_questions = FALSE;
	}
	if (!od)
	{
	  printf ("Second Drive: ");
	    od = toupper (bios (3));
	  if (od != '\r')
	    putch (od);
	  putch ('\n');
	  no_questions = FALSE;
	}

	if (id == '\r') id=ld;
	if (od == '\r') od=ld;
	if (id == od)
	{
	  printf ("FIRST & SECOND DRIVES MUST DIFFER!\n");
	  exit (1);
	}
	if ((id < 'A') || (id > 'P') ||
	    (od < 'A') || (od > 'P'))
	{
	  printf ("INVALID DRIVE NAME!\n");
	  exit (1);
	}

	if (!no_questions)
	  printf ("\n");

	if (!no_wait)
	{
	  printf ("Mount disks, <CR> to continue: ");
	  bios (3);
	  printf ("\n\n");
	  bdos (13);
	}

	files = 0;
	temp[0]=id;	temp[1]=':';	temp[2]=0;
	strcat (temp,"*.*");
	setfcb (fcb1,temp);

	code = bdos (17,fcb1);	/* search for first	*/
	if (code > 3)
	{
	  printf ("NO FILE\n");
	  quit (1);
	}
	getdir (fcb1);
	while (TRUE)
	{
	  code = bdos (18);
	  if (code > 3)
	    break;
	  getdir (fcb1);
	}

	config2();
	masks=0;
	mask_num (0);
	while (strlen(work_mask))
	{
	  block_check (work_mask);
	  masks++;
	  mask_num (masks);
	}
	quit (0);
}

config2 ()

{
	unsigned	x,p,z;
	char		*y,*top,*mid;

	x = 16*files;
	p = (dir + x +0x101);
	dbuf1 = z = p & 0xff00;
	p = (topofmem() - stackspace) & 0xff00;
	sectors = (p - z) >> 8;
	dbuf2 = dbuf1 + (sectors << 7);
	sectors--;			/* for safety!!	*/

	if (sectors < 8)
	{
	  printf ("NOT ENOUGH RAM FOR THIS PROGRAMME!\n");
	  quit (1);
	}
	if (debug)
	{
	  printf ("Compiled on %s, at %s\n\n",DATE,TIME);

	  printf ("Directory assigned at: %04x\n",dir);
	  printf ("Entries found:         %4d\n", files);
	  printf ("Buffer 1 assigned at:  %04x\n",dbuf1);
	  printf ("Buffer 2 assigned at:  %04x\n",dbuf2);
	  printf ("Max. Records Buffered: %4d\n", sectors);
	  printf ("Stackspace reserved:   %04x\n",stackspace);
	  printf ("Top of Buffers at:     %04x\n\n",p);
	}
}