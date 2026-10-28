        SUBROUTINE      EVNTS(IX,NSET)
C////////////////////////////////////////////////////////////////
C/                                                              /
C/      Program-id.     EVNTS                                   /
C/      Date-written.   Jan. 24th 1984                          /
C/      File-name.      EVNTS4.FOR                              /
C/      Remarks.        Subroutine EVNTS page 146               /
C/                      Event code 1 siginifires an arrival     /
C/                      event; event code 2 signifires an end   /
C/                      of service event;                       /
C/                      and event code 3 signifires an end of   /
C/                      simulation event.                       /
C/                      User subroutine for Example-4.          /
C/                                                              /
C////////////////////////////////////////////////////////////////
C
C	* ONE WORD INTEGERS EXCEPT NSET
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
	GO TO (1,2,2,3),IX
    1       CALL    ARRVL(NSET)
        RETURN
    2       CALL    ENDSV(NSET)
        RETURN
    3       CALL    ENDSM(NSET)
        RETURN
        END
