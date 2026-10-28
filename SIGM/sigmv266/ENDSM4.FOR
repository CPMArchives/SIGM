        SUBROUTINE      ENDSM(NSET)
C////////////////////////////////////////////////////////////////
C/                                                              /
C/      Program-id.     ENDSM                                   /
C/      Date-written.   Jan. 26th 1984                          /
C/      File-name.      ENDSM4.FOR                              /
C/      Remaeks.        User defined subroutine, the completion /
C/                      of the simulation at a time specified   /
C/                      by the programmer. (p.152)              /
C/                      This is the version for Example 4.      /
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
        COMMON /C3/XL,XMU(2),XBUZ(2),XISYS,CBALK,TCUST,TLD
C
C       --- Update time ststistics for last time segment
C
        CALL    TMST(XBUZ(1),TNOW,1,NSET)
        CALL    TMST(XBUZ(2),TNOW,2,NSET)
        CALL    TMST(XISYS,TNOW,3,NSET)
        MSTOP = -1
        NORPT = 0
        RETURN
        END
