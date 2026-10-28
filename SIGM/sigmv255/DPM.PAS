program dp;     { Floppy disk  patch program }
                { Used compiler : Pascal/mt+ }
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


type
iooperation  = (get_disk, put_disk);
buffer = array [0..255] of byte ;
ptr = ^integer;

var

  cmdch:        char;
  sb_last_x,
  sb_last_y:    integer; { for software clr to eol/ clr to eos routines }

  cdisk:        integer; { current Drive no. }

  ch_drv:       char;    { Input  drive name }
  ch_drv_o:     char;    { Output drive name }

  in_drive,in_trk,in_sec,in_skew,          { variables for FD i/o }
  in_trk_num,in_sec_num,
  e_trk,e_sec,
  o_drive,o_trk,o_sec,o_skew,
  o_trk_num,o_sec_num   : integer;

  p_drive,p_trk,p_sec,p_skew,
  p_trk_num,p_sec_num   : integer;         { for verify }

  skew_tab:   array[0..2,1..52] of byte;   { skew table }

  pat :         buffer;
  lng_pat :     integer;
  buff:         array[0..15] of buffer;        { I/O Buffer }


  flg_85 :      boolean;       { flag for 8 inch <--> 5 inch   }
  fl_type:      string;        { MD1D , MD2D , FD1 , FD2D }

  f_exit:       boolean;       { flag of read next  ..EDIT }

  ch:           char;
  str:          string;
  delimiter:    char;
  i,j,k:        integer;

  noerr:        boolean;       { i/o error flag }

  pr_flg ,
  pr2_flg:      boolean;       { flag for Hard Copy }
  ebcdik :      boolean;       { flag for EBCDIK code disk }

const
  ctrl_a = $01;
  ctrl_c = $03;
  ctrl_d = $04;
  ctrl_e = $05;
  ctrl_l = $0c;
  ctrl_r = $12;
  ctrl_s = $13;
  ctrl_x = $18;
  esc    = $1b;
  bs     = $08;
  cr     = $0d;
  ctrl_ar= $1e;
  drive_max = 7;

external procedure prologue;
external procedure wboot;
external procedure rset_drv;            { reset disk drive }
external procedure set_drive( dr : integer );
external procedure get_buff(var buff:buffer; var noerr:boolean);
external procedure put_buff(var buff:buffer; var noerr:boolean);
external procedure kind_dsk(drive:integer;var ftype:string;
                            var trk_num,sec_num,skew:integer;
                            var noerr:boolean               );
external procedure dump_buff;
external procedure edit_buff;
external procedure wr_buff;
external procedure count_up (var trk,sec,sec_num:integer);
external procedure count_dwn(var trk,sec,sec_num:integer);
external procedure pr_out_ch(ch:char);
external procedure sb_out_ch(ch:char);    { console only }
external procedure lst_out  (ch:char);    { printer only }
external function  sb_getch:char;
external function  sb_up_case(ch:char):char;
external function  sb_stcon : byte;
external procedure xygoto(x,y:integer);
external procedure sb_clr_scrn;
external procedure sb_clr_eos;
external procedure sb_clr_line;
external procedure prnt_at(row,col:integer; s:string);
external procedure hex( x:byte );
external procedure ascii( x:byte );
external procedure hlp_msg;
external function get_str(var str:string; var delimiter:char):integer;
external function get_num(var str:string; delimiter:char):integer;

procedure ioerror(iotype : iooperation);
var
  ch : char;
begin
  xygoto(0,18);
  sb_clr_line;
  if iotype=get_disk then
        write([addr(sb_out_ch)],'Read Error occured.')
  else  write([addr(sb_out_ch)],'Write Error occured.');

  while (sb_stcon=255) do ch:=sb_getch;


  write([addr(sb_out_ch)],' Continue (Y/N) ?');
  ch:=sb_up_case(sb_getch);
  sb_out_ch(ch);
  if ch='Y' then noerr:=true else wboot;
end;

