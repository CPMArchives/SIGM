{ Read file names from command buffer }

{ Assumes global file names 'infilename' and 'outfilename' }

procedure getfilenames (extin, extout : string255);

const
buflen = 128;    { Length of command buffer }

var
buffer : string buflen;
ch : char;
bp, len : byte;

{ Read a name from the command buffer }

procedure getname (var name : string0; ext : string255);

{ Read one character from the command buffer }

procedure getchar;

begin
bp := bp + 1;
if bp <= len then ch := buffer[bp] else ch := chr(0)
end; { getchar }

begin { getname }
setlength(name,0);
repeat getchar until ch <> blank;
if ch > chr(0) then
begin
repeat append(name,ch); getchar until (ch = blank) or (ch = chr(0));
if index(name,'.') = 0 then append(name,ext)
end
end; { getname }

begin { getfilenames }
setlength(buffer,0);
while not eoln(0) do
begin read(ch); append(buffer,ch) end; { while }
len := length(buffer); bp := 0;
getname(infilename,extin);
getname(outfilename,extout);
if (length(infilename) > 0) and (length(outfilename) = 0)
then
begin
outfilename := infilename;
setlength(outfilename,index(outfilename,'.') - 1);
append(outfilename,extout)
end
end; { getfilenames }
