	SUBROUTINE	SCAN( NSET,QSET )
C////////////////////////////////////////////////////////////////
C/								/
C/	Program-id.	SCAN.FOR				/
C/	Date-written.	11th,Feb,1984				/
C/	Remarks.	Subroutine SCAN controls the scanner 	/
C/			and is called each time the scanner	/
C/			can intettogate a scan point.		/
C/			From page 274				/
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
C	--- Test to see if scan point has a request which is to be 
C	    transferred to the buffer.
C
	K = JRPLY( NSCAN )
	GO TO (4,1,4,4),K
C
C	--- Test to see if buffer is full. If buffer is full, stop 
C	    scanner and set buffer index to full ststus and return
C
1	IF ( NQ(3) - IBUFF ) 3,2,2
2	JBUFF = 1
	RETURN
C
C	--- If buffer is not full, find the request at the scan point
C	    and transfer it to the buffer.
C
3	CALL	FINDN( NSCAN,5,2,2,KCOL,NSET,QSET )
	CALL	RMOVE( KCOL,2,NSET,QSET )
	JTRIB(1) = 30
	CALL	FILEM( 3,NSET,QSET )
C
C	--- File request in file 3, the file of calls in buffer.
C	    Schedule arrival of answer to the request to occur at
C	    current time plus the transfer time from the scanner to 
C	    the buffer and from the buffer to the station plus 
C	    the computer computation time.
C
	JRPLY( NSCAN ) = 3
	ADDTIM = TRTIM + DLTIM
	ATRIB( 1 ) = TNOW + ADDTIM + UNFRM( COMTIM(1),COMTIM(2) )
	JTRIB( 1 ) = 4
	CALL	FILEM( 1,NSET,QSET )
C
C	--- Set scanner delay time as the sum of the transfer time plus
C	    scan time plus movement time.
C
	SUMTIM = SRTIM + SCTIM + TRTIM
	ATRIB( 1 ) = TNOW + SUMTIM
	GO TO 5
C
C	--- Set scan time delay equal to scan time plus movement time
C
4	SUMTIM = SRTIM + SCTIM
	ATRIB( 1 ) = TNOW + SUMTIM
C
C	--- Move scanner to next position and schedule another scan
C
5	IF( NSCAN - NTER ) 7,6,6
6	NSCAN = 0
7	JTRIB( 1 ) = 3
	CALL	FILEM( 1,NSET,QSET )
	NSCAN = NSCAN + 1
	RETURN
	END
