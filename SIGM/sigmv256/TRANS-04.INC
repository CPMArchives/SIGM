
procedure SetFATPointer(Loc,Val: integer);
var
  I,R: integer;
begin
I:= ((Loc * 3) div 2) +1;
R:= (FAT[I] or (FAT[I+1] shl 8));
if odd(loc) then
  R:= ((R and $F) or (Val shl 4))
else
  R:= ((R and $F000) or (Val and $FFF));
FAT[I]:= (R and $FF);
FAT[I+1]:= ((R shr 8) and $FF);
end;



procedure WriteMS_DOS;
var
  FileName:       Str20;
  UnAmbiguous:    Str20;
  InFile:         File;
  ErrorCode:      integer;
  I:              integer;
  Stop:           boolean;
  RecsPerCluster: integer;
  Remaining:      integer;
  NRecs:          integer;
  FAT_Marker:     integer;
  LastMarker:     integer;


function FirstFree(Start: integer): integer;
var
  I: integer;
begin
I:= Start;
while (I < NClusters + 2) and (FATPointer(I) <> 0) do
  I:= I + 1;
FirstFree:= I;
if (I = NClusters + 2) then BiosError:= true;
end;


procedure ReWriteMS_DOS(FN: NameAry; FT: TypeAry);
var
  ErrorCode: integer;
  S:         Str20;
begin
S:= '????????.???';
VolumeName:= False;
SubDirName:= False;
SearchFirstAll(S,ErrorCode);
  while (ErrorCode <> MTDirectory)
    and (ErrorCode <> EODirectory)
    or VolumeName
    or SubDirName do
      SearchNextAll(S,ErrorCode);
if (ErrorCode = EODirectory) then
  BiosError:= true
else
  begin
  DOS_FCB^.Name:= FN;
  DOS_FCB^.Extention:= FT;
  DOS_FCB^.Attribute:= 0;
  for I:= 12 to 21 do DOS_FCB^.Rsrvd[I]:= 0;
  DOS_FCB^.Time:= 0;
  DOS_FCB^.Date:= 0;
  FAT_Marker:= FirstFree(2);
  DOS_FCB^.ClusterNo:= FAT_Marker;
  end;
end;


procedure CloseMS_DOS(Size: integer);
{ Size is filesize / 128 }
var
  Size2: integer;
begin
Size2:= hi(Size shr 1);       { prevent overflow }
Size:= ((Size and $1FF) shl 7);
DOS_FCB^.FileSize[1]:= lo(Size);
DOS_FCB^.FileSize[2]:= hi(Size);
DOS_FCB^.FileSize[3]:= lo(Size2);
DOS_FCB^.FileSize[4]:= hi(Size2);
if (Size = 0) then
  (* DOS_FCB^.Cluster:= $FFF *)
else
  SetFATPointer(LastMarker,$FFF);
WriteSector(DirSector,DirTrack,addr(DirBuffer));
PutFAT;
end;


begin (* WriteMS_DOS *)
IdentifyMS_DOS;
if not (Identity = Unidentified) then
  begin
  repeat
    ClrScr;
    writeln;
    writeln('File Transfer From CP/M to MS-DOS');
    writeln;
    write('File Name to Get From CP/M: ');
    readln(filename);
    writeln;
    Stop:= (pos(':',FileName) <> 0);
    if Stop then
      begin
      write('DriveCode = ',CPM_DriveCh);
      writeln(', Do Not Include In Name.');
      Continue;
      end;
    until not Stop;
  RecsPerCluster:= SecsPerCluster * SectorSize div 128;
  Stop:= false;


  SearchFileCPM(FileName,ErrorCode,First);
  if (ErrorCode = $FF) then
    write('File Not Found, ')
  else
    begin
    write('Transfering -');

    repeat
      UnAmbiguous:= '';
      for I:= 1 to NameSize do
        if not (CPM_FCB.Name[I] = ' ') then
          UnAmbiguous:= UnAmbiguous + CPM_FCB.Name[I];
      UnAmbiguous:= UnAmbiguous + '.';
      for I:= 1 to TypeSize do
        if not (CPM_FCB.Extention = ' ') then
          UnAmbiguous:= UnAmbiguous + CPM_FCB.Extention[I];

      SearchFirst(Unambiguous,ErrorCode);
      writeln;
      write(CPM_DriveCh + ':',UnAmbiguous);
      if (ErrorCode = FoundDir) then
        write(' Exists')
      else
        begin
        assign(InFile,UnAmbiguous);
        reset(InFile);

        ReWriteMS_DOS(CPM_FCB.Name,CPM_FCB.Extention);

        if not BiosError then
          begin
          Remaining:= FileSize(InFile);
          while (Remaining > 0) and not Stop do
            begin
            if (Remaining > RecsPerCluster) then
              NRecs:= RecsPerCluster
            else
              begin
              NRecs:= Remaining;
              for I:= 1 to RecsPerCluster * 128 do ClusterBuffer[I]:= Chr(0);
              end;
            BlockRead(InFile,ClusterBuffer,NRecs);
            SetFATPointer(FAT_Marker,FirstFree(FAT_Marker + 1));
            WriteCluster(FAT_Marker);
            LastMarker:= FAT_Marker;
            FAT_Marker:= FirstFree(FAT_Marker + 1);
            Stop:= BiosError or Stop;
            Remaining:= Remaining - NRecs;
            end;
          CloseMS_DOS(FileSize(InFile));
          end; (* if not bioserror *)
        end; (* if founddir *)

      if BiosError then
        begin
        Stop:= true;
        writeln;
        writeln('MS-DOS Write Error or Disk or Directory Full');
        end
      else
        begin
        SearchFileCPM(UnAmbiguous,ErrorCode,First);
        if (ErrorCode = 0) then
          SearchFileCPM(FileName,ErrorCode,Next);
        end;

      Stop:= (Stop or Break);
      until (ErrorCode = $FF) or Stop;

    writeln;
    writeln;
    end;
  if Stop then
    write('Aborted, ');
  Continue;
  end;
end;

