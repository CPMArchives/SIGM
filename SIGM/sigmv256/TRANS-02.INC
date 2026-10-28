

procedure ConvertName(Str: Str20; var N: NameAry; var T: TypeAry);
var
  I,J: integer;
begin
for I:= 1 to NameSize do N[I]:= ' ';
for I:= 1 to TypeSize do T[I]:= ' ';
if (Str = '') then Str:= '*.*';
if (pos('.',Str) = 0) then Str:= concat(Str,'.');
if not (pos('.',Str)-1 > NameSize) then
  for I:= 1 to pos('.',Str)-1 do
    N[I]:= upcase(Str[I]);
if not (length(copy(Str,pos('.',Str)+1,20)) > TypeSize) then
  for I:= pos('.',Str)+1 to length(Str) do
    T[I-pos('.',Str)]:= upcase(Str[I]);
for I:= 1 to NameSize do
  if (N[I] = '*') then
    for J:= I to NameSize do
      N[J]:= '?';
for I:= 1 to TypeSize do
  if (T[I] = '*') then
    for J:= I to TypeSize do
      T[J]:= '?';
end;



function SameName(S: Str20; FN: NameAry; FT: TypeAry): boolean;
var
  N: NameAry;
  T: TypeAry;
  I,J: integer;
  Match: boolean;
begin
ConvertName(S,N,T);
Match:= true;
for I:= 1 to NameSize do
  if ((N[I] <> FN[I]) and (N[I] <> '?')) then
    Match:= False;
for I:= 1 to TypeSize do
  if ((T[I] <> FT[I]) and (T[I] <> '?')) then
    Match:= False;
SameName:= Match;
end;



procedure SearchNextAll(FileName: Str20; var Error: integer);
const
  SizePC_FCB = 32;
var
  I,FCBsPerSector: integer;

begin
repeat
  Error:= FoundDir;  { default }
  FCBsPerSector:= (SectorSize div SizePC_FCB);

  if ((DirOffset mod FCBsPerSector) = 0) then
    begin
    DirOffset:= 0;
    NextSector(DirSector,DirTrack);
    ReadSector(DirSector,DirTrack,Addr(DirBuffer));
    DirSectorCount:= DirSectorCount +1;
    end;

  if (DirSectorCount < DirSecs) then
    begin
    DOS_FCB:= ptr(addr(DirBuffer) + (DirOffset * SizePC_FCB));
    if (DOS_FCB^.Name[1] in [#0,#$F6,#$E5]) then
      Error:= MTDirectory;
    end
  else
    Error:= EODirectory;
  DirOffset:= DirOffset +1;
  until ((Error = EODirectory)
    or (Error = MTDirectory)
    or (SameName(FileName,DOS_FCB^.Name,DOS_FCB^.Extention)));

If (Error = EODirectory) Then
  Begin
  VolumeName:= False;
  SubDirName:= False;
  End
Else
  Begin
  VolumeName:= (DOS_FCB^.Attribute and $08) <> 0;
  SubDirName:= (DOS_FCB^.Attribute and $10) <> 0;
  End
end;



procedure SearchNext(FN: Str20; var Err: integer);
begin
repeat
  SearchNextAll(FN,Err);
  if (DOS_FCB^.Name[1] = #0) then { "high water" mark }
    Err:= EODirectory;
  until ((Err = EODirectory) or (Err = FoundDir));
end;



procedure SearchFirstAll( FileName: Str20; var Error: integer );
const
  SizePC_FCB = 32;
var
  I: integer;
begin
DirOffset:= 0;
DirTrack:= 0;
DirSectorCount:= -1;
DirSector:= FirstDirSector -1;
SearchNextAll(FileName,Error);
end;



procedure SearchFirst(FN: Str20; var Err: integer);
begin
SearchFirstAll(FN,Err);
if (Err = MTDirectory) then
  SearchNext(FN,Err);
end;



procedure IdentifyMS_DOS;
begin
SectorSize:= 512;
RecordsPerSector:= SectorSize div 128;
FirstFATSector:= 1;
GetFAT;
case FAT[1] of
  $FF:
    begin
    Identity:=       ds8spt;
    FATSize:=        1;          (* size of FAT in sectors (1 copy)*)
    DirSecs:=        7;          (* number of sectors in directory *)
    NTracks:=        80;         (* number of tracks on disk       *)
    NSectors:=       8;          (* number of sectors per track    *)
    SecsPerCluster:= 2;          (* number of sectors per cluster  *)
    SingleSided:=    false;
    end;
  $FE:
    begin
    Identity:=       ss8spt;
    FATSize:=        1;
    DirSecs:=        4;
    NTracks:=        40;
    NSectors:=       8;
    SecsPerCluster:= 1;
    SingleSided:=    true;
    end;
  $FD:
    begin
    Identity:=       ds9spt;
    FATSize:=        2;
    DirSecs:=        7;
    NTracks:=        80;
    NSectors:=       9;
    SecsPerCluster:= 2;
    SingleSided:=    false;
    end;
  $FC:
    begin
    Identity:=       ss9spt;
    FATSize:=        2;
    DirSecs:=        4;
    NTracks:=        40;
    NSectors:=       9;
    SecsPerCluster:= 2;
    SingleSided:=    true;
    end;
else
  begin  (* Try Another Sector Size *)
  SectorSize:= 256;
  FirstFATSector:= 2;
  RecordsPerSector:= SectorSize div 128;
  GetFAT;
  Case FAT[1] of
    $F8:
      Begin
      Identity:=       B_20; (* Burroughs B-20 *)
      FATSize:=        2;
      DirSecs:=        18;
      NTracks:=        160;
      NSectors:=       16;
      SecsPerCluster:= 8;
      SingleSided:=    false;
      End;
  else
    Begin
    Identity:= Unidentified;
    gotoxy(1,23);
    write('Cannot Identify MS-DOS Disk, ');
    Continue;
    end; (* else Case *)
    end; (* Case      *)
  end;   (* else Case *)
  end;   (* Case      *)
if not (Identity = Unidentified) then
  begin
  FirstDirSector:=   FatSize * 2 + FirstFATSector;
  FirstDataSector:=  (FirstDirSector + DirSecs) mod NSectors;
  FirstDataTrack:=   (FirstDirSector + DirSecs) div NSectors;
  NClusters:= (NTracks * NSectors div SecsPerCluster)
              - (((FATSize * 2) + DirSecs + 1) div SecsPerCluster);
  end;
end;



procedure RestoreFAT;
var
  S,T,I: integer;
begin
writeln;
write('FAT Size in Sectors? (1,2..) ');
readln(FATSize);
FATSize:= (FATSize and 3);
S:= 1 + FATSize;
T:= 0;
for I:= 0 to FATSize-1 do
  begin
  ReadSector(S,T,addr(FAT) + (SectorSize * I));
  NextSector(S,T);
  PutFAT;
  end
end;


