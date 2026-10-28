

Function SizeDOS_File(Var A: SizeArray): Real;
Begin
SizeDOS_File:= (A[1] + (256.0 * A[2]) + (256.0 * 256.0 * A[3]) +
    (256.0 * 256.0 * 256.0 * A[4]));
End;

procedure ReadMS_DOS;
var
  FileName:          Str20;
  CPMName:           Str20;
  I,Err:             integer;
  CPMFile:           File;
  Cl:                integer;
  RecordsPerCluster: integer;
  Stop:              boolean;
  Size:              Real;
begin
IdentifyMS_DOS;
if not (Identity = Unidentified) then
  begin
  ClrScr;
  writeln;
  writeln('File Transfer From MS-DOS to CP/M');
  writeln;
  write('File Name to Get From MS-DOS: ');
  readln(FileName);
  writeln;
  Stop:= false;

  SearchFirst(FileName,Err);
  While VolumeName or SubDirName do
    SearchNext(FileName,Err);

  if (Err = EODirectory) then
    begin
    write('File Not Found, ');
    end
  else
    begin
    write('Transfering -');
    RecordsPerCluster:= RecordsPerSector * SecsPerCluster;

    repeat
      CPMName:= '';
      for I:= 1 to NameSize do
        if not (DOS_FCB^.Name[I]=' ') then
          CPMName:= CPMName + DOS_FCB^.Name[I];
      CPMName:= CPMName + '.';
      for I:= 1 to TypeSize do
        CPMName:= CPMName + DOS_FCB^.Extention[I];
      CPMName:= concat(CPM_DriveCh,':',CPMName);
      writeln; write(CPMName);
      assign(CPMFile,CPMName);
      rewrite(CPMFile);
      Cl:= DOS_FCB^.ClusterNo;

      Size:= SizeDOS_File(DOS_FCB^.FileSize);
      while (Cl < $FF8) do
        begin
        ReadCluster(Cl);
        For I:= 1 to RecordsPerCluster do
          Begin
          If Size < 128.0 Then (* Put in CP/M EOF Char *)
            ClusterBuffer[((I - 1) * 128) + Trunc(Size) + 1]:= ^Z;
          If Size > 0.01 Then (* Don't Compare Reals With Zero *)
            blockwrite(CPMFile,ClusterBuffer[((I - 1) * 128) + 1],1);
          Size:= Size - 128.0;
          End;
        Cl:= FATPointer(Cl); (* Point to Next Cluster *)
        end;

      close(CPMFile);
      Repeat
        SearchNext(FileName,Err);
        Until Not (VolumeName or SubDirName);
      Stop:= Break;
      until (Err = EODirectory) or Stop;

    writeln;
    writeln;
    end;
  if Stop then write('Aborted, ');
  Continue;
  end;
end;



procedure DirMS_DOS;
var
  ErrorCode,
  Count,
  I,N:         integer;
  X:           real;
  FileName:    Str20;
  MonthString: array[0..38] of char;
begin
MonthString:= '...JanFebMarAprMayJunJulAugSepOctNovDec';
Count:= 0;
IdentifyMS_DOS;
if not (Identity = Unidentified) then
  begin
  ClrScr;
  writeln;
  write('Dir Mask: ');
  readln(FileName);
  writeln;
  writeln('Name',
  'Attrubutes':18,
    'Clstr':7,
    'Date':13,
    'Time':10,
    'Size':8);
  for I:= 1 to 59 do write('-');
  SearchFirst(FileName,ErrorCode);
  repeat
    if (ErrorCode = 0) then
      begin
      writeln;
      Count:= Count + 1;

      with DOS_FCB^ do
        begin
        for I:= 1 to NameSize do write(Name[I]);
        write('.');
        for I:= 1 to TypeSize do write(Extention[I]);
        write('  ');
        N:= Attribute;

        If VolumeName Then
          Write('<VolNam>')
        Else if SubDirName Then
          Write('<SubDir>')
        Else
          for I:= 1 to 8 do
            begin
            write(chr(((N shr 7) and 1) + $30));
            N:= N shl 1;
            end;

        write(ClusterNo:7);
        write('  ');
        N:= ((Date shr 5) and $F);
        if (N > 12) then N:= 0;
        N:= N * 3;
        for I:= N to N+2 do write(MonthString[I]);
        write(' ');
        N:= Date and $1F;
        if N < 10 then write('0');
        write(N);
        write(',',(Date shr 9) + 1980);

        write('  ');
        N:= (Time shr 11);
        if N < 10 then write('0');
        write(N,':');
        N:= ((Time shr 5) and 63);
        if N < 10 then write('0');
        write(N,':');
        N:= ((Time and $1F) * 2);
        if N < 10 then write('0');
        write(N);
        write('  ',SizeDOS_File(FileSize):6:0);
        end;
      end;
    SearchNext(FileName,ErrorCode);
    until (ErrorCode = $FF) or Break;
  writeln;
  writeln;
  writeln('File Count: ',Count);
  Continue;
  end;
end;



procedure MapMS_DOS;
begin
IdentifyMS_DOS;
if not (Identity = Unidentified) then
  begin
  ClrScr;
  for I:= 0 to NClusters -1 do
    begin
    if (I mod 18) = 0 then writeln;
    write(FATPointer(I + 2),',')
    end;
  writeln;
  writeln;
  continue;
  end;
end;

