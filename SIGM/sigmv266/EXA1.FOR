        PROGRAM EXA1
C////////////////////////////////////////////////////////////////
C/                                                              /
C/      Program-id.     Main of Exmple 1                        /
C/      Date-written.   Jan. 16th 1984                          /
C/      File-name.      EXA1.FOR                                /
C/      Remarks.        A single-channel queueing situation.    /
C/                      Simulation with GASP page 118.          /
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
      COMMON /C3/ XISYS,BUS,XL,XMU
C
	DATA	FLNAME(1),FLNAME(2),FLNAME(3),FLNAME(4),FLNAME(5),
     1  FLNAME(6),FLNAME(7),FLNAME(8),FLNAME(9),FLNAME(10),FLNAME(11)
     2	/'G','A','S','P',' ',' ',' ',' ','D','A','T'/
C
C       --- Set NCRDR equal to the Floppy drive number and
C           NPRNT to the printer number.
C
        NCRDR = 6
C
	IDRIVE = 0
	WRITE(1,90)
   90	FORMAT(1H0,'Output GASP data file to Display(3) or Printer(2)'
     $  ,/1H ,'Input Device Number (3 or 2): ')
	READ(1,95) NPRNT
   95	FORMAT(I1)
	WRITE(1,100)
  100	FORMAT(1H0,'Input GASP data file name (max 8 characters): ')
	READ(1,200) (FLNAME(I),I=1,8)
	WRITE(3,210) (FLNAME(I),I=1,11)
  210	FORMAT(1H ,'Input GASP data file name: ',11A1)
  200	FORMAT(8A1)
	CALL	OPEN(NCRDR,FLNAME,IDRIVE)
C
        XISYS = 1.
        BUS = 1.
        XL = 10.
        XMU = 6.
	CALL	GASP(NSET)
        CALL    EXIT
        END
