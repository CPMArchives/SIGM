        SUBROUTINE      ENDSV(NSET)
C////////////////////////////////////////////////////////////////
C/                                                              /
C/      Program-id.     ENDSV                                   /
C/      Date-written.   Jan. 23rd 1984				/
C/      File-name.      ENDSV3.FOR                              /
C/      Remarks.        Subroutine ENDSV page 126               /
C/			In ENDSV(End_of_Service) it is first	/
C/			necessary to collect statiscal infor-	/
C/			mation about the item completing 	/
C/			processing.				/
C/			This is the version for Examle 3.	/
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
	COMMON /C3/ XISYS,BUS
C
C	--- Compute time in system equal to current time minus arrival
C	    time of customer finishing service. Cmpute statistics on
C	    in system.
C
	TISYS = TNOW - ATRIB(3)
	CALL	COLCT(TISYS,1,NSET)
	CALL	HISTO(TISYS,2.0,1.0,1)
C
C	--- Since a customer will depart from the system due to the
C	    end of service collect ststistics on number in system
C	    and decrement the number in the system by one.
C
	CALL	TMST(XISYS,TNOW,1,NSET)
	XISYS = XISYS - 1.0
C
C	--- Test to see if customer are waiting for service. If none
C	    collect statistics on the busy time of the server and set
C	    his status to idle by making bus equal zero.
C	    If customer are waiting for service remove first customer
C	    from the queue of the server which is file two.
C
	IF (NQ(2)) 7,8,9
    7	CALL	ERROR(41,NSET)
	RETURN
C
    8	CALL	TMST(BUS,TNOW,2,NSET)
	BUS = 0.0
	RETURN
C
    9	CALL 	RMOVE(MFE(2),2,NSET)
C
C	--- Compute waiting time of customer and collect statistics
C	    on waiting time. Put customer in service by scheduling
C	    and end of service event for the customer.
C
	WT = TNOW - ATRIB(3)
	CALL	COLCT(WT,2,NSET)
	CALL	DRAND(ISEED,RNUM)
	ATRIB(1) = TNOW - PARAM(2,1) * ALOG(RNUM)
	ATRIB(2) = 2.0
	CALL	FILEM(1,NSET)
	RETURN
	END
