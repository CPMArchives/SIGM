PROGRAM dump;
{
*****************************************************************
*								*
*	Hex-Ascii file dump utility				*
*								*
*	Written by:	Bob Longoria				*
*			1024 Lawrence Dr. N.E.			*
*			Albuquerque, New Mexico 87123		*
*			(505)-298-7231				*
*								*
*	Description:						*
*	     This program is a slightly improved dump utility	*
*	over the standard dump program which comes with CP/M	*
*	distribution.  When dumping, the program will dump	*
*	both in hex (as done by dump.com) and in ascii and	*
*	at a standard CP/M sector (128 bytes) at a time.  Also	*
*	each sector is numbered beginning with sector 1.	*
*	     Output of the dump can be directed to any desired  *
*	file or output device.  For example:			*
*		zdump foo.rel	- dumps to the console		*
*		zdump foo.rel con:   - also dumps to console	*
*		zdump foo.rel lst:   - dumps to listing device  *
*		zdump foo.rel dumb.dmp   - dumps to a file	*
*			called dump.dmp			 	*
*								*
***************************************************************** }

CONST
    MAXARGS = 4;	{ Maximum command line arguments }
TYPE
    byte = 0..255;
    buffer = array[1..8,1..16] of 0..255;
    ch2 = packed array[1..2] of char;
    args = array[1..MAXARGS] of string 14;
VAR
    i	     : integer;		{ General purpose index variable }
    infile   : file of buffer;	{ The input file to be dumped }
    outfile  : text;		{ The output file to receive the dump }
    inbuf    : buffer;		{ Buffer which holds a standard sector }
    reccount : integer;		{ The current sector being processed }
    argc     : integer;		{ The number of command line arguments }
    argv     : args;		{ The command line argument array }

FUNCTION tohex(x : byte) : char;
{	Description:
 	receives a byte within the hex range (0-15) and returns
	the hex character equivalent. }
BEGIN
    case x of
	0,1,2,3,4,5,6,7,8,9 :
	    tohex := chr(x+ord('0'));
	{ If it is in this range, must be a letter character
	  of A-F }
        10,11,12,13,14,15:
	    tohex := chr(x+ord('A')-10);
    end
end;

FUNCTION cnvrthex(operand : byte) : ch2;
{	DESCRIPTION:
	This function takes a byte and converts it into it's
	two equivalent hex characters. }
VAR
    remain : byte;

BEGIN
    remain := operand-(operand div 16)*16;
    cnvrthex[2] := tohex(remain);	{ First hex character }
    operand := operand div 16;
    remain := operand-(operand div 16)*16;
    cnvrthex[1] := tohex(remain)	{ Second hex character }
END;

PROCEDURE display(recno : integer; inbuf : buffer);
{	DESCRIPTION:
	This routine takes care of displaying in both hex and
	ascii the input buffer (128 byte record). }
VAR
    i, j : integer;
    hexchar : ch2;

BEGIN
    { Begin by labeling the record number }
    write(outfile,recno:3,':  ');
    { This buffer is processed into 8 lines of output }
    for i := 1 to 8 do
	begin
	    { Each line has 16 bytes to process }
	    { Begin by writing out the hexidecimal equivalents
	      of each of the bytes }
	    for j := 1 to 16 do
	        begin
	            hexchar := cnvrthex(inbuf[i,j]);
		    write(outfile,hexchar,' ')
	        end;
	    { Now convert the same 16 bytes into their ascii eqivalents }
	    write(outfile,'  ');
	    for j := 1 to 16 do
	        begin
		    { If the byte is a non-printing character, sub-
		      stitute an ascii "." in its place }
		    if (inbuf[i,j] < 32) or (inbuf[i,j] > 126)
		        then write(outfile,'.')
		    { Otherwise print the actual ascii equivalent }
		    else
		        write(outfile,chr(inbuf[i,j]))
	        end;
	    writeln(outfile);
	    write(outfile,'      ')
	end;
    writeln(outfile)
END;

PROCEDURE cmdline(var count : integer; var token : args);
{	DESCRIPTION
	This routine performs several functions.  It reads
	the CP/M command tail if any and breaks the command 
	tail into tokens.  A token is any string of characters
	delimited by either the beginning of the command
	tail, the end of the command tail, or a space.  The
	routine returns the token count and all tokens found. }

VAR
    cmd_line : packed array[1..80] of char;
    i, j : integer;

BEGIN { cmdline }
    { Make sure the command line is clean }
    for i := 1 to 80 do
	cmd_line[i] := ' ';
    count := 0;
    { if the following is true there is a command tail, otherwise
      leave the count set to 0 and do not parse the command line }
    if not eoln(0) then
	begin
	    readln(cmd_line);
    	    i := 0;
    	    repeat
     		i := i+1;
		if cmd_line[i] <> ' ' then
	    	    begin
			count := count+1;
			j := 1;
			token[count,j] := cmd_line[i];
			while cmd_line[i+1] <> ' ' do
		    	    begin
				i := i+1;
				j := j+1;
				token[count,j] := cmd_line[i]
		    	    end { while }
	    	end { if }
    	    until i = 80
	end { if not eoln }
END; { cmdline }

BEGIN  { MAIN CODE }
    writeln;
    { Make sure command line arguments are clean }
    for i := 1 to MAXARGS do
	argv[i] := '              ';
    reccount := 1;	{ Begin numbering records at 1 }
    cmdline(argc,argv);	{ Get and parse the command line }
    if argc = 0 then
	writeln('No INPUT file specified')
    else if argc > 2 then
	writeln('Too many command line arguments')
    else
	begin
	    { Default output goes to the console }
	    if argc = 1 then
		argv[2] := 'CON:';
	    reset(argv[1],infile);
	    rewrite(argv[2],outfile);
    	    writeln(outfile,'                Hex-Ascii file dump -- Vers. 1.1');
    	    writeln(outfile);
	    { Process until EOF detected on input file }
            while not(eof(infile)) do
	        begin
	            read(infile,inbuf);
	            display(reccount,inbuf);
	            reccount := reccount+1
	        end
	end
END.
