        SUBROUTINE      OTPUT(NSET )
C////////////////////////////////////////////////////////////////
C/                                                              /
C/      Program-id.     OTPUT                                   /
C/      Date-written.   26th,Jan,1984                           /
C/      File-name.      OTPUT4.FOR                              /
C/      Remarks.        Subroutine OTPUT.FOR page 152           /
C/                      Written by a programmer to perform      /
C/                      calculations and provide additional     /
C/                      output at the end of a simulation run.  /
C/                      This is for Example-4 version.          /
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
        COMMON /C3/ XL,XMU(2),XBUZ(2),XISYS,CBALK,TCUST,TLD
C
C
        WRITE(NPRNT,10 ) XL,XMU(1),XMU(2)
   10      FORMAT(/25X,'Mean time between arrivals  =  ',F5.2/25X,
     1            'Mean service time for tellers = ',F5.2,2X,F5.2)
        YBALK = CBALK * 100.0 / TCUST
        WRITE(NPRNT,20 ) YBALK,CBALK,TCUST
   20     FORMAT(25X,'Percent of customers balking = ',F6.2,' %'/,25X,
     1           'Number of customers balking =  ',F6.2/,25X,
     2           'Total customers',14X,'= ',F6.2 )
        RETURN
        END

