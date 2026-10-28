(************************************************
*
*		CHECKBK PROGRAM
*
*  It always shocks me when I do something I don't
* think I would ever do but when I was handed this 
* program from BYTE magazine I really scared myself.
* I sat down that same day and four hours later had
* it all typed in and debugged. As lazy as I am that
* set a record. I have never been know to stick to
* it that long. Ray Penley you would have been 
* proud of me.
*
*  I always like to give credit to the author of a 
* program but in this case I'll need help. BYTE blew
* it pretty bad during the Jan 1982 issue and lost
* a huge chunk of the West Coast's mail of their 
* issue. Furthermore, they refused to resend it.
* So this program was send to me on a poor paper
* copy. I was able to guess at the program because
* it had some logic to it but the Author I couldn't
* figure out. So whoever you are, I apologize. But
* this was in the Jan 1982 issue of Byte under the
* name of NOW. Pretty good job anyway.
* 
*  I wrote this in Pascal/Z and created a Data file
* to go along with the program. You can go into the
* source and change things but hang onto the data
* file. Otherwise, you'll have to compile twice.
* Once to comment out the READFILE procedure so you
* can run the program and create the disk data file.
* Then you'll have to put READFILE back in and re-
* compile.
*
*  How about you all improveing this thing and sending
* me the updates for the membership. I'll be 
* working on it.
*
* Charlie Foster, March 1982
**************************************************)
    
PROGRAM checkbk;

CONST
	maxItems = 300;
	maxCodes = 50;
	maxAddCode = 10;
	diskFile = 'a:DATA.82';
TYPE
	itemData = RECORD
		itemNumber : INTEGER;
		month      : INTEGER;
		day        : INTEGER;
		year       : INTEGER;
		amount     : REAL;
		description: STRING 30;
		code       : INTEGER;
		END;

	$STRING0 = STRING 0;
	$STRING255 = STRING 255;
VAR
	command 	: CHAR;
	ItemCode   : ARRAY[1..maxCodes] OF STRING 15;
	items  : ARRAY[1..maxItems] OF itemData;
	itemLast	: 1..maxItems;
	dataFile	: File of itemData;
	linesPrinted	: 0..80;
	codeAmount	: ARRAY[1..maxCodes] OF REAL;
	entryYear	: INTEGER;
	swaped		: BOOLEAN;
	answer		: CHAR;
	result		: INTEGER;

FUNCTION length (x:$STRING255) : INTEGER; EXTERNAL;

PROCEDURE initialize;	{this sets initial code values}

VAR
	count : 0..maxItems;
