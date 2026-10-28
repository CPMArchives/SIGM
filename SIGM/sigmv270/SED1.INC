procedure setnumbuf;
begin
  while (numbuf>0) and (buffer[numbuf]=' ') do numbuf:=numbuf-1
end;

procedure pushtop;
begin
  setnumbuf;
  inline($3A/ numbuf/ $ED/ $5B/ ptop/
         $13/ $B7/ $28/ $08/ $06/ $00/ $4F/ $21/ buffer/
         $ED/ $B0/ $EB/ $36/ $0D/ $23/ $36/ $0A/ $22/
         ptop)
end;

procedure poptop;
begin
  inline($2A/ ptop/ $7E/ $B7/ $28/ $1C/ $0E/ $00/ $2B/
         $0C/ $7E/ $B7/ $28/ $04/ $FE/ $0A/ $20/ $F6/ $22/
         ptop/ $0D/ $0D/ $79/ $28/ $08/ $06/ $00/ $23/
         $11/ buffer/ $ED/ $B0/ $32/ numbuf)
end;

procedure pushbottom;
begin
  setnumbuf;
  inline($3A/ numbuf/ $2A/ pbotm/ $2B/
         $36/ $0A/ $2B/ $36/ $0D/ $B7/ $28/ $0E/ $2B/ $EB/
         $06/ $00/ $4F/ $21/ buffer/ $2B/ $09/ $ED/ $B8/ $EB/
         $23/ $22/ pbotm)
end;

procedure popbottom;
begin
  inline($2A/ pbotm/ $0E/ $00/ $11/ buffer/ $7E/ $FE/
         $1A/ $28/ $0C/ $FE/ $0D/ $28/ $06/ $12/ $13/ $23/
         $0C/ $18/ $F1/ $23/ $23/ $22/ pbotm/ $79/ $32/
         numbuf)
end;

procedure topbottom;
begin
  inline($2A/ ptop/ $23/ $ED/ $5B/
         pbotm/ $1A/ $FE/ $1A/ $28/ $0B/ $FE/ $0D/ $28/
         $05/ $77/ $13/ $23/ $18/ $F2/ $13/ $13/ $ED/ $53/
         pbotm/ $36/ $0D/ $23/ $36/ $0A/ $22/ ptop)
end;

procedure bottomtop;
begin
  inline($2A/ pbotm/ $2B/ $36/ $0A/
         $2B/ $36/ $0D/ $2B/ $ED/ $5B/ ptop/ $1A/ $B7/
         $28/ $0F/ $1B/ $1B/ $1A/ $B7/ $28/ $09/ $FE/ $0A/
         $28/ $05/ $77/ $1B/ $2B/ $18/ $F3/ $ED/ $53/
         ptop/ $23/ $22/ pbotm)
end;

procedure textbottom;
begin
  pushtop;
  while mem[pbotm]<>$1A do topbottom;
  repeat
    poptop
  until (numbuf>0) or (mem[ptop]=0)
end;

procedure texttop;
begin
  pushbottom;
  while mem[ptop]<>0 do bottomtop;
  repeat
    popbottom
  until (numbuf>0) or (mem[pbotm]=$1A)
end;

function getline(yto,yfrom:byte):byte;
var i,j:byte;
begin
  if yto>yfrom then
    begin
      pushtop;
      while yfrom<(yto-1) do
        begin
          topbottom;
          yfrom:=yfrom+1
        end;
      popbottom
    end
  else if yto<yfrom then
    begin
      pushbottom;
      while yfrom>(yto+1) do
        begin
          bottomtop;
          yfrom:=yfrom-1
        end;
      poptop
    end;
  getline:=yto
end;
