{$C+ generate CTRL-C check in code                    }
{$E+ generate code for line numbers in error messages }
{$M+ generate checks for multiply/divde               }
{$S+ enable stack overflow checking code              }
{$R+ enable range/bound checking                      }
{$U+ enable parameter bound checking                  }

PROGRAM CLEANPRT;

CONST

{$ICONSTS.PAS }

LF          = 10;

DefaultHead = 'CLEANPRT version 1.0:  ';
DefaultPL   = 50;
ForcePageBrk= 32767;

NAMELEN     = 8;
FILENAMELEN = 14;
EXTIN       = '.LET';
EXTOUT      = '.CLN';
MAXLINE     = 255;
MAXHeader   = 255;


TYPE

{$ITYPES.PAS }

NAMETYPE = STRING NAMELEN;
FNTYPE   = STRING FILENAMELEN;




VAR

INFILENAME, OUTFILENAME: FNTYPE;
INFILE, OUTFILE: TEXT;

PageLen, Linect: integer;
Header: string255;


BADCHRCOUNT,
LINES: INTEGER;



{$IPROCS.PAS }
{$IGETFILES.PAS }


function iMax(i,j:integer): integer;
begin  {* iMax *}
     iMax := i;
     if  j>i  then begin
          iMax := j;
     end;
end;  {* iMax *}



PROCEDURE CLEANCOPY;
VAR  C,I,J: byte;
     CH : CHAR;
     Gobbleline: boolean;
     LINE: string maxline;


procedure writeline;
begin  {* writeline *}
     if not Gobbleline then begin
          if (linect>=PageLen) or (line[i]=chr(ff)) then begin
               if (line[i]=chr(ff)) then begin
                    line[i] := blank;
               end;
               if (linect<PageLen) then begin
                    Gobbleline := true;
                    lines := succ(lines);
                    setlength(line,i);
                    writeln(outfile,line);
               end
               else begin
                    Gobbleline := (i > 1);
               end;
               writeln(outfile,chr(ff));
               writeln(outfile);
               writeln(outfile,Header);
               writeln(outfile);
               writeln(outfile);
               linect := 0;
          end;
          if not Gobbleline then begin
               lines := succ(lines);
               linect := succ(linect);
               setlength(line,i);
               writeln(outfile,line);
          end;
     end;
     Gobbleline := false;
     i := 0;
     setlength(line,maxline);
end;  {* writeline *}



procedure readch;
begin  {* readch *}
     i := succ(i);
     read(infile,ch);
     c := ord(ch);
     IF C > 127 THEN BEGIN    { Turn off high bit if left on }
          c := c - 128;
          ch := chr(c);
     end;
     line[i] := ch;
end;  {* readch *}



procedure getnum(var N:integer);
begin  {* getnum *}
     repeat begin
          readch;
     end until eoln(infile) or (ch<>blank);
     N := 0;
     if (ch>='0') and (ch<='9') then begin
          N := c - ord('0');
          while (not eoln(infile)) do begin
               readch;
               if ((ch>='0') and (ch<='9')) and (N<=3275) then begin
                    N := N * 10 + (c - ord('0'));
               end;
          end;
     end; 
end;  {* getnum *}



procedure getstring(var S:string255; SLen:integer);
var  SpecialFlag: boolean;
     i: integer;
begin  {* getstring *}
     setlength(S,SLen);
     i:=1;
     SpecialFlag := false;
     while (not eoln(infile)) 
       and (not SpecialFlag) and (i<=SLen) do begin
          readch;
          if (c>=32) and (c<=126) then begin
               S[i] := ch;
          end
          else begin
               SpecialFlag := true;
          end;
          i := succ(i);
     end;
     setlength(s,i-1);
end;  {* getstring *} 



