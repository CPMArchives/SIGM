        PROGRAM EXA3
C////////////////////////////////////////////////////////////////
C/                                                              /
C/      Program-id.     Main of exmple 3                        /
C/      Date-written.   21th,Jan,1984                           /
C/      File-name.      EXA3.FOR                                /
C/      Remarks.        a single-channel queueing situation.    /
C/                      Simulation with GASP page 140.          /
C/			This example is for multiple run.	/
C/                                                              /
C////////////////////////////////////////////////////////////////
C       //FOR
C       *ONE WORD INTEGER
C       *LIST SOURCE PROGRAM
C       *IOCS   PRINTER PC-8023C, CARD PC-8031 2W FLOPPY DRIVE
        INTEGER*1       FLNAME( 11 )
        INTEGER*4       NSET( 6,25 )
        COMMON /C1/ID,IM,INIT,JEVNT,JMNIT,MFA,MSTOP,MX,MXC,NCLCT,NHIST,
     $  NOQ,NORPT,NOT,NPRMS,NRUN,NRUNS,NSTAT,OUT,SCALE,ISEED,TNOW,
     $  TBEG,TFIN,MXX,NPRNT,NCRDR,NEP,VNQ(4)
        COMMON /C2/ATRIB(4),ENQ(4),INN(4),JCELS(5,22),KRANK(4),MAXNQ(4),
     $  MFE(4),MLC(4),MLE(4),NCELS(5),NQ(4),PARAM(20,4),QTIME(4),
     $  SSUMA(10,5),SUMA(10,5),NAME(6),NPROJ,MON,NDAY,NYR,JCLR
	common /c3/ xisys,bus
        DATA    FLNAME(1),FLNAME(2),FLNAME(3),FLNAME(4),FLNAME(5),
     $  FLNAME(6),FLNAME(7),FLNAME(8),FLNAME(9),FLNAME(10),FLNAME(11)
     $  /'G','A','S','P',' ',' ',' ',' ','D','A','T'/
C
C       --- Set NCRDR equal to the Floppy drive number and
C           NPRNT to the printer number.
C
        NCRDR = 6
C
        IDRIVE = 0
        WRITE(1,90)
90      FORMAT(1H0,'Output GASP data file to Display(3) or Printer(2)'
     $  ,/1H ,'Output Device number 3 or 2 : ' )
        READ( 1,95 ) NPRNT
95      FORMAT( I1 )
        WRITE(1,100)
100     FORMAT(1H0,'Input GASP data file name ( max 8 characters ) : ')
        READ(1,200) ( FLNAME( I ),I=1,8 )
        WRITE( 3,210 ) ( FLNAME(I),I=1,11 )
210     FORMAT(1H ,'Input GASP data file name : ',11A1 )
200     FORMAT( 8A1 )
        CALL    OPEN( NCRDR,FLNAME,IDRIVE )
C
        CALL    GASP( NSET )
        CALL    EXIT
        END
        SUBROUTINE      ARRVL( NSET )
C////////////////////////////////////////////////////////////////
C/                                                              /
C/      Program-id.     ARRVL                                   /
C/      Date-written.   23th,Jan,1984                           /
C/      File-name.      ARRVL3.FOR                              /
C/      Remarks.        Subroutine ARRVL page 123               /
C/                      The arrival of items to the system is   /
C/                      described in terms of the time between  /
C/                      the arrivals, every arrival event must  /
C/                      cause the next arrival event to occur.  /
C/			This is for Example-3 version.		/
C/                                                              /
C////////////////////////////////////////////////////////////////
C       //FOR
C       *ONE WORD INTEGERS
C       *LIST SOURCE PROGRAM
        INTEGER*4       NSET( 6,1 )
        COMMON /C1/ID,IM,INIT,JEVNT,JMNIT,MFA,MSTOP,MX,MXC,NCLCT,NHIST,
     $  NOQ,NORPT,NOT,NPRMS,NRUN,NRUNS,NSTAT,OUT,SCALE,ISEED,TNOW,
     $  TBEG,TFIN,MXX,NPRNT,NCRDR,NEP,VNQ(4)
        COMMON /C2/ATRIB(4),ENQ(4),INN(4),JCELS(5,22),KRANK(4),MAXNQ(4),
     $  MFE(4),MLC(4),MLE(4),NCELS(5),NQ(4),PARAM(20,4),QTIME(4),
     $  SSUMA(10,5),SUMA(10,5),NAME(6),NPROJ,MON,NDAY,NYR,JCLR
	COMMON /C3/ XISYS,BUS
