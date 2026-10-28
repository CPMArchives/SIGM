        SUBROUTINE      GASP(NSET)
C/////////////////////////////////////////////////////////////////////
C/                                                                   /
C/      Program-id.     GASP                             	     /
C/      Date-written.   Jan. 16th 1984                               /
C/      File-name.      GASP.FOR                                     /
C/      Remarks.        Subroutine GASP page 34                      /
C/			GASP is the master control routine and       /
C/			is referred to as the GASP executive.	     /
C/	Source.		Original GASP was developed at U.S. Steel.   /
C/			GASP II was developed at Arizona State	     /
C/			University with FORTRAN IV on IBM 1130 with  /
C/			8K words (16bit one word).		     /
C/			Translate to CP/M 8bit computer	by Makoto    /
C/			Yamagiwa (JUG-CP/M No.61) and released to    /
C/			JUGPDS.					     /
C/	Security.	GASP II is a trade mark of Arizona	     /
C/			State University, U.S.A. by A. Alan B.       /
C/			Pritsker & Philip J. Kiviat: "Simulation     /
C/			with GASP II", 1969			     /
C/                                                                   /
C/////////////////////////////////////////////////////////////////////
C	* ONE WORD INTEGERS EXCEPT NSET
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
        NOT = 0
    1   CALL    DATAN(NSET)
C
C       --- Print out filing array.
C
        JEVNT = 101
        CALL    MONTR(NSET)
        WRITE(NPRNT,403)
  403     FORMAT(1H0,28X,'** Intermediate Results **'//)
C
C       --- Obtain next event which is first entry in file 1.
C           ATRIB(1) is event time, ATRIB(2) is event code.
C
   10   CALL    RMOVE(MFE(1),1,NSET)
        TNOW = ATRIB(1)
        JEVNT = ATRIB(2)
C
C       --- Test to see if this event is a moitor event.
C
        IF (JEVNT - 100) 13,12,6
   13   I = JEVNT
C
C       --- Call programmers event routines.
C
        CALL    EVNTS(I, NSET)
C
C       --- Test methode for stopping
C
        IF (MSTOP) 40,8,20
   40   MSTOP = 0
C
C       --- Test for no summary report.
C
        IF (NORPT) 14,22,42
   20   IF (TNOW - TFIN) 8,22,22
   22   CALL    SUMRY(NSET)
        CALL    OTPUT(NSET)
C
C       --- Test number of runs remaining
C
   42   IF(NRUNS - 1) 14,9,23
   23   NRUNS = NRUNS - 1
        NRUN = NRUN + 1
     				        GO TO 1
   14   CALL    ERROR(93,NSET)
    6   CALL    MONTR(NSET)
  					GO TO 10
C
C       --- Reset JMNIT
C
   12      IF(JMNIT) 14,30,31
   30      JMNIT = 1
   					GO TO 10
   31      JMNIT = 0
        				GO TO 10
C
C       --- Test to see if event information is to be printed.
C
    8   IF (JMNIT) 14,10,32
   32   ATRIB(2) = JEVNT
        JEVNT = 100
        CALL    MONTR(NSET)
        				GO TO 10
C
C       --- If all runs are completed return to main program 
C           for instructions.
C
    9   RETURN
        END
