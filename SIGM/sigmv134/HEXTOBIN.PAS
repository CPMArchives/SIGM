{$E+,T-}

program hextobin
;
const
     TheHEADER = 'CP/M Hex Ascii File to Binary File Program';
     TheVERSION= 'Version -- October 10, 1982.';
     TheTRAILER= 'Hex to Binary File conversion done.';

type 
     BYTE      = 0..255;
     sector    = packed array [1..128] of byte;
     filestring= string 14;
     bufaction = (buf_hold, buf_write);

var 
     ofilename ,
     ifilename : filestring;

     hexfile   ,
     binfile   : file of sector;
     
     sectorct  : integer;

     hexbuf    ,
     binbuf    : sector;

     buflag    : bufaction;

     i         ,
     j         ,
     k         : integer;



function OpenInp: boolean
;
begin  {* OpenInp *}
     OpenInp := true;
     write('INPUT FILE? ');
     read(ifilename);
     reset(ifilename,hexfile);
     if EOF(hexfile) then begin
          writeln(' ... file is empty...');
          OpenInp := false;
     end; 
end;  {* OpenInp *}



function OpenOut:boolean
;
begin  {* OpenOut *}
     OpenOut := true;
     write('OUTPUT FILE? ');
     read(ofilename);
     rewrite(ofilename,binfile);
end;  {* OpenOut *}



function hexdigit(ndx:integer):integer
;
begin  {* hexdigit *}
     if (hexbuf[ndx] >= ord('0')) and (hexbuf[ndx] <= ord('9')) then begin
          hexdigit := ord(hexbuf[ndx]) - ord('0');
     end
     else if (hexbuf[ndx] >= ord('A')) and (hexbuf[ndx] <= ord('F')) then begin
          hexdigit := 10 + ord(hexbuf[ndx]) - ord('A');
     end
     else begin      { not one of the characters that should be in the file }
          hexdigit := 0;
          writeln('*** found bad character. (',hexbuf[ndx],')');
     end;
end;  {* hexdigit *}




begin  {* HextoBin *}
     writeln(TheHEADER);
     writeln(TheVERSION);

     repeat
     until OpenInp;
     writeln('------> File opened.');

     repeat
     until OpenOut;
     writeln('------> File opened.');

     sectorct := 0;
     buflag := buf_hold;
     i := 0;
     while  not EOF(hexfile) do begin
          read(hexfile,hexbuf);
          for j := 1 to 64 do begin
               binbuf[i+j] := hexdigit(j+j-1)*16+hexdigit(j+j);
          end;
          sectorct := succ(sectorct);
          case buflag of 
          buf_hold:  
               begin
                    buflag := buf_write;
                    i := 64;
               end;
          buf_write: 
               begin
                    write(binfile,binbuf);
                    buflag := buf_hold;
                    i := 0;
                    write('.');      { show progress }
                    if sectorct mod 40 = 0 then begin
                         writeln;
                    end;
               end;
          end;    { case what to do with buffer }
     end;
     if buflag = buf_hold then begin
          write(binfile,binbuf);
     end;
     writeln(TheTRAILER);
end.  {* HextoBin *}
