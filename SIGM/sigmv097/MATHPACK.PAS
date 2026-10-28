{ for future debugging efforts }{$e+}
PROGRAM mathpack;

CONST  dpmax=6; {upper limit controled by carry in simm}
       digmax=dpmax*2;

TYPE  flt = RECORD
            exp:integer; {exp=exponent*2 (+1 if neg mant.)}
            dp : ARRAY [1..dpmax] OF 0..99
          END;
      $string255= STRING 255;
      $string0  = STRING 0;
      byte= 0..255; {short integer}

VAR   m,n: integer;
      i,j,k: byte;
      u,v,w: flt;
      i$,o$: STRING 127;
      error$: $string255;
message$: STRING 40; 
FUNCTION length (x: $string255):integer;external;
FUNCTION index (x,y: $string255):integer;external;
PROCEDURE setlength (VAR x: $string0; y:integer);external;

{it is intended that parts of this program would become}
{included files [or externals] for pascalZ programs}
{requiring number formats more powerful than real or}
{fixed. division is slow for large number of digits}



PROCEDURE errortrap (errnum: integer;message$: $string255);

{error recovery or unrecoverable error exit module}

VAR  u,v: integer;

BEGIN
writeln ('ERROR TRAP FUNCTION');
writeln ( message$ );
writeln ( error$ );
writeln; 
CASE errnum OF
     0:BEGIN
       writeln ('PROGRAM CANNOT RECOVER!');
       u:=2;
       v:=u-2;
       u:=u DIV v
       END;
     1:writeln ('no action taken');
     2:writeln ('maximum value returned');
     3:writeln ('zero value returned');
     4:writeln ('null string returned');
     5:writeln ('blank char returned');
     ELSE:BEGIN
          writeln ('undefined error number = ',errnum );
          errortrap (0,'undefined error handling')
          END {else}
   END; {case}
END; {errortrap}

{returns 0 for positive and 1 for negative}
FUNCTION signdig (u:flt):integer;

BEGIN
signdig:=(abs(u.exp))MOD 2;
END; {signdig}

{returns base 10 exponent of type flt}
FUNCTION expvalue (u:flt):integer;

VAR  i:integer;

BEGIN
IF ODD(u.exp)
THEN i:=(u.exp-1) DIV 2
ELSE i:=u.exp DIV 2;
expvalue :=i
END; {expvalue}

{integer to flt conversion and intitalization}
PROCEDURE setF (n: integer; VAR u:flt);

VAR i: byte;
    D: ARRAY [1..5] OF 0..9;

BEGIN
u.exp:=0;
FOR i:=1 TO dpmax DO
     u.dp[i]:=0;
IF NOT (n=0)
THEN BEGIN
     IF n<0
     THEN u.exp:=1;
     n:=abs(n);
     D[1]:=n DIV 10000;
     D[2]:=n MOD 10000 DIV 1000;
     D[3]:=n MOD 1000 DIV 100;
     D[4]:=n MOD 100 DIV 10;
     D[5]:=n MOD 10;
     IF D[1]=0
     THEN IF D[2]=0
          THEN IF D[3]=0
               THEN IF D[4]=0
                    THEN BEGIN
                         u.dp[1]:=D[5]*10
                         END
                    ELSE BEGIN
                         u.dp[1]:=D[4]*10+D[5];
                         u.exp:=u.exp+2
                         END
               ELSE BEGIN
                    u.dp[1]:= D[3]*10+D[4];
                    u.dp[2]:= D[5]*10;
                    u.exp:=u.exp+4
                    END
          ELSE BEGIN
               u.dp[1]:=D[2]*10+D[3];
               u.dp[2]:=D[4]*10+D[5];
               u.exp:=u.exp+6
               END
     ELSE BEGIN
          u.dp[1]:=D[1]*10+D[2];
          u.dp[2]:=D[3]*10+D[4];
          u.dp[3]:=D[5]*10;
          u.exp:=u.exp+8
          END
     END {then}
END; {setF}

{tests digits and not exponent}
FUNCTION ztest (u: flt):boolean;

