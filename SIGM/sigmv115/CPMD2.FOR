C************************************************
C*                                              *
C*  CPMD2--CP/M TO DEC DISK TRANSLATER          *
C*                                              *
C*  NOTE:  MUST BE COMPILED '/NOSWAP'           *
C*                                              *
C*  THIS IS A SHORT VERSION OF CPMDEC, FOR USE  *
C*    WHERE THE PROGRAM MUST BE HAND ENTERED.   *
C*    TYPE THIS FILE INTO YOUR DEC SYSTEM,      *
C*    OMITTING THE COMMENTS.  THEN COMPILE IT,  *
C*    THE RESULT WILL BE A SHORT VERSION WHICH  *
C*    WILL ONLY READ CPMDEC FROM THE DISK.      *
C*    YOU MAY THEN COMPILE CPMDEC FOR LATER USE.*
C*                                              *
C*  RUSS BAKKE                02-18-83          *
C*                                              *
C************************************************
C
	PROGRAM CPMD2
C
	BYTE DIR(32,64),CNAME(12),DNAME(12)
	COMMON DIR
	DATA DNAME/ 'D','K','0','C','P','M','D','E','C',
     +	'F','O','R'/
	DATA CNAME/ 'C','P','M','D','E','C',' ',' ','F','O','R',0/
C
	TYPE 100
  100	FORMAT (1X,'CP/M TRANSLATER BOOTSTRAP, V1.0'//
     +	1X,'INSERT CP/M DISK IN DY1: AND PRESS RETURN'/)
	ACCEPT 104,IWANT
  104	FORMAT (1A1)
C
C OPEN CP/M DISK AS NON-FILE STRUCTURED DEVICE:
	CALL DSKOPN(ICHAN)
	CALL GETDIR(ICHAN)
C
C  LOOKUP CNAME IN DISK DIR
	CALL FIND(CNAME,0,IENTRY)
	IF (IENTRY .NE. -1) GOTO 32	!OK
   31	TYPE *,'FILE NOT FOUND'
	GOTO 90
C
C  GET DEC NAME & OPEN
   32	CALL DECOPN(DNAME,IDCHAN)
C  READ FILE AND WRITE TO DEC
	CALL CPYFIL(IENTRY,CNAME,ICHAN,IDCHAN)
C
C  CLOSE
   90	CALL ICLOSE (ICHAN)
	CALL IFREEC (ICHAN)
	CALL EXIT
	END
C
	SUBROUTINE DSKOPN (IDCH)
C****************************************************
C*                                                  *
C*  OPEN FLOPPY DISK DRIVE 1 AS NON-FILE            *
C*  STRUCTURED DEVICE; RETURN CHANNEL NO. IN IDCH.  *
C*                                                  *
C*  RUSS BAKKE                      02-10-83        *
C*                                                  *
C****************************************************
C
	REAL*4 DISK1
	DATA DISK1 /3RDY1   /
C
C  FETCH HANDLER, OPEN A CHANNEL, LOOKUP DEVICE
	IF (IFETCH(DISK1) .NE. 0) STOP 'IFETCH ERROR
     +	IN DSKOPN'
	IDCH=IGETC()
	IF(IDCH.LT.0) STOP' NO CHANNEL AVAILABLE'
C
	IRET = LOOKUP(IDCH,DISK1)
	IF (IRET .GE. 0) GOTO 10
C
C  LOOKUP FAILURE
	TYPE *,'LOOKUP FAILURE TYPE ',IRET
	STOP
C
   10	RETURN
	END
C
	SUBROUTINE GETDIR(ICHAN)
C****************************************************
C*                                                  *
C*  READ DIRECTORY OF CP/M DISK.                    *
C*                                                  *
C*  THE CP/M DISK USES TRACKS 0 AND 1 FOR SYSTEM    *
C*  TRACKS; WE MAY IGNORE THEM.  THE DIRECTORY IS   *
C*  2K OR 16 SECTORS, STARTING ON TRACK 2.          *
C*                                                  *
C*  RUSS BAKKE                  05-06-82            *
C*                                                  *
C****************************************************
C
	BYTE DIR(32,64)
	COMMON DIR
C
	DO 80 INDEX=1,16
	ISECTR=INDEX
	CALL DOSEC(2,ISECTR,DIR(1,4*(ISECTR-1)+1),ICHAN)
   80	C O N T I N U E
	RETURN
	END
C
	SUBROUTINE DOSEC(ITRK,ISEC,BUFF,ICHAN)