C
C       --- Since ARRVL is an endogenous event schedule the next 
C           arrival. At TNOW plus number drawn from an exponential
C           distribution. The arrival time is stored in ATRIB(1).
C           The event code for an ARRVL is 1. Set ATRIB(2)
C           equal to 1.
C
        CALL    DRAND( ISEED,RNUM )
        ATRIB(1) = TNOW - PARAM(1,1) * ALOG( RNUM )
        ATRIB(2) = 1.0
        CALL FILEM( 1,NSET )
C
C       --- Collect the statistics on the number in the system since
C           an arrival causes number in the system to change.
C
        CALL    TMST( XISYS,TNOW,1,NSET )
        IF ( XISYS ) 7,8,9
7       CALL    ERROR(31,NSET)
        RETURN
C
C       --- Increment the number in the system. Since the number in
C           the system was zero the server was not busy.
C           The server status will change due to the new arrival
C           therefore statistics on the time the server was busy
C           must be collected.
C
8       XISYS = XISYS + 1.0
        CALL    TMST( BUS,TNOW,2,NSET )
C
C       --- Change the status of the server to busy. Collect 
C           statistics on the waitting time of current arrival which
C           is zero since the server was not busy at his time of 
C           arrival.
C
        BUS = 1.0
        CALL    COLCT( 0.0,2,NSET )
C
C       --- Since the new arrival goes directly into service cause an 
C           end of service event. Set ATRIB(2) equal to indicate an end
C           of service event. Set ATRIB(3) equal to TNOW the arrival
C           time of the customer.
C
        CALL    DRAND( ISEED,RNUM )
        ATRIB(1) = TNOW - PARAM(2,1) * ALOG( RNUM )
        ATRIB(2) = 2.0
        ATRIB(3) = TNOW
        CALL    FILEM( 1,NSET )
        RETURN
C
C       --- Increment the number in the system.
C
9       XISYS = XISYS + 1.0
C
C       --- Put new arrival in the queue waiting for the server to 
C           become free. Set ATRIB(3) equal to the arrival time of
C           the customer.
C
        ATRIB(3) = TNOW
        CALL    FILEM( 2,NSET )
        RETURN
        END
        SUBROUTINE      ENDSM( NSET )
C////////////////////////////////////////////////////////////////
C/                                                              /
C/      Program-id.     ENDSM                                   /
C/	Date-written.	23th,Jan,1984				/
C/      File-name.      ENDSM3.FOR                              /
C/	Remaeks.	User defined subroutine, the completion /
C/			of the simulation at a time specified   /
C/			by the programmer.			/
C/			page 128.				/
C/			This is for Example-3 version.		/
C/                                                              /
C////////////////////////////////////////////////////////////////
C       //FOR
C       *ONE WORD INTEGERS
C       *LIST SOURCE PROGRAM
        INTEGER*4       NSET( 6,1 )
        COMMON /C1/ID,IM,INIT,JEVNT,JMNIT,MFA,MSTOP,MX,MXC,NCLCT,NHIST,
     $  NOQ,NORPT,NOT,NPRMS,NRUN,NRUNS,NSTAT,OUT,SCALE,ISEED,TNOW,
     $  TBEG,TFIN,MXX,NPRNT,NCRDR,NEP,VNQ(4)
        COMMON /C2/ATRIB(4),ENQ(4),INN(4),JCELS(5,22),KRANK(4),MAXNQ(4),
     $  MFE(4),MLC(4),MLE(4),NCELS(5),NQ(4),PARAM(20,4),QTIME(4),
     $  SSUMA(10,5),SUMA(10,5),NAME(6),NPROJ,MON,NDAY,NYR,JCLR
	COMMON /C3/ XISYS,BUS
