{ update.pas
    update library  by K.Nakazato
      Ver. 1.0   December 10, 1984 }

const
  name_length =16;
  max_name    =128;
  line_length =128;
  max_buf     =$3FFF;
  default_name='LIB.INC';
type
  symbol=(nosym,namesym,externalsym,scansym);
  linetype   =string[line_length];
  stringtype =string[name_length];
  stringarray
    =record
       number:integer;
       name  :array [1..max_name] of stringtype
     end;
var
  infile,outfile:text;
  bufindex      :array [0..1] of integer;
  buffer        :array [1..max_buf] of char;
  arg,lib_,add_ :stringarray;
  error         :boolean;
  lib_name,add_name,outfile_name:stringtype;

{$I LIB.INC}
{#scan lib.lib}
{#external getarg,exist,set_buffer,set_string,write_lib}

procedure init;
var j:integer;
begin
  getarg(arg);
  if arg.number<1 then
    begin
      writeln('Update library');
      writeln('usage: >update library_file_name [include_file_name]');
      writeln('  When "include_file_name" is absent, "LIB.INC" is assumed.');
      halt
    end
  else lib_name:=arg.name[1];
  outfile_name:=lib_name;
  j:=pos('.',outfile_name);
  if j>0 then outfile_name[0]:=chr(j-1);
  if arg.number<2 then add_name:=default_name
                  else add_name:=arg.name[2]
end;

var a:char; i:integer; flag:boolean;
begin
  init; error:=false;
  assign(infile,lib_name); {$I-}; reset(infile); {$I+};
  flag:=(ioresult=0); close(infile);
  if flag then
    begin
      bufindex[0]:=1; set_buffer(lib_name,bufindex[0]);
      set_string(namesym,lib_)
    end
  else lib_.number:=0;
  bufindex[0]:=1; set_buffer(add_name,bufindex[0]);
  set_string(namesym,add_);
  assign(outfile,outfile_name+'.$$$'); rewrite(outfile);
  for i:=1 to lib_.number do
    begin
      a:='N';
      if exist(add_,lib_.name[i]) then
        repeat
          write(lib_.name[i]:17,' update [y/n] ? ');
          read(trm,a); a:=upcase(a); writeln
        until a in ['Y','N'];
      if      a='Y' then write_lib(add_name,lib_.name[i])
      else if a='N' then write_lib(lib_name,lib_.name[i])
    end;
  for i:=1 to add_.number do
    if not exist(lib_,add_.name[i]) then
      repeat
        write(add_.name[i]:17,'    add [y/n] ? ');
        read(trm,a); a:=upcase(a); writeln;
        if a='Y' then write_lib(add_name,add_.name[i])
      until a in ['Y','N'];
  close(outfile);
  if flag then
    begin
      assign(outfile,lib_name); rename(outfile,outfile_name+'.bak')
    end;
  assign(outfile,outfile_name+'.$$$'); rename(outfile,lib_name)
end.
