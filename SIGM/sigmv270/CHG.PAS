{ CHG.PAS of JUGPDS Vol.11 by M. Miyao (No.78) }

program disk_parameter_change(input, output );

const
     TARGETDRV = 1;    { 0:A 1:B 2:C 3:D 4:E 5:F }
     DPBADR    = $40;  { $40 ~ $51 : work area }
     RSFLAG    = $4F;
     SAVEADRL  = $50;
     SAVEADRH  = $51;
     CHANGE    =   1;
     UNCHANGE  =  14; { these pattern may not in initial memory data }
     SORCEDISK =   3; { Turbo Pascal source drive number }

type
     dsktype  = ( reset, pcsingle, pcdouble, pc88, pc98,
                  if8, fm8, fm7, mz, pasopia, qc10,
                  yours{ Change this to your system
                  type if there is not, or add new target system type,
                  procedures printtable and initdpb also must be rewritten,
                  if add more than 2 then rewrite nans range });
     dpbmem   = ( sectl,   secth,  blkshf, blkmsk, extmsk,
                  dksm1l,  dksm1h, dirm1l, dirm1h, dirblkh,
                  dirblkl, cksd4l, cksd4h, ofsl,   ofsh );
     dpb      = array [sectl..ofsh] of byte;

var
     alvcsvover         : boolean; { ALV,CSV area overflow OK? }
     ans                  : char;
     dskno                : integer;
     dpbtable             : array[dsktype] of dpb;
     mydsktype, targetdsk : dsktype;
     nans                 : 0..11; { change range when
                                     you add more than 2 types }

function peek( adr : integer ) : byte;
    begin peek := mem[adr]; end;

procedure poke( adr : integer; data : byte );
    begin mem[adr] := data; end;

function getdphadr( dsk : integer ) : integer;

  begin
     getdphadr := bioshl( 8 {seldisk}, dsk );
  end;

function getdpbadr( dsk : integer ) : integer;

  var dphadr  : integer;

  begin
     dphadr    := getdphadr( dsk );
     getdpbadr := peek(dphadr+10)+256*peek(dphadr+11);
  end;

procedure printtable;

  begin
    writeln('* CHG: Change Disk Format *');
    writeln('Specify target disk type.');
    writeln('   Reset to org. disk:    0  or');
    writeln('   PC-8001(single side):  1');
    writeln('   PC-8001(double side):  2');
    writeln('   PC-8801, FP-1100:      3');
    writeln('   PC-9801:               4');
    writeln('   if800:                 5');
    writeln('   FM-8:                  6');
    writeln('   FM-7:                  7');
    writeln('   Sharp MZ:              8');
    writeln('   TOSHIBA Pasopia:       9');
    writeln('   QC-10:                10');
 {  writeln('                       : 11');   add here new disk }
    write  ('   Which disk? Select one:    ');
  end;

procedure setmydsktype;

{ Define here your working system type,
  then you must change this procedure for your system }

    begin
       alvcsvover:= true;       { if ALV, CSV area overflow OK then true }
       mydsktype := qc10;       { Change your own system type  }
       dskno     := TARGETDRV;  { A:0, B:1, C:2, D:3, E:4, F:5 }
    end;


