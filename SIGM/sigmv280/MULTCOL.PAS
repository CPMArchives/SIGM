program multcol;
{ converts a single column of text to multi-column output}
{$iglobdefs.pas}
{$istdutil.pas}
{$istdio.pas}
{$R+}

const
     ncdefault      = 2;  { default number of columns }
     csdefault      = 4;  { default space between columns }
     cwdefault      = 38; { default column width }
     lppdefault     = 56; { default lines per page }
     ppdefault      = 66; { default physical page size }
     PBSIZE         = 8000;  { size of page buffer (chars.) }
     MAXLINES       = 80;    { max. no. of lines/page }
var
     gotfile,gotfile2 :boolean;
     name,prompt    :textline;
     infile,outfile :filedesc;
     badinput       :boolean;
     linesperpage,
     colwidth,
     colspace,
     physpage,
     numcols,
     linewidth      :integer;

procedure getparams(var numcols,colwidth,colspace,linesperpage,linewidth:
                    integer; var badinput:boolean);
{ get parameters from console}

var
    prompt :textline;
    maxbuf :integer;

procedure getnum(var prompt:textline;var x:integer;xdefault:integer);
{get a number from the console}

var
     gotline   :boolean;
     numstring :textline;
     i,junk    :integer;

begin
     putstr(prompt,TRMOUT);
     putc(LESS);
     write(xdefault);
     putc(GREATER);
     putc(SPACE);
     if getline(numstring,TRMIN,MAXSTR) then
     begin
          i:=1;
          if skipsp(numstring,i) in [NEWLINE,EOS] then
              x := xdefault
          else x := ctoi(numstring,i);
     end
     else x := xdefault;
end; { getnum }

begin { getparams }
     setstring(prompt,'Number of columns? ');
     getnum(prompt,numcols,ncdefault);
     setstring(prompt,'Column width? ');
     getnum(prompt,colwidth,cwdefault);
     setstring(prompt,'Space between columns? ');
     getnum(prompt,colspace,csdefault);
     setstring(prompt,'Lines per page? ');
     getnum(prompt,linesperpage,lppdefault);
     setstring(prompt,'Physical page size (lines)? ');
     getnum(prompt,physpage,ppdefault);
     linewidth := (numcols*colwidth) + (numcols-1)*colspace;
     maxbuf := linesperpage*(linewidth+1) + 5;
     badinput := false;
     if maxbuf>PBSIZE then
     begin
          writeln;
          writeln('Not enough memory to store an output page.');
          writeln;
          badinput := true;
     end;
     if (linesperpage>MAXLINES) or (physpage>MAXLINES) then
     begin
          writeln;
          writeln('Too many lines specified -- ',MAXLINES,' maximum.');
          writeln;
          badinput := true;
     end;
end; { getparams }

procedure convert(var infile,outfile:filedesc);

type
     pagebuftype    = array[1..PBSIZE] of character;
     cwarray        = array[1..MAXLINES] of integer;
var
     s              :textline;
     pagebuf        :pagebuftype;
     colswritten    :cwarray;
     pagenum,
     line,
     column         :integer;

procedure initpage;
{ initialize page buffer }

var
     i    :integer;
begin
     for i:=1 to PBSIZE do pagebuf[i] := SPACE;
     for i:=1 to MAXLINES do colswritten[i] := 0;
end;

procedure writeline(var s:textline;column,line:integer);

{ write a line into the proper place on the page}

var
     i,j  :integer;
     eol  :boolean;
begin
     i := 1;
     j := (linewidth+1)*(line-1) + 1 + (column-1)*(colwidth+colspace);
     eol := false;
     while (i<=colwidth) and (not eol) do
     begin
          eol := (s[i] = NEWLINE) or (s[i]=EOS);
          if not eol then
          begin
               pagebuf[j] := s[i];
               i := i + 1; j := j + 1;
          end;
     end;
     colswritten[line] := colswritten[line] + 1;
end; {writeline}

procedure writepage(var colswritten: cwarray);
{ write contents of page buffer to file }

var
     i,j,k:integer;
     c    :character;

begin
     pagenum := pagenum + 1;
     for i:=1 to linesperpage do
     begin
          j := (i-1)*(linewidth+1) + 1 + (colswritten[i]*colwidth);
          if colswritten[i]>0 then j:=j+(colswritten[i]-1)*colspace;
          pagebuf[j] := NEWLINE;
     end;
     for i:=1 to linesperpage do
     begin
          j := (i-1)*(linewidth+1)+1;
          k := 0;
          repeat
               c := pagebuf[j];
               {putc(c);}
               putcf(c,outfile);
               j := j + 1;
               k := k + 1;
          until (c=NEWLINE) or (k>linewidth);
     end;
     for i:=linesperpage+1 to physpage do putcf(NEWLINE,outfile);
end; { writepage }

begin { convert }
     column := 1; line := 1; pagenum := 0;
     initpage;
     while getline(s,infile,MAXSTR) do
     begin
          {putstr(s,TRMOUT);}
          if (line>1) or (not (s[1] in [EOS,NEWLINE])) then
          begin
               writeline(s,column,line);
               line := line + 1;
          end;
          if line > linesperpage then
          begin
               column := column + 1;
               line := 1;
               if column > numcols then
               begin
                    writepage(colswritten);
                    initpage;
                    column := 1;
               end;
          end;
     end; { while }
     if (line>1) or (column>1) then {output last partial page}
          writepage(colswritten);
     writeln; writeln(pagenum, ' page(s) written.'); writeln;
end; { convert }

begin { main program }
     lowvideo;
     ioinit(2);
     writeln;
     writeln('This program converts a single-column input file to');
     writeln('multi-column output.');
     writeln;
     writeln('by Jon Dart ... Version 1.3 (31-Mar-85)');
     writeln;
     repeat
          setstring(prompt,'Input file name? ');
          gotfile := getfile(infile,prompt,name,IOREAD);
          if gotfile then
          begin
               setstring(prompt,'Output file name? ');
               repeat
                    gotfile2 := getfile(outfile,prompt,name,IOWRITE);
               until gotfile2;
               getparams(numcols,colwidth,colspace,linesperpage,linewidth,
                         badinput);
               if not badinput then
                    convert(infile,outfile);
               pclose(infile); pclose(outfile);
          end;
     until not gotfile;
end.

