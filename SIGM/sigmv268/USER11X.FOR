C	[USER11X.FOR of JUGPDS Vol.10]
C
	PROGRAM		EXA11
C////////////////////////////////////////////////////////////////
C/								/
C/	Program-id.	Example_11x, Information System		/
C/	Date-written.	Feb. 11th 1984				/
C/	Remarks.	A main program of Information service	/
C/			system, from page 269.			/
C/			This program uses GASP IIex version.	/
C/								/
C////////////////////////////////////////////////////////////////
C
	INTEGER*1	FLNAME(11)
	DIMENSION	NSET(120), QSET(30)
        COMMON/C1/ID,IM,INIT,JEVNT,JMNIT,MFA,MSTOP,MX,MXC,NCLCT,NHIST,
     $  NOQ,NORPT,NOT,NPRMS,NRUN,NRUNS,NSTAT,OUT,ISEED,TNOW,
     $  TBEG,TFIN,MXX,NPRNT,NCRDR,NEP,VNQ(4),IMM,MAXQS,MAXNS
	COMMON/C2/ATRIB(10),ENQ(4),INN(4),JCELS(5,22),KRANK(4),
     $  MAXNQ(4),MFE(4),MLC(4),MLE(4),NCELS(5),NQ(4),PARAM(20,4),
     $  QTIME(4),SSUMA(10,5),SUMA(10,5),NAME(6),NPROJ,MON,NDAY,NYR,
     $  JCLR,JTRIB(12)
	COMMON /U1/ NARC,NSCAN,JBUFF,NSTA(10),JRPLY(10)
	COMMON /U2/ XL,NTER,IBUFF,CDIAL(2),CREAD(2),SRTIM,SCTIM,
     $	TRTIM,DLTIM,COMTIM(2)
	DATA FLNAME/'G','A','S','P',4*' ','D','A','T'/
C
C	--- Start of Main program of Information System.
C
	NCRDR = 6
C
	IDRIVE = 0
	WRITE(1,90)
   90	FORMAT(1H0,'Output GASP data file to Display(3) or Printer(2)'
     1         ,/1H ,'Enter Output Device number 2 or 3 : ')
	READ(1,95) NPRNT
  95	FORMAT(I1)
	WRITE(1,100)
  100	FORMAT(1H0,'Input GASPex data file name (max 8 characters):')
	READ(1,200) (FLNAME(I),I=1,8)
	WRITE(1,210) (FLNAME(I),I=1,11)
  200	FORMAT(8A1)
  210	FORMAT(1H ,'Input GASPex data file name: ',11A1)
	CALL	OPEN(NCRDR,FLNAME,IDRIVE)
C
C	--- Initial conditions for he simulation are no customers in
C	    the system. the scanner is at position (1), the buffer sto-
C	    rage is not blocked, all stations have no customers in them
C	    and all lines are free.
C
	NARC = 0
	NSCAN = 1
	JBUFF = 0
   	DO 10 I=1,10
	NSTA(I) = 0
   10	JRPLY(I) = 1
C
	CALL	GASP(NSET,QSET)
	CALL	EXIT
	END
C
	SUBROUTINE	EVNTS(I,NSET,QSET)
C////////////////////////////////////////////////////////////////
C/								/
C/	Program-id.	EVNTS.FOR				/
C/	Date-written.	11th,Feb,1984				/
C/	Remarks.	The user defined events routine for 	/
C/			Information system, from page 270	/
C/								/
C////////////////////////////////////////////////////////////////
C
	DIMENSION	NSET(1),QSET(1)
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
C	--- SET INITIAL USER VARIABLES.
C
	NTER = PARAM(1,1)
	IBUFF = PARAM(1,2)
	XL = PARAM(1,3)
	CDIAL(1) = PARAM(2,1)
	CDIAL(2) = PARAM(2,2)
	CREAD(1) = PARAM(3,1)
	CREAD(2) = PARAM(3,2)
	SRTIM = PARAM(4,1)
	SCTIM = PARAM(4,2)
	TRTIM = PARAM(5,1)
	DLTIM = PARAM(5,2)
	COMTIM(1) = PARAM(6,1)
	COMTIM(2) = PARAM(6,2)