(*--- change and save   disk access parameters ---*)

procedure in_d_rset;    { in_drive,in_trk... -->  p_drive,p_trk.. }
begin
  p_drive:=in_drive;  p_trk:=in_trk;  p_sec:=in_sec;
  p_trk_num:=in_trk_num;   p_sec_num:=in_sec_num;  p_skew:=in_skew
end;

procedure in_d_set;     { p_drive,p_trk...  -->  in_drive,in_sec.. }
begin
  in_drive:=p_drive;  in_trk:=p_trk;  in_sec:=p_sec;
  in_trk_num:=p_trk_num;   in_sec_num:=p_sec_num; in_skew:=p_skew
end;

procedure out_d_rset;   { in_drive,in_trk... -->  o_drive,o_trk... }
begin
  o_drive:=in_drive;  o_trk:=in_trk;  o_sec:=in_sec;
  o_trk_num:=in_trk_num;   o_sec_num:=in_sec_num; o_skew:=in_skew
end;

procedure out_d_set;    { o_drive,o_trk...  -->  in_drive,in_sec.. }
begin
  in_drive:=o_drive;  in_trk:=o_trk;  in_sec:=o_sec;
  in_trk_num:=o_trk_num;   in_sec_num:=o_sec_num; in_skew:=o_skew
end;


procedure slip;            (* move 1 Sector for making delay  *)
begin
  in_sec:=in_sec-1;
  if in_sec<1  then  in_sec:=in_sec+2;
end;


procedure menu;
begin
  flg_85:=false;
  sb_clr_scrn;
  if pr_flg then prnt_at(0,78,'*');

  prnt_at(1,1,'Floppy Disk Patch Program v6.3 by Kei.M');
  prnt_at(2,1,' Public Domain Soft. 21-Oct-84 JUG-CP/M');
  prnt_at(4,1,'Options:           D)ump  Sector');
  prnt_at(5,20,                  'L)ist  HexDec');
  prnt_at(6,20,                  'E)dit  Sector');
  prnt_at(7,20,                  'C)opy  Sector');
  prnt_at(8,20,                  'V)erify');
  prnt_at(9,20,                  'M)ake  File');
  prnt_at(10,20,                 'F)ind  Pattern');
  prnt_at(11,20,                 'X)clusive Find');
  prnt_at(12,20,                 'R)eset Drive');
  prnt_at(13,20,                 'H)elp');
  prnt_at(14,20,                 'Q)uit');
  prnt_at(22,1,'Command? ');
end;

function  dump_menu(msg:string): boolean;
var ch : char;
begin
  sb_clr_scrn;
  if pr_flg then prnt_at(0,78,'*');

  prnt_at(2,7,msg);
  prnt_at(4,7,'Drive (A,B,...) : ');
  prnt_at(5,7,'Drive   Type    : ');
  prnt_at(6,7,'Start   Track   : ');
  prnt_at(7,7,'Start   Sector  : ');

  repeat
    repeat                                              { Drive }
      xygoto(25,4);
        i:=get_str(str,delimiter);
        if i=1 then ch:=sb_up_case(str[1])
                else ch:=' ';
        if delimiter=chr(ESC) then begin
                        dump_menu:=true; exit end;

        in_drive:=ord(ch)-65;
    until(in_drive >= 0) and (in_drive < drive_max);

    ch_drv  :=ch;
    kind_dsk(in_drive,fl_type,in_trk_num,in_sec_num,in_skew,noerr);
  until  noerr ;

  if in_trk_num > 40 then flg_85:=true;

  xygoto(25,5);
  write([addr(sb_out_ch)],fl_type);
  if in_skew < 0 then begin
  repeat
    prnt_at(5,33,'skew(0,3,6) : ');
    i:=get_str(str,delimiter);
    if delimiter=chr(ESC) then begin
                dump_menu:=true; exit end;
    in_skew:=get_num(str,' ');
  until (in_skew=0) or (in_skew=3) or (in_skew=6);

  in_skew:=in_skew div 3
  end;

  repeat                                        { Track }
    xygoto(25,6);
    i:=get_str(str,delimiter);
    if delimiter=chr(ESC) then begin
                dump_menu:=true; exit end;
    in_trk:=get_num(str,' ');
    xygoto(25,6);
    write([addr(sb_out_ch)],in_trk,'   ');sb_clr_line;
  until (in_trk < in_trk_num);

  repeat                                        { Sector }
    xygoto(25,7);
    i:=get_str(str,delimiter);
    if delimiter=chr(ESC) then begin
                dump_menu:=true; exit end;
    in_sec:=get_num(str,' ');
    xygoto(25,7);
    write([addr(sb_out_ch)],in_sec,'   ');sb_clr_line;
  until (in_sec <= in_sec_num) and (in_sec > 0);
  dump_menu := false;
