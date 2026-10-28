PROGRAM checks;
{ Pascal/z version--This is an update from Disk #15 of CheckBk(alias
  NOW). The author sez the interesting improvements are the availability
  of on-line changes in code assignments, and ability to edit and
  reconform the data stored in the file. He has had a little bug in
  the 'Dump' portion of the program. If it is selected from the menu
  it may or may not lose some data . So if anyone traps that bug be
  sure and let us know.}


CONST max_items = 300;
      max_codes = 50;
      max_add_code = 10;
      disk_file = 'A:CHECK82';
      left = 7;     { Number of digits to the left of the dp }
      right =  2;    {   "    "    "     "  "  right "  "  "  }

  { Number of bytes it takes to represent a fixed-point number  }
	bytes = (left + right + 1) div 2;

   {  Length of a fixed-point converted string  }
	maxchars = ((left * 4) div 3) + right + 3;

TYPE
	signtyp = (plus, minus);
	carrytyp = 0..1;

{ The basic unit of a fixed-point number, takes 1 byte of storage. }
	byte = 0..255;

	modetyp = (none, suplzer, supltzer, wdollar, wcomma, wboth);

  { This is the type around which this whole package is based.	 }
	fixed = record
		  sign: signtyp;
		  digits: array[1..bytes] of byte
		end;

{ This is a string type which holds a fixed-point number converted }
  { to ASCII. }
	fixstr = string maxchars;

	$STRING0 = STRING 0;
	$STRING255 = STRING 255;
     	item_data = RECORD
			item_number : INTEGER;
			month : INTEGER;
			day : INTEGER;
			year : INTEGER;
			amount : FIXED;
			description : STRING 30;
			code : INTEGER;
		    END;
VAR command : CHAR;
	code_description : ARRAY [1..max_codes] OF STRING 15;
	items : ARRAY [1..max_items] OF item_data;
        item_last : 1..max_items;
	data_file : FILE of item_data;
	lines_printed : 0..80;
	code_amount : ARRAY [1..max_codes] OF FIXED;
	entry_year : INTEGER;
	swaped : BOOLEAN;
	answer : CHAR;
	result : INTEGER;

{ This is set by the fixed point functions. It is set true if there }
{ was an overflow. }
	fixederror: boolean;

{ This is the carry flag. It is used by the fixed point functions. }
{ The user's code doesn't play with it. }
	carry: carrytyp;

