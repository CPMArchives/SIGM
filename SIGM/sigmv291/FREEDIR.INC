function FreeDir(Drive: char): integer;
  { This function will give free directory entries of specified drive. }
const
  Search_First  = 17;
  Search_Next   = 18;
  Set_DMA       = 26;
  Current_Drive = 25;
  Set_Drive     = 14;

var
  First: Boolean;
  Total, dirmax : integer;
  HomeDrive,
  Result, Loop, Start : byte;
  FCB                 : array[0..35] of Byte;
  DMA                 : array[0..127] of Byte;

begin
  First:= True;
  Total:= 0;
  HomeDrive := BDOS(Current_Drive);
  if Drive in ['A'..'P'] then
    BDOS(Set_Drive,ord(Drive)-$41);  {drive must be in 0..15}
  fillchar(FCB,sizeof(FCB),0);
  fillchar(FCB,12,'?');
  Result := BDos(Set_DMA,Addr(DMA));
  repeat
    if First then
       begin
         First := false;
         Result := BDos(Search_First,Addr(FCB));
       end
    else
      Result := BDos(search_Next);
    Start := Result * 32;
    if (Result <> 255) and (dma[start] <> $E5) then Total := Total + 1
  until Result=255;
  INLINE (
    $0E/$1F/$CD/$05/$00/         {2.X or MP/M...request DPB}
    $23/$23/$23/$23/$23/$23/$23/ {Bump to directory size}
    $5E/$23/$56/$EB/$23/         {Get directory size and add 1}
    $22/DIRMAX/$00);             {Save max # of entries in directory}
  BDOS(Set_drive,HomeDrive);
  FreeDir := dirmax-total;
end; { of function FreeDir }
