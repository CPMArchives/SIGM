        PROGRAM EXA4
C////////////////////////////////////////////////////////////////
C/                                                              /
C/      Program-id.     Main of Exmple 4                        /
C/      Date-written.   Jan. 24th 1984                          /
C/      File-name.      EXA4.FOR                                /
C/      Remarks.        Example-4 Simulation of a Drive-in Bank /
C/                      Simulation with GASP page 146.          /
C/                                                              /
C////////////////////////////////////////////////////////////////
C	* ONE WORD INTEGERS EXCEPT FINAME & NSET
	INTEGER*1	FLNAME(11)
        INTEGER*4       NSET(6,25)
C
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
        COMMON /C3/ XL,XMU(2),XBUZ(2),XISYS,CBALK,TCUST,TLD
C
        DATA    FLNAME(1),FLNAME(2),FLNAME(3),FLNAME(4),FLNAME(5),
     1  FLNAME(6),FLNAME(7),FLNAME(8),FLNAME(9),FLNAME(10),FLNAME(11)
     2  /'G','A','S','P',' ',' ',' ',' ','D','A','T'/
	DATA	XL,XMU,XBUZ,XISYS/0.4,1.0,1.0,1.0,1.0,6.0/
C
C       --- Set NCRDR equal to the Floppy drive number and
C           NPRNT to the printer number.
C
        NCRDR = 6
C
        IDRIVE = 0
        WRITE(1,90)
   90   FORMAT(1H0,'Output GASP data file to Display(3) or Printer(2)',
     1         /1H ,'Output Device Number (3 or 2): ')
        READ(1,95) NPRNT
   95      FORMAT(I1)
        WRITE(1,100)
  100     FORMAT(1H0,'Input GASP data file name (max 8 characters): ')
        READ(1,200) (FLNAME(I),I=1,8)
  200     FORMAT(8A1)
        WRITE(1,210) (FLNAME(I),I=1,11)
  210     FORMAT(1H ,'Input GASP data file name: ',11A1)
        CALL    OPEN(NCRDR,FLNAME,IDRIVE)
C
	WRITE(3,1000) XL,XMU(1),XMU(2),XBUZ(1),XBUZ(2),XISYS
 1000     FORMAT(1H ,6F10.2)
C
C       --- Initailize number of customers balking (CBALK), total
C           customers arriving (TCUST), and time last departure
C           (TLD) at 0.
C
        CBALK = 0.0
        TCUST = 0.0
        TLD = 0.0
        CALL    GASP(NSET)
        CALL    EXIT
        END
