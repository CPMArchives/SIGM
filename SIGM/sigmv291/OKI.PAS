PROGRAM CPI;

VAR
  X : CHAR;
BEGIN
  CLRSCR;
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
  WRITELN;
  WRITE     ('  ENTER YOUR SELECTION: ');
REPEAT
  READ (X);
  CASE X OF
    '1': WRITE (LST, CHR (30));
    '2': WRITE (LST, CHR (29));
    '3': WRITE (LST, CHR (31));
    '4': WRITE (LST, CHR (27), CHR (54));
    '5': WRITE (LST, CHR (27), CHR (56));
  END;
   DELLINE;
   GOTOXY(1,23);
   WRITE ('Another selection - or 0 to exit.');
 UNTIL X = '0';
 CLRSCR
END.
