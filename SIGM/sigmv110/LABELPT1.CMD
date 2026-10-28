*
*
*		Labelprt.Cmd  Label Printing Command File
*
*			by Micheal R. Abram
*		             11/20/81
*			  (rev. 07/11/82)
*		
*		    From October, 1982  Lifelines
*
*
*	    This dBASE II command file will print labels several across
*	the page.  It expects a .DBF file in USE positioned at the first
*	record to print, and will print to the end of the file.  The
*	fields expected are:
*		Field	Type	Comment
*		Name	C	Name-flipping a la NAD.  "Abram*Micheal R."
*				Last name, asterisk, first name.  This 
*                               allows you to sort or index on Name.
*		Addr1	C	Use for second name, affiliation, or
*				comment:  If the first column is blank,
*				the line will not be printed and the next
*				lines will move up.
*		Addr2	C	Street Address
*		City	C	The length of City, State, and Zip may
*		State	C	not total more than five less than the
*		Zip	C	horizontal spacing between labels, or
*				City will be truncated.
*	    The horizontal increment specified must be at least one more
*	than the lenght of the longest field, or truncation will occure.
*
*
SAVE TO LABELPRT
SET TALK OFF
SET EXACT OFF
ERASE
STORE '                                                ' TO Blanks
STORE 1 TO Perrec
STORE 2 TO Nwide
STORE 35 TO Hinc
STORE 6 TO Vinc
@  9,10 SAY '  labelprint.cmd -- Label printing Command File'
@ 10,10 SAY ' How many labels for each name?             ' GET Perrec PICT '9'
@ 11,10 SAY ' How many labels across the form?           ' GET Nwide PICT '9'
@ 12,10 SAY ' What is the horizontal spacing in columns? ' GET Hinc PICT '99'
@ 13,10 SAY ' What is the vertical spacing in lines?     ' GET Vinc PICT '9'
READ
STORE Hinc-1 TO Maxname
STORE Hinc-1 TO Maxaddr1
STORE Hinc-1 TO Maxaddr2
STORE Hinc-(LEN(State)+LEN(Zip)+5) TO Maxcity
STORE 'Y' TO Offer
DO WHILE !(Offer) = 'Y'
	@ 20,10 SAY 'Print a line of dummy labels? (Y or N)' GET Offer
        READ
	IF !(Offer) = 'Y'
		SET CONSOLE OFF
		SET PRINT ON
		STORE Nwide TO N
		DO WHILE N > 0
			?? ' Name'+$(Blanks,1,Hinc-6)
			STORE N-1 TO N
		ENDDO
		?
		?
		?
		STORE Nwide TO N
		DO WHILE N > 0
			?? ' City'+$(Blanks,1,Hinc-6)
			STORE N-1 TO N
		ENDDO
		STORE Vinc-4 TO N
                DO WHILE N > 0
                       ?
                       STORE N-1 TO N
                ENDDO
                SET PRINT OFF
                SET CONSOLE ON
        ENDIF
ENDDO
*
* labelprt.cmd
STORE 0 TO Reccount
STORE 0 TO Lpr
DO WHILE .NOT. EOF
        STORE ' ' TO Mline1
        STORE ' ' TO Mline2
        STORE ' ' TO Mline3
        STORE ' ' TO Mline4
	STORE 0 TO N
        DO WHILE N < Nwide
		DO CASE
		   CASE EOF
			STORE Nwide TO N
		   CASE Lpr < Perrec
			STORE LEN(Mline1) TO Length
			IF '*' $ Name
				STORE Mline1;
				 +$(TRIM($(Name,@('*',Name)+1,Hinc));
				 +' '+$(Name,1,@('*',Name)-1),1,Maxname);
				 TO Mline1
			ELSE
				STORE Mline1+$(Name,1,Maxname) TO Mline1
			ENDIF
			STORE Mline1+$(Blanks,1,Hinc-(LEN(Mline1)-Length));
			  TO Mline1
			IF Addr1 = ' '
				 STORE 'Mline2' TO Maddr2
                                 STORE 'Mline3' TO Mcity
                                 STORE Mline4+$(Blanks,1,Hinc) TO Mline4
                        ELSE
                                 STORE LEN(Mline2) TO Length
                                 STORE Mline2+$(Addr1,1,Maxaddr1) TO Mline2
                                 STORE Mline2+$(Blanks,1,;
                                    Hinc-(LEN(Mline2)-Length)) TO Mline2
                                 STORE 'Mline3' TO Maddr2
                                 STORE 'Mline4' TO Mcity
                        ENDIF
                        STORE LEN(&Maddr2) TO Length
                        STORE &Maddr2+$(Addr2,1,Maxaddr2) TO &Maddr2
                        STORE &Maddr2+$(Blanks,1,Hinc-(LEN(&Maddr2)-Length));
                          TO &Maddr2
                        STORE LEN(&Mcity) TO Length
                        STORE &Mcity+TRIM($(City,1,Maxcity))+', '+State+'  ';
			  +Zip TO &Mcity
			STORE &Mcity+$(Blanks,1,Hinc-(LEN(&Mcity)-Length));
			  TO &Mcity
			STORE N+1 TO N
			STORE Lpr+1 TO Lpr
		   OTHERWISE
			SKIP
			STORE Reccount+1 TO Reccount
			STORE 0 TO Lpr
		ENDCASE
	ENDDO
	SET CONSOLE OFF
	SET PRINT ON
	? Mline1
	? Mline2
	? Mline3
	? Mline4
	STORE Vinc-4 TO N
	DO WHILE N > 0
		?
		STORE N-1 TO N
	ENDDO
	SET PRINT OFF
	SET CONSOLE ON
ENDDO
@ 14,10 SAY 'There were '
@ 14,22 SAY Reccount USING '99999'
@ 14,28 SAY 'records processed '
@ 15,10 SAY '       and '
@ 15,22 SAY Reccount*Perrec USING '99999'
@ 15,28 SAY ' labels printed.   '
RESTORE FROM LABELPRT
DELETE FILE LABELPRT.MEM
RETURN
