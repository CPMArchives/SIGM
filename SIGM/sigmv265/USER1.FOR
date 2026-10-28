C	[USER1.FOR]
C
        PROGRAM EXA1
C////////////////////////////////////////////////////////////////
C/                                                              /
C/      Program-id.     Main of Example 1 for F80 		/
C/      Date-written.   Jan. 16th 1984                          /
C/      File-name.      EXA1.FOR                                /
C/      Remarks.        A single-channel queueing situation.    /
C/                      Simulation with GASP page 118.          /
C/                                                              /
C////////////////////////////////////////////////////////////////
C
C	* Default size of INTEGER = 2 bytes
C       
        INTEGER*1       FLNAME(11)
        INTEGER*4       NSET(6,25)
C
      COMMON /C1/ ID,IM,INIT,JEVNT,JMNIT,MFA,MSTOP,MX,MXC,NCLCT,NHIST,
     1            NOQ,NORPT,NOT,NPRMS,NRUN,NRUNS,NSTAT,OUT,SCALE,ISEED,
     2            TNOW,TBEG,TFIN,MXX,NPRNT,NCRDR,NEP,VNQ(4)
C
      COMMON /C2/ ATRIB(4),ENQ(4),INN(4),JCELS(5,22),KRANK(4),MAXNQ(4),
     1            MFE(4),MLC(4),MLE(4),NCELS(5),NQ(4),PARAM(20,4),
     2            QTIME(4),SSUMA(10,5),SUMA(10,5),NAME(6),NPROJ,MON,
     3		  NDAY,NYR,JCLR
C
      COMMON /C3/ XISYS,BUS,XL,XMU
C
        DATA    FLNAME(1),FLNAME(2),FLNAME(3),FLNAME(4),FLNAME(5),
     1  FLNAME(6),FLNAME(7),FLNAME(8),FLNAME(9),FLNAME(10),FLNAME(11)
     2  /'G','A','S','P',' ',' ',' ',' ','D','A','T'/
C
C       --- Set NCRDR equal to the Floppy drive number and
C           NPRNT to the printer number.
C
        NCRDR = 6
        IDRIVE = 0
C
        WRITE(1,90)
   90   FORMAT(1H0,'Output GASP data file to CRT(3) or Printer(2)?'
     1         /1H ,'Output Device number 3 or 2 : ')
        READ(1,95) NPRNT
   95      FORMAT(I1)
        WRITE(1,100)
  100     FORMAT(1H0,'Input GASP data file name (max 8 characters): ')
        READ(1,200) (FLNAME(I),I=1,8)
  200     FORMAT(8A1)
        WRITE(3,210) (FLNAME(I),I=1,11)
  210     FORMAT(1H ,'Input GASP data file name: ',11A1)
        CALL    OPEN(NCRDR,FLNAME,IDRIVE)
C
        XISYS = 1.
        BUS = 1.
        XL = 10.
        XMU = 6.
        CALL    GASP(NSET)
        CALL    EXIT
        END
C
        SUBROUTINE      EVNTS(IX,NSET)
C////////////////////////////////////////////////////////////////
C/                                                              /
C/      Program-id.     EVNTS                                   /
C/      Date-written.   Jan. 16th 1984                          /
C/      File-name.      EVNTS.FOR                               /
C/      Remarks.        Subroutine EVNTS (P. 121)               /
C/                      Event code 1 siginifies an arrival      /
C/                      event; event code 2 signifies an end    /
C/                      of service event;                       /
C/                      and event code 3 signifies an end of    /
C/                      simulation event.                       /
C/                                                              /
C////////////////////////////////////////////////////////////////
C
C	* Default size of INTEGER = 2 bytes
C       
        INTEGER*1       FLNAME(11)
        INTEGER*4       NSET(6,1)
C
      COMMON /C1/ ID,IM,INIT,JEVNT,JMNIT,MFA,MSTOP,MX,MXC,NCLCT,NHIST,
     1            NOQ,NORPT,NOT,NPRMS,NRUN,NRUNS,NSTAT,OUT,SCALE,ISEED,
     2            TNOW,TBEG,TFIN,MXX,NPRNT,NCRDR,NEP,VNQ(4)
