/**************************************************************** 
 *								* 
 *	ls.c  -  CP/M Directory lising program			* 
 *		 Written in BDS C  				* 
 *		 Written by: Bob Longoria			*  
 *		             9-Jan-82				*
 *								*
 *	The program lists the directory in several different	*
 *	formats depending on switches set in the command	*
 *	line (ala C).	Explanation of the switches follows:	*
 *								*
 *	Size specification:					*
 *		-f	Lists full directory (file size in	*
 *			records, size file takes in disk	*
 *			space, and the files attributes		*
 *		-b	Lists brief directory (file size in	*
 *			records only				*
 *	   default	Lists file names only			*
 *	Attribute specification:				*
 *		-n	Lists files that are SYS only	 	*
 *		-r	Lists files that are R/O only		*
 *		-w	Lists files that are R/W only		*
 *		-a	Lists files regardless of attributes	*
 *	   default	Lists files that are DIR only		*
 *			(corresponds to CP/M dir)		*
 *	Sort specification:					*
 *		-s	Sorts listed files alphabettically	*
 *	   default	Does not sort files			*
 *	Case specification:					*
 *		-u	Lists information in upper case		*
 *	   default	Lists information in lower case		*
 *								*
 *	For the size or attributes specifications - if two	*
 *	of any switches in either of these groups are set -	*
 *	a conflict arises and a warning is issued and the   	*
 *	default setting for the group is set.			*
 *	e.g. ls *.com -fb	This command asks for a full	*
 *	and a brief listing at the same time.  Here warning	*
 *	is issued and default set (brief, brief listing)	*
 *	Switches may be set in any order and can be con-	*
 *	catenated or separated.					*
 *	e.g. ls *.com -fasl does the same as			*
 *	ls *.com -a -s -fl					*
 *								*
 ****************************************************************/
 
#include "bdscio.h"	/* Standard header file */
#define DMABUF 0x0080	/* Default DMA buffer address */
#define MASK   0x80	/* Attribute bit mask */
#define SSIZE  16	/* No of significant fcb bytes */
#define FCBADR 0x005c	/* Default fcb address */
#define FCBS   128	/* Define max number of directory entries */
int usr;		/* Current user number */
int dsk;		/* Currently selected disk */
int blm;

main(argc,argv)
int argc;		/* argument count */
char **argv;		/* argument vector */
{
  char *fcb_ptr[FCBS];
  int nfcbs, count, tot;
  int size_sw, attr_sw;
  int sort_sw, case_sw;
  int blm;

  _allocp = NULL;
  size_sw = attr_sw = sort_sw = case_sw = 0;
  get_args(&size_sw, &attr_sw, &sort_sw, &case_sw, argc, argv);
  get_params();
  if ((count = save_fcb(fcb_ptr,attr_sw,&tot)) == -1){ 
    printf("Warning: FCB list too large for available memory\n");
    exit();
    }
  else if (count == 0){ /* no match found */
    printf("No match found for %s\n",argv[1]);
    exit();
    }
  else {		/* There may be a match */
    if (sort_sw)
      sort_fcb(fcb_ptr,count,11);
    list_fcbs(fcb_ptr, size_sw, case_sw, count, tot);
    }
}

save_fcb(fcb_ptr, attr, ncnt)
char *fcb_ptr[];
char *ncnt;
int attr;
{
  int nsave,n;
  char *p, *alloc(), *buf_ptr;
  char ro, sys;
  char cusr, fusr;

  cusr = usr;
  *ncnt = nsave = 0;
  if ((n = bdos(17,FCBADR)) == 255)
    return(0);
    do {
      (*ncnt)++;
      buf_ptr = DMABUF+32*n;
      sys = *(buf_ptr+10) & MASK;
      ro  = *(buf_ptr+9) & MASK;
      fusr = *buf_ptr;
      if (((attr == 1 &&  sys) || (attr == 2 && ro) ||
	  (attr == 0 && !sys) || (attr == 3) ||
	  (attr == 4 && !ro)) && ((fusr ^ cusr) == 0)) {
	if ((p = alloc(SSIZE)) == NULL)
	  return(-1);
	copy_fcb(p, buf_ptr);
	fcb_ptr[nsave++] = p;
      } 
    }
    while ((n=bdos(18,FCBADR)) != 255);
  return (nsave);
}