BEGIN
	ItemLast := 1;
	FOR count := 1 TO maxCodes DO
	  ItemCode[count] := '               ';
	
	{now we list the code items, can be changed}
{Family}
	ItemCode[1] := 'Zug Balance';
	ItemCode[2] := 'Family Balance';
	ItemCode[3] := 'Zug Deposit';
	ItemCode[4] := 'Family Deposit';
	ItemCode[5] := 'Zug Interest';
	ItemCode[6] := 'Family Interest';
	{ #'s 7,8,8,10 for future}
	ItemCode[11] := 'House Payment';
	ItemCode[12] := 'Car Lease';
	ItemCode[13] := 'Car Expenses';
	ItemCode[14] := 'Electricity';
	ItemCode[15] := 'Gas';
	ItemCode[16] := 'Credit Cards';
	ItemCode[17] := 'Insurance';
	ItemCode[18] := 'Telephone';
	ItemCode[19] := 'Contributions';
	ItemCode[20] := 'Water/Sewer';
	ItemCode[21] := 'Taxes';
	ItemCode[22] := 'Food';
	ItemCode[23] := 'Medical';
	ItemCode[24] := 'Misc.expenses';
{Pascal/Z}
	ItemCode[25] := 'Computer Lease';
	ItemCode[26] := 'Car Expenses';
	ItemCode[27] := 'Disks';
	ItemCode[28] := 'Printing';
	ItemCode[29] := 'Postage';
	ItemCode[30] := 'Books';
	ItemCode[31] := 'Software';
	ItemCode[32] := 'Printer Expen.';
	ItemCode[33] := 'Trip Expen.';
	ItemCode[34] := 'Equipment';
	ItemCode[35] := 'Misc.expenses';
	{ #'s 36 through 50 for future }

END;

PROCEDURE newpage;
	{ print form-feed and 2 blank lines}
BEGIN
	WRITELN(CHR(12));
	WRITELN;
	WRITELN;
	linesPrinted := 0;
END;

PROCEDURE instructions;
	{ print description of program operation}
	{ ADD my header program once debugged}
VAR
	pause,answer : CHAR;
	count        : INTEGER;
BEGIN
	newpage;
	WRITELN(' ':15,'THE (your name) CHECKBOOK PROGRAM');
	WRITELN(' ':24,'Version 1.0');
	WRITELN;
	WRITE('Do you want some instructions?  ');
	READ(answer);
	WRITELN;
	IF (answer = 'Y') OR (answer ='y') THEN
	  BEGIN
	    newpage;
	    WRITELN('-----------Commands------------');
	    WRITELN;
	    WRITELN('A - Add an item');
	    WRITELN('R - Remove an item');
	    WRITELN('P - Print all items');
	    WRITELN('B - Print Balance');
	    WRITELN('S - Sort by date');
	    WRITELN('D - Dump to disk');
	    WRITELN('L - Load from disk');
	    WRITELN('Q - Quit');
	    WRITELN;
	    WRITELN;
	    WRITELN ('Hit any key to continue---');
	    READLN (pause); 			
	    WRITELN('Code          Description');
	    FOR  count := 1 TO 27 DO
		WRITE('-');
	    WRITELN;
	    FOR count := 1 TO 50 DO
		IF ItemCode[count] <> '               ' THEN
		  WRITELN(count:3,'   ',ItemCode[count]);
	END;
END;


PROCEDURE heading;
	{print heading for new page of item printout}
VAR
	count : 0..79;
BEGIN
	WRITE(' Item     Date         Amount       ');
	WRITE('      Description              Code');
	WRITELN;
	FOR count := 1 TO 79 DO
	  WRITE('-');
	WRITELN;
END;

PROCEDURE itemPrint ( count : INTEGER);
	{ print data on one item}
BEGIN
	WITH items[count] DO
	  BEGIN
	    WRITE(itemNumber:5);
	    WRITE(month:5,'/');
	    IF day < 10 THEN
	      WRITE('0',day:1)
	    ELSE
	      WRITE(DAY:2);
	    WRITE('/',year:2);
	    WRITE(amount:14:2);
	    WRITE('    ',description);
	    WRITE('  ',ItemCode[code]);
	    END;
END;

PROCEDURE printAll;
	{ print data for all items in file}
VAR
	count : INTEGER;
BEGIN
	newpage;
	heading;
	FOR count := 1 TO itemLast-1 DO
	  BEGIN
	    IF linesPrinted = 55 THEN
		BEGIN
		  newpage;
		  heading;
		END;	
            itemPrint(count);
	    WRITELN;
	  END;
	WRITELN;
END;

PROCEDURE balance;
	{ print totals by categories and net balance }
VAR
	item : 1..maxItems;
	balance : REAL;
BEGIN
	FOR item := 1 TO maxCodes DO
	  codeAmount[item] := 0.00;
	balance := 0.00;
	FOR  item := 1 TO itemLast-1 DO
	  WITH items[item] DO
	  codeAmount[code] := codeAmount[code] + amount;
	FOR item := 1 TO maxAddCode DO
	  balance := balance + codeAmount[item];
	FOR item := maxAddCode + 1 TO maxCodes DO
	 balance := balance - codeAmount[item];
	newpage;
	WRITELN('   Category            Amount');
	FOR item := 1 TO 32 DO
	  WRITE('-');
	WRITELN;
	FOR item := 1 TO maxCodes DO
	  IF codeAmount[item] <> 0.00 THEN
WRITELN(itemCode[item],'  -',codeAmount[item]:14:2);
	FOR item := 1 TO 32 DO
	  WRITE('-');
	WRITELN;
	WRITELN('Balance          -',balance:14:2);
	WRITELN;
END;

PROCEDURE remove;
	{ remove item from file }
VAR
	remove : CHAR;
	found,
	item   : INTEGER;
	itemRemove : INTEGER;
BEGIN
	found := 0;
	WRITELN;
	WRITE(' Remove item number - ');
	READ(itemRemove);
	FOR item := 1 TO itemLast - 1 DO
	  IF items[item].itemNumber = itemRemove THEN
	    found := item;
	WRITELN;
	IF found <> 0 THEN
	  BEGIN
	    heading;
	    itemPrint(found);
	WRITELN;
	WRITELN;
	WRITE(' Remove ? ');
	READ(remove);
	IF (remove = 'Y') OR (remove = 'y') THEN
	  BEGIN
	    FOR item := found TO itemLast - 1 DO
	      items[item] := items[item + 1];
	    itemLast := itemLast - 1;
	   END;
	  END;
	IF found = 0 THEN
	  WRITELN(' Item not in list ...');
END;

PROCEDURE entry;
	{ console entry of check/deposit data }
VAR
	ch : CHAR;
BEGIN
	REPEAT
	  WITH items[itemLast] DO
	    BEGIN
	      description := '                              ';
	      WRITELN;
	      WRITE(' Item number ? ');
	      READLN(itemNumber);
	      WRITE(' Month ? ');
	      READ(month);
	      WRITE(' Date ? ');
	      READ(day);
	      WRITE (' Amount ?');
	      READ(amount);
	      WRITELN('               ------------------------------');
	      WRITE(' Description ? ');
	      READLN(description);
	      WHILE length(description) <> 30 DO
	        APPEND(description,' ');
	      WRITE(' Code ? ');
	      READ(code);
	      year := entryYear;
	      WRITELN;
	   END;
	heading;
	itemPrint(itemLast);
	WRITELN;
	WRITELN;
	WRITE(' Correct ?');
	READ(ch);
      UNTIL (ch = 'Y') OR (ch = 'y');
	items[itemLast + 1] := items[itemLast];
	items[itemLast + 1].itemNumber := 0;
	itemLast := itemLast + 1;
	WRITELN;
END;

PROCEDURE swapItems(item : INTEGER ;
		    VAR swaped : BOOLEAN);
	{exchange file data at location with location+1}
BEGIN
	items[maxItems] := items[item];
	items[item] := items[item + 1];
	items[item + 1] := items[maxItems];
	swaped := TRUE
END;

PROCEDURE dateSort;
	{ sort data file by date }
VAR
	finish,
	item       : 0..maxItems;
	dateFirst,
	dateSecond : REAL;
	itemFirst,
	itemSecond : INTEGER;
BEGIN
	finish := itemLast - 2;
	REPEAT
	  swaped := FALSE;
	  FOR item := 1 TO finish DO
	    BEGIN
	      WITH items[item] DO
		BEGIN
		  dateFirst := year * 10000.0 + month
			       * 100.0 + day;
		  itemFirst := itemNumber;
		END;
	     WITH items[item+1] DO
		BEGIN
		  dateSecond := year * 10000.0 + month
				* 100.0 + day;
		  itemSecond := itemNumber;
		END;
	     IF dateFirst > dateSecond THEN
		swapItems(item,swaped);
	     IF (dateFirst = dateSecond) AND
		(itemFirst > itemSecond) THEN
		swapItems(item,swaped);	 	
      	   END;
	IF finish > 2 THEN
	  finish := finish - 1;
     UNTIL NOT swaped
END;

PROCEDURE dump;
	{ write file of item information to disk }
VAR
	count : INTEGER;
BEGIN
	REWRITE(diskFile,dataFile);
	FOR count := 1 TO itemLast DO
	  WRITE(dataFile,items[count]);
END;

PROCEDURE readDisk;
	{ load data from disk to file}
BEGIN
	WRITELN;
	RESET(diskFile,dataFile);
	itemLast := 1;
	REPEAT
	  READ(dataFile,items[itemLast]);
	  WRITE('.');
	  IF itemLast MOD 10 = 0 THEN
	    WRITELN;
	  itemLast := itemLast + 1;
	UNTIL items[itemLast - 1].itemNumber = 0;
	  itemLast := itemLast - 1;
	  WRITELN;
END;

PROCEDURE progCommands;
	{ console entry of program command }
BEGIN
	WRITELN;
	WRITE(' Command ? ');
	READ (command);
	CASE command OF
	  'A','a' : entry;
	  'B','b' : balance;
	  'P','p' : printAll;
	  'R','r' : remove;
	  'S','s' : dateSort;
	  'D','d' : dump;
	  'L','l' : readDisk;
	ELSE:
	  IF (command = 'Q') OR (command = 'q') THEN
	    WRITELN ('Leaving Program')
	      ELSE
		WRITELN(' Invalid command...');
	END;
END;

{----------- MAIN ------------------}
BEGIN
	initialize;
	instructions;
	WRITELN;
	WRITE('Enter Year "2-digit" for new entries - ');
	READ(entryYear);
	WRITELN;
	WRITELN;
	readDisk;
	REPEAT
	  progCommands;
	UNTIL (command = 'Q') OR (command = 'q');
	WRITELN;
	WRITE(' Save file ?   ');
	READ(answer);
	IF (answer = 'Y') OR (answer = 'y') THEN
	  dump;
END.
