function Dir(Drive: char): integer;
  { This program will give a directory of specified drive.
    And returns the number of files on that drive }
const
  Search_First  = 17;
  Search_Next   = 18;
  Set_DMA       = 26;

var
  First: Boolean;
  Count, Total,
  Result, Loop, Start : Integer;
  FCB                 : array[0..35] of Byte;
  DMA                 : array[0..127] of Byte;
  ch : char;

begin
  First:= True;
  Count:= 0;
  Total:= 0;
  Result := BDos(Set_DMA,Addr(DMA));
  fillchar(FCB,sizeof(FCB),0); { fill FCB with 0}
  fillchar(FCB,12,'?'); {now make FCB 0 to 11 = ?}
  if Drive in ['A'..'P'] then  FCB[0] := ord(Drive) - $40  {select the drive}
    else FCB[0] := 0; {if not in range use the default drive}
  repeat
  if First then
     begin
       First := false;
       write('   ');
       Result := BDos(Search_First,Addr(FCB));
     end
  else
    Result := BDos(search_Next);

    Start := Result * 32;
    if Result <> 255 then begin
      for Loop:= Start to start+8 do
        Write(Char(DMA[Loop]and 127)); {and 127 to reset bit 8}
      Write('.');
     for Loop:= Start+9 to Start+11 do begin
       ch := Char(DMA[Loop]);
       if ch > '~' then begin
         lowvideo;
         write(Char(ord(ch)and 127));
         normvideo;
       end else write(ch);
     end;

    if Count < 4 then begin
       Count := Count + 1;
       Write(' | ');
      end
    else begin
       WriteLn;
       write('   ');
       Count := 0;
      end;

    Total := Total + 1;
  end;
 until Result=255;
 if count <> 0 then writeln;
 Dir := Total;
end; { of function Dir }

