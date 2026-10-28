(******************************************************
** PROGRAM TITLE:	FILE_CLOSE_DEMONSTRATION
**
** WRITTEN BY:		Raymond E. Penley
** DATE WRITTEN:	22 JAN 1980
** 			Modified for Pascal/Z vers 3.0
**			25 June 1980
**
** SUMMARY:
**	Demonstrate the three methods of closing files
**	with Pascal.
**
**	1. Using a file variable in a block.
**	2. Reusing a file variable with another file
**	   identifier (file name) to close the currently
**	   open file before opening the new file.
**	3. Normal program termination will close ALL
**	   open files. (This is NOT the preferred method)
**
*******************************************************)
PROGRAM FCLOSE;
var
  IX   : INTEGER;
  wrk1 : TEXT;	{ Global file descriptor <FCB> }

Procedure PAUSE;
var	du: char;
begin
  write('Press return to continue');
  readln(du);
end;

Procedure CLEAR;
var	ix: 1..25;
begin
  for ix:=1 to 25 do writeln;
end;

PROCEDURE A;
VAR	F1 : TEXT;
BEGIN
  CLEAR;
  writeln('FILE CLOSE METHOD #1');
  writeln;
  writeln('USING A FILE VARIABLE LOCAL TO A "BLOCK"');
  writeln('WILL CLOSE THE FILE(S) UPON EXIT OF THE BLOCK');
  writeln('This is the preferred method!');
  writeln;
  writeln('     PROCEDURE A;');
  writeln('     VAR   F1 : TEXT;');
  writeln('     BEGIN');
  writeln('       REWRITE(''CTESTA.$$$'',F1);');
  writeln('       ... BODY OF PROCEDURE ...');
  writeln('     END; { CLOSE(F1)  }');
  writeln;
  writeln('UPON EXITING THIS PROCEDURE WE WILL CLOSE');
  writeln('THE FILE ''CTESTA.$$$'' AND FIX IT ON THE DIRECTORY');
  REWRITE('CTESTA.$$$', F1);
  writeln(F1, 'PROCEDURE A');
  writeln;
  PAUSE;
END; { CLOSE(F1) }

Procedure B;
begin
  CLEAR;
  REWRITE('CTESTQQ.$$$',WRK1);
  writeln(WRK1,'CTESTQQ.$$$ THIS IS CURRENTLY OPEN FILE');
  writeln('FILE CLOSE METHOD #2');
  writeln;
  writeln('Reusing the same file variable with a new file');
  writeln('identifier <file name> will close the currently');
  writeln('open file before opening the new file');
  writeln;
  writeln('   begin');
  writeln('     REWRITE(''CTESTQQ.$$$'',WRK1);');
  writeln('     writeln(WRK1,''THIS IS THE CURRENTLY OPEN FILE'');');
  writeln('     writeln(''NOW TO CLOSE CTESTQQ.$$$ AND OPEN'');');
  writeln('     writeln(''CTESTZZ.$$$'');');
  writeln('     REWRITE(''CTESTZZ.$$$'',WRK1);');
  writeln('     writeln(''CTESTZZ.$$$ IS NOW THE CURRENT FILE'');');
  writeln('   end;');
  writeln;
  REWRITE('CTESTZZ.$$$',WRK1);
  writeln(WRK1,'CTESTZZ.$$$ IS NOW THE CURRENT FILE');
  writeln;
  PAUSE;
end;


BEGIN
  CLEAR;
  writeln('FILE CLOSE DEMONSTRATION FOR PASCAL/Z');
  writeln('by Raymond E. Penley');
  FOR IX:=1 TO 12 DO writeln;
  FOR IX:=1 TO 5000 DO {DUMMY} ;
  A;	{--- Method #1 ---}
  B;	{--- Method #2 ---}
	{--- Method #3 ---}
  CLEAR;
  writeln('FILE CLOSE METHOD #3');
  writeln;
  writeln('This is really the simplist method.  Any files still');
  writeln('open at program termination will be closed.  This is');
  writeln('the most dangerous method in that a power failure or a');
  writeln('disk failure while the program is running will leave');
  writeln('your file nowhere.');
  writeln('The file "CTESTZZ.$$$" is still open at this time.');
  writeln('When this program terminates it will be fixed on the');
  writeln('directory.');
  writeln;
  PAUSE;
  writeln;writeln;writeln;writeln;
End{of file close demo}{ CLOSE(wrk1) }.
