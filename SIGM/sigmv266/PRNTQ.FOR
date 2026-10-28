        SUBROUTINE      PRNTQ(JQ,NSET)
C////////////////////////////////////////////////////////////////
C/                                                              /
C/      Program-id.     PRNTQ                                   /
C/      Date-written.   Jan. 16th 1984                          /
C/      File-name.      PRNTQ.FOR                               /
C/      Remarks.        Subroutine PRNTQ.FOR page 81.           /
C/                      PRNTQ computes and prints the time-     /
C/                      integrated average and standard of the  /
C/                      number of entries in particular file    /
C/                      and the maximum number of entries  	/
C/                      that  were in the file since the file   /
C/                      was last initialized.                   /
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
        WRITE(NPRNT,100) JQ
  100     FORMAT(//29X,' File Printout, File  No.',I3)
        IF (TNOW - TBEG) 12,12,13
   12   WRITE(NPRNT,105)
  105     FORMAT(/25X,'No Printout TNOW = TBEG '//)
        				GO TO 2
C
C       --- Compute expect no.
C
   13   XNQ = NQ(JQ)
	WRITE(3,1000) XNQ,ENQ(JQ),TNOW,QTIME(JQ),TBEG,VNQ(JQ)
 1000	  FORMAT(1H ,25X,'XNQ, ENQ(JQ),TNOW = ',3F10.4/25X,
     1           'QTIME(JQ),TBEG,VNQ(JQ) = ',3F10.4)
        X = (ENQ(JQ) + XNQ * (TNOW - QTIME(JQ)))/(TNOW - TBEG)
        STD = ((VNQ(JQ)+XNQ*XNQ*(TNOW-QTIME(JQ)))/(TNOW-TBEG)-X*X)**.5
        WRITE(NPRNT,104) X,STD,MAXNQ(JQ)
  104     FORMAT(/25X,'Average Number in file  was',F10.4/25X,
     1           'STD. DEV.',18X,F10.4,/25X,'Maximum',24X,I4)
C
C       --- Print file in proper order requires tracing through the
C           pointers of the file
C
        LINE = MFE(JQ)
        IF (LINE - 1) 4,1,1
    4   WRITE(NPRNT,102)
  102     FORMAT(/33X,'The File is empty')
    2   RETURN
    1   WRITE(NPRNT,101)
  101     FORMAT(/35X,' File Contents'/)
    6 DO 77 I=1,IM
        ATRIB(I) = NSET(I,LINE)
	ATRIB(I) = ATRIB(I) / SCALE
   77 CONTINUE
        WRITE(NPRNT,103) (ATRIB(I),I=1,IM)
  103     FORMAT(10X,10F10.4)
        LINE = NSET(MX,LINE)
        IF (LINE - 7777) 6,2,5
    5   WRITE(NPRNT,199)
  199     FORMAT(///26X,'Error Exit, Type 94 Error.')
        CALL    EXIT
        END
