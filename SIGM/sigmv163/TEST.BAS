REM This is a program to test the linkage between CBAS2 and Assembly
REM language programs.
REM
REM	T E S T . B A S
REM

	SAVEMEM 01006H, "CBAS.TST"

1000	PRINT "This is the Basic portion of the CBASIC assembly language"
	PRINT " linkage."
	PRINT

	CALL 09200H

	PRINT
	PRINT "This is a return to the CBASIC interpreter"
	PRINT

	END
