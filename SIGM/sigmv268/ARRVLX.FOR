	SUBROUTINE	ARRVL( NSET,QSET )
C////////////////////////////////////////////////////////////////
C/								/
C/	Program-id.	ARRVL.FOR				/
C/	Date-written.	11th,Feb,1984				/
C/	Remarks.	Subroutine ARRVL is called each time	/
C/			a new customer arrives to the system	/
C/			from page 272				/
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
C	--- Determine the station number that the arriving customer
C	    will go to by sampling from a uniform distribution.
C	    Collect statistics on number of customers at the station
C	    to which the new arrival is going.
C
	NARC = NARC + 1
	J = 1
	ICHEK = NSTA( 1 )
	DO 10 I=2,NTER
	IF( ICHEK.LE.NSTA( I ) ) GO TO 10
	ICHEK = NSTA( I )
	J = I
10	CONTINUE
	X = NSTA( J )
	CALL	TMST( X,TNOW,J,NSET,QSET )
C
C	--- Allow customer to make his request immediately since 
C	    station was idle.
C
	IF ( NSTA(J) ) 2,2,3
2	ATRIB(1) = TNOW + UNFRM( CDIAL(1),CDIAL(2) )
	JTRIB(1) = 2
	JTRIB(2) = J
	CALL	FILEM( 1,NSET,QSET )
C
C	--- Increment number of customer at station J by one
C
3	NSTA( J ) = NSTA( J ) + 1
C
C	--- Schedule next customer arrival at current time olus a
C	    sample from an exponential distribution.
C	    Customers request is completed. Store request in file 
C	    of calls requested but not in buffer. 
C
	CALL	DRAND( ISEED,RNUM )
	ATRIB(1) = TNOW - XL*ALOG( RNUM )
	JTRIB(1) = 1
	CALL	FILEM( 1,NSET,QSET )
	RETURN
	END
