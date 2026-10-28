PROGRAM CPI;

VAR
  PRINTER : TEXT;
  X : CHAR;
BEGIN
  WRITELN; WRITELN; WRITELN; WRITELN;
  WRITELN;
  WRITELN ('           ************************************************');
  WRITELN ('           *                                              *');
  WRITELN ('           *                  Special Print               *');
  WRITELN ('           *       Selection Menu for Okidata Printer     *');
  WRITELN ('           *                                              *');
  WRITELN ('           *            Character Spacing:                *');
  WRITELN ('           *                                              *');
  WRITELN ('           *        1 - NORMAL (80 MAX)                   *');
  WRITELN ('           *        2 - COMPRESSED (132 MAX)              *');
  WRITELN ('           *        3 - WIDE (40 OR 66 MAX)               *');
  WRITELN ('           *                                              *');
  WRITELN ('           *            Line Sapacing:                    *');
  WRITELN ('           *                                              *');
  WRITELN ('           *        4 - NORMAL (6 LPI)                    *');
  WRITELN ('           *        5 - COMPRESSED (8 LPI)                *');
  WRITELN ('           *                                              *');
  WRITELN ('           *        0 - Exit to system                    *');
  WRITELN ('           *                                              *');
  WRITELN ('           ************************************************');
  WRITELN;
 REPEAT
  WRITE     ('  ENTER YOUR SELECTION: ');
  READ (X);
  REWRITE ( 'LST:', PRINTER );
  CASE X OF    
    '1': WRITE (PRINTER, CHR (30));
    '2': WRITE (PRINTER, CHR (29));
    '3': WRITE (PRINTER, CHR (31));
    '4': WRITE (PRINTER, CHR (27), CHR (54));
    '5': WRITE (PRINTER, CHR (27), CHR (56));
  END;
   WRITE ('Another selection - or 0 to exit.');
 UNTIL X = '0';
WRITELN; WRITELN; WRITELN; WRITELN; WRITELN; WRITELN; WRITELN; WRITELN;
WRITELN; WRITELN; WRITELN; WRITELN; WRITELN; WRITELN; WRITELN; WRITELN;
WRITELN; WRITELN; WRITELN; WRITELN; WRITELN; WRITELN; WRITELN; WRITELN 
END.
; WRITELN; WRITELN; WRITELN; WRITELN; WRITELN;
WRITELN; WRITELN; WRITELN; WRITELN; WRITELN; WRITELN; WRITELN; WRITELN