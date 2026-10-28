PROGRAM PROMPTX;{$I+,M-,C-,F-}
TYPE 
BYTE = 0..255;
$STRING255 = STRING 255;


PROCEDURE PROMPT (X,Y,LENGTH: BYTE; P:$STRING255;
	         PROTECTED_FIELD_DESIRED:BOOLEAN);

{procedure to position the cursor on the terminal, display a 
prompting message, and provide underline char for an answer}

VAR
UNDERLINE: STRING 255;
I:INTEGER;
BEGIN
	UNDERLINE:='_';
	FOR  I:= 1 TO LENGTH DO APPEND (UNDERLINE,'_');
	IF PROTECTED_FIELD_DESIRED = FALSE THEN
WRITE  (CHR(27),'=',CHR(Y+31),CHR(X+31),P,UNDERLINE)
	ELSE
WRITE (CHR(27),'=',CHR(Y+31),CHR(X+31),CHR(27),')',P,
	UNDERLINE,CHR(27),'(');
END;
BEGIN END.
