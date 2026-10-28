{ Cross-reference generator for Pascal/Z programs.  Cross references
  lower case identifiers, ignores comments enclosed in braces and
  quoted strings.  }

{ Author:   Peter Grogono }

{$M- inhibit multiply/divide check }
{$R- inhibit range/bound check }
{$S- inhibit stack overflow check }
{$U- inhibit range/bound check for parameters }

program xref;

const

{$ICONSTS.PAS }

namelen = 8;                   { Significant length of identifier }
filenamelen = 14;              { For i/o file names }
extin = '.PPP';                { Default input file extension }
extout = '.XRT';               { Default output extension }
maxwidth = 80;                 { Maximum width of output line }
minspace = 100;                { Abandon if < minspace bytes free}

type

{$ITYPES.PAS }

nametype = string namelen;
fntype = string filenamelen;

itemptr = ^ itemrecord;
entryptr = ^ entryrecord;

itemrecord = record
line : integer;
next : itemptr
end; { itemrecord }

entryrecord = record
name : nametype;
items : itemptr;
left, right : entryptr
end; { entryrecord }

var

infilename, outfilename : fntype;
infile, outfile : text;

roots : array ['a'..'z'] of entryptr;
name : nametype;
line, oldline, symcount, entcount : integer;
ch : char;
maxent, entlen : byte;
spaceleft : boolean;

{$IPROCS.PAS }
{$IGETFILES.PAS }

{ Read one character from the input file; check for end of file; count lines }

procedure getchar;

begin
if eof(infile) then ch := blank
else
if eoln(infile) then
begin readln(infile,ch); line := line + 1 end
else read(infile,ch)
end; { getchar }

{ Read an identifier from the input file; ignore names that start
  with an upper case letter, comments, quoted strings, and other
  characters. }

procedure getname;

var
done : boolean;

begin
done := false;
repeat
if ch in ['a'..'z'] then
begin
setlength(name,0); oldline := line;
while ch in ['a'..'z','A'..'Z','0'..'9','_'] do
begin
if length(name) < namelen then append(name,ch);
getchar
end; { while }
done := true
end
else
if ch = '{' then
begin repeat getchar until (ch = '}') or eof(infile); getchar end
else
if ch = '''' then
begin repeat getchar until (ch = '''') or eof(infile); getchar end
else getchar
until done or eof(infile)
end; { getname }

{ Store a name in one of the binary trees.  The tree is chosen according
  to the first letter of the name.  The tree is searched with a REPEAT
  loop rather than by recursion for speed.  }

procedure storename;

var
entry : entryptr;
item : itemptr;
entered : boolean;

{ Make an entry in the symbol table.  }

procedure makentry (var entry : entryptr);

var
tempentry : entryptr;
tempitem : itemptr;

begin
new(tempitem);
tempitem^.line := oldline;
tempitem^.next := nil;
new(tempentry);
tempentry^.name := name;
tempentry^.items := tempitem;
tempentry^.left := nil;
tempentry^.right := nil;
entry := tempentry;
symcount := symcount + 1;
entered := true
end; { makentry }

begin { storename }
entry := roots[name[1]]; entered := false;
repeat
if name < entry^.name then
if entry^.left = nil then makentry(entry^.left)
else entry := entry^.left
else
if name > entry^.name then
if entry^.right = nil then makentry(entry^.right)
else entry := entry^.right
else { name matched }
begin
if entry^.items^.line <> line then
begin
new(item);
item^.line := oldline;
item^.next := entry^.items;
entry^.items := item
end;
entered := true
end
until entered;
entcount := entcount + 1
end; { storename }

{ Print a tree given its root.  The list of line numbers associated with
  an identifier is LIFO and must be reversed before printing.  }

procedure print (entry : entryptr);

var
forwards, backwards, temp : itemptr;
entcount : byte;

begin
if entry <> nil then
begin
print(entry^.left);
if length(entry^.name) > 0 then
begin
write(outfile,entry^.name,blank:namelen+2-length(entry^.name));
forwards := nil; backwards := entry^.items;
while backwards <> nil do { reverse list }
begin
temp := backwards; backwards := temp^.next;
temp^.next := forwards; forwards := temp
end; { while }
entcount := 0;
while forwards <> nil do
begin
if entcount >= maxent then
begin writeln(outfile); write(outfile,blank:namelen+2); entcount := 0 end;
write(outfile,forwards^.line:entlen); entcount := entcount + 1;
forwards := forwards^.next
end; { while }
writeln(outfile)
end;
print(entry^.right)
end
end; { print }

{ Main program }

begin

{ Open files }

getfilenames(extin,extout);
writeln('Reading from ',infilename);
reset(infilename,infile);
if eof(infile) then writeln(infilename,' is empty.')
else
begin
writeln('Writing to   ',outfilename);
reset(infilename,infile);
rewrite(outfilename,outfile);

{ Initialize 26 binary trees.  Storename requires dummy entries.  }


for ch := 'a' to 'z' do
begin
new(roots[ch]);
setlength(roots[ch]^.name,0);
roots[ch]^.items := nil;
roots[ch]^.left := nil;
roots[ch]^.right := nil
end; { for }

{ Initialize counters and space flag }

symcount := 0; entcount := 0; spaceleft := true;

{ Initialize input procedures }

line := 1; getchar; getname;

{ Scan the program }

while spaceleft and not eof(infile) do
begin 
if (0 < space) and (space < minspace) then
begin writeln('Memory exhausted at line ',line:1); spaceleft := false end;
storename; getname 
end; { while }

{ Define output layout }

entlen := 3;
if line > 99 then entlen := 4;
if line > 999 then entlen := 5;
maxent := (maxwidth - namelen - 2) div entlen;

{ Print the tree }

for ch := 'a' to 'z' do print(roots[ch]);

{ Display report }

writeln(line-1:1,' lines read, ',symcount:1,' symbols stored, ',
entcount:1,' entries recorded.');
if space > 0 then writeln('Space left: ',space:1,' bytes.')
end
end. { xref }