procedure EmbeddedCommand;
begin  {* EmbeddedCommand *}
     readch;
     case  ch  of

          'p','P':  begin
               readch;
               case  ch  of
                    'a','A':  begin
                         i := 1;
                         c := ff;
                         ch := chr(ff);
                         line[i] := ch;
                         writeline;
                         Gobbleline := true;
                    end;
                    'l','L':  begin
                         { pick up pagelength parameter }
                         getnum(PageLen);
                         if (PageLen=0) then begin
                              PageLen := DefaultPl;
                         end;
                         Gobbleline := true;
                    end;
                    ELSE:     begin
                          { pass it on through }
                    end;
               end;  { case  ch  of }
          end;  { 'p','P' }

          'h','H':  begin
               readch;
               case  ch  of
                    'e','E':  begin
                         { pick the remainder of line as new header }
                         setlength(header,0);
                         getstring(header,maxheader);
                         if length(header)<=1 then begin
                              header := DefaultHead;
                         end;
                         Gobbleline := true;
                    end;

                    ELSE:     begin
                         { pass it on through }
                    end;
               end;  { case  ch  of }
          end;  { 'h','H' }

          ELSE:     begin
               { pass it on through }
          end;
     end;  { case  ch  of } 
end;  {* EmbeddedCommand *}


procedure SpecialChar;
begin  {* SpecialChar *}
     case  C  of

          TAB: begin  { assume tab every eighth column }
               if  (i mod 8) = 0  then begin
                    for j := i to (i+7) do begin
                         Line[j] := blank;
                    end;
                    i := i + 8;
               end
               else begin
                   while (i mod 8) <> 0  do begin
                         Line[i] := blank;
                         i := succ(i);
                    end;
               end;
               Line[i] := blank;
          end;

          LF:  begin  { discard if at beginning of line }
                      { else insert CR.                 }
               line[i] := blank;
               i := iMax(i-1,1);
               if  i>1 then begin  { assume end of record }
                    writeline;
               end;
          end;
                         
          CR:  begin  { assume eoln, LF case above will catch }
                      { following line-feed                   }
               line[i] := blank;
               i := iMax(i-1,1);
               writeline;
          end;
                         
          FF:  begin  { pass this through - recognize as eoln }
               writeline;
          end;

          ELSE:begin
               Line[i] := blank;
               BADCHRCOUNT := SUCC(BADCHRCOUNT);
               writeln('Unusual Character: CHR(',C:3,'), line:',LINES:0);
          end;
     end;  { case ch of }
end;  {* SpecialChar *}


 
BEGIN  {* CLEANCOPY *}
     I := 0;
     setlength(line,maxline);
     gobbleline := false;
     REPEAT BEGIN
          IF eoln(infile) then begin
               readln(infile,ch);
               if i<1 then begin
                    line[1] := blank;
                    i := 1;
               end;
               writeline;
          end
          else begin
               readch;
               if (i=1) and (ch='.') then begin
                    EmbeddedCommand;
               end;
               if (C<32) or (C=127) then begin
                    SpecialChar;
               end;
          end;
     END  UNTIL EOF(INFILE);
END;  {* CLEANCOPY *}






BEGIN {* CLEANPRT *}

{ OPEN FILES UP }

     GETFILENAMES(EXTIN,EXTOUT);
     WRITELN('READING FROM ',INFILENAME);
     RESET(INFILENAME,INFILE);
     IF EOF(INFILE) THEN BEGIN
          WRITELN(INFILENAME,' IS EMPTY.');
     END
     ELSE BEGIN
          WRITELN('WRITING TO   ',OUTFILENAME);
          RESET(INFILENAME,INFILE);
          REWRITE(OUTFILENAME,OUTFILE);

{ COPY INPUT TO OUTPUT WHILE CLEANING UP BAD CHARACTERS }

          LINES := 0;
          BADCHRCOUNT := 0;
          Header := DefaultHead;
          PageLen:= DefaultPL;
          Linect := ForcePageBrk;

	  CLEANCOPY;

{ TELL 'EM THAT YOU ARE DONE }
     
          WRITELN('DONE.  ');
          WRITELN('       ',LINES:0,' RECORDS CLEANED.');
          WRITELN('       ',BADCHRCOUNT:0,' UNUSUAL CHARACTERS FOUND.');
     END;
 
END.  {* CLEANPRT *}
