FUNCTION dig2integer(input_character	: CHAR;
		     VAR output_number	: INTEGER) : BOOLEAN;

BEGIN
dig2integer := TRUE;
IF input_character IN ['0'..'9']
  THEN output_number := ORD(input_character) - ORD('0')
  ELSE dig2integer   := FALSE;
END; { of : FUNCTION dig2integer }

FUNCTION Str2Integer(InputString	: string255;
		     VAR output#,
		         error#		: INTEGER	) : BOOLEAN;
{ COMMENT:
	This function takes as input any PASCAL/Z string and , if the
 string is acceptable , returns the integer value equivalent in output#.
 Errors are reported in two ways : 
	If the function returns TRUE then no errors were detected.
	If the function returns FALSE :
		error# will = 1 if the string was too long to convert,
		or would have resulted in a number greater than MAXINT
		error# will = 2 if the string contained nonconvertable
		characters.
 N.B.The input string may be signed (i.e. first character = '+' or '-' )
  and may contain leading zeroes.
}
CONST	str2long	= 1;
	toobig		= str2long;
	bad_character	= 2;
VAR	stillvalid,
	overflow,
	negative	: BOOLEAN;
	value,
	multiplier,
	last_character,
	first_character,
	next_character  : INTEGER;
FUNCTION StringTooLong(instring : STRING255) : BOOLEAN;
{COMMENT:
	Checks the string's length for Str2Integer.
	Allows first character to be '0','+',or'-'.
	Allows leading zeroes.
	Returns true if more than 5 significant characters in string.
	Does not check completely for inappropriate characters or
        possibility of potential overflow.
}
CONST	ok	= TRUE;
VAR	leading_zeros,
	str_length	: BOOLEAN;
	string_length,
	char#		: INTEGER;
BEGIN
leading_zeros := TRUE;
string_length := length(instring);
IF string_length < 5 THEN StringTooLong := FALSE
   ELSE BEGIN
        FOR char# := 2 TO (string_length - 5) DO BEGIN
           leading_zeros := leading_zeros AND (instring[char#] = '0')
	   END;
	leading_zeros := leading_zeros AND (instring[1] IN ['+','-','0']);
	StringTooLong := NOT leading_zeros;
   END;
END; { of : FUNCTION StringTooLong }

BEGIN { FUNCTION Str2Integer }
Str2Integer	:= TRUE;
stillvalid	:= TRUE;
last_character := length(InputString);
IF last_character = 0 THEN output# := 0 ELSE BEGIN
 IF StringTooLong(InputString) THEN BEGIN
   Str2Integer   := false;
   error#	:= str2long;
   END
 ELSE BEGIN
   negative	:= InputString[1] = '-';
   IF last_character > 4 THEN first_character:= last_character - 4
     ELSE first_character := 1;
   output#	:= 0;
   multiplier	:= 1;
   FOR next_character := last_character DOWNTO first_character DO BEGIN
       overflow   := NOT( 
         	(multiplier < 10000) OR
		((multiplier = 10000) AND 
		((InputString[next_character] IN ['0'..'2']) OR
		((InputString[next_character] = '3') AND (output# < 2767)))));
       IF (next_character > first_character) OR
	(InputString[first_character] IN ['0'..'9']) THEN BEGIN
          stillvalid := stillvalid AND
		  Dig2Integer(InputString[next_character],value);
          IF stillvalid AND NOT overflow THEN BEGIN
            output#    := multiplier * value + output#;
            multiplier := multiplier * 10;
            END;  { of : IF stillvalid AND ...     }
	END;    { of : IF (next_character...   }
      END;    { of : FOR next_character    }
    IF stillvalid THEN BEGIN
        IF negative THEN output# := -output#;
      END
      ELSE BEGIN { i.e. at least one character was non-numeric }
        Str2Integer := FALSE;
        error#      := bad_character;
      END; { of : IF stillvalid }
    IF overflow THEN BEGIN
       Str2Integer := FALSE;
       error#      := toobig;
       END;
    END;   { of : IF StringTooLong .. ELSE BEGIN...  }
  END;     { of : IF last_character = 0 ...ELSE BEGIN...}
END; { of : FUNCTION Str2Integer }