procedure initdpb( dtype : dsktype );
 {

  Set up data is following

----------------------------------------------------------------------------
 System type |   PC-8001   | PC8801 |        |      |       |       |
-------------|-------------|  FM-7  | PC9801 |  MZ  | if800 |Pasopia| QC-10
 Parameter   |  1D  |  2D  |  FM-8  |        |      |       |       |
-------------|--------------------------------------------------------------
  Sectors(l) |  20  |  40  |   40   |   40   |  40  |   40  |  40   |   40
         (h) |  00  |  00  |   00   |   00   |  00  |   00  |  00   |   00
-------------|------|------|--------|--------|------|-------|-------|-------
  blkshft    |  03  |  04  |   04   |   04   |  04  |   04  |  04   |   04
-------------|------|------|--------|--------|------|-------|-------|-------
  blkmask    |  07  |  0F  |   0F   |   0F   |  0F  |   0F  |  0F   |   0F
-------------|------|------|--------|--------|------|-------|-------|-------
  extmask    |  00  |  01  |   01   |   01   |  01  |   01  |  01   |   01
-------------|------|------|--------|--------|------|-------|-------|-------
 dsksize-1(l)|  83  |  97  |   97   |   9B   |  7F  |   7F  |  93   |   8B
          (h)|  00  |  00  |   00   |   00   |  00  |   00  |  00   |
-------------|------|------|--------|--------|------|-------|-------|-------
 dirnum.-1(l)|  3F  | 7F/3F| 7F/3F  | 7F/3F  |  3F  | 7F/3F |  3F   |   3F
          (h)|  00  |  00  |   00   |   00   |  00  |   00  |  00   |   00
-------------|------|------|--------|--------|------|-------|-------|-------
 dirblok(h)  |  C0  | C0/80| C0/80  | C0/80  |  80  | C0/80 |  80   |   80
-------------|------|------|--------|--------|------|-------|-------|-------
 dirblok(l)  |  00  |  00  |   00   |   00   |  00  |   00  |  00   |   00
-------------|------|------|--------|--------|------|-------|-------|-------
 check/4(l)  |  10  | 20/10| 20/10  | 20/10  |  10  | 20/10 |  10   |   10
 check/4(h)  |  00  |  00  |   00   |   00   |  00  |   00  |  00   |   00
-------------|------|------|--------|--------|------|-------|-------|-------
 offset(l)   |  02  |  02  |   02   |   01   |  02  |   03  |  03   |   04
       (h)   |  00  |  00  |   00   |   00   |  00  |   00  |  00   |   00

        dirnum.-1,dirblok(h),check/4 : 128dir/64dir
}

 var     p : dsktype;

 begin
     for p := pcsingle to qc10 { here add your system } do begin
                                               { set standard (pc88) data }
         dpbtable[ p, sectl  ] := $40; { sectors }
         dpbtable[ p, secth  ] := $00;
         dpbtable[ p, blkshf ] := $04; { blkshft }
         dpbtable[ p, blkmsk ] := $0F; { blkmask }
         dpbtable[ p, extmsk ] := $01; { extmask }
         dpbtable[ p, dksm1l ] := $97; { dsk - 1 }
         dpbtable[ p, dksm1h ] := $00;

         { If your system has only 64 directory entries, the area of CSV and
         ALV will overflow when reading the disk sytem with 128 directory
         entries, then you must set DPB as 64 and you cannot write files more 
         than 64. }

         dpbtable[ p, dirm1l  ] := $7F; { dir - 1 };
         dpbtable[ p, dirblkh ] := $C0; { dirblk(h) }
         dpbtable[ p, cksd4l  ] := $20; { cks/4   }
         dpbtable[ p, dirm1h  ] := $00;
         dpbtable[ p, dirblkl ] := $00; { dirblk(l) }
         dpbtable[ p, cksd4h  ] := $00;
         dpbtable[ p, ofsl    ] := $02; { ofset   }
         dpbtable[ p, ofsh    ] := $00;

         { Set different byte for suitable to the system }

         case p of
           pcsingle : begin
                        dpbtable[ p, sectl  ] := $20; { sectors }
                        dpbtable[ p, blkshf ] := $03; { blkshft }
                        dpbtable[ p, blkmsk ] := $07; { blkmask }
                        dpbtable[ p, extmsk ] := $00; { extmask }
                        dpbtable[ p, dksm1l ] := $83; { dsk - 1 }
                        dpbtable[ p, dirm1l ] := $3F; { dir - 1 };
                        dpbtable[ p, dirblkh] := $C0; { dirblk(h) }
                        dpbtable[ p, cksd4l ] := $10; { cks/4   }
                      end;

           pcdouble, pc88, fm8, fm7 : {do nothing};

           pc98     : begin
                        dpbtable[ p, dksm1l ] := $9B; { dsk - 1 }
                        dpbtable[ p, ofsl   ] := $01; { ofset }
                      end;

           if8      : begin
                        dpbtable[ p, dksm1l ] := $7F; { dsk - 1 }
                        dpbtable[ p, ofsl   ] := $03; { ofset }
                      end;

           mz       : begin
                        dpbtable[ p, dksm1l ] := $7F; { dsk - 1 }
                        dpbtable[ p, dirm1l ] := $3F; { dir - 1 };
                        dpbtable[ p, dirblkh] := $80; { dirblk(h) }
                        dpbtable[ p, cksd4l ] := $10; { cks/4   }
                      end;

           pasopia  : begin
                        dpbtable[ p, dksm1l ] := $93; { dsk - 1 }
                        dpbtable[ p, ofsl   ] := $03; { ofset }
                        dpbtable[ p, dirm1l ] := $3F; { dir - 1 };
                        dpbtable[ p, dirblkh] := $80; { dirblk(h) }
                        dpbtable[ p, cksd4l ] := $10; { cks/4   }
                      end;

           qc10     : begin
                        dpbtable[ p, dksm1l ] := $8B; { dsk - 1 }
                        dpbtable[ p, ofsl   ] := $04; { ofset }
                        dpbtable[ p, dirm1l ] := $3F; { dir - 1 };
                        dpbtable[ p, dirblkh] := $80; { dirblk(h) }
                        dpbtable[ p, cksd4l ] := $10; { cks/4   }
                     end;

           { here adds your new system data which differ from
             standard data }

         end;

     end;
     if not alvcsvover then
         for p := pcsingle to qc10 { here add your system } do begin
             if dpbtable[ mydsktype, dksm1l ] < dpbtable[ p, dksm1l  ] then
                dpbtable[ p, dksm1l ] := dpbtable[ mydsktype, dksm1l ];
             if dpbtable[ mydsktype, dirm1l ] < dpbtable[ p, dirm1l  ] then
                dpbtable[ p, dirm1l  ]:= dpbtable[ mydsktype, dirm1l ];
             if dpbtable[ mydsktype, dirblkh] < dpbtable[ p, dirblkh ] then
                dpbtable[ p, dirblkh ]:= dpbtable[ mydsktype, dirblkh];
             if dpbtable[ mydsktype, cksd4l ] < dpbtable[ p, cksd4l  ] then
                dpbtable[ p, cksd4l  ]:= dpbtable[ mydsktype, cksd4l ];
                { limit the maximum target disk size to your system }
     end;
  end;

