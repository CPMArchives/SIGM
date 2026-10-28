{ liblink.pas
    turbo pascal preprocessor for library link
      by K.Nakazato  Ver. 1.0   September 16, 1984 }

const
  name_length =16;
  max_name    =32;
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
  link =^table;
  table=record
          next:link;
          name:stringtype;
          index:integer
        end;
var
  root:link;
  infile,outfile:text;
  infile_name,outfile_name:stringtype;
  bufindex:array [0..max_name] of integer;
  buffer  :array [1..max_buf ] of char;
  arg,scan_,external_:stringarray;
  error:boolean;

{$I LIB.INC}
{#scan lib.lib}
{#external getarg,set_buffer,set_string,make_table,condense,make_library}

procedure init;
var j:integer;
begin
  getarg(arg);
  if arg.number<1 then
    begin
      writeln('Library linker');
      writeln('usage: >liblink main_file_name [include_file_name]');
      writeln('  When "include_file_name" is absent, "LIB.INC" is assumed.');
      halt
    end
  else infile_name:=arg.name[1];
  if arg.number<2 then outfile_name:=default_name
                  else outfile_name:=arg.name[2]
end;

var i:integer;
begin
  init; error:=false; bufindex[0]:=1;
  set_buffer(infile_name,bufindex[0]);
  set_string(scansym,scan_);
  set_string(externalsym,external_);
  for i:=1 to scan_.number do
    begin
      bufindex[i]:=bufindex[i-1];
      set_buffer(scan_.name[i],bufindex[i])
    end;
  new(root); make_table(external_); condense;
  if not error then make_library
end.
