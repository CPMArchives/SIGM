        SUBROUTINE      ARRVL(NSET)
C////////////////////////////////////////////////////////////////
C/                                                              /
C/      Program-id.     ARRVL                                   /
C/      Date-written.   Jan. 23rd 1984                          /
C/      File-name.      ARRVL3.FOR                              /
C/      Remarks.        Subroutine ARRVL page 123               /
C/                      The arrival of items to the system is   /
C/                      described in terms of the time between  /
C/                      the arrivals, every arrival event must  /
C/                      cause the next arrival event to occur.  /
C/			This is for Example-3 version.		/
C/                                                              /
C////////////////////////////////////////////////////////////////
C
C	* Default size of INTEGR = 2 bytes in F80
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
C       --- Since ARRVL is an endogenous event schedule the next 
C           arrival. At TNOW plus number drawn from an exponential
C           distribution. The arrival time is stored in ATRIB(1).
C           The event code for an ARRVL is 1. Set ATRIB(2)
C           equal to 1.
C
        CALL    DRAND(ISEED,RNUM)
        ATRIB(1) = TNOW - PARAM(1,1) * ALOG(RNUM)
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
        ATRIB(1) = TNOW - PARAM(2,1) * ALOG(RNUM)
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
