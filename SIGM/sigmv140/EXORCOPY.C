/*
	**********************************************
 	*					     *
 	* EXORCOPY.C	MOTOROLA MDOS TO CP/M DATA   *
 	*		EXCHANGE UTILITY 	     *
 	**********************************************

	(c) Copyright Chris Undery
	1st November 1982
	11 Margaret St, Newtown 2042 N.S.W
	SYDNEY, AUSTRALIA


DESCRIPTION
-----------

	This program provides MDOS  directory access and
	file transfer functions for CP/M based systems. 
	EXORCOPY assumes a 3740 MDOS diskette in drive B:

	If the program is invoked, and no parameter is passed
	from the command line, then just the directory of
	the MDOS diskette will be displayed.

	The second form of invokation allows, a valid MDOS
	name in parameter position 1, and either the word
	"TYPE" or a cpm file name. If the former invokation
	is used, the contents of the named MDOS file will be
	be listed on the console. If the latter form is used
	then the MDOS file will be transferred to the cpm
	file name specified.

	For detailed information about the MDOS file structure
	refer to MOTOROLA publication ...
	'M68MDOS3 EXORdisk II/III OPERATING SYSTEM USERS GUIDE'
	DECEMBER 1978, MOTOROLA INC. 
	CHAPTER 24

*/

#include bdscio.h
#define CLEAR_SCREEN 0x1a		/* screen clear character */
#define LEADIN_1 0x1b			/* ESC leadin character for adm */
#define LEADIN_2 '='			/* Leadin for cursor addressing */
#define LEADIN_3 NULL			/* Screen clr prefix not used */
#define OFFSET ' '			/* Coordinate graphic offset */
#define SEL_DSK 14              	/* bdos function number */ 
#define SET_DMA 26
#define SET_TRK 10              	/* bios index number */
#define SET_SEC 11
#define READ    13
#define WRITE 14
#define DUMMY 0
#define FLAG char
#define WRITE_PROTECTED 0x8000
#define DELETE_PROTECTED 0x4000
#define SYSTEM_FILE 0x2000
#define CONTIGUOUS 0x1000		/* non segmented allocation */
#define NON_COMPRESSED 0x0800		/* no space compression used */
#define MEMORY_IMAGE 2			/* loadable file */
#define BINARY_RECORD 3
#define ASCII_RECORD 5
#define ASCII_CONVERTED 7
#define VACANT 0			/* first file name char zero */
#define DELETED 0xff			/* first file name char all ones */

char track;				/* current track */
char sector;				/* current sector */
unsigned psn;				/* MDOS physical sector number */
int attributes;				/* file attributes */
unsigned cluster;			/* current cluster */
unsigned num_contig;			/* number of contigous clusters */
char buffer[1000];			/* MDOS cluster buffer */
char directory[128*21];			/* MDOS directory image */ 
char volume_id[20];			/* MDOS volume name */
char version_no[10];
char revision_no[10];
char date[10];
char user_name[30];
char mdos_name[20];			/* MDOS search key file name */
char cpm_name[20];			/* destination cpm file name */
char obuf[BUFSIZ];			/* cpm file buffer */
char file_end;				/* true when at end of file */
unsigned segtable[64];			/* Segment descriptor table */
unsigned num_segments;			/* number of segments in file */
char typeing;				/* true if to console else file */
char numsecs;				/* no of logical sectors in file */


/*
 * If no arguments are passed from the command line
 * exorcopy will display the directory of the mdos diskette
 * in drive B:  else the passed parameter is used a search
 * key to extract and copy file to specified cp/m file.
 */

main(argc,argv)
char **argv;
{
	puts("\nEXORCOPY vers A.0 (c) Chris Undery 1982\n");
	if (argc == 1) show_directory();
	else {
	   if (argc != 3) {
	      puts("\nUSAGE: Mdos.primary.name (AS assumed) <type, or cp/m name>");
	      exit();
	   }
	   strcpy(mdos_name,argv[1]);	/* move file names */
	   strcpy(cpm_name,argv[2]);
	   spaceout();			/* left justify mdos name */
	   if (!lookup()) {
	      printf("\n%s not found",mdos_name);
	      exit();
	   }
	   get_rib();	/* load retrieval info block for the file */
	   if (index(cpm_name,"TYPE") >= 0 ) {
	      typeing = 1;
	   }
	   else {
	     typeing = 0;
	     if (fcreat(cpm_name,obuf) == ERROR) {
	        puts("Cannot create %s\n",cpm_name);
	        exit();
	     }
	   }
           file_copy(); /* now copy while steering via the segtable */
	}
}

