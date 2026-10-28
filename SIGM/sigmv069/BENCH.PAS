(**************************************************
*
*		BENCHMARK PROGRAM
*
*  In the September issue of Byte, there was a article
* that claimed to benchmark 50 high level languages.
* This is the Pascal version they used. I wanted to see
* if I get the same results. So I am typing it in from
* page 182, listing 2. The algorithm is the most in-
* teresting part of it.
*
* Charlie Foster, September 1981
***************************************************)

(*Eratosthenes Sieve Prime number program*)

PROGRAM Prime;

CONST
	Size = 8190;
VAR
        Flags : ARRAY [0..Size] OF BOOLEAN;
	x,I, Prime, K, Count, Iter : INTEGER;

BEGIN
	WRITELN ('10 iterations');
	FOR Iter := 1 TO 10 DO 
	  BEGIN
	{initialize everything first}
	    Count := 0;

{article had= FillChar (Flags, Sizeof (Flags),CHR (TRUE));}
{But it should have had-----}

	    FOR x := 0 TO Size DO
	      Flags [x] := TRUE;

	    WRITELN ('Everything initialized--OK');	    		    

{back to the article--------}

	    FOR I := 0 TO Size DO
		IF Flags[I] = TRUE THEN 
		  BEGIN
			Prime := I+I+3;	
			K := I+Prime;
			WHILE K <= Size DO
			  BEGIN
				Flags [K] := FALSE;
				K := K+Prime
			  END;
			Count := Count + 1;
                	WRITE (Prime)
			
		  END;
	WRITELN  
	END;
	  WRITELN;
	  WRITELN ('There are ',Count:4,' Primes')
END.