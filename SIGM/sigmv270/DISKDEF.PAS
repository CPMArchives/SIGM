{ DISKDEF.PAS of JUGCPM Vol.11 }
program simulate_diskdef;

type ms  = string[30];
     hx2 = string[2];
     hx4 = string[4];

var
   als0, css0 : integer;
   dn, fsc, lsc, skf, bls, dks, dir, cks, ofs : integer;

function hex2( i : integer ) : hx2;
    var j,k : integer;
        st  : hx2;
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
         hex2:=st;
     end;


function hex4( i : integer ): hx4;

     begin
          hex4:=hex2(hi(i))+hex2(lo(i));
     end;


function gcd( m, n : integer ) : integer;

var
   mm, nn, r, x, i : integer;

begin
     r := 0;
     mm := m;
     nn := n;
     i := 0;
     repeat
           i := i + 1;
           x := mm div nn;
           r := mm - x * nn;
           if r <> 0 then  begin
              mm := nn;
              nn := r;
           end;
     until ( r = 0 ) or ( i = $7FFF );
     gcd := nn;
end;

procedure diskdef( fsc, lsc, skf, bls, dks, dir, cks, ofs : integer );

var
   i, sectors, secmax, blkval, blkshf, blkmsk, extmsk : integer;
   dirrem, dirbks, nxtsec, nxtbas, neltst, nelts : integer;
   dirblk : integer;

begin
    secmax  := lsc - fsc;
    sectors := secmax + 1;
    if ( dks mod 8 ) = 0 then  als0 := dks div 8
    else                       als0 := dks div 8 + 1;
    css0    := cks div 4;
    blkval  := bls div 128;
    blkshf  := 0;
    blkmsk  := 0;
    while ( blkshf < 16 ) and ( blkval <> 1 ) do begin
          blkshf  := blkshf + 1;
          blkmsk  := blkmsk * 2 + 1;
          blkval  := blkval div 2;
    end;
    blkval  := bls div 1024;
    extmsk  := 0;
    i       := 0;
    while ( i < 16 ) and ( blkval <> 1 ) do begin
          i       := i + 1;
          extmsk  := extmsk * 2 + 1;
          blkval  := blkval div 2;
    end;
    if dks > 256 then extmsk := extmsk div 2;
    dirrem  := dir;
    dirbks  := bls div 32;
    dirblk  := 0;
    i       := 0;
    while ( i < 16 ) and ( dirrem <> 0 ) do begin
          i      := i + 1;
          dirblk := ( dirblk shr 1 ) or $8000;
          if dirrem > dirbks then dirrem := dirrem - dirbks
          else                    dirrem := 0;
    end;
    writeln('Disk Block Address');
    writeln('     DW sectors per track = ',hex4( sectors   ));
    writeln('     DB block shift       = ',hex2( blkshf    ));
    writeln('     DB block mask        = ',hex2( blkmsk    ));
    writeln('     DB extent mask       = ',hex2( extmsk    ));
    writeln('     DW disk-1            = ',hex4( dks - 1   ));
    writeln('     DW directory max     = ',hex4( dir - 1   ));
    writeln('     DB allocation vec.0  = ',hex2( hi(dirblk)));
    writeln('     DB allocation vec.1  = ',hex2( lo(dirblk)));
    writeln('     DW check size        = ',hex4( cks div 4 ));
    writeln('     DW offset            = ',hex4( ofs       ));
    if skf = 0 then writeln ( 'XLT table := 0')
    else begin
         nxtsec   := 0;
         nxtbas   := 0;
         neltst   := sectors div gcd(sectors,skf);
         nelts    := neltst;
         writeln('Translation table here');
         if sectors < 256 then
                write('      DB sectors ' )
         else   write('      DW sectors ' );
         for i := 1 to sectors do  begin
             if sectors < 256 then
                    write(' ',hex2( nxtsec + fsc ))
             else   write(' ',hex4( nxtsec + fsc ));
             nxtsec   := nxtsec + skf;
             if nxtsec >= sectors then nxtsec := nxtsec - sectors;
             nelts    := nelts - 1;
             if nelts = 0 then begin
                nxtbas  := nxtbas + 1;
                nxtsec  := nxtbas;
                nelts   := neltst;
             end;
         end;
         writeln;
    end;
end;

procedure endef;

begin
    writeln('Here Directory buffer of 128 byte area');
    writeln('Allocation vector work ALV0 = ', als0, ' byte' );
    writeln('Dir Check  vector work CSV0 = ', css0, ' byte' );
end;

function ask( message : ms ) : integer;

var ans : integer;

begin
    write( message );
    readln( ans );
    ask := ans;
end;

procedure askparam( var  fsc, lsc, skf, bls, dks, dir, cks, ofs : integer );

begin
     fsc := ask( 'First sector number           ? ');
     lsc := ask( 'Last  sector number           ? ');
     skf := ask( 'Skew factor  0 if not         ? ');
     bls := ask( 'Block size, 1024,2048...16382 ? ');
     dks := ask( 'Disk size in blocks           ? ');
     dir := ask( 'Number of Directory element   ? ');
     cks := dir;
     ofs := ask( 'Offset of track/number of sys ? ');
end;


begin {main}
    askparam( fsc, lsc, skf, bls, dks, dir, cks, ofs );
    diskdef(  fsc, lsc, skf, bls, dks, dir, cks, ofs );
    endef;
end.
