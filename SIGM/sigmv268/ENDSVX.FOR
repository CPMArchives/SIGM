	SUBROUTINE	ENDSV( NSET,QSET )
C////////////////////////////////////////////////////////////////
C/								/
C/	Program-id	ENDSV.FOR				/
C/	Date-written.	11th,Feb,1984				/
C/	Remarks.	Subroutine ENDSV is called eack time	/
C/			a customer is finished with the answer	/
C/			to his request.				/
C/			From page 276				/
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
C	--- Collect statistics on number of customers at station J
C
	J = JTRIB( 2 )
	X = NSTA( J )
	CALL	TMST( X,TNOW,J,NSET,QSET )
C
C	--- Decrement number of customers at station J by one
C
	NSTA( J ) = NSTA(J ) - 1
	JRPLY( J ) = 1
C
C	--- Set line from station J to free status
C
	IF ( NSTA(J) ) 3,3,2
C
C	--- If a customer is waitting for station J, schedule a 
C	    plavement of request event at station J
C
2	ATRIB( 1 ) = TNOW + UNFRM( CDIAL(1),CDIAL(2) )
	JTRIB( 1 ) = 2
	JTRIB( 2 ) = J
	CALL	FILEM( 1,NSET,QSET )
3	RETURN
	END
