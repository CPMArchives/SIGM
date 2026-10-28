{ Pascal/Z pretty printer }

{ Author:  Peter Grogono }

{ This program is based on a Pascal pretty-printer written by Ledgard,
  Hueras, and Singer.  See SIGPLAN Notices, Vol. 12, No. 7, July 1977,
  pages 101-105.  }

{ This version of PP must be compiled by Pascal/Z V4.0 or later.
  It will run correctly under V3.0 only if 'byte' fields in records
  are changed to 'integer'.  }

{$M- inhibit integer multiply/divide check }
{$R- inhibit range/bound check - see procedure HASH }
{$S- inhibit stack overflow check }
{$U- inhibit range/bound check on parameters }

program pp;

const

{$ICONSTS.PAS }
maxsymbolsize = 80;
maxstacksize = 100;
maxkeylength = 9;     { The longest keyword is PROCEDURE }
maxlinesize = 90;     { Maximum length of output line }
indent = 2;           { Indentation step size for structured statements }
extin = '.PAS';
extout = '.PPP';
casediff = 32;        { ord('a') - ord('A') }

type

{$ITYPES.PAS }

keysymbol = 
{ keywords }
(endsym,beginsym,ifsym,thensym,elsesym,procsym,varsym,ofsym,
whilesym,dosym,casesym,withsym,forsym,repeatsym,untilsym,
funcsym,labelsym,constsym,typesym,recordsym,stringsym,progsym,
andsym,arrsym,divsym,downsym,filesym,gotosym,insym,modsym,
notsym,nilsym,orsym,setsym,tosym,casevarsym,
{ other symbols }
becomes,opencomment,closecomment,semicolon,colon,equals,
openparen,closeparen,period,endoffile,othersym);

options = (crsupp,crbefore,blinbefore,
dindonkey,dindent,spbef,
spaft,gobsym,inbytab,crafter);

optionset = set of options;
keysymset = set of keysymbol;

tableentry = record
selected : optionset;
dindsym : keysymset;
terminators : keysymset
end;

tableptr = ^ tableentry;
optiontable = array [keysymbol] of tableptr;
key = array [1..maxkeylength] of char;
keywordtable = array [endsym..tosym] of key;
specialchar = array [1..2] of char;
dblcharset = set of endsym..othersym;
dblchartable = array [becomes..opencomment] of specialchar;
sglchartable = array [opencomment..period] of char;
token = array [1..maxsymbolsize] of char;

symbol = record
name : keysymbol;
value : token;
iskeyword : boolean;
length, spacesbefore, crsbefore : byte
end;

symbolinfo = ^ symbol;
charname = (letter,digit,space,quote,endofline,
filemark,otherchar);

charinfo = record
name : charname;
value : char
end;

stackentry = record
indentsymbol : keysymbol;
prevmargin : byte
end;

symbolstack = array [1..maxstacksize] of stackentry;

hashentry = record
keyword : key;
symtype : keysymbol
end;

var

infilename,outfilename : string 20;
infile,outfile : text;
recordseen : boolean;
currchar,nextchar : charinfo;
currsym,nextsym : symbolinfo;
crpending : boolean;
option : optiontable;
sets : tableptr;
keyword : keywordtable;
dblch : dblcharset;
dblchar : dblchartable;
sglchar : sglchartable;
stack : symbolstack;
top,startpos,currlinepos,currmargin,
inlines,outlines : integer;
hashtable : array [byte] of hashentry;

{$IPROCS.PAS }
{$IGETFILES.PAS }

{ Convert letters to upper case }

function upper (ch : char) : char;

begin
if ch in ['a'..'z'] then upper := chr(ord(ch) - casediff)
else upper := ch
end; { upper }

{ Read the next character and classify it }

procedure getchar;

var
ch : char;

