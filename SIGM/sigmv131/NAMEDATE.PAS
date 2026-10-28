PROCEDURE NAME_DATE(	m,
			d,
			y 	: INTEGER;
		VAR day_of_week	: INTEGER;
		VAR monthname,
		    dayname	: STR9 );
{ COMMENT:
	Namedate accepts as input the date expressed as a set of integers.
	The month and day of the week will be named and returned in the
	corresponding strings.
	If the calling program transmits a number between 0 and 6 in the
	variable day_of_week , then this is assumed to be the day number,
	otherwise the day number will be determined using the zeller#
	algorithm , via the PROCEDURE weekday#.
	Note that if the zeller# is to be determined , then the number
	for the year must be complete (e.g. 1982 ,not 82).
	If something screws up and the day of week number or the month
	number ends up out of range , then the appropriate string will
	return as 'ERROR'.
}
VAR
	day#		: INTEGER;

BEGIN
writeln;
 IF day_of_week IN [0..6]
	THEN day# := day_of_week
	ELSE day# := weekday#(m,d,y);
 CASE day# OF
  0	: dayname := 'SUNDAY';
  1	: dayname := 'MONDAY';
  2	: dayname := 'TUESDAY';
  3	: dayname := 'WEDNESDAY';
  4	: dayname := 'THURSDAY';
  5	: dayname := 'FRIDAY';
  6	: dayname := 'SATURDAY';
  ELSE	: dayname := 'ERROR'
  END;
 CASE m OF
  1 	: monthname := 'JANUARY';
  2 	: monthname := 'FEBRUARY';
  3 	: monthname := 'MARCH';
  4 	: monthname := 'APRIL';
  5 	: monthname := 'MAY';
  6 	: monthname := 'JUNE';
  7 	: monthname := 'JULY';
  8 	: monthname := 'AUGUST';
  9 	: monthname := 'SEPTEMBER';
  10	: monthname := 'OCTOBER';
  11	: monthname := 'NOVEMBER';
  12	: monthname := 'DECEMBER';
  ELSE  : monthname := 'ERROR'
  END;
END; { of : PROCEDURE namedate }
