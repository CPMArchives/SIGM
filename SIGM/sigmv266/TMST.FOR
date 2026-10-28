        SUBROUTINE      TMST(X,T,N,NSET)
C////////////////////////////////////////////////////////////////
C/                                                              /
C/      Program-id.     TMST                                    /
C/      Date-written.   Jan. 16th 1984                          /
C/      File-name.      TMST.FOR                                /
C/      Remarks.        Subroutine TMST.FOR page 76.            /
C/                      This subroutine collects sample data    /
C/                      on observations of a variable made over /
C/                      a period of time.                       /
C/                                                              /
C////////////////////////////////////////////////////////////////
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
C
        IF (N.GT.0) GO TO 20
   10   CALL    ERROR(91,NSET)
   20   IF (N .GT. NSTAT) GO TO 10
        TT = T - SSUMA(N,1)
        SSUMA(N,1) = SSUMA(N,1) + TT
        SSUMA(N,2) = SSUMA(N,2) + X*TT
        SSUMA(N,3) = SSUMA(N,3) + X*X*TT
        SSUMA(N,4) = AMIN1(SSUMA(N,4),X)
        SSUMA(N,5) = AMAX1(SSUMA(N,5),X)
        RETURN
        END