end;


procedure dump_proc;
begin
  if dump_menu('+++ Dump +++') then exit;
       pr2_flg:=pr_flg;
       repeat
        get_buff( buff[0],noerr );
         if noerr then begin
         dump_buff; pr_flg:=pr2_flg;
         prnt_at(22,1,
         '<space>: Forward, <bs>: Backward,  P)rint, <esc>: Exit');
         end
           else ioerror(get_disk);

           ch:=sb_up_case(sb_getch);
           if ch=chr(ctrl_c) then wboot;
           if ch='P' then begin
                          pr2_flg:=pr_flg;  pr_flg:=true;
                     end;

         if ch=chr(bs)
          then count_dwn( in_trk,in_sec,in_sec_num )
          else if ch<>'P'
               then count_up ( in_trk,in_sec,in_sec_num );
          if in_trk>=in_trk_num then begin
                                      in_trk:=in_trk_num-1;
                                      in_sec:=in_sec_num
                                    end;
   until (ch=chr(esc)) or ( not noerr );
end;

procedure edit_proc;
begin
   if dump_menu('+++ Edit +++') then exit;

   repeat
     out_d_rset;
     get_buff(buff[0],noerr);
     if (not noerr) then ioerror(get_disk);
     move(buff[0],buff[1],256);

     pr2_flg:=pr_flg;
     repeat
       dump_buff; pr_flg:=pr2_flg;

       f_exit:=false;  { exit flag from repeat loop }

       prnt_at(21,0,
     'Command?   E)dit,N)ext,W)rite and next,');
       prnt_at(21,39,
      'B)ackward,R)eturn to original, Q)uit');
       xygoto(8,21);

       ch:=sb_up_case(sb_getch);
       if ch=chr(ctrl_c) then wboot;
       if ch='P' then begin
                       pr2_flg:=pr_flg; pr_flg:=true;
                end;
       if ch <> chr(esc) then sb_out_ch(ch);

       case ch of

        'E' : edit_buff;

        'N' : begin
                f_exit:=true;
                count_up( in_trk,in_sec,in_sec_num);
                if in_trk>=in_trk_num then begin
                                           in_trk:=in_trk_num-1;
                                           in_sec:=in_sec_num
                                      end;
              end;
        'B' : begin
                f_exit:=true;
                count_dwn(in_trk,in_sec,in_sec_num);
              end;
        'R' : move( buff[1],buff[0],256 );

        'W' : wr_buff;

        'Q' : f_exit:=true;

        end;
      until f_exit;
    until  (ch='Q');
end;