VAR i: byte;
    value: boolean;

BEGIN
value:= true;
i:= 1;
WHILE value AND (i<=dpmax) DO
     IF NOT (u.dp[i]=0)
     THEN value:=false
     ELSE i:=i+1;
END; {ztest}

{early version of Ftostr used to debug modules}
PROCEDURE dispF (u: flt);

VAR i,j,k: integer;

BEGIN
i:= u.exp MOD 2;
IF ODD(u.exp)
THEN write ('-')
ELSE write (' ');
i:=u.dp[1] DIV 10;
write (i:1);
write ('.');
i:=u.dp[1] MOD 10;
write (i:1);
FOR i:=2 TO dpmax DO
     BEGIN
     j:=u.dp[i] DIV 10;
     write (j:1);
     j:=u.dp[i] MOD 10;
     write (j:1)
     END;
write ('E');
i:=expvalue(u);
IF i<0
THEN BEGIN
     write ('-');
     i:=abs(i)
     END;
IF i=0
THEN write ('0')
ELSE BEGIN
     IF i>999
     THEN IF i>9999
          THEN write (i:5)
          ELSE write (i:4)
     ELSE IF i>99
          THEN write (i:3)
          ELSE IF i>9
               THEN write (i:2)
               ELSE write (i:1)
     END; {else}
writeln
END; {dispF}

{this test is for algerbraic greater than}
FUNCTION gtest (u,v: flt):boolean;

VAR  i:byte;
     value,decided: boolean;

BEGIN
if ztest(u)
then u.exp:=0;
if ztest(v)
then v.exp:=0;
value:= false;
IF (ODD(u.exp)=ODD(v.exp))
THEN BEGIN
     IF ((u.exp DIV 2)=(v.exp DIV 2))
     THEN BEGIN
          i:=1;
          decided:= false;
          WHILE NOT decided AND (i<=dpmax) DO
               BEGIN
               IF u.dp[i]=v.dp[i]
               THEN i:=i+1
               ELSE BEGIN
                    decided:= true;
                    IF u.dp[i]>v.dp[i]
                    THEN value:=true
                    END
               END {while}
          END {then}
     ELSE IF ((u.exp DIV 2)>(v.exp DIV 2))
          THEN value:= true;
     IF ODD(u.exp)
     THEN value:= NOT(value)
     END
ELSE IF ODD(v.exp)
     THEN value:=true;
gtest:=value
END; {gtest}

{fixes exponent for numbers that might be zero}
procedure zfix( var u:flt);

begin
if ztest(u)
then u.exp:=0
end; {zfix}

{tests sign of mant. }
FUNCTION ntest (u:flt):boolean;

BEGIN
IF ODD(u.exp)
THEN ntest:= true
ELSE ntest:= false
END; {ntest}

{digit shift with exp. correction remains almost the}
{same number except last digit is lost}
PROCEDURE sr1 (VAR u:flt);

VAR  i: byte;

BEGIN
FOR i:=dpmax DOWNTO 2 DO
     u.dp[i]:=u.dp[i] DIV 10+((u.dp[i-1] MOD 10)*10);
u.dp[1]:=u.dp[1] DIV 10;
u.exp:=u.exp+2
END; {sr1}

{this time first digit is lost}
PROCEDURE sl1 (VAR u:flt);

VAR  i:byte;

BEGIN
FOR i:=1 TO dpmax-1 DO
     u.dp[i]:=u.dp[i] MOD 10 *10+(u.dp[i+1] DIV 10);
u.dp[dpmax]:= u.dp[dpmax] MOD 10 *10;
u.exp:=u.exp-2
END; {sl1}

{sr1,sl1,sle and sre are used by shift}

PROCEDURE sle (n: integer; VAR u: flt);

VAR  i: byte;

BEGIN
n:=abs(n) DIV 2;
FOR i:=1 TO dpmax DO
     IF (i+n)>dpmax
     THEN u.dp[i]:=0
     ELSE U.dp[i]:=u.dp[i+n];
u.exp:=u.exp-(4*n)
END; {sl2n}

