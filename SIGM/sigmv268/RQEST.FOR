	SUBROUTINE 	RQEST( NSET,QSET )
C////////////////////////////////////////////////////////////////
C/								/
C/	Program-id.	RQEST.FOR				/
C/	Date-written.	11th,Feb,1984				/
C/	Remarks.	Placement of request for information	/
C/			from page 273				/
C/								/
C////////////////////////////////////////////////////////////////
C
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
	J = JTRIB( 2 )
	JTRIB( 1 ) = 20
	CALL	FILEM( 2,NSET,QSET )
	JRPLY( J ) = 2
	RETURN
	END