list_fcbs(fcb_ptr, size, ucase, count, tot)
char *fcb_ptr[];
int size, ucase;
int count, tot;
{
  int i;
  char sys, ro;
  char *name;
  unsigned n, s, fsize();
  unsigned tblks, ksize;
  
  tblks = ksize = 0;
  name = "            ";
  printf("Directory for Disk %c:  User %2d:\n", dsk+'A', usr);
  for (i = 0; i < count; i++) {
    n = fsize(fcb_ptr[i]);
    s = (n/blm)*(blm/8)+((n%blm) ? blm/8 : 0);
    tblks += n;
    ksize += s;
    strset(name, fcb_ptr[i], ucase);
    switch (size) {
      case 0:
        printf("%s%s", name, (i%5==4 || i==count-1) ? "\n" : " | ");
        break;
      case 1:
	printf("%s%5u", name, n);
	printf("%s", (i%4==3 || i==count-1) ? "\n" : " | ");
	break;
      case 2:
	printf("%s%6u%4dK", name, n, s);
	sys = *(fcb_ptr[i]+10) & MASK;
	ro = *(fcb_ptr[i]+9) & MASK;
	if (ucase)
	printf("%s%s", (sys) ? "  SYS" : "  DIR", (ro) ? "  R/O" : "  R/W");
	else
	printf("%s%s", (sys) ? "  sys" : "  dir", (ro) ? "  r/o" : "  r/w");
	printf("%s", (i%2==1 || i==count-1) ? "\n" : "           ");
	break;
      }
  }
  printf("\nListed %d/%d files",count,tot);
  printf("   %u/%u Blocks used",tblks, ksize*8);
  printf("   %uK Disk space used\n",ksize);
}

copy_fcb(p, s)		/* Copy s to p */
char *p, *s;
{
  int i;

  for (i=0; i < SSIZE; i++)
    *(p+i) = *(s+i);
}

strset(s, t, c)		/* Copy t to s */
char *s, *t;
int c;
{
  int i;

  for (i = 0; i < 12; i++)
    if (i < 8)
      *(s+i) = (c) ? *(t+i+1) : tolower(*(t+i+1) & ~MASK);
    else if (i == 8)
      ;
    else
      *(s+i) = (c) ? *(t+i) : tolower(*(t+i) & ~MASK);
}

get_args (psize, pattr, psort, pcase, argc, argv)
char *psize, *pattr, *psort, *pcase;
int argc;
char *argv[];
{
  char *sptr;

  while (--argc > 0)
    if ((*++argv)[0] == '-')
      for (sptr = argv[0]+1; *sptr != '\0'; sptr++)
        switch (*sptr) {
        case 'F':
          if (*psize == 0)
            *psize = 2;
          else {
 	    printf("Warning: Size switch conflict - Default set\n");
	    *psize = 0;
	    }
	  break;
        case 'B':
	  if (*psize == 0)
	    *psize = 1;
	  else {
	    printf("Warning: Size switch conflict - Default set\n");
	    *psize = 0;
	    }
	  break;
        case 'A':
	  if (*pattr == 0)
	    *pattr = 3;
	  else {
	    printf("Warning: Attr switch conflict - Default set\n");
	    *pattr = 0;
	    }
	  break;
        case 'N':
	  if (*pattr == 0)
	    *pattr = 1;
	  else {
	    printf("Warning: Attr switch conflict - Default set\n");
	    *pattr = 0;
	    }
	  break;
        case 'R':
	  if (*pattr == 0)
	    *pattr = 2;
	  else {
	    printf("Warning: Attr switch conflict - Default set\n");
	    *pattr = 0;
	    }
	  break;
	case 'W':
	  if (*pattr == 0)
	    *pattr = 4;
	  else {
	    printf("Warning: Attr switch conflict - Default set\n");
	    *pattr = 0;
	    }
	  break;
        case 'S':
	  *psort = 1;
	  break;
	case 'U':
	  *pcase = 1;
	  break;
        default:
	  printf("Warning: Illegal switch (%c) - Ignored\n",*sptr);
        }
}

sort_fcb(v, n, num)
char *v[];
int n, num;
{
  int gap, i, j;
  char *temp;

  for (gap = n/2; gap > 0; gap /= 2)
    for (i = gap; i < n; i++)
      for (j = i-gap; j >=0; j -= gap) {
	if (sstrcmp(v[j], v[j+gap], num) <= 0)
	  break;
	temp = v[j];
	v[j] = v[j+gap];
	v[j+gap] = temp;
        }
}

sstrcmp(s, t, num)
char *s, *t;
int num;
{
  int i;

  i = 1;
  while (*(s+i) == *(t+i))
    if (++i > num)
      return(0);
  return (*(s+i) - *(t+i));
}

unsigned fsize(ptr)
char *ptr;
{
  char *p;
  int ex;
  unsigned n;
  unsigned *tmptr;

  ex = *(ptr+12);
  n = *(ptr+15);
  if (ex != 0 && n != 128)
    n = ex*128+n;
  else
    if (n == 128) {
    if ((p = alloc(SSIZE+20)) == NULL)
      return(0);
    copy_fcb(p, ptr);
    bdos(35,p);
    tmptr = p+33;
    n = *tmptr;
    }
  return(n);
}

get_params()
{
  char *dpb_ptr;
  char *buf_ptr;

  buf_ptr = 0x005c;
  dsk = (*buf_ptr & 0x0f)-1;
  if (dsk < 0)
    dsk = bdos(25,0);
  bdos(14,dsk);
  dpb_ptr = bdos(31,dsk);
  blm = *(dpb_ptr+3)+1;
  usr = bdos(32,0x00ff);
}