(****************************************************************)
(*								*)
(* Ithaca InterSystems' Pascal/Z Fixed-Point Package            *)
(*								*)
(* Written by Robert Bedichek	  August 1980			*)
(*								*)
(****************************************************************)

procedure setlength( var y:$string0; x: integer ); external;
function length( x:$string255 ): integer; external;

(* The next two external functions are in LIB.REL and are automatically *)
(* linked in when the library is being linked in.  They add and 	*)
(* subtract two decimal digits packed into a byte using Z-80 decimal	*)
(* arithmetic.								*)
function addbyte( var carry: carrytyp; a, b: byte ):byte; external;
function subbyte( var carry: carrytyp; a, b: byte ):byte; external;

function add( a, b: fixed ): fixed;
(************************************************************************)
(* The value of this function is the signed sum of the two value	*)
(* parameters.	The global variable 'fixederror' is set if there was	*)
(* an overflow. 							*)
(*									*)
(*									*)
(*									*)
(************************************************************************)
var
	carry: 0..1;
	i: integer;
	res: fixed;

begin
  carry := 0;
  if a.sign = b.sign then   (* Like signs, just add	*)
    begin
      add.sign := a.sign;
      for i := 1 to bytes do
	add.digits[ i ] := addbyte( carry, a.digits[ i ], b.digits[ i ] );
      fixederror := (carry = 1)
    end
		     else   (* Unlike signs, subract negative op from pos.  *)
    begin
      fixederror := false;
      if a.sign = plus then
	for i := 1 to bytes do
	  res.digits[ i ] := subbyte(carry, a.digits[ i ], b.digits[ i ])
		       else
	for i := 1 to bytes do
	  res.digits[ i ] := subbyte(carry, b.digits[ i ], a.digits[ i ]);
      if carry = 0 then res.sign := plus
		   else
		     begin
		       res.sign := minus;
		       carry := 0;

(* Take nines complement of the result by subtracting it from zero.	*)
		       for i := 1 to bytes do
		res.digits[ i ] := subbyte( carry, 0, res.digits[ i ])
		     end;
      add := res
    end
end;

function sub( minuend, subtrahend: fixed ): fixed;
(************************************************************************)
(* The value of this function is the signed difference of the two	*)
(* value parameters.  The global variable 'fixederror' is set if the	*)
(* is an overflow.							*)
(*									*)
(*									*)
(*									*)
(************************************************************************)

begin

(* Just reverse the sign of the subtrahend and add.			*)
  if subtrahend.sign = plus then subtrahend.sign := minus
			    else subtrahend.sign := plus;
  sub := add( minuend, subtrahend )
end;



procedure shiftleft( var a: fixed );
(************************************************************************)
(* This procedure shifts all of the packed decimal digits in the	*)
(* passed parameter left one position.	A zero is shifted into the	*)
(* least significant position.	The digit shifted out is lost.		*)
(*									*)
(*									*)
(*									*)
(************************************************************************)
var
	i: integer;
	next: byte;

begin
  for i := bytes downto 1 do
    begin
      if i > 1 then next := (a.digits[ i - 1 ] div 16)
	       else next := 0;
      a.digits[ i ] := ((a.digits[ i ] * 16) + next) mod 256
    end
end;		(*	shiftleft	*)

procedure shiftright( var a: fixed );
(************************************************************************)
(* This procedure shifts all of the packed decimal digits in the passed *)
(* parameter right one position.  A zero is shifted into the most	*)
(* significant position.  The digits shifted out is lost.		*)
(*									*)
(*									*)
(*									*)
(************************************************************************)
var
	i: integer;
	next: byte;

begin
  for i := 1 to bytes do
    begin
      if i < bytes then next := (a.digits[ i + 1 ] mod 16) * 16
		   else next := 0;
      a.digits[ i ] := (a.digits[ i ] div 16) + next
    end
end;		(*	shiftright	*)







function fixtostr( a: fixed; mode: modetyp; trailing: byte ): fixstr;
(************************************************************************)
(* This function returns a formatted string.  The 'mode' parameter	*)
(* specifies which formatting operation is to take place.  The		*)
(* 'trailing' parameter specifies the maximum number of digits to the	*)
(* right of the decimal point that are to appear.			*)
(*									*)
(*									*)
(************************************************************************)
var
	i, j: byte;
	result: fixstr;

begin
  if trailing > right then trailing := right;

(* Make the 'result' string have 'maxchars' spaces		*)
  setlength( result, 0 );
  for i := 1 to maxchars do append( result, ' ' );

  result[ maxchars - right ] := '.';

(* Put the digits to the right of the dp into the string	 *)
  for i := maxchars downto maxchars - (right - 1) do
    begin
      result[ i ] := chr((a.digits[ 1 ] mod 16) + ord('0'));
      shiftright( a )
    end;

(* Leave 'trailing' digits to the right of the decimal point	*)
  for i := maxchars downto (maxchars - (right - trailing)) + 1 do
    result[ i ] := ' ';

(* Put the digits to the left of the dp into the string 	*)
  j := maxchars - right - 1;
  for i := maxchars - right - 1 downto maxchars - left - right do
    begin

(* Put a comma between every third digit if 'mode' tells us to	*)
      if ((((maxchars - right - 1) - i) mod 3) = 0) and
	 (i < (maxchars - right - 1)) and
	 (mode >= wcomma) then
			    begin
			      result[ j ] := ',';
			      j := j - 1
			    end;
      result[ j ] := chr((a.digits[ 1 ] mod 16) + ord('0'));
      j := j - 1;
      shiftright( a )
    end;


(* Suppress leading zeros if mode is anything other than 'none' *)
  j := j + 1;
  if mode > none then
    while ((result[ j ] = '0') or (result[ j ] = ','))
	  and (j < maxchars - right - 1) do
      begin
	result[ j ] := ' ';
	j := j + 1
      end;

(* Put a dollar sign in front of the most significant digit if	*)
(* 'mode' is 'wdollar' or 'wboth'				*)
  j := j - 1;
  if (mode = wdollar) or (mode = wboth) then
    begin
      result[ j ] := '$';
      j := j - 1
    end;

(* If the number being converted is negative put a minus sign in	*)
(* front of the dollar sign or (if there is no dollar sign) the most	*)
(* most significant digit.						*)
  if a.sign = minus then result[ j ] := '-';

(* If we are supposed to suppress leading and trailing zeros	*)
(* (mode = supltzer), suppress the trailing ones here.		*)
  if mode = supltzer then
    begin
      j := maxchars - ( right - trailing );
      while result[ j ] = '0' do
	begin
	  result[ j ] := ' ';
	  j := j - 1
	end
    end;
  fixtostr := result
end;		(*	fixtostr	*)

function strtofix( a: fixstr ): fixed;
(************************************************************************)
(* This converts the passed string to fixed point.  All characters	*)
(* other than the minus sign (-), decimal point(.), and the decimal	*)
(* digits (0123456789) are skipped over and ignored.			*)
(*									*)
(*									*)
(*									*)
(************************************************************************)
var
	rightcount, i: byte;
	righthalf: boolean;	(* True when scanning digits to right of dp  *)
	result: fixed;

begin
  righthalf := false;
  rightcount := 0;
  for i := 1 to bytes do result.digits[ i ] := 0;
  result.sign := plus;
  for i := 1 to length( a ) do
    if a[ i ] = '.' then righthalf := true
		    else
      if a[ i ] = '-' then result.sign := minus
		      else
       if (rightcount < right) and (a[ i ] <= '9') and (a[ i ] >= '0')
	 then
	   begin
	     shiftleft( result );
	     result.digits[1] := result.digits[1] + ord(a[i]) - ord('0');
	     if righthalf then rightcount := rightcount + 1
	   end;
    for i := rightcount to right - 1 do shiftleft( result );
  strtofix := result
end;		(*	strtofix	*)




PROCEDURE initialize;
{ set inital values }
VAR count : 0..max_items;
BEGIN
	item_last := 1;
	FOR count := 1 TO max_codes DO
	  code_description[count] := '               ';
	code_description[1]  := 'Balance forward';
	code_description[2]  := 'Deposit        ';
	code_description[3]  := 'NOW interest   ';
        code_description[4]  := 'Misc. add      ';
	code_description[11] := 'House payment  ';
	code_description[12] := 'Car payment    ';
	code_description[13] := 'Gas & Electric ';
	code_description[14] := 'Gasoline       ';
	code_description[15] := 'Credit cards   ';
	code_description[16] := 'Auto insurance ';
	code_description[17] := 'Entertainment  ';
	code_description[18] := 'Telephone      ';
	code_description[19] := 'Auto maint.    ';
	code_description[20] := 'Subscriptions  ';
	code_description[21] := 'Clothing       ';
	code_description[22] := 'Computer parts ';
	code_description[23] := 'Travel/hotels  ';
	code_description[24] := 'Contributions  ';
	code_description[25] := 'Misc auto      ';
	code_description[26] := 'Investments    ';
        code_description[27] := 'Education      ';                         
        code_description[28] := 'Water & sewer  ';
        code_description[29] := 'Taxes          ';
        code_description[30] := 'Books          ';
        code_description[31] := 'Food           ';
        code_description[32] := 'Drugs          ';
        code_description[33] := 'Medical service';
        code_description[34] := 'Tyme withdrawl ';
        code_description[35] := 'Misc insurance ';
        code_description[36] := 'Dental         ';
        code_description[37] := 'Pro tools/equip';
        code_description[38] := 'Pro subscript. ';
        code_description[39] := 'Pro books      ';
        code_description[40] := 'Auto Registrat.';
        code_description[41] := 'Slip rent      ';
        code_description[42] := 'Boat expenses  ';
        code_description[43] := 'Sewing/knitting';
        code_description[49] := 'Misc. subtract ';
        code_description[50] := 'Misc. expenses ';
END;

PROCEDURE newpage;
{ print form-feed and 2 blank lines }
BEGIN
        WRITELN(CHR(12));
        WRITELN;
        WRITELN;
        lines_printed := 0;
END;

PROCEDURE instructions;
{ print description of program operation }
VAR answer : CHAR;
    count  : INTEGER;
BEGIN
        newpage;
        WRITELN(' Checkbook program - For Wesley & Shirley Jenkins ');
        WRITELN(' Version 1.23 ');
        WRITELN;
        WRITE(' Want instructions ? ');
        READ(answer);
        WRITELN;
        IF (answer = 'Y') OR (answer = 'y') THEN
          BEGIN          
             newpage;    
             WRITELN(' -- Commands --');
             WRITELN;
             WRITELN(' A - Add an item');
             WRITELN(' R - Remove an item');
             WRITELN(' P - Print all items');
             WRITELN(' B - Print by balance');
             WRITELN(' S - Sort by date');
             WRITELN(' D - Dump to disk');
             WRITELN(' L - Load from disk');
	     WRITELN(' M - Modify an item');
             WRITELN(' Q - Quit');
	     WRITELN(' H - Hardcopy all items');
	     WRITELN(' I - Hardcopy instructions and codes');
	     WRITELN(' J - Hardcopy balance');
             WRITELN;
             WRITELN;
             WRITELN('Code        Description');
             FOR count := 1 TO 27 DO
                WRITE('-');
             WRITELN;
             FOR count := 1 TO 50 DO
                IF code_description[count] <> '              ' THEN
                   WRITELN(count:3,'        ',code_description[count]);
             END;
END;

PROCEDURE heading;
{ print heading for new page of item printout }
VAR  count : 0..79;
BEGIN
        WRITE(' Item     Date         Amount           Description');
        WRITE('              Code');
        WRITELN;
        FOR COUNT := 1 TO 79 DO WRITE('-');
        WRITELN;
END;

PROCEDURE item_print(count : INTEGER);
{ print data on one item }
BEGIN
        WITH items[count] DO
        BEGIN
        WRITE(item_number:5);
        WRITE(month:5,'/');
        IF day < 10 THEN
             WRITE('0',day:1) 
        ELSE
             WRITE(day:2);
        WRITE('/',year:2);
        WRITE(FIXTOSTR(amount,WBOTH,2));
        WRITE(' ',description);
        WRITE('  ',code_description[code]);
        END;
END;


PROCEDURE print_instructions;
{ Output to printer, commands & codes }
VAR file_out : TEXT;
    count : INTEGER;
BEGIN
  REWRITE('Lst:',file_out);
  WRITELN(file_out,CHR(12));
  WRITELN(file_out,' ------Commands---------------------- ');
  WRITELN(file_out,' A - Add an item');
  WRITELN(file_out,' R - Remove an item');
  WRITELN(file_out,' P - Print all items');
  WRITELN(file_out,' B - Print by balance');
  WRITELN(file_out,' S - Sort by date');
  WRITELN(file_out,' D - Dump to disk');
  WRITELN(file_out,' L - Load from disk');
  WRITELN(file_out,' M - Modify an item');
  WRITELN(file_out,' Q - Quit');
  WRITELN(file_out,' H - Hardcopy all items');
  WRITELN(file_out,' I - Hardcopy instructions and codes');
  WRITELN(file_out,' J - Hardcopy balance');
  WRITELN(file_out);
  WRITELN(file_out,'Code    Description');
  WRITELN(file_out,CHR(9),'---------------------------');
  FOR count := 1 TO max_codes DO
      WRITELN(file_out,count:3,'     ',code_description[count]);
  WRITELN(file_out);
  WRITELN;
END;

PROCEDURE print_all;
{ print data for all items in file }
VAR count : INTEGER;
BEGIN
        newpage;
        heading;
             FOR count := 1 TO item_last-1 DO
             BEGIN
             IF lines_printed = 20 THEN
                    BEGIN
                      newpage;
                      heading;
                    END;
             item_print(count);
             lines_printed := lines_printed +1;
	     WRITELN;
             END;	
        WRITELN;
END;

PROCEDURE hardcopy_heading;
{ prints hardcopy heading for printout }
VAR file_out : TEXT;
    count : INTEGER;
BEGIN
	REWRITE('Lst:',file_out);
        WRITELN(file_out,CHR(12));
	WRITE(file_out,' Item     Date        Amount           Description');
	WRITE(file_out,'              Code');
	WRITELN(file_out);
	FOR count := 1 TO 79 DO WRITE(file_out,'-');
	WRITELN(file_out);
	lines_printed := 3;
END;

PROCEDURE copy_all;
{ Hardcopys all items in file }
VAR count : 0..79;
    file_out : TEXT;
BEGIN
	hardcopy_heading;
         FOR count := 1 TO item_last-1 DO
         BEGIN
             IF lines_printed = 75 THEN
			hardcopy_heading;
             WITH items[count] DO  
	     BEGIN
		REWRITE('Lst:',file_out);
	     	WRITE(file_out,item_number:5);
		WRITE(file_out,month:5,'/');
		IF day < 10 THEN 
			WRITE(file_out,'0',day:1)
		ELSE
			WRITE(file_out,day:2);
		WRITE(file_out,'/',year:2);
		WRITE(file_out,FIXTOSTR(amount,WBOTH,2));
		WRITE(file_out,' ',description);
		WRITE(file_out,'  ',code_description[code]);
		WRITELN(file_out);
             END;	
        lines_printed := lines_printed +1;
        END;
END;

PROCEDURE print_balance;
{ Print totals by categories and net balance }
VAR item : 1..max_items;
    balance : FIXED;
BEGIN
        FOR item := 1 TO max_codes DO
          code_amount[item] := STRTOFIX('0');
        balance := STRTOFIX('0');
	FOR item := 1 TO item_last-1 DO
	  WITH items[item] DO
	    code_amount[code] := ADD(code_amount[code], amount);
	FOR item := 1 TO max_add_code DO
	  balance := ADD(balance, code_amount[item]);
	FOR item := max_add_code+1 TO max_codes DO
	  balance := SUB(balance, code_amount[item]);
	newpage;
	WRITELN('   Category             Amount');
	FOR item := 1 TO 32 DO
	  WRITE('-');
	WRITELN;
	FOR item := 1 TO max_codes DO
	  IF code_amount[item] <> STRTOFIX('0') THEN	 
   WRITELN(code_description[item],'  -',FIXTOSTR(code_amount[item],WBOTH, 2 ));
	FOR item := 1 TO 32 DO
	  WRITE('-');
	WRITELN;
	WRITELN('Balance          -',FIXTOSTR(balance, WBOTH, 2));
	WRITELN;
END;

PROCEDURE kopy_balance;
{ hardcopy balance sheet to printer }
VAR item : 1..max_items;
    balance : FIXED;
    file_out : TEXT;
BEGIN
        FOR item := 1 TO max_codes DO
          code_amount[item] := STRTOFIX('0');
        balance := STRTOFIX('0');
	FOR item := 1 TO item_last-1 DO
	  WITH items[item] DO
	      code_amount[code] := ADD(code_amount[code], amount);
	FOR item := 1 TO max_add_code DO
	  balance := ADD(balance, code_amount[item]);
	FOR item := max_add_code+1 TO max_codes DO
	  balance := SUB(balance, code_amount[item]);
	REWRITE('Lst:',file_out);
	WRITELN(file_out,CHR(12));
	WRITELN(file_out,'   Category               Amount');
	FOR item := 1 TO 32 DO
	  WRITE(file_out,'-');
	WRITELN(file_out);
	FOR item := 1 TO max_codes DO
	  IF code_amount[item] <>STRTOFIX('0') THEN	 
	   BEGIN
       	     WRITE(file_out,code_description[item],'  -');
	     WRITELN(file_out,FIXTOSTR(code_amount[item],WBOTH, 2 ));
	   END;
	FOR item := 1 TO 32 DO
	  WRITE(file_out,'-');
	WRITELN(file_out);
	WRITELN(file_out,'Balance          -',FIXTOSTR(balance, WBOTH, 2));
	WRITELN(file_out);
END;

PROCEDURE remove;
{ remove item from file }
VAR remove : CHAR;
    found,item : INTEGER;
    item_remove : INTEGER;
BEGIN
	found :=0;
	WRITELN;
	WRITE(' Remove item number - ');
	READ(item_remove);
	FOR item := 1 TO item_last-1 DO
	  IF items[item].item_number = item_remove THEN
	    found := item;
	WRITELN;
	IF found <> 0 THEN
	  BEGIN
	    heading;
	    item_print(found);
	    WRITELN;
	    WRITELN;
	    WRITE(' Remove ? ');
	    READ(remove);
	    IF (remove = 'Y') OR (remove = 'y') THEN
		BEGIN
		  FOR item := found TO item_last-1 DO
		    items[item] := items[item+1];
		  item_last := item_last-1;
		END;
	  END;
  IF found = 0 THEN
    WRITELN(' Item not in list.....');
END;

PROCEDURE entry;
{ console entry of check/deposit data }
VAR ch : CHAR;
    number : STRING 20;
BEGIN          
  REPEAT
    WITH items[item_last] DO
	BEGIN
	  description := '                          ';
	  WRITELN;
	  WRITE(' Item number ? ');
	  READLN(item_number);
	  WRITE(' Month ? ');
	  READ(month);
	  WRITE(' Date ? ');
	  READ(day);
	  WRITE(' Amount ? ');
	  READ(number);
	  amount := STRTOFIX(number);
	  WRITELN('               _____________________________');
	  WRITE(' Description ? ');
	  READLN(description);
	  WHILE LENGTH(description) <> 30 DO
	    APPEND(description,' ');
	  WRITE(' Code ? ');
	  READ(code);
	  year := entry_year;
	  WRITELN;
       END;
  heading;
  item_print(item_last);
  WRITELN;
  WRITELN;
  WRITE(' Correct ? ');
  READ(ch);
  UNTIL (ch ='Y') OR (ch = 'y');
  items[item_last+1] := items[item_last];
  items[item_last+1].item_number := 0;
  item_last := item_last+1;
  WRITELN;
END;

PROCEDURE modify;
{ modify a field in an item }
VAR found,item : INTEGER;
    number : STRING 20;
    name : STRING 30;
    item_modify : INTEGER;
    answer : CHAR;
    A,B,C,D,N,R : STRING 3;
BEGIN
  A:=CHR(27);
  B:=CHR(48);
  C:=CHR(64);
  APPEND(A,B);
  APPEND(A,C);
  N:=A;
  A:=CHR(27);
  B:=CHR(48);
  D:=CHR(80);
  APPEND(A,B);
  APPEND(A,D);
  R:=A;
  found := 0;
  WRITELN;
  WRITE(' Modify Item number - ');
  READ(item_modify);
  WRITELN;
  FOR item := 1 TO item_last-1 DO
   IF items[item].item_number=item_modify THEN
     found := item;
  WRITELN;
  IF found<>0 THEN
    BEGIN
      heading;
      item_print(found);
      WRITELN;
      WRITE(R,'I',N,'tem # ');
      WRITE(R,'M',N,'onth ');
      WRITE(R,'D',N,'ate     ');
      WRITE(R,'A',N,'mount   ');
      WRITE(R,'N',N,'ame or description      ');
      WRITELN(R,'C',N,'ode');
      WRITELN;
      WRITELN(' Modify one of the above fields ');
      WRITE(' Enter letter of the field to be changed?- ');
      READ(answer);
      WRITELN;
      CASE answer OF
	'I','i':BEGIN
		  WRITE(' New item number- ');
                  READLN(items[found].item_number);
		  WRITELN;
		END;
	'M','m':BEGIN
		  WRITE(' New month- ');
                  READ(items[found].month);
		  WRITELN;
		END;
        'D','d':BEGIN
		  WRITE(' New day- ');
      		  READ(items[found].day);
		  WRITELN;
		END;
	'A','a':BEGIN
		  WRITE(' New amount- ');
 		  READ(number);
		  WRITELN;
		  items[found].amount:=STRTOFIX(number);
		END;
	'N','n':BEGIN
		  WRITE(' New name or description- ');
		  READLN(name);
		  WRITELN;
		  WHILE LENGTH(name)<>30 DO
		    APPEND(name,' ');
		  items[found].description:=name;
		END;
	'C','c':BEGIN
		  WRITE(' New code #- ');
		  READ(items[found].code);
		  WRITELN;
		END;
	END;
  END;
END;

PROCEDURE swap_items(item : INTEGER ; VAR swaped : BOOLEAN);
{ exchange file data at location with location+1 }
BEGIN
  items[max_items] := items[item];
  items[item] := items[item+1];
  items[item+1] := items[max_items];
  swaped := TRUE
END;

PROCEDURE date_sort;
{ sort data file by date }
VAR finish , item : 0..max_items;
    date_first , date_second : REAL;
    item_first , item_second : INTEGER;
BEGIN
  finish := item_last-2;
  REPEAT
    swaped := FALSE;
    FOR item := 1 TO finish DO
	BEGIN
	  WITH items[item] DO
	   BEGIN
	     date_first := year * 10000.0 + month * 100.0 + day;
	     item_first := item_number;
	   END;
	  WITH items[item+1] DO
	    BEGIN
	      date_second := year * 10000.0 + month * 100.0 + day;
	      item_second := item_number;
	    END;
	  IF date_first > date_second THEN
	    swap_items(item,swaped);
	  IF (date_first = date_second) AND (item_first > item_second) THEN
	    swap_items(item,swaped);
	END;
      IF finish > 2 THEN
        finish := finish -1;
  UNTIL NOT swaped
END;

PROCEDURE dump;
{ write file of item information to disk }
VAR count : INTEGER;
BEGIN
  RESET(disk_file, data_file);
  REWRITE(disk_file,data_file);
  FOR count := 1 TO item_last DO
    WRITE(data_file,items[count]);
END;

PROCEDURE read_disk;
{ load data from disk to file }
BEGIN
  WRITELN;
  RESET(disk_file,data_file);
  item_last := 1;
  REPEAT
    READ(data_file,items[item_last]);
    WRITE('.');
    IF item_last MOD 10 = 0 THEN
      WRITELN;
    item_last := item_last + 1;
  UNTIL items[item_last-1].item_number = 0;
    item_last := item_last -1;
    WRITELN;
END;

PROCEDURE prog_commands;
{ console entry of program command }
BEGIN
    WRITELN;
    WRITE(' Command ? ');
    READ(command);
    CASE command OF
	'A','a' : entry;
	'B','b' : print_balance;
	'P','p' : print_all;
	'R','r' : remove;
	'S','s' : date_sort;
	'D','d' : dump;
	'L','l' : read_disk;
	'M','m' : modify;
	'H','h' : copy_all;
	'I','i' : print_instructions;
	'J','j' : kopy_balance;
	ELSE :
	IF (command = 'Q') OR (command ='q') THEN
	  WRITELN(' Leaving Program')
	ELSE
	  WRITELN(' Invalid command .....')
   END;
END;

{ Mainline Program }
BEGIN
    initialize;
    instructions;
    WRITELN;
    WRITE(' Enter year " 2-digit " for new entries - ');
    READ(entry_year);
    WRITELN;
    WRITELN;
    REPEAT
      prog_commands;
    UNTIL (command = 'q') OR (command = 'Q');
    WRITELN;
    WRITE(' Save file ? ');
    READ(answer);
    IF (answer ='Y') OR (answer = 'y') THEN
      dump;
END.
