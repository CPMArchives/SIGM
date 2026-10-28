        SUBROUTINE      ERROR(J,NSET)
C////////////////////////////////////////////////////////////////
C/                                                              /
C/      Program-id.     ERROR                                   /
C/      Date-written.   Jan. 16th 1984                          /
C/      File-name.      ERROR.FOR ver2.0                        /
C/      Remarks.        Subroutine ERROR.FOR page 93.           /
C/                      Subroutine ERROR is called when an e    /
C/                      error is detected in any GASP subroutine/
C/                      except PRNTQ, SUMRY, and MONTR, all of  /
C/                      which print their own message.          /
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
        WRITE(NPRNT,100) J
  100     FORMAT(///26X,'Error exit, Type',I3,' Error.')
        JEVNT = 101
C
C       --- Print filing array NSET
C
        CALL    MONTR(NSET)
        WRITE(NPRNT,101)
  101     FORMAT(1H0,31X,'Sceduled events'//)
C
C       --- Print next event file
C
        CALL    PRNTQ(1,NSET)
C
C       --- Print summary report up to present
C
        CALL    SUMRY(NSET)
        IF (JEVNT - 101) 5,6,5
    5   RETURN
    6   CALL    EXIT
        END