procedure ver_proc;
begin
  if copy_menu('+++ Verify +++') then exit;
  in_d_rset;

  repeat
     get_buff(buff[1],noerr);
     if (not noerr) then ioerror(get_disk);
     out_d_set;
     get_buff(buff[0],noerr);
     if (not noerr) then ioerror(get_disk);
     in_d_set;

     xygoto(1,22);
     write([addr(sb_out_ch)],
     'Verifing    Drive:',ch_drv,',  Tr',in_trk:2,',  Sc',in_sec:2,
     '  and    Drive:',ch_drv_o,',  Tr',o_trk:2,',  Sc',o_sec:2) ;

  { verify }
     ch:=' ' ; i:=0 ; j:=-1 ; repeat
     if buff[0][i] <> buff[1][i]    then  j:=i;
     i:=i+1;
  until ( i >= 256 ) or ( j >= 0 );
  if j >= 0 then
  begin
    if pr_flg then
       write([addr(lst_out)],
       'Unmatching. Drive:',ch_drv,', Tr',in_trk:2,', Sc',in_sec:2,
       ' <---> Drive:',ch_drv_o,', Tr',o_trk:2,', Sc',o_sec:2,', Addr ');

    xygoto(1,20);
    write([addr(sb_out_ch)],'Unmatching at ');
    hex(j);
    if pr_flg then
       writeln([addr(lst_out)]);


    write([addr(sb_out_ch)],
     '.  Continue ?      <space>: next, <esc>: exit');
    ch:=sb_getch
  end;
  count_up(in_trk,in_sec,in_sec_num);
  count_up(o_trk, o_sec, o_sec_num );
  in_d_rset;
  until cend or (ch=chr(esc));
end;


function  copy_menu(msg:string): boolean;
var ch : char;
begin
  sb_clr_scrn;
  if pr_flg then prnt_at(0,78,'*');

  prnt_at(1,7,msg);
  prnt_at(3,4,'Input disk');
  prnt_at(4,7,   'Drive (A,B,...) : ');
  prnt_at(5,7,   'Drive   Type    : ');
  prnt_at(6,7,   'Start   Track   : ');
  prnt_at(7,7,   'Start   Sector  : ');
  prnt_at(8,7,   'End     Track   : ');
  prnt_at(9,7,   'End     Sector  : ');

  prnt_at(11,4,'Output or Verify disk');
  prnt_at(12,7,   'Drive (A,B,...) : ');
  prnt_at(13,7,   'Drive   Type    : ');
  prnt_at(14,7,   'Start   Track   : ');
  prnt_at(15,7,   'Start   Sector  : ');

  repeat
    repeat
    repeat
      xygoto(25,4);
        i:=get_str(str,delimiter);
        if i=1 then ch:=sb_up_case(str[1])
                else ch:=' ';
        if delimiter=chr(ESC) then begin
                        copy_menu:=true; exit end;

        in_drive:=ord(ch)-65;
     until (in_drive >= 0) and (in_drive < drive_max);
      ch_drv:=ch;
      kind_dsk(in_drive,fl_type,in_trk_num,in_sec_num,in_skew,noerr);
    until noerr ;
    if in_trk_num > 40 then flg_85:=true;

    xygoto(25,5);
    write([addr(sb_out_ch)],fl_type);
    if in_skew < 0 then begin
    repeat
        prnt_at(5,33,'skew(0,3,6) : ');
        i:=get_str(str,delimiter);
        in_skew:=get_num(str,' ');
    until (in_skew=0) or (in_skew=3) or (in_skew=6);

    in_skew:=in_skew div 3
    end;


    repeat
        xygoto(25,6);
        i:=get_str(str,delimiter);
        in_trk:=get_num(str,' ');
        xygoto(25,6);
        write([addr(sb_out_ch)],in_trk,'   '); sb_clr_line;
    until (in_trk < in_trk_num);

    repeat
        xygoto(25,7);
        i:=get_str(str,delimiter);
        in_sec:=get_num(str,' ');
        xygoto(25,7);
        write([addr(sb_out_ch)],in_sec,'   '); sb_clr_line;
    until (in_sec <= in_sec_num) and (in_sec > 0);

    repeat
        xygoto(25,8);
        i:=get_str(str,delimiter);
        e_trk:=get_num(str,' ');
        xygoto(25,8);
        write([addr(sb_out_ch)],e_trk,'   ');sb_clr_line;
    until(e_trk >= in_trk) and (e_trk < in_trk_num);

    repeat
        xygoto(25,9);
        i:=get_str(str,delimiter);
        e_sec:=get_num(str,' ');
        xygoto(25,9);
        write([addr(sb_out_ch)],e_sec,'   ');sb_clr_line;
    until (e_sec <= in_sec_num) and (e_sec > 0);

    repeat
    repeat
        xygoto(25,12);
        i:=get_str(str,delimiter);
        if i=1 then ch:=sb_up_case(str[1])
                else ch:=' ';
        if delimiter=chr(ESC) then begin
                        copy_menu:=true; exit end;

        o_drive:=ord(ch)-65;
     until (o_drive >= 0) and (o_drive < drive_max);
      ch_drv_o:=ch;
      kind_dsk(o_drive,fl_type,o_trk_num,o_sec_num,o_skew,noerr);
    until noerr;
    if o_trk_num > 40 then flg_85:=true;

    xygoto(25,13);
    write([addr(sb_out_ch)],fl_type);
    if o_skew < 0 then begin
    repeat
        prnt_at(13,33,'skew(0,3,6) : ');
        i:=get_str(str,delimiter);
        o_skew:=get_num(str,' ');
    until (o_skew=0) or (o_skew=3) or (o_skew=6);

    o_skew:=o_skew div 3
    end;


    repeat
        xygoto(25,14);
        i:=get_str(str,delimiter);
        o_trk:=get_num(str,' ');
        xygoto(25,14);
        write([addr(sb_out_ch)],o_trk,'   '); sb_clr_line;
    until (o_trk < o_trk_num);

    repeat
        xygoto(25,15);
        i:=get_str(str,delimiter);
        o_sec:=get_num(str,' ');
        xygoto(25,15);
        write([addr(sb_out_ch)],o_sec,'   '); sb_clr_line;
    until (o_sec <= o_sec_num) and (o_sec > 0);

    prnt_at(22,1,'Ready (Y/N) :');
    ch:=sb_up_case( sb_getch );
    if ch=chr(ctrl_c)  then  wboot;
    sb_out_ch(ch);
  until ch='Y' ;
  copy_menu := false;
