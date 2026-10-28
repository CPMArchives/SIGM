        SUBROUTINE      ARRVL(NSET)
C////////////////////////////////////////////////////////////////
C/                                                              /
C/      Program-id.     ARRVL                                   /
C/      Date-written.   Jan. 24th 1984				/
C/      File-name.      ARRVL4.FOR                              /
C/      Remarks.        Subroutine ARRVL page 148               /
C/                      The arrival of items to the system is   /
C/                      described in terms of the time between  /
C/                      the arrivals, every arrival event must  /
C/                      cause the next arrival event to occur.  /
C/                      This is the version for Example 4.	/
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
C       --- Cause next arrival to occur
C
        CALL    DRAND(ISEED,RNUM)
        ATRIB(1) = TNOW - XL * ALOG(RNUM)
        ATRIB(3) = ATRIB(1)
        ATRIB(2) = 1.0
        CALL    FILEM(1,NSET)
C
C       --- Increment total customers arriving
C
        TCUST = TCUST + 1.0
C
C       --- Test to see if system in full
C
        IF (XISYS - 8.0) 2,1,1
C
C       --- System in full. increment number of balkers
C
    1   CBALK = CBALK + 1.0
        RETURN
    2   CALL    TMST(XISYS,TNOW,3,NSET)
C       --- Increment number in system
C
        XISYS = XISYS + 1.0
C
C       ---Set arrival time of this customer to TNOW
C
        ATRIB(3) = TNOW
C
C       --- Test to see if either server is free
C
        IF (XBUZ(1)) 15,4,3
    3   IF (XBUZ(2)) 15,5,7
    4   J = 1
        					GO TO 6
    5   J = 2
C
C       --- Assign arriving customer to free server.
C
    6   CALL    DRAND(ISEED,RNUM)
        ATRIB(1) = TNOW - XMU(J) * ALOG(RNUM)
        ATRIB(2) = J + 1
        CALL    FILEM(1,NSET)
        CALL    TMST(XBUZ(J),TNOW,J,NSET)
C
C       --- Set assigned server to busy status
C
        XBUZ(J) = 1.0
        RETURN
C
C       ---Both server are busy. Put customer in shorter queue.
C
    7   ATRIB(4) = TNOW
        IF (NQ(2) - NQ(3)) 8,8,9
    8   CALL    FILEM(2,NSET)
        				GO TO 10
    9   CALL    FILEM(3,NSET)
   10   RETURN
   15   CALL    ERROR(87,NSET)
        CALL    EXIT
        END
