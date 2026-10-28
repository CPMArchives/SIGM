procedure dispinsert;
begin
  gotoxy(70,1);
  if insert then write('insert   ') else write('overwrite')
end;

procedure readline(prompt:linetype; var line:linetype);
begin
  sline(0); gotoxy(1,1);
  write(prompt,' ? '); readln(line); sline(0)
end;

procedure putmem(var i:byte; var k:integer; c:char);
begin
  if (pbotm-k)>255 then
    begin
      if (c=newline) or (i>=width) then
        begin mem[k]:=$D; mem[k+1]:=$A; k:=k+2; i:=0 end;
      if (c>=#$20) then
        begin mem[k]:=ord(c); k:=k+1; i:=i+1 end
    end
  else begin mem[k-2]:=$D; mem[k-1]:=$A end
end;

procedure settext;
var c:char; j:byte; i:integer; infil:text;
begin
  startaddress:=addr(textbuf[0]);
  endaddress:=addr(textbuf[maxtext]);
  textbuf[0]:=#0; textbuf[maxtext]:=#$1A;
  i:=startaddress+1; j:=0; pbotm:=endaddress;
  write('file name ? '); readln(filename);
  assign(infil,filename); {$I-} reset(infil); {$I+}
  if ioresult<>0 then
    begin  writeln('*** new file ***'); delay(500) end
  else
    while not eof(infil) do begin read(infil,c); putmem(j,i,c) end;
  close(infil); putmem(j,i,newline); ptop:=i-1;
  poptop; texttop; clrscr; x:=1; y:=1; insert:=true
end;

procedure outtext;
var c:char; i:integer; infil:text;
begin
  repeat
    sline(0); gotoxy(1,1);
    write('> Save Write Return New Quit ? '); read(trm,c);
    if c in ['Q','q'] then begin clrscr; halt end;
    if c in ['W','w']  then readline('file name',filename);
    if (c in ['S','s','W','w']) and (filename<>'') then
      begin
        texttop; textbottom; pushtop; mem[ptop+1]:=$1A;
        assign(infil,filename); rewrite(infil); i:=1;
        while textbuf[i]<>#$1A do
          begin write(infil,textbuf[i]); i:=i+1 end;
        close(infil); poptop; x:=numbuf
      end;
  until c in ['N','n','R','r'];
  sline(0);
  if c in ['N','n'] then begin gotoxy(1,1); settext end
end;

procedure checkbuf;
begin
  if (pbotm-ptop)<255 then
    begin
      gotoxy(1,1); write('Text buffer full !'); delay(1000); outtext;
    end;
end;