PROCEDURE sre (n: integer; VAR u: flt);

VAR  i:byte;

BEGIN
n:=n DIV 2;
FOR i:= dpmax DOWNTO 1 DO
     IF (i-n)<1
     THEN u.dp[i]:=0
     ELSE u.dp[i]:=u.dp[i-n];
u.exp:=u.exp+(4*n)
END; {sre}

{handels shifts of flt numbers }
{positive n is to the right}
PROCEDURE shift (n: integer; VAR u: flt);

BEGIN
IF NOT (n=0)
THEN IF n>(digmax-1)
     THEN setF (0,u)
     ELSE IF n>(0-digmax)
          THEN IF n<0
               THEN IF n=(-1)
                    THEN sl1(u)
                    ELSE IF ODD(n)
                         THEN BEGIN
                              sl1(u);
                              n:=n+1;
                              sle(n,u)
                              END
                         ELSE sle(n,u)
               ELSE IF n=1
                    THEN sr1(u)
                    ELSE IF ODD(n)
                         THEN BEGIN
                              sr1(u);
                              n:=n-1;
                              sre(n,u)
                              END
                         ELSE sre(n,u)
          ELSE setF(0,u);
END; {shift}

{chops of digits to left of decimal point}
FUNCTION ipart (u:flt):flt;

VAR  n:byte;
     v:flt;

BEGIN
IF u.exp>=digmax
THEN v:=u
ELSE  IF u.exp<0
      THEN setf(0,v)
      ELSE BEGIN
           n:=digmax-1-(u.exp DIV 2);
           v:=u;
           shift(n,v);
           n:=0-n;
           shift (n,v);
           END;
ipart:=v
END; {ipart}

{prevents zeros from being the first digit}
PROCEDURE slar (VAR u: flt);

VAR  i:byte;
     notdone: boolean;
     n: integer;

BEGIN
n:=0;
i:=1;
notdone:=true;
WHILE notdone AND (i-1<dpmax) DO
     IF u.dp[i]=0
     THEN BEGIN
          n:=n+2;
          i:=i+1
          END
     ELSE BEGIN
          notdone:=false;
          IF u.dp[i]<10
          THEN n:=n+1
          END;
n:=0-n;
shift (n,u)
END; {slar}

{chops off digits to left of decimal point}
FUNCTION fpart (u:flt):flt;

VAR  n:integer;
     v:flt;

BEGIN
IF u.exp>=digmax
THEN setF (0,v)
ELSE BEGIN
     v:=u;
     IF u.exp>(0-1)
     THEN BEGIN
          n:=0-1-(u.exp DIV 2);
          shift (n,v)
          END
     END {else}
END; {fpart}


