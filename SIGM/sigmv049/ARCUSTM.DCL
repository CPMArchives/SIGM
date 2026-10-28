/************************************************
*	     CUSTOMER MASTER RECORD		*
************************************************/

		/* * *  BT-80 HEADER  * * */
		  2  CSID	CHAR(06), /* RECORD ID */
		  2  REC_LEN	BIN(7),   /* RECORD LENGTH */
		  2  DEL_FLG	BIN(7),   /* DELETE FLAG */

		/* * *  BILLING DATA  * * */
		  2  CSBILCON   CHAR(32), /* CONTACT */
		  2  CSBILCMP	CHAR(32), /* COMPANY NAME */
		  2  CSBILAD1	CHAR(32), /* ADDRESS LINE 1 */
		  2  CSBILAD2	CHAR(32), /* ADDRESS LINE 2 */
		  2  CSBILAD3	CHAR(23), /* ADDRESS LINE 3 */
		  2  CSBILZIP	CHAR(9),  /* ZIP CODE */
		  2  CSBILTEL	CHAR(10), /* TELEPHONE NUMBER */
		  2  CSBILEXT	BIN(15),  /* TEL. EXTENSION */

		/* * *  TECHNICAL DATA  * * */
		  2  CSTECCON   CHAR(32), /* CONTACT */
		  2  CSTECCMP	CHAR(32), /* COMPANY NAME */
		  2  CSTECAD1	CHAR(32), /* ADDRESS LINE 1 */
		  2  CSTECAD2	CHAR(32), /* ADDRESS LINE 2 */
		  2  CSTECAD3	CHAR(23), /* ADDRESS LINE 3 */
		  2  CSTECZIP	CHAR(9),  /* ZIP CODE */
		  2  CSTECTEL	CHAR(10), /* TELEPHONE NUMBER */
		  2  CSTECEXT	BIN(15),  /* TEL. EXTENSION */

		/* * *  GENERAL DATA  * * */
		  2  CSSTAT	CHAR(2),  /* RECORD STATUS */
		  2  CSTERM	CHAR(2),  /* BILLING TERMS (30, 60, 90, ETC.)
					     */
		  2  CSBALTYP	CHAR(1),  /* BALANCE TYPE */
					  /* F - BALANCE FORWARD */
					  /* O - OPEN ITEM */
		  2  CSPRCCOD	CHAR(1),  /* PRICE CODE (0-9) */
		  2  CSDISC	CHAR(1),  /* DISCOUNT CODE (0-9) */
		  2  CSTAXCOD	CHAR(1),  /* TAX CODE (0-9) */

		/* * *  DOLLAR AMOUNTS  * * */
		  2  CSCURAMT	DEC(9,2), /* CURRENT AMOUNT */
		  2  CS30DAMT	DEC(9,2), /* 30-59 DAYS AMOUNT */
		  2  CS60DAMT	DEC(9,2), /* 60-89 DAYS AMOUNT */
		  2  CSOVRAMT	DEC(9,2), /* OVER 90 DAYS AMOUNT */
		  2  CSLYRAMT	DEC(9,2), /* LAST YEARS TOTAL AMOUNT */

		/* * *  MISCELLANEOUS DATA  * * */
		  2  CSSPCL	CHAR(20), /* MISCELLANEOUS DATA */

		/* * *  TRAILING BT-80 FILLER  * * */
		  2  FILLER	CHAR(081);
