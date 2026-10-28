EXTERNAL ATSMON::DTST;


{$I+}
function DTEST (DRIVE:char): INTEGER;
TYPE
     FI = FILE OF ARRAY [1..128] OF INTEGER;
     FILESTRING = string 14;
VAR
     CONTROL : ARRAY[1..128] OF INTEGER;

     TEST_ERRORS,
     Y,
     X    : INTEGER;
     F    : FI;
     REC:ARRAY[1..128] OF INTEGER;
     DR   : string 14;

function ERASE (OLD_FILE:filestring):boolean; external;

BEGIN
     DR := DRIVE;
     TEST_ERRORS := 0;
     APPEND(DR,':DELETE--.ME-');
     REWRITE(DR,F);

     FOR X := 1 TO 128 DO
     BEGIN
          REC[X] := MAXINT;
          CONTROL[X] := MAXINT
     END;

     FOR X := 1 TO 12 DO
          WRITE(F,REC);

     RESET(DR,F);
     FOR X := 1 TO 12 DO
     BEGIN
          READ(F,REC);
          IF REC <> CONTROL THEN
               TEST_ERRORS := TEST_ERRORS+1
     END;
     if ERASE(DR) then

END; 
.