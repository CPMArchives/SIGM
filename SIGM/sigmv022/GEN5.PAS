PROGRAM GENERATE;
(*
 ********************************************************
 *	An attempt to access files under PASCAL/Z.	*
 *	This program will Generate a File of data,	*
 *	read the data back and display the data.	*
 *							*
 *	 1.0  30 NOV 79, REP				*
 *	 1.1   3 DEC 79, REP				*
 *	 1.2   4 DEC 79, REP				*
 *		 Cleaned up some logic concerning Eof()	*
 *							*
 *  REP (Ray Penley) wrote this back in version 2.O	*
 *  days but I upgraded it to version 3.O. Its still    *
 *  interesting to those of us who need all the in-	*
 *  structional help we can get.(I only modified it 	*
 *  enough to get it running, so it possibly has some   *
 *  outdated syntax.)					*
 *							*
 *  Donated to Pascal/Z users group, Aug 1980		*
 ********************************************************
 *)
CONST
  MaxLength = 80;
  EOS = '|';	(* End of String marker *)

TYPE
  FILETYPE	= TEXT;
  CPMFILENAME	= PACKED ARRAY[1..14] of CHAR;
  ErrorSym	= (NULL, ERR0, ERR1, ERR2, ERR3);
  MININTEGER	= -240..240;
  strg = record
	    length  : INTEGER;
	     image  : PACKED ARRAY[1..MaxLength] of CHAR;
	   end;
VAR
  F1NAME,			(* File name - File A *)
  F2NAME	: CPMFILENAME;	(* File name - File B *)
  TextFile	: FILETYPE;
  INBUFF 	: STRG;
  CH 		: CHAR;
  ErrorCodes 	: SET of ErrorSym;
  error     	: ErrorSym;
  EndofFile,		(* End of File flag *)
  EndofText,		(* End of Text flag *)
  complete : BOOLEAN;	(* Action flag *)

(**********************************)

FUNCTION G( II : INTEGER  ): CHAR;
(* Function to perform some action upon the CHAR *)
begin
  G := CHR(II +32)
end;

Procedure PRINT( VAR X : STRG );
(*	Print the string X until End of String	    *)
VAR
  CH : CHAR;
  pos : MININTEGER;
begin
  pos := 0;
  REPEAT
    pos := pos +1;
    CH := X.image[ pos ];
    If CH <> EOS then WRITE(CH)
  UNTIL (CH = EOS) OR (pos = MaxLength);
  If (pos=MaxLength) then error := ERR3;
  Writeln
end;

Procedure PUTDATA;
VAR 
  I, J : MININTEGER;
begin
  (***    CREATE FILE    ***)
  REWRITE( F1NAME, TextFile );
  EndofFile := Eof(TextFile);(*** SET Eof FLAG ***)
  J := 0;
  complete := FALSE;
  Writeln('Now writing data to File ', F1NAME);
  REPEAT
    J := J +1;
    WRITE( J:4 );
    FOR I := 1 TO 58 DO
      begin
      CH := G( I );	(*** PROCESS CHAR  ***)
      WRITE( TextFile, CH )
      end;
    WRITE( TextFile, EOS ) (* NOW WRITE OUR End of String *)
  UNTIL (J = 25);
  Writeln;
  complete := TRUE
(***   CLOSE FILE   ***)
end(* PUTDATA *);

Procedure GetLine( VAR INBUFF : STRG );
(* GLOBAL
	INBUFF,	EndofFile, MaxLength 	*)
VAR
 CH   : CHAR;
 I    : MININTEGER;
begin
  WITH INBUFF DO
    begin
      FOR I:=1 TO MaxLength DO (* Initialize INbuffer *)
	 image[ I ]:= EOS;
      length := 0;
      EndofText := FALSE;
	WHILE NOT Eof(TextFile) AND (CH <> EOS) DO
	  begin
	  If length < MaxLength then
	    begin
	      READ(TextFile, CH );
	      length := length +1;
	      image [length] := CH
	    end(* If *)
	  ELSE	(***   error   ***)
	    begin
	      error := ERR2;
	      EndofText := TRUE
	    end(* else *)
	  end(* WHILE *);
      EndofFile := Eof(TextFile) (*** !!! SET FLAG !!! ***)
    end(* with *)
end(* GetLine *);

Procedure GetData;
VAR
  I : MININTEGER;
begin
  (***   Open File   ***)
  RESET( F1NAME, TextFile );
  I := 0;
  complete := TRUE;
  EndofFile := Eof(TextFile);(*** GET Eof FLAG ***)
  If EndofFile then
    begin
    error := ERR1;(* FILE NOT FOUND *)
    complete := FALSE
    end
  ELSE
    begin   Writeln('Now Reading Data from ', F1NAME );

      GetLine(INBUFF); (* Attempt to Read a Line *)
      WHILE NOT EndofFile DO
	begin
	I := I +1;
	WRITE( I:2, ' ');
	PRINT(INBUFF); 	(*** PROCESS THE CHAR ***)
	GetLine(INBUFF); (* Attempt to Read a Line *)
	end(* While *)

    end(* else *)
(***   Close File   ***)
end(* GET DATA *);

Procedure ShowError;
begin
  CASE error of
    ERR0:	Writeln;
    ERR1:	Writeln('FILE NOT FOUND');
    ERR2:	Writeln('Exceeded buffer limits on read');
    ERR3:	Writeln('Exceeded write buffer limits')
    end(* CASE *)
end;

Procedure INITIALIZE;
begin
  F1NAME := 'TEST.DAT      ';
  F2NAME := 'TEST.DAT      ';
  ErrorCodes := [ERR0..ERR3];	(* INITIALIZE ERROR CODES *)
  error  := NULL;
  EndofText := FALSE
end;

begin(*** GENERATE ***)
  INITIALIZE;
  PUTDATA;
  If NOT(error IN ErrorCodes) then
    begin
      If complete then Writeln(CHR(7), ' ':12, 'Good Write!');
      GetData
    end(* If *);
  Writeln;
  If error IN ErrorCodes then ShowError;
  If complete then Writeln(CHR(7), ' ':12, 'Excellent Read Back!');
  Writeln;Writeln;
  Writeln('That''s All!')
end.