end;

function cend: boolean ;  { detect copy end }
var flag: boolean ;
begin
  flag:=false;
  if in_trk > e_trk       then flag:=true;
  if (in_trk = e_trk)     and
     (in_sec > e_sec)     then flag:=true;
  if (o_trk >= o_trk_num) then flag:=true;
  cend:=flag
end;

procedure copy_proc;
begin
  if copy_menu('+++ Copy +++') then exit;
  repeat
        get_buff( buff[0],noerr );
        if ( not noerr ) then ioerror(get_disk);

        in_d_rset;  out_d_set;  {  parm  in->p , o->in }
        slip;
        put_buff( buff[0],noerr );
        if ( not noerr )   then ioerror(put_disk);
        if flg_85 then get_buff( buff[0],noerr );      { get after put }
        if ( not noerr )   then ioerror(put_disk);
        in_d_set;               {  parm  p->in  }
        xygoto(1,22);
        write([addr(sb_out_ch)],
              'Copied from  Drive:',ch_drv,',  Tr',in_trk:2,',  Sc',in_sec:2,
              '  ...to...   Drive:',ch_drv_o,',  Tr',o_trk:2, ',  Sc',o_sec:2);

        count_up(in_trk,in_sec,in_sec_num);
        count_up(o_trk, o_sec, o_sec_num );
  until cend ;
end;

