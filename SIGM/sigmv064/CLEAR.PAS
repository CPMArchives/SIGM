{procedure to clear the screen of a soroc or televideo... essentially
sends an ESC 27...the chr(0) are nulls to slow it down and give the 
terminal time to respond}

PROCEDURE CLEAR_SCREEN;
BEGIN
WRITE(CHR(27),'*',CHR(0),CHR(0),CHR(0),CHR(0));
END;