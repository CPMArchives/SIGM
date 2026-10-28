.po 0
PROGRAM ERASE;
{ This program will erase only files that show in the directory. It will
not touch any file that is R/O or SYS. }


TYPE
	byte=0..255;
	string12=packed array [1..12] of char;

	registers=record
		a:0..255;		{ A register }
		bc,de,hl:integer	{ BC, DE, HL registers }
	end;
{**********************************************************************}

VAR
	currentdisk { disk user is logged into },
	dircode     { return code from CP/M }		:byte;

	found	:boolean;	{ found a directory file to delete }
	reg	:registers;
{**********************************************************************}

{ call is provided on Pascal/Z source disk.  CALL the memory
	location pointed to by 'address' with the values in the required
	registers. }

procedure call(var regs:registers;address:integer);external;

{***********************************************************************}

{* You can find the assembler source for peek and poke written by      *
 * Ray Penley in the PascalZ Users Group Newsletter #14, Sept., 1982   *
 * on page 5                                                           *}
 
function peek (address:integer):byte;external;

procedure poke (address:integer;abyte:byte);external;

{***********************************************************************}

procedure directory(var dircode:byte;var title:string12);
const
	srchfst=17;		{ CP/M function code = search first }
	srchnxt=18;		{ CP/M function code = search next }
	delfile=19;		{ CP/M function code = delete file }
	bdos=5;			{ CP/M BDOS entry point }
	eodir=255;		{ end of directory flag }
{=======================================================================}

var
	ch	:char;		
	fcb	:integer;	{ address of the file control block }		
	i	:byte;		{ indexer }
	dirptr	:integer;
	func	:integer;	{ function code to be passed to CP/M }
{========================================================================}

procedure search(var dircode:byte;func:integer);
begin
	fcb:=92;
	reg.de:=fcb;
	reg.bc:=func;
	call(reg,bdos);
	dircode:=reg.a
end;
{========================================================================}

{ This procedure does the actual deleting of files that are DIR and R/W. }
 
procedure eraser;
begin

{ If the high bit is set for any of the three characters used for file type
    then the particular file in question is not DIR and R/W. }

	if (peek(dirptr+9) < 128) and (peek(dirptr+10) < 128) and
		(peek(dirptr+11) < 128) then begin
	
	reg.de:=dirptr;
	reg.bc:=delfile;
	call(reg,bdos);		{ delete the file when DIR and R/W }
	dircode:=reg.a;

	found:=true		{ found a file to delete }
	
	end {if}
end;
{==========================================================================}

begin  {directory}
	found:=false;

{ First find out what drive the user is logged into and save }
	reg.a	:=0;
	reg.bc	:=25;		{ CP/M return current disk function }
	reg.de	:=0;		
	reg.hl	:=0000;
	call(reg,5);
	currentdisk:=reg.a;

{ set up the address at which we wish to leave anything that CP/M reads
   from the disk to 80H = 128 dec }	
	reg.a	:=0;
	reg.bc	:=26; 		{ CP/M set DMA address function}
	reg.de	:=128; 		{to 80H}
	reg.hl	:=0000;
	call(reg,5);
	
	fcb:=92;		{ set pointer to the default file control 
				block at memory location 5CH = 92 dec }
	
	for i:=1 to 12 do begin
		poke(fcb,ord(title[i]));
		fcb:=fcb+1
	end;

	func:=srchfst;
	search(dircode,func);

	func:=srchnxt;

{ set the directory pointer at the start of information received from the
  directory and erase DIR, R/W files }
	while dircode <> eodir do begin
		dirptr:=128 + (dircode*32);
		eraser;
		search(dircode,func)
	end {while}

end {directory};

{*******************************************************************}

{ Process the directory list for selected drive }

procedure list;
var	 
	title:string12;
	ch:char;
	i:byte;
{=====================================================================}

{ Converts all letters to uppercase }
function toupper(ch:char):char;
begin
	if ('a' <= ch) and (ch <= 'z') then
		toupper:=chr(ord(ch)-32)
	else
		toupper:=ch
end;
{=====================================================================}

begin { list procedure }

	title:='0???????????';	{ 12 chars. 1st char = drive unit }

{ I have inserted a clear screen for my terminal (an ADDS Regent 40)
  at this point }
	write(chr(12)); 
	writeln; writeln; 
	write('Erase directory files on what drive (A thru P)? ');
	readln(ch);
	ch:=toupper(ch);

{ Construct the proper binary unit identifier:
	1 = drive A
	2 = drive B
	.
	.
	16 = drive P                           }

	title[1]:=chr(ord(ch)-ord('@'));

{ Log on to the drive that files are to be deleted on }
	reg.a	:=0;
	reg.bc	:=14;		{ select disk }
	reg.de	:=ord(title[1]) - 1;
	reg.hl	:=0000;
	call(reg,5);

	writeln;

{ Repeat finding and erasing files until end of directory and no other
  files are found to delete. }
	repeat
		directory (dircode,title)
	until (found=false) and (dircode=255);

{ Return to the user logged in disk }
	reg.a	:=0;
	reg.bc	:=14;		{ select disk }
	reg.de	:=currentdisk;
	reg.hl	:=0000;
	call(reg,5)

end;

{*******************************************************************}

{ This is where the program begins. }

{$C+}{enable control-c from the keyboard}

BEGIN
	list
END.