function  dup_menu(msg:string): boolean;
var ch : char;
begin
  sb_clr_scrn;
  if pr_flg then prnt_at(0,78,'*');

  prnt_at(1,7,msg);
  prnt_at(3,4,'Input disk');
  prnt_at(4,7,   'Drive (A,B,...) : ');
  prnt_at(5,7,   'Drive   Type    : ');
  prnt_at(6,7,   'Start   Track   : ');
  prnt_at(7,7,   'Start   Sector  : ');
  prnt_at(8,7,   'End     Track   : ');
  prnt_at(9,7,   'End     Sector  : ');


    repeat
    repeat
        xygoto(25,4);
        i:=get_str(str,delimiter);
        if i=1 then ch:=sb_up_case(str[1])
                else ch:=' ';
        if delimiter=chr(ESC) then begin
                        dup_menu := true; exit end;

        in_drive:=ord(ch)-65;
     until (in_drive >= 0) and (in_drive < drive_max);
      ch_drv:=ch;
      kind_dsk(in_drive,fl_type,in_trk_num,in_sec_num,in_skew,noerr);
    until noerr ;
    if in_trk_num > 40 then flg_85:=true;

    xygoto(25,5);
    write([addr(sb_out_ch)],fl_type);
    if in_skew < 0 then begin
    repeat
        prnt_at(5,33,'skew(0,3,6) : ');
        i:=get_str(str,delimiter);
        in_skew:=get_num(str,' ');
    until (in_skew=0) or (in_skew=3) or (in_skew=6);

    in_skew:=in_skew div 3
    end;


    repeat
        xygoto(25,6);
        i:=get_str(str,delimiter);
        in_trk:=get_num(str,' ');
        xygoto(25,6);
        write([addr(sb_out_ch)],in_trk,'   ');sb_clr_line;
    until (in_trk < in_trk_num);

    repeat
        xygoto(25,7);
        i:=get_str(str,delimiter);
        in_sec:=get_num(str,' ');
        xygoto(25,7);
        write([addr(sb_out_ch)],in_sec,'   ');sb_clr_line;
    until (in_sec <= in_sec_num) and (in_sec > 0);

    repeat
        xygoto(25,8);
        i:=get_str(str,delimiter);
        e_trk:=get_num(str,delimiter);
        xygoto(25,8);
        write([addr(sb_out_ch)],e_trk,'   ');sb_clr_line;
    until(e_trk >= in_trk) and (e_trk < in_trk_num);

    repeat
        xygoto(25,9);
        i:=get_str(str,delimiter);
        e_sec:=get_num(str,delimiter);
        xygoto(25,9);
        write([addr(sb_out_ch)],e_sec,'   ');sb_clr_line;
    until (e_sec <= in_sec_num) and (e_sec > 0);
    dup_menu := false;

end;

procedure lt_proc;
var
  ch: char;
  ii: integer;
begin
    repeat
        if dup_menu('+++ List +++') then exit;
        prnt_at(22,1,'Ready (Y/N) :');
        ch:=sb_up_case( sb_getch );
        if ch=chr(ctrl_c)  then  wboot;
        if ch=chr(ESC)     then  exit;
        sb_out_ch(ch);
    until ch='Y' ;

    o_trk:=0; o_trk_num:=1;
    repeat
        get_buff( buff[0],noerr );
        if noerr then dump_buff else ioerror(get_disk);
        count_up(in_trk,in_sec,in_sec_num);

        ii:=sb_stcon;
    until (ii=255) or cend;

    if ii=255 then ch:=sb_getch;
    while (sb_stcon=255) do ch:=sb_getch;
end;

procedure search;
var
  i,j,k: integer;
  ch : char;
begin
  { first character }
  i:=0; j:=0;

  repeat

        write([addr(sb_out_ch)],'Searching Tr',
        in_trk:2,',  Sc',in_sec:2); sb_out_ch(chr(CR));


        while (buff[0][i]<>pat[j]) and (i<256) do i:=i+1;
        if i>=256 then exit; { not found }

  { another character }
        k:=i+1; j:=j+1;
        while (buff[0][k]=pat[j]) and (j<lng_pat)
        do begin
                k:=k+1;
                j:=j+1;
        end;

        if j>=lng_pat then begin        {--- found ---}
                write([addr(pr_out_ch)],'Found at  Tr',
                in_trk:2,',  Sc',in_sec:2,',  Addr ');
                hex(lo(i)); writeln([addr(pr_out_ch)])
        end;

        j:=0;
        i:=i+1;
  until (sb_stcon=255) or (i>=256);
