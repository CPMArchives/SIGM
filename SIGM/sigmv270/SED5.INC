procedure find1(var n:integer);
var i,j:byte;
begin
  if line1='' then n:=0
  else begin
    pushbottom; j:=0;
    for i:=x+1 to numbuf do begin j:=j+1; buffer[j]:=buffer[i] end;
    numbuf:=j; n:=pos(line1,sbuffer); popbottom;
    if n>0 then n:=x+n;
    while (n=0) and (mem[pbotm]<>$1A) do
      begin pushtop; popbottom; n:=pos(line1,sbuffer) end;
    if n>0 then x:=n else begin textbottom; x:=numbuf end;
    y:=halflength
  end
end;

procedure find;
var n:integer; line:linetype;
begin
  readline('find',line);
  if line<>'' then begin
    fr:=findsym; line1:=line; find1(n) end;
end;

procedure replace1(var n:integer);
var c:char;
begin
  find1(n);
  if n>0 then
    begin
      newscreen; sline(0); gotoxy(1,1);
      write('replace - space -');
      gotoxy(x,y+1); read(kbd,c); sline(0);
      if c=' ' then replaceline(x,length(line1),line2)
    end
end;

procedure replace;
var n:integer; line:linetype;
begin
  readline('replace from',line);
  if line<>'' then begin
    fr:=replacesym; line1:=line;
    readline('to',line2); replace1(n)
  end
end;