20	IF( NQ(1) ) 7,8,9
7	CALL	ERROR( 3,NSET )
C
C	--- Update statistics on number in system and status of server 
C	    to end of simulation time. Set control variable to stop
C	    simulation and to yield final report.
C
8	CALL	TMST( XISYS,TNOW,1,NSET )
	CALL	TMST( BUS,TNOW,2,NSET )
	MSTOP = -1
	NORPT = 0
	RETURN
C
C	--- Remove all events from event file so that all customers
C	    arriving before end of simulation time are included in
C	    simulation statistics. Only end of service event need be 
C	    processed. If items are in the queue of the server they
C	    will be removed in the end of service event where another
C	    end of service event will be created.
C
9	CALL	RMOVE( MFE(1),1,NSET )
	TNOW = ATRIB(1)
	IF( ATRIB(2) - 2.0 ) 20,21,20
21	CALL	ENDSV( NSET )
	GO TO 20
	END
        SUBROUTINE      ENDSV( NSET )
C////////////////////////////////////////////////////////////////
C/                                                              /
C/      Program-id.     ENDSV                                   /
C/      Date-written.   23th,Jan,1984                           /
C/      File-name.      ENDSV3.FOR                              /
C/      Remarks.        Subroutine ENDSV page 126               /
C/			In ENDSV( End_of_Service ) it is first	/
C/			necessary to collect statiscal infor-	/
C/			mation about the item completing 	/
C/			processing.				/
C/			This is for Examle-3 version.		/
C/                                                              /
C////////////////////////////////////////////////////////////////
C       //FOR
C       *ONE WORD INTEGERS
C       *LIST SOURCE PROGRAM
        INTEGER*4       NSET( 6,1 )
        COMMON /C1/ID,IM,INIT,JEVNT,JMNIT,MFA,MSTOP,MX,MXC,NCLCT,NHIST,
     $  NOQ,NORPT,NOT,NPRMS,NRUN,NRUNS,NSTAT,OUT,SCALE,ISEED,TNOW,
     $  TBEG,TFIN,MXX,NPRNT,NCRDR,NEP,VNQ(4)
        COMMON /C2/ATRIB(4),ENQ(4),INN(4),JCELS(5,22),KRANK(4),MAXNQ(4),
     $  MFE(4),MLC(4),MLE(4),NCELS(5),NQ(4),PARAM(20,4),QTIME(4),
     $  SSUMA(10,5),SUMA(10,5),NAME(6),NPROJ,MON,NDAY,NYR,JCLR
	COMMON /C3/ XISYS,BUS
C
C	--- Compute time in system equal to current time minus arrival
C	    time of customer finishing service. Cmpute statistics on
C	    in system.
C
	TISYS = TNOW - ATRIB(3)
	CALL	COLCT( TISYS,1,NSET )
	CALL	HISTO( TISYS,2.0,1.0,1 )
C
C	--- Since a customer will depart from the system due to the
C	    end of service collect ststistics on number in system
C	    and decrement the number in the system by one.
C
	CALL	TMST( XISYS,TNOW,1,NSET )
	XISYS = XISYS - 1.0
C
C	--- Test to see if customer are waiting for service. If none
C	    collect statistics on the busy time of the server and set
C	    his status to idle by making bus equal zero.
C	    If customer are waiting for service remove first customer
C	    from the queue of the server which is file two.
C
	IF( NQ(2) ) 7,8,9
7	CALL	ERROR( 41,NSET )
	RETURN
8	CALL	TMST( BUS,TNOW,2,NSET )
	BUS = 0.0
	RETURN
9	CALL 	RMOVE( MFE(2),2,NSET )
C
C	--- Compute waiting time of customer and collect statistics
C	    on waiting time. Put customer in service by scheduling
C	    and end of service event for the customer.
C
	WT = TNOW - ATRIB(3)
	CALL	COLCT( WT,2,NSET )
	CALL	DRAND( ISEED,RNUM )
	ATRIB( 1 ) = TNOW - PARAM(2,1) * ALOG( RNUM )
	ATRIB( 2 ) = 2.0
	CALL	FILEM( 1,NSET )
	RETURN
	END
        SUBROUTINE      EVNTS( IX,NSET )