C
	GO TO (1,2,3,4,5),I
    1	CALL	ARRVL(NSET,QSET)
	RETURN
    2	CALL	RQEST(NSET,QSET)
	RETURN
    3	CALL	SCAN(NSET,QSET)
	RETURN
    4	CALL	ANSER(NSET,QSET)
	RETURN
    5	CALL	ENDSV(NSET,QSET)
	RETURN
	END
C
	SUBROUTINE	OTPUT(NSET,QSET)
C////////////////////////////////////////////////////////////////
C/								/
C/	Program-id.	OTPUT.FOR				/
C/	Date-written.	11th,Feb,1984				/
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
	SUBROUTINE	ARRVL(NSET,QSET)
C////////////////////////////////////////////////////////////////
C/								/
C/	Program-id.	ARRVL.FOR				/
C/	Date-written.	11th,Feb,1984				/
C/	Remarks.	Subroutine ARRVL is called each time	/
C/			a new customer arrives to the system	/
C/			from page 272				/
C/								/
C////////////////////////////////////////////////////////////////
C
	DIMENSION	NSET(1),QSET(1)
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
C	--- Determine the station number that the arriving customer
C	    will go to by sampling from a uniform distribution.
C	    Collect statistics on number of customers at the station
C	    to which the new arrival is going.
C
	NARC = NARC + 1
	J = 1
	ICHEK = NSTA(1)
	DO 10 I=2,NTER
	IF(ICHEK.LE.NSTA(I)) GO TO 10
	ICHEK = NSTA(I)
	J = I
10	CONTINUE
	X = NSTA(J)
	CALL	TMST(X,TNOW,J,NSET,QSET)
C
C	--- Allow customer to make his request immediately since 
C	    station was idle.
C
	IF (NSTA(J)) 2,2,3
2	ATRIB(1) = TNOW + UNFRM(CDIAL(1),CDIAL(2))
	JTRIB(1) = 2
	JTRIB(2) = J
	CALL	FILEM(1,NSET,QSET)
C
C	--- Increment number of customer at station J by one
C
3	NSTA(J) = NSTA(J) + 1
C
C	--- Schedule next customer arrival at current time olus a
C	    sample from an exponential distribution.
C	    Customers request is completed. Store request in file 
C	    of calls requested but not in buffer. 
C
	CALL	DRAND(ISEED,RNUM)
	ATRIB(1) = TNOW - XL*ALOG(RNUM)
	JTRIB(1) = 1
	CALL	FILEM(1,NSET,QSET)
	RETURN
	END
	SUBROUTINE 	RQEST(NSET,QSET)
C////////////////////////////////////////////////////////////////
C/								/
C/	Program-id.	RQEST.FOR				/
C/	Date-written.	11th,Feb,1984				/
C/	Remarks.	Placement of request for information	/
C/			from page 273				/
C/								/
C////////////////////////////////////////////////////////////////
C
	DIMENSION	NSET(1),QSET(1)
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
	J = JTRIB(2)
	JTRIB(1) = 20
	CALL	FILEM(2,NSET,QSET)
	JRPLY(J) = 2
	RETURN
	END
	SUBROUTINE	SCAN(NSET,QSET)
C////////////////////////////////////////////////////////////////
C/								/
C/	Program-id.	SCAN.FOR				/
C/	Date-written.	11th,Feb,1984				/
C/	Remarks.	Subroutine SCAN controls the scanner 	/
C/			and is called each time the scanner	/
C/			can intettogate a scan point.		/
C/			From page 274				/
C/								/
C////////////////////////////////////////////////////////////////
C
	DIMENSION	NSET(1),QSET(1)
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
C	--- Test to see if scan point has a request which is to be 
C	    transferred to the buffer.
C
	K = JRPLY(NSCAN)
	GO TO (4,1,4,4),K
C
C	--- Test to see if buffer is full. If buffer is full, stop 
C	    scanner and set buffer index to full ststus and return
C
1	IF (NQ(3) - IBUFF) 3,2,2
2	JBUFF = 1
	RETURN
C
C	--- If buffer is not full, find the request at the scan point
C	    and transfer it to the buffer.
C
3	CALL	FINDN(NSCAN,5,2,2,KCOL,NSET,QSET)
	CALL	RMOVE(KCOL,2,NSET,QSET)
	JTRIB(1) = 30
	CALL	FILEM(3,NSET,QSET)
