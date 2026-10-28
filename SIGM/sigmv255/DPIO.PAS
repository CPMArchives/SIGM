MODULE DPIO;            { I/O module for CP/M80 }
{-------------------------------------------------------------}
{                                                             }
{       Program Title: Floppy Disk  Patch Program             }
{                                                             }
{       Program  file:  DPM.PAS         ... Main control      }
{                       DPEDIT.PAS      ... Edit module       }
{                       DPIO.PAS        ... I/O  module       }
{                       DPL.CMD         ... Linkage parameter }
{                                                             }
{       Last update : 21-Oct-1984 by K.Maeda                  }
{                                                             }
{           Note : This program was originally written by     }
{               Keizo Maeda and checked (and enhanced) by     }
{               Sakurao Nemoto and is a Public Domain Soft-   }
{               ware (JUG-CP/M). If you make revisions, etc.  }
{               please leave the author and modifiers name    }
{               in the source file. Thank you.                }
{                                                             }
{          Ver-Rev :                                          }
{                       0.0 : 7 July, 83       by  K.Maeda    }
{                       2.0 : 28 July,83                      }
{                             ...check sum...  by  S.Nemoto   }
{                       3.0 : 20 September,83                 }
{                             ...8 inch support...            }
{                       5.3 : 6 November, 83                  }
{                             ...Printing Hard Copy...        }
{                       5.5 : 23 December,83                  }
{                             ...Read EBCDIK code...          }
{                       6.0 : 12 May,84                       }
{                             ...Make File...                 }
{                       6.1 : 18 May,84                       }
{                             ...Exclusive Find...            }
{                       6.2 : 17 June,84                      }
{                       6.3 : 21 October,84                   }
{                             ...beep at print_mode...        }
{                                                             }
{-------------------------------------------------------------}


const
        ctrl_a= 1;
        ctrl_j=10;
        ctrl_k=11;
        ctrl_l=12;
        ctrl_o=15;
        ctrl_p=16;
        esc  = 27;
        cr   = 13;
        bs   =  8;

type
cpmoperation = (coldboot,warmboot,constat,conin,conout,list,
                punout,rdrin,home,seldsk,settrk,setsec,setdma,
                dskread,dskwrite);
iooperation  = (get_disk, put_disk);
buffer = array [0..255] of byte ;
ptr = ^byte;

var
  ebcdik:       external boolean; { flag of EBCDIK code }

  sb_last_x,
  sb_last_y:    external integer;

  cdisk:        external integer; { current Drive no. }


  in_drive,in_trk,in_sec,in_skew,            { variables for FD i/o }
  in_trk_num,in_sec_num,
  e_trk,e_sec,
  o_drive,o_trk,o_sec,o_skew,
  o_trk_num,o_sec_num   :       external integer;

  ch_drv, ch_drv_o :            external char;

  skew_tab:     external array[0..2,1..52] of byte;   { skew table }

  buff:         external array[0..15] of buffer;      { I/O Buffer }

  flg_85 : external boolean;
  pr_flg : external boolean;
  pr2_flg: external boolean;

external function @bdos( func:integer; de_adr:ptr ) : integer;

procedure prologue;        (* start routine *)
var a,i,j:   integer;
    sk3,sk6: integer;
    ch : char;
begin
  ebcdik :=false;

  flg_85:=false;  pr_flg:=false;

  cdisk:=0;                         { save current Drive No.  }
  a:=$4;
  move(a^,cdisk,1);

  sk3:=1; sk6:=1;                   { Set skew table }
  for i:=1 to 26 do
  begin
    skew_tab[0,i]:=i;

    skew_tab[1,i]:=sk3;
    sk3:=sk3+3;
    if sk3 > 26 then sk3:=sk3-26;

    skew_tab[2,i]:=sk6;
    sk6:=sk6+6;
    if sk6 > 26 then sk6:=sk6-26;
    if sk6 = 1  then sk6:=2;
  end;

  for i:=27 to 52 do
  begin
    j:=i-26;
    skew_tab[0,i]:=i;
    skew_tab[1,i]:=skew_tab[1,j]+26;
    skew_tab[2,i]:=skew_tab[2,j]+26
  end;
end;


procedure wboot;                { return to CP/M }
begin
  xygoto( 1,23);
  set_drive( cdisk );
  sb_bios_call(home,0);
  sb_bios_call(warmboot,0)
end;

procedure rset_drv;
var
  i : integer;
begin
  i:=@bdos(13,addr(i)) {------ Reset Drive ------}