procedure savedpbadr;

  var address : integer;

  begin
     address := getdpbadr( dskno );
     poke( SAVEADRL, lo(address));
     poke( SAVEADRH, hi(address));
  end;


{     ------------                             --------   getdphadr(disk#)
     | sector(l)  |   40   DPBADR  -----.     | XLTTBL |
      ------------                      |      --------
     | sector(h)  |   41                |     |  0000  |
      ------------                      |      --------
           :                            |     |  0000  |
           :                            |      --------
      ------------                      |     |  0000  |
     | offset(h)  |   4E                |      --------
      ------------                      |     | DIRBUF |
     | set/res flg|   4F   RSFLAG       |      --------
      ------------                      '-->  | DPBADR | -.
     | save old   |   50   SAVEADRL            --------   |
      ------------                  <--       |  CSV n |  |
     | DPB addr.  |   51   SAVEADRH    |       --------   |
      ------------                     |      |  ALV n |  |
                                       |       --------   |
         usage       address           |                  |
                                        ------------------
 }
procedure setdpb( dtype : dsktype );

 var i : 0..14;

  begin
     if peek( RSFLAG ) <> CHANGE then savedpbadr;
     for i:= 0 to 14 do    poke( DPBADR + i, dpbtable[ dtype, dpbmem(i)]);
     poke( getdphadr( dskno ) +10 {lo byte of DPB address}, DPBADR );
     poke( getdphadr( dskno ) +11 {hi byte of DPB address}, $00    );
     poke( RSFLAG, CHANGE );
  end;


procedure resetdsk;

  { Set Disk Parameter Block address at the Disk Parameter Header
    to the original address which are saved into SAVEADRH/L
    and change RSFLAG to UNCHANGE }

  begin
     poke( getdphadr( dskno ) +10 {lo byte of DPB address}, peek(SAVEADRL));
     poke( getdphadr( dskno ) +11 {hi byte of DPB address}, peek(SAVEADRH));
     poke ( RSFLAG, UNCHANGE );
  end;

begin { MAIN program }
     setmydsktype;                    { set up working disk/machine type  }
     initdpb( mydsktype );            { set up all target disk type table }
     printtable;                      { select target disk type           }
     repeat
         readln( nans ) ;
     until (nans>=0) and (nans<11{change if add new type});
     case nans of                     { define target disk type           }
          0 : targetdsk := reset;
          1 : targetdsk := pcsingle;
          2 : targetdsk := pcdouble;
          3 : targetdsk := pc88;
          4 : targetdsk := pc98;
          5 : targetdsk := if8;
          6 : targetdsk := fm8;
          7 : targetdsk := fm7;
          8 : targetdsk := mz;
          9 : targetdsk := pasopia;
          10: targetdsk := qc10;
{         11: targetdsk := added new disk type   }
     end;
     if targetdsk = reset then begin
        if peek( RSFLAG ) = CHANGE then  resetdsk
     end
     else setdpb( targetdsk );
     dskno := getdphadr(SORCEDISK);       { reset bdos state to A drive }
end.
