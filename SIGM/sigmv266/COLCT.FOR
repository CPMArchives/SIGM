        SUBROUTINE      COLCT(X,N,NSET)
C////////////////////////////////////////////////////////////////
C/                                                              /
C/      Program-id.     COLCT                                   /
C/      Date-written.   16th,Jan,1984                           /
C/      File-name.      COLCT.FOR                               /
C/      Remarks.        Subroutine COLCT.FOR page 74.           /
C/                      This subroutine collects sample data on /
C/                      the value of a variable.                /
C/                                                              /
C////////////////////////////////////////////////////////////////
C
C	* Default size of INTEGER = 2 bytes in F80
C
        INTEGER*4       NSET(6,1)
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
        IF (N.GT.0) GO TO 20
   10   CALL    ERROR(90,NSET)
   20   IF (N.GT.NCLCT) GO TO 10
        SUMA(N,1) = SUMA(N,1) + X
        SUMA(N,2) = SUMA(N,2) + X*X
        SUMA(N,3) = SUMA(N,3) + 1.0
        SUMA(N,4) = AMIN1(SUMA(N,4),X)
        SUMA(N,5) = AMAX1(SUMA(N,5),X)
        RETURN
        END
