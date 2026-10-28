{ [GRAPHN88.PAS of JUGPDS Vol.11] }

{ Graphic Routines for NEC PC-8801
    by K. Nakazato   Nov. 23, 1984   }

procedure gon;
begin
  port[$31]:=$3B
end;

procedure goff;
begin
  port[$31]:=$37
end;

procedure gcls;
var wsp:integer;
begin
  inline( $F3/ $ED/ $73/ wsp/ $3E/ $5C/ $21/ $00/ $00/
          $31/ $80/ $FE/ $06/ $FA/ $4F/ $ED/ $79/ $E5/
          $E5/ $E5/ $E5/ $E5/ $E5/ $E5/ $E5/ $E5/ $E5/
          $E5/ $E5/ $E5/ $E5/ $E5/ $E5/ $E5/ $E5/ $E5/
          $E5/ $E5/ $E5/ $E5/ $E5/ $E5/ $E5/ $E5/ $E5/
          $E5/ $E5/ $E5/ $E5/ $10/ $DE/ $3C/ $FE/ $5F/
          $20/ $D1/ $D3/ $5F/ $ED/ $7B/ wsp/ $FB)
end;


procedure dotset(x,y,c:integer);
begin
  inline( $2A/   y/ $01/ $C8/ $00/ $54/ $5D/ $B7/ $ED/
          $42/ $30/ $F9/ $EB/ $29/ $29/ $29/ $29/ $54/
          $5D/ $29/ $29/ $19/ $11/ $00/ $C0/ $19/ $E5/
          $2A/   x/ $01/ $80/ $02/ $54/ $5D/ $B7/ $ED/
          $42/ $30/ $F9/ $EB/ $7D/ $E6/ $07/ $06/ $80/
          $B7/ $28/ $05/ $CB/ $08/ $3D/ $20/ $FB/ $CB/
          $3C/ $CB/ $1D/ $CB/ $3C/ $CB/ $1D/ $CB/ $3C/
          $CB/ $1D/ $D1/ $19/ $3A/   c/ $57/ $0E/ $5C/
          $F3/ $78/ $ED/ $79/ $CB/ $3A/ $38/ $04/ $2F/
          $A6/ $18/ $01/ $B6/ $77/ $0C/ $79/ $FE/ $5F/
          $20/ $ED/ $ED/ $79/ $FB)
end;

procedure drawline(x1,y1,x2,y2,c:integer);
var dx,dy,accx,accy,x,y:integer; sdx,sdy:boolean;
begin
  dx:=abs(x2-x1); dy:=abs(y2-y1);
  if (dx>0) or (dy>0) then
    while ((dx and $4000)=0) and ((dy and $4000)=0) do
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
  if color>=0 then drawline(x+320,100-y,x1+320,100-y1,color);
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

procedure cls(g:boolean);
var addr:integer; i,attr:byte;
begin
  if g then begin goff; gcls; gon end else clrscr
end;

procedure initturtle;
begin
  cls(false); cls(true);
  x:=0; y:=0; angle:=0; color:=-1
end;
