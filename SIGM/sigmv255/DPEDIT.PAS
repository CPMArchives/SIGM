MODULE DPEDIT;  { Edit module for CP/M80 and CP/M86 }
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
   left_x = 5;
   right_x= 52;
   bound_x=28;
   c_off_x=62;

   y_top  = 3;
   y_bot  =18;

   ctrl_a = 1;
   ctrl_b = 2;
   ctrl_c = 3;
   ctrl_d = 4;
   ctrl_e = 5;
   ctrl_l =12;
   ctrl_s =19;
   ctrl_x =24;
   bs     = 8;
   esc    =27;
   ctrl_ar=$1e;

type
   buffer = array[0..255] of byte;
   iooperation  = (get_disk, put_disk);
var
   px,py:       integer;
   dval:        integer;

   ch:          external char;
   str:         external string;
   delimiter:   external char;
   buff:        external array[0..15] of buffer;

   in_drive,in_trk,in_trk_num,
   in_sec,in_sec_num,in_skew,
   o_drive, o_trk, o_trk_num,
   o_sec, o_sec_num, o_skew  : external integer;
   ch_drv, ch_drv_o :          external char;

   flg_85 : external boolean;
   f_exit ,
   noerr  : external boolean;
   fl_type: external string;

external procedure sb_out_ch(ch:char);
external function  sb_get_ch : char;
external function  sb_up_case(ch:char) : char;
external procedure chex( x:byte );
external procedure xygoto(x,y : integer);
external procedure prnt_at(row,col:integer; str:string);
external procedure sb_clr_scrn;
external procedure sb_clr_line;
external procedure wboot;
external function  get_str(var str:string; var delimiter:char):
                        integer;
external function  get_num(var str:string; delimiter:char):integer;


external procedure dump_buff;
external procedure put_buff (var buff:buffer; var noerr:boolean);
external procedure get_buff (var buff:buffer; var noerr:boolean);
external procedure ioerror( ie : iooperation );
external procedure kind_dsk(drive:integer;var fl_type:string;
           var trk_num,sec_num,skew:integer; var noerr:boolean);
external procedure slip;
external procedure count_up(var trk,sec,sec_num:integer);
external procedure cascii(i:byte);
external function  cval( c:char ) : byte;
external procedure out_d_set;
external procedure in_d_set;
external procedure in_d_rset;

(*$E-*)
procedure move_r;   { set right position   to px,py }
var mx : integer;
begin
  px:=px+1;
  mx:=(px-1) mod 3;
  if px >=bound_x then if px=bound_x then px:=bound_x+1
                                     else mx:=(px-2) mod 3;

  if mx = 0  then px:=px+1;
  if px > right_x then
  begin
    px:=left_x;
    py:=py+1;
    if py>y_bot   then begin
                    py:=y_bot;
                    px:=right_x
                  end;
  end;
end;

procedure move_l;   { set left  position   to px,py }
var mx : integer;
begin
  px:=px-1;
  mx:=(px-1) mod 3;
  if px >=(bound_x+1) then  if px=(bound_x+1) then px:=bound_x-1
                                              else mx:=(px-2) mod 3;

  if mx=0  then px:=px-1;
  if px<left_x then
  begin
    px:=right_x;
    py:=py-1;
    if py<y_top  then begin
                   py:=y_top;
                   px:=left_x
                 end;
  end;
end;

procedure set_val;   { set value to buff[*]  and display  }
var
  i,n,cx,cy,mx : integer;
begin
    sb_out_ch(ch);
    if px<bound_x then cx:=(px-left_x)   div 3
                  else cx:=(px-left_x-1) div 3;
    cy:=py;
    n:=cx+(py-y_top)*16;

    if px<bound_x then mx:=(px-left_x)   mod 3
                  else mx:=(px-left_x-1) mod 3;
    if mx=1 then   { right hand value }
    begin
      i:=buff[0][n] div 16;
      buff[0][n]:=i*16+dval;
    end
    else begin     { left  hand value }
      i:=buff[0][n] mod 16;
      buff[0][n]:=dval*16+i;
    end;

    move_r;

    cx:=cx+c_off_x;
    xygoto(cx,cy);
    cascii(buff[0][n]);
    xygoto(px,py);
end;

procedure edit_char;
var
  i,n,mx,cx,cy : integer;

  procedure ch_adr;
  begin
    if px<bound_x then cx:=(px-left_x)   div 3
                  else cx:=(px-left_x-1) div 3;
    cy:=py;
    cx:=cx+c_off_x;
  end;



