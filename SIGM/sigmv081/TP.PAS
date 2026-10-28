{ Text Processor }

{ Author: Peter Grogono }

{$E- No statement numbers }
{$F- No real overflow/underflow checking (no reals used anyway) }
{$M- No integer multiply/divide check }
{$R- No range and bounds checking }
{$S+ Check stack overflow because dynamic storage is used }
{$U- No range and bounds checking of parameters }

program TP;

const

{$ICONSTS.PAS }

{ Strings }

extin = '.TEX';      { Default input file extension }
extout = '.DOC';     { Default output file extension }
extcon = '.CON';     { Extension for contents file }
extref = '.REF';     { Extension for cross-reference file }
period = '.';        { End of                  }
query = '?';         {        sentence         }
shriek = '!';        {                 markers }
sentgap = '  ';      { Two blanks at end of sentence }
secgap = ' ';        { Two blanks after a section number }
hardblank = '`';     { Non-trivial blank }
underscore = '_';    { Underlining character }
concat = '-';        { Concatenation character }
pagechar = '#';      { Translates to page number in titles }

{ String lengths.  The most important of these is maxlinelen, which
  determines the maximum possible length of a line of text.  When keeping
  blocks of text, TP uses more than 2 * maxlinelen bytes of memory for each
  line.  Consequently you can reduce the dynamic storage requirements by
  reducing the value of maxlinelen, if your lines will never be as long
  as 120 characters.  }

namelen = 14;        { CP/M file name length }
maxlinelen = 120;    { Maximum length of text line }
maxkeylen = 4;       { Maximum length of cross-reference key }

{ For default values not defined here, see the initialization section
  at the end of the listing.  }

{ Horizontal control }

