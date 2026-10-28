        SUBROUTINE      ENDSV(NSET)
C////////////////////////////////////////////////////////////////
C/                                                              /
C/      Program-id.     ENDSV                                   /
C/      Date-written.   Jan. 26th 1984                          /
C/      File-name.      ENDSV4.FOR                              /
C/      Remarks.        Subroutine ENDSV page 151               /
C/                      In ENDSV (END of SerVice) it is first   /
C/                      necessary to collect statiscal infor-   /
C/                      mation about the item completing        /
C/                      processing.                             /
C/                      This is the version for Examle 4. 	/
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
        COMMON /C3/ XL,XMU(2),XBUZ(2),XISYS,CBALK,TCUST,TLD
C
C       --- Service is completed. Decrement number in system.
C           Collect ststistics on customer time in system and 
C           time between departure.
C
        CALL    TMST(XISYS,TNOW,3,NSET)
        XISYS = XISYS - 1.0
        TISYS = TNOW - ATRIB(3)
        CALL    COLCT(TISYS,1,NSET)
        TBD = TNOW - TLD
        TLD = TNOW
        CALL    COLCT(TBD,2,NSET)
C
C       --- J = number of queue of server with completed service.
C           M = server number, K = number of queue of the other server
C
        J = JEVNT
        M = J - 1
        IF (J - 2) 15,2,3
    2   K = 3
 				        GO TO 1
    3   K = 2
    1   IF (NQ(J)) 15,4,6
    4   IF (NQ(K)) 15,5,9
    5   CALL    TMST(XBUZ(M),TNOW,M,NSET)
        XBUZ(M) = 0.0
        RETURN
C
C       --- Put first customer of queue J in service
C
6       CALL    RMOVE(MFE(J),J,NSET)
C
C       --- Cause end of service event
C
   10   CALL    DRAND(ISEED,RNUM)
        ATRIB(1) = TNOW - XMU(M) * ALOG(RNUM)
        ATRIB(2) = J
        CALL    FILEM(1,NSET)
C
C       --- Test difference in queue length to determine if 
C           jockeying to take place
C
        IF (NQ(K) - NQ(J) - 2) 7,8,8
    7   RETURN
    8   CALL    RMOVE(MLE(K),K,NSET)
        ATRIB(4) = TNOW
        CALL    FILEM(J,NSET)
        RETURN
C
C       --- Since queue of server M is empty, last customer in queue
C           of other server is served by M
C
    9   CALL    RMOVE(MLE(K),K,NSET)
        				GO TO 10
   15   CALL    ERROR(86,NSET)
        CALL    EXIT
        END
