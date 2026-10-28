

PROGRAM INSTALL;{$P+}

{This program will install an array of characters into a .com file.  You}
{merely enter the beginning and ending address of the array, and the char-}
{acters you wish to insert.  No carriage return is needed when entering the}
{characters.  Use the program "locate" to determine the address of the array.}
{Since pascal/z limits the size of an integer to 32768, and the record number}
{must be an integer, I am not sure this will work if the array is located }
{beyond 32768 bytes...}
{Written by: Craig Rudlin, M.D.}

{$C-,M-,F-}
label 2;

CONST
index = 20;  {this is the only change needed to alter the length of the array}

TYPE
byte = 0..255;
F = file of  byte;
$string14 = string 14;

VAR
start, finish, I:integer;
INPUT:F;
C:char;
SUB:array[1..index] OF byte;
continue:boolean;
filename:$string14;

PROCEDURE KEYIN(VAR CIX:CHAR);EXTERNAL;


{************** READ FILE AND SUBSTITUTE VALUES ********************}
PROCEDURE PUT_VALUES( var start,finish:integer);
label 1;
begin
	
for I:= start to finish do read(INPUT:I,SUB[I-(start-1)]);
	write('     ');
	for I:=index downto 1 do     
		if SUB[I] = 32 then write('-') else
					  write(chr(SUB[I]));
		{32 = a space..want to visualize this so write a dash}

	writeln;
	write('---> ');
	for I:=index downto 1 do 
			{pascal stores the string backwards in com file}
			{e.g. notsob for boston; so must use downto}
			begin	      
			repeat
			keyin(C);
			until ((ord(C) >31) AND (ord(C) < 127)) OR 
				(ord(c) = 27) ;
{permit only entry of letters, numbers or printable symbols}
		
			if ord(c) = 27 then goto 1;  
{entering an esc keeps the array presently in the file unchanged}

			if C = ' ' then write('-') else write(C);
			SUB[I]:=ORD(C); {note use of an array to store values}
			end;

1:  for I:=start to finish do write(INPUT:I,SUB[I-(start-1)]);

end; {of procedure}

{************************* main program *************************************}
begin
continue:=true;
write(CHR(27),'*',CHR(0),CHR(0),CHR(0),CHR(0));   {clear screen}

writeln('PROGRAM TO INSTALL AN ARRAY OF CHARACTERS IN A .COM FILE ');
writeln;
writeln;
writeln('Enter the name of the .COM file you wish to alter. ');
write('Enter the name as DRIVE: NAME.COM:  ');
readln(filename);
	reset(filename,INPUT);
	if eof(input) then
		begin
		writeln;
		writeln('ERROR:  FILE NOT FOUND ON DISK! ');	
		goto 2;
		end;

while continue do
begin
write(CHR(27),'*',CHR(0),CHR(0),CHR(0),CHR(0));   {clear screen}
writeln('When prompted, enter the array of characters you wish to install   ');
writeln;
writeln('You must enter all ',index:2,' characters. ');
writeln;
writeln('The characters may be any displayable letter, numeral or symbol  ');
writeln;
writeln('NOTE: The program will display a space as a ''-''; do NOT enter ');
writeln('      a carriage return after you type each character !  ');
writeln;
writeln('      Entering an ESC will cause the program to leave the array ');
writeln('      presently in the file unchanged.');

writeln('      If you make a mistake, complete the entry, ask the program ');
writeln('      to allow you to make another alteration, and then re-enter ');
writeln('      the correct array of characters.');
writeln;
writeln;
write  ('Enter the starting "address" for the array:  ');
readln(start);
writeln;
write('Enter the final "address" for the array:  ');
readln(finish);
writeln;
if (finish -start + 1) <> index then
	begin
	writeln;
	writeln('ERROR: addresses do not match the length of the array!' );
	goto 2;
	end;

writeln('FILE CURRENTLY CONTAINS THE FOLLOWING ARRAY AT THIS LOCATION: ');
put_values(start,finish);
writeln;
repeat
write('Do you wish to make another alteration to ' ,filename,'  ? y/n  ');
keyin(c);
until c in ['n','y','N','Y'];
if (c = 'y') or (c = 'Y') then continue:= true else continue:=false;

end; {of while}
2:
END.
