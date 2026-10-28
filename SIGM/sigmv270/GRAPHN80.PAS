{ [GRAPHN80.PAS of JUGPDS Vol.11] }

{ Semi-Ggraphic Routines for NEC PC-8001
          by K. Nakazato   Nov. 23, 1984   }

procedure cls(g:boolean);
var addr:integer; i,attr:byte;
begin
  clrscr; addr:=$F350;
  if g then attr:=$80 else attr:=0;
  for i:=1 to 24 do begin
    mem[addr]  :=1;  mem[addr+1]:=attr;
    mem[addr+2]:=81; addr:=addr+$78
  end
end;

procedure dotset(x,y,color:integer);
var ad:integer; bit:byte;
begin
  x:=x mod 160; y:= y mod 100;
  ad:=$F300+(y and $fc)*30+x shr 1;
  bit:=1 shl ( y and 3+(x and 1) shl 2);
  if color>0 then mem[ad]:=mem[ad] or bit
  else if color=0 then mem[ad]:=mem[ad] and not bit
end;

procedure drawline(x1,y1,x2,y2,c:integer);
var dx,dy,accx,accy,x,y:integer; sdx,sdy:boolean;
begin
  dx:=abs(x2-x1); dy:=abs(y2-y1);
  if (dx>0) or (dy>0) then
    while (dx and $4000=0) and (dy and $4000=0) do
      begin dx:=dx shl 1; dy:=dy shl 1 end;
  accx:=$4000; accy:=accx;
  sdx:=x2>x1; sdy:=y2>y1;
  x:=x1; y:=y1; dotset(x,y,c);
  while (x<>x2) or (y<>y2) do
    begin
      accx:=accx+dx;
      if accx<0 then
        begin
          if sdx then x:=x+1 else x:=x-1;
          accx:=accx and $7FFF
        end;
      accy:=accy+dy;
      if accy<0 then
        begin
          if sdy then y:=y+1 else y:=y-1;
          accy:=accy and $7FFF
        end;
      dotset(x,y,c)
    end
end;

{ turtle }

var x,y,angle,color:integer;

procedure moveto(x1,y1:integer);
begin
  if color>=0 then drawline(x+80,49-y,x1+80,49-y1,color);
  x:=x1; y:=y1
end;

procedure move(dest:integer);
var angle1:real;
begin
  angle1:=angle*pi/180.0;
  moveto(x+round(dest*cos(angle1)),y+round(dest*sin(angle1)))
end;

procedure turnto(i:integer);
begin
  angle:=i mod 360
end;

procedure turn(i:integer);
begin
  turnto(angle+i)
end;

procedure pascolor(i:integer);
begin
  color:=i
end;

procedure initturtle;
begin
  cls(true); x:=0; y:=0; angle:=0; color:=-1
end;
