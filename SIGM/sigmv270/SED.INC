{  Small editor                              }
{    by K.Nakazato  Ver. 1.00  Feb. 10, 1984 }
{                        1.12  Jun.  2, 1984 }
{                        1.13  Jul. 14, 1984 }
{                        1.14  Dec. 16, 1984 }

{ const maxtext =$7FFF;                      }
{ type  texttype=array [0..maxtext] of char; }

procedure sedit(var textbuf:texttype; onmemory:boolean;
                var position:integer);

{*****    machine dependent routine     *****}

const
  screen_width =80;
  screen_length=23;

{ Set VRAM address, here.                    }
{   vramaddr[0]= home position of screen     }
{   vramaddr[1]= left edge of second line    }
{    .......                                 }
{ The following is for NEC PC8001, PC8801.   }

var vramaddr:array [0..screen_length] of integer;

procedure setvramaddr;
var i:byte;
begin
  vramaddr[0]:=$F300;
  for i:=1 to screen_length do vramaddr[i]:=vramaddr[i-1]+$78
end;

{***** end of machine dependent routine *****}

{ constants and main variables }

const
    newline   =#$0D; { mark of CR/LF       }
    mark      =#$87; { mark of work        }
    startblock=#$E7; { mark of start block }
    endblock  =#$E4; { mark of end   block }
    swidth  :byte=screen_width;
    slength :byte=screen_length;
    wordset :set of char=['a'..'z','A'..'Z','0'..'9','_'];
    ctrlcode:set of char=[#0,#$A,#$D,#$1A];
type
    linetype=string[30];
    frtype=(nosym,findsym,replacesym);
var
    ptop    :integer;              { stack pointer of top    text   }
    pbotm   :integer;              { stack pointer of bottom text   }
    address :integer;              { address of searched character  }
    buffer  :string[screen_width]; { buffer of current line         }
    numbuf  :byte absolute buffer; { number of characters in buffer }
    insertsw:boolean;              { insert/overwrite switch        }
    outflag :boolean;              { quit flag                      }
    x,y     :byte;                 { cursor position                }
    halflen :byte;                 { half length of screen          }
    fr      :frtype;               { find/replace                   }
    infile  :text;                 { text file control block        }
    filename:linetype;             { main file name                 }
    bkname  :linetype;             { block file name                }
    line    :linetype;             { work string for input          }
    linefrom:linetype;             { string of find / replace(from) }
    lineto  :linetype;             { string of        replace(to)   }

{ text basic routines }

procedure setnumbuf;
begin
  while buffer[numbuf]=' ' do numbuf:=numbuf-1
end;

procedure pushtop;
begin
  setnumbuf;
  inline($21/ buffer/ $7E/ $ED/ $5B/ ptop/ $13/ $B7/ $28/ $06/
         $06/ $00/ $4F/ $23/ $ED/ $B0/ $EB/ $36/ $0D/ $23/ $36/
         $0A/ $22/ ptop)
end;

procedure poptop;
begin
  inline($2A/ ptop/ $7E/ $B7/ $28/ $1D/ $0E/ $00/ $2B/
         $0C/ $7E/ $B7/ $28/ $04/ $FE/ $0A/ $20/ $F6/
         $22/ ptop/ $0D/ $0D/ $79/ $28/ $09/ $06/ $00/
         $23/ $11/ buffer/ $13/ $ED/ $B0/ $32/ buffer)
end;

procedure pushbottom;
begin
  setnumbuf;
  inline($3A/ buffer/ $2A/ pbotm/ $2B/ $36/ $0A/ $2B/ $36/
         $0D/ $B7/ $28/ $0D/ $2B/ $EB/ $06/ $00/ $4F/ $21/
         buffer/ $09/ $ED/ $B8/ $EB/ $23/ $22/ pbotm)
end;

procedure popbottom;
begin
  inline($2A/ pbotm/ $0E/ $00/ $11/ buffer/ $13/ $7E/ $FE/ $1A/
         $28/ $0C/ $FE/ $0D/ $28/ $06/ $12/ $13/ $23/ $0C/
         $18/ $F1/ $23/ $23/ $22/ pbotm/ $79/ $32/ buffer)
end;

procedure topbottom;
begin
  inline($2A/ ptop/ $23/ $ED/ $5B/ pbotm/ $1A/ $FE/ $1A/
         $28/ $0B/ $FE/ $0D/ $28/ $05/ $77/ $13/ $23/ $18/
         $F2/ $13/ $13/ $ED/ $53/ pbotm/ $36/ $0D/
         $23/ $36/ $0A/ $22/ ptop)
end;

procedure bottomtop;
begin
  inline($2A/ pbotm/ $2B/ $36/ $0A/ $2B/ $36/ $0D/ $2B/ $ED/
         $5B/ ptop/ $1A/ $B7/ $28/ $0F/ $1B/ $1B/ $1A/ $B7/
         $28/ $09/ $FE/ $0A/ $28/ $05/ $77/ $1B/ $2B/
         $18/ $F3/ $ED/ $53/ ptop/ $23/ $22/ pbotm)
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
var i:byte;
begin
  if yto>yfrom then
    begin
      pushtop;
      for i:=yfrom+1 to yto-1 do topbottom;
      popbottom
    end
  else if yto<yfrom then
    begin
      pushbottom;
      for i:=yfrom-1 downto yto+1 do bottomtop;
      poptop
    end;
  getline:=yto
end;

{ screen basic routines }

function tline(yto,yfrom:byte):byte; { transfer line }
var vram,vram1:integer;
begin
  vram1:=vramaddr[yfrom]; vram:=vramaddr[yto];
  inline($2A/ vram1/ $ED/ $5B/ vram/
         $3A/ swidth/ $4F/ $06/ $00/ $ED/ $B0);
  tline:=yfrom
end;

procedure sline(y:byte); { erase line }
var vram:integer;
begin
  vram:=vramaddr[y];
  inline($2A/ vram/ $3A/ swidth/ $47/
         $3E/ $20/ $77/ $23/ $10/ $FC)
end;

procedure pline(y:byte); { print line }
var vram:integer;
begin
  vram:=vramaddr[y];
  inline($21/ buffer/ $7E/ $23/ $ED/ $5B/ vram/ $B7/
         $28/ $05/ $06/ $00/ $4F/ $ED/ $B0/ $47/ $3A/
         swidth/ $90/ $28/ $0B/ $38/ $09/ $47/ $3E/
         $20/ $12/ $77/ $13/ $23/ $10/ $FA)
end;

procedure rolldown(y1,y2:byte);
begin
  while y1<y2 do y2:=tline(y2,y2-1)
end;

procedure rollup(y1,y2:byte);
begin
  while y1<y2 do y1:=tline(y1,y1+1)
end;

procedure newscreen;
var n:byte;
begin
  pline(getline(1,y));
  for n:=2 to slength do
    begin pushtop; popbottom; pline(n) end;
  y:=getline(y,slength)
end;

{ primitives }

procedure dispinsert;
begin
  gotoxy(screen_width-10,1);
  if insertsw then write('insert   ') else write('overwrite')
end;

procedure newcommandline;
begin
  sline(0); dispinsert
end;

procedure readline(prompt:linetype; var line:linetype);
begin
  sline(0); gotoxy(1,1);
  write(prompt,' ? '); readln(line);
  newcommandline
end;

procedure putmem(var i:byte; var k:integer; c:char);
begin
  if (pbotm-k)>250 then
    begin
      if (c=newline) or (i>=swidth) then
        begin mem[k]:=$D; mem[k+1]:=$A; k:=k+2; i:=0 end;
      if not (c in ctrlcode) then
        begin mem[k]:=ord(c); k:=k+1; i:=i+1 end
    end
  else begin mem[k-2]:=$D; mem[k-1]:=$A end
end;

{ elementary routines }

procedure replaceline(xfrom,xlength:byte; line:linetype);
var i,n:byte; k:integer;
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
var len:integer;
begin
  if s=1 then
    begin
      len:=ptop-addr(textbuf[0]);
      if len>0 then
        inline($3A/ c/ $ED/ $4B/ len/ $2A/ ptop/
               $ED/ $B9/ $23/ $22/ address)
    end
  else if s=2 then
    begin
      len:=addr(textbuf[maxtext])-pbotm;
      if len>0 then
        inline($3A/ c/ $ED/ $4B/ len/ $2A/ pbotm/
               $ED/ $B1/ $2B/ $22/ address)
    end
end;

procedure erasemem(s:byte; mem1,mem2:integer);
var len:integer;
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
  s:=2; m:=0;
  while (s>0) and (m=0) do
    begin
      searchmem(s,c);
      if mem[address]=ord(c) then m:=address else s:=s-1
    end
end;

{ block routines }

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
  poptop; newscreen
end;

procedure writeblock;
var s,t:byte; mem1,mem2,i:integer;
begin
  pushtop; search1(startblock,s,mem1); search1(endblock,t,mem2);
  if ((mem2-mem1)>0) and (mem1<>0)  then
    begin
      readline('write block name',bkname);
      assign(infile,bkname); rewrite(infile); i:=mem1+1;
      if t>s then
        begin
          while i<>ptop+1 do
            begin write(infile,chr(mem[i])); i:=i+1 end;
          i:=pbotm
        end;
      while i<>mem2 do
        begin write(infile,chr(mem[i])); i:=i+1 end;
      close(infile)
    end;
  poptop
end;

procedure readblock;
var c:char; k:integer;
begin
  replaceline(x,0,newline); pushbottom; numbuf:=x-1; k:=ptop-1;
  readline('read block name',bkname);
  assign(infile,bkname); {$I-} reset(infile) {$I+};
  if ioresult=0 then
    begin
      putmem(numbuf,k,startblock);
      while not eof(infile) do
        begin read(infile,c); putmem(numbuf,k,c) end;
      putmem(numbuf,k,endblock)
    end;
  close(infile); putmem(numbuf,k,newline); ptop:=k-1; poptop;
  connect; newscreen
end;

procedure cmblock(copy:boolean);
var s,t:byte; k,m,mem1,mem2:integer;
begin
  replaceline(x,0,newline); pushbottom; numbuf:=x-1; k:=ptop-1;
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
  poptop; connect; newscreen
end;

procedure erasemark;
var s:byte; m:integer;
begin
  pushtop;
  repeat search1(startblock,s,m); erasemem(s,m,m) until s=0;
  repeat search1(endblock  ,s,m); erasemem(s,m,m) until s=0;
  poptop; newscreen
end;

{ find/replace }

function find1:boolean;
var n:integer;
begin
  find1:=false;
  if linefrom<>'' then
  begin
    pushbottom; delete(buffer,1,x); n:=pos(linefrom,buffer); popbottom;
    if n>0 then n:=x+n;
    while (n=0) and (mem[pbotm]<>$1A) do
      begin pushtop; popbottom; n:=pos(linefrom,buffer) end;
    if n>0 then begin x:=n; find1:=true end
           else begin textbottom; x:=numbuf end;
    if x>swidth then x:=swidth;
    y:=halflen; newscreen
  end
end;

procedure find;
var junk:boolean;
begin
  readline('find',line);
  if line<>'' then begin
    fr:=findsym; linefrom:=line; junk:=find1 end
end;

procedure replace1;
var c:char;
begin
  if find1 then
    begin
      sline(0); gotoxy(1,1);
      write('replace - space -');
      gotoxy(x,y+1); read(kbd,c); newcommandline;
      if c=' ' then
        begin
          replaceline(x,length(linefrom),lineto);
          newscreen
        end
    end
end;

procedure replace;
var n:integer;
begin
  readline('replace from',line);
  if line<>'' then begin
    fr:=replacesym; linefrom:=line;
    readline('to',lineto); replace1
  end
end;

{ elements }

function getnextc(c:char):char;
var r:char;
begin
  gotoxy(1,1); write('^',c);
  gotoxy(x,y+1); read(kbd,r); getnextc:=r;
  gotoxy(1,1); write('  ')
end;

procedure deletechar;
begin
  delete(buffer,x,1)
end;

procedure insertchar(r:char);
begin
  if buffer[numbuf]=' ' then
    begin
      numbuf:=numbuf-1;
      insert(r,buffer,x)
    end
  else write(^G)
end;

procedure deleteword;
var i:byte; c:char;
begin
  i:=x; c:=buffer[i];
  if c in wordset then
    while (buffer[i] in wordset) and (i<=numbuf) do i:=i+1
  else if c=' ' then
    while (buffer[i]=c) and (i<=numbuf) do i:=i+1
  else i:=i+1;
  delete(buffer,x,i-x)
end;

procedure linedown;
begin
  if y<slength then y:=getline(y+1,y)
  else begin rollup(1,slength); pushtop; popbottom end
end;

procedure lineup;
begin
  if y>1 then y:=getline(y-1,y)
  else begin rolldown(1,slength); pushbottom; poptop end
end;

procedure screenup;
var i:byte;
begin
  i:=getline(slength,y-1);
  rollup(1,slength); pline(slength);
  if y>1 then y:=y-1;
  y:=getline(y,slength)
end;

procedure screendown;
var i:byte;
begin
  i:=getline(1,y+1);
  rolldown(1,slength); pline(1);
  if y<slength then y:=y+1;
  y:=getline(y,1)
end;

procedure wordleft;
begin
  x:=x-1;
  repeat
    if x=0 then begin lineup; pline(y); x:=swidth end;
    while not (buffer[x] in wordset) and (x>0) do x:=x-1
  until (x>0) or (mem[ptop]=0);
  while (buffer[x] in wordset) and (x>0) do x:=x-1;
  x:=x+1
end;

procedure wordright;
begin
  while (buffer[x] in wordset) and (x<=swidth) do x:=x+1;
  repeat
    if x>swidth then begin linedown; pline(y); x:=1 end;
    while not (buffer[x] in wordset) and (x<=swidth) do x:=x+1
  until (x<=swidth) or (mem[pbotm]=$1A);
  if x>swidth then x:=1
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
  while (buffer[x]=' ') and (x<=swidth) do x:=x+1;
  if x>swidth then x:=1
end;

procedure mostright;
begin
  setnumbuf;
  if (numbuf=0) or (numbuf>=swidth) then x:=swidth
  else x:=numbuf+1
end;

procedure findpos(c:char);
begin
  texttop; textbottom; pushtop; mem[ptop+1]:=$1A;
  searchmem(1,c); position:=address
end;

procedure setposition;
begin
  while (ptop-position)>=0 do begin pushbottom; poptop end;
  x:=position-ptop; if x>swidth then x:=swidth
end;

procedure gotoc(c:char);
begin
  findpos(c); popbottom; setposition; y:=halflen; newscreen
end;

procedure endtext;
var c:char;
begin
  c:=buffer[x]; buffer[x]:=mark; findpos(mark);
  mem[position]:=ord(c)
end;

{ disk input/output routines }

procedure settext(onmemory:boolean);
var c:char; j:byte; i:integer;
begin
  textbuf[0]:=#0; textbuf[maxtext]:=#$1A;
  pbotm:=addr(textbuf[maxtext]);
  i:=addr(textbuf[0])+1;
  if onmemory then begin
    while mem[i]<>$1A do i:=i+1;
    ptop:=i-1; popbottom;
    if ((position-addr(textbuf[0]))>0) and ((ptop-position)>=0)
    then begin setposition; y:=halflen end
    else begin texttop; x:=1; y:=1 end
  end
  else begin
    j:=0;
    write('file name ? '); readln(filename);
    assign(infile,filename); {$I-} reset(infile); {$I+}
    if ioresult<>0 then
      begin  write('*** new file ***'); delay(500) end
    else
      while not eof(infile) do begin read(infile,c); putmem(j,i,c) end;
    close(infile); putmem(j,i,newline);
    ptop:=i-1; poptop; texttop; x:=1; y:=1
  end;
  clrscr; insertsw:=true; dispinsert; newscreen
end;

procedure outtext;
var c:char; i:integer;
begin
  if onmemory then outflag:=true
  else begin
    repeat
      sline(0); gotoxy(1,1);
      write('> Save Write Return New Quit ? '); read(trm,c); c:=upcase(c);
      if c='W' then readline('file name',filename);
      if ((c='S') or (c='W')) and (filename<>'') then
        begin
          endtext; assign(infile,filename); rewrite(infile); i:=1;
          while textbuf[i]<>#$1A do
            begin write(infile,textbuf[i]); i:=i+1 end;
          close(infile); popbottom; setposition
        end
    until c in ['N','R','Q'];
    newcommandline;
    if c='Q' then outflag:=true
    else if c='N' then begin gotoxy(1,1); settext(false) end
  end
end;

procedure checkbuf;
begin
  if (pbotm-ptop)<255 then
    begin
      gotoxy(1,1); write('Text buffer full !'^G);
      delay(500); outtext
    end
end;

{*** main ***}

var r:char; i:byte; junk:boolean;
begin
  outflag:=false; fr:=nosym; halflen:=slength div 2+1;
  position:=position+addr(textbuf[0]);
  crtinit; setvramaddr; settext(onmemory);
  repeat
    pline(y); numbuf:=swidth;
    gotoxy(x,y+1); read(kbd,r);
    case r of
      ^G:deletechar;
      ^S,^H:if x>1 then x:=x-1;
      ^V:begin insertsw:=not insertsw; dispinsert end;
      ^I:begin x:=8*((x-1) div 8)+9; if x>swidth then x:=swidth end;
      ^D:if x<swidth then x:=x+1;
      ^T:begin
           setnumbuf;
           if x<=numbuf then deleteword
           else begin connectline; newscreen end
         end;
      ^N:begin replaceline(x,0,newline); pushbottom; poptop; newscreen end;
      ^R:begin i:=getline(1,slength); newscreen end;
      ^C:begin i:=getline(slength,1); newscreen end;
      ^L:if fr=findsym then junk:=find1
         else if fr=replacesym then replace1;
      ^X:linedown;
      ^E:lineup;
      ^M:begin linedown; mostleft end;
      ^B:begin mostleft; pushbottom; numbuf:=0; rolldown(y,slength) end;
      ^Y:begin
           rollup(y,slength); popbottom;
           pline(getline(slength,y)); y:=getline(y,slength)
         end;
      ^A:wordleft;
      ^F:wordright;
      ^Z:screenup;
      ^W:screendown;
      ^P:begin
           r:=getnextc('P');
           if not (r in ctrlcode) then
             begin
              if insertsw then insertchar(r) else buffer[x]:=r;
              if x<swidth then x:=x+1
             end
         end;
      #$7F:if x>1 then begin x:=x-1; deletechar end;
      ^Q:case getnextc('Q') of
           ^Y:numbuf:=x-1;
           ^S:x:=1;
           ^D:mostright;
           ^R:begin x:=1; y:=1; texttop; newscreen end;
           ^C:begin y:=halflen; textbottom; x:=numbuf; newscreen end;
           ^F:find;
           ^A:replace;
           ^B:gotoc(startblock);
           ^K:gotoc(endblock);
           ^E:begin x:=1; y:=getline(1,y) end;
           ^X:begin y:=getline(slength,y); mostright end;
         else
         end;
      ^K:case getnextc('K') of
           ^B:insertchar(startblock);
           ^K:insertchar(endblock);
           ^W:writeblock;
           ^D:outtext;
           ^C:cmblock(true);
           ^V:cmblock(false);
           ^Y:eraseblock;
           ^R:readblock;
           ^X:erasemark;
         else
         end;
    else
      if r>=' ' then begin
        if insertsw then insertchar(r) else buffer[x]:=r;
        if x<swidth then x:=x+1
      end
    end;
    checkbuf
  until outflag;
  endtext; position:=position-addr(textbuf[0]);
  clrscr; crtexit
end;
