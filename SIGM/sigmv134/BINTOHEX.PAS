{$E+,T-}

program bintohex
;
const
     TheHEADER = 'CP/M Binary File to ASCII Hex File Program';
     TheVERSION= 'Version -- October 10, 1982.';
     TheTRAILER= 'Binary to Hex File conversion done.';
     hexinit   = '0123456789ABCDEF';

type 
     sector    = packed array [1..128] of char;
     filestring= string 14;

var 
     ofilename ,
     ifilename : filestring;

     hexfile   ,
     binfile   : file of sector;
     
     hexbuf    ,
     binbuf    : sector;

     hextab    : string 16;

     i         ,
     j         ,
     k         : integer;



function OpenInp: boolean
;
begin  {* OpenInp *}
     OpenInp := true;
     write('INPUT FILE? ');
     read(ifilename);
     reset(ifilename,binfile);
     if EOF(binfile) then begin
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
     rewrite(ofilename,hexfile);
end;  {* OpenOut *}




begin  {* BintoHex *}
     writeln(TheHEADER);
     writeln(TheVERSION);

     hextab := Hexinit;

     repeat
     until OpenInp;
     writeln('------> File opened.');

     repeat
     until OpenOut;
     writeln('------> File opened.');

     while  not EOF(binfile) do begin
          read(binfile,binbuf);
          for i := 0 to 1 do begin
               for j := 1 to 64 do begin
                    k := ord(binbuf[i*64+j]);
                    hexbuf[2*j-1] := hextab[(k div 16)+1];
                    hexbuf[2*j]   := hextab[(k mod 16)+1];
               end;
               write(hexfile,hexbuf);
          end;
     end;
     writeln(TheTRAILER);
end.  {* BintoHex *}
