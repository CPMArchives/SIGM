{
        *        *******  *            *  *******   *
        *        *         *          *   *         *
        *        *          *        *    *         *
        *        ****        *      *     ****      *
        *        *            *    *      *         *
        *        *             * *        *         *
        *******  *******        *         ********  ********      }

PROCEDURE LEVEL (VAR BASELINE : BOOLEAN );

 CONST
     MAX_TILT = 5;
     LONGNUFF = 500;

 VAR
    LEFTX,
    LEFTY,
    RIGHTX,
    RIGHTY,
    UP_DOWN : INTEGER;
    DUMMY   : CHAR;
    TILT    : REAL;

BEGIN
  BLNKSCRN;
  CRSR(8,1);
  BASELINE := FALSE;
  WRITELN('         ROUTINE TO ADJUST ORIENTATION OF A DOCUMENT ON HIPAD :');
  WRITELN;
  WRITELN(' 1 : DEFINE A HORIZONTAL BASELINE ON YOUR DOCUMENT.');
  WRITELN(' 2 : SET THE DOCUMENT ON THE HIPAD SO THAT YOUR HORIZONTAL LINE');
  WRITELN('     IS PARALLEL TO THE X-AXIS OF THE HIPAD.');
  WRITELN(' 3 : LIGHTLY TAPE OR OTHERWISE SECURE DOCUMENT TO ENSURE THAT');
  WRITELN('     IT CANNOT SLIP.');
  WRITELN(' 4 : CHECK THAT HIPAD IS IN POINT MODE.');
  WRITELN;
  WRITELN(' 5 : WHEN YOU ARE READY , HIT ANY KEY TO START.');
  READQ(DUMMY);
  WRITELN;
  BLNKSCRN;
  REPEAT  { UNTIL BASELINE = TRUE }

   REPEAT  { UNTIL 0 = LEFTX AND LEFTY }
    BLNKSCRN;
    WRITELN('HIT RESET ON HIPAD.');
    WRITE('THE 1ST POINT TO BE TO ACQUIRED IS THE LEFTMOST END');
    WRITELN(' OF THE BASELINE');
    POINT(LEFTX,LEFTY)
   UNTIL ((0 = LEFTX ) AND (0 = LEFTY ));
  
   BLNKSCRN;
   WRITELN(' OK : ORIGON READ!  ');
   WRITELN;
  
   REPEAT { UNTIL RIGHTX  LONGNUFF}
    WRITE('THE 2ND POINT MUST BE ON THE BASELINE AND AT LEAST 5CMS');
    WRITELN(' FROM THE 1ST POINT');
    POINT(RIGHTX,RIGHTY);
    IF RIGHTX < LONGNUFF
       THEN WRITELN(' POINT WAS TOO CLOSE TO ORIGON.TRY AGAIN,PLEASE.')
   UNTIL (RIGHTX > (LONGNUFF - 1));

   UP_DOWN := ABS(RIGHTY);
   IF UP_DOWN < MAX_TILT
      THEN BASELINE  := TRUE
      ELSE BEGIN
          BLNKSCRN;
          TILT := 0.1*UP_DOWN;
          IF RIGHTY > 0
             THEN WRITE('RIGHT END TOO HIGH BY ')
             ELSE WRITE('RIGHT END TOO LOW BY ');
          WRITELN(TILT:7:1,' MM.');
          WRITELN;
          WRITELN('IF YOU ACCEPT THAT MUCH TILT : HIT Y');
          WRITELN('OTHERWISE HIT RETURN TO TRY AGAIN.');
          READQ(DUMMY);
          BASELINE:= (DUMMY='Y');
          IF BASELINE = FALSE THEN
             BEGIN
             BLNKSCRN;
             WRITELN('PLEASE READJUST DOCUMENT ON HIPAD. ')
             END;
          END;  { ELSE }
  UNTIL (BASELINE = TRUE);
END;{ OF PROCEDURE LEVEL. }
