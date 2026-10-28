  /***********************************************************\
  *                                                           *
  *   VFILE consists of 5 functions which simulate a "BASIC   *
  *   RANDOM FILE" structure using fixed length records of    *
  *   varying pre-specified size. A record may be up to 255   *
  *   chars long. It is the programmer's responsibility to    *
  *   keep track of the contents of his record, and VFILE's   *
  *   responsibility to write and read the record to and from *
  *   the correct position in file.  Record numbers are       *
  *   maximum 32767. VFILE will give ERROR if reading past    *
  *   end of file or exceeding legal bounds.  It will pad     *
  *   as-yet-unwritten internal records with nulls. An error  *
  *   is returned if there is not enough disk space for       *
  *   either the record or the padding.  There is a sixth     *
  *   function (vset), which is used internally.              *
  *                                                           *
  *   The structure "_vbuf" must be included in the           *
  *   programme, and each file must reserve a VBUFSIZ area    *
  *   for buffering.  This area will vary depending on NSECTS *
  *   in BDSCIO.H   THE VALUE OF NSECTS MUST BE GREATER       *
  *   THAN TWO.  The definitions of _vbuf and VBUFSIZ         *
  *   should eventually find their way into BDSCIO.H          *
  *   I have included them in this source for clarity.        *
  *                                                           *
  *   telend finds the end of any sequential file and returns *
  *   its record number.  Only sequential extents are searched*
  *   (i.e. it may not work on random files)                  *
  *                                                           *
  \************************************************************




	Version 1.0  (c) 1980 	Greg Lister

				Software Source
				P.O. Box 364
				Edgecliff   2027

				Australia


		19th November, 1980			    */




#include "bdscio.h"
#define VBUFSIZ NSECTS * SECSIZ + 14

struct _vbuf
{   int fd;	/* File Descriptor */
    int eof;	/* Actual EOF of file */
    int pos;	/* Current record's position in buffer */
    int len;	/* Record length */
    int sta;	/* Start sector of buffer */
    int cnt;	/* Number of sectors in buffer */
    int wflag;	/* flag set if buffer written to */
    char buffer[NSECTS * SECSIZ];
};


vset(recno,vbuf)
    int recno;
    struct _vbuf *vbuf;
    /************************************************\
    *                                                *
    *   Sets up buffer for random reads and writes.  *
    *   Flushes buffer if necessary and fills buffer *
    *   with required data. Sets pointer to beginning*
    *   of r/w record.  Fills unwritten buffer with  *
    *   nulls.  Returns ERROR if cannot flush or     *
    *   if hard read error.  Returns NULL if         *
    *   required buffer is not yet written. Returns  *
    *   -2 if required sector (128 byte) is not yet  *
    *   written. Else returns valid sectors in buf.  *
    *                                                *
    \************************************************/
{
   int tmp,blkno,bss,blkoff,secno,bufsec,endrec;

   blkno=recno>>7;		/* Block Number */

   bss=blkno*vbuf->len;		/* Block start Sector */

   blkoff=(recno%128)*vbuf->len;	/* Offset into Block */

   secno=bss+(blkoff>>7);	/* Sector # of start of rec */

   endrec=bss+((blkoff+vbuf->len-1)>>7);/* Sec# END of rec */

   bufsec=(secno/(NSECTS-2))*(NSECTS-2); /* Start sec of buf */

   vbuf->pos=vbuf->buffer+((secno-bufsec)<<7)+(blkoff%128);

   if(bufsec!=vbuf->sta)
   {    if(vbuf->wflag)
	{   seek(vbuf->fd,vbuf->sta,0);
           if(write(vbuf->fd,vbuf->buffer,vbuf->cnt)<vbuf->cnt)
		return ERROR;
	    if((tmp=tell(vbuf->fd))>vbuf->eof)
		vbuf->eof=tmp;
	    vbuf->wflag=0;
	}
	if((vbuf->sta=bufsec)>vbuf->eof) return NULL;
	seek(vbuf->fd,bufsec,0);
	if((vbuf->cnt=read(vbuf->fd,vbuf->buffer,NSECTS))<0)
		return ERROR;
	if(vbuf->cnt!=NSECTS)
		fillb(vbuf->buffer+(vbuf->cnt<<7),
		vbuf->buffer+(NSECTS<<7),0,0);
   }

   if(endrec-bufsec>=vbuf->cnt) return -2;
   return vbuf->cnt;
}


