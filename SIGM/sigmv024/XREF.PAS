(******************************************************
*
*	Donated to the Pascal/Z Users Group by Ithaca
*  Intersystems, Dec 1980.
******************************************************)

Program  xref; {$i+,e+,l- }
{ This is a quick and dirty program to do Pascal cross reference listings }
{ without regard to Pascal scoping rules. It has a minimum of comments and}
{ was intended for internal use only					  }
{ This program may die terribly if your program is not of correct Pascal  }
{ syntax. Each symbol which only occurs once is marked with an '*'.	  }
const tab = 9;
      cr  = 13;
      lf  = 10;
      blanks = '        ';
      symlen = 8;
      tabsize = 750;
      listsize = 10;

type  symbol = array[ 1..symlen ] of char;
      xreflist = record
		     nextlist: ^xreflist;
		     xreflines: array[ 1..listsize ] of integer;
		 end;
      $string255 = string 255;
      $string0	 = string 0;
      byte = 0..255;

var  i, j, linepos, symcnt: integer;
    caps,
    good_ctrl,	{ set of acceptable control characters }
    stop, stoppnum: set of char;
    tab_index: integer;
    entry: ^xreflist;

    { save all of the symbols in alphabetical order }
    symbols: array[ 1..tabsize ] of symbol;

    { for each symbol there is a list of references, this table has a }
    { pointer to the start of the list				      }
    xreftable: array[ 1..tabsize ] of ^xreflist;

    { count the number of references for the corresponding symbol }
    xctr:   array[ 1..tabsize ] of integer;

    { it is important to know the line number in order to xref }
    linectr: integer;

    firstchar: boolean; { is this the first character on this line }

    answer: char;

    { used in reading the Pascal program }
    already_read: boolean;
    one_ahead,
    curch: char;

    { the latest symbol extracted from the Pascal program }
    current_symbol: array[ 1..symlen ] of char;

    { input/output files }
    pasprog,
    xrefout: text;

    { for constructing file names }
    filnam: string 50;

{ do a binary search for the current identifier, if found return the index }
{ and set the function return value to TRUE.				   }
{ if not found set index to correct insertion point.			   }
function  bsearch( var index: integer ): boolean;
var i,j,k: integer;
    done: boolean;
begin
    i := 1;
    j := symcnt;
    done := false;
    repeat
	k := (j - i + 1) div 2 + i;
	if current_symbol < symbols[ k ] then j := k - 1
	else if current_symbol > symbols[ k ] then i := k + 1
	else done := true
    until done or (i > j );
    index := k;
    if not done and (symbols[k] < current_symbol) then index := k + 1;
    bsearch := done
end;

{ get the next character }
{ convert ugly control control characters to spaces and convert upper case }
{ to lower case 							   }
procedure nextch;
begin
    if firstchar then linectr := linectr + 1;
    firstchar := eoln( pasprog );
    if already_read then begin
	curch := one_ahead;
	already_read := false
    end
    else if not eof( pasprog ) then begin
	read( pasprog, curch );
	{ convert ugly control chars to spaces }
	if (curch < ' ') and not(curch in good_ctrl) then curch := ' ';
	{ convert upper to lower case }
	if curch in caps then curch := chr( ord( curch ) + 32 );
    end;
end;

{ return the look-a-head character from the input stream }
function lookahead: char;
var temp: char;
begin
    if already_read then lookahead := one_ahead
    else begin
	temp := curch;
	nextch;
	one_ahead := curch;
	lookahead := curch;
	already_read := true;
	curch := temp
    end;
end;

{ find the next symbol skipping over quoted strings, comments, numbers and }
{ special symbols (i.e. <> )						   }
procedure  parse;
var i: byte;
begin
    { skip characters until we get one that can start an identifier or }
    { we hit the end of the file				       }
    repeat
	nextch;
	if curch = '''' then begin
	    repeat
		nextch
	    until curch = ''''
	end
	else if ((curch='(') and (lookahead='*')) or
		(curch = '{')  then repeat
	    repeat
		nextch
	    until (curch = '*') or (curch='}')
	until (lookahead = ')') or (curch='}');
    until not (curch in stoppnum) or eof( pasprog );
    i := 0;
    current_symbol := blanks;
    { read the identifier into current_symbol, ignoring characters which }
    { exceed the maximum symbol length					 }
    repeat
	i := i + 1;
	if i <= symlen then current_symbol[ i ] := curch;
	nextch;
    until curch in stop;
end;

{ add a cross reference entry to the table }
procedure add_xref( sym_index, ref_line: integer );
var ptrnum: integer;
begin
    entry := xreftable[ sym_index ];
    ptrnum := xctr[sym_index] mod listsize + 1;
    xctr[sym_index] := xctr[sym_index]+1;
    while (entry^.nextlist <> nil) do entry := entry^.nextlist;
    if ptrnum = 1 then
	begin
	    new( entry^.nextlist );
	    entry := entry^.nextlist;
	    entry^.nextlist := nil
	end;
    entry^.xreflines[ptrnum] := ref_line