end;

procedure fnd_pat;
var
  fmode   : char;
  upv,lov : integer;
  i,ii    : integer;
  ch : char;
begin
    repeat
        if dup_menu('+++ Find +++') then exit;
        prnt_at(13,1,'H)ex or S)tring : ');
        ch:=sb_up_case( sb_getch );
        if ch=chr(ctrl_c)  then  wboot;
        if ch=chr(ESC) then exit;
        sb_out_ch(ch);
        if ch='H' then write([addr(sb_out_ch)],'ex');
        if ch='S' then write([addr(sb_out_ch)],'tring');

    until (ch='H') or (ch='S');

    fmode:=ch;

    prnt_at(15,1,'Pattern : ');
    i:=get_str(str,delimiter);
    if (i=0) or (delimiter=chr(ESC)) then exit;

    if pr_flg then begin
        writeln([addr(lst_out)]);
        if fmode='H' then write([addr(lst_out)],'Hex')
                     else write([addr(lst_out)],'String');
        writeln([addr(lst_out)],' Pattern : ',str);
        writeln([addr(lst_out)]);
    end;


    xygoto(0,17);
    if fmode='S' then begin
                        lng_pat:=i;
                        for i:=1 to lng_pat do
                                pat[i-1]:=ord(str[i]); end
    else begin
        lng_pat:=(i+1) div 2;
        if lng_pat<>(i div 2) then str:=concat('0',str);
        for i:=0 to lng_pat do
          begin
                ch:=sb_up_case( str[i*2+1] );
                if (ch>='0') and (ch<='9')
                then upv:=ord(ch)-48
                else if (ch>='A') and (ch<='F')
                     then upv:=ord(ch)-55
                     else upv:=0;

                ch:=sb_up_case( str[i*2+2] );
                if (ch>='0') and (ch<='9')
                then lov:=ord(ch)-48
                else if (ch>='A') and (ch<='F')
                     then lov:=ord(ch)-55
                else lov:=0;

                pat[i] := upv*16 + lov;
          end;
    end;


    o_trk:=0; o_trk_num:=1;
    repeat
        get_buff( buff[0],noerr );
        if (not noerr) then ioerror(get_disk);
        count_up(in_trk,in_sec,in_sec_num);
        if (not cend ) then
          get_buff( buff[1],noerr );
          if (not noerr) then ioerror(get_disk);

        count_dwn(in_trk,in_sec,in_sec_num);
        search;
        count_up( in_trk,in_sec,in_sec_num);

        ii:=sb_stcon; (* key press ? *)
    until (ii=255) or cend;
    if ii=255 then ch:=sb_getch;

    while (sb_stcon=255) do ch:=sb_getch;

    writeln([addr(sb_out_ch)]);
    write([addr(sb_out_ch)],'Hit any key'); ch:=sb_getch;
end;

procedure ex_fnd;
var
  upv,lov : integer;
  i,ii    : integer;
  ch      : char;
begin
  if dup_menu('+++ Ex Find +++') then exit;
  prnt_at(13,0,'HexDec Byte Data : ');
  i:=get_str(str,delimiter);
  if (i=0) or (delimiter=chr(ESC)) then exit;

  str[1] := sb_up_case( str[1] );
  str[2] := sb_up_case( str[2] );

  if (str[1]>='0') and (str[1]<='9')
  then upv:=ord(str[1])-48
  else if (str[1]>='A') and (str[1]<='F')
    then upv:=ord(str[1])-55
    else upv:=0;

  if (str[2]>='0') and (str[2]<='9')
  then lov:=ord(str[2])-48
  else if (str[2]>='A') and (str[2]<='F')
    then lov:=ord(str[2])-55
    else lov:=0;

  pat[0]:= upv*16 + lov;

  xygoto(0,12);
  writeln([addr(pr_out_ch)]);
  write([addr(pr_out_ch)],'Exclusive Find Code : ');
    hex( pat[0] );
  write([addr(pr_out_ch)],'   ');
    ascii( pat[0] );
  writeln([addr(pr_out_ch)]);
  writeln([addr(pr_out_ch)]);


    xygoto(0,17);
    o_trk:=0; o_trk_num:=1;
    repeat
        get_buff( buff[0],noerr );
        if (not noerr) then ioerror(get_disk);
        x_search;
        count_up( in_trk,in_sec,in_sec_num);

        ii:=sb_stcon; (* key press ? *)
    until (ii=255) or cend;
    if ii=255 then ch:=sb_getch;

    while (sb_stcon=255) do ch:=sb_getch;

    writeln([addr(sb_out_ch)]);
    write([addr(sb_out_ch)],'Hit any key'); ch:=sb_getch;
