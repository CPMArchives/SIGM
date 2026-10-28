/****************************************************************
*                      A/R COMMON AREAS                         *
****************************************************************/
	DCL	CURDAT CHAR(8) EXTERNAL; /* CURRENT DATE */
	DCL	1 OPENCB1 EXTERNAL,	/*BT-80 OPEN IOCB FOR ARCUSTM*/
		  2 IDXDRIVE CHAR(1),
		  2 IDXFILE CHAR(8),
		  2 IDXTYPE CHAR(3),
		  2 NPAGES BIN(6),
		  2 PW CHAR(4),
		  2 DLYUPD BIT(1),
		  2 DRIVES(8) CHAR(1);
	DCL	IDX1 BIN(7) EXTERNAL;	/*BT-80 FILE INDEX # */
	DCL	IOCB1P PTR EXTERNAL;
	DCL	1 IOCB1 EXTERNAL,	/*BT-80 IOCB FOR ARCUSTM*/
		  2 KEYPTR1 PTR,
		  2 RECPTR1 PTR,
		  2 DFLLOC1 CHAR(3),
		  2 DUP_KEY1 BIT(1);
	DCL	1 REC1 EXTERNAL,
