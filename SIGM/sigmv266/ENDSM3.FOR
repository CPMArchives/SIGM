        SUBROUTINE      ENDSM(NSET)
C////////////////////////////////////////////////////////////////
C/                                                              /
C/      Program-id.     ENDSM                                   /
C/	Date-written.	Jan. 23rd 1984				/
C/      File-name.      ENDSM3.FOR                              /
C/	Remaeks.	User defined subroutine, the completion /
C/			of the simulation at a time specified   /
C/			by the programmer.			/
C/			page 128.				/
C/			This is the version for Example 3.	/
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
	COMMON /C3/ XISYS,BUS
C
   20	IF (NQ(1)) 7,8,9
    7	CALL	ERROR(3,NSET)
C
C	--- Update statistics on number in system and status of server 
C	    to end of simulation time. Set control variable to stop
C	    simulation and to yield final report.
C
    8	CALL	TMST(XISYS,TNOW,1,NSET)
	CALL	TMST(BUS,TNOW,2,NSET)
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
    9	CALL	RMOVE(MFE(1),1,NSET)
	TNOW = ATRIB(1)
	IF (ATRIB(2) - 2.0) 20,21,20
   21	CALL	ENDSV(NSET)
					GO TO 20
	END