end;

procedure x_search;
var
  i,j,k: integer;
  ch : char;
begin
  write([addr(sb_out_ch)],'Searching Tr',
  in_trk:2,',  Sc',in_sec:2); sb_out_ch(chr(CR));

  i:=0;
  while (buff[0][i]=pat[0]) and (i<256) do i:=i+1;

  if i<256 then begin
        write([addr(pr_out_ch)],'Found at  Tr',
        in_trk:2,',  Sc',in_sec:2,',  Addr ');
        hex(lo(i)); writeln([addr(pr_out_ch)]);
  end;

end;


procedure mk_proc;
var
  dfile : file;
  ofnam : string;
  delimiter : char;
  ii,result : integer;
  irec,orec : integer;
  qt : boolean;
begin
  rset_drv; { reset drive }
  repeat
    if dup_menu('+++ Make File +++') then exit;

        repeat
        repeat
          prnt_at(13,1,'Output Drive : ');
          i:=get_str(str,delimiter);
          if i=1 then ch:=sb_up_case(str[1])
                  else ch:=' ';
          if delimiter=chr(ESC) then exit;
          o_drive:=ord(ch)-65;
         until (o_drive >= 0) and (o_drive < 6);
          ch_drv_o:=ch;
          kind_dsk(o_drive,fl_type,o_trk_num,o_sec_num,o_skew,noerr);
        until noerr;

        prnt_at(14,1,'File Name : ');
        ii:=get_str(ofnam,delimiter);
        if delimiter=chr(ESC) then exit;
  until ii>0;

    xygoto(0,15);
    o_trk:=0; o_trk_num:=1;
    set_drive( o_drive );

    assign( dfile,ofnam );
    rewrite(dfile);

    orec := 0;
    repeat
      irec := 0;
      repeat
        write([addr(sb_out_ch)],'Reading   Tr',
        in_trk:2,',  Sc',in_sec:2,chr(CR));
        get_buff( buff[irec],noerr );
        if not noerr then ioerror(get_disk);
        count_up(in_trk,in_sec,in_sec_num);
        irec := irec + 1;
        qt := cend;
      until qt or (irec > 15);

      set_drive( o_drive );

      write([addr(sb_out_ch)],'Writing ......           ',chr(CR));

      blockwrite( dfile,buff[0],result,256*irec,orec);
      if result<>0 then begin
            ioerror(put_disk); exit end;
      orec := orec + irec*2;
      if not qt then
         blockwrite( dfile,buff[0],result,256,orec );
    until qt;
    close( dfile,result );
end;




{ ==============  main procedure =============== }

begin
  prologue;
  repeat
    menu;
    cmdch:=sb_up_case(sb_getch);
    if cmdch>=' ' then sb_out_ch(cmdch);

    case cmdch of

    'D' : dump_proc;
    'E' : edit_proc;
    'H' : hlp_msg;

    'C' : copy_proc;

    'V' : ver_proc;
    'L' : lt_proc;

    'M' : mk_proc;

    'F' : fnd_pat;

    'X' : ex_fnd;  { May 18, 84 }

    'R' : rset_drv; {------ Reset Drive ------}

        end;  { case of cmdch }

      until (cmdch='Q') or (cmdch=chr(ctrl_c));

      wboot
end.
