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

NAMELEN     = 8;
FILENAMELEN = 14;
EXTIN       = '.LET';
EXTOUT      = '.CLN';
MAXLINE     = 255;


TYPE

{$ITYPES.PAS }

NAMETYPE = STRING NAMELEN;
FNTYPE   = STRING FILENAMELEN;




VAR

INFILENAME, OUTFILENAME: FNTYPE;
INFILE, OUTFILE: TEXT;

BADCHRCOUNT,
LINES: INTEGER;



{$IPROCS.PAS }
{$IGETFILES.PAS }






PROCEDURE CLEANCOPY;
VAR  C,I,J: byte;
     CH : CHAR;
     LINE: string maxline;


procedure writeline;
begin  {* writeline *}
     lines := succ(lines);
     setlength(line,i);
     writeln(outfile,line);
     i := 0;
     setlength(line,maxline);
end;  {* writeline *}


BEGIN  {* CLEANCOPY *}
     I := 0;
     setlength(line,maxline);
     REPEAT BEGIN
          IF eoln(infile) then begin
               readln(infile,ch);
               writeline;
          end
          else begin
               i := succ(i);
               read(infile,line[i]);
               c := ord(line[i]);
               IF C > 127 THEN BEGIN    { Turn off high bit if left on }
                    c := c - 128;
                    line[i] := chr( c );
               end;
               if (C<32) or (C=127) then begin
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
                              i := pred(i);
                              if  i>1 then begin  { assume end of record }
                                   i := pred(i);
                                   writeline;
                              end;
                         end;
                         
                         CR:  begin  { assume eoln, LF case above will catch }
                                     { following line-feed                   }
                              i := pred(i);
                              writeline;
                         end;
                         
                         FF:  begin  { pass this through - recognize as eoln }
                              writeline;
                         end;

                         ELSE:begin
                              Line[i] := blank;
                              BADCHRCOUNT := SUCC(BADCHRCOUNT);
                              writeln('Unusual Character: CHR(',C:3,'), line:',
                                      LINES:0);
                         end;
                    end;  { case C of }
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
	  CLEANCOPY;

{ TELL 'EM THAT YOU ARE DONE }
     
          WRITELN('DONE.  ');
          WRITELN('       ',LINES:0,' RECORDS CLEANED.');
          WRITELN('       ',BADCHRCOUNT:0,' UNUSUAL CHARACTERS FOUND.');
     END;
 
END.  {* CLEANPRT *}
