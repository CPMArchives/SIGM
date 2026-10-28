function getnextc(c:char):char;
var r:char;
begin
  gotoxy(1,1); write('^',c);
  gotoxy(x,y+1); read(kbd,r); getnextc:=chr(ord(r)+ord('@'));
  gotoxy(1,1); write('  ')
end;

procedure deletechar;
var i:byte;
begin
  for i:=x to width-1 do buffer[i]:=buffer[i+1];
  buffer[width]:=' '
end;

procedure insertchar(r:char);
var i:byte;
begin
  for i:=width downto x+1 do buffer[i]:=buffer[i-1];
  buffer[x]:=r
end;

procedure deleteword;
var i,j,k:byte;
begin
  i:=x;
  if buffer[i] in wordset then
    while (buffer[i] in wordset) and (i<=numbuf) do i:=i+1
  else
    while not (buffer[i] in wordset) and (i<=numbuf) do i:=i+1;
  k:=x;
  for j:=i to numbuf do begin buffer[k]:=buffer[j]; k:=k+1 end;
  numbuf:=k-1
end;

procedure screenup;
begin
  rollup(1,slength);
  pline(getline(slength,y-1));
  y:=getline(y,slength)
end;

procedure screendown;
begin
  rolldown(1,slength);
  pline(getline(1,y+1));
  y:=getline(y,1)
end;

procedure linedown;
var i:byte;
begin
  if y<slength then y:=getline(y+1,y)
  else begin rollup(1,slength); i:=getline(1,0) end
end;

procedure lineup;
var i:byte;
begin
  if y>1 then y:=getline(y-1,y)
  else begin rolldown(1,slength); i:=getline(0,1) end;
end;

procedure wordleft;
begin
  x:=x-1;
  repeat
    if x=0 then begin lineup; pline(y); x:=numbuf end;
    while not (buffer[x] in wordset) and (x>0) do x:=x-1;
  until (x>0) or (mem[ptop]=0);
  while (buffer[x] in wordset) and (x>0) do x:=x-1;
  x:=x+1
end;

procedure wordright;
begin
  while (buffer[x] in wordset) and (x<=numbuf) do x:=x+1;
  repeat
    if x>numbuf then begin linedown; pline(y); x:=1 end;
    while not (buffer[x] in wordset) and (x<=numbuf) do x:=x+1;
  until (x<=numbuf) or (mem[pbotm]=$1A)
end;

procedure connectline;
var s:byte; m:integer;
begin
  buffer[x]:=mark; numbuf:=x;
  while mem[pbotm]=ord(' ') do pbotm:=pbotm+1;
  connect; pushtop; search1(mark,s,m); erasemem(s,m,m); poptop
end;

procedure mostleft;
begin
  x:=1;
  while (buffer[x]=' ') and (x<=width) do x:=x+1;
  if x>width then x:=1
end;

procedure mostright;
begin
  setnumbuf;
  if numbuf=0 then x:=width
  else if numbuf<width then x:=numbuf+1
end;