deffirstmargin = 6;  { Nothing can be printed left of this }
defmaxwidth = 78;    { Width of text on page: 6.5" at 12 cpi }
deflindent = 5;      { Indentation for list numbers }
deflincr = 6;        { Additional indentation for list items }
defparindent = 5;    { Indentation at start of paragraph }
defdisindent = 10;   { Indentation for displays }
deftabgap = 8;       { Tabs at 8, 16, 24, ... } 
numpos = 70;         { Position for page # in table of contents }
contmargin = 6;      { Left margin for contents file }
contindent = 8;      { Indentation for contents file }

{ Vertical control }

defleadin = 3;       { Lines between header and text }
defmaxlines = 52;    { Maximum number of text lines on a page:
                         8.7" at 6 lpi }
deflinespacing = 2;  { Default line spacing }
defparspacing = 4;   { Blank lines between paragraphs }
defbhead = 6;        { Blank lines before a subheading }
defahead = 4;        { Blank lines after a subheading }
defbdisp = 3;        { Blank lines before a display }
defadisp = 3;        { Blank lines after a display }
defchapgap = 20;     { Blank lines after a chapter heading }
deflastline = 55;    { Position of footer, relative to start of text }
defminpara = 4;      { These three constants are used to avoid }
defminsubsec = 8;    { starting something new near the bottom of }
defminsec = 8;       { of a page }
contpagsize = 52;    { Line on a page on the contents file }
contlastline = 55;   { Line # for page # in contents file }
contleadin = 3;      { Line feeds at top of contents page }

type

{$ITYPES.PAS }

filename = string namelen;
linetype = string maxlinelen;
pair = array [1..2] of char;

{ A linerecord stores a line and the environment in which it must be
  formatted.  TP stores a block of text to be 'kept' as a linked list
  of line records.  Line records are also used by the procedures PUSH
  and POP to save an environment.  A floatrecord is used to store an
  entire block of text until it is required for output.  TP maintains
  unprinted floating keeps as a linked list of floatrecords.

  There is a global variable corresponding to each field of these records.
  It would be better programming practice to acknowledge this by using
  global records rather than separate variables.  This, however, would
  (1) make the program larger because of the offset addressing required;
  (2) make the program slower for the same reason; and (3) penalize users
  who are not using the features which require dynamic storage.  }

lineptr = ^ linerecord;
linerecord = record
suppressing, textonline, breakline : boolean;
line, overline : linetype;
spacing : byte;
next : lineptr
end; { linerecord }

floatptr = ^ floatrecord;
floatrecord = record
first, last : lineptr;
keepcount : byte;
next : floatptr
end; { floatrecord }

{ Cross-reference types }

keytype = string maxkeylen;
refptr = ^ refrecord;
refrecord = record
key : keytype;
pagenum : integer;
chapnum, secnum, subsecnum, itemnum, entcount : byte;
left, right : refptr
end; { refrecord }

{ Internal command codes. AA and ZZ are dummies }

codetype = (aa,bd,bf,bk,cc,ce,cx,co,ec,dl,ed,ef,ek,el,ep,
fl,gp,hl,ic,il,im,li,ls,mr,mv,nu,ov,pa,pl,rb,rm,
rr,sb,se,si,sl,sm,sp,ss,su,tc,tl,ts,ul,vl,zr,zz);

var

{ Files }

infilename, outfilename, contfilename, refilename : filename;
output, cont : text;

{ Line buffers }

title, footer, line, overline : linetype;

{ Command character }

comchar : char;

{ Horizontal control }

maxwidth, firstmargin, margin, tabgap, parindent, disindent,
listindent, listincr : byte;
textonline, suppressing : boolean;

{ Vertical control }

linesonpage, spacesdone, linespacing, spacing, minpara, minsec, minsubsec,
leadin, maxlines, lastline, parspacing, chapgap, beforehead, afterhead, 
beforedisp, afterdisp, beforeitem, afterlist : byte;
breakline, pageready : boolean;

{ Table of contents }

conttitle : linetype;
contlines, contpage, contchapter, contsection : byte;
contents, pageintc : boolean;

{ Cross-references }

reftable : refptr;
showrefs : boolean;
currkey : keytype;
entcount : byte;

{ Section numbering }

pagenum : integer;
chapnum, secnum, subsecnum : byte;

{ Keeps and floating keeps }

freelist, first, last, stack : lineptr;
firstfloat, lastfloat, freefloat : floatptr;
keepcount : byte;
keeping : boolean;

{ Displays }

displaylevel, dispspacing, savespacing, diswidth, savewidth : byte;

{ Itemized lists }

itemnum : byte;
itemlist : boolean;

{ Underlining }

uscharset : set of char;
underlining : boolean;

{ Special printer codes }

printwarning : boolean;

{ Miscellaneous counters }

spaceleft, wordcount, pagecount : integer;
errorcount : byte;

{ Constant tables and sets }

codetable : array [codetype] of pair;
wordends : set of char;

{$IPROCS.PAS }
{$IGETFILES.PAS }

{ Convert lower case letters to upper case }

function upper (ch : char) : char;

begin
if ch in ['a'..'z'] then upper := chr(ord(ch) - ord('a') + ord('A'))
else upper := ch
end; { upper }

{ Create a new file name from a given file name and the extension EXT.  }

procedure changext (inname : filename; ext : string255; var name : filename);

begin
name := inname;
setlength(name,pred(index(name,period)));
append(name,ext)
end; { changext }

{ ---------------------- Cross-reference procedures ------------------------ }

{ Store current global values into specified entry.  }

procedure update (ref : refptr);

begin
ref^.pagenum := pagenum;
ref^.chapnum := chapnum;
ref^.secnum := secnum;
ref^.subsecnum := subsecnum;
ref^.itemnum := itemnum
end; { update }

{ Make a new entry or update an old entry in the cross-reference table.  }

procedure makentry (key : keytype; var ref : refptr);

begin
if ref = nil then
begin new(ref); ref^.left := nil; ref^.right := nil;
ref^.key := key; ref^.entcount := 0; update(ref) end
else
if key < ref^.key then makentry(key,ref^.left)
else
if key > ref^.key then makentry(key,ref^.right)
else update(ref) { old entry }
end; { makentry }

{ Look up an entry in the table, given the key.  }

procedure lookup (key : keytype; root : refptr; var ref : refptr);

begin
if root = nil then ref := nil else
if key < root^.key then lookup(key,root^.left,ref) else
if key > root^.key then lookup(key,root^.right,ref)
else ref := root
end; { lookup }

{ Write cross-reference table to a file.  }

procedure writerefs;

var
refile : text;

{ Write a sub-tree of entries to the file.  The sub-tree is traversed
  in pre-order so that re-reading the file will not create a degenerate
  tree.  }

procedure putentry (ref : refptr);

begin
if ref <> nil then
with ref ^ do
begin
writeln(refile,key,pagenum:6,chapnum:4,secnum:4,
subsecnum:4,itemnum:4,entcount:4);
putentry(left); putentry(right)
end
end; { putentry }

begin { writerefs }
changext(infilename,extref,refilename); 
rewrite(refilename,refile); putentry(reftable)
end; { writerefs }

{ Read a file of cross-references.  }

procedure readrefs;

var
refile : text;
key : keytype;
ch : char;

begin
reftable := nil;
changext(infilename,extref,refilename); reset(refilename,refile);
while not eof(refile) do
begin
setlength(key,0); read(refile,ch);
while ch <> blank do
begin append(key,ch); read(refile,ch) end; { while }
readln(refile,pagenum,chapnum,secnum,subsecnum,itemnum);
pad(key,maxkeylen); makentry(key,reftable)
end { while }
end; { readrefs }

procedure putline; forward;

{ --------------------- Free store and keep management --------------------- }

{ The next three procedures handle dynamic storage of lines.  There is a
  stack for saving environments and a queue for storing 'kept' text.
  The procedure POP is used to remove a line from the stack or the queue.
  The procedure SAVE is used to insert a line into the stack or the queue,
  it does not do the pointer updating because it doesn't know whether the
  line is to go at the back of a queue or the front of a list.  }

procedure save (var ptr : lineptr);

begin
if freelist = nil then new(ptr)
else
begin ptr := freelist; freelist := freelist^.next end;
ptr^.suppressing := suppressing; ptr^.textonline := textonline;
ptr^.breakline := breakline; ptr^.line := line; ptr^.overline := overline;
ptr^.spacing := spacing
end; { save }

procedure push;

var
ptr : lineptr;

begin save(ptr); ptr^.next := stack; stack := ptr end; { push }

procedure pop (var ptr : lineptr);

var
old : lineptr;

begin
suppressing := ptr^.suppressing; textonline := ptr^.textonline;
breakline := ptr^.breakline; line := ptr^.line; 
overline := ptr^.overline; spacing := ptr^.spacing;
old := ptr; ptr := ptr^.next; old^.next := freelist; freelist := old
end; { pop }

{ Reset the keep pointers and count.  This procedure does not affect the
  contents of the keep queue.  }

procedure resetkeep;

begin first := nil; last := nil; keepcount := 0 end; { resetkeep }

{ Put a line of text into a keep buffer }

procedure keep;

var
ptr : lineptr;

begin
save(ptr); keepcount := keepcount + spacing;
if first = nil then first := ptr else last^.next := ptr;
last := ptr; ptr^.next := nil
end; { keep }

{ End a keep.  Write kept lines to output file.  }

procedure endkeep;

var
ptr : lineptr;

begin
ptr := first; resetkeep;
while ptr <> nil do begin pop(ptr); putline end { while }
end; { endkeep }

{ ------------------------- Table of Contents management ------------------- }

{ Write a title in the contents file }

procedure putconttitle;

var
count : byte;

begin
writeln(cont,chr(FF));
writeln(cont,blank:contmargin,conttitle);
for count := 1 to contleadin do writeln(cont);
contpage := succ(contpage);
contlines := 0
end; { putcontitle }

{ End a page of the contents file }

procedure endcontpage;

begin
while contlines < contlastline do
begin
writeln(cont); contlines := succ(contlines)
end; { while }
writeln(cont,blank:numpos,'C-',contpage:1)
end; { endcontpage }

{ Write blank lines followed by title or section name to contents file;
  start a new page when necessary.  }

procedure putcontline (lines, indent : byte; line : linetype);

var
count : byte;
ch : char;

begin
if contlines + lines > contpagsize then
begin endcontpage; putconttitle end
else
begin
for count := 1 to lines do writeln(cont);
contlines := contlines + lines
end;
write(cont,blank:indent);
for count := 1 to length(line) do
begin
ch := line[count];
if ch = hardblank then write(cont,blank)
else write(cont,ch)
end; { for }
if pageintc then write(cont,blank:3,pagenum:1)
end; { putcontline }

{ -------------------------- Page layout ----------------------------------- }

{ Write a running header or footer }

procedure writerunner (runner : linetype);

var
i : byte;
ch : char;

begin
write(output,blank:firstmargin);
for i := 1 to length(runner) do
begin
ch := runner[i];
if ch = hardblank then write(output,blank)
else
if ch = pagechar then write(output,pagenum:1)
else write(output,ch)
end; { for }
writeln(output)
end; { writerunner }

{ Start a new page and write header on it.  If there are any floating keeps
  in the list, as many are printed as will fit on the page.  When a floating
  keep has been printed out the memory that it occupied is reclaimed.  }

procedure startpage;

var
count : byte;
float : floatptr;
done : boolean;

begin
writeln(output,chr(FF)); writerunner(title);
for count := 1 to leadin do writeln(output);
pagenum := succ(pagenum); pagecount := succ(pagecount);
linesonpage := 0; pageready := true; done := false;
repeat
if firstfloat = nil then done := true
else
begin
count := firstfloat^.keepcount;
if (count + linesonpage > maxlines) and (count <= maxlines)
then done := true { Not enough space }
else
begin
push; first := firstfloat^.first; last := firstfloat^.last; 
keepcount := count; endkeep; float := firstfloat; firstfloat := float^.next;
float^.next := freefloat; freefloat := float; pop(stack)
end
end
until done
end; { startpage }

{ End a page by filling it with blank lines and writing footer }

procedure endpage;

begin
if pageready then
begin
while linesonpage < lastline do
begin writeln(output); linesonpage := succ(linesonpage) end; { while }
writerunner(footer);
pageready := false
end
end; { endpage }

{ Any floating keeps must be released at the end of a chapter and at
  the end of the text.  }

procedure endchap;

begin
putline; endpage;
while firstfloat <> nil do begin startpage; endpage end { while }
end; { endchap }

{ -------------------------- Output management ----------------------------- }

{ Initialize the current line }

procedure resetline;

begin
setlength(line,0); setlength(overline,0); 
spacing := linespacing; textonline := false; breakline := false
end; { resetline }

{ Output a completed line.  Where the line goes depends on whether
  we are "keeping" or not.  Output blank lines after the line 
  according to the value of SPACING.  Reset the line buffers. }

procedure putline;

var
ch : char;
count : byte;

{ Write the left margin.  No user text can appear in margin, but it is used
  for cross-reference entries if \ZR is called.  }

procedure writemargin;

begin
if showrefs and (length(currkey) > 0)
then
begin
write(output,currkey,blank:firstmargin - maxkeylen); setlength(currkey,0)
end
else write(output,blank:firstmargin)
end; { writemargin }

begin { putline }
if keeping then keep
else
begin
if textonline or not suppressing then
begin
if linesonpage >= maxlines then endpage;
if not pageready then startpage;
writemargin;
for count := 1 to length(line) do
begin
ch := line[count];
if ch = hardblank then write(output,blank) else write(output,ch)
end; { for }
if length(overline) > 0
then
begin
write(output,chr(CR)); writemargin; write(output,overline)
end;
spacesdone := 0
end;
while (spacesdone < spacing) and (linesonpage < maxlines) do
begin
writeln(output);
linesonpage := succ(linesonpage); spacesdone := succ(spacesdone)
end; { while }
end;
resetline
end; { putline }

{ Append one character to a line.  Start a new line if necessary.
  Underline the character if UNDERLINING is true and the character
  is in the underline set. }

procedure putchar (ch : char; underlining : boolean);

begin
if breakline or (length(line) >= maxwidth) then putline;
if not textonline then pad(line,margin);
append(line,ch);
if underlining and (ch in uscharset) then
begin
pad(overline,pred(length(line)));
append(overline,underscore)
end;
textonline := true
end; { putchar }

{ Append a positive number to the line buffer without leading
  or trailing blanks. }

procedure putnum (var line : string0; num : integer);

var
buf : array [1..5] of char;
bp, cp : byte;

begin
bp := 0;
repeat
bp := succ(bp);
buf[bp] := chr(num mod 10 + ord('0'));
num := num div 10
until num = 0;
for cp := bp downto 1 do append(line,buf[cp])
end; { putnum }

{ Append a section number to a line }

procedure putsecnum (var line : string0; 
chapnum, secnum, subsecnum : integer);

var
trailing : boolean;

begin
trailing := false;
if chapnum > 0 then
begin putnum(line,chapnum); trailing := true end;
if secnum > 0 then
begin
if trailing then append(line,period);
putnum(line,secnum); trailing := true
end;
if subsecnum > 0 then
begin
if trailing then append(line,period);
putnum(line,subsecnum)
end
end; { putsecnum }

{ Append a word to the line buffer.  Separate words by:
    0 blanks if CONCAT character is last but not only character;
    2 blanks if end of sentence;
    1 blank otherwise.  
  If first character is underscore then underline entire word. }

procedure putword (word : string255);

var
ch, lastchar : char;
wordlen, linelen, count : byte;
space : integer;
underline, concatenate, sentend : boolean;

begin
linelen := length(line);
if linelen = 0 then
begin lastchar := blank; sentend := false; concatenate := false end
else
begin
lastchar := line[linelen];
if (lastchar = concat)
and (linelen > 1)
and (line[pred(linelen)] <> blank) 
and (line[pred(linelen)] <> concat)
then
begin
sentend := false; concatenate := true;
setlength(line,pred(linelen))
end
else
begin
sentend := lastchar in [period,query,shriek];
concatenate := false
end
end;
wordlen := length(word);
underline := (wordlen > 1) and (word[1] = underscore);
if underline then wordlen := pred(wordlen);
space := maxwidth - linelen - wordlen;
if breakline or (sentend and (space <= 6))
or (not sentend and (space <= 1)) then putline;
if textonline then
begin
if sentend then append(line,sentgap)
else
if not concatenate then append(line,blank)
end
else pad(line,margin);
if underline then
begin
pad(overline,length(line));
for count := 2 to succ(wordlen) do
begin
ch := word[count];
append(line,ch);
if ch in uscharset
then append(overline,underscore) else append(overline,blank)
end { for }
end
else append(line,word);
textonline := true; wordcount := succ(wordcount)
end; { putword }

{ Record the need to break a line, and the blank space needed after it }

procedure break (spaceneeded : byte);

begin
breakline := true;
if spaceneeded > spacing then spacing := spaceneeded
end; { break }

{ -------------------------- Text Processing ------------------------------- }

{ Process a file of text.  This procedure calls itself recursively
  to process included files.  Global variables are maintained while
  an included file is processed, but variables local to this
  procedure are saved implicitly on the stack until the included
  file has been processed, and are then restored. }

procedure process (infilename : filename);

var
input : text;
word : linetype;
ch : char;
inlinecount : integer;

{ Get a character from the input file.  Translate EOF to NUL (0)
  and EOL to CR.  Count lines read. }

procedure getchar;

begin
if eof(input) then ch := chr(0)
else
if eoln(input) then
begin
read(input,ch); ch := chr(CR);
inlinecount := succ(inlinecount)
end
else read(input,ch)
end; { getchar }

{ Get a word from the input file.  The first character is already
  in ch.  A word is terminated by blank, EOL, EOF, or TAB. }

procedure getword (var word : string0);

begin
setlength(word,0);
repeat
append(word,ch);
getchar
until ch in wordends
end; { getword }

{ Read and store text up to the end of the input line }

procedure getline (var line : string0);

begin
while ch <> chr(CR) do begin append(line,ch); getchar end { while }
end; { getline }

{ -------------------------  Command decoder  ------------------------- }

{ Called when comchar is encountered in text. }

procedure command;

var
infilename : filename;
cmd : pair;
code : codetype;
count : byte;
word : linetype;
num : integer;
key : keytype;
ref : refptr;
refcode : char;
float : floatptr;

{ Report an error }

procedure error (message : string255);

begin
writeln('Line ',inlinecount:1,', command ',codetable[code],': ',message);
errorcount := succ(errorcount)
end; { error }

{ Skip over blanks }

procedure skip;

begin 
while ch = blank do getchar
end; { skip }

{ Read an unsigned integer.  Skip leading blanks.
  Any non-digit terminates the number. }

procedure getnum (var num : integer);

begin
num := 0;
skip;
while ch in ['0'..'9'] do
begin
num := 10 * num + ord(ch) - ord('0');
getchar
end { while }
end; { getnum }

{ Read a number.  The following cases are handled:
    NNN    return value of NNN;
    =      return DEFAULT;
    +NNN   return DEFAULT + NNN;
    -NNN   return DEFAULT - NNN. }

procedure getdefnum (var num : integer; default : integer);

var
mode : (plus, minus, abs);

begin
skip;
if ch = '+' then
begin mode := plus; getchar end
else 
if ch = '-' then
begin mode := minus; getchar end
else mode := abs;
getnum(num);
if (num = 0) and (ch = '=') then
begin num := default; getchar end
else
case mode of
plus : num := default + num;
minus : num := default - num;
abs :
end { case }
end; { getdefnum }

{ Read a cross-reference key }

procedure getkey (var key : string0);

begin
setlength(key,0); skip;
while ch in ['a'..'z','A'..'Z','0'..'9'] do
begin
if length(key) < maxkeylen then append(key,ch);
getchar
end; { while }
pad(key,maxkeylen)
end; { getkey }

{ Set vertical spacing parameters based on the value of linespacing }

procedure setspacing (linespacing : byte);

begin
parspacing := 2 * linespacing; beforehead := 3 * linespacing;
afterhead := 2 * linespacing; beforedisp := succ(linespacing); 
afterdisp := succ(linespacing); beforeitem := succ(linespacing); 
afterlist := succ(linespacing); dispspacing := linespacing
end; { setspacing }

{ This procedure is called when the command processor encounters a
  command character that is not followed by a letter; ch contains
  the character following the command character. }

procedure putcomchar;

var
word : linetype;

begin
if suppressing then 
if ch in wordends then putword(comchar) else
begin
setlength(word,0); append(word,comchar);
repeat append(word,ch); getchar
until ch in wordends;
putword(word)
end
else putchar(comchar,underlining)
end; { putcomchar }

{ Check amount of space on page and start a new page if necessary.
  No effect in keep mode. }

procedure check (linesneeded : byte);

begin
if not keeping then
begin
if linesonpage + linesneeded > maxlines then endpage;
if not pageready then startpage
end
end; { check }

{ Start a new paragraph, on a new page if necessary. }

procedure startpara (spaceneeded : byte);

begin
break(spaceneeded); putline; check(minpara);
pad(line,margin + parindent)
end; { startpara }

{ Write a subheading.  Write chapter number, section number,
  subsection number if > 0, title.  Title is terminated by
  EOL or command terminator.  Start a new paragraph. }

procedure putsubhead (min : byte; numbered : boolean);

var
word : linetype;

begin
break(beforehead); putline; check(min); setlength(word,0);
if numbered then
begin
putsecnum(word,chapnum,secnum,subsecnum);
if length(word) > 0 then
begin append(word,secgap); putword(word) end
end;
skip;
while ch <> chr(CR) do
begin getword(word); skip; putword(word) end; { while }
if contents and numbered
then putcontline(contsection,contmargin+contindent,line);
startpara(afterhead)
end; { putsubhead }

{ ---------------------- Command processor --------------------------------- }

begin { command }
getchar;
if not (ch in ['a'..'z','A'..'Z']) then putcomchar
else
begin
cmd[1] := upper(ch); getchar;
cmd[2] := upper(ch); getchar;
code := zz; codetable[aa] := cmd;
while codetable[code] <> cmd do code := pred(code);

case code of

{ Illegal commands }

aa, zz : error('invalid command code');

{ BD : Begin display }

bd : begin
margin := margin + disindent; break(beforedisp); 
displaylevel := succ(displaylevel);
if displaylevel = 1 then
begin
savespacing := linespacing; linespacing := dispspacing; 
setspacing(linespacing); savewidth := maxwidth; maxwidth := diswidth
end
end;

{ BF : Begin floating keep }

bf : if keeping then error('already keeping')
else
begin push; resetline; keeping := true; keepcount := 0 end;

{ BK : Begin keep }

bk : if keeping then error('already keeping')
else
begin break(0); putline; keeping := true end;

{ CC : Printer control characters }

cc : begin
skip;
while ch in ['0'..'9'] do
begin
getnum(num); skip;
if (1 <= num) and (num <= 31) then write(output,chr(num))
else
begin error('invalid control character'); getchar end
end; { while }
printwarning := true
end;

{ CE : Print one line centered }

ce : begin
break(0); putline; setlength(word,0); skip; getline(word);
for count := 1 to (maxwidth - length(word)) div 2 do append(line,blank);
append(line,word); textonline := true; putline
end;

{ CH : Start a new chapter }

cx : begin
if keeping then error('floating or keeping'); endchap;
chapnum := succ(chapnum); secnum := 0; subsecnum := 0;
setlength(title,0); putnum(title,chapnum); append(title,'.  ');
skip; getline(title); startpage; startpara(chapgap);
if contents then putcontline(contchapter,contmargin,title)
end;

{ CO : Comment }

co : while ch <> chr(CR) do getchar;

{ DL : Set display layout }

dl : begin
getdefnum(beforedisp,defbdisp); getdefnum(afterdisp,defadisp);
getdefnum(dispspacing,linespacing); getdefnum(disindent,defdisindent);
getdefnum(diswidth,maxwidth)
end;

{ EC : Set escape character (= command character) }

ec : begin skip; comchar := ch; getchar end;

{ ED : End display }

ed : if displaylevel > 0 then
begin
if displaylevel = 1 then
begin
linespacing := savespacing; setspacing(linespacing); maxwidth := savewidth
end; 
margin := margin - disindent; break(afterdisp); 
displaylevel := pred(displaylevel)
end
else error('not displaying');

{ EF : End a floating keep.  If there are no keeps already in the queue
  and there is room on this page, then print the contents of the keep;
  otherwise put it in the queue.  }

ef : if keeping then
begin
putline; keeping := false;
if (firstfloat <> nil)
or (keepcount + linesonpage > maxlines)
and (keepcount <= maxlines) then
begin
if freefloat = nil then new(float)
else
begin float := freefloat; freefloat := freefloat^.next end;
float^.first := first; float^.last := last; float^.keepcount := keepcount;
float^.next := nil;
if firstfloat = nil then firstfloat := float
else lastfloat^.next := float;
lastfloat := float; resetkeep
end
else endkeep;
pop(stack)
end
else error('not keeping');

{ EK : End keep.  If there is room on the page, then print the keep;
  otherwise start a new page and then print it.  There may be floating
  keeps waiting to be printed and so we must go on skipping pages until
  there is enough space for the keep.  }

ek : if keeping then
begin
putline; keeping := false;
if keepcount <= maxlines then
while keepcount + linesonpage > maxlines do
begin endpage; if not pageready then startpage end; { while }
endkeep
end
else error('not keeping');

{ EL : End a list of items }

el : begin margin := 0; break(afterlist);
putline; itemnum := 0; itemlist := false end;

{ EP : End page }

ep : if keeping then error('illegal in keep')
else
begin putline; endpage end;

{ FL : Define new running footer.  The footer is terminated by
       EOL or command terminator.  No entry in table of contents. }

fl: begin setlength(footer,0); skip; getline(footer) end;

{ GP : Get page number from keyboard or parameter }

gp : begin
skip;
if ch = query then
begin
getchar;
if pagenum = 0 then
begin write('Enter page number: '); read(num) end
else num := succ(pagenum)
end
else getnum(num);
pagenum := pred(num)
end;

{ HL : Set horizontal layout parameters }

hl : begin
getdefnum(firstmargin,deffirstmargin);
getdefnum(maxwidth,defmaxwidth)
end;

{ IC : Include named file }

ic : begin
setlength(infilename,0); skip; getline(infilename);
if index(infilename,period) = 0 then append(infilename,extin);
process(infilename)
end;

{ IL : Set itemized list layout }

il : begin
getdefnum(beforeitem,succ(linespacing));
getdefnum(afterlist,succ(linespacing));
getdefnum(listindent,deflindent);
getdefnum(listincr,deflincr)
end;

{ IM : Set immediate margin }

im : begin
count := length(line); getdefnum(num,count);
if count >= num then putline; pad(line,pred(num)); margin := num
end;

{ LI : List item.  Put item number and indent. }

li : if itemlist then
begin
itemnum := succ(itemnum); margin := listindent; break(beforeitem); putline;
pad(line,margin); putchar('(',false); putnum(line,itemnum); 
putchar(')',false); margin := margin + listincr; pad(line,pred(margin))
end
else error('not in list mode');

{ LS : Set linespacing }

ls : begin
getdefnum(linespacing,deflinespacing);
if (1 <= linespacing) and (linespacing <= 3) then
begin
setspacing(linespacing);
if spacing < linespacing then spacing := linespacing
end
else error('value out of range')
end;

{ MR : make a cross-reference }

mr : begin getkey(key); currkey := key; makentry(key,reftable) end;

{ MV : Set minimum values for starting something near bottom of page }

mv : begin 
getdefnum(minpara,defminpara); getdefnum(minsubsec,defminsubsec);
getdefnum(minsec,defminsec)
end;

{ NU : Remove characters from underline set }

nu : while ch <> chr(CR) do
begin uscharset := uscharset - [ch]; getchar end; { while }

{ OV : Overlay next two characters }

ov : begin
skip;
if suppressing then append(line,blank);
pad(overline,length(line));
append(line,ch); getchar; append(overline,ch); getchar
end;

{ PA : Start a new paragraph }

pa : startpara(parspacing);

{ PL : Set paragraph layout }

pl : begin
getdefnum(parspacing,defparspacing);
getdefnum(parindent,defparindent)
end;

{ RB : Switch to retain blank mode }

rb : if suppressing then
begin suppressing := false; underlining := false end
else error('occurred twice');

{ RM : Put next word in right margin }

rm : begin
skip; getword(word);
if length(line) + length(word) > maxwidth then putline;
pad(line,maxwidth - length(word)); append(line,word)
end;

{ RR : Retrieve cross-reference data and print it }

rr : begin
skip; refcode := upper(ch); getchar; getkey(key); lookup(key,reftable,ref);
setlength(word,0);
if ref = nil then putnum(word,0)
else
with ref ^ do
begin
entcount := succ(entcount);
case refcode of
'P' : putnum(word,pagenum);
'C' : putnum(word,chapnum);
'S' : putsecnum(word,chapnum,secnum,subsecnum);
'I' : putnum(word,itemnum)
end { case }
end;
while not (ch in wordends) do
begin append(word,ch); getchar end;
putword(word)
end;

{ SB : Switch to suppress blank and EOL mode }

sb : if suppressing
then error('occurred twice')
else suppressing := true;

{ SE : Start section }

se : begin 
secnum := succ(secnum); subsecnum := 0; putsubhead(minsec,true) 
end;

{ SI : Set item number }

si : if itemlist then error('inside list')
else
begin itemlist := true; getnum(itemnum) end;

{ SL : Set subheading layout }

sl : begin
getdefnum(beforehead,defbhead); getdefnum(afterhead,defahead)
end;

{ SM : Set left margin }

sm : getdefnum(margin,length(line));

{ SP : Force line break and write blank lines. }

sp : begin getdefnum(count,linespacing); break(count); putline end;

{ SS : Start subsection }

ss : begin
if secnum = 0 then error('no section');
subsecnum := succ(subsecnum); putsubhead(minsubsec,true)
end;

{ SU : Start unnumbered section }

su : putsubhead(minsec,false);

{ TC : write a table of contents.  Linespacing in contents file
       is determined by LS setting when this command is executed. }

tc : if contents then error('occurred twice')
else
begin
contents := true;
contsection := linespacing;
contchapter := 2 * linespacing;
changext(outfilename,extcon,contfilename);
rewrite(contfilename,cont);
setlength(conttitle,0);
skip;
if ch = '#' then
begin pageintc := true; getchar; skip end;
getline(conttitle); putconttitle
end;

{ TL : Define new running title.  The title is terminated by
       EOL or command terminator.  Make an entry in the table
       of contents.  # will be translated to page number. }

tl : begin
setlength(title,0); skip; getline(title);
if contents then putcontline(contchapter,contmargin,title)
end;

{ TS : Set tab spacing }

ts : getdefnum(tabgap,deftabgap);

{ UL : Add characters to underline set }

ul : while ch <> chr(CR) do
begin if ch <> blank then uscharset := uscharset + [ch]; getchar end; { while }

{ VL : Set vertical layout parameters }

vl : begin
getdefnum(leadin,defleadin); getdefnum(maxlines,defmaxlines);
getdefnum(lastline,deflastline); getdefnum(chapgap,defchapgap)
end;

{ ZR : Show references in left margin }

zr : showrefs := true;

end; { case }
skip
end
end; { command }

{ ----------------- Main text processing loop ------------------------------ }

{ If suppressing is true (usual case) the input text is processed
  word by word.  If suppressing is false the text is processed
  character by character. }

begin { process }

writeln(infilename,' opened for input.');
reset(infilename,input);
inlinecount := 0;
getchar;

while ch <> chr(0) do
begin
while ch = comchar do command;
if suppressing then
if ch in wordends then getchar
else
begin
getword(word); putword(word)
end
else { retaining blanks and line breaks }
begin
if ch in wordends then
begin wordcount := succ(wordcount); underlining := false end;
if ch = chr(CR) then putline
else
if ch = chr(TAB) then
repeat append(line,blank) until length(line) mod tabgap = 0
else
if (ch = underscore) and not underlining then underlining := true
else putchar(ch,underlining);
getchar
end
end; { while }

writeln(infilename,' closed on page ',pagenum:1,'; ',
inlinecount:1,' lines read.')

end; { process }

{ ------------------------------- Main program ----------------------------- }

begin

{ Read file names from command line }

getfilenames(extin,extout);
if length(infilename) = 0
then writeln('No input file.')
else
begin

{ Read cross-reference file.  This must be done before global variables
  are initialized because it changes some of them.  }

readrefs;

{ Initialize keep space }

freelist := nil; stack := nil; resetkeep;
firstfloat := nil; lastfloat := nil; freefloat := nil; 

{ Initialize sets.  The underline character set contains all characters
  except the common punctuation characters; this is to prevent the
  underlining of a punctuation character that follows an underlined word.
  Blank and rubout cannot be underlined.  See \UL and \NU. }

wordends := [blank,chr(0),chr(CR),chr(TAB)];
uscharset := [chr(33)..chr(126)] - [',','.',';',':','!','?','-','_'];

{ Initialize flags }

suppressing := true; pageready := false; keeping := false; contents := false; 
pageintc := false; itemlist := false; underlining := false;
printwarning := false; showrefs := false;

{ Initialize counters and parameters  }

linesonpage := 0; pagenum := 0; wordcount := 0; chapnum := 0; secnum := 0; 
subsecnum := 0; contpage := 0; pagecount := 0; margin := 0; spacesdone := 0; 
errorcount := 0; itemnum := 0; displaylevel := 0; spaceleft := maxint;

{ Set defaults }

comchar := '\';                  { Default command character }

{ Set horizontal defaults }

firstmargin := deffirstmargin;      { Nothing can be printed left of this }
maxwidth    := defmaxwidth;         { Width of text on page; 6.5" at 12 cpi }
parindent   := defparindent;        { Paragraph indentation }
tabgap      := deftabgap;           { Tabs at X where X mod tabgap = 0 }
diswidth    := maxwidth;            { Default length of displyed lines }
disindent   := defdisindent;        { Display indentation }
listindent  := deflindent;          { Indentation for a numbered list }
listincr    := deflincr;            { Additional indentation for list items }

{ Set vertical defaults }

leadin      := defleadin;           { Lines between running header and text }
maxlines    := defmaxlines;         { Maximum # of text lines on a page:
                                              8.5" at 6 lpi }
lastline    := deflastline;         { Line #, relative to start of text,
                                              for footer }
linespacing := deflinespacing;      { Normal spacing between lines }
dispspacing := linespacing;         { Line spacing in a display }
parspacing  := defparspacing;       { Lines before a paragraph }
beforehead  := defbhead;            { Lines before a heading }
afterhead   := defahead;            { Lines after a heading }
beforedisp  := defbdisp;            { Lines before a display }
afterdisp   := defadisp;            { Lines after a display }
beforeitem  := succ(deflinespacing);  { Lines before a list item }
afterlist   := succ(deflinespacing);  { Lines after an itemized list }
chapgap     := defchapgap;          { Lines before first line of chapter }
minpara     := defminpara;          { Limit for starting paragraph }
minsubsec   := defminsubsec;        { Limit for starting subsection }
minsec      := defminsec;           { Limit for starting section }

{ Initialize line buffers and strings }

resetline;
setlength(title,0); setlength(footer,0);
setlength(currkey,0);

{ Define code mnemonic table }

codetable[bd] := 'BD'; codetable[bf] := 'BF'; codetable[bk] := 'BK';
codetable[cc] := 'CC'; codetable[ce] := 'CE'; codetable[cx] := 'CH'; 
codetable[co] := 'CO'; codetable[dl] := 'DL'; codetable[ec] := 'EC';
codetable[ed] := 'ED'; codetable[ef] := 'EF'; codetable[ek] := 'EK';
codetable[el] := 'EL'; codetable[ep] := 'EP'; codetable[fl] := 'FL'; 
codetable[gp] := 'GP'; codetable[hl] := 'HL'; codetable[ic] := 'IC'; 
codetable[il] := 'IL'; codetable[im] := 'IM'; codetable[li] := 'LI'; 
codetable[ls] := 'LS'; codetable[mr] := 'MR'; codetable[mv] := 'MV';
codetable[nu] := 'NU'; codetable[ov] := 'OV';
codetable[pa] := 'PA'; codetable[pl] := 'PL'; codetable[rb] := 'RB'; 
codetable[rm] := 'RM'; codetable[rr] := 'RR'; codetable[sb] := 'SB'; 
codetable[se] := 'SE'; codetable[si] := 'SI'; codetable[sl] := 'SL'; 
codetable[sm] := 'SM'; codetable[sp] := 'SP'; codetable[ss] := 'SS'; 
codetable[su] := 'SU'; codetable[tc] := 'TC'; codetable[tl] := 'TL'; 
codetable[ts] := 'TS'; codetable[ul] := 'UL'; codetable[vl] := 'VL'; 
codetable[zr] := 'ZR'; codetable[zz] := 'ZZ';

{ Open the output file }

writeln(outfilename,' opened for output.');
rewrite(outfilename,output);

{ Process the input file }

process(infilename); endchap;
if contents then endcontpage; if reftable <> nil then writerefs;

{ Display the results }

writeln(outfilename,': ',pagecount:1,' pages; ',wordcount:1,' words.');
if contpage > 0 
then writeln(contfilename,': ',contpage:1,' pages.');
if space > 0 then writeln('Free memory: ',space:1,' bytes.');
if errorcount > 0 then writeln('Errors: ',errorcount:1,'.');
if printwarning then
begin
writeln;
writeln('WARNING: the output file contains printer control characters!')
end
end
end. { TP }
