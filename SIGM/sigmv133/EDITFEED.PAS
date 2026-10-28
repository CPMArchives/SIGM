(*********************************************************
*
*		Donated by Ray Penley, June 1980
*
********************************************************)


{*  PROGRAM TITLE:	EDIT A LINEAR FILE
**
**  WRITTEN BY:         W.M. Yarnall
**  DATE WRITTEN:       May 1980
**
**  WRITTEN FOR:	S100 Microsystems
**			May/June 1980
**
**  SUMMARY:
**		See the article in S100....
**
**  MODIFICATION RECORD:
**	25 May 1980	-Modified for Pascal/Z by Raymond E. Penley
**			-All files made local to Procedures.
**			 This insures that each file will be closed.
**
**	1 FEB 1983	-CHANGED STRING LENGTH FROM 6 TO 20 IN RINDEX
**			AND CINDEX
**	4 FEB 83	-BREAK INTO MODULES AND REWORK FOR SPECIAL
**			PURPOSE FEEDLOT PROGRAM.  buddenberg
**
**		---NOTE---
**
** The first logical record in Pascal/Z is No. 1, NOT record
** No. 0 as in PASCAL/M or UCSD PASCAL. This can be rectified
** very eaisly by adding a 'bias' to every record number.
**		PASCAL/Z	bias = 1
**		PASCAL/M	bias = 0
**
*}
PROGRAM EDLINEAR(0);
CONST
  default = 80;	   (* Default length for strings *)
  FID_LENGTH = 14; (* MAXIMUM ALLOWED LENGTH FOR A FILE NAME *)
  bias   =  1;	   (* see comments above *)

TYPE
  FREC = RECORD
	   CASE tag:integer of
	    0:  (NAME :STRING 20; N1, N2 :integer);
	    1:  (HEADER :STRING 64);
	    2:  (RNAME :STRING 20; RINDEX :integer; RHS :real);
	    4:  (CNAME :STRING 20; CINDEX :integer; OBJ :real);
	    6:  (R,S :integer; T :real);
	   99:  () {--end of file--}
	 END;

  FID	    = STRING FID_LENGTH;
  LINEAR    = FILE OF FREC;
  STR0	    = STRING 0;
  STRING80  = STRING default;
  STR255    = STRING 255;

VAR
  OFIL,		(*---File Identifiers <FID>---*)
  NFIL	: FID;
  OBUFFER,	   {buffer for OLD file}
  NBUFFER	   {buffer for NEW file}
	: FREC;
  editing,	   {The state of editing the file}
  valid,	   {An answer must be valid to be accepted}
  valid_build,	   {All aspects of a "build" have been completed}
  XEOF		   {End_Of_File flag for a NON TEXT file}
	: boolean;
  bell,		   {console bell}
  Command	   {Command answer}
	: char;

PROCEDURE KEYIN(VAR X: char); EXTERNAL;
(* Direct keyboard entry of a single char *)

	(*----Required for Pascal/Z functions----*)
FUNCTION  LENGTH( X :STR255) :INTEGER; EXTERNAL;
PROCEDURE SETLENGTH(VAR X :STR0; Y :INTEGER); EXTERNAL;

Function INREC (j:INTEGER): integer; EXTERNAL;

Function INRE: integer; external;

Procedure PRINT( This_one: FREC; Rcd: INTEGER);
begin
  writeln;
  writeln(' REC', Rcd:4, ' TAG:', This_one.tag:5);
  With This_one do
    CASE TAG of
	0:    begin
		writeln(' NAME: ', name);
		writeln(' No ROWS: ', N1);
		writeln(' No COLS: ', N2)
	      end;
	1:    begin
		writeln(' HEADING:');
		writeln(header)
	      end;
	2:    begin
		writeln(' ROW: ', RNAME);
		writeln(' INDEX: ', RINDEX);
		writeln(' RHS: ', RHS)
	      end;
	4:    begin
		writeln(' COL: ', CNAME);
		writeln(' INDEX: ', CINDEX);
		Writeln(' OBJ: ', OBJ)
	      end;
	6:	Writeln(' ABAR[', R:3, ',', S:3, ']: ', T);
	99:	Writeln(' --- End of File ---')
    End{of With/CASE};
  writeln
End{of PRINT};

PROCEDURE GETID( VAR ID: FID; Message: STRING80 );
{-Pascal/Z does not like file names that are
  not space filled to user specified length-}
CONST	SPACE = ' ';
begin
  SETLENGTH(ID,0);
  writeln;
  write(message);
  READLN(ID);
  While Length(ID) < FID_length Do APPEND(ID,SPACE)
end;

Procedure BUILD; EXTERNAL;

Procedure LIST;
LABEL	2 {File not found};
VAR	REC : integer;
	fa  : LINEAR; (*---File descriptor <FCB>---*)
begin
  GETID(OFIL,' List what File? ');
  WRITELN;
  RESET(OFIL, fa);	 (*---RESET( <FID> , <FCB> )---*)
  If EOF(fa) then
    begin
    writeln(bell,'File ',OFIL,'not found');
    {exit}goto 2
    end;
  WRITELN;
  WRITE(' Starting at what record? ');
  READLN(REC);
  writeln;
  READ(fa:REC+BIAS, OBUFFER);
  XEOF := (OBUFFER.TAG=99);
  WHILE NOT XEOF do
    begin
      write( REC:5, ': ' );
      With OBUFFER do begin
	Write(TAG:3,' ');
	CASE TAG of
	  0:	Writeln(Name:8, N1:7, N2:7);
	  1:	Writeln(HEADER);
	  2:	Writeln(RNAME:22, RINDEX:7, RHS:14:8);
	  4:	Writeln(CNAME:22, CINDEX:7, OBJ:14:8);
	  6:	Writeln('ROW', R:3, ' COL', S:3, T:14:8)
	  End{of Case}
	End{With};
      REC := REC + 1;
      READ(fa:REC+BIAS,OBUFFER);
      XEOF := (OBUFFER.TAG=99);
    end{while};
2:	{file not found}
End{of LIST};{ CLOSE(fa) }

Procedure MODIFY; external;

BEGIN (*---Main Program---*)
  BELL := CHR(7);
  editing := true;

  WHILE editing do
    begin{ EDIT session }
      REPEAT
	valid := true;
	writeln;
	write(' EDIT: L(ist, B(uild, M(odify, Q(uit ');
	KEYIN(Command);WRITELN(Command);
        CASE Command of
	  'L','l':	LIST;
	  'B','b':	BUILD;
	  'M','m':	MODIFY;
	  'Q','q':	editing := false
	  ELSE:    	begin
		 	write(BELL);
		 	valid := false
		 	end
        End{case}
    UNTIL valid{command}
    end{ EDIT session }
End{---of Edit Linear---}.
ýf¿ÝtúÝuùÝwØÝw×Ý6ÖÝwÔÝ6ÓÝwÒÝwÕÝwÑÝwÏÝwïýnÀýfÁÝtÚÝuÙýn¼ÝuÐýn½Ýuõg}þÂ«V¯ÝnÙÝfÚ}/o|/g#¯ÝtÚÝuÙÃ