*     LABELPRT.CMD
*     Lifelines Oct 82
*     See Lifelines for comments

*			     CLH ADDITION Next block  11/ 1/82
ERASE
SET TALK ON
STORE '          ' TO mdbf
SET DEFA TO B:
ACCEPT " DBF Filename " TO mdbf
USE &mdbf
GOTO TOP
*			     CLH Addition ends


SAVE TO LABELPRT
SET TALK OFF
SET EXACT OFF
ERASE
STORE '                                            ' TO BLANKS
STORE  1 TO Perrec
STORE  2 TO Nwide
STORE 45 TO Hinc
STORE  6 TO Vinc
@  9,10 SAY ' LABELPRT.CMD  Label Printing File    '
@ 10,10 SAY ' How many labels per name ?           ' GET Perrec PICT '9'
@ 11,10 SAY ' How many labels across form?         ' GET  Nwide PICT '9'
@ 12,10 SAY ' Give horizontal spacing in columns?  ' GET  Hinc PICT '99'
@ 13,10 SAY ' What is vertical spacing in lines?   ' GET   Vinc PICT '9'
READ
STORE Hinc-1 TO Maxname
STORE Hinc-1 TO MaxAddr1
STORE Hinc-1 TO MaxAddr2
STORE Hinc-(LEN(State)+LEN(ZIP)+5) TO MaxCity
STORE 'Y' TO Offer
DO WHILE !(Offer)='Y'
    @ 20,10 SAY'Print a line of dummy labels? ( Y or N )' GET Offer
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

*	  LABELPRT.CMD

STORE 0 TO RECCOUNT
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
	CASE Lpr < perrec
	    STORE LEN(Mline1) TO Length
	    IF '*' $NAME
	    STORE Mline1;
		+$(TRIM($(Name,@('*',Name)+1,Hinc));
		+' '+$(Name,1,@('*',Name)-1),1,Maxname);
		TO Mline1
	    ELSE
	    STORE MLine1+$(Name,1,Maxname) TO Mline1
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
		STORE &Mcity+TRIM($(City,1,Maxcity))+', '+State+' ';
		  +ZIP TO &Mcity
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
@ 14,10 SAY ' There were '
@ 14,22 SAY Reccount USING '99999'
@ 14,28 SAY ' records processed '
@ 15,10 SAY '        and '
@ 15,22 SAY  Reccount*Perrec USING '99999'
@ 15,28 SAY ' labels printed. '
RESTORE FROM Labelprt 
DELE FILE LABELPRT.MEM
RETURN
2 SAY  Reccount*Perrec USING '99999'
@ 15,28 SAY ' labels printed. '
R