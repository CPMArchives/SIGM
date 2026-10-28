{ DSKDMP.PAS of JUGPDS Vol.11 by M. Miyao (No.78) }

program dskdmp(input,output);

const
    maxdsknminus1 =   4;
    maxtrknum     =  40;
    mintrknum     =   0;
    maxsecnum     =  63;
    minsecnum     =   0;
    errorcode     =  -1;
    CR            = $0D;
    LF            = $0A;
    HOMEDISK      =   3; { Turbo Pascal is on D/3 disk }

type
    hex2 = string[2];
    hex4 = string[4];

var  i,error  : integer;
     ans,adrs : integer;
     dskbuf   : array[0..127] of byte;
     chans    : char;
     incdec   : ( inc, dec , noi );
     trksec   : ( track, sector, nos );
     trk      : 0..maxtrknum;
     sec      : 0..maxsecnum;
     disk     : 0..maxdsknminus1;

function peek( adr : integer ) : byte;

    begin peek := mem[adr]; end;

procedure poke( adr : integer; data : byte );

    begin mem[adr] := data; end;


function hex2cnv( i : integer ) : hex2;
    var j,k : integer;
        st  : hex2;
        ch  : byte;

    begin
         st := '';
         j := i;
         for k:=1 to 2 do
             begin
                 ch :=( j mod $10 );
                 if ch > 9 then ch := ch + byte('@')-9
                           else ch := ch + byte('0');
                 st := chr(ch) + st;
                 j:=j div $10;
             end;
         hex2cnv:=st;
     end;


function hex4cnv( i : integer ): hex4;
     begin
          hex4cnv:=hex2cnv(hi(i))+hex2cnv(lo(i));
     end;

procedure dump( sadd, line : integer; faddress : boolean );
  var
       address     : integer;
       hia, loa, j : byte;
       stbuf       : array[0..$f] of char;

     begin
          for hia:=0 to line-1 do
              begin
                  if faddress then write( hex4cnv(sadd+hia*$10),'  ');
                  for loa:= 0 to $F do
                      begin
                          address := sadd+hia*$10+loa;
                          write(hex2cnv(peek(address)),' ');
                          stbuf[loa] := chr(peek(address));
                          if (stbuf[loa] < ' ') or (stbuf[loa] > '~')
                                          then  stbuf[loa]:= '.' ;
                      end;
                  write('    ');
                  for j:=0 to $f do
                      write(stbuf[j]);
                  writeln;
              end;
      end;

function get1sect( disk, trk, sec : integer ) : integer;

   var error : integer;

   begin
     if     (trk<=maxtrknum) and (trk>=mintrknum)
        and (sec<=maxsecnum) and (sec>=minsecnum)
        and (disk<=maxdsknminus1) and (disk>=0) then
       begin
         error:=bioshl(  8 {seldsk}, disk );
         bios(  9 {settrk}, trk  );
         bios( 10 {setsec}, sec  );
         bios( 11 {setdma}, addr( dskbuf ));
         get1sect:= -( bios( 12 {read} )  and $00FF );
       end
     else get1sect:= errorcode;
   end;

procedure memdump;

var i : integer;

    begin
        adrs:=0;
        repeat
             write('Start address (Hex) = ');
             readln(adrs);
             writeln;
             write( '      ');
             for i:= 0 to $F do write ( hex2cnv( i ), ' ');
             writeln;
             for i:= 0 to $E do write ( '-----');
             writeln;
             dump( adrs, 8, true );
             adrs := adrs + $80;
        until (adrs <= 0) and (adrs > $FF80) ;
    end;

procedure dumpexec;

    begin
        error := get1sect(disk,trk,sec);
        writeln;
        if error <> errorcode then begin
                 writeln('Disk = ', char(disk + byte('A'))
                          , '     Track = ',trk, '    Sector = ',sec );
                 writeln;
                 for i:= 0 to $F do
                     write ( hex2cnv( i ), ' ');
                 writeln;
                 for i:= 0 to $10 do write ( '----');
                 writeln;
                 dump(addr(dskbuf),8,false);
                 case trksec of
                      track : case incdec of
                                   inc : trk := trk + 1;
                                   dec : trk := trk - 1;
                      end;
                      sector: case incdec of
                                   inc : sec := sec + 1;
                                   dec : sec := sec - 1;
                      end;
                 end;
        end;
    end;

procedure dskdump;

var
    ansc   : char;
    i      : integer;

begin
   incdec := noi;
   trksec := nos;
   trk    := 0;
   sec    := 0;
   disk   := 0;
   repeat
       writeln('Q)uit or R)andum, or ');
       write(  'default Inc/Decrement is T)rack or S)ector   ' );
       ansc := char(bios(2)){ conin function call };
       while not(( ansc = 'T' ) or ( ansc = 't' )
              or ( ansc = 'S' ) or ( ansc = 's' )
              or ( ansc = 'R' ) or ( ansc = 'r' )
              or ( ansc = 'Q' ) or ( ansc = 'q' )
              or ( ansc = char(CR)) or ( ansc = char(LF)) )
          do ansc := char(bios(2)){ conin function call };
       writeln ( char( ansc ));
       case ansc of
          'Q','q' : ;
          else
              case ansc of
                   'R','r': begin
                            writeln('Disk number A->0 ');
                            writeln('            B->1 ');
                            writeln('            C->2 ');
                            writeln('            D->3 ');
                            writeln('            E->4 ');
                            write  ('            Which disk select ?    ');
                            readln ( disk );
                            if not((disk<0)or(disk>maxdsknminus1)) then begin
                               write( 'Track number            = ');
                               readln ( trk );
                               write( 'Sector number           = ');
                               readln ( sec );
                            end;
                            dumpexec;
                          end;
                   'T','t','S','s': begin
                             case ansc of
                                  'T','t' : trksec := track;
                                  'S','s' : trksec := sector;
                             end;
                             write( '                  I)ncriment or D)ecriment ');
                             chans := char(bios(2)){ conin function call };
                             while not((chans='I')or(chans='i')or(chans='D')
                                or(chans='d')) do
                                chans := char(bios(2)){ conin function call };
                             writeln ( char( chans ));
                             case chans of
                                  'I','i' : incdec := inc;
                                  'D','d' : incdec := dec;
                             end;
                   end;
                   else dumpexec;
              end;
     end;
   until (disk<0)or(disk>maxdsknminus1)or(ansc = 'Q')or(ansc='q')
end;

begin { main program }
    writeln ( '** DSKDMP **');
    write ( 'M)emory or D)isk dump?');
    chans := char(bios(2));
    while not((chans='M')or(chans='m')or(chans='D')
      or(chans='d')) do chans := char(bios(2)){ conin function call };
    writeln ( char( chans ));
    case chans of
         'M','m' : memdump;
         'D','d' : dskdump;
    end;
    error:=bioshl(  8 {seldsk}, HOMEDISK );
end.