procedure replaceline(xfrom,xlength:byte; line:linetype);
var k:integer; i,n:byte;
begin
  setnumbuf; k:=ptop+1; n:=0;
  for i:=1 to xfrom-1 do putmem(n,k,buffer[i]);
  for i:=1 to length(line) do putmem(n,k,line[i]);
  for i:=xfrom+xlength to numbuf do putmem(n,k,buffer[i]);
  putmem(n,k,newline); ptop:=k-1; poptop
end;

procedure connect;
var i,n:byte; k:integer;
begin
  pushtop; n:=numbuf; k:=ptop-1; popbottom;
  for i:=1 to numbuf do putmem(n,k,buffer[i]);
  putmem(n,k,newline); ptop:=k-1; poptop
end;

procedure searchmem(s:byte; c:char);
begin
  if s=1 then
    begin
      len:=ptop-startaddress;
      if len>0 then
        inline($3A/ c/ $ED/ $4B/ len/ $2A/ ptop/
               $ED/ $B9/ $23/ $22/ address)
    end
  else if s=2 then
    begin
      len:=endaddress-pbotm;
      if len>0 then
        inline($3A/ c/ $ED/ $4B/ len/ $2A/ pbotm/
               $ED/ $B1/ $2B/ $22/ address)
    end
end;

procedure erasemem(s:byte; mem1,mem2:integer);
begin
  if s=1 then
    begin
      len:=ptop-mem2;
      if len>0 then
        inline($ED/ $4B/ len/ $ED/ $5B/ mem1/ $2A/ mem2/
               $23/ $ED/ $B0/ $1B/ $ED/ $53/ ptop)
    end
  else if s=2 then
    begin
      len:=mem1-pbotm;
      if len>0 then
        inline($ED/ $4B/ len/ $ED/ $5B/ mem2/ $2A/ mem1/
               $2B/ $ED/ $B8/ $13/ $ED/ $53/ pbotm)
      else if len=0 then pbotm:=mem2+1
    end
end;

procedure search1(c:char; var s:byte; var m:integer);
begin
  m:=0; s:=2; searchmem(1,c);
  if mem[address]=ord(c) then s:=1 else searchmem(2,c);
  if mem[address]<>ord(c) then s:=0 else m:=address
end;

procedure eraseblock;
var s,t:byte; mem1,mem2:integer;
begin
  pushtop; search1(startblock,s,mem1); search1(endblock,t,mem2);
  if (mem2-mem1)>0 then
    begin
      if (s=t) then erasemem(s,mem1,mem2)
      else if (s=1) and (t=2) then
        begin
          mem[mem1]:=$D; mem[mem1+1]:=$A;
          ptop:=mem1+1; pbotm:=mem2+1; x:=1
        end
    end;
  poptop
end;

procedure writeblock;
var s,t:byte; mem1,mem2,i:integer; name:linetype; fil:text;
begin
  pushtop; search1(startblock,s,mem1); search1(endblock,t,mem2);
  if (s>0) and (t>0) and ((mem2-mem1)>0) then
    begin
      readline('write block name',name);
      assign(fil,name); rewrite(fil); i:=mem1+1;
      if t>s then
        begin
          while i<>ptop+1 do
            begin write(fil,chr(mem[i])); i:=i+1 end;
          i:=pbotm
        end;
      while i<>mem2 do
        begin write(fil,chr(mem[i])); i:=i+1 end;
      close(fil)
    end;
  poptop
end;

procedure readblock;
var c:char; k:integer; name:linetype; fil:text;
begin
  replaceline(x,0,newline); pushbottom; numbuf:=x-1; k:=ptop-1;
  readline('read block name',name);
  assign(fil,name); {$I-} reset(fil) {$I+};
  if ioresult=0 then
    begin
      putmem(numbuf,k,startblock);
      while not eof(fil) do
        begin read(fil,c); putmem(numbuf,k,c) end;
      putmem(numbuf,k,endblock)
    end;
  close(fil); putmem(numbuf,k,newline); ptop:=k-1; poptop; connect
end;

procedure cmblock(copy:boolean);
var s,t:byte; k,m,mem1,mem2:integer;
begin
  replaceline(x,0,newline);pushbottom; numbuf:=x-1; k:=ptop-1;
  search1(startblock,s,mem1); search1(endblock,t,mem2); m:=mem1;
  if ((mem2-mem1)>0) and (s=t) then
    while m<>(mem2+1) do
      begin putmem(numbuf,k,chr(mem[m])); m:=m+1 end;
  putmem(numbuf,k,newline); ptop:=k-1;
  if ((mem2-mem1)>0) and (s=t) then
    if copy then
      begin
        if s=1 then
          begin erasemem(s,mem2,mem2); erasemem(s,mem1,mem1) end
        else if s=2 then
          begin erasemem(s,mem1,mem1); erasemem(s,mem2,mem2) end
      end
    else erasemem(s,mem1,mem2);
  poptop; connect
end;

procedure erasemark;
var s:byte; m:integer;
begin
  pushtop;
  repeat search1(startblock,s,m); erasemem(s,m,m); until s=0;
  repeat search1(endblock,s,m); erasemem(s,m,m); until s=0;
  poptop
end;
