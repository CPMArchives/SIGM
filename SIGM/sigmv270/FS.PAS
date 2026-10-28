{ [FS.PAS of JUGPDS Vol.16]			85-09-15	}
{                                                               }
{    Fortran Coding Format Converter: 				}
{    Free Format to Standard Format     			}
{                                                               }
{		by H. Miyasaka (JUG-CP/M, No.6)			}
{
{             Created  84/11/01   Ver 1.0                          }
{             Updated  85/02/19       1.0A  ... debug              }
{                      85/03/16       1.1   ... auto indent        }
{                      85/04/22       1.1A  ... default indent     }
{                                                                  }
{$A-}

program fs;
const
  MAXLINE  = 128;                  {  max input line  }
  MAXLINE1 = 129;                  {  max input line plus one  }
  CONTCHAR = '$';                  {  '$' or '1' or ect.  }
  COMMENT  = 'C';                  {  'C' or '*'  }
  MAXNEST  =  20;                  {  max do nesting  }
  INDENTVAL=   2;                  {  1,2,3,4,...  }

type
  maxstr   = string[MAXLINE];
  maxstr1  = string[MAXLINE1];
  filstr   = string[15];           {  filenames  }

var
  inf       : text;
  tempf     : text;
  eraf      : text;

  infile    : filstr;              {  input filename  }
  tempfile  : filstr;              {  temporary filename  }
  outfile   : filstr;              {  output filename  }

  inputline : maxstr;              {  one line input buff  }
  outnumber : string[5];           {  number output buff  }
  outcont   : char;                {  continuation output buff  }
  outtext   : string[65];          {  text output buff  }

  lastchar  : char;

  options   : maxstr;              {  command tail options  }

  numbers   : array[1..MAXNEST] of integer;
  index     : byte;                {  numbers[] index  }
  indent    : byte;                {  auto indent  }

  cnt       : integer;             {  line count  }

  cond,fend : boolean;

procedure exit;
begin
  bdos(0);
end;

function exist(filename:filstr):boolean;
var
  fil : text;
begin
  assign(fil,filename);
  {$I-}
  reset(fil);
  {$I+}
  exist := (ioresult = 0)
end;

procedure delleft(var st:maxstr);
var
  i : byte;
begin
  i := 1;
  while  copy(st,i,1) = ' ' do
    i := i + 1;
  delete(st,1,i-1);
end;

procedure arguments(var arg1:filstr;var arg2:maxstr;var cond:boolean);
label
  001;
var
  arg : maxstr absolute $0080;
  i   : byte;
begin
  if length(arg) = 0
    then
      cond := False
    else
      begin
        delleft(arg);
        for i := 1 to length(arg) do
          if (arg[i] = ' ') or (arg[i] = '[')
            then
              begin
                arg2 := copy(arg,i,length(arg)-i+1);
                i := i - 1;
                goto 001;
              end;
        arg2 := ' ';
001:    arg1 := copy(arg,1,i);
        cond := True;
      end;
end;

procedure outputf(var infile,tempfile,outfile:filstr);
var
  name : filstr;
  i    : byte;
begin
  i := pos ('.',infile);
  if i = 0
    then
      begin
        name  := infile;
        infile:= infile + '.FRE';
      end
    else
      name := copy(infile,1,i-1);
  tempfile := name + '.$$$';
  outfile  := name + '.FOR';
end;

procedure linput(var st:maxstr;var fend:boolean);
var
  st1 : maxstr1;
  i : byte;
begin
  if not EOF(inf)
    then
      begin
        cnt := cnt + 1;
        readln(inf,st1);
        if length(st1) = 129
          then
            begin
              write  ('Warning ... Input line number ',cnt);
              writeln(', *** Record length too long ***');
            end;
        st := st1;
        fend := False
      end
    else
      fend := True;
end;

function firsts(st:maxstr):char;
begin
  delleft(st);
  firsts := st[1];
end;

procedure outclear;
begin
  outnumber    := '     ';
  outcont      := ' ';
  outtext      := ' ';
end;

function lasts:char;
var
  i : byte;
begin
  i := length(inputline);
  while inputline[i] = ' ' do
    i := i - 1;
  lasts := inputline[i];
  if inputline[i] = '-'
    then
      inputline[i] := ' '
end;

procedure numzero;
var
  i  :  byte;
begin
  for i:=1 to MAXNEST do
    numbers[i] := 0
end;

procedure indadd;
var
  numstr  : maxstr;
  tempstr : maxstr;
  num     : integer;
  code    : integer;
  i,j     : byte;
begin
  if indent <> 0
    then
      for i:=1 to indent do
        insert(' ',inputline,1);
  i := pos('DO',inputline);
  if i = 0
    then
      i := pos('do',inputline);
  if i <> 0
    then
      begin
        tempstr := copy(inputline,i+2,length(inputline)-(i-1));
        delleft(tempstr);
        i := 1;
        while (tempstr[i] <> ' ') and (length(tempstr) > i) do
          i := i + 1;
        numstr := copy(tempstr,1,i-1);
        j := 0;
        val(numstr,num,code);
        if code <> 0
          then
            writeln('Warnning ... Input line number ',cnt,
                     '  *** DO number error ***');
        index := 1;
        while numbers[index] <> 0 do
          index := index + 1;
        numbers[index] := num;
        indent := indent + INDENTVAL;
      end;
end;

procedure indsub(tnumber:maxstr);
var
  num  : integer;
  code : integer;
  i    : byte;
begin
  for i:=index downto 1 do
    begin
      val(tnumber,num,code);
      if numbers[i] = num
        then
          begin
            numbers[i] := 0;
            indent := indent - INDENTVAL;
            if indent < 0
              then
                begin
                  writeln(' ******* Indent error !!!! *********');
                  indent := 0
                end
          end
     end
end;

procedure number;
var
  tnumber : maxstr;
  i       : byte;
begin
  delleft(inputline);
  i := 1;
  while inputline[i] <> ' ' do
    i := i + 1;
  tnumber := copy(inputline,1,i-1);
  if length(tnumber) > 5
    then
      writeln('Warning ... Input line number ',cnt,
                   ', *** Line number too long ***');
  if pos('N',options) = 0
    then
      indsub(tnumber);
  tnumber := '     ' + tnumber;
  outnumber := copy(tnumber,length(tnumber)-4,5);
  inputline := copy(inputline,i+1,length(inputline)-i);
end;

procedure texts;
begin
  if pos('N',options) = 0
    then
      indadd;
  if lastchar = '-'
    then
      outcont := CONTCHAR;
  if length(inputline) > 66
    then
      begin
        lastchar := '-';
        outtext  := copy(inputline,1,65);
        inputline := copy(inputline,66,length(inputline)-65);
      end
    else
      begin
        lastchar := lasts;
        outtext  := inputline;
        inputline := '';
      end;
  writeln(tempf,outnumber,outcont,outtext);
  if length(inputline) <> 0
    then
      begin
        outclear;
        texts;
      end;
end;

begin
  cnt := 0;
  indent := 0;
  lastchar := ' ';
  numzero;
  arguments(infile,options,cond);
  if not cond
    then
      begin
        writeln('Fortan Free-format to Standard-format converter.');
        writeln('Usage : fs file-name [n]');
        exit;
      end;
  writeln('---------------------------------------------------------');
  writeln('Fortran Free-Format to Standard-Format Converter Ver 1.1A');
  writeln('---------------------------------------------------------');
  outputf(infile,tempfile,outfile);
  if not exist(infile)
    then
      begin
        writeln(infile,' not found');
        exit;
      end;
  assign(inf,infile);
  assign(tempf,tempfile);
  reset(inf);
  rewrite(tempf);
  linput(inputline,fend);
  while not fend do
    begin
      outclear;
      case firsts(inputline) of
        '"'     : begin
                    inputline[1] := COMMENT;
                    writeln(tempf,inputline);
                  end;
        '0'..'9': begin
                    if lastchar <> '-'
                      then
                        number;
                    texts;
                  end;
         else     texts;
      end;
      linput(inputline,fend);
    end;
    close(inf);
    close(tempf);
    if exist(outfile)
      then
        begin
          assign(eraf,outfile);
          erase(eraf);
        end;
    rename(tempf,outfile);
    writeln;
    writeln('complete');
end.