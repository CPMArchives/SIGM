{ [SF.PAS of JUGPDS Vol.16]				85-09-15   }
{                                                                  }
{    Fortran Coding Format Converter: Standard to Free Format      }
{                                                                  }
{              by H. Miyasaka (JUG-CP/M, No.6)			   }
{              Created  85/02/24   Ver 1.0                         }
{              Updated  85/04/29       1.0A ... all left delete    }
{                                                                  }

program sf;
const
  MAXLINE = 80;

type
  maxstr   = string[MAXLINE];          { max input line }
  filstr   = string[15];               { filename }

var
  Buff1     : maxstr;                  { input buff 1 }
  Buff2     : maxstr;                  { input buff 2 }

  inf       : text;
  tempf     : text;
  eraf      : text;

  infile    : filstr;                  { input filename }
  tempfile  : filstr;                  { temporary filename }
  outfile   : filstr;                  { output filename }

  options   : maxstr;                  { dummy }

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
  while copy(st,i,1) = ' ' do
    i := i + 1;
  delete(st,1,i-1);
end;

procedure delmid(var st:maxstr);
var
  temps : maxstr;
  i,j   : byte;
begin
  temps := ' ';
  j := 0;
  for i:=1 to length(st) do
    if st[i] <> ' '
      then
        begin
          j := j + 1;
          insert(st[i],temps,j);
        end;
  st := temps;
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
                goto 001;
              end;
        arg1 := copy(arg,1,i);
001:    cond := True;
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
        infile:= infile + '.FOR';
      end
    else
      name := copy(infile,1,i-1);
  tempfile := name + '.$$$';
  outfile  := name + '.FRE';
end;

procedure linput(var st:maxstr;var fend:boolean);
begin
  if not EOF(inf)
    then
      begin
        readln(inf,st);
        fend := False
      end
    else
      fend := True;
end;

procedure condense(var texts:maxstr);
var
  text1,text2:maxstr;
  i : byte;
begin
  text1 := copy(texts,1,6);
  text2 := copy(texts,7,length(texts)-6);
  delmid(text1);
  delleft(text2);
  if text1 = ' '
    then
      texts := text2
    else
      texts := text1 + text2;
end;

procedure lastbar(var texts:maxstr);
var
  i : byte;
begin
  i := length(texts);
  texts := texts + ' ';
  while texts[i]=' ' do
    i := i - 1;
  texts[i+1] := '-';
end;


begin
  arguments(infile,options,cond);
  if not cond
    then
      begin
        writeln('Fortran Standard-Format to Free-Format Converter.');
        writeln('Usage : sf file-name');
        exit;
      end;
  writeln('---------------------------------------------------------');
  writeln('Fortran Standard-Format to Free-Format Converter Ver 1.0A');
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
  linput(Buff1,fend);
  if fend
    then
      begin
        writeln(infile,' is empty');
        exit;
      end;
  while not fend do
    begin
      Buff2 := Buff1;
      linput(buff1,fend);
      if fend
        then
          Buff1 := '';
      if (Buff2[1]='C') or (Buff2[1]='*')
        then
          Buff2[1] := '"'
        else
          begin
            if (Buff1[6]<>' ') and (Buff1[6]<>'0')
              then
                begin
                  Buff1[6] := ' ';
                  lastbar(Buff2);
                end;
            condense(Buff2);
          end;
      writeln(tempf,Buff2);
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
end.