vwrite(recno,vbuf,str)
    int recno;
    struct _vbuf *vbuf;
    char *str;

    /********************************************************\
    *                                                        *
    *   Writes data at str to file vbuf at recno.  Pads file *
    *	with NULLS if skipping unwritten sections of file.   *
    *	Returns ERROR if full disk, unopened file etc        *
    *	Returns ERROR if bad record #;  else returns OK      *
    *                                                        *
    \********************************************************/

{   int tmp,tmp1,tmp2;

    if(recno<0) return ERROR;
    if((tmp=vset(recno,vbuf))==-1) return ERROR;
      if(tmp==0)
      { fillb(vbuf->buffer,NSECTS<<7,0,1);
	seek(vbuf->fd,vbuf->eof,0);
	while((vbuf->eof=tell(vbuf->fd))<vbuf->sta)
	if(write(vbuf->fd,vbuf->buffer,1)>1) return ERROR;
      }
      movmem(str,vbuf->pos,vbuf->len);
      tmp2=vbuf->buffer;
      tmp1=(127+vbuf->pos-tmp2+vbuf->len)>>7;
      if(tmp1>vbuf->cnt)
	vbuf->cnt=tmp1;
      vbuf->wflag=1;
    return OK;
}


vread(recno,vbuf,str)
    int recno;
    struct _vbuf *vbuf;
    char str[];

    /************************************************\
    *                                                *
    *   Reads record 'recno' from file to 'str'.     *
    *   Returns ERROR if hard error (unopened        *
    *   file etc) or if attempt is made to read      *
    *   past current end of file.  Returns no of     *
    *   secs read in.   ERROR if bad recno.          *
    *                                                *
    \************************************************/

{   int tmp;
    if(recno<0) return ERROR;
    tmp=vbuf->sta;
    if(vset(recno,vbuf)<1)
    {
	vbuf->sta=tmp;
	return ERROR;
    }
    movmem(vbuf->pos,str,vbuf->len);
    return vbuf->cnt;
}


vclose(vbuf)
   struct _vbuf *vbuf;

    /************************************************\
    *                                                *
    *   Closes file using vbuf.  Returns OK if       *
    *   closed successfully.  ERROR if error.        *
    *                                                *
    \************************************************/

{   if(vbuf->wflag)
    {	seek(vbuf->fd,vbuf->sta,0);
	if(write(vbuf->fd,vbuf->buffer,vbuf->cnt)<0)
	    return ERROR;
    }
    return close(vbuf->fd);
}



vopen(filename,vbuf,reclen)
    int reclen;
    char filename[];
    struct _vbuf *vbuf;

    /************************************************\
    *                                                *
    *   Opens filename for v-format buffered io      *
    *   Reclen is the specified record length        *
    *   (may be up to 255 chars).  Vbuf is a         *
    *   VBUFSIZ buffer ((128 * NSECTS)+14)           *
    *   **NOTE** NSECTS must be 3 or more for this   *
    *   file structure to work.                      *
    *   Returns ERROR if reclen is out of range      *
    *   or if open error occurs (ie file doesn't     *
    *   exist - use vcreat)                          *
    *                                                *
    \************************************************/

{   if((vbuf->len=reclen)>255)return ERROR;
    if(reclen<0) return ERROR;
    if((vbuf->fd=open(filename,2))<0) return ERROR;
    vbuf->sta=vbuf->cnt=-1;
    vbuf->wflag=0;
    vbuf->pos=vbuf->buffer;
    vbuf->eof=telend(filename);
    return vbuf->fd;
}


vcreat(filename,vbuf,reclen)
    int reclen;
    char filename[];
    struct _vbuf *vbuf;
    /************************************************\
    *                                                *
    *   Creates a file as vopen (see above)          *
    *                                                *
    \************************************************/
{   fabort(creat(filename));
    return vopen(filename,vbuf,reclen);
}
















telend(filename)
char *filename;
    /************************************************\
    *                                                *
    *   returns number of last 128-byte record in    *
    *   file 'filename'.  Returns NULL if file       *
    *   is either nonexistent or empty.              *
    *                                                *
    \************************************************/
{
    int recnt;
    char fcb[38],ex;
    setfcb(fcb,filename);
    ex=recnt=0;
    while(1)
    {	fcb[12]=ex++;
	if((bdos(15,fcb))==255) break;
	recnt+=fcb[15];
    }
    return recnt;
}

