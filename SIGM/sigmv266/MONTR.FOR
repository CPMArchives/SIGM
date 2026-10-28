        SUBROUTINE      MONTR( NSET )
C////////////////////////////////////////////////////////////////
C/                                                              /
C/      Program-id.     MONTR                                   /
C/      Date-written.   16th,Jan,1984                           /
C/      File-name.      MONTR.FOR                               /
C/      Remarks.        Subroutine MONTR.FOR page 87.           /
C/                      The monitoring of events as they        /
C/                      occur.                                  /
C/                                                              /
C////////////////////////////////////////////////////////////////
C       //FOR
C       *ONE WORD INTEGER
C       *LIST SOURCE PROGRAM
        INTEGER*4       NSET( 6,1 )
        COMMON /C1/ID,IM,INIT,JEVNT,JMNIT,MFA,MSTOP,MX,MXC,NCLCT,NHIST,
     $  NOQ,NORPT,NOT,NPRMS,NRUN,NRUNS,NSTAT,OUT,SCALE,ISEED,TNOW,
     $  TBEG,TFIN,MXX,NPRNT,NCRDR,NEP,VNQ(4)
        COMMON /C2/ATRIB(4),ENQ(4),INN(4),JCELS(5,22),KRANK(4),MAXNQ(4),
     $  MFE(4),MLC(4),MLE(4),NCELS(5),NQ(4),PARAM(20,4),QTIME(4),
     $  SSUMA(10,5),SUMA(10,5),NAME(6),NPROJ,MON,NDAY,NYR,JCLR
C
C       --- IF JEVNT .GE. 101   Print NSET
C
        IF (JEVNT - 101) 9,7,9
7       WRITE( NPRNT,100 ) TNOW
        DO 1000 I=1,ID
100     FORMAT(1H0,10X,'** GASP Job Storage area dump at',F10.4,
     $  2X,'Time units **'// )
1000    WRITE( NPRNT,101 ) I,( NSET(J,I),J=1,MXX )
101     FORMAT(I5,12I9)
        RETURN
9       IF ( MFE(1) ) 3,6,1
C
C       --- IF JMNIT = 1 Print TNOQ, Current event code, and all
C           attributes of the next event.
C
1       IF ( JMNIT - 1 ) 5,4,3
3       WRITE( NPRNT,199 )
199     FORMAT(///26X,' Error Exit, type 99 error.' )
        CALL    EXIT
4       MMFE = MFE(1)
        WRITE( NPRNT,103 ) TNOW,ATRIB(2),(NSET(I,MMFE),I=1,MXX )
103     FORMAT(/10X,'Current event.... Time =',F8.2,5X,'Event =',F7.2,
     $  /10X,'Next event.......',/(10X,12I9)// )
5       RETURN
6       WRITE( NPRNT,104 ) TNOW
104     FORMAT(10X,' File 1 is empty at',F10.2 )
        GO TO 5
        END
