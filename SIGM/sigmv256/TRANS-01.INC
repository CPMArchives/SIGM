
(* module 01 *)

procedure Box(X1,Y1,X2,Y2: integer);
var
  I: integer;
begin
gotoxy(X1,Y1);
for I:= X1 to X2 do write('*');
for I:= Y1 to Y2 do
  begin
  gotoxy(X2,I);
  write('*');
  end;
gotoxy(X1,Y2);
for I:= X2 downto X1 do write('*');
for I:= Y2 downto Y1 do
  begin
  gotoxy(X1,I);
  write('*');
  end;
end;



function MainSelection: char;
var
  Ch: char;
begin
ClrScr;
Box(13,5,60,22);
writeln('* TRANSFER - vers ',Vers:0:1,' ');
gotoxy(MenuMargin,8);
write('   CP/M= ',chr(CPM_Drive+ord('A')),':');
write('             MS-DOS= ',chr(MS_DOS_Drive+ord('A')),':');

gotoxy(MenuMargin,10);
write('1. Transfer File:  CP/M ==> MS-DOS');

gotoxy(MenuMargin,11);
write('2. Transfer File:  CP/M <== MS-DOS');

gotoxy(MenuMargin,12);
write('3. Directory of      MS-DOS Disk');

gotoxy(MenuMargin,13);
write('4. Allocation Map    MS-DOS Disk');

gotoxy(MenuMargin,14);
write('5. Directory of      CP/M Disk');

gotoxy(MenuMargin,15);
write('6. Erase File        MS-DOS Disk');

gotoxy(MenuMargin,16);
write('7. Restore FAT');

gotoxy(MenuMargin,17);
write('8. Quit');

repeat
  gotoxy(MenuMargin,19);
  write('   Enter Your Selection? ');
  read(KBD,Ch);
  until (Ch in ['1'..'9']);
MainSelection:= Ch;
end;



procedure Continue;
begin
write('Press [Return] to Continue..');
repeat
  read(KBD,Selection);
  until (Selection = #$D);
end;



procedure NextSector(var S: integer; var T: integer);
begin
S:= S + 1;
if (S >= NSectors) then
  begin
  S:= MinSector;
  T:= T + 1;
  end;
end;



procedure DiskError;
begin
writeln;
write('Disk I/O Error, ');
Continue;
end;



procedure BiosSelect(DriveCode: integer);
begin
BiosError:=(BiosHL(8,DriveCode)=0);
end;



procedure ReadSector(Sector,Track,Address: integer);
var
  Rec: integer;
  RPS: integer;
  I:   integer;
begin
if SingleSided then Track:= Track * 2;
RPS:= SectorSize div 128;
BiosSelect(MS_DOS_Drive);
BiosError:= False;
for I:= 0 to (RPS -1)do
  begin
  bios(9,track);                               (* select track     *)
  if SecTrans then
    Rec:= BiosHL(15,Sector * RPS + I + SO)     (* translate sector *)
  else
    Rec:= (Sector * RPS + I + SO);
  bios(10,Rec);                                (* select sector    *)
  bios(11,(I * 128) + Address);                (* set dma addr     *)
  BiosError:= (BiosError or (bios(12)<>0));    (* read 128 bytes   *)
  end;
bios(8,DefaultDisk);
if BiosError then DiskError;
end;



procedure WriteSector(Sector,Track,Address: integer);
var
  Rec: integer;
  RPS: integer;
  I:   integer;
begin
if SingleSided then Track:= Track * 2;
RPS:= SectorSize div 128;
BiosSelect(MS_DOS_Drive);
BiosError:= False;
for I:= 0 to (RPS -1)do
  begin
  bios(9,track);                               (* select track     *)
  if SecTrans then
    Rec:= BiosHL(15,Sector * RPS + I + SO)     (* translate sector *)
  else
    Rec:= (Sector * RPS + I + SO);
  bios(10,Rec);                                (* select sector    *)
  bios(11,(I * 128) + Address);                (* set dma addr     *)
  BiosError:= (BiosError or (bios(13)<>0));    (* read 128 bytes   *)
  end;
bios(8,DefaultDisk);
if BiosError then DiskError;
end;



procedure GetFAT;
begin
ReadSector(FirstFATSector,0,addr(FAT));
ReadSector(FirstFATSector + 1,0,addr(FAT)+SectorSize);
end;


procedure PutFAT;
var
  S,T,I: integer;
begin
S:= FirstFATSector;
T:= 0;
for I:= 0 to FATSize-1 do
  begin
  WriteSector(S,T,addr(FAT) + (SectorSize * I));
  NextSector(S,T);
  end;
end;


procedure ReadCluster(Cl: integer);
var
  I:      integer;
  Sector: integer;
  Track:  integer;
begin
Cl:= Cl - 2;
Track:= (Cl * SecsPerCluster) div NSectors;
Sector:= (Cl * SecsPerCluster) mod NSectors;
Sector:= Sector + FirstDataSector;
Track:= Track + FirstDataTrack + (Sector div NSectors);
Sector:= Sector mod NSectors;
for I:= 0 to (SecsPerCluster -1) do
  begin
  ReadSector(Sector,Track,addr( ClusterBuffer[ I * SectorSize + 1] ));
  NextSector(Sector,Track);
  end;
end;



procedure WriteCluster(Cl: integer);
var
  I:      integer;
  Sector: integer;
  Track:  integer;
begin
Cl:= Cl - 2;
Track:= (Cl * SecsPerCluster) div NSectors;
Sector:= (Cl * SecsPerCluster) mod NSectors;
Sector:= Sector + FirstDataSector;
Track:= Track + FirstDataTrack + (Sector div NSectors);
Sector:= Sector mod NSectors;
for I:= 0 to (SecsPerCluster -1) do
  begin
  WriteSector(Sector,Track,addr( ClusterBuffer[ I * SectorSize + 1] ));
  NextSector(Sector,Track);
  end;
end;



function FATPointer(Index: integer): Integer; (* 2..NClusters + 2 *)
var
  Result,I:    Integer;
  OddNum:      Boolean;
begin
I:= ((Index * 3) div 2) +1;
Result:= (FAT[I] + (256 * FAT[I + 1]));
if odd(Index) then Result:= Result shr 4;
FATPointer:= (Result and $FFF);
end;



function Break: boolean;
var
  Ch: char;
begin
if KeyPressed then
  begin
  read(KBD,Ch);
  if (Ch = ^S) then
    begin
    while not KeyPressed do;
    read(KBD,Ch);
    end;
  if (Ch = #27) then
    Break:= true
  else
    Break:= false;
  end
else
  Break:= false;
end;



(* end module 01 *)
