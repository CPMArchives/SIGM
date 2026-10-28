{  Small editor                            }
{     by K.Nakazato  Ver. 1.00 10-Feb-1984 }
{                         1.12  2-Jun-1984 }

const
    maxtext   =$7FFF;
    newline   =#$0D;
    mark      =#$87;
    startblock=#$E7;
    endblock  =#$E4;
type
    linetype=string[30];
    frtype=(nosym,findsym,replacesym);
var
    vram   :integer absolute $EDD0;
    vram1  :integer absolute $EDD2;
    ptop   :integer absolute $EDD4;
    pbotm  :integer absolute $EDD6;
    len    :integer absolute $EDD8;
    address:integer absolute $EDDA;
    width  :byte    absolute $EDDC;

    numbuf :byte                  absolute $EDE0;
    sbuffer:string[80]            absolute $EDE0;
    buffer :array [1..80] of char absolute $EDE1;

    insert:boolean;
    r:char;
    x,y,i,slength,halflength:byte;
    startaddress,endaddress,n:integer;
    textbuf:array [0..maxtext] of char;
    filename,line1,line2:linetype;
    wordset :set of char;
    vramaddr:array [0..24] of integer;
    fr:frtype;

{$I SED1.INC}
{$I SED2.INC}
{$I SED3.INC}
{$I SED4.INC}
{$I SED5.INC}
{$I SED6.INC}

begin
  wordset:=['0'..'9','A'..'Z','a'..'z'];
  slength:=23; width:=80; halflength:=slength div 2; fr:=nosym;
  crtinit; setvramaddr; settext; dispinsert; newscreen;
  repeat
    checkbuf; pline(y); numbuf:=width;
    gotoxy(x,y+1); read(kbd,r);
    case chr(ord(r)+ord('@')) of
      'G':deletechar;
      'S','H':if x>1 then x:=x-1;
      'V':begin insert:=not insert; dispinsert end;
      'I':begin x:=8*((x-1) div 8)+9; if x>width then x:=width end;
      'D':if x<width then x:=x+1;
      'T':begin
            setnumbuf;
            if x<=numbuf then deleteword
            else begin connectline; newscreen end
          end;
      'N':begin replaceline(x,0,newline); i:=getline(0,1); newscreen end;
      'R':begin i:=getline(0,slength); newscreen end;
      'C':begin i:=getline(slength,0); newscreen end;
      'L':begin
            if fr=findsym then find1(n)
            else if fr=replacesym then replace1(n);
            newscreen
          end;
      'X':linedown;
      '^':begin x:=1; y:=getline(1,y) end;
      'E':lineup;
      'M':begin linedown; mostleft end;
      'B':begin mostleft; pushbottom; numbuf:=0; rolldown(y,slength) end;
      'Y':begin
            rollup(y,slength); popbottom;
            pline(getline(slength,y)); y:=getline(y,slength)
          end;
      'A':wordleft;
      'F':wordright;
      'Z':screenup;
      'W':screendown;
      #$BF:if x>1 then begin x:=x-1; deletechar end;
      'Q':case getnextc('Q') of
            'Y':numbuf:=x-1;
            'S':mostleft;
            'D':mostright;
            'R':begin x:=1; y:=1; texttop; newscreen end;
            'C':begin y:=halflength; textbottom; x:=numbuf; newscreen end;
            'F':begin find; newscreen; dispinsert end;
            'A':begin replace; newscreen; dispinsert end;
          else;
          end;
      'K':case getnextc('K') of
            'B':insertchar(startblock);
            'K':insertchar(endblock);
            'W':begin writeblock; dispinsert end;
            'D':begin outtext; newscreen; dispinsert end;
            'C':begin cmblock(true); newscreen end;
            'V':begin cmblock(false); newscreen end;
            'Y':begin eraseblock; newscreen end;
            'R':begin readblock; newscreen; dispinsert end;
            'X':begin erasemark; newscreen end;
          else;
          end;
    else
      if r>=' ' then
        begin
          if insert then insertchar(r) else buffer[x]:=r;
          if x<width then x:=x+1
        end
    end;
until false
end.
