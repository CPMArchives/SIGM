{ DPR.PAS of JUGPDS Vol.11 by M. Miyao (No.78) }

program disk_parameter_read(input, output );

const
     CR     = $0D;
     LF     = $0A;
     SRSDSK =   3;

type
     hex2 = string[2];
     hex4 = string[4];

var
     ans    : char;
     diskno : integer;

function peek( adr : integer ) : byte;
    begin peek := mem[adr]; end;

procedure poke( adr : integer; data : byte );
    begin mem[adr] := data; end;


{
  seldsk------> getdphadr(disk#)
                    |
  XLTTBL n          |
  .--------.  <-----'  sector trans tavle
  | XLTTBL |  --.    .--------.
  :--------:    '--> |   1    |        dirbuf
  |  0000  |         |   7    |     .------------------------------------.
  :--------:         |   :    |  .->|   128 byte directory access buffer |
  |  0000  |         |   :    |  |  '------------------------------------'
  :--------:         |   22   |  |
  |  0000  |         '--------'  |        .------------.
  :--------:                     |   .--->| sector(l)  | DPBADR
  | DIRBUF |---------------------'   |    '------------'
  :--------:                         |          :
  | DPBADR |-------------------------'          :
  :--------:               .---------.    .------------.
  |  CSV n |-------------> | CSV n   |    | sector(h)  |
  :--------:               | check   |    :------------:
  |  ALV n |--> .--------. | vectors |    | offset(h)  |
  '--------'    | ALV n  | |         |    '------------'
                |alloca- | '---------'
                |tion    |
                |vectors |
                '--------'
}


function getdphadr( dsk : integer ) : integer;

begin
     getdphadr := bioshl( 8 {seldisk}, dsk );
end;

function getxltadr( dsk : integer ) : integer;

var
    adr  : integer;

begin
     adr := getdphadr( dsk );
     getxltadr := peek(adr) + peek(adr+1)*256;
end;

function getdpbadr( dsk : integer ) : integer;

var
    adr  : integer;

begin
     adr := getdphadr( dsk );
     getdpbadr := peek(adr+10) + peek(adr+11)*256;
end;



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

procedure dphtblprint(dsk : integer);

var
   adr   : integer;
   data  : integer;

   begin
       adr := getdphadr(dsk);
       data := getxltadr(dsk);
       if data = 0 then writeln('        No translation table')
       else writeln( 'XLT table address            = ',
                      hex4cnv(data));
       writeln(      'Directory buffer address     = ',
                      hex4cnv(peek(adr+8)+peek(adr+9)*256));
       writeln(      'Disk Parameter Block address = ',
                      hex4cnv(peek(adr+10)+peek(adr+11)*256));
       writeln(      'Check vector address         = ',
                      hex4cnv(peek(adr+12)+peek(adr+13)*256));
       writeln(      'Allocation vector address    = ',
                      hex4cnv(peek(adr+14)+peek(adr+15)*256));
   end;


procedure xlttblprint( dsk : integer );

var
   adr   : integer;
   data  : integer;
   i     : integer;
   sectn : integer;

   begin
       adr := getxltadr( dsk );
       if adr <> 0 then begin
          write ('Sector read order : ');
          sectn := peek(getdpbadr(dsk))+peek(getdpbadr(dsk)+1)*256;
          for i := 0 to sectn-1 do
              write( peek(getxltadr(dsk)+i),' ');
          writeln;
       end;
   end;

procedure dpbtblprint( dsk : integer );

var
   adr   : integer;
   spt, bsh, blm, exm, dsm, drm, al0, al1, cks, off   : integer;

   begin
        adr := getdpbadr(dsk);
        spt := peek(adr)+peek(adr+1)*256;
        bsh := peek(adr+2);
        blm := peek(adr+3);
        exm := peek(adr+4);
        dsm := peek(adr+5)+peek(adr+6)*256;
        drm := peek(adr+7)+peek(adr+8)*256;
        al0 := peek(adr+9);
        al1 := peek(adr+10);
        cks := peek(adr+11)+peek(adr+12)*256;
        off := peek(adr+13)+peek(adr+14)*256;
        writeln('    Sector per Track   = ', hex4cnv( spt ), '/ ', spt );
        writeln('    Block SHift        =   ', hex2cnv( bsh ), '/ ', bsh );
        writeln('    BLock Mask         =   ', hex2cnv( blm ), '/ ', blm );
        writeln('    EXtent Mask        =   ', hex2cnv( exm ), '/ ', exm );
        writeln('    Disk Size Minus 1  = ', hex4cnv( dsm ), '/ ', dsm );
        writeln('    DiRectory Minus 1  = ', hex4cnv( drm ), '/ ', drm );
        writeln('    ALlocation 0       =   ', hex2cnv( al0 ), '/ ', al0 );
        writeln('    ALlocation 1       =   ', hex2cnv( al1 ), '/ ', al1 );
        writeln('    ChecK Size         = ', hex4cnv( cks ), '/ ', cks );
        writeln('    OFFset             = ', hex4cnv( off ), '/ ', off );
   end;

begin { MAIN program }
  repeat
    writeln('* DPR: Disk parameter Read *');
    write('Disk drive name: A), B), C), D), E), or Q)uit?');
    repeat
      ans := char(bios(2){ conin function call});
      write(ans);
    until   ((ans>='a')and(ans<='e'))
          or((ans>='A')and(ans<='E'))
          or(ans='q')or(ans='Q');
    if (((ans>='a')and(ans<='e'))or((ans>='A')and(ans<='E'))) then begin
        if      (ans>='a')and(ans<='e') then diskno:=byte(ans)-byte('a')
        else if (ans>='A')and(ans<='E') then diskno:=byte(ans)-byte('A');
        writeln; writeln;
        writeln( 'Disk Parameter Head Address  = ',
                  hex4cnv(getdphadr(diskno)));
        xlttblprint(diskno);
        dphtblprint(diskno);
        writeln( 'Disk Parameter Block address = ',
                  hex4cnv(getdpbadr(diskno)));
        dpbtblprint(diskno);
        writeln; writeln;
    end;
  until (ans = 'Q') or (ans = 'q');
  diskno := getdphadr(SRSDSK);
end.

