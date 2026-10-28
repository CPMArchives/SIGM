        SUBROUTINE      FILEM(JQ,NSET)
C////////////////////////////////////////////////////////////////
C/                                                              /
C/      Program-id.     FILEM                                   /
C/      Date-written.   Jan. 16th 1984                          /
C/      File-name.      FILEM.FOR                               /
C/      Remarks.        Subroutine FILEM.FOR page 68.           /
C/                      FILEM is called to file an entry in     /
C/                      file JQ of the array NSET.              /
C/                                                              /
C////////////////////////////////////////////////////////////////
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
C
C       --- Test to see if there is an avilable column for storage.
C
        IF (MFA .GT. ID) GO TO 10
        WRITE(NPRNT,100)
  100     FORMAT(//24H Overlap Set Given Below/)
        CALL    ERROR(87,NSET)
C
C       --- Put attribute value in file
C
   10 DO 1 I=1,IM
        DEL = 0.000001
        IF (ATRIB(I).GE.0) GO TO 20
        DEL = -0.000001
   20   NSET(I,MFA) = SCALE * (ATRIB(I) + DEL)
   30 CONTINUE
C
C       --- Call SET to put new entry in proper place in NSET
C
        CALL SET (JQ,NSET)
        RETURN
        END
