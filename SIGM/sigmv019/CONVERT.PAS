
(*********************************************************************
:
:			CONVERT PROGRAM
:	
:	This was a class assignment in Introduction to Pascal.
:  It allows you to enter the price of Gas per liter and the
:  program will return the price of that gas per gallon.
:
:  June 30 1980			Charlie Foster
:
**********************************************************************)

PROGRAM convert;

VAR
	price, pricepg : real;
BEGIN
	WRITE('Enter current price per liter of gasoline-->  ');
	READLN(price);
	pricepg := price * 3.78;
	WRITELN('Price per gallon of gasoline=  ',pricepg)
END.