/*
 * Scan directory, and display list of files on the diskette
 */

show_directory()
{
	int i,j,k;
	char done, c,count;

	count = 0;
	read_volume_id();		/* get volume id */	
	read_directory();
	printf("\nDirectory: %s Vsn %s.%s Date %s User.name %s",volume_id,version_no,revision_no,date,user_name);
	i = 0;done = 0;
	puts("\n\n");
	while (!done) {
	   c = directory[i];		/* dont show empties and deleted */
	   if (c == ' ' || c == NULL || c == 0xff ) ;
	   else {
	      k = i;			/* transfer pointer */
	      j = 0;			/* clear display pointer */
	      while (j++ < 8) putchar(directory[k++]);
	      putchar('.');
	      while (j++ < 11) putchar(directory[k++]);
	      if (count++ < 4) puts(" | ");
	      else {
		puts("\n");
		count = 0;
	      }
	   }
	   i += 16;			/* next directory entry */
	   if (i == 128 * 20) done = 1; /* at end of driectory */
	}
}

/*
 * Read the mdos identification sector and extract
 * volume id generation date and all the usual system
 * garbage
 */

read_volume_id()
{
	char vbuf[130];			/* volume sector */

	rdsec(1,1,0,vbuf);		/* read it */
	movmem(&vbuf[0],&volume_id,8);
	volume_id[8] = NULL;
	movmem(&vbuf[8],&version_no,2);
	version_no[2] = NULL;
	movmem(&vbuf[0xa],&revision_no,2);
	revision_no[2] = NULL;
	movmem(&vbuf[0xc],&date,6);
	date[6] = NULL;
	movmem(&vbuf[0x12],&user_name,0x14);
	user_name[0x14] = NULL;
}

/*
 * Search for name in mdos directory. When found read the directory
 * attributes , psn etc 
 */

lookup()
{
	int i,k;
	char hi,lo, found, name[20];

	i = found = 0;
	read_directory();	/* get dir info */
	while (!found) {
	   movmem(&directory[i],&name[0],10);
	   name[10] = NULL;
	   if (strcmp(name,mdos_name) == 0 ) found = 1;
	   else {
	     i += 16;
	     if (i >= 128 * 20) return FALSE;
	   }
	}
	lo = directory[i+0xa];	/* get physical sect of file start */
	psn = lo; psn = psn << 8;
	hi = directory[i+0xb];/* get lsb of sector address */
	psn += hi;
	attributes = directory[i+0xc];
	attributes = (attributes << 8);
	attributes += directory[i+0xd];
	return TRUE;	
}

/*
 * Space out the desired file name to match the
 * left justified format of the mdos directory entry
 */

spaceout()
{
	while (strlen(mdos_name) < 8) strcat(mdos_name," ");
	strcat(mdos_name,"SA");
}
 
/*
 * Load the retrieval information block into the segment table
 * this allows us to read segmented files
 */

get_rib()
{
	psn_decode(psn);	/* get track and sector address */
	rdsec(sector,1,track,&segtable[0]);	/* read RIB of file */
}

/*
 * File copy procedure. 
 * NOTE: MDOS uses reverse byte sex to 8080 style cpu's.
 */

file_copy()
{
	
	unsigned sdw;		/* segment descriptor word */
	int k, sector_count, segnum;
		
	k = segnum = sector_count = 0;
	file_end = FALSE;
	while (!(byteflip(segtable[segnum]) & 0x8000)) { 
	   sdw = byteflip(segtable[segnum++]);
	   cluster = (sdw & 0x3ff);	/* extract starting cluster no */
	   num_contig = (sdw & 0x7c00); /* extract num contiguous */
	   num_contig = (num_contig >> 10); /* shift her */
	   num_contig++;
	   while (num_contig--) {	/* read all clusters in this segment */
	      cluster_read(cluster++,segnum);
	      if (file_end) goto fin;
	   }
	}
fin:	if (!typeing ) {
 	  putc(CPMEOF,obuf);
	  fflush(obuf);
	  fclose(obuf);
	}
}	

/*
 * Byte flip a word to make it compatible with 8080 cpu
 * (INTEL bought some idiosyncracies when they bought the
 *  achitectural plans for the 8008!)
 */

