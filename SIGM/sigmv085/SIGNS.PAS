{$E+}
program signs;
{kilobaud, Aug '78, page 90
program originally in North Star BASIC by Joseph J. Roehrig
numbers in brackets indicate line numbers in original program
}
LABEL
  1;
TYPE
  $str8 = string 8;
VAR
  fout : text;
  V : array[0..31] of integer;	{patterns}
  L$ : array[1..27] of char;	{top of array equ number of chars}
  L  : array[1..27,1..7] of integer;	{dimensions of each letter}
  Z  : array[1..5] of integer;
  D1$: array[1..7]of char;
  D$ : array[1..7]of char;	{top of array equ total number of letters}
  C$ : char;
  a,
  b,
  c,
  d,
  f,
  g,
  q,
  e : integer;

function ucase(ch:char):char;
{This function filters all non-alphabetical characters, replacing
them with blanks.  It also converts all lower case letters to
upper case.}
begin
  if ch in ['A'..'Z'] then ucase := ch	{accept uppers}
  else
    if ch in ['a'..'z'] then	{translate to upper case}
      ucase := chr(ord(ch) - 32)
      else ucase := ' '		{filter illegal characters}
end;	{ucase}

procedure setarray;
{This procedure fills the array L with the font values from
"font.dat".  It takes the place of a series of DATA statements
in the original BASIC program.}
var
  letter : $str8;
  a,b    : integer;
  fin    : file of $str8;
  {L     : array [1..27,1..7] of integer - global}
begin
  reset('font.dat',fin);	{font.dat contains array values}
  for a := 1 to 27 do		{70, set loop value to tot # chars formed}
    begin
    readln(fin,letter);	{'letter' contains 8 char; 1st 7 are significant}
    for b := 1 to 7 do	{8th is "for info" label}
      begin
      L[a,b] := ord(letter[b])-64;	{80}
      end;	{for b}
    end;	{for a}
end;	{procedure setarray}

begin	{main program}
  D1$ := '       ';		{7 blanks}
  L$  := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ ';	{15}
  z[1] := 10000; z[2] := 1000; z[3] := 100; z[4] := 10; z[5] := 1;
  for a := 1 to 7 do		{40	7 is the number of lines of ltrs}
    begin
    D$[a] := ' ';		{fill array D$ with blanks}
    end;
  v[0]:=0; v[1]:=1; 		{50	read binary number line}
  v[2]:=10; v[3]:=11; v[4]:=100; v[5]:=101; v[6]:=110; v[7]:=111;
  v[8]:=1000; v[9]:=1001; v[10]:= 1010; v[11]:=1011; v[12]:= 1100;
  v[13]:=1101; v[14]:=1110; v[15]:=1111;
  for a := 16 to 31 do v[a] := 10000+v[a-16];	{60}
  {there has to be a better way to fill this array, when you
  find it, let me know}
  setarray;		{70,80}
  rewrite('lst:',fout);
  writeln('Instructions:  This program will accept upper case');
  writeln('characters and blanks. (Lower case letters will translate)');
  writeln('Enter a period and a carriage return to end.');
  writeln;
    while D1$[1] <> '.' do
    begin	{while}
    Writeln('Input line:');
    writeln('_______');
    readln(D1$);
      if D1$[1] = '.' then goto 1;	{sorry, had to GOTO}
    for e := 1 to 7 do
    D$[e] := ucase(D1$[e]);
{98 "get paper ready & enter <cr>}
    for d := 1 to 7 do		{105}
    begin
      for b := 1 to 7 do	{110}
      begin
      c := b;			{120}
      C$ := D$[c];		{122}
      c := ord(C$);
      c := c-64;		{124}
      if 0 > c then c := 27;
      f := L[c,d];		{135}
      f := v[f];		{136}
      q := c;			{137}
      for e := 1 to 5 do	{150}
        begin
        g := trunc(f div z[e]);	{160}
        f := f-(g*z[e]);	{165}
        if g = 1 then write(fout,L$[q],L$[q])	{170}
                 else write(fout,'  ');
        end;	{for e}
      write(fout,'  ');		{200, number of spaces between letters}
      end;	{for b}
    writeln(fout,' ');		{220, ends each line of print}
    end;	{for d}
  writeln(fout); writeln(fout);	{230, 2 blank lines between each printed string}
  1:
  end;	{while}
end.
í{ä(:m¯¿p