C////////////////////////////////////////////////////////////////
C/                                                              /
C/      Program-id.     EVNTS                                   /
C/      Date-written.   21th,Jan,1984                           /
C/      File-name.      EVNTS3.FOR                              /
C/      Remarks.        Subroutine EVNTS page 121               /
C/                      Event code 1 siginifires an arrival     /
C/                      event; event code 2 signifires an end   /
C/                      of service event;                       /
C/                      and event code 3 signifires an end of   /
C/                      simulation event.                       /
C/			User subroutine for Example-3.		/
C/                                                              /
C////////////////////////////////////////////////////////////////
C       //FOR
C       *ONE WORD INTEGERS
C       *LIST SOURCE PROGRAM
        INTEGER*4       NSET( 6,1 )
        COMMON /C1/ID,IM,INIT,JEVNT,JMNIT,MFA,MSTOP,MX,MXC,NCLCT,NHIST,
     $  NOQ,NORPT,NOT,NPRMS,NRUN,NRUNS,NSTAT,OUT,SCALE,ISEED,TNOW,
     $  TBEG,TFIN,MXX,NPRNT,NCRDR,NEP,VNQ(4)
        COMMON /C2/ATRIB(4),ENQ(4),INN(4),JCELS(5,22),KRANK(4),MAXNQ(4),
     $  MFE(4),MLC(4),MLE(4),NCELS(5),NQ(4),PARAM(20,4),QTIME(4),
     $  SSUMA(10,5),SUMA(10,5),NAME(6),NPROJ,MON,NDAY,NYR,JCLR
	COMMON /C3/ XISYS,BUS
C
        GO TO (1,2,3,4),IX
1       CALL    ARRVL( NSET )
        RETURN
2       CALL    ENDSV( NSET )
        RETURN
3       CALL    ENDSM( NSET )
        RETURN
4       CALL    STTUP( NSET )
        RETURN
        END
        SUBROUTINE      OTPUT( NSET )
C////////////////////////////////////////////////////////////////
C/                                                              /
C/      Program-id.     OTPUT                                   /
C/      Date-written.   23th,Jan,1984                           /
C/      File-name.      OTPUT3.FOR                              /
C/      Remarks.        Subroutine OTPUT.FOR page 130           /
C/                      Written by a programmer to perform      /
C/                      calculations and provide additional     /
C/                      output at the end of a simulation run.  /
C/			This is for Example-3 version.		/
C/                                                              /
C////////////////////////////////////////////////////////////////
C       //FOR
C       *ONE WORD INTEGERS
C       *LIST SOURCE PROGRAM
        INTEGER*4       NSET( 6,1 )
        COMMON /C1/ID,IM,INIT,JEVNT,JMNIT,MFA,MSTOP,MX,MXC,NCLCT,NHIST,
     $  NOQ,NORPT,NOT,NPRMS,NRUN,NRUNS,NSTAT,OUT,SCALE,ISEED,TNOW,
     $  TBEG,TFIN,MXX,NPRNT,NCRDR,NEP,VNQ(4)
        COMMON /C2/ATRIB(4),ENQ(4),INN(4),JCELS(5,22),KRANK(4),MAXNQ(4),
     $  MFE(4),MLC(4),MLE(4),NCELS(5),NQ(4),PARAM(20,4),QTIME(4),
     $  SSUMA(10,5),SUMA(10,5),NAME(6),NPROJ,MON,NDAY,NYR,JCLR
	COMMON /C3/ XISYS,BUS
C
C       --- Compute theoretical and simulation values of performance
C           measures for the queuing system.
C
        ETISS = SUMA(1,1) / SUMA(1,3)
        EIDTS = ( SSUMA(2,1) - SSUMA(2,2) ) / ( SUMA(1,3) - 1.0 )
        EWTS = SUMA(2,1) / SUMA(2,3)
        EIDTC = PARAM(1,1) - PARAM(2,1)
	EWTC = ( 1.0/PARAM(1,1) ) / ( (1.0/PARAM(2,1) ) * ( 1.0/
     $  PARAM(2,1) - 1.0/PARAM(1,1) ) )
        ETISC = 1.0/( 1.0/PARAM(2,1) - 1.0/PARAM(1,1) )
        YA = ETISS / ( SSUMA(1,2) / SSUMA(1,1) )
        YS = ETISS - EWTS
        WRITE( NPRNT,85 )
