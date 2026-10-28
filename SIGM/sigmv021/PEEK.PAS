
(*****************************************************
*
*		PEEK/POKE PROGRAM
*
*  Bob Harsch said he needed this for a program and
*  afterward thought someone else could use it so he
*  gave us a copy for the Pascal/Z Users Group.
*
*  August 1980
*
*******************************************************

{$E+ }
PROGRAM PEEKPOKE;

TYPE	BYTE= 0..255;
	CONTENTS= PACKED RECORD
			BYT: BYTE { byte in memory }
		END; { of record }
	FORM=(INTEGR,ADDRESS);
	REFERENCE= RECORD
		CASE FORM OF
			INTEGR:  (I: INTEGER);
			ADDRESS: (P: ^CONTENTS)
		END;

VAR	K,I: INTEGER;

FUNCTION PEEK(ADDR: INTEGER): BYTE;
	VAR	TEMP: REFERENCE;
	BEGIN { of function peek }
		TEMP.I:= ADDR;
		PEEK:= TEMP.P^.BYT
	END; { of function peek }

PROCEDURE POKE(ADDR: INTEGER; BITS8: BYTE);
	VAR	TEMP: REFERENCE;
	BEGIN { of procedure poke }
		TEMP.I:= ADDR;
		TEMP.P^.BYT:= BITS8
	END; { of procedure poke }



BEGIN { of main program }
	K:= -1024 + 5*64;  { screen address }
	WRITE(PEEK(128):3,'--');
	FOR I:= 129 TO 160 DO
		BEGIN
		WRITE(CHR(PEEK(I)));
		POKE(K, PEEK(I));
		K:= K + 1;
		END;
	WRITELN
END.