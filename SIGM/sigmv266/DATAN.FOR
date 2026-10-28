        SUBROUTINE      DATAN(NSET)
C////////////////////////////////////////////////////////////////
C/                                                              /
C/      Program-id.     DATAN                                   /
C/      Date-written.   Jan. 16th 1984                          /
C/      File-name.      DATAN.FOR                               /
C/      Remarks.        Subroutine DATAN.FOR page 44.           /
C/			Initialize GASP variables to permit the /
C/			starting of the Simulation.		/
C/                                                              /
C////////////////////////////////////////////////////////////////
C
C	* Defailt size of INTEGER = 2 bytes in F80
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
        IF (NOT) 23,1,2
C
C       --- NEP is a control variable for determining the starting
C           card type for multiple run problems.        
C           the value of NEP specifies the starting card type.
C
2       NT = NEP
        GO TO (1,5,6,41,42,8,43,299,15,20),NT
   23	CALL	ERROR(95,NSET)
    1   NOT = 1
        NRUN = 1
C
C       --- Data card type one
C
	WRITE(3,200)
  200	FORMAT(1H0,9X,'1',9X,'2',9X,'3',9X,'4',9X,'5',9X,'6',9X,'7' /
     1  1H ,'123456789',1H0,'123456789',1H0,'123456789',1H0,'123456789'
     2  ,1H0,'123456789',1H0,'123456789',1H0,'1234567890')
        READ(NCRDR,101) NAME,NPROJ,MON,NDAY,NYR,NRUNS
  101     FORMAT(6A2,I4,I2,I2,I4,I4)
	WRITE(3,201) NAME,NPROJ,MON,NDAY,NYR,NRUNS
  201	  FORMAT(1H ,6A2,I4,I2,I2,I4,I4)
        IF (NRUNS) 30,30,5
   30   CALL    EXIT
C
C       --- Data card type two
C
    5   READ(NCRDR,803) NPRMS,NHIST,NCLCT,NSTAT,ID,IM,NOQ,MXC,SCALE
  803     FORMAT(8I5,F10.2)
	WRITE(3,804) NPRMS,NHIST,NCLCT,NSTAT,ID,IM,NOQ,MXC,SCALE
  804	  FORMAT(1H ,8I5,F10.2)
        IF (NHIST) 41,41,6
C
C       --- Data card type three is used only if NHIST is greater
C           than zero. Specify number of cells in histograms not
C           including end cells.
C
6       READ(NCRDR,103) (NCELS(I),I=1,NHIST)
  103     FORMAT(10I5)
	WRITE(3,203) (NCELS(I),I=1,NHIST)
  203	  FORMAT(1H ,10I5)
C
C       --- Data card type four
C           Specify KRANK = Ranking row.
C
   41   READ(NCRDR,103) (KRANK(I),I=1,NOQ)
	WRITE(3,203) (KRANK(I),I=1,NOQ)
C
C       --- Data card type five
C           Specify INN=1 for LVF, INN=2 for HVF
C
   42   READ(NCRDR,103) (INN(I),I=1,NOQ)
	WRITE(3,203) (INN(I),I=1,NOQ)
        IF (NPRMS) 23,43,8
    8 DO 9 I=1,NPRMS
C       
C       --- Data card type six used only if NPRMS is greater than
C           zero.
C
        READ(NCRDR,106) (PARAM(I,J),J =1,4)
  106     FORMAT(4F10.4)
	WRITE(3,206) (PARAM(I,J),J=1,4)
  206	  FORMAT(1H ,4F10.4)
    9 CONTINUE
C
C       ---Data card type seven.
C          The NEP value is for the next run.
C          Set JSEED greater than zero to set tnow equal to TBEG
C
   43   READ(NCRDR,104) MSTOP,JCLR,NORPT,NEP,TBEG,TFIN,JSEED
	WRITE(3,204) MSTOP,JCLR,NORPT,NEP,TBEG,TFIN,JSEED
  104     FORMAT(4I5,2F10.3,I4)
  204	FORMAT(1H ,4I5,2F10.3,I4)
        IF (JSEED) 27,26,27
   27   ISEED = JSEED
	CALL	DRAND(ISEED,RNUM)
        TNOW = TBEG
        DO 142 J=1,NOQ
  142     QTIME(J) = TNOW
   26   JMNIT = 0
C
C       --- Initialize nset
C           Specify inputs for next run
C           Read in initial events
C
  299 DO 300 JS = 1,ID
C
C       --- Data card type 8
C           Initialize NSET by JQ equal to a negative value on
C           first event card.
C           Read in intial vents. End initial events and entities
C           with JQ equal to zero.
C
	READ(NCRDR,1110) JQ
	WRITE(3,2110) JQ
 1110	FORMAT(I10)
 2110	FORMAT(1H ,I10)
        IF (JQ) 44,15,320
   44      INIT = 1
	CALL	SET(1,NSET)
			        	GO TO 300
  320	READ(NCRDR,1120) (ATRIB(JK),JK=1,IM)
 1120	FORMAT(7F10.4)
	WRITE(3,2120) (ATRIB(JK),JK=1,IM)
 2120	FORMAT(1H ,7F10.4)
	CALL	FILEM(JQ,NSET)
  300 CONTINUE
C
C       --- JCLR be positive for initialization of storage arrays.
C
   15      IF (JCLR) 20,20,10
   10      IF (NCLCT) 23,110,116
  116 DO 18 I = 1,NCLCT
        DO 17 J = 1,3
   17     SUMA(I,J) = 0.
        SUMA(I,4) = 1.0E20
        SUMA(I,5) = -1.0E20
   18 CONTINUE
  110   IF (NSTAT) 23,111,117
  117 DO 360 I=1,NSTAT
        SSUMA(I,1) = TNOW
        DO 370 J =2,3
  370     SSUMA(I,J) = 0.
	SSUMA(I,4) = 1.0E20
  360	SSUMA(I,5) = -1.0E20
  111   IF (NHIST) 23,20,118
  118 DO 380 K = 1,NHIST
        DO 380 L = 1,MXC
        JCELS(K,L) = 0
  380 CONTINUE
C
C       --- Print out program identification information.
C
   20      WRITE(1,102) NPROJ,NAME,MON,NDAY,NYR,NRUN
  102     FORMAT(1H1,19X,'Simulation Project No.',I4,2X,'on',2X,
     $ 6A2//,20X,'Date',I3,'/',I3,'/',I5,12X,'Run number',I5//)
C
C       --- Print parameter values and scale.
C
        IF (NPRMS) 60,60,62
   62 DO 64 I=1,NPRMS
   64   WRITE(1,107) I,(PARAM(I,J),J=1,4)
  107     FORMAT(10X,' Parameter No.',I5,4F12.4)
   60   WRITE(1,1107) SCALE
 1107    FORMAT(//37X,' Scale =',F10.4)
        RETURN
        END
