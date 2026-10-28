	SUBROUTINE	OTPUT(NSET,QSET)
C////////////////////////////////////////////////////////////////
C/								/
C/	Program-id.	OTPUT.FOR				/
C/	Date-written.	Feb. 11th 1984				/
C/	Remarks.	User optinal output routine for 	/
C/			Information system from page 270	/
C/								/
C////////////////////////////////////////////////////////////////
C
	INTEGER*1	DOT(90)
	DIMENSION	NSET(1),QSET(1),DIST(22)
        COMMON/C1/ID,IM,INIT,JEVNT,JMNIT,MFA,MSTOP,MX,MXC,NCLCT,NHIST,
     $  NOQ,NORPT,NOT,NPRMS,NRUN,NRUNS,NSTAT,OUT,ISEED,TNOW,
     $  TBEG,TFIN,MXX,NPRNT,NCRDR,NEP,VNQ(4),IMM,MAXQS,MAXNS
	COMMON /C2/ATRIB(10),ENQ(4),INN(4),JCELS(5,22),KRANK(4),
     $  MAXNQ(4),MFE(4),MLC(4),MLE(4),NCELS(5),NQ(4),PARAM(20,4),
     $  QTIME(4),SSUMA(10,5),SUMA(10,5),NAME(6),NPROJ,MON,NDAY,NYR,
     $  JCLR,JTRIB(12)
	COMMON /U1/ NARC,NSCAN,JBUFF,NSTA(10),JRPLY(10)
	COMMON /U2/ XL,NTER,IBUFF,CDIAL(2),CREAD(2),SRTIM,SCTIM,
     $  TRTIM,DLTIM,COMTIM(2)
C
C
	SIMTIM = TFIN - TBEG
	EFECT  = FLOAT(NARC) / SIMTIM
	WRITE(NPRNT,290) NPROJ,NAME,MON,NDAY,NYR,SIMTIM
290	FORMAT(1H1,'Simulation Project no.',I4,2X,'on',2X,6A2,
     $  //,' Date',I3,'/',I3,'/',I5,5X,'Simulation time : ',F5.0,
     $  ' min ')
	WRITE(NPRNT,380) NTER,IBUFF,XL,CDIAL(1),CDIAL(2),CREAD(1),
     $  CREAD(2),SRTIM,SCTIM,TRTIM,DLTIM,COMTIM(1),COMTIM(2)
380	FORMAT(1H ,'Numbers of stations : ',I2/
     $  1H ,'Max size of buffer         : ',I2/
     $  1H ,'Mean time between arrivals of customers : ',F4.1,
     $  /1H ,'Customers dialing time range : ',F4.1,2X,F4.1,
     $  /1H ,'Customers reading time range : ',F4.1,2X,F4.1,
     $  /1H ,'Scanner rotation time and scanning time : ',F7.4,2X,F7.4,
     $  /1H ,'Scanner transfer time and delay time    : ',F7.4,2X,F7.4,
     $  /1H ,'Computing time range : ',F6.3,2X,F6.3)
	WRITE(NPRNT,385)
385	FORMAT(1H ,'------------------------------------------------',
     $  '---------------------------')
	WRITE(NPRNT,901) NARC
901	FORMAT(1H ,'Total customers served is : ',I6,' persons ')
	WRITE(NPRNT,902) EFECT
902	FORMAT(1H ,'Customers served / Simulation time : ',F7.4,
     $  ' persons/min ')
	WRITE(NPRNT,905) (NSTA(I),I=1,NTER)
905	FORMAT(1H ,'Number of customers waiting at station at end : ',/
     $  1H ,10(I5,2X))
C
C	--- Define user output
C
	SUMT = SRTIM + SCTIM + TRTIM + DLTIM
	DELT = (COMTIM(2) - COMTIM(1) + SUMT) / 20.0
	SUMH = 0
	NCL = NCELS(1) + 2
	DO 910 I=1,NCL
910	SUMH = SUMH + JCELS(1,I)
	DO 920 I=1,NCL
920	DIST(I) = FLOAT(JCELS(1,I)) / SUMH * 100.0
	WRITE(NPRNT,925)
925	FORMAT(1H ,'Average time to obtain a display Distribution : ')
	WRITE(NPRNT,930)
930	FORMAT(1H ,'Upper Limit  Observations  Percentage ')
	DO 940 I=1,NCL
	DO 950 J=1,90
	DOT(J) = ' '
950	CONTINUE
	DOT(1) = ':'
	K = IFIX((DIST(I) + 0.5) * 0.9)
	IF (K.LE.0) GO TO 960
	DO  980  M=1,K
980	DOT(M) = '@'
960	IF (NPRNT.NE.2) GO TO 975
	WRITE(NPRNT,970) SUMT,JCELS(1,I),DIST(I),(DOT(L),L=1,90)
	GO TO 976
975	WRITE(NPRNT,977) SUMT,JCELS(1,I),DIST(I)
977	FORMAT(3X,F6.3,8X,I3,9X,F6.2)
976	CONTINUE
970	FORMAT(3X,F6.3,8X,I3,9X,F6.2,3X,90A1)
	SUMT = SUMT + DELT
940	CONTINUE
	WRITE(NPRNT,1000)
1000	FORMAT(1H1)
	RETURN
	END
