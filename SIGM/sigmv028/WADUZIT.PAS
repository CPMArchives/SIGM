{$C-,M-,F-}{ PASCAL/Z COMPILER OPTIONS }
PROGRAM WADUZITDO;
{
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
+ PROGRAM TITLE:	What Does It Do?		+
+							+
+ WRITTEN BY:		Larry Kheriaty, Computer Center +
+			Western Washington Univ.	+
+			Bellingham, Wa. 98225		+
+			BYTE MAG, Sept 1978		+
+							+
+ SUMMARY:						+
+ A minimal PILOT interpreter.	A sample of what can be +
+ done with the high level language Pascal. Commands	+
+ will be found in the file WADUZIT.DOC.		+
+							+
+ Modification record:					+
+    1.1   -August 1979 Entered by Ray Penley		+
+	    program does not work as originally written.+
+    1.2   -added EndOfString marker (EOS)		+
+		  and EndOfFile marker (EOFS)		+
+	    added DEBUG FLAG; procedure PAD;		+
+	    rewrote PROCEDURE LIST			+
+	    program still not working.			+
+    1.3   -April 1, 1981 - finally got program to work!+
+	    rewrote LIST; some mods to EXECUTE; 	+
+	    added getc(); putc(); readchar(); advance;	+
+	    added KEYIN(); signon header & prompt.	+
+    1.4   -April 3, 1981 - Modified so that all lines	+
+	    are "linelength" characters long.  This	+
+	    allows a cleaner line insert and delete.	+
+	    added procedure debug;/deleted advance;	+
+							+
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
}

LABEL	1;		{ Program termination on ctrl-e 	}

