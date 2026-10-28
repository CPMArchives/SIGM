{$I-,R-}
program TestIOCheck;
{
       The routine IOCheck, along with the global declarations
       IOFlag and IOErr, should be placed in any program where you
       want to handle your own I/O error checking.
}
{***************************** Please Note **************************

       The main routine in this program is just a sample of what you
       can do with TestIOCheck.  This sample simply assigns a new file
       ReWrites it and then tries to read from it - which is illegal.
       The error this routine generates is somewhat explanatory of what
       error has actually occured.  Try it - and modify it.  It can be
       a real added benifit to programs you write yourself using files!

*********************************************************************}

const
  IOVal                : Integer = 0;
  IOErr                : Boolean = False;
var
  InFile               : Text;
  Line                 : string[80];

procedure IOCheck;
{
       This routine sets IOErr equal to IOresult, then sets
       IOFlag accordingly.  It also prints out a message on
       the 24th line of the screen, then waits for the user
       to hit any character before proceding.
}
var
  Ch                   : Char;
begin
  IOVal := IOresult;
  IOErr := (IOVal <> 0);
  GotoXY(1,24); ClrEol;        { Clear error line in any case }
  if IOErr then begin
    Write(Chr(7));
    case IOVal of
      $01  :  Write('File does not exist');
      $02  :  Write('File not open for input');
      $03  :  Write('File not open for output');
      $04  :  Write('File not open');
      $05  :  Write('Can''t read from this file');
      $06  :  Write('Can''t write to this file');
      $10  :  Write('Error in numeric format');
      $20  :  Write('Operation not allowed on a logical device');
      $21  :  Write('Not allowed in direct mode');
      $22  :  Write('Assign to standard files not allowed');
      $90  :  Write('Record length mismatch');
      $91  :  Write('Seek beyond end of file');
      $99  :  Write('Unexpected end of file');
      $F0  :  Write('Disk write error');
      $F1  :  Write('Directory is full');
      $F2  :  Write('File size overflow');
      $FF  :  Write('File disappeared')
    else      Write('Unknown I/O error:  ',IOVal:3)
    end;
    Read(Kbd,Ch)
  end
end; { of proc IOCheck }

procedure PutLineNum(LineNum : Integer);
{
       This routine tells you which line is being executed,
       so that you can see which statement is causing which
       error.
}
begin
  GotoXY(1,1); ClrEol;
  Write('Executing line #',LineNum)
end; { of proc PutLineNum }

begin
  PutLineNum(1); Assign(InFile,'dummy');     IOCheck;
  PutLineNum(2); Rewrite(InFile);            IOCheck;
  PutLineNum(3); Read(Infile,Line);          IOCheck;
  PutLineNum(4); Close(Infile);              IOCheck
end. { of program TestIOCheck }
