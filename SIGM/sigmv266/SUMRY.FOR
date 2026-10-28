        SUBROUTINE      SUMRY(NSET)
C////////////////////////////////////////////////////////////////
C/                                                              /
C/      Program-id.     SUMRY                                   /
C/      Date-written.   Jan. 16th 1984                          /
C/      File-name.      SUMRY.FOR                               /
C/      Remarks.        Subroutine SUMRY.FOR page 84.           /
C/			Subroutine SUMRY is the basic output 	/
C/			routine of GASP II. It processes the	/
C/			data collected in subroutine COLCT	/
C/			TMST, and HISTO and then prints out 	/
C/			a data summary.				/
C/                                                              /
C////////////////////////////////////////////////////////////////
C
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
	WRITE(NPRNT,21)
   21	FORMAT(1H1,29X,'** GASP Summary Report ** '/)
	WRITE(NPRNT,102) NPROJ,NAME,MON,NDAY,NYR,NRUN
  102	FORMAT(20X,'Simulation Project No.',I4,2X,'on',2X,
     1  6A2//,20X,'Date',I3,'/',I3,'/',I5,12X,'Run number',I5/)
	IF (NPRMS) 147,147,146
  146	DO  64  I=1,NPRMS
   64	WRITE(NPRNT,107) I,(PARAM(I,J),J=1,4)
  107	FORMAT(10X,' Parameter No.',I5,4F12.4)
  147	IF (NCLCT) 5,60,66
    5	WRITE(NPRNT,199)
  199	FORMAT(///26X,'Error Exit, Type 98 Error.')
	CALL	EXIT
   66	WRITE(NPRNT,23)
   23	FORMAT(//34X,'** Generated Data ** ',/17X,'Code',4X,'Mean',6X,
     1	'STD.DEV.',5X,'Min.',7X,'Max.',5X,'OBS.'/)
C
C	--- Compute and print statistics gathered by CLCT
C
      DO 2 I=1,NCLCT
	IF (SUMA(I,3)) 5,62,61
   62	WRITE(NPRNT,63) I
   63	FORMAT(17X,I3,10X,'No Values Recorded ')
					GO TO 2
   61	XS = SUMA(I,1)
	XSS = SUMA(I,2)
	XN = SUMA(I,3)
	AVG = XS / XN
	STD = (((XN * XSS) - (XS * XS))/(XN * (XN - 1.0)))**0.5
	N = XN
	WRITE(NPRNT,24) I,AVG,STD,SUMA(I,4),SUMA(I,5),N
   24	FORMAT(17X,I3,4F11.4,I7)
    2 CONTINUE
   60	IF (NSTAT) 5,67,4
    4	WRITE(NPRNT,29)
   29	FORMAT(/34X,'** Time Generated Data **'/,17X,'Code',4X,'Mean',
     1  6X,'STD.DEV.',5X,'Min.',7X,'Max.',3X,'Total Time '/)
C
C	--- Compute and print statistics gathered by TMST
C
      DO 6 I=1,NSTAT
	IF (SSUMA(I,1)) 5,71,72
   71	WRITE(NPRNT,63) I
					GO TO 6
   72	XT = SSUMA(I,1)
	XS = SSUMA(I,2)
	XSS = SSUMA(I,3)
	AVG = XS / XT
	STD = (XSS/XT - AVG*AVG) ** 0.5
	WRITE(NPRNT,30) I,AVG,STD,SSUMA(I,4),SSUMA(I,5),XT
   30	FORMAT(17X,I3,5F11.4)
    6 CONTINUE
   67	IF (NHIST) 5,75,9
    9	WRITE(NPRNT,25)
   25	FORMAT(/27X,'** Generated Frequency Distributions **',/17X,
     1  'Code',20X,'Histograms')
C
C	--- Print histograms
C
      DO  12  I=1,NHIST
	NCL = NCELS(I) + 2
   12 WRITE(NPRNT,26) I,(JCELS(I,J),J=1,NCL)
   26	FORMAT(/17X,I3,5X,11I4,/(25X,11I4))
C
C	--- Print files and file statistics
C
   75	DO  15  I=1,NOQ
   15	CALL	PRNTQ(I,NSET)
	RETURN
	END
