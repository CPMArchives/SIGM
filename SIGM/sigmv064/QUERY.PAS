program queryx;
{$I+,m-,c-,f-}
type
byte = 0..255;
$string255 = string 255;

var
answer:char;
procedure move_cursor(x,y:byte);external;
procedure keyin (var cix:char);external;
FUNCTION QUERY(X,Y:BYTE;MESSAGE:$STRING255;BELL:BOOLEAN):BOOLEAN;

{function to move the cursor to position x,y, display an interrogative
 message, ring a bell to alert the operator, if desired, and then accept
 either an upper or lower case "y" or "n", in answer to the message.
 This function returns a boolean TRUE if the answer to the question is
 affirmative (yes).}


BEGIN
	REPEAT
	MOVE_CURSOR(X,Y);
	IF BELL = TRUE THEN WRITE(CHR(7),MESSAGE) ELSE WRITE(MESSAGE);
	KEYIN(ANSWER);
	WRITE(ANSWER);
	UNTIL ANSWER IN ['y','n','Y','N'];
	QUERY:= ( (ANSWER = 'Y') or (ANSWER = 'y') );
END;

begin end.