{ disk input/output routines for sed.inc }

procedure intext(filename:fnametype; var textbuf:texttype);
var i:integer; infile:text;
begin
  i:=1;
  assign(infile,filename); {$I-} reset(infile); {$I+}
  if ioresult<>0 then
    begin  writeln('*** new file ***'); delay(500) end
  else
    while not eof(infile) and (i<maxtext) do
      begin read(infile,textbuf[i]); i:=i+1 end;
  close(infile); textbuf[i]:=#$1A
end;

procedure outtext(filename:fnametype; var textbuf:texttype);
var i:integer; infile:text;
begin
  if filename<>'' then begin
    i:=1;
    assign(infile,filename); rewrite(infile);
    while textbuf[i]<>#$1A do
      begin write(infile,textbuf[i]); i:=i+1 end;
    close(infile)
  end
end;
 
procedure ls(ext:exttype);
const num=5;
      dev=#0;
var   dmabuf :array [1..128] of char;
      fcb    :string[36];
      n,count:integer;

procedure putdir;
var i:integer; s:exttype;
begin
  n:=n shl 5;
  s:=''; for i:=10 to 12 do s:=s+dmabuf[i+n];
  if (s=ext) or (ext='???') then
    begin
      if (count mod num)<>0 then write(' : ');
      for i:=2 to 9 do write(dmabuf[i+n]);
      write('.',s); count:=count+1;
      if (count mod num)=0 then writeln
    end
end;

begin
  count:=0;
  bdos(26,addr(dmabuf));
  fcb:=dev+'???????????'+#0;
  n:=bdos(17,addr(fcb[1]));
  if n<>255 then
    repeat
      putdir; n:=bdos(18,0)
    until n=255;
  if (count mod num)<>0 then writeln
end;
