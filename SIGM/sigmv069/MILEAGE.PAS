(*===================================================

PROGRAM TITLE:  Mileage Statistics

AUTHOR:		William E. Lewis

ADAPATION BY:	Charlie Foster, Aug 1981

PROGRAM SUMMARY:

	This program processes Automobile odometer
readings and gas consumptions. It has been adapated
for Pascal/Z. The program terminates after the number
of odometer readings have been processed. It computes
Average miles per gallon, average miles between refills
and average gallons between refills.

===================================================*)

PROGRAM MileageStatistics;

VAR
  TotalMiles, TotalGallons,
  NumReadings, CurrentReading,
  NextOdometerValue, OdometerValue,
  GallonsAdded			     : INTEGER;

  MilesGallon, AvgMilesGallon,
  AvMileRefill, AvgGallonsRefill   : REAL;

BEGIN
  TotalMiles	:= 0;
  TotalGallons	:= 0;
  WRITE ('Please enter the number of reading you want--> ');
  READLN (NumReadings);
  WRITELN;  
  WRITE ('Please enter the first odometer reading--> ');
  READLN (OdometerValue);
  WRITELN;
  WRITELN ('Now enter the NEXT odometer reading and number ');
  WRITELN ('of gallons added. Do this ',NumReadings:2,'  times.');
  WRITELN (' ':20,'============MILES PER GALLON============');
  FOR CurrentReading := 1 TO NumReadings DO
    BEGIN
	READ (NextOdometerValue, GallonsAdded);
	MilesGallon := (NextOdometerValue-OdometerValue) /
			Gallonsadded;
	WRITELN (' ':37,MilesGallon);
	TotalMiles := TotalMiles + (NextOdometerValue-
			OdometerValues);
	TotalGallons := TotalGallons + GallonsAdded;
	OdometerValue := NextOdometerValue;
    END;	(* the FOR loop *)
  WRITELN (' ':20,'=======================================');
  AvgMilesGallon := TotalMiles / TotalGallons;
  WRITELN ('Your average miles per gallon =       ',AvgMilesGallon);
  AvMileRefill := TotalMiles / NumReadings;
  WRITELN ('Your average miles per refill =       ',AvMileRefill);
  AvgGallonsRefill := TotalGallons / NumReadings;
  WRITELN ('Your average gallons per refill =     ',AvgGallonsRefill);

END.
  