C****************************************************
C*                                                  *
C*  READ LOGICAL SECTOR 'ISEC', TRACK 'ITRK', TO    *
C*   'BUFF' (128 BYTES), FROM CHANNEL 'ICHAN'.      *
C*                                                  *
C*  RUSS BAKKE                   02-18-83           *
C*                                                  *
C****************************************************
C
	BYTE BUFF(128),MYBUFF(130)
	INTEGER ITABLE(26)
	DATA ITABLE /1,7,13,19,25,5,11,17,23,3,9,15,21,2,8,
     +	14,20,26,6,12,18,24,4,10,16,22/
C  ITABLE IS THE CP/M SECTOR INTERLEAVE TABLE (26 SECTORS PER TRACK)
C  PHYSICAL SECTOR # [1..26] = ITABLE(LOGICAL SECTOR # [1..26])
C
	IRET=ISPFNW("377,ICHAN,ITRK,MYBUFF,ITABLE(ISEC))
C
C  THE ISPFNW CALL IS AS FOLLOWS:
C  IRET=ISPFNW(FUNC,ICHAN,ITRK,BUFF,SECTOR)
C    FUNC="377 FOR READ, "376 FOR WRITE
C    ICHAN=CHANNEL #, FROM LOOKUP
C    ITRK=ABSOLUTE PHYSICAL TRACK #, 0..76
C    SECTOR=ABSOLUTE PHYSICAL SECTOR #, 1..26
C    BUFF=128 BYTE BUFFER
C    IRET RETURNS:
C	0 NORMAL
C	1  EOF
C	2  HARDWARE ERROR
C	3  CHANNEL NOT OPEN
C
	IF (IRET .EQ. 0) GOTO 40
   30	TYPE 100,RW,ITRK,ISEC
  100	FORMAT (1X,A,2X,'TRACK: ',I3,'   LOG. SECTOR: ',I3)
	IF (IRET .EQ. 1) STOP 'CHANNEL EOF IN DOSEC'
	IF (IRET .EQ. 2) STOP 'HARDWARE ERROR IN DOSEC'
	IF (IRET .EQ. 3) STOP 'CHANNEL NOT OPEN IN DOSEC'
	STOP 'ERROR IN DOSEC'
C
C  WE MUST READ INTO 130 BYTE BUFFER, BECAUSE ISPFNW READS
C  LEADING 0 WORD INTO BUFFER.  (THIS IS DOCUMENTED IN THE
C  SOFTWARE SUPPORT MANUAL BUT NOT IN THE PROGRAMMER'S REFERENCE).
   40	DO 45 I=1,128
	BUFF(I) = MYBUFF(I+2)
   45	C O N T I N U E
	RETURN
	END
C
	SUBROUTINE DECOPN(FNAME,IDCHAN)
C**************************************************
C*                                                *
C*  OPEN A DEC FILE FNAME, RETURNING CHANNEL      *
C*  NUMBER IN IDCHAN.                             *
C*                                                *
C*  RUSS BAKKE               02-18-83             *
C*                                                *
C**************************************************
C
	BYTE FNAME(12)
	REAL*8 FSPEC
C
C  GET A CHANNEL
	IDCHAN=IGETC()
	IF(IDCHAN .LT. 0) STOP' NO CHANNEL AVAILABLE'
C
C  CONVERT FNAME TO RADIX 50
	IDUM=IRAD50(12,FNAME,FSPEC)
C
	IRET=IENTER(IDCHAN,FSPEC,-1)
	IF (IRET .GE. 0) GOTO 90
C  IENTER ERRORS ARE:
C  -1: CHANNEL ALREADY OPEN
C  -2: NO SPACE AVAILABLE
C  -3: DEVICE IN USE
C  -4: FILE EXISTS AND IS PROTECTED
C  -5: CASSETTE ONLY
	TYPE *,'IENTER FAILURE TYPE ',IRET
	STOP
C
   90	RETURN
	END
C
	SUBROUTINE FIND(CNAME,EXT,IENTRY)
C****************************************************
C*                                                  *
C*  FIND CP/M FILE NAMED CNAME IN DIRECTORY (IN     *
C*  DIR, PASSED IN COMMON), EXTENT 'EXT'; RETURN    *
C*  DIRECTORY ENTRY NUMBER IN IENTRY.               *
C*                                                  *
C*  RUSS BAKKE                    05-11-82          *
C*                                                  *
C****************************************************
C
	BYTE DIR(32,64),CNAME(12)
	INTEGER EXT
	COMMON DIR
C
	DO 44 IENTRY=1,64
	IF (DIR(1,IENTRY) .EQ. "345) GOTO 44	!EMPTY, SKIP
	DO 42 ICHAR=2,12
	IF (DIR(ICHAR,IENTRY) .NE. CNAME(ICHAR-1)) GOTO 44
   42	C O N T I N U E
C  FALL THROUGH MEANS A MATCH
	IF (DIR(13,IENTRY) .EQ. EXT) GOTO 90	!FOUND IT
C
   44	C O N T I N U E
C  FALL THROUGH MEANS NO MATCH FOUND
	IENTRY=-1
   90	RETURN
	END
C
	SUBROUTINE CPYFIL(IENTRY,CNAME,ICHAN,IDCHAN)
C*************************************************
C*                                               *
C*  COPY CP/M FILE (ICHAN) TO DEC FILE (IDCHAN). *
C*  CP/M DIRECTORY ENTRY IS 'IENTRY'.            *
C*  CLOSE DEC CHANNEL (IDCHAN) WHEN FINISHED.    *
C*                                               *
C*  RUSS BAKKE                      02-18-83     *
C*                                               *
C*************************************************
C
	BYTE DIR(32,64),DBUFF(1024),CNAME(12)
	COMMON DIR
C
	IDBLK=0	!DISK BLOCK TO WRITE
	IEXT=0	!FIRST EXTENT
C
    8	ICLU=1	!FIRST CLUSTER
	ISIZE=DIR(16,IENTRY)
	IF (ISIZE .LT. 0) ISIZE=ISIZE+256
	IF (ISIZE .EQ. 128) ISIZE=129	!DON'T LET IT COUNT OUT
   10	IF (ISIZE .EQ. 0) GOTO 90
	IBLK=DIR(16+ICLU,IENTRY)
	IF (IBLK .LT. 0) IBLK=IBLK+256
C  (PROBLEM HERE, IS WE GET SIGN EXTENSION ON READING BYTE
C  VALUE INTO INTEGER VARIABLE)
	IF (IBLK .EQ. 0) GOTO 90	!THAT'S ALL
C
C  NEED TO READ 'IBLK' 1K CLUSTER (8 SECTORS)
C
C  CONVERT IBLK TO STARTING SECTOR # AND TRACK #
C  MULTIPLY BY 8 AND REDUCE MODULO 26
	ITEMP=8*IBLK
	ISTTRK=ITEMP/26
	ISTART=ITEMP-26*ISTTRK+1
	ISTTRK=ISTTRK+2	!SKIP SYSTEM TRACKS
C
	DO 60 ISECTR=0,7
	ITEMP=ISTART+ISECTR
	ITRK=ISTTRK
	IF (ITEMP .LE. 26) GOTO 30
	ITEMP=ITEMP-26
	ITRK=ITRK+1
   30	CALL DOSEC(ITRK,ITEMP,DBUFF(128*ISECTR+1),ICHAN)
	ISIZE=ISIZE-1
	IF (ISIZE .LE. 0) GOTO 62
   60	C O N T I N U E
C
C  NOW WRITE BUFF TO IDCHAN
C  SEARCH BUFFER FOR CTL-Z (EOF)
   62	DO 65 INDEX=1,1024
	IF (DBUFF(INDEX) .EQ. 26) GOTO 75
   65	C O N T I N U E
C
   70	IRET=IWRITW(512,DBUFF,IDBLK,IDCHAN)
	IDBLK=IDBLK+2
C  IWRITW RETURNS:
C  -1: EOF
C  -2: HARDWARE ERROR
C  -3: CHANNEL NOT OPEN
C
	IF (IRET .LT. 0) GOTO 95
	ICLU=ICLU+1
	IF (ICLU .LT. 17) GOTO 10	!NEXT SEGMENT
C
C  NOW SEE IF WE HAVE ANOTHER EXTENT
	IEXT=IEXT+1
	CALL FIND(CNAME,IEXT,IENTRY)
	IF (IENTRY .NE. -1) GOTO 8	!NEXT EXTENT
	GOTO 90
C
C  HAVE EOF AT "INDEX"
   75	DO 78 INDEX1=INDEX,1024
	DBUFF(INDEX1)=0		!NULL FILL
   78	C O N T I N U E
	IF (INDEX .GT. 512) GOTO 84
C
C  HAVE PARTIAL BUFFER--WRITE IT OUT.
   83	IRET=IWRITW(256,DBUFF,IDBLK,IDCHAN)
	IDBLK=1
	GOTO 86
C
   84	IRET=IWRITW(512,DBUFF,IDBLK,IDCHAN)
	IDBLK=2
   86	IF (IRET .LT. 0) GOTO 95
   90	IF (IDBLK .EQ. 0) GOTO 94
	CALL ICLOSE(IDCHAN)
   92	CALL IFREEC(IDCHAN)
	RETURN
C
C  FILE OF 0 LENGTH, EAT IT.
   94	CALL PURGE(IDCHAN)
	GOTO 92
C
   95	TYPE *,'WRITE ERROR IN CPYFIL, TYPE ',IRET
	STOP
	END
                                                                                                                                                                                                                                              