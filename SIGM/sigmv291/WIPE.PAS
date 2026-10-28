program wipe_bak_files;
{
 Delete  CP/M-80 *.bak files while in Turbo environment.
 Ue by block reading to top of Turbo progrm, running, and then block erase.

                   ....Richard J. Hunter [70227,137]
                       June 13, 1985
}
const
  delete =  19; {bdos delete file function}
var
  fcb    :  string[12];
  result :  integer;

begin {main}
  fcb:='?????????BAK';
  fcb[1]:=char(0); {default drive}
  result:=bdos(delete,addr(fcb[1]));
  if result=255 then writeln('No files found!');
end. {main}
char(0); {default drive}
  result:=bdos(delete,addr(fcb[1]));
  if result=255 then writeln('No f