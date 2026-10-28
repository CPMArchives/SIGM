
(* module 3 *)



procedure SearchFileCPM( FileName: Str20; var Error: integer; First: boolean );
const
  SizeCPM_FCB = 32;
  SearchF = 17;
  SearchN = 18;
  SetDMAF = 26;
var
  I,J: integer;
begin
BDos(SetDMAF,addr(CPM_Buf));
ConvertName(FileName,CPM_FCB.Name,CPM_FCB.Extention);
CPM_FCB.DriveCode:= CPM_Drive + 1;
CPM_FCB.Extent:= 0;
CPM_FCB.CR:= 0;
if First then
  I:= BDos(SearchF,addr(CPM_FCB))
else
  I:= BDos(SearchN,addr(CPM_FCB));
if (I = $FF) then
  Error:= EODirectory
else
  begin
  Error:= 0;
  I:= (((I and 3) * SizeCPM_FCB) + 1);
  for J:= 0 to (NameSize + TypeSize)  do
    mem[addr( CPM_FCB ) + J]:= mem[ addr( CPM_Buf[I]) + J];
  end;
end;



procedure DirCPM;
const
  First = true;
  Next  = false;
var
  ErrorCode,
  Count,
  I,N:      integer;
  FileName: Str20;
begin
Count:= 0;
ClrScr;
writeln;
write('Dir Mask: ');
readln(FileName);
writeln;
SearchFileCPM(FileName,ErrorCode,First);

if (ErrorCode = EODirectory) then
  begin
  write('No File, ');
  Continue;
  end
else
  begin
  repeat
    if ((Count mod 4) = 0) then
      writeln
    else
      write('  :  ');
    write(CPM_DriveCh,':');
    for I:= 1 to NameSize do
      write(CPM_FCB.Name[I]);
    write('.');
    for I:= 1 to TypeSize do
      write(CPM_FCB.Extention[I]);
    Count:= Count + 1;
    SearchFileCPM(FileName,ErrorCode,Next);
    until (ErrorCode = EODirectory) or Break;
  writeln;
  writeln;
  writeln('File Count: ',Count);
  Continue;
  end;
end;



(* end module 3 *)