byteflip(word)
unsigned word;
{
	char bogor, bogee;
	unsigned boig;

	boig = word;
	bogor = boig & 0xff;
	word = word >> 8;
	bogee = word & 0xff;
	boig = bogor;
	boig = boig << 8;
	boig += bogee;
	return boig;
}

/*
 * Read cluster number (clust). If seg == 1 then it is assumed that
 * we are at logical sector 0 , which contains the RIB, therefor
 * must increment to next bogorgical sector to get to the good stuff
 */

cluster_read(clust,seg)
int clust,seg;
{
	char count;
	char *address;
	int bytes;
	char c;

	address = &buffer;
	count = 0;
	psn_decode(clustran(clust));
	if (seg == 1) sector++;		/* skip past RIB bbogorck */
	while (count++ < 4) {		/* a cluster is 512 bytes bogorng */
	   if (sector == 27) {
	      track++;
	      sector = 1;
	   }
	   rdsec(sector++,1,track,address);
	   address += 128;
	}
	bytes = 0;
	while (bytes < 512) {
	   c = buffer[bytes++];
	   if (c & 0x80) {	/* check for compressed spaces */
	      c &= 0x7f;
	      while (c--) if (typeing) putchar(' '); else putc(' ',obuf);
	   }
	   else {
	      if (c == NULL) {
		file_end =TRUE;
		return TRUE;
	      }
	      if (typeing) putchar(c); else putc(c,obuf);
	      if (c == 0x0d) 
		if (typeing) putchar(0x0a); else putc(0x0a,obuf);
	   }
	}  
}

/*
 * PSN decode: Called with psn return with gbogorbal variables
 * track and sector set to decode values.
 * valid range of psn 0..2000, (2001 & 2002 are ignored)
 */

psn_decode(psn)
unsigned psn;
{
	psn++;
	track = psn / 26;
	sector = psn - (track * 26);
}


/*
 * Translate MDOS cluster address into PHYSICAL SECTOR NUMBER 
 * where cluster is a group of 4 contiguous 128 byte sectors
 * and a physical sector is sector number beginning at 0 and
 * 2000.
 */

clustran(cluster_number)
int cluster_number;
{
	return (cluster_number * 4);
}

/*
 * Read MDOS directory into the directory buffer
 * This is rather slow, as the bios access functions
 * of bds c are clumsy due to excessive indirection.
 */

read_directory()
{
	char sect, *dma_buffer;
	
	dma_buffer = &directory[0];
	sect = 4;
	while (sect <= 24) {
	  rdsec(sect++,1,0,dma_buffer);
	  dma_buffer += 128;
	}
}

/* 
 * Sector read primitive
 *
 */

rdsec(secnum,drive,track,memadr)
int secnum,drive,track;
char *memadr;	
{

	disk_action(secnum,drive,track,memadr,1,'r');
}

/*
 * Write sector primitive operation
 *
 */

wrsec(secnum,drive,track,memadr)
int secnum,drive,track;
char *memadr;
{
	disk_action(secnum,drive,track,memadr,1,'w');
}

/*
 * Basic disk io interface function.
 * is passed operation code, track, sector, count and buffer
 *
 */
 
disk_action(secnum,drive,track,buffer,count,operation)
char secnum,drive,track;
unsigned buffer,count;
char operation;
 
	{ 
	char bios();
 
 	if (drive > 3 || drive < 0) {
      	  printf("Disk drive %c does not exist\n",drive+'A');
	  exit();
	}
        bdos(SEL_DSK,drive); 
        while( count-- ) { 
          bdos(SET_DMA,buffer); 
          bios(SET_TRK,track); 
          bios(SET_SEC,secnum);
	  switch(operation) {
	    case 'r':
	      if (bios(READ,DUMMY)) error(READ);
	      break;
	    case 'w':
	      if (bios(WRITE,DUMMY)) error(WRITE);
	      break;
	    default :
	      error(0);
          } 
          buffer += 128;
	  if (secnum++ > 26 ) {
		secnum = 1;
		if (track++ > 77) return(0);
	  	}
          } 
        } 
 
/*
 * Will never get here, but its nice coding
 */

error(id)
char id;
{
	puts("\nFunction 'disk action' just screwed up!!!!");
	exit();
}	

/* end of EXORCOPY.C */