C
C	--- File request in file 3, the file of calls in buffer.
C	    Schedule arrival of answer to the request to occur at
C	    current time plus the transfer time from the scanner to 
C	    the buffer and from the buffer to the station plus 
C	    the computer computation time.
C
	JRPLY(NSCAN) = 3
	ADDTIM = TRTIM + DLTIM
	ATRIB(1) = TNOW + ADDTIM + UNFRM(COMTIM(1),COMTIM(2))
	JTRIB(1) = 4
	CALL	FILEM(1,NSET,QSET)
C
C	--- Set scanner delay time as the sum of the transfer time plus
C	    scan time plus movement time.
C
	SUMTIM = SRTIM + SCTIM + TRTIM
	ATRIB(1) = TNOW + SUMTIM
	GO TO 5
C
C	--- Set scan time delay equal to scan time plus movement time
C
4	SUMTIM = SRTIM + SCTIM
	ATRIB(1) = TNOW + SUMTIM
C
C	--- Move scanner to next position and schedule another scan
C
5	IF(NSCAN - NTER) 7,6,6
6	NSCAN = 0
7	JTRIB(1) = 3
	CALL	FILEM(1,NSET,QSET)
	NSCAN = NSCAN + 1
	RETURN
	END
C
	SUBROUTINE	ANSER(NSET,QSET)
C////////////////////////////////////////////////////////////////
C/								/
C/	Program-id.	ANSER.FOR				/
C/	Date-written.	11th,Feb,1984				/
C/	Remarks.	Subroutine ANSER ia called whenever an	/
C/			answer to request is ready.		/
C/			From page 275				/
C/								/
C////////////////////////////////////////////////////////////////
C
	DIMENSION	NSET(1),QSET(1)
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
C	--- Find request for which an answer has been determined
C	    and remove it from the file of calls requested and stored 
C	    in the buffer.
C
	J  = JTRIB(2)
	CALL	FINDN(J,5,3,2,KCOL,NSET,QSET)
	CALL	RMOVE(KCOL,3,NSET,QSET)
	TI = TNOW - ATRIB(1)
	CALL	COLCT(TI,1,NSET,QSET)
	SUMT = SRTIM + SCTIM + TRTIM + DLTIM
	DELT = (COMTIM(2) - COMTIM(1) + SUMT) / 20.0
	CALL	HISTO(TI,SUMT,DELT,1)
	JRPLY(J) = 4
C
C	--- Schedule an end of service event for the customer to
C	    occur at current time plus customer's reading time
C
	ATRIB(1) = TNOW + UNFRM(CREAD(1),CREAD(2))
	JTRIB(1) = 5
	CALL	FILEM(1,NSET,QSET)
C
C	--- Determine if buffer was full 
C
	IF (JBUF.LE.0) RETURN
C
C	--- If buffer was full, set it to nonfull status and call 
C	    subroutine SCAN to start the scanner moving again.
C
	JBUFF = 0
	CALL	SCAN(NSET,QSET)
	RETURN
	END
C
	SUBROUTINE	ENDSV(NSET,QSET)
C////////////////////////////////////////////////////////////////
C/								/
C/	Program-id	ENDSV.FOR				/
C/	Date-written.	Feb. 11th 1984				/
C/	Remarks.	Subroutine ENDSV is called eack time	/
C/			a customer is finished with the answer	/
C/			to his request.				/
C/			From page 276				/
C/								/
C////////////////////////////////////////////////////////////////
C
	DIMENSION	NSET(1),QSET(1)
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
C	--- Collect statistics on number of customers at station J
C
	J = JTRIB(2)
	X = NSTA(J)
	CALL	TMST(X,TNOW,J,NSET,QSET)
C
C	--- Decrement number of customers at station J by one
C
	NSTA(J) = NSTA(J) - 1
	JRPLY(J) = 1
C
C	--- Set line from station J to free status
C
	IF (NSTA(J).LE.0) RETURN
C
C	--- If a customer is waitting for station J, schedule a 
C	    plavement of request event at station J
C
	ATRIB(1) = TNOW + UNFRM(CDIAL(1),CDIAL(2))
	JTRIB(1) = 2
	JTRIB(2) = J
	CALL	FILEM(1,NSET,QSET)
	RETURN
	END
