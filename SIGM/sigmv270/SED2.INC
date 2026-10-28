procedure setvramaddr;
var i:byte;
begin
  vramaddr[0]:=$F300;
  for i:=1 to 24 do vramaddr[i]:=vramaddr[i-1]+$78
end;

procedure tline(yto,yfrom:byte);
begin
  vram1:=vramaddr[yfrom]; vram:=vramaddr[yto];
  inline($2A/ vram1/ $ED/ $5B/ vram/
         $3A/ width/ $4F/ $06/ $00/ $ED/ $B0)
end;

procedure sline(y:byte);
begin
  vram:=vramaddr[y];
  inline($2A/ vram/ $3A/ width/ $47/
         $3E/ $20/ $77/ $23/ $10/ $FC)
end;

procedure pline(y:byte);
begin
  vram:=vramaddr[y];
  inline($2A/ vram/ $EB/ $21/ buffer/ $3A/ numbuf/
         $B7/ $28/ $05/ $06/ $00/ $4F/ $ED/ $B0/ $47/
         $3A/ width/ $90/ $C8/ $D8/ $47/ $3E/ $20/
         $12/ $77/ $13/ $23/ $10/ $FA)
end;

procedure rolldown(y1,y2:byte);
begin
  while y1<y2 do begin y2:=y2-1; tline(y2+1,y2) end
end;

procedure rollup(y1,y2:byte);
begin
  while y1<y2 do begin y1:=y1+1; tline(y1-1,y1) end
end;

procedure newscreen;
var n:byte;
begin
  n:=getline(1,y);
  while n<=slength do
     begin pline(n); n:=getline(n+1,n) end;
  n:=getline(y,n)
end;