{makes positive flt's negative and vice versa}
PROCEDURE chsF (VAR u:flt);

BEGIN
IF ODD(u.exp)
     THEN u.exp:=u.exp-1
     ELSE u.exp:=u.exp+1;
END; {chsF}

{returns positive version of number}
FUNCTION absF (u:flt):flt;

VAR v:flt;

BEGIN
v:=u;
v.exp:=expvalue(u)*2;
absF:=v
END; {absF}

{used by addf and subf depending on signs involved}
PROCEDURE sima (u:flt; VAR v:flt);

VAR  index        :byte;
     sum,carry    :integer;
     shiftsize    :integer;
     exchange     :flt;

BEGIN
IF gtest (u,v)
THEN BEGIN
     exchange:=u;
     u:=v;
     v:=exchange
     END;
shiftsize:=(v.exp-u.exp) DIV 2;
shift (shiftsize,u);
carry:=0;
FOR index := dpmax DOWNTO 1 DO
     BEGIN
     sum:=u.dp[index] + v.dp[index]+carry;
     carry:=sum DIV 100;
     v.dp[index]:=sum MOD 100;
     END; {for}
IF carry>0
THEN BEGIN
     shift(1,v);
     v.dp[1]:=v.dp[1]+(carry*10)
     END
END; {sima}

{used by addf and subf according to signs}
PROCEDURE sims (u:flt; VAR v:flt);

VAR  index      :byte;
     shiftsize  :integer;

PROCEDURE borrow;

VAR i        :byte;
    notdone  :boolean;

BEGIN
i:=index-1;
notdone:=true;
WHILE notdone DO
     BEGIN
     IF v.dp[i]=0
     THEN BEGIN
          v.dp[i]:=99;
          i:=i-1
          END
     ELSE BEGIN
          v.dp[i]:=v.dp[i]-1;
          notdone:=false
          END
     END
END; {borrow}

BEGIN
shiftsize := (v.exp-u.exp) DIV 2;
shift(shiftsize,u);
FOR index:=dpmax DOWNTO 1 DO
     IF v.dp[index]>=u.dp[index]
     THEN v.dp[index]:=v.dp[index]-u.dp[index]
     ELSE BEGIN
          borrow;
          v.dp[index]:=v.dp[index]+100-u.dp[index]
          END;
IF ztest(v)
THEN v.exp:=0
ELSE slar(v);
END; {sims}

{used by mulf and divf stands for simple mult. }
PROCEDURE simm (u:flt; VAR v:flt);

VAR  w        :flt;
     result   :integer;
     carry    :integer;
     h,i,k    :byte;

BEGIN
result:=0;
FOR h:= dpmax DOWNTO 1 DO
     BEGIN
     carry:=0;
     FOR i:=1 TO h DO
          BEGIN
          k:=h+1-i;
          result:=u.dp[i]*v.dp[k]+result;
          carry:= carry+(result DIV 100);
          result:= result MOD 100
          END;
     w.dp[h]:=result;
     result:=carry
     END;
w.exp:=u.exp+v.exp-2;
WHILE result >0 DO
     BEGIN
     carry:=result DIV 10;
     result:=result MOD 10;
     shift(1,w);
     w.dp[1]:=w.dp[1]+(result*10);
     result :=carry
     END;
v:=w
END; {simm}

{returns algebraic sum}
FUNCTION addF(u,v:flt):flt;

VAR  ucopy,vcopy :flt;

BEGIN
ucopy:=u;
vcopy:=v;
IF (ODD(ucopy.exp)=ODD(vcopy.exp))
THEN IF ODD(ucopy.exp)
     THEN BEGIN
          ucopy.exp:=ucopy.exp-1;
          vcopy.exp:=vcopy.exp-1;
          sima(ucopy,vcopy);
          vcopy.exp:=vcopy.exp+1
          END
     ELSE sima(ucopy,vcopy)
ELSE IF ODD(ucopy.exp)
     THEN BEGIN
          ucopy.exp:=ucopy.exp-1;
          IF gtest(vcopy,ucopy)
          THEN sims(ucopy,vcopy)
          ELSE BEGIN
               sims(vcopy,ucopy);
               vcopy:=ucopy;
               vcopy.exp:=vcopy.exp+1
               END
          END
     ELSE BEGIN
          vcopy.exp:=vcopy.exp-1;
          IF gtest(vcopy,ucopy)
          THEN BEGIN
               sims(ucopy,vcopy);
               vcopy.exp:=vcopy.exp +1
               END
          ELSE BEGIN
               sims(vcopy,ucopy);
               vcopy:=ucopy
               END
          END; {else}
addF:=vcopy
END; {addF}

{returns (v minus u) }
FUNCTION subF (u,v:flt):flt;

VAR w:flt;

BEGIN
chsF(u);
w:=addF(u,v);
subF:=w
END; {subF}

{tests for equality including sign and exponents}
FUNCTION etest (u,v:flt):boolean;

VAR  value: boolean;
     index:byte;

BEGIN
value:=true;
IF NOT(u.exp=v.exp)
THEN value:=false;
index:=1;
WHILE value AND (index<=dpmax) DO
     IF u.dp[index]=v.dp[index]
     THEN index:=index+1
     ELSE value:=false;
etest:=value
END; {etest}

{returns product}
FUNCTION mulF (u,v:flt):flt;

VAR  x,y:flt;

BEGIN
x:=u;
y:=v;
IF (ODD(x.exp)=ODD(y.exp))
THEN BEGIN
     x:=absF(x);
     y:=absF(y);
     simm(x,y);
     END
ELSE BEGIN
     x:=absF(x);
     Y:=absF(y);
     simm(x,y);
     y.exp:=y.exp+1
     END;
mulF:=y
END; {mulF}

{division by interger n<163 will be used for trig functions}
PROCEDURE diviF (n:integer; VAR u:flt);

VAR  rem,result,index                :integer;

BEGIN
IF n=0
THEN BEGIN
     errortrap(2,'division by integer zero');
     u.exp:=(u.exp MOD 2)+16000;
     FOR index:=1 TO dpmax
     DO   u.dp[index]:=99;
     END
ELSE BEGIN
     IF n<0
     THEN BEGIN
          chsF(u);
          n:=abs(n)
          END;
     rem:=0;
     FOR index:=1 TO dpmax
     DO   BEGIN
          result:=rem*100+u.dp[index];
          rem:=result MOD n;
          result:=result DIV n;
          IF result >100
          THEN u.dp[index-1]:=(result DIV 100)+u.dp[index-1];
          u.dp[index]:=result MOD 100
          END; {for}
     IF ztest(u)
     THEN u.exp:=0
     ELSE slar(u)
     END; {else}
END; {diviF}

{equal except maybe the last digit}
{note 1.00000... isn't semiequal to .999999...}
FUNCTION semiequal (u,v:flt):boolean;

VAR  test : boolean;         index : byte;

BEGIN
IF u.exp = v.exp
THEN test := true
ELSE test := false;
index := 1;
WHILE test AND (index < dpmax)
DO   BEGIN
     IF u.dp[index] = v.dp[index]
     THEN index := index + 1
     ELSE test := false
     END;
semiequal := test
END; {semiequal}

{used by division retruns 1/u }
FUNCTION recipF (u:flt):flt;

VAR  one      :flt;
     two      :flt;
     appro    :flt;
     temp     :flt;
     n,e,sign :integer;
     temreal  :real;

BEGIN
IF ztest (u)
THEN BEGIN
     appro.exp:=u.exp MOD 2+16000;
     FOR e:=1 TO dpmax DO
          appro.dp[e]:=99;
     ERRORTRAP (2,'Divison by zero')
     END {then}
ELSE BEGIN
     e:=expvalue(u);
     IF ODD(u.exp)
     THEN sign:=1
     ELSE sign:=0;
     setF(1,one);
     IF etest (u,one)
     THEN BEGIN
          appro:=u;
          appro.exp:=(0-e)*2+(sign)
          END
     ELSE BEGIN {inside}
          temreal:=u.dp[1]+(u.dp[2]/100);
          n:=ROUND(100000.0/temreal); {sets good approx}
          setF(n,appro);
          u.exp:=0;
          setF(2,two);
          appro.exp:=-2;
          FOR n:=1 TO ((dpmax +1)DIV 2)
          DO   BEGIN
               temp:=appro;
               simm(u,temp);
               chsF(temp);
               temp:=addF(two,temp);
               simm(temp,appro);
               END; {while}
          appro.exp:=(0-1-e)*2+sign
          END;
     END;
recipF:=appro
END; {recipF}


{returns (v divided by u) }
FUNCTION divF (u,v:flt):flt;

VAR  w:flt;

BEGIN
w:=recipF(u);
divF:=mulf(w,v);
END; {divF}


{square root function for type flt}
FUNCTION sqrtF (u:flt):flt;

VAR  root1,delta  :flt;
     temp         :integer;
     rootval      :real;
     roottest:flt;

PROCEDURE betterroot;

BEGIN
roottest:=root1;
delta :=subF(mulF(root1,root1),u);
diviF(2,delta);
root1:=addF(divF(root1,delta),root1);
END; {betterroot}

BEGIN
IF ntest(u)
THEN BEGIN
     errortrap (1,'positive root of neg number');
     u.exp:=u.exp-1
     END;
temp:=u.exp DIV 2;
IF ODD(temp)
THEN temp:=u.dp[1]*100+u.dp[2]
ELSE temp:=u.dp[1]*10+(u.dp[2] DIV 10);
rootval:=sqrt(temp)*100;
temp:=round(rootval);
setF(temp,root1);
root1.exp:=(u.exp DIV 4) * 2;
REPEAT
     betterroot
UNTIL semiequal(root1,roottest);
sqrtF:=root1
END; {sqrtF}

{converts any string to a flt number default is}
{0.0e0 if there is no digits present}
PROCEDURE strtoF (num$ : $string255; VAR u :flt);

VAR  nextchar                   :char;
     digitflag,expflag          :boolean;
     pastpoint,negexp           :boolean;
     digpos,strpos              :byte;
     value                      :1..9;
     afterE                     :integer; {entered part of exponent}
     i                          :integer;

PROCEDURE processchar;

BEGIN
nextchar:=num$[strpos];
CASE nextchar OF
     'E','e'  :IF digitflag
               THEN expflag:=true;
     '-'  :IF expflag
           THEN negexp:=true
           ELSE u.exp :=(u.exp DIV 2)*2 +1;
     '0'  :IF expflag
           THEN BEGIN
                if afterE<1630
                then afterE:=afterE*10
                END
           ELSE if pastpoint
                then if digitflag
                     then digpos:=digpos+1
                     else u.exp:=u.exp-2 {allows entry of .00 ... 001}
                else if digitflag
                     then begin
                          digpos:=digpos+1;
                          u.exp:=u.exp+2
                          end;
     '.'  :BEGIN
           pastpoint := true;
           END;
     '1','2','3','4','5','6','7','8','9'
          :BEGIN
           digitflag := true;
           IF expflag
           THEN BEGIN
                value:=ord(nextchar)-ord('0');
                if afterE<1630
                then afterE:=afterE*10+value
                END
           ELSE BEGIN
                IF digpos < digmax
                THEN BEGIN
                     value:=ord(nextchar)-ord('0');
                     i:=(digpos +1) DIV 2;
                     IF ODD(digpos)
                     THEN u.dp[i]:=value*10
                     ELSE u.dp[i]:=u.dp[i]+value;
                     digpos:=digpos+1;
                     end; {then}
                IF NOT(pastpoint)
                THEN u.exp:=u.exp+2;
                END
           END; {digits}
     END; {case}
END; {processchar}

BEGIN
setF(0,u);
u.exp:=-2;
afterE:=0;
digitflag :=false;
expflag:=false;
pastpoint:=false;
negexp:=false;
digpos:=1;
FOR strpos := 1 TO length(num$)
DO   processchar;
IF negexp
then u.exp:=u.exp-(2*afterE)
else u.exp:=u.exp+(2*afterE)
END; {strtoF}

{$iftostr.txt }

{the program is just a short demo}

BEGIN
error$:='MATHPACK';
writeln (error$);
setlength(error$,0);
append(error$,'fltmath');
m:=1739;
n:=-831;
setF (8246,u);
setF (m,w);
setF (n,v);
dispF (u);
dispF (w);
dispF (v);
shift(-1,v);
dispF (v);
w:=addF(u,w);
dispF(w);
w:=subF(u,w);
dispF(w);
w:=mulF(u,w);
dispF(w);
diviF(29,v);
dispF(v);
v:=recipF(w);
dispF(v);
writeln;
v:=divF(u,w);
dispF(v);
writeln;
dispF(w);
v:=sqrtF(w);
dispF(v);
     i$:='9.75312468E-14';
     strtoF(i$,u);
     strtoF('-3.161',v);
     FOR m:=1 to 60
     DO   BEGIN
          u:=mulF(v,u);
          dispF(u); {for comparison purposes}
          Ftostr(u,12,'6');
          writeln;
          writeln;
          END;
repeat
     writeln;
writeln('Enter stop to stop loop');
     write('Enter number to be converted : ');
     readln(i$);
     strtoF(i$,w);
     Ftostr(w,10,'4')
until i$='stop';
END. {mathpack.pas}
