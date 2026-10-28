PROGRAM ERASEZ;{$I+,V-,M-,F-}
TYPE
BYTE = 0..255;

{procedure to erase lines on the terminal screen starting at 
a given line and for a given number of lines}


PROCEDURE ERASE_LINES(STARTING_LINE,NUMBER_OF_LINES:BYTE);

VAR
I:INTEGER;
BLANKS:STRING 80;Š
BEGIN

BLANKS:='                                                ';{40SPACES}
FOR  I:= 1 TO NUMBER_OF_LINES DO
	BEGIN
	WRITE(CHR(27),'=',CHR(STARTING_LINE+31),CHR(32),BLANKS,BLANKS);
	STARTING_LINE:=STARTING_LINE + 1;
	END
END;
BEGIN END.