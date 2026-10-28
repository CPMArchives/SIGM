        SUBROUTINE      HISTO(X1,A,W,N )
C////////////////////////////////////////////////////////////////
C/                                                              /
C/      Program-id.     HISTO                                   /
C/      Date-written.   Jan. 16th 1984                          /
C/      File-name.      HISTO.FOR                               /
C/      Remarks.        Subroutine HISTO.FOR page 79.           /
C/                      HISTO tabulates the number of times X1  /
C/                      is within the specified cell limits.    /
C/                                                              /
C////////////////////////////////////////////////////////////////
C
        INTEGER*4       NSET(6,1 )
C
      COMMON /C1/ID,IM,INIT,JEVNT,JMNIT,MFA,MSTOP,MX,MXC,NCLCT,NHIST,
     1           NOQ,NORPT,NOT,NPRMS,NRUN,NRUNS,NSTAT,OUT,SCALE,ISEED,
     2           TNOW,TBEG,TFIN,MXX,NPRNT,NCRDR,NEP,VNQ(4)
C
      COMMON /C2/ATRIB(4),ENQ(4),INN(4),JCELS(5,22),KRANK(4),MAXNQ(4),
     1           MFE(4),MLC(4),MLE(4),NCELS(5),NQ(4),PARAM(20,4),
     2           QTIME(4),SSUMA(10,5),SUMA(10,5),NAME(6),NPROJ,MON,
     3		 NDAY,NYR,JCLR
C
C
C
        IF (N- NHIST ) 11,11,2
    2   WRITE(NPRNT,250 ) N
  250     FORMAT(' Error in histogram',I4,// )
        CALL    EXIT
   11   IF (N ) 2,2,3
C
C       --- Translate X1 by subtracing A if X.LE.A
C
    3   X = X1 - A
        IF (X ) 6,7,7
    6   IC = 1
        				GO TO 8
C
C       --- Determine cell number IC.
C
    7   IC = X / W + 2.0
        IF (IC - NCELS(N ) - 1 ) 8,8,9
    9   IC = NCELS(N ) + 2
    8   JCELS(N,IC ) = JCELS(N,IC ) + 1
        RETURN
        END
