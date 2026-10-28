{ PROGRAM AUTHOR: Mark Aldon Weiss  PROGRAM RELEASED TO PUBLIC DOMAIN }
{ THIS IS ONLY AN INCLUDE FILE FOR MOVIES.PAS }

PROCEDURE  GetFileName( var DummyFile: Text);

Var      FileName: String[14];   OK: Boolean;

Begin {PROCEDURE}
REPEAT
  Writeln;  Write(' What is the name of the file?  ');  Readln(FileName);
  Writeln;
  ASSIGN(DummyFile, FileName);
  {$I-}    RESET(DummyFile);   {$I+}     { See p. 114 }
  OK := (IOResult = 0);        { OK gets the value of the boolean expression }
  IF NOT OK THEN Writeln(#7' There is no such file ',FileName,' try another.')
UNTIL OK
End;  {PROCEDURE}
