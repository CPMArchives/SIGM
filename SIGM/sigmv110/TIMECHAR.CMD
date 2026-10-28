TIMECHAR.CMD
*
*
ERASE
SET TALK OFF
? CHR(27)+CHR(40)
? '                GCS Timesheet Entry             '
? CHR(27)+CHR(41)
? CHR(27)+CHR(40)
? 'Entry of R for DATE Will Return You to Menu     '
? CHR(27)+CHR(41)
ACCEPT 'ENTER DATE (MM/DD/YY)       ' to C:DATE
IF !(C:DATE)='R'
	RELEASE C:DATE
	RETURN
ENDIF
USE &COST
DO WHILE T
	ERASE
	?
	? CHR(27)+CHR(40) + '           GCS TIMESHEET ENTRY         '+;
	 CHR(27)+CHR(41)
	?
	?
	? CHR(27)+CHR(40)
	REMARK Entry of 0 for Name will Return you to Menu
	? CHR(27)+CHR(41)
	?
	ACCEPT 'Enter Employee Name' to C:NAME
	IF C:NAME = '0'
		USE
		RELEASE C:DATE, C:JOBNUM, GO:NOGO, C:PCODE, C:NAME, C:HOURS, C:RATE, ;
		C:AMT, C:CUSTCD, C:CUSTOD
		RETURN
	ENDIF
	?
	ACCEPT 'Enter Operation Code' to C:OPCODE
	STORE '0' TO C:PCODE
	STORE 'y' TO PERSON
	DO WHILE !(PERSON) = 'Y'
		ERASE
		?
		? CHR(27)+CHR(40) + '           GCS TIMESHEET ENTRY         '+;
		 CHR(27)+CHR(41)
		?
		?
		? CHR(27)+CHR(40)
		? 'Date set is      :'+CHR(27)+CHR(41)+'  &C:DATE'+CHR(27)+CHR(40)
		? 'Operation Code   :'+CHR(27)+CHR(41)+'  &C:OPCODE'+CHR(27)+CHR(40)
		? 'Entering Time For:'+CHR(27)+CHR(41)+'  &C:NAME'
		IF C:PCODE = '0'
			ACCEPT	        'Enter Production Code:     ' to C:PCODE
		ENDIF
		? CHR(27)+CHR(40)
		? 'Production Code is:'+CHR(27)+CHR(41)+'  &C:PCODE'
		?
		? CHR(27)+CHR(40)
		ACCEPT 'Do you Wish to Change Production Code (Y/N)?' TO CHANGE
		? CHR(27)+CHR(41)
		IF !(CHANGE) = 'Y'
			ACCEPT   	'Enter New Production Code:      ' to C:PCODE
		ENDIF		
		IF C:PCODE = "245"
			STORE 21 TO C:RATE
		ELSE
			IF C:PCODE = "246"
				STORE 24 TO C:RATE
			ELSE
				IF C:PCODE = "247"
					STORE 70 TO C:RATE
				ELSE
					IF C:PCODE = "248"
						STORE 40 TO C:RATE
					ELSE
						IF C:PCODE = "250"
							STORE 55 TO C:RATE
						ELSE
							IF C:PCODE = "251"
								STORE 47 TO C:RATE
							ELSE
								IF C:PCODE = "252"
									STORE 50 TO C:RATE
								ELSE
									IF C:PCODE = "253"
										STORE 45 TO C:RATE
									ENDIF
								ENDIF
							ENDIF
						ENDIF
					ENDIF
				ENDIF
			ENDIF
		ENDIF
		? CHR(27)+CHR(40) + 'Enter Job Number "C" to Charge Hours '
		?           'to Customer Code and Order number    ' + CHR(27)+CHR(41)
		STORE "Y" TO NUM
		DO WHILE !(NUM) = "Y"
			ACCEPT		'ENTER JOBNUMBER             ' to C:JOBN
			?
			IF C:JOBN <> "C" .AND. LEN(C:JOBN) <> 6
				? CHR(27)+CHR(40)
				REMARK    INVALID JOB NUMBER -- REENTER
				REMARK      PRESS ANY KEY TO CONTINUE
				? CHR(27)+CHR(41)
				WAIT
				LOOP
			ENDIF
			STORE "N" TO NUM
			IF C:JOBN = 'C'
				ACCEPT		'ENTER CUSTOMER CODE         ' to C:CUSTCD
				ACCEPT		'ENTER CUSTOMER ORDER NUMBER ' to C:CUSTOD
			ELSE		
				IF !(C:JOBN) <> 'C'
					STORE "NA" TO C:CUSTCD
					STORE "NA" TO C:CUSTOD
				ENDIF
			ENDIF
			INPUT		'ENTER HOURS                 ' to C:HOURS
			?
			? CHR(27)+CHR(40)
			ACCEPT          'ARE ALL FIELDS CORRECT? (Y/N)' TO GO:NOGO
			? CHR(27)+CHR(41)
			IF GO:NOGO <> 'Y'
				LOOP
			ENDIF
			STORE (C:RATE * C:HOURS) TO C:AMT
			APPEND BLANK
			REPLACE JOBNUMBER WITH C:JOBN, BILL:DATE WITH C:DATE, OPCODE ;
				WITH C:OPCODE, NAME WITH C:NAME, HOURS WITH C:HOURS, INTCOST ;
				WITH C:AMT, PROD:CODE WITH C:PCODE, CUSTCODE WITH C:CUSTCD, ;
				CUSTORDER WITH C:CUSTOD
			ERASE
			?
			? CHR(27)+CHR(40) + '           GCS TIMESHEET ENTRY         '+;
				 CHR(27)+CHR(41)
			?
			?
			? CHR(27)+CHR(40)
			ACCEPT  'MORE HOURS FOR &C:NAME? (Y/N)' TO PERSON
			? CHR(27)+CHR(41)
			ERASE
			RELEASE C:JOBNUM, GO:NOGO, C:HOURS, C:RATE, C:AMT
		ENDDO
	ENDDO
ENDDO
RETURN