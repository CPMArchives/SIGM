        SUBROUTINE      MONTR(NSET)
C////////////////////////////////////////////////////////////////
C/                                                              /
C/      Program-id.     MONTR                                   /
C/      Date-written.   Jan. 16th 1984                          /
C/      File-name.      MONTR.FOR                               /
C/      Remarks.        Subroutine MONTR.FOR page 134           /
C/                      The monitoring of events as they        /
C/                      occur.                                  /
C/			Revised version of MONTR.		/
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
      COMMON /C3/XISYS,BUS,XL,XMU
C
C
C       --- IF JEVNT .GE. 101   Print NSET
C
        IF (JEVNT - 101) 9,7,9
    7   WRITE(NPRNT,100) TNOW
  100     FORMAT(1H1,10X,'** GASP Job Storage area dump at',F10.4,
     1           2X,'Time units **'//)
C
	IF (TNOW - 0.05) 22,22,23
   23	ATRIB(1) = ATRIB(1) + 1000.0
	CALL	FILEM(1,NSET)
   22 DO  1000  I=1,ID
        WRITE(NPRNT,101) I,(NSET(J,I),J=1,MXX)
  101	FORMAT(12I10)
 1000 CONTINUE
        RETURN
C
    9   IF (MFE(1)) 3,6,1
C
C       --- IF JMNIT = 1 Print TNOQ, Current event code, and all
C           attributes of the next event.
C
    1   IF (JMNIT - 1) 5,4,3
    3   WRITE(NPRNT,199)
  199     FORMAT(///26X,' Error Exit, Type 99 error.')
        CALL    EXIT
    4   MMFE = MFE(1)
        WRITE(NPRNT,103) TNOW,ATRIB(2),(NSET(I,MMFE),I=1,MXX)
  103     FORMAT(/10X,'Current event.... Time =',F8.2,5X,'Event =',
     1           F7.2,/10X,'Next event.......',(6I8))
C
	WRITE(NPRNT,105) BUS,XISYS
  105	FORMAT(/10X,'BUS =',F4.0,5X,'No. in System =',F4.0/)
    5   RETURN
    6   WRITE(NPRNT,104) TNOW
  104     FORMAT(10X,' File 1 is empty at',F10.2)
        				GO TO 5
        END
