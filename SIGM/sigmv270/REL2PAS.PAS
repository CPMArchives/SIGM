{ REL to TURBO PASCAL inline code by K.Nakazato
                         Ver. 1.0  Dec. 7, 1984 }

const
  size=$1FFF;
  a_type=0;
  b_type=1;
  e_type=2;
  p_type=3;
type
  linetype=string[20];
  hextype=string[2];
  labeltype=string[6];
  link=^item;
  item=record
         next:link;
         addr:integer;
         name:labeltype
       end;
var
  code,ref:array [0..size] of byte;
  rel_code:array [0.. 127] of byte;
  r_name  :array [0.. 127] of labeltype;
  p_size:integer;
  bit_,b_count,r_count:byte;
  root:link;
  infile :file;
  outfile:text;

procedure error(line:linetype);
begin
  writeln('error:',line); halt
end;

procedure read_rel;
begin
  blockread(infile,rel_code,1); b_count:=0
end;

procedure init;
var
  i,j,len:integer;
  comline:string[127] absolute $80;
  inname,outname:linetype;

function get_name(var name:linetype):boolean;
begin
  while (comline[i] =' ') and (i<=len) do i:=i+1;
  name:='';
  while (comline[i]<>' ') and (i<=len) do
    begin name:=name+comline[i]; i:=i+1 end;
  get_name:=(length(name)=0)
end;

begin
  bit_:=128;
  i:=1; len:=length(comline);
  if get_name(inname) then
    begin
      writeln('Transform relocatable code to Pascal inline code');
      writeln('usage: >rel2pas relocatable_file_name [inline_file_name]');
      writeln('  When inline_file_name is absent, the same file name as');
      writeln('  relocatable_file_name with extension "INC" is assumed.');
      halt
    end;
  j:=pos('.',inname); if j>0 then inname[0]:=chr(j-1);
  if get_name(outname) then outname:=inname+'.inc';
  assign(infile,inname+'.rel');
  {$I-} reset(infile); {$I+}
  if ioresult<>0 then error('file can''t open');
  read_rel; assign(outfile,outname)
end;

function get_bit(x:integer):integer;

function get_1bit:integer;
begin
  if (rel_code[b_count] and bit_)=0 then get_1bit:=0 else get_1bit:=1;
  bit_:=bit_ shr 1;
  if bit_=0 then
    begin
      b_count:=b_count+1;
      if b_count=128 then read_rel;
      bit_:=128
    end
end;

var val,i:integer;
begin
  val:=0;
  for i:=1 to x do val:=val shl 1+get_1bit;
  get_bit:=val
end;

procedure hex(x:integer; var h:hextype);

procedure hex1(x:integer);
begin
  if x>9 then x:=x+55 else x:=x+48;
  h:=h+chr(x)
end;

begin
  h:=''; hex1(x shr 4); hex1(x and $F)
end;

procedure afield(var t,k:integer);
begin
  t:=get_bit(2);
  k:=get_bit(8)+256*get_bit(8)
end;

procedure bfield(var label_:labeltype);
var i,t,c:integer;
begin
  label_:=''; t:=get_bit(3);
  for i:=1 to t do
    begin
      c:=get_bit(8);
      if (c>=ord('A')) and (c<=ord('Z')) then c:=c-ord('A')+ord('a');
      label_:=label_+chr(c)
    end
end;

procedure special(var flag:boolean);
var k,t:integer; p,q:link; label_:labeltype;
begin
  case get_bit(4) of
    0..3:bfield(label_);
    5:error('common size');
    6:begin
        afield(t,k); bfield(label_);
        if t=1 then
          begin
            repeat
              t:=ref[k];
              ref[k]:=e_type;
              ref[k+1]:=r_count;
              k:=code[k]+256*code[k+1]
            until t=a_type;
            r_name[r_count]:=label_;
            r_count:=r_count+1
          end
      end;
    7:begin
        afield(t,k); bfield(label_);
        if t=1 then
          begin
            p:=root; while p^.next^.addr<k do p:=p^.next;
            new(q); q^.addr:=k; q^.name:=label_;
            q^.next:=p^.next; p^.next:=q
          end
      end;
    9 :error('external offset');
    10:begin afield(t,k); if k<>0 then error('data area size') end;
    11:begin afield(t,k); if t<>1 then error('set loc counter') end;
    12:afield(t,k);
    13:afield(t,p_size);
    14:flag:=false;
  end
end;

procedure input;
var k:integer; flag:boolean;
begin
  new(root); new(root^.next);
  root^.next^.next:=nil;
  root^.next^.addr:=maxint;
  r_count:=0; k:=0; flag:=true;
  while flag do
    case get_bit(1) of
      0:begin
          ref [k]:=a_type;
          code[k]:=get_bit(8);
          k:=k+1
        end;
      1:case get_bit(2) of
          0:special(flag);
          1:begin
              ref[k]:=p_type;
              code[k]:=get_bit(8);
              k:=k+1;
              code[k]:=get_bit(8);
              k:=k+1
            end;
          else error('relative');
        end
    end;
  close(infile)
end;

procedure output;
var i,k,l:integer; p:link; h:hextype;
begin
  p:=root^.next;
  rewrite(outfile);
  k:=0; l:=0;
  while k<p_size do
    begin
      if k=p^.addr then
        begin
          if k>0 then
            begin
              writeln(outfile,')');
              writeln(outfile,'end;');
              writeln(outfile)
            end;
          l:=0;
          writeln(outfile,'procedure ',p^.name,';');
          writeln(outfile,'begin');
          write(outfile,'  inline ( ');
          p:=p^.next
        end;
      if l>=8 then
        begin
          l:=0;
          writeln(outfile,'/');
          write(outfile,' ':11)
        end;
      if l>0 then write(outfile,'/ ');
      case ref[k] of
        a_type:begin
                 hex(code[k],h);
                 write(outfile,'$',h)
               end;
        e_type:begin
                 k:=k+1;
                 write(outfile,r_name[ref[k]])
               end;
        p_type:begin
                 i:=code[k]+256*code[k+1]-k;
                 write(outfile,'*');
                 if      i>0 then write(outfile,'+',i:0)
                 else if i<0 then write(outfile,i:0);
                 k:=k+1
               end;
      end;
      k:=k+1; l:=l+1
    end;
  writeln(outfile,')'); writeln(outfile,'end;');
  close(outfile)
end;

begin
  init; input; output
end.
