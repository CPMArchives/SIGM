PROCEDURE dateNtimeStamp(hardcopy   : BOOLEAN;
			 VAR device : TEXT);
{
written by G.M.ACLAND
COMMENT :
	Prints the date and the time as in the following example :
		    MONDAY OCTOBER 21 1999  13:25:01
If hardcopy is true then output will be to the file "device",otherwise 
output will be to the terminal.The following external routines are called :
PROCEDURES setlength,time,date,name_date and zeller &
FUNCTIONS  weekday#,dig2integer,str2integer,length and mid .
They , and their appropriate types and variables (n.b. especially the record
type "composite" ) , must be declared in the main program as must be the 
following types :
	str8 = STRING 8;str9 = STRING 9;str10 = STRING 10;
Note that this procedure was written primarily to use the clock chip
( OKI MSM5832 ) on the Godbout SS1 Board , via the time and date routines.
However it does not depend on that chip.Any other way of supplying the time 
and date in the correct format will do.Note also that if the date routine
supplies a value for the day of week number that is > 6 then the day of week 
will be calculated using the zeller procedure.
Note also that it is set up assuming that the date is in the 20th Century.If 
that is not true then a small change will be needed or code added to allow a
differrent century to supplied from outside this procedure.
Note also that the cursor or printhead is left at the end of the time and
date stamp (i.e.no carriage return appended).			}

TYPE
	str4		= STRING 4;

VAR
	timestring	: str8;
	yearname	: str4;
	monthname,
	dayname		: str9;
	datestring	: str10;
	ok		: BOOLEAN;
	error#,
	month#,
	year#,
	day#,
	day_of_week	: INTEGER;
	zeller#		: composite;

BEGIN
 timestring := '  :  :  ';
 datestring := '  /  /19  ';
 time(timestring);
 date(datestring,day_of_week);
 monthname := mid(datestring,1,2);
 ok	   := str2integer(monthname,month#,error#);
 dayname   := mid(datestring,4,5);
 ok	   := str2integer(dayname,day#,error#);
 yearname  := mid(datestring,7,10);
 ok	   := str2integer(yearname,year#,error#);
 name_date(month#,day#,year#,day_of_week,monthname,dayname);
 IF hardcopy
  THEN WRITE(device,dayname,' ',monthname,day#:3,' ',yearname,'  ',timestring)
  ELSE WRITE(dayname,' ',monthname,day#:3,' ',yearname,'  ',timestring);
END; { of : PROCEDURE dateNtimeStamp }
