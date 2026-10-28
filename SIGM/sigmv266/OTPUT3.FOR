        SUBROUTINE      OTPUT(NSET)
C////////////////////////////////////////////////////////////////
C/                                                              /
C/      Program-id.     OTPUT                                   /
C/      Date-written.   Jan. 23rd 1984                          /
C/      File-name.      OTPUT3.FOR                              /
C/      Remarks.        Subroutine OTPUT.FOR page 130           /
C/                      Written by the programmer to perform    /
C/                      calculations and provide additional     /
C/                      output at the end of a simulation run.  /
C/			This is the version for Example-3.	/
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
      COMMON /C3/ XISYS,BUS,XL,XMU
C
	COMMON /C3/ XISYS,BUS
C
C       --- Compute theoretical and simulation values of performance
C           measures for the queuing system.
C
        ETISS = SUMA(1,1) / SUMA(1,3)
        EIDTS = (SSUMA(2,1) - SSUMA(2,2)) / (SUMA(1,3) - 1.0)
        EWTS = SUMA(2,1) / SUMA(2,3)
        EIDTC = PARAM(1,1) - PARAM(2,1)
	EWTC = (1.0/PARAM(1,1)) / ((1.0/PARAM(2,1)) * (1.0/
     1  PARAM(2,1) - 1.0/PARAM(1,1)))
        ETISC = 1.0/(1.0/PARAM(2,1) - 1.0/PARAM(1,1))
        YA = ETISS / (SSUMA(1,2) / SSUMA(1,1))
        YS = ETISS - EWTS
        WRITE(NPRNT,85)
   85     FORMAT(/36X,'Simulated Value',4X,'Theoretical Value'/)
        WRITE(NPRNT,90) EIDTS,EIDTC
   90     FORMAT(10X,'Expected idle time',11X,F8.3,12X,F8.3)
        WRITE(NPRNT,95) EWTS,EWTC
   95     FORMAT(10X,'Expected waiting time',8X,F8.3,12X,F8.3)
        WRITE(NPRNT,96) ETISS,ETISC
   96     FORMAT(10X,'Expected time in system',6X,F8.3,12X,F8.3)
        WRITE(NPRNT,97) YA,PARAM(1,1)
   97     FORMAT(10X,'Expected arrival time',8X,F8.3,12X,F8.3)
        WRITE(NPRNT,98) YS,PARAM(2,1)
   98     FORMAT(10X,'Expected service time',8X,F8.3,12X,F8.3)
        RETURN
        END