begin
currchar := nextchar;
with nextchar do
if eof(infile) then
begin name := filemark; value := blank end
else
if eoln(infile) then
begin name := endofline; value := blank;
inlines := inlines + 1; readln(infile) end
else
begin
read(infile,ch);
value := ch;
if ch in ['a'..'z','A'..'Z','_'] then name := letter
else
if ch in ['0'..'9'] then name := digit
else
if ch = '''' then name := quote
else
if (ch = blank) or (ch = chr(tab)) then name := space
else name := otherchar
end
end; { getchar }

{ Store a character in the current symbol }

procedure storenextchar(var length : byte; var value : token);

begin
getchar;
if length < maxsymbolsize then
begin length := length + 1; value[length] := currchar.value end;
end; { storenextchar }

{ Count the spaces between symbols }

procedure skipblanks (var spacesbefore,crsbefore : byte);

begin
spacesbefore := 0;
crsbefore := 0;
while nextchar.name in [space,endofline] do
begin
getchar;
case currchar.name of
space : spacesbefore := spacesbefore + 1;
endofline : begin
crsbefore := crsbefore + 1;
spacesbefore := 0
end
end
end
end; { skipspaces }

{ Process comments using either brace or parenthesis notation }

procedure getcomment (sym : symbolinfo);

begin
sym^.name := opencomment;
while not (((currchar.value = '*') and (nextchar.value = ')'))
or (currchar.value = '}')
or (nextchar.name = endofline)
or (nextchar.name = filemark)) do
storenextchar(sym^.length,sym^.value);
if (currchar.value = '*') and (nextchar.value = ')') 
then
begin
storenextchar(sym^.length,sym^.value); sym^.name := closecomment
end;
if currchar.value = '}' 
then sym^.name := closecomment
end; { getcommment }

{ Hashing function for identifiers.  The formula gives a unique value
  in the range 0..255 for each Pascal/Z keyword.  Note that range and
  overflow checking must be turned off for this function even if they
  are enabled for the rest of the program.  }

function hash (symbol : key; length : byte) : byte;

begin
hash := (ord(symbol[1]) * 5 + ord(symbol[length])) * 5 + length
end; { hash }

{ Classify an identifier.  We are only interested
  in it if it is a keyword, so we use the hash table. }

procedure classid (value : token; length : byte;
var idtype : keysymbol; var iskeyword : boolean);

var
keyvalue : key;
i, tabent : byte;

begin
if length > maxkeylength then 
begin idtype := othersym; iskeyword := false end
else
begin
for i := 1 to length do keyvalue[i] := upper(value[i]);
for i := length + 1 to maxkeylength do keyvalue[i] := blank;
tabent := hash(keyvalue,length);
if keyvalue = hashtable[tabent].keyword then
begin idtype := hashtable[tabent].symtype; iskeyword := true end
else
begin idtype := othersym; iskeyword := false end
end
end; { classid }

{ Read an identifier and classify it }

procedure getidentifier (sym : symbolinfo);

begin
while nextchar.name in [letter,digit] do
storenextchar(sym^.length,sym^.value);
classid(sym^.value,sym^.length,sym^.name,sym^.iskeyword);
if sym^.name in [recordsym,casesym,endsym]
then case sym^.name of
recordsym : recordseen := true;
casesym : if recordseen then sym^.name := casevarsym;
endsym : recordseen := false
end
end; { getidentifier }

{ Read a number and store it as a string }

procedure getnumber (sym : symbolinfo);

begin
while nextchar.name = digit do
storenextchar(sym^.length,sym^.value);
sym^.name := othersym
end; { getnumber }

{ Read a quoted string }

procedure getcharliteral (sym : symbolinfo);

begin
while nextchar.name = quote do
begin
storenextchar(sym^.length,sym^.value);
while not (nextchar.name in [quote,endofline,filemark]) do
storenextchar(sym^.length,sym^.value);
if nextchar.name = quote
then storenextchar(sym^.length,sym^.value)
end;
sym^.name := othersym
end; { getcharliteral }

{ Classify a character pair }

function chartype : keysymbol;

var
nexttwochars : specialchar;
hit : boolean;
thischar : keysymbol;

begin
nexttwochars[1] := currchar.value;
nexttwochars[2] := nextchar.value;
thischar := becomes;
hit := false;
while not (hit or (thischar = closecomment)) do
begin
if nexttwochars = dblchar[thischar]
then hit := true
else thischar := succ(thischar)
end;
if not hit then
begin
thischar := opencomment;
while not (hit or (pred(thischar) = period)) do
begin
if currchar.value = sglchar[thischar]
then hit := true
else thischar := succ(thischar) 
end
end;
if hit then chartype := thischar
else chartype := othersym;
end; { chartype }

{ Read special characters }

procedure getspecialchar (sym : symbolinfo);

begin
storenextchar(sym^.length,sym^.value);
sym^.name := chartype;
if sym^.name in dblch then storenextchar(sym^.length,sym^.value)
end; { getspecialchar }

{ Read a symbol using the appropriate procedure }

procedure getnextsymbol (sym : symbolinfo);

begin
case nextchar.name of
letter : getidentifier(sym);
digit : getnumber(sym);
quote : getcharliteral(sym);
otherchar : begin
getspecialchar(sym);
if sym^.name = opencomment then getcomment(sym)
end;
filemark : sym^.name := endoffile;
else : writeln('Unknown character type: ',ord(nextchar.name))
end
end; { getnextsymbol }

{ Store the next symbol in NEXTSYM }

procedure getsymbol;

var
dummy : symbolinfo;

begin
dummy := currsym;
currsym := nextsym;
nextsym := dummy;
skipblanks(nextsym^.spacesbefore,nextsym^.crsbefore);
nextsym^.length := 0;
nextsym^.iskeyword := false;
if currsym^.name = opencomment
then getcomment(nextsym)
else getnextsymbol(nextsym)
end;

{ Manage stack of indentation symbols and margins }

procedure popstack (var indentsymbol : keysymbol; var prevmargin : byte);

begin
if top > 0 
then
begin
indentsymbol := stack[top].indentsymbol;
prevmargin := stack[top].prevmargin;
top := top - 1
end
else 
begin
indentsymbol := othersym; 
prevmargin := 0
end
end; { popstack }

procedure pushstack (indentsymbol : keysymbol; prevmargin : byte);

begin
top := top + 1;
stack[top].indentsymbol := indentsymbol;
stack[top].prevmargin := prevmargin
end; { pushstack }

procedure writecrs (numberofcrs : byte);

var
i : byte;

begin
if numberofcrs > 0 then
begin
for i := 1 to numberofcrs do writeln(outfile);
outlines := outlines + numberofcrs;
currlinepos := 0
end
end; { writecrs }

procedure insertcr;

begin
if currsym^.crsbefore = 0
then
begin
writecrs(1); currsym^.spacesbefore := 0
end
end; { insertcr }

procedure insertblankline;

begin
if currsym^.crsbefore = 0
then
begin
if currlinepos = 0
then writecrs(1)
else writecrs(2);
currsym^.spacesbefore := 0
end
else
if currsym^.crsbefore = 1 then
if currlinepos > 0 then writecrs(1)
end; { insertblankline }

{ Move margin left according to stack configuration and current symbol }

procedure lshifton (dindsym : keysymset);

var
indentsymbol : keysymbol;
prevmargin : byte;

begin
if top > 0 then
begin
repeat
popstack(indentsymbol,prevmargin);
if indentsymbol in dindsym
then currmargin := prevmargin
until not (indentsymbol in dindsym) or (top = 0);
if not (indentsymbol in dindsym)
then pushstack(indentsymbol,prevmargin)
end
end; { lshifton }

{ Move margin left according to stack top }

procedure lshift;

var
indentsymbol : keysymbol;
prevmargin : byte;

begin
if top > 0 then
begin
popstack(indentsymbol,prevmargin);
currmargin := prevmargin
end
end; { lshift }

{ Insert space if room on line }

procedure insertspace (var symbol : symbolinfo);

begin
if currlinepos < maxlinesize
then
begin
write(outfile,blank);
currlinepos := currlinepos + 1;
if (symbol^.crsbefore = 0) and (symbol^.spacesbefore > 0)
then symbol^.spacesbefore := symbol^.spacesbefore - 1
end
end; { insertspace }

{ Insert spaces until correct line position reached }

procedure movelinepos (newlinepos : byte);

var
i : byte;

begin
for i := currlinepos + 1 to newlinepos do write(outfile,blank);
currlinepos := newlinepos
end; { movelinepos }

{ Print a symbol converting keywords to upper case }

procedure printsymbol;

var
i : byte;

begin
if currsym^.iskeyword then
for i := 1 to currsym^.length do write(outfile,upper(currsym^.value[i]))
else
for i := 1 to currsym^.length do write(outfile,currsym^.value[i]);
startpos := currlinepos;
currlinepos := currlinepos + currsym^.length
end; { printsymbol }

{ Find position for symbol and then print it }

procedure ppsymbol;

var
newlinepos : byte;

begin
writecrs(currsym^.crsbefore);
if (currlinepos + currsym^.spacesbefore > currmargin)
or (currsym^.name in [opencomment,closecomment])
then newlinepos := currlinepos + currsym^.spacesbefore
else newlinepos := currmargin;
if newlinepos + currsym^.length > maxlinesize
then
begin
writecrs(1);
if currmargin + currsym^.length <= maxlinesize
then newlinepos := currmargin
else
if currsym^.length < maxlinesize
then newlinepos := maxlinesize - currsym^.length
else newlinepos := 0
end;
movelinepos(newlinepos);
printsymbol
end; { ppsymbol }

{ Print symbols which follow a formatting symbol but which do not
  affect layout }

procedure gobble (terminators : keysymset);

begin
if top < maxstacksize 
then pushstack(currsym^.name,currmargin);
currmargin := currlinepos;
while not ((nextsym^.name in terminators)
           or (nextsym^.name = endoffile)) do
begin
getsymbol; ppsymbol
end;
lshift
end; { gobble }

{ Move right, stacking margin positions }

procedure rshift (currsym : keysymbol);

begin
if top < maxstacksize
then pushstack(currsym,currmargin);
if startpos > currmargin
then currmargin := startpos;
currmargin := currmargin + indent
end; { rshift }

{ Initialize everything }

procedure initialize;

var
sym : keysymbol;
ch : char;
pos, len : byte;

begin

{ Get file name and open files }

getfilenames(extin,extout);
writeln('Reading from ',infilename);
writeln('Writing to   ',outfilename);
reset(infilename,infile);
rewrite(outfilename,outfile);

{ Initialize variables and set up control tables }

top := 0;
currlinepos := 0;
currmargin := 0;
inlines := 0;
outlines := 0;

{ Keywords used for formatting }

keyword[progsym]    := 'PROGRAM  ';
keyword[funcsym]    := 'FUNCTION ';
keyword[procsym]    := 'PROCEDURE';
keyword[labelsym]   := 'LABEL    ';
keyword[constsym]   := 'CONST    ';
keyword[typesym]    := 'TYPE     ';
keyword[varsym]     := 'VAR      ';
keyword[beginsym]   := 'BEGIN    ';
keyword[repeatsym]  := 'REPEAT   ';
keyword[recordsym]  := 'RECORD   ';
keyword[casesym]    := 'CASE     ';
keyword[ofsym]      := 'OF       ';
keyword[forsym]     := 'FOR      ';
keyword[whilesym]   := 'WHILE    ';
keyword[withsym]    := 'WITH     ';
keyword[dosym]      := 'DO       ';
keyword[ifsym]      := 'IF       ';
keyword[thensym]    := 'THEN     ';
keyword[elsesym]    := 'ELSE     ';
keyword[endsym]     := 'END      ';
keyword[untilsym]   := 'UNTIL    ';

{ Keywords not used for formatting }

keyword[andsym]     := 'AND      ';
keyword[arrsym]     := 'ARRAY    ';
keyword[divsym]     := 'DIV      ';
keyword[downsym]    := 'DOWNTO   ';
keyword[filesym]    := 'FILE     ';
keyword[gotosym]    := 'GOTO     ';
keyword[insym]      := 'IN       ';
keyword[modsym]     := 'MOD      ';
keyword[notsym]     := 'NOT      ';
keyword[nilsym]     := 'NIL      ';
keyword[orsym]      := 'OR       ';
keyword[setsym]     := 'SET      ';
keyword[tosym]      := 'TO       ';
keyword[stringsym]  := 'STRING   ';

{ Create hash table }

for pos := 0 to maxbyte do
begin
hashtable[pos].keyword := '         ';
hashtable[pos].symtype := othersym
end; { for }
for sym := endsym to tosym do
begin
len := maxkeylength;
while keyword[sym,len] = blank do len := len - 1;
pos := hash(keyword[sym],len);
hashtable[pos].keyword := keyword[sym];
hashtable[pos].symtype := sym
end; { for }

{ Set up other special symbols }

dblch := [becomes,opencomment];

dblchar[becomes] := ':=';
dblchar[opencomment] := '(*';

sglchar[semicolon] := ';';
sglchar[colon]     := ':';
sglchar[equals]    := '=';
sglchar[openparen] := '(';
sglchar[closeparen] := ')';
sglchar[period]    := '.';
sglchar[opencomment] := '{';
sglchar[closecomment] := '}';

{ Set up the sets that control formatting.  If you want PP to insert a
  line break before every statement, include CRBEFORE in the SELECTED
  set of the appropriate keywords (WHILE, IF, REPEAT, etc.).  The
  disadvantage of this is that PP will sometimes put line breaks 
  where you don't want them, e.g. after ':' in CASE statements.  Note
  also that PP does not understand the Pascal/Z use of ELSE as a
  CASE label -- I wish they'd used OTHERWISE like everybody else.  }

for sym := endsym to othersym do
begin
new(option[sym]);
option[sym]^.selected := [];
option[sym]^.dindsym := [];
option[sym]^.terminators := []
end;

option[progsym]^.selected    := [blinbefore,spaft];
option[funcsym]^.selected    := [blinbefore,dindonkey,spaft];
option[funcsym]^.dindsym     := [labelsym,constsym,typesym,varsym]; 
option[procsym]^.selected    := [blinbefore,dindonkey,spaft];
option[procsym]^.dindsym     := [labelsym,constsym,typesym,varsym];
option[labelsym]^.selected   := [blinbefore,spaft,inbytab];
option[constsym]^.selected   := [blinbefore,dindonkey,spaft,inbytab];
option[constsym]^.dindsym    := [labelsym];
option[typesym]^.selected    := [blinbefore,dindonkey,spaft,inbytab];
option[typesym]^.dindsym     := [labelsym,constsym];
option[varsym]^.selected     := [blinbefore,dindonkey,spaft,inbytab];
option[varsym]^.dindsym      := [labelsym,constsym,typesym];
option[beginsym]^.selected   := [dindonkey,inbytab,crafter];
option[beginsym]^.dindsym    := [labelsym,constsym,typesym,varsym];
option[repeatsym]^.selected  := [inbytab,crafter];
option[recordsym]^.selected  := [inbytab,crafter];
option[casesym]^.selected    := [spaft,inbytab,gobsym,crafter];
option[casesym]^.terminators := [ofsym];
option[casevarsym]^.selected := [spaft,inbytab,gobsym,crafter];
option[casevarsym]^.terminators := [ofsym]; 
option[ofsym]^.selected      := [crsupp,spbef];
option[forsym]^.selected     := [spaft,inbytab,gobsym,crafter];
option[forsym]^.terminators  := [dosym];
option[whilesym]^.selected   := [spaft,inbytab,gobsym,crafter];
option[whilesym]^.terminators := [dosym];
option[withsym]^.selected    := [spaft,inbytab,gobsym,crafter];
option[withsym]^.terminators := [dosym];
option[dosym]^.selected      := [crsupp,spbef];
option[ifsym]^.selected      := [spaft,inbytab,gobsym,crafter];
option[ifsym]^.terminators   := [thensym];
option[thensym]^.selected    := [inbytab];
option[elsesym]^.selected    := [crbefore,dindonkey,dindent,inbytab];
option[elsesym]^.dindsym     := [ifsym,elsesym];
option[endsym]^.selected     := [crbefore,dindonkey,dindent,crafter];
option[endsym]^.dindsym      := [ifsym,thensym,elsesym,forsym,whilesym,
withsym,casevarsym,colon,equals];
option[untilsym]^.selected   := [crbefore,dindonkey,dindent,
spaft,gobsym,crafter];
option[untilsym]^.dindsym    := [ifsym,thensym,elsesym,forsym,whilesym,
withsym,colon,equals];
option[untilsym]^.terminators := [endsym,untilsym,elsesym,semicolon];
option[becomes]^.selected    := [spbef,spaft,gobsym];
option[becomes]^.terminators := [endsym,untilsym,elsesym,semicolon];
option[opencomment]^.selected := [crsupp];
option[closecomment]^.selected := [crsupp];
option[semicolon]^.selected  := [crsupp,dindonkey,crafter];
option[semicolon]^.dindsym   := [ifsym,thensym,elsesym,forsym,whilesym,
withsym,colon,equals];
option[colon]^.selected      := [inbytab];
option[equals]^.selected     := [spbef,spaft,inbytab];
option[openparen]^.selected  := [gobsym];
option[openparen]^.terminators := [closeparen];
option[period]^.selected     := [crsupp]; 

{ Start i/o }

crpending := false;
recordseen := false;
getchar;
new(currsym); new(nextsym);
getsymbol;

end; { initialize }

{ Main Program }

begin
initialize;
while nextsym^.name <> endoffile do
begin
getsymbol;
sets := option[currsym^.name];
if (crpending and not (crsupp in sets^.selected))
or (crbefore in sets^.selected) then
begin
insertcr; crpending := false
end;
if blinbefore in sets^.selected then
begin
insertblankline; crpending := false
end;
if dindonkey in sets^.selected
then lshifton(sets^.dindsym);
if dindent in sets^.selected
then lshift;
if spbef in sets^.selected
then insertspace(currsym);
ppsymbol;
if spaft in sets^.selected
then insertspace(nextsym);
if inbytab in sets^.selected
then rshift(currsym^.name);
if gobsym in sets^.selected
then gobble(sets^.terminators);
if crafter in sets^.selected
then crpending := true
end;
if crpending then writecrs(1);

writeln(inlines:1,' lines read, ',outlines:1,' lines written.')

end.
