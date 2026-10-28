        SUBROUTINE      STTUP(NSET )
C////////////////////////////////////////////////////////////////
C/                                                              /
C/      Program-id.     STTUP                                   /
C/      Date-written.   Jan. 21st 1984                          /
C/      File-name.      STTUP.FOR                               /
C/      Remarks.        Subroutine STTUP.FOR page 139           /
C/                      Subroutine STTUP for Reinitializing     /
C/                      values for multiple runs.               /
C/			User subroutine for Example-3		/
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
C       
C
	COMMON /C3/ XISYS,BUS
C       
C       --- Comment cards for starter subroutine
C           Initialize statiscal storage areas for each fiule used
C           in the simulation. This is required since the files are
C           not initilized by subroutine SET
C
      DO 17 K=1,NOQ
        ENQ(K ) = 0.0
        VNQ(K ) = 0.0
        MAXNQ(K ) = NQ(K )
        QTIME(K ) = TNOW
   17 CONTINUE
C
C       --- Test to see if the event file is empty. If event file is 
C           empty start up events are to be used. If event file is not
C           empty read in the number in the system and the status
C           of the server.
C
        IF(NQ(1) ) 19,19,25
   25   READ(NCRDR,91 ) XISYS,BUS
   91     FORMAT(2F5.0 )
        WRITE(1,291 ) XISYS,BUS
  291     FORMAT(1H ,2F5.0 )
    8   RETURN
C
C       --- If start events is to be used the number in the system is 
C           equal to the number of starter events minus the end of 
C           simulation event and the arrival event.
C           If monitor events are used these must also be subtracted
C
   19   XISYS = NQ(3) - 2
C
C       --- If number in system is greater than zero the server
C           status should be set to busy. Let nine equal the 
C           number of initial entries.
C
        BUS = 1.0
        IF(XISYS ) 18,18,7
   18   BUS = 0.0
    7   NINE = NQ(3)
        NC = 1
   11   CALL    RMOVE(MFE(3),3,NSET )
        J = 1
        IF(ATRIB(2) - 0.1 ) 20,20,21
   20   J = 2
   21   CALL    FILEM(J,NSET )
        CALL    FILEM(3,NSET )
        IF(NC - NINE ) 9,8,8
    9   NC = NC + 1
        				GO TO 11
        END
