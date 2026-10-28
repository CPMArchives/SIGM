(*****************************************************
*
*	This can be put in your library or just used
*  as a source of random numbers. It was written by
*  Bob Harsch as a quickie.
*
* donated Sept 1980
***************************************************)

PROGRAM random;
var
  seed:0..65535;
  i:integer;

  Function Random:real;
   begin /* Random */
     seed:=(seed*13077+6925)mod 32768;
     random:=seed/32768.0
   end /* Random */;

begin
     seed:=trunc(time*1000.0);
        for i:=1 to 25 do writeln(trunc(random*6.0)+1)
end.