85      FORMAT(/36X,'Simulated Value',4X,'Theoretical Value'/)
        WRITE( NPRNT,90 ) EIDTS,EIDTC
90      FORMAT(10X,'Expected idle time',11X,F8.3,12X,F8.3 )
        WRITE( NPRNT,95 ) EWTS,EWTC
95      FORMAT(10X,'Expected waiting time',8X,F8.3,12X,F8.3 )
        WRITE( NPRNT,96 ) ETISS,ETISC
96      FORMAT(10X,'Expected time in system',6X,F8.3,12X,F8.3 )
        WRITE( NPRNT,97 ) YA,PARAM(1,1)
97      FORMAT(10X,'Expected arrival time',8X,F8.3,12X,F8.3 )
        WRITE( NPRNT,98 ) YS,PARAM(2,1)
98      FORMAT(10X,'Expected service time',8X,F8.3,12X,F8.3 )
        RETURN
        END
        SUBROUTINE      STTUP( NSET )
C////////////////////////////////////////////////////////////////
C/                                                              /
C/      Program-id.     STTUP                                   /
C/      Date-written.   21th,Jan,1984                           /
C/      File-name.      STTUP.FOR                               /
C/      Remarks.        Subroutine STTUP.FOR page 139           /
C/                      Subroutine STTUP for Reinitializing     /
C/                      values for multiple runs.               /
C/			User subroutine for Example-3		/
C/                                                              /
C////////////////////////////////////////////////////////////////
C       //FOR
C       *ONE WORD INTEGER
C       *LIST SOURCE PROGRAM
        INTEGER*4       NSET( 6,1 )
        COMMON /C1/ID,IM,INIT,JEVNT,JMNIT,MFA,MSTOP,MX,MXC,NCLCT,NHIST,
     $  NOQ,NORPT,NOT,NPRMS,NRUN,NRUNS,NSTAT,OUT,SCALE,ISEED,TNOW,
     $  TBEG,TFIN,MXX,NPRNT,NCRDR,NEP,VNQ(4)
        COMMON /C2/ATRIB(4),ENQ(4),INN(4),JCELS(5,22),KRANK(4),MAXNQ(4),
     $  MFE(4),MLC(4),MLE(4),NCELS(5),NQ(4),PARAM(20,4),QTIME(4),
     $  SSUMA(10,5),SUMA(10,5),NAME(6),NPROJ,MON,NDAY,NYR,JCLR
C
	COMMON /C3/ XISYS,BUS
C       
C       --- Comment cards for starter subroutine
C           Initialize statiscal storage areas for each fiule used
C           in the simulation. This is required since the files are
C           not initilized by subroutine SET
C
        DO 17 K=1,NOQ
        ENQ( K ) = 0.0
        VNQ( K ) = 0.0
        MAXNQ( K ) = NQ( K )
17      QTIME( K ) = TNOW
C
C       --- Test to see if the event file is empty. If event file is 
C           empty start up events are to be used. If event file is not
C           empty read in the number in the system and the status
C           of the server.
C
        IF( NQ(1) ) 19,19,25
25      READ( NCRDR,91 ) XISYS,BUS
91      FORMAT( 2F5.0 )
        WRITE( 1,291 ) XISYS,BUS
291     FORMAT( 1H ,2F5.0 )
8       RETURN
C
C       --- If start events is to be used the number in the system is 
C           equal to the number of starter events minus the end of 
C           simulation event and the arrival event.
C           If monitor events are used these must also be subtracted
C
19      XISYS = NQ(3) - 2
C
C       --- If number in system is greater than zero the server
C           status should be set to busy. Let nine equal the 
C           number of initial entries.
C
        BUS = 1.0
        IF( XISYS ) 18,18,7
18      BUS = 0.0
7       NINE = NQ(3)
        NC = 1
11      CALL    RMOVE( MFE(3),3,NSET )
        J = 1
        IF( ATRIB(2) - 0.1 ) 20,20,21
20      J = 2
21      CALL    FILEM( J,NSET )
        CALL    FILEM( 3,NSET )
        IF( NC - NINE ) 9,8,8
9       NC = NC + 1
        GO TO 11
        END
