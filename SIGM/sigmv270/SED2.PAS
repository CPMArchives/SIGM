{  Small editor                              }
{    by K.Nakazato  Ver. 1.00  Feb. 10, 1984 }
{                        1.13  Jul. 14, 1984 }

const maxtext =$7FFF;
type  texttype=array [0..maxtext] of char;
var   textbuf :texttype;
      position:integer;

{$I SED.INC}

begin
  sedit(textbuf,false,position)
end.
