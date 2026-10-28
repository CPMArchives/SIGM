program GetFunctionKeyData;
{
        This program looks at keyboard input to see if a key was hit that
        generates a two-character sequence.  On most keyboards, these two
        characters consist of chr(27) [ESC] plus an alphanumeric char.
}
var
  Ch                   : Char;
  Previous             : Boolean;
  Count                : Integer;

begin
  for Count := 1 to 20 do begin
    Read(Kbd,Ch);              { Read a character, if ESC (chr(27) then }
    if Ch = chr(27) then begin { keystroke must be either ESC key or one }
      Previous := True;        { that generates a two-digit code }
      Read(Kbd,Ch);
    end
    else Previous := False;
    if Previous
      then Write('previous ')
      else Write('single char ');
    WriteLn('Ord(Ch)= ',Ord(Ch))
  end
end. { of program GetFunctionKeyData }