CONST
  prompt = '>';
  CTRLD  = 4;		{ control-D will display the whole	 }
			{ memory buffer.			 }
  CTRLE  = 5;		{ assign control-E as program terminator }
  lines  = 50;		{ total # of lines per program		 }
  linelength = 64 + 1;	{ # chars/line plus one for EOS marker	 }
  BUFSIZE =		{ total # of chars =			 }
     lines*linelength+1;{    linelength times (# of lines) + 1	 }

VAR
  tcount,		{ line counter }
  ppos, 		{ present position location }
  lpos	: INTEGER;	{ last position location    }

  BACKSPACE,		{ backspace character  }
  bell, 		{ terminal bell char   }
  EOS,			{ End of string marker }
  EOFS, 		{ End of file marker   }
  null, 		{ null character       }
  lastchar,		{ last character       }
  FLAG, 		{ match flag	       }
  pchar : CHAR; 	{ current character    }

  membuffer : ARRAY [1..BUFSIZE] OF CHAR;{ the working area in memory }

  listing,		{ Listing to console flag }
  xeof, 		{ End of file flag }
  xeoln : BOOLEAN;	{ End of line flag }



PROCEDURE KEYIN(VAR ch: char); EXTERNAL;
{ Direct keyboard input of a single character }


Procedure getc(VAR ch: char);
{ Read single character from the keyboard/ with echo }
begin 
  KEYIN(ch);Write(ch);
  If ORD(ch)=13 then ch := EOS;
  xeoln := ( ch=EOS );
end;


Procedure putc(ch: char);
{ Write out a single character to the output device }
begin
  if ( ch=EOS ) then
    writeln
  else
    write(ch);
end;


Procedure Restart;
begin
  ppos := 1;
  tcount := 0;
  writeln('Ready');
  putc(prompt);
end;


PROCEDURE INITIALIZE;
BEGIN
  BACKSPACE := CHR(8);
  bell := CHR(7);
  EOS := '|';		{ end of string character }
  EOFS := CHR(127);	{ end of file character   }
  null := CHR(0);
  listing := false;
  xeof := true; 	{ must be end of file since buffer is empty }
  xeoln := false;

  { initialize the entire input buffer into lines }
  ppos := 0;
  repeat
    ppos := ppos + 1;
    if ( ppos MOD linelength=0 ) then
       membuffer[ppos] := EOS	    { end of string }
    else
       membuffer[ppos] := null;
  until ( ppos=bufsize );
  membuffer[ppos] := EOFS;	    { end of file }
END;


Procedure Readchar(var ch: char);
{ Reads a single character from the input buffer }
begin
  ch := membuffer[ppos];
  ppos := ppos + 1;
  xeof := ( ch=EOFS );
  xeoln := ( ch=EOS );
end;


Procedure push(ch: CHAR);
begin
  membuffer[ppos] := ch;
  ppos := ppos +1;
end;


PROCEDURE LIST;
BEGIN
  Readchar(pchar);
  if ( listing ) then
    begin tcount := tcount + 1;
	  write(tcount:3,':  ');
    end;
  while not (xeof or xeoln) do
    begin if ( pchar<>null ) then putc(pchar);
	  Readchar(pchar);
    end;
  putc(EOS);
END;


PROCEDURE PAD;
{ Pads a line by filling with nulls }
BEGIN
  while ( ppos MOD linelength<>0 ) do push(null);
  push(EOS);
END;


PROCEDURE EXECUTE;
VAR	i: INTEGER;
	DONE : BOOLEAN;
BEGIN
  ppos := 1;		{ * execution always starts here * }
  DONE := FALSE;
  REPEAT
    pchar := membuffer[ppos] ;
    IF (pchar < '*') THEN pchar := '*';
    CASE pchar OF

	'*':	{ * program marker - jump destination * }
		ppos := ppos + 1;

	'Y','N':
		{ * YT:text  *	NT:text  *  YJ:n  *  NJ:n  * etc.  * }
		IF pchar=FLAG THEN
		  ppos := ppos+1
		ELSE
		  repeat
		    Readchar(pchar);
		  until ( xeof ) or ( xeoln );

	'A':	begin  { *    A:    * }
		  lpos := ppos;
		  getc(pchar);
		  lastchar := pchar;
		  putc(EOS);
		  ppos := ppos + 2
		end;

	'M':	BEGIN	{ *	M:x	     * }
		  IF ( lastchar=membuffer[ppos+2] ) then
		     FLAG := 'Y'
		  ELSE
		     FLAG := 'N';
		  ppos := ppos+3
		END;

	'J':	{ *   J:n    * }
		IF ( membuffer[ppos+2]='0' ) then
		  ppos := lpos
		ELSE
		  begin { CONVERT ASCII CHAR TO NUMBER }
		    i := ORD(membuffer[ppos+2])-48;
		    REPEAT
		      Readchar(pchar);
		      IF ( pchar='*' ) THEN i := i - 1
		    UNTIL ( i=0 ) OR ( xeof );
		  END;

	'T':	BEGIN	{ *   T:text	* }
		  ppos := ppos + 2;
		  LIST
		END;

	'S':	BEGIN	{ *   S:	 * }
		  DONE := TRUE;
		END

	ELSE:	LIST;

    END;(* case *)
  Until ( done ) or (membuffer[ppos]=EOFS);
END;


Procedure debug;
var	ch: char;
begin
  ppos := 1;	{ * start at first char in the memory buffer * }
  repeat
     repeat
	Readchar(ch);
	if ( ch=null ) then putc('.')
	else putc(ch);
     until (ch=eos) or (ch=eofs);
  until (ch=eofs);
  writeln;
  Restart;
end;


Procedure DoCommand(comchar: char);
begin
  putc(EOS);
  CASE comchar of

    '/':  begin listing := true;
		LIST;
		listing := false;
		putc(prompt);
	  end;

    '\':  Restart;

    '$':  begin EXECUTE;
		Restart;
	  end;

    '%':  begin PAD;
		Restart;
	  end;
  END{of CASE};
end;



BEGIN	(* MAIN PROGRAM *)
  WRITELN(' ':20, 'WHAT DOES IT DO?');
  WRITELN(' ':20, 'by Larry Kheriaty');
  WRITELN(' ':20, 'this version by Ray Penley');
  WRITELN;WRITELN;
  INITIALIZE;
  restart;
  getc(pchar);
  While true do { start infinite loop }
    BEGIN
      if ord(pchar)=CTRLE then {EXIT}
	 goto 1
      else if ord(pchar)=CTRLD then
	 Debug
      else IF ( pchar=BACKSPACE ) and ( ppos>1 ) then
	ppos := ppos - 1
      else
	begin if pchar IN ['/','\','$','%'] then
		DoCommand(pchar)
	      else
		begin IF ( pchar<>eos ) then
			push(pchar)	 { * store present char * }
		      else
			begin PAD;
			      putc(EOS);
			      putc(prompt);
			end;
		end;
	end;
      if ( ppos>=bufsize ) then
	 begin writeln(bell, '+++MEMORY FULL');
	       restart;
	 end;
      getc(pchar);
    END;
1:WRITELN;
END.
ze ) then
	 begin writeln(bell, '+++MEM