C
      COMMON /C2/ ATRIB(4),ENQ(4),INN(4),JCELS(5,22),KRANK(4),MAXNQ(4),
     1            MFE(4),MLC(4),MLE(4),NCELS(5),NQ(4),PARAM(20,4),
     2            QTIME(4),SSUMA(10,5),SUMA(10,5),NAME(6),NPROJ,MON,
     3		  NDAY,NYR,JCLR
C
      COMMON /C3/ XISYS,BUS,XL,XMU
C
        GO TO (1,2,3),IX
    1   CALL    ARRVL(NSET)
        RETURN
    2   CALL    ENDSV(NSET)
        RETURN
    3   CALL    ENDSM(NSET)
        RETURN
        END
C
        SUBROUTINE      ARRVL(NSET)
C////////////////////////////////////////////////////////////////
C/                                                              /
C/      Program-id.     ARRVL                                   /
C/      Date-written.   Jan. 16th 1984                          /
C/      File-name.      ARRVL.FOR                               /
C/      Remarks.        Subroutine ARRVL page 123               /
C/                      The arrival of items to the system is   /
C/                      described in terms of the time between  /
C/                      the arrivals, every arrival event must  /
C/                      cause the next arrival event to occur.  /
C/                                                              /
C////////////////////////////////////////////////////////////////
C
C	* Default size of INTEGER = 2 bytes
C       
        INTEGER*1       FLNAME(11)
        INTEGER*4       NSET(6,1)
C
      COMMON /C1/ ID,IM,INIT,JEVNT,JMNIT,MFA,MSTOP,MX,MXC,NCLCT,NHIST,
     1            NOQ,NORPT,NOT,NPRMS,NRUN,NRUNS,NSTAT,OUT,SCALE,ISEED,
     2            TNOW,TBEG,TFIN,MXX,NPRNT,NCRDR,NEP,VNQ(4)
C
      COMMON /C2/ ATRIB(4),ENQ(4),INN(4),JCELS(5,22),KRANK(4),MAXNQ(4),
     1            MFE(4),MLC(4),MLE(4),NCELS(5),NQ(4),PARAM(20,4),
     2            QTIME(4),SSUMA(10,5),SUMA(10,5),NAME(6),NPROJ,MON,
     3		  NDAY,NYR,JCLR
C
      COMMON /C3/ XISYS,BUS,XL,XMU
C
C       --- Since ARRVL is an endogenous event schedule the next 
C           arrival. At TNOW plus number drawn from an exponential
C           distribution. The arrival time is stored in ATRIB(1).
C           The event code for an ARRVL is 1. Set ATRIB(2)
C           equal to 1.
C
        CALL    DRAND(ISEED,RNUM)
        ATRIB(1) = TNOW - XL * ALOG(RNUM)
        ATRIB(2) = 1.0
        CALL FILEM(1,NSET)
C
C       --- Collect the statistics on the number in the system since
C           an arrival causes number in the system to change.
C
        CALL    TMST(XISYS,TNOW,1,NSET)
        IF (XISYS) 7,8,9
    7   CALL    ERROR(31,NSET)
        RETURN
C
C       --- Increment the number in the system. Since the number in
C           the system was zero the server was not busy.
C           The server status will change due to the new arrival
C           therefore statistics on the time the server was busy
C           must be collected.
C
    8   XISYS = XISYS + 1.0
        CALL    TMST(BUS,TNOW,2,NSET)
C
C       --- Change the status of the server to busy. Collect 
C           statistics on the waitting time of current arrival which
C           is zero since the server was not busy at his time of 
C           arrival.
C
        BUS = 1.0
        CALL    COLCT(0.0,2,NSET)
C
C       --- Since the new arrival goes directly into service cause an 
C           end of service event. Set ATRIB(2) equal to indicate an end
C           of service event. Set ATRIB(3) equal to TNOW the arrival
C           time of the customer.
C
        CALL    DRAND(ISEED,RNUM)
        ATRIB(1) = TNOW - XMU * ALOG(RNUM)
        ATRIB(2) = 2.0
        ATRIB(3) = TNOW
        CALL    FILEM(1,NSET)
        RETURN
C
C       --- Increment the number in the system.
C
    9   XISYS = XISYS + 1.0
C
C       --- Put new arrival in the queue waiting for the server to 
C           become free. Set ATRIB(3) equal to the arrival time of
C           the customer.
C
        ATRIB(3) = TNOW
        CALL    FILEM(2,NSET)
        RETURN
        END
C
        SUBROUTINE      ENDSM(NSET)