end;


{ add the current symbol to the symbol table at position 'index' }
procedure  add_symbol( index: integer );
var i: integer;
begin
    symcnt := symcnt + 1;
    for i := symcnt downto index+1 do begin
	symbols[ i ] := symbols[ i-1 ];
	xctr[ i ] := xctr[ i-1 ];
	xreftable[ i ] := xreftable[ i-1 ];
    end;
    new( entry );
    xctr[index] := 1;
    xreftable[index] := entry;
    entry^.nextlist := nil;
    entry^.xreflines[1] := linectr;
    symbols[index] := current_symbol
end;

{ add an initial entry to the symbol table....these entries are the }
{ Pascal/Z reserved words.					    }
procedure init( res: symbol );
var i: integer;
    junk: boolean;
begin
    current_symbol := res;
    junk := bsearch( i );
    add_symbol( i )
end;

function  index( x, y: $string255 ): integer; external;
procedure  setlength( var x: $string0; y: integer ); external;

{
 start of program
}
begin
    writeln( 'XREF -- version 1a' );
    already_read := false;
    good_ctrl := [ chr( tab ), chr( cr ), chr( lf ) ];
    stop := [ chr( tab ),' ',':',',','+','-','/','*','(',')','=','.','>',
	      '<','{','}','[',']', '''', '^', ';'  ];
    stoppnum := stop + [ '0'..'9' ];
    caps := [ 'A'..'Z' ];
    repeat
	if eoln( 0 ) then write( 'File name -- ' );
	readln( filnam );
	linepos := index( filnam, '.' );
	if linepos <> 0 then setlength( filnam, linepos-1 );
	append( filnam, '.pas' );
	reset( filnam, pasprog );
    until not eof( pasprog );
    for i := 1 to tabsize do symbols[ i ] := '}       ';
    symcnt := 0;
    linectr := 0;
    firstchar := true;
    init( 'and     ' );
    init( 'array   ' );
    init( 'begin   ' );
    init( 'case    ' );
    init( 'const   ' );
    init( 'div     ' );
    init( 'do      ' );
    init( 'downto  ' );
    init( 'else    ' );
    init( 'end     ' );
    init( 'external' );
    init( 'file    ' );
    init( 'for     ' );
    init( 'forward ' );
    init( 'function' );
    init( 'goto    ' );
    init( 'if      ' );
    init( 'in      ' );
    init( 'label   ' );
    init( 'mod     ' );
    init( 'nil     ' );
    init( 'not     ' );
    init( 'of      ' );
    init( 'or      ' );
    init( 'packed  ' );
    init( 'procedur' );
    init( 'program ' );
    init( 'record  ' );
    init( 'repeat  ' );
    init( 'set     ' );
    init( 'string  ' );
    init( 'then    ' );
    init( 'to      ' );
    init( 'type    ' );
    init( 'until   ' );
    init( 'var     ' );
    init( 'while   ' );
    init( 'with    ' );
    while not eof( pasprog ) do
	begin
	    parse;
	    if current_symbol <> blanks then begin
		if bsearch( tab_index ) then add_xref( tab_index, linectr )
		else add_symbol( tab_index )
	    end;
	end;
    linepos := index( filnam, '.' );
    setlength( filnam, linepos-1 );
    append( filnam, '.xrf' );
    rewrite( filnam, xrefout );
    writeln( xrefout, 'Total identifiers = ', symcnt-38:1 );
    for j := 1 to symcnt do
	if xreftable[ j ]^.xreflines[ 1 ] <> 0 then begin
	    writeln( xrefout, ' ' );
	    write( xrefout, symbols[ j ], '  ' );
	    entry := xreftable[ j ];
	    for i := 1 to xctr[ j ] do
		begin
		    write( xrefout,
			   entry^.xreflines[(i-1) mod listsize + 1]:6 );
		    if (i mod 10 = 0) and (xctr[ j ] > i ) then begin
			writeln( xrefout );
			write(	 xrefout, '          ' )
		    end;
		    if i mod listsize = 0 then	entry := entry^.nextlist;
		end;
	    if xctr[ j ] = 1 then write( xrefout, '*' );
	end;
    write( 'Include reserved words? ' ); readln( answer );
    if answer in [ 'Y', 'y' ] then begin
	writeln( xrefout );
	writeln( xrefout );
	writeln( xrefout, 'Reserved words:' );
	for j := 1 to symcnt do
	    if xreftable[ j ]^.xreflines[ 1 ] = 0 then begin
		writeln( xrefout, ' ' );
		write( xrefout, symbols[ j ], '  ' );
		entry := xreftable[ j ];
		for i := 2 to xctr[ j ] do
		    begin
			write( xrefout,
				entry^.xreflines[(i-1) mod listsize + 1]:6 );
			if (i mod 10 = 0) and (xctr[ j ] > i ) then begin
			    writeln( xrefout );
			    write(	 xrefout, '          ' )
			end;
			if i mod listsize = 0 then entry := entry^.nextlist;
		    end;
	    end;
     end;
end.
