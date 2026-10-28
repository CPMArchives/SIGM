        SUBROUTINE      RMOVE(KCOL,JQ,NSET)
C////////////////////////////////////////////////////////////////
C/                                                              /
C/      Program-id.     RMOVE                                   /
C/      Date-written.   Jan. 16th 1984                          /
C/      File-name.      RMOVE.FOR                               /
C/      Remarks.        Subroutine RMOVE.FOR page 69.           /
C/                      Subroutine RMOVE is called to remove    /
C/                      an entry from file JQ of the array      /
C/                      NSET.                                   /
C/                                                              /
C////////////////////////////////////////////////////////////////
C
C	* Default size of INTEGER = 2 bytes
C       
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
        IF (KCOL) 16,16,2
   16   CALL    ERROR(97,NSET)
    2   MLC(JQ) = KCOL
C
C       --- Put values of KCOL in attrib
C
      DO 3 I=1,IM
        ATRIB(I) = NSET(I,KCOL)
        ATRIB(I) = ATRIB(I)/SCALE
    3 CONTINUE
C
C       --- Set OUT=1 and call set to remove entry from NSET
C
        OUT = 1.0
        CALL    SET(JQ,NSET)
        RETURN
        END