end;


procedure get_buff( var a_buff:buffer; var noerr:boolean );
var
  sec1,sec2    : integer;
  ior:           byte;
  ch:            char;
begin
  noerr:=true;
  sec2:=skew_tab[in_skew,in_sec];
  sec2:=sec2+sec2;
  sec1:=sec2-1;

  if in_sec_num=13 then     { for fd1  }
  begin
    sec2:=in_sec+in_sec;
    sec1:=sec2-1;
    sec2:=skew_tab[2,sec2];
    sec1:=skew_tab[2,sec1]
  end;

  set_drive(in_drive);
  def_dma( addr(a_buff[0]) );

  sb_bios_call(settrk,in_trk  );
  sb_bios_call(setsec,sec1    );
  sb_bios_call(dskread,0      );
  inline("STA / ior );
  if ior<>0 then noerr:=false;

  def_dma( addr(a_buff[128]) );
  sb_bios_call(setsec,sec2    );
  sb_bios_call(dskread,0      );
  inline("STA / ior );
  if ior<>0 then noerr:=false;

end;

procedure put_buff( var a_buff:buffer; var noerr:boolean );
var
  sec1,sec2 :     integer;
  ior :           byte;
  ch:             char;
begin
  noerr:=true;
  sec2:=skew_tab[o_skew,o_sec];
  sec2:=sec2+sec2;
  sec1:=sec2-1;

  if o_sec_num = 13 then  { for fd1  }
  begin
    sec2:=o_sec+o_sec;
    sec1:=sec2-1;
    sec2:=skew_tab[2,sec2];
    sec1:=skew_tab[2,sec1]
  end;

  set_drive(o_drive);
  def_dma( addr(a_buff[0]) );

  sb_bios_call(settrk,o_trk  );
  sb_bios_call(setsec,sec1   );
  sb_bios_call(dskwrite,0    );
  inline("STA / ior );
  if ior<>0 then noerr:=false;

  def_dma( addr(a_buff[128]) );
  sb_bios_call(setsec,sec2   );
  sb_bios_call(dskwrite,0    );
  inline("STA / ior );
  if ior<>0 then noerr:=false

end;

procedure set_drive(drive:integer);
begin
  inline("LHLD / drive /
         "MOV E,L /
         "MOV D,H /
          $0e / $0e /
         "CALL / $05 / $00 );

  sb_bios_call(seldsk,drive)
end;

procedure def_dma( adres:integer );
begin
  inline("LHLD / adres /
         "MOV E,L /
         "MOV D,H /
          $0e / $1a /    { set dma address }
         "CALL / $05 / $00 );
  sb_bios_call(setdma,adres)
end;


procedure KIND_DSK( DRIVE:integer; var FL_TYPE:string;
                    var TRK_NUM,SEC_NUM,SKEW : integer;var NOERR:boolean );
var
  SEC,D_ADR,DPB_ADR : integer ;
begin
  INLINE("LHLD / DRIVE /
         "MOV E,L /
         "MOV D,H /
          $0E / $0E /        (* Select disk *)
         "CALL / $05 / $00 /
          $0E / $1F /        (* Get DPB address *)
         "CALL / $05 / $00 /
         "SHLD / DPB_ADR );


  move(DPB_ADR^,SEC,2);

  NOERR:=false;
  FL_TYPE:='    ';
  TRK_NUM:=40;
  SEC_NUM:=32;

  case SEC of
  32: begin
        FL_TYPE:='MD1D';
        TRK_NUM:=35;
        SEC_NUM:=16;
        SKEW:=0;
        NOERR:=true
      end;
  64: begin
        FL_TYPE:='MD2D';
        TRK_NUM:=40;
        SEC_NUM:=32;
        SKEW:=0;
        NOERR:=true
      end;
  26: begin
        FL_TYPE:='FD1 ';
        TRK_NUM:=77;
        SEC_NUM:=13;
        SKEW:=0;
        NOERR:=true
      end;
  104:begin
        FL_TYPE:='FD2D';
        TRK_NUM:=77;
        SEC_NUM:=52;
        SKEW:=-1;
        NOERR:=true
      end;
  end;
end;

procedure dump_buff;           {  Make HEX and ASCII dump of var. BUFF }
var
  i,j,k,l : integer;
  blkno   : integer;
  sum     : integer;
  vsum    : array [0..15] of integer;
begin
  sb_clr_scrn;
  if in_trk_num > 40                                       { blk-no }
     then blkno:=( (in_trk -2)*52 + in_sec-1 )  div 16     { 8 inch }
     else blkno:=(in_trk - 2)*4+((in_sec -1) div 8);       { 5 inch }

  if pr_flg then writeln([addr(lst_out)]);

  write([addr(pr_out_ch)],'     Drive: ',ch_drv:1,'   Track: ',in_trk:2,
                          '   Sector: ',in_sec:2 ,
                          '   Block: ');hex(blkno);
  if ebcdik then write([addr(pr_out_ch)],'                  EBCDIK')
            else write([addr(pr_out_ch)],'                  JIS 8');
  writeln([addr(sb_out_ch)]);
  writeln([addr(pr_out_ch)]);

  write([addr(pr_out_ch)],'     ');
  for i:=0 to 15 do begin
    if i=8 then write([addr(pr_out_ch)],' ');
    vsum[i]:=0;
    hex1(i)
  end;
  writeln([addr(pr_out_ch)],'  Hsum');

  for i:=0 to 15 do
  begin
    k:=i*16;
    hex(k); write([addr(pr_out_ch)],':  ');
    sum:=0;
    begin
      for l:=0 to 15 do
      begin
        if l=8 then write([addr(pr_out_ch)],' ');
        sum:=sum+buff[0][k+l];
        hex(buff[0][k+l]);
        vsum[l]:=vsum[l]+buff[0][k+l];
        write([addr(pr_out_ch)],' ');
      end;
      write([addr(pr_out_ch)],'   ');  hex(sum)
    end;

    write([addr(pr_out_ch)],'   ');
    for j:=k to k+15 do ascii(buff[0][j]);
    writeln([addr(pr_out_ch)])
  end;

    write([addr(pr_out_ch)],'------');
    sum:=0;
    for i:=0 to 15 do
    begin
      sum:=sum+vsum[i];
      write([addr(pr_out_ch)],'---')
    end;
    writeln([addr(pr_out_ch)],'-----');

    write([addr(pr_out_ch)],'VSum:');
    for i:=0 to 15 do
    begin
      if i=8 then write([addr(pr_out_ch)],' ');
      hex(vsum[i]);
      write([addr(pr_out_ch)],' ');
    end;
    write([addr(pr_out_ch)],'   ');hex(sum);
    writeln([addr(pr_out_ch)]);
    writeln([addr(pr_out_ch)]);

end;


procedure COUNT_UP( var TRK,SEC,SEC_NUM : integer );
begin
  SEC:=SEC+1;
  if SEC > SEC_NUM  then
  begin
     SEC:=1;
     TRK:=TRK+1
  end;
end;

procedure COUNT_DWN( var TRK,SEC,SEC_NUM : integer );
begin
  SEC:=SEC-1;
  if SEC < 1 then
  begin
     SEC:=SEC_NUM;
     TRK:=TRK-1;
     if TRK < 0 then begin
                       TRK:=0;
                       SEC:=1
                     end;
  end
end;

procedure sb_out_ch(ch:char);
begin
  sb_bios_call(conout,ord(ch))
end;

procedure lst_out(ch:char);
begin
  sb_bios_call(list,ord(ch))
end;

procedure pr_out_ch(ch:char);
begin
  sb_bios_call(conout,ord(ch));
  if pr_flg then lst_out(ch)
end;


function  sb_getch:char;
var
  ch : char;
begin

  repeat
     sb_bios_call(conin,0);
     inline("STA / ch);
     if ch=chr(ctrl_p) then begin
                            pr_flg:= not pr_flg;
                            if pr_flg then sb_out_ch(chr(7)); {beep}
                            pr2_flg:=pr_flg
                       end;
     if ch=chr(ctrl_o) then ebcdik:= not ebcdik;

  until (ch<>chr(ctrl_p)) and (ch<>chr(ctrl_o));

  sb_getch := ch
end;

procedure xygoto( x,y:integer);
begin
  sb_out_ch(chr(esc));
  sb_out_ch('=');
  sb_out_ch(chr(y+32));
  sb_out_ch(chr(x+32));
  sb_last_x := x;
  sb_last_y := y
end;

procedure sb_clr_scrn;
begin
  sb_out_ch(chr(esc)); sb_out_ch('*');
  sb_out_ch('0');
  sb_out_ch(chr(bs));  sb_out_ch(' '); sb_out_ch(chr(bs));
  xygoto(0,0)   { appended for FM-7 }
end;

procedure sb_clr_eos;
begin
  sb_out_ch(chr(esc));
  sb_out_ch('Y');
  sb_out_ch(chr(0));    { give it time to work }
  sb_out_ch(chr(0));    { give it time to work }
  sb_out_ch(chr(0));    { give it time to work }
  sb_out_ch(chr(0));    { give it time to work }
end;


procedure sb_clr_line;
begin
  sb_out_ch(chr(esc));
  sb_out_ch('T')
end;



procedure sb_bios_call(func:cpmoperation; parm:integer);
var
  dispatch_loc : integer;
  memory       : absolute [$0000] array [0..0] of byte;
begin
  dispatch_loc := (memory[1] + swap(memory[2])) + (ord(func)*3) - 3;
  inline("LHLD / parm /
         "MOV C,L /
         "MOV B,H /
         "LHLD / dispatch_loc /
         "PCHL);
end;

function sb_stcon : byte;
var
  i : integer;
  x : byte;
begin
  sb_bios_call( constat,i );
  inline( "STA / x );
  sb_stcon:=x
end;

procedure prnt_at( row,col:integer; s:string);
begin
  xygoto( col,row);
  write([addr(sb_out_ch)],s)
end;

function  sb_up_case(ch:char):char;
begin
  if (ch >= 'a') and (ch <= 'z') then
    sb_up_case := chr(ch & $df)
  else
    sb_up_case := ch
end;

procedure hex1( x: byte);
var     ml : integer;
        cl : char;
begin
  ml:=x mod 16 ;
  if ml > 9 then cl:=chr(ml+55) else cl:=chr(ml+48);
  write([addr(pr_out_ch)],'+',cl,' ')
end;

procedure hex( x : byte );
var
  mh,ml : integer;
  ch,cl : char;
begin
  mh:=x div 16 ;  ml:=x mod 16 ;
  if mh > 9 then ch:=chr(mh+55) else ch:=chr(mh+48);
  if ml > 9 then cl:=chr(ml+55) else cl:=chr(ml+48);
  write([addr(pr_out_ch)],ch,cl)
end;

procedure chex( x : byte );
var
  mh,ml : integer;
  ch,cl : char;
begin
  mh:=x div 16 ;  ml:=x mod 16 ;
  if mh > 9 then ch:=chr(mh+55) else ch:=chr(mh+48);
  if ml > 9 then cl:=chr(ml+55) else cl:=chr(ml+48);
  write([addr(sb_out_ch)],ch,cl)
end;

procedure ascii( code_ch : byte );
var
  x : byte;
  tab_ptr: ^buffer;
begin
  tab_ptr:=addr( tran_tbl );
  if ebcdik then x:=tab_ptr^[code_ch]
            else x:=code_ch;
  if (x > 31) and (x < 255)
  then write([addr(pr_out_ch)],chr(x))
  else write([addr(pr_out_ch)],'.'   )
end;

procedure cascii( code_ch : byte );
var
  x : byte;
  tab_ptr: ^buffer;
begin
  tab_ptr:=addr( tran_tbl );
  if ebcdik then x:=tab_ptr^[code_ch]
            else x:=code_ch;
  if (x > 31) and (x < 255)
  then write([addr(sb_out_ch)],chr(x))
  else write([addr(sb_out_ch)],'.'   )
end;

function cval( ch : char ) : byte;
var
  x : byte;
  tab_ptr: ^buffer;
  i : integer;
begin
  tab_ptr:=addr( tran_tbl );
  x := ord(ch);

  if ebcdik then
  begin
        i:=-1;
        repeat
          i:=i+1;
        until (x=tab_ptr^[i]) or (i=255);
        x:=i;
  end;

  cval := x
end;


procedure tran_tbl;
                       {  Table for     EBCDIK  --->  JIS 8   }

begin
inline( $00/$01/$02/$03/$9C/$09/$86/$7F/$97/$8D/$8E/$0B/$0C/$0D/$0E/$0F/
        $10/$11/$12/$13/$9D/$0A/$08/$87/$18/$19/$92/$8F/$1C/$1D/$1E/$1F/
        $80/$81/$82/$83/$84/$85/$17/$1B/$88/$89/$8A/$8B/$8C/$05/$06/$07/
        $90/$91/$16/$93/$94/$95/$96/$04/$98/$99/$9A/$9B/$14/$15/$9E/$1A/
        $20/$A1/$A2/$A3/$A4/$A5/$A6/$A7/$A8/$A9/$5B/$2E/$3C/$28/$2B/$21/
        $26/$AA/$AB/$AC/$AD/$AE/$AF/$A0/$B0/$61/$5D/$5C/$2A/$29/$3B/$5E/
        $2D/$2F/$62/$63/$64/$65/$66/$67/$68/$69/$7C/$2C/$25/$5F/$3E/$3F/
        $6A/$6B/$6C/$6D/$6E/$6F/$70/$71/$72/$60/$3A/$23/$40/$27/$3D/$22/
        $73/$B1/$B2/$B3/$B4/$B5/$B6/$B7/$B8/$B9/$BA/$74/$BB/$BC/$BD/$BE/
        $BF/$C0/$C1/$C2/$C3/$C4/$C5/$C6/$C7/$C8/$C9/$75/$76/$CA/$CB/$CC/
        $77/$7E/$CD/$CE/$CF/$D0/$D1/$D2/$D3/$D4/$D5/$78/$D6/$D7/$D8/$D9/
        $79/$7A/$E0/$E1/$E2/$E3/$E4/$E5/$E6/$E7/$DA/$DB/$DC/$DD/$DE/$DF/
        $7B/$41/$42/$43/$44/$45/$46/$47/$48/$49/$E8/$E9/$EA/$EB/$EC/$ED/
        $7D/$4A/$4B/$4C/$4D/$4E/$4F/$50/$51/$52/$EE/$EF/$F0/$F1/$F2/$F3/
        $24/$9F/$53/$54/$55/$56/$57/$58/$59/$5A/$F4/$F5/$F6/$F7/$F8/$F9/
        $30/$31/$32/$33/$34/$35/$36/$37/$38/$39/$FA/$FB/$FC/$FD/$FE/$FF  );
end;

procedure hlp_msg;   { display help message }
var
  fhlp    : text;    { file }
  dat_hlp : string;  { i/o buffer }
  ch      : char;

begin
  set_drive(cdisk);
  sb_bios_call( home,0 );

  assign( fhlp,'DP.HLP');
  reset ( fhlp );

  sb_clr_scrn;

  while  (not eof( fhlp )) and (ioresult<>255) do
  begin
    readln(fhlp,dat_hlp);
    writeln([addr(sb_out_ch)],dat_hlp)
  end;

  if ioresult=255 then writeln([addr(sb_out_ch)],'HELP file not found.');

  write([addr(sb_out_ch)],'Hit any key! ');
  ch:=sb_getch
end;

function get_str( var str:string; var delimiter:char ) : integer;
var
  c_num : integer;
  ch : char ;
  w_str : string;
begin
  c_num := 0;
  w_str := '';
  ch := sb_getch;

  while (ch<>chr(CR)) & (ch<>chr(ctrl_K)) & (ch<>chr(ctrl_J))
      & (ch<>chr(ESC)) do
   begin
     if (ch>=' ') & (ch<chr(241))
      then begin
                sb_out_ch( ch );
                c_num := c_num+1;
                w_str := concat( w_str,ch )
      end else
     if ch=chr(BS)
      then begin
                c_num := c_num-1;
                if c_num < 0 then begin
                                c_num := 0;
                                w_str := ''
                end else begin
                                delete( w_str,c_num+1,1 );
                                sb_out_ch(ch);
                                sb_out_ch(' ');
                                sb_out_ch(ch);
                end;
      end;

     ch := sb_getch;
   end; {while}

  str := w_str;
  delimiter := ch;
  get_str := c_num
end;

function get_num( var str : string; delimiter : char ) : integer;
var
  i, source_l,
  get_l         : integer;
  g_str         : string ;
  num           : integer;
begin
  source_l := length( str );

  repeat
   if source_l = 0 then begin
                        get_num := 0;
                        exit            { empty data }
                  end;
   if str[1]=' ' then begin
                         delete( str,1,1 );
                         source_l := source_l - 1;
                 end;
  until (str[1]<>' ') and (source_l>0);

  i := pos( delimiter,str );
  if i=0 then begin
                get_l := source_l;
                g_str := str;
                str   := ''
         end else begin
                get_l := i-1;
                g_str := copy( str,1,get_l );
                str   := copy( str,i+1,source_l-i)
         end;

  num:=0;
  for i:=1 to get_l do
    begin
        if (g_str[i] >='0') & (g_str[i] <='9')
           then num := ord(g_str[i])-48 + num*10
           else begin { error code }
                get_num := -1;
                exit
           end;
    end;

  get_num := num
end;

modend.
