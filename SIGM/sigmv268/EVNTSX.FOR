	SUBROUTINE	EVNTS( I,NSET,QSET )
C////////////////////////////////////////////////////////////////
C/								/
C/	Program-id.	EVNTS.FOR				/
C/	Date-written.	11th,Feb,1984				/
C/	Remarks.	The user defined events routine for 	/
C/			Information system, from page 270	/
C/								/
C////////////////////////////////////////////////////////////////
	DIMENSION	NSET(1),QSET(1)
        COMMON/C1/ID,IM,INIT,JEVNT,JMNIT,MFA,MSTOP,MX,MXC,NCLCT,NHIST,
     $  NOQ,NORPT,NOT,NPRMS,NRUN,NRUNS,NSTAT,OUT,ISEED,TNOW,
     $  TBEG,TFIN,MXX,NPRNT,NCRDR,NEP,VNQ(4),IMM,MAXQS,MAXNS
	COMMON /C2/ATRIB(10),ENQ(4),INN(4),JCELS(5,22),KRANK(4),
     $  MAXNQ(4),MFE(4),MLC(4),MLE(4),NCELS(5),NQ(4),PARAM(20,4),
     $  QTIME(4),SSUMA(10,5),SUMA(10,5),NAME(6),NPROJ,MON,NDAY,NYR,
     $  JCLR,JTRIB(12)
	COMMON /U1/ NARC,NSCAN,JBUFF,NSTA(10),JRPLY(10)
	COMMON /U2/ XL,NTER,IBUFF,CDIAL(2),CREAD(2),SRTIM,SCTIM,
     $  TRTIM,DLTIM,COMTIM(2)
C
C
C	--- SET INITIAL USER VARIABLES.
C
	NTER = PARAM( 1,1 )
	IBUFF = PARAM( 1,2 )
	XL = PARAM( 1,3 )
	CDIAL(1) = PARAM( 2,1 )
	CDIAL(2) = PARAM( 2,2 )
	CREAD(1) = PARAM( 3,1 )
	CREAD(2) = PARAM( 3,2 )
	SRTIM = PARAM( 4,1 )
	SCTIM = PARAM( 4,2 )
	TRTIM = PARAM( 5,1 )
	DLTIM = PARAM( 5,2 )
	COMTIM(1) = PARAM( 6,1 )
	COMTIM(2) = PARAM( 6,2 )
C
	GO TO (1,2,3,4,5),I
1	CALL	ARRVL( NSET,QSET )
	RETURN
2	CALL	RQEST( NSET,QSET )
	RETURN
3	CALL	SCAN( NSET,QSET )
	RETURN
4	CALL	ANSER( NSET,QSET )
	RETURN
5	CALL	ENDSV( NSET,QSET )
	RETURN
	END
