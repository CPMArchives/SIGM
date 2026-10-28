/********************************************************
 *                                                      *
 *              BDS-C Supplementary Library             *
 *                      release 2                       *
 *                                                      *
 *              Steve de Plater, Nov. 1980              *
 *                    66 Priam St.                      *
 *                    Chester Hill,                     *
 *                    NSW, 2162                         *
 *                    Australia                         *
 *              Phone: (02) 644 4009                    *
 *                                                      *
 *              This file: GC0.C   release 1            *
 *                                                      *
 ********************************************************/
 
/*=======================================================
 
        This routine creates a standard inverse video
        character set for the Exidy Sorcerer.
        The inverse character generator resides in both
        the standard and user graphics areas (ie from
        0xfc00 through to 0xffff).
*/
 
invid()
{
        int *p1,*p2;
 
        for (p1=0xf800,p2=0xfc00;p2;*p2++=~(*p1++));
}
 
/*=======================================================*/
 
pgraf(filename)
char *filename;
 
/*      This is "pgraf" which:
          (1)   creates a file called "filename",
          (2)   writes the graphics areas of the Sorcerer
                (ie char generators for ASCII characters
                 0x80 to 0xFF) to the file just created.
        The return codes are:
          (1)   0 if successful, or
          (2)   -1 otherwise.
        This allows statements of the form:
        "if pgraf("mygrafix.txt") goodsave();"
*/
{
        int fd;
        char *buf;
 
        return swapout(filename,0xfc00,0xffff);
}
 
/*======================================================*/
 
ggraf(filename)
char *filename;
 
/*      This is "ggraf" which:
          (1)   reads the file "filename" into the graphics
                area of the Sorcerer.
                No check is made on file length (users beware!)
          (2)   is designed to undo what "pgraf" does.
        The return codes are:
          (1)   0 if successful, or
          (2)   -1 otherwise.
        This allows statements of the form:
        "if ggraf("mygrafix.txt") goodload();"
*/
{
        return swapin(filename,0xfc00);
}
 
/*=======================================================
 
        The Standard Exidy Monitor caller!
        Calling sequence is of the form:
          x=monitor("SA IDIOT 100 2BFF 2");
        ie it is passed a pointer to a Standard Monitor
        command string. The required CR is appended
        automatically by this routine.
        The value returned is:
                0 for an error in the command string,
                1 for a successful operation, or
                NO RETURN AT ALL for errors caught by
                 the monitor itself (sorry about that!)
*/
 
monitor(s)
char *s;
 
{       char    *inbuf;
 
        inbuf = mwa();
        strcpy(inbuf,s);
        while (*inbuf=toupper(*inbuf)) inbuf++;
        *inbuf = '\r';
        return exycall();
}
 
/*=======================================================
 
        This routine returns a character from the
        console device WITHOUT echoing it to the screen
*/
 
char inchar()
 
{       return bios(3,0);       }
 
/*=======================================================
 
        This routine returns a STRING from the console
        device WITHOUT echoing it to the screen.
        The string is terminated with a CR (not included
        in the string).
        The return value is the length of the string.
        's' is a pointer to the string space (which must be
        large enough to hold it!)
*/
 
char instr(s)
char *s;
 
{       char c, *temp;
 
        temp=s;
        while ((c=bios(3,0)) != '\r')
           *s++=c;
        *s='\0';
        return strlen(temp);
}
 
/*=======================================================
 
        Reads Standard Exidy tape file of name 'name'
        from tape 'unit' into address 'addr'.
        Returns 0 for bad, 1 for ok.
*/
 
rtape(name,unit,addr)
char *name;
int   unit, addr;
 
{       char monbuf[50];
 
        sprintf(monbuf,"LO %s %x %x",name,unit,addr);
        return monitor(monbuf);
}
 
/*=======================================================
 
        Writes standard Exidy tape file of 'name' from
        address 'addr1' to address 'addr2' to tape 'unit'.
        Returns 0 for bad, 1 for ok.
*/
 
wtape(name,addr1,addr2,unit)
char *name;
int   addr1, addr2, unit;
 
{       char monbuf[50];
 
        sprintf(monbuf,"SA %s %x %x %x",name,addr1,addr2,unit);
        return monitor(monbuf);
}
 
/*=======================================================
 
        Reads standard Exidy tape as in 'rtape' but then
        chains to the execution address on the tape header.
        NO return values (of course!)
*/
 
rtapeg(name,unit,addr)
char *name;
int   unit, addr;
 
