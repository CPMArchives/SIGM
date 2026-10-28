PROGRAM MOVE;{$I+,M-,C-,F-}
TYPE 
BYTE=0..255;
VAR
X,Y:BYTE;


{procedure to move the cursor to any given x,y coordinates on the
terminal screen...command is for a soroc or televideo terminal}


PROCEDURE MOVE_CURSOR (X,Y:BYTE);
BEGIN
	WRITE(CHR(27),'=',CHR(Y+31),CHR(X+31));
END;
BEGIN END.