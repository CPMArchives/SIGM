PROGRAM EPSON; { This should work on any CP/M system with an Epson printer.}
	       { Writeln after BEGIN and before END has been used in place}
	       { of clear screen codes because of the many different }
	       { codes in use on various terminals.}
VAR
  PRINTER : TEXT;
  X : CHAR;

BEGIN
  WRITELN; WRITELN; WRITELN; WRITELN; WRITELN; WRITELN;
  WRITELN;
  WRITELN ('             ************************************************'); 
  WRITELN ('             *                                              *');
  WRITELN ('             *                  Special Print               *');
  WRITELN ('             *          Selection Menu for Epson Printer    *');
  WRITELN ('             *                                              *');
  WRITELN ('             *        1 - COMPRESSED PRINT - ON             *');
  WRITELN ('             *        2 - COMPRESSED PRINT - OFF            *');
  WRITELN ('             *        3 - EMPHASIZED PRINT - ON             *');
  WRITELN ('             *        4 - EMPHASIZED PRINT - OFF            *');
  WRITELN ('             *        5 - DOUBLE STRIKE - ON                *');
  WRITELN ('             *        6 - DOUBLE STRIKE - OFF               *');
  WRITELN ('             *        7 - LINE SPACING - 1/8TH INCH         *');
  WRITELN ('             *        8 - LINE SPACING - NORMAL (1/6TH)     *');
  WRITELN ('             *        0 - Exit to system                    *');
  WRITELN ('             *                                              *');
  WRITELN ('             ************************************************');
  WRITELN;
 REPEAT
  WRITE     (' Enter Your Selection: ');		     
  READ (X);
  CASE X OF
    '1': WRITE (PRINTER, CHR(15));
    '2': WRITE (PRINTER, CHR(18));
    '3': WRITE (PRINTER, CHR(27), CHR(69));
    '4': WRITE (PRINTER, CHR(27), CHR(70));
    '5': WRITE (PRINTER, CHR(27), CHR(71));
    '6': WRITE (PRINTER, CHR(27), CHR(72));
    '7': WRITE (PRINTER, CHR(27), CHR(48));
    '8': WRITE (PRINTER, CHR(27), CHR(50));
  END; 
  WRITE ('Another selection - or 0 to exit.');
 UNTIL X = '0';
WRITELN; WRITELN; WRITELN; WRITELN; WRITELN; WRITELN; WRITELN; WRITELN;
WRITELN; WRITELN; WRITELN; WRITELN; WRITELN; WRITELN; WRITELN; WRITELN;
WRITELN; WRITELN; WRITELN; WRITELN; WRITELN; WRITELN; WRITELN; WRITELN
END.
N; WRITELN; WRITELN; WRITELN; WRITELN; WRITELN;
WRITELN; WRITELN; WRIT