program xlocate;{$P,c-,m-,f-}

{A program to locate the starting and ending address of an array of charac-}
{ters within a .com file.  Enter the characters with a carriage return.}
{Written by: Craig Rudlin, M.D.}


label 1;
type 
byte = 0..255;
f = file of byte;
$string14 = string 14;
 
var
length,match,c,b:byte;
charsub:array[1..80] of byte;
input:f;
ch:char;
i:real;
filename:$string14;
found,first_occurrence,continue:boolean;
 
procedure keyin(var cix:char);external; {this procedure is on a previous user
 					group disc}

begin
continue:=true;
write(chr(27),'*',chr(0),chr(0),chr(0),chr(0));	 {clear screen code for Soroc
					        or Televideo}
writeln;
writeln(' PROGRAM TO LOCATE MEMORY ADDRESS OF AN ARRAY OF CHARACTERS ');
writeln;
writeln('Enter the NAME of the .COM file you wish to search ');
write  ('as Drive:name.COM.    The file must be a .COM file ');
readln(filename);

writeln;
writeln;


{a com file is nothing more than an file of bytes, and thus can be either
sequentially or randomly read just like any other file. Each "record" in
the COM file is a single byte.  Note we must declare the type byte = 0..255}



while continue do
begin
found:=false;
write(chr(27),'*',chr(0),chr(0),chr(0),chr(0));	     {clear screen}
reset(filename,INPUT);
if eof(input) then
	begin
	writeln('File ',filename, 'not present on disk. ');
	goto 1;
	end;
i:=0.0;       {initialize values}
c:=0;
for b:= 1 to 80 do charsub[b]:=32;   {initialize array to all spaces}

repeat
write(' Enter the LENGTH (up to 80 characters) of the array:   ');
readln(length);
until (length > 0) and (length < 81);

{I chose to limit the size to one line on my CRT, hence a max length of 80}
writeln;
writeln;
repeat
writeln('Do you want (1) only the first occurrence or (2) all occurrences of');
write  ('the array of characters?   Enter either a  1  or a  2 :   ');
keyin(ch);
until (ch = '1') or (ch = '2');
if ch = '1' then first_occurrence:= true else first_occurrence:= false;
write(chr(27),'*',chr(0),chr(0),chr(0),chr(0));	     {clear screen}
writeln;
writeln('When prompted, enter ',length:4,'  characters or spaces.');
writeln;
writeln('DO NOT ENTER A CARRIAGE RETURN AT ANY TIME.'); {keyin doesnt need one}
writeln;
writeln('If you make a mistake, type a control-C after ');
writeln('entering all the characters or spaces.');
writeln;
writeln;


write('---> ');
for b:=length downto 1 do 
 		     {pascal stores an array of char backwards in .com file}
begin	
  repeat
	keyin(ch);   
	until ((ord(ch) > 64) and (ord(ch) < 91)) or 
	      ((ord(ch) > 96) and (ord(ch) < 123)) or (ch = ' ');

	{permit only lower case or capital letters, or a space}

	charsub[b]:=ord(ch);
	if ch = ' ' then write('-') else write(ch);
end;    {ouput a "-" instead of a space, so can see all characters}

writeln;
writeln;

match:=0;
 
	repeat
	i:=i+1.0;
	c:=c+1;
	read(input,b);
	if charsub[c] = b then match:=match + 1;

{the problem is that parts of the desired array may match at many locations }
{ in the file.  For example, if you were looking for the string RICHMOND, the}
{letters R I C might be present numerous times in the file. The ONLY time you} 
{want the program to acknowledge a match is when ALL the characters in the }
{array, match in the PROPER ORDER.  So when the first character matches, you}
{start counting...if the next character matches, you continue to count. If}
{it does not, start over-- When the count = the length of the array, then}
{(1) all the characters in the desired array are present in the file AND}
{(2) they appear in the file in the SAME ORDER as in the desired array..ie}
{a MATCH }

	if charsub[c] <> b then 
		begin
		match:=0;
		c:=0;
		end;
		
	if match = length then 
	begin	
	found:=true;
	write('ARRAY LOCATED AT:  ');  
	writeln('starting address: ',i-20.0:5:0,'   last address: ',i-1.0:5:0);
	writeln;
	writeln('If you plan to use these values for installing a new array');
	writeln('of characters into ',filename,'  then use: ');
	writeln('start = ',i-19.0:5:0,'  finish = ',i:5:0);
	writeln;
	writeln;
	if first_occurrence = false then match:=0;  
		{set up for next occurrence of string}
	end;


{The starting and last address are offset 100H (<) the address in DDT. 
 Remember that :
 (1) the program begins at 100H in DDT  and 
 (2) the first byte of memory is 0000H.  
 Hence, in the install program the start and finish must be 100H <
 the value of DDT PLUS 1, to allow for not starting at 0000H but at a
 decimal value of 1 }

  until (eof(input)) or ((match = length) and (first_occurrence = true));

if (eof(input)) and (found = false) then writeln('Array not found in file. ');

writeln;
writeln;
repeat
write('Do you wish to locate another array of characters?  y/n  ');
keyin(ch);
until ch in ['y','n','Y','N'];
if (ch = 'n') or (ch = 'N') then continue:= false else 
			begin
			continue:= true;
			write(chr(27),'*',chr(0),chr(0),chr(0),chr(0));	
			end;			

end; {of continue}

1:
end.