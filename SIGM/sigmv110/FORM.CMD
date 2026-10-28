SET TALK OFF
ERASE
SET INTENSITY OFF
STORE "                     " TO FDESC
STORE "          " TO FNAME
@ 7,20 SAY "FILE DESCRIPTION"
@ 9,20 SAY "FILE NAME"
@ 7,37 GET FDESC
@ 9,37 GET FNAME
READ
USE &FNAME
COPY STRUCTURE EXTENDED TO FORM
USE FORM
SET FORMAT TO PRINT
STORE 2 TO CNTR
**********    Next command causes expanded print on Okidata printer
@ CNTR,0 SAY CHR(31)
@ CNTR + 2,9 SAY "DBASE FILE LAYOUT FORM"
@ CNTR + 7,4 SAY "FILE NAME:"
@ CNTR + 7,15 SAY FDESC
@ CNTR + 9,4 SAY "INT. NAME:"
@ CNTR + 9,15 SAY FNAME
@ CNTR + 14,4 SAY "|==============================|"
@ CNTR + 15,4 SAY "| FLD |   NAME   |TYP|WIDTH|DEC|"
@ CNTR + 16,4 SAY "|==============================|"
@ CNTR + 17,4 SAY "|     |          |   |     |   |"
STORE 20 TO CNTR
STORE 1 TO FLD
DO WHILE .NOT. EOF
	STORE STR(FLD,3) TO FLDS
	STORE STR(FIELD:LEN,3) TO LEN
	STORE STR(FIELD:DEC,3) TO DEC
	@ CNTR,4 SAY "| " + FLDS + " |" + FIELD:NAME + "| " + FIELD:TYPE + " | " + LEN + " |" + DEC + "|"
	STORE FLD + 1 TO FLD
	SKIP
	IF EOF
		@ CNTR+1,4 SAY "|     |          |   |     |   |"
	ELSE
		@ CNTR+1,4 SAY "|-----|----------|---|-----|---|"
		STORE CNTR + 2 TO CNTR
	ENDIF
ENDDO
@ CNTR + 2,4 SAY "|==============================|"
**********    Next command switches Okidata printer back to normal print
@ CNTR + 3,0 SAY CHR(30)
EJECT
SET FORMAT TO SCREEN
RETURN
