	SUBROUTINE	ANSER( NSET,QSET )
C////////////////////////////////////////////////////////////////
C/								/
C/	Program-id.	ANSER.FOR				/
C/	Date-written.	11th,Feb,1984				/
C/	Remarks.	Subroutine ANSER ia called whenever an	/
C/			answer to request is ready.		/
C/			From page 275				/
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
C	--- Find request for which an answer has been determined
C	    and remove it from the file of calls requested and stored 
C	    in the buffer.
C
	J  = JTRIB( 2 )
	CALL	FINDN( J,5,3,2,KCOL,NSET,QSET )
	CALL	RMOVE( KCOL,3,NSET,QSET )
	TI = TNOW - ATRIB( 1 )
	CALL	COLCT( TI,1,NSET,QSET )
	SUMT = SRTIM + SCTIM + TRTIM + DLTIM
	DELT = ( COMTIM(2) - COMTIM(1) + SUMT ) / 20.0
	CALL	HISTO( TI,SUMT,DELT,1 )
	JRPLY( J ) = 4
C
C	--- Schedule an end of service event for the customer to
C	    occur at current time plus customer's reading time
C
	ATRIB(1) = TNOW + UNFRM( CREAD(1),CREAD(2) )
	JTRIB(1) = 5
	CALL	FILEM(1,NSET,QSET)
C
C	--- Determine if buffer was full 
C
	IF ( JBUFF ) 2,2,1
C
C	--- If buffer was full, set it to nonfull status and call 
C	    subroutine SCAN to start the scanner moving again.
C
1	JBUFF = 0
	CALL	SCAN( NSET,QSET )
2	RETURN
	END
