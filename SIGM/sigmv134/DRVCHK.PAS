
PROCEDURE DRVCHK( VAR DR:CHAR);

{      A PROCEDURE TO ENSURE THAT A CHARACTER TO BE USED
       AS A FILENAME PREFIX REFERS TO A LEGAL DRIVE.THE
       INTERNALLY DEFINED CONSTANT NUM_DRIVES SHOULD BE
       SET TO THE NUMBER OF LOGICAL DRIVES AVAILABLE.

       IF THE TRANSMITTED DRIVE-NAME IS ILLEGAL,THE USER
       IS ASKED TO SUPPLY ANOTHER LETTER,FROM THE CONSOLE.
       
       NOTE THAT THIS PROCEDURE RECURSIVELY CALLS ITSELF,
       AND WILL NOT EXIT UNTIL A LEGAL DRIVE-NAME IS INPUT.

       THE PASCAL/Z EXTERNAL PROCEDURE SETLENGTH MUST BE
       DECLARED IN THE MAIN PROGRAM.                            }


  CONST
       NUM_DRIVES = 2;

  TYPE
       DR_NAME = 'A'..'Z';
       COUNTER = 0..25;

  VAR
       DRIVE      : DR_NAME;
       LEGAL_NAME : BOOLEAN;
       DR_AGAIN   : CHAR;
       I          : COUNTER;
       ANSWER     : STRING 40;

BEGIN { DRVCHK }
  LEGAL_NAME:=FALSE;
  DRIVE:='A';
  I:=0;
  WHILE I < NUM_DRIVES 
        DO BEGIN
           I:=I+1;
           IF DR=DRIVE 
              THEN BEGIN
                   LEGAL_NAME:=TRUE;
                   I:=25
                   END
               ELSE DRIVE:=SUCC(DRIVE);
          END;
  IF NOT LEGAL_NAME
     THEN BEGIN
          WRITELN('WHICH DRIVE DO YOU WANT DATA WRITTEN TO ?');
          WRITE('DRIVE = ?',CHR(8));
          SETLENGTH(ANSWER,0);
          READ(ANSWER);
          DR_AGAIN := ANSWER[1];
          WRITELN;
          DRVCHK(DR_AGAIN);
          DR := DR_AGAIN;
          END;
  BLNKSCRN;
END;  { DRVCHK }