begin
  px := ( (px+1) div 3 ) * 3 -1;
  if px >=(bound_x-1)  then px:=px+1;

  repeat
        ch_adr;
        xygoto(cx,cy);
        ch:=sb_getch;

        if (ch<' ') then begin
          case ord(ch) of

          ctrl_a : begin ch:=chr(0); exit end;
          ctrl_e : begin
                        py:=py-1;
                        if py<y_top then py:=y_top;
                   end;
          ctrl_x : begin
                        py:=py+1;
                        if py>y_bot then py:=y_bot;
                   end;
          ctrl_d : begin
                        move_r; move_r end;
          ctrl_s : begin
                        move_l; move_l end;
          bs     : begin
                        move_l; move_l end;
          ctrl_b : if px=left_x then px:=right_x-1
                                 else px:=left_x;
          ctrl_ar: if py=y_top  then py:=y_bot
                                 else py:=y_top;

        end; { case }

        ch_adr;
        xy_goto(cx,cy);
        end; { if }

     if (ch>=' ') and (ch<chr($ff))
     then begin
        sb_out_ch( ch );
        n:=cx-c_off_x +(py-y_top) *16;
        buff[0][n] := cval(ch);
        xygoto( px,py ); chex( buff[0][n] );
        move_r; move_r; ch_adr;
     end;
  until ch=chr(esc);
end;

(*$E+*)


procedure edit_buff;   { screen edit buff (use hex code) }
begin
  px:=left_x;  py:=y_top;
  xygoto(1,21);   sb_clr_line;
  prnt_at(21,0,
'^E:up, ^X:down, ^D:right, ^S:left, ^^:top/bot, ^A:hex/char, <esc>:exit     ');
  xygoto(left_x,y_top);

  repeat
    ch:=sb_up_case(sb_getch);

    if (ord(ch)<31) or (ch=' ') then
    begin
      case ord(ch) of

    ctrl_a: edit_char;

    ctrl_e: begin
              py:=py-1;
              if py<y_top then py:=y_top;
            end;
    ctrl_x: begin
              py:=py+1;
              if py>y_bot then py:=y_bot;
            end;
    ctrl_d: move_r;
    ctrl_s: move_l;
    bs    : move_l;
    ctrl_b: if px=left_x then px:=right_x else px:=left_x;
    ctrl_ar:if py=y_top  then py:=y_bot   else py:=y_top;
      end;

      if ch=' ' then move_r;
      xygoto(px,py)
    end;

    if (ch>='0') and (ch<='9') then
    begin
      dval:=ord(ch)-48;
      set_val
    end;
    if (ch>='A') and (ch<='F') then
    begin
      dval:=ord(ch)-55;
      set_val
    end;

  until (ch=chr(esc));
end;

procedure wr_buff;   { write buff to sector }
var
   ch: char;
   i : integer;
begin
  xygoto(1,21);     sb_clr_line;
  prnt_at(21,0,
'Command?   W)rite same sector, A)nother sector, C)ancel                    ');
  xygoto(8,21);
  ch:=sb_up_case(sb_getch);
  if ch <> chr(esc) then sb_out_ch(ch);

  case ch of

  'W': begin
       f_exit:=true;
       put_buff(buff[0],noerr);
       if (not noerr) then ioerror(put_disk);
       count_up(in_trk,in_sec,in_sec_num);
       if in_trk >= in_trk_num then begin
                                    in_trk:=in_trk_num-1;
                                    in_sec:=in_sec_num
                               end;
       end;
  'A': begin
       f_exit:=true;
       sb_clr_line;
       prnt_at(21,0,
'Drive:   Type:      Track:    Sector:                                      ');

       repeat
       repeat
         xygoto(6,21);
         i:=get_str(str,delimiter);
         if i=1 then ch:=sb_up_case(str[1])
                else ch:=' ';
         o_drive:=ord(ch)-65;
        until (o_drive>=0) and (o_drive<7);
         ch_drv_o:=ch;
         kind_dsk( o_drive,fl_type,o_trk_num,o_sec_num,o_skew,noerr );
        until  noerr ;
       o_skew:=0;
       if o_trk_num > 40 then flg_85:=true;

       xygoto(14,21);
       write([addr(sb_out_ch)],fl_type);

       repeat
         xygoto(26,21);
         i:=get_str(str,delimiter);
         o_trk:=get_num(str,' ');
         xygoto(26,21);
         write([addr(sb_out_ch)],o_trk,' ');
       until (o_trk < o_trk_num);

       repeat
         xygoto(37,21);
         i:=get_str(str,delimiter);
         o_sec:=get_num(str,' ');
         xygoto(37,21);
         write([addr(sb_out_ch)],o_sec,'    ');sb_clr_line;
       until (o_sec <= o_sec_num) and (o_sec > 0);

       in_d_rset;  out_d_set;               { parm  in->p,  o->in  }
       slip;
       put_buff( buff[0],noerr );
       if (not noerr) then ioerror(put_disk);
       if flg_85 then get_buff( buff[0],noerr ); { get after put }
       if (not noerr) then ioerror(put_disk);
       in_d_set;                            { parm  p->in }

       count_up(in_trk,in_sec,in_sec_num);
       if in_trk >= in_trk_num then begin
                                    in_trk:=in_trk_num-1;
                                    in_sec:=in_sec_num
                               end;
     end;

  'C': prnt_at(21,1,'Canceled...');

  end;
end;

MODEND.