{       char monbuf[50];
 
        sprintf(monbuf,"LOG %s %x %x",name,unit,addr);
        monitor(monbuf);
}
 
/*=======================================================
 
        Undoes what swapin does:
        ie swaps out to a filename pointed to by name
        the contents of memory between saddr and eaddr
        (inclusive).
        Actually the end addr is calculated to the next
        128 bytes ABOVE if the amount of data to be transferred
        is not actually a multiple of 128.
        Previous contents are discarded.
        Returns either
                0 if successful, or
                -1 otherwise.
*/
 
swapout(name,saddr,eaddr)
char *name;
int   saddr, eaddr;
 
{       int     nbl;
        int     fd;
 
        if ((fd=creat(name)) == -1) return fd;
        nbl=((eaddr-saddr)/128)+1;
        if (write(fd,saddr,nbl) != nbl) {
           unlink(name);
           return -1;
        }
        close(fd);
        return 0;
}
 
/*=======================================================
 
        Fills the plot area from the string pointed to
        by s. The string is reused until the plot area
        is full.
        The address of the (0,0) position of the screen
        is returned.
*/
 
fillplot(s)
char *s;
 
{
        int *pbase,*psize;
 
        pbase=getplot();
        psize=pbase+3;        /* pointers are NOT integers! */ 
        fill(*pbase,*psize,s,1);
        return *pbase;        /* return the screen RAM addr */
}
 
/*=======================================================
 
        If (mode==0)
          fills the plot area from the beginning of the
          current line to the cursor address.
        else
          fills the plot area from the cursor address to
          the end of the current line.
 
        The string pointed to by s is used as many times
        as needed to fill the area.
 
        Returns the cursor address.
*/
 
linefill(mode,s)
char *s;
int mode;
 
{       int csr,k,l,*pbase,*ysize,*xsize;
 
        csr=cursor(-1);
        pbase=getplot();
        ysize=pbase+1;
        xsize=ysize+1;
        l=*pbase;
        for (k=0;k<*xsize;k++)
        {
          if (l>csr) break;
          l+=*ysize;
        }
 
 
        if (mode==0)
        {
          k=l-*ysize;
          fill(k,csr,s,0);
        }
        else
        {
          k=l-1;
          fill(csr,k,s,0);
        }
        return csr;     /* return the cursor position */
}
 
/*=======================================================
 
        if (mode==0)
          fills from the beginning of the screen to
          the cursor.
        else
          fills from the cursor to the end of the screen.
 
        The string pointed to by s is used as many times
        as required to fill.
 
        Returns the cursor address.
*/
 
fillcur(mode,s)
char *s;
int mode;
 
{
        int csr,*pbase,*psize,pend;
        csr=cursor(-1);
        pbase=getplot();
        psize=pbase+3;
        pend =*pbase+*psize-1;
        if (mode==0)
           fill(*pbase,csr,s,0);
        else
           fill(csr,pend,s,0);
        return csr;     /* return the cursor position */
}
 
/*=======================================================
 
        Returns:
          1 if bit 'bit' is set in the word pointed to
            by 'word', or
          0 otherwise.
 
        Bits are numbered 0 to 15, right to left.
*/
 
tstbit(word,bit)
unsigned *word,bit;
 
{
        if ((1<<bit)&*word)
          return 1;
        else
          return 0;
}
 
/*=======================================================
 
        Sets the bit 'bit' in the word pointed to by
        'word'.
        No return value.
 
        Bits are numbered 0 to 15, right to left.
*/
 
setbit(word,bit)
unsigned *word,bit;
 
{
        *word=*word|(1<<bit);
}
 
/*=======================================================
 
        Resets (clears) the bit 'bit' in the word pointed
        to by 'word'.
        No return value.
 
        Bits are numbered 0 to 15, right to left.
*/
 
clrbit(word,bit)
unsigned *word,bit;
 
{
        *word=*word&(~(1<<bit));
}
 
/*=======================================================
 
        Swaps the contents of the words pointed to by
        p1 and p2.
        ie: if w1=1234 and w2=5678 and p1 points to w1
        and p2 points to w2, then after swap(p1,p2)
        w1 will contain 5678 and w2 will contain 1234.
 
        (See K & R, p117)
        No return value.
*/
 
swap(p1,p2)
int *p1,*p2;
 
{       int *temp;
 
        *temp=*p1;
        *p1=*p2;
        *p2=*temp;
}
 
.
*/
 
swap(p1,p2)
int *p1,*p2;
 
{       int *temp;
 
        *te