C////////////////////////////////////////////////////////////////
C/                                                              /
C/      Program-id.     ENDSM                                   /
C/      Date-written.   Jan. 16th 1984                          /
C/      File-name.      ENDSM.FOR                               /
C/      Remaeks.        User defined subroutine, the completion /
C/                      of the simulation at a time specified   /
C/                      by the programmer.                      /
C/                      page 128.                               /
C/                                                              /
C////////////////////////////////////////////////////////////////
C
C	* Default size of INTEGER = 2 bytes
C       
        INTEGER*1       FLNAME(11)
        INTEGER*4       NSET(6,1)
C
      COMMON /C1/ ID,IM,INIT,JEVNT,JMNIT,MFA,MSTOP,MX,MXC,NCLCT,NHIST,
     1            NOQ,NORPT,NOT,NPRMS,NRUN,NRUNS,NSTAT,OUT,SCALE,ISEED,
     2            TNOW,TBEG,TFIN,MXX,NPRNT,NCRDR,NEP,VNQ(4)
C
      COMMON /C2/ ATRIB(4),ENQ(4),INN(4),JCELS(5,22),KRANK(4),MAXNQ(4),
     1            MFE(4),MLC(4),MLE(4),NCELS(5),NQ(4),PARAM(20,4),
     2            QTIME(4),SSUMA(10,5),SUMA(10,5),NAME(6),NPROJ,MON,
     3		  NDAY,NYR,JCLR
C
      COMMON /C3/ XISYS,BUS,XL,XMU
C
   20   IF (NQ(1)) 7,8,9
    7   CALL    ERROR(3,NSET)
C
C       --- Update statistics on number in system and status of server 
C           to end of simulation time. Set control variable to stop
C           simulation and to yield final report.
C
    8   CALL    TMST(XISYS,TNOW,1,NSET)
        CALL    TMST(BUS,TNOW,2,NSET)
        MSTOP = -1
        NORPT = 0
        RETURN
C
C       --- Remove all events from event file so that all customers
C           arriving before end of simulation time are included in
C           simulation statistics. Only end of service event need be 
C           processed. If items are in the queue of the server they
C           will be removed in the end of service event where another
C           end of service event will be created.
C
    9   CALL    RMOVE(MFE(1),1,NSET)
        TNOW = ATRIB(1)
        IF (ATRIB(2) - 2.0) 20,21,20
   21   CALL    ENDSV(NSET)
        				GO TO 20
        END
C
        SUBROUTINE      ENDSV(NSET)
C////////////////////////////////////////////////////////////////
C/                                                              /
C/      Program-id.     ENDSV                                   /
C/      Date-written.   Jan. 16th 1984                          /
C/      File-name.      ENDSV.FOR                               /
C/      Remarks.        Subroutine ENDSV page 126               /
C/                      In ENDSV(End_of_Service) it is first  /
C/                      necessary to collect statiscal infor-   /
C/                      mation about the item completing        /
C/                      processing.                             /
C/                                                              /
C////////////////////////////////////////////////////////////////
C
C	* Default size of INTEGER = 2 bytes
C       
        INTEGER*1       FLNAME(11)
        INTEGER*4       NSET(6,1)
C
      COMMON /C1/ ID,IM,INIT,JEVNT,JMNIT,MFA,MSTOP,MX,MXC,NCLCT,NHIST,
     1            NOQ,NORPT,NOT,NPRMS,NRUN,NRUNS,NSTAT,OUT,SCALE,ISEED,
     2            TNOW,TBEG,TFIN,MXX,NPRNT,NCRDR,NEP,VNQ(4)
C
      COMMON /C2/ ATRIB(4),ENQ(4),INN(4),JCELS(5,22),KRANK(4),MAXNQ(4),
     1            MFE(4),MLC(4),MLE(4),NCELS(5),NQ(4),PARAM(20,4),
     2            QTIME(4),SSUMA(10,5),SUMA(10,5),NAME(6),NPROJ,MON,
     3		  NDAY,NYR,JCLR
C
      COMMON /C3/ XISYS,BUS,XL,XMU
C
C       --- Compute time in system equal to current time minus arrival
C           time of customer finishing service. Cmpute statistics on
C           in system.
C
        TISYS = TNOW - ATRIB(3)
        CALL    COLCT(TISYS,1,NSET)
        CALL    HISTO(TISYS,2.0,1.0,1)
C
C       --- Since a customer will depart from the system due to the
C           end of service collect ststistics on number in system
C           and decrement the number in the system by one.
C
        CALL    TMST(XISYS,TNOW,1,NSET)
        XISYS = XISYS - 1.0
C
C       --- Test to see if customer are waiting for service. If none
C           collect statistics on the busy time of the server and set
C           his status to idle by making bus equal zero.
C           If customer are waiting for service remove first customer
C           from the queue of the server which is file two.
C
        IF (NQ(2)) 7,8,9
    7   CALL    ERROR(41,NSET)
        RETURN
    8   CALL    TMST(BUS,TNOW,2,NSET)
        BUS = 0.0
        RETURN
    9   CALL    RMOVE(MFE(2),2,NSET)
C
C       --- Compute waiting time of customer and collect statistics
C           on waiting time. Put customer in service by scheduling
C           and end of service event for the customer.
C
        WT = TNOW - ATRIB(3)
        CALL    COLCT(WT,2,NSET)
        CALL    DRAND(ISEED,RNUM)
        ATRIB(1) = TNOW - XMU * ALOG(RNUM)
        ATRIB(2) = 2.0
        CALL    FILEM(1,NSET)
        RETURN
        END
C
        SUBROUTINE      OTPUT(NSET)
C////////////////////////////////////////////////////////////////
C/                                                              /
C/      Program-id.     OTPUT                                   /
C/      Date-written.   Jan. 16th 1984                          /
C/      File-name.      OTPUT.FOR                               /
C/      Remarks.        Subroutine OTPUT.FOR page 130           /
C/                      Written by a programmer to perform      /
C/                      calculations and provide additional     /
C/                      output at the end of a simulation run.  /
C/                                                              /
C////////////////////////////////////////////////////////////////
C
C	* Default size of INTEGER = 2 bytes
C       
        INTEGER*1       FLNAME(11)
        INTEGER*4       NSET(6,1)
C
      COMMON /C1/ ID,IM,INIT,JEVNT,JMNIT,MFA,MSTOP,MX,MXC,NCLCT,NHIST,
     1            NOQ,NORPT,NOT,NPRMS,NRUN,NRUNS,NSTAT,OUT,SCALE,ISEED,
     2            TNOW,TBEG,TFIN,MXX,NPRNT,NCRDR,NEP,VNQ(4)
C
      COMMON /C2/ ATRIB(4),ENQ(4),INN(4),JCELS(5,22),KRANK(4),MAXNQ(4),
     1            MFE(4),MLC(4),MLE(4),NCELS(5),NQ(4),PARAM(20,4),
     2            QTIME(4),SSUMA(10,5),SUMA(10,5),NAME(6),NPROJ,MON,
     3		  NDAY,NYR,JCLR
C
      COMMON /C3/ XISYS,BUS,XL,XMU
C
C       --- Compute theoretical and simulation values of performance
C           measures for the queuing system.
C
        ETISS = SUMA(1,1) / SUMA(1,3)
        EIDTS = (SSUMA(2,1) - SSUMA(2,2)) / (SUMA(1,3) - 1.0)
        EWTS = SUMA(2,1) / SUMA(2,3)
        EIDTC = XL - XMU
        EWTC = (1.0 / XL) / ((1.0 / XMU) * (1.0/XMU - 1.0/XL))
        ETISC = 1.0/(1.0/XMU - 1.0/XL)
        YA = ETISS / (SSUMA(1,2) / SSUMA(1,1))
        YS = ETISS - EWTS
        WRITE(NPRNT,85)
   85      FORMAT(/36X,'Simulated Value',4X,'Theoretical Value'/)
        WRITE(NPRNT,90) EIDTS,EIDTC
   90      FORMAT(10X,'Expected idle time',11X,F8.3,12X,F8.3)
        WRITE(NPRNT,95) EWTS,EWTC
   95      FORMAT(10X,'Expected waiting time',8X,F8.3,12X,F8.3)
        WRITE(NPRNT,96) ETISS,ETISC
   96      FORMAT(10X,'Expected time in system',6X,F8.3,12X,F8.3)
        WRITE(NPRNT,97) YA,XL
   97      FORMAT(10X,'Expected arrival time',8X,F8.3,12X,F8.3)
        WRITE(NPRNT,98) YS,XMU
   98      FORMAT(10X,'Expected service time',8X,F8.3,12X,F8.3)
        RETURN
        END
