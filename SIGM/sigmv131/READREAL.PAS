FUNCTION char2real(inchar : CHAR;VAR out# :REAL):BOOLEAN;
{
Comment : converts a numeric character to its equivalent REAL value.
          If successful returns TRUE , else FALSE.
}
VAR testchar : BOOLEAN;
BEGIN
 testchar  := inchar IN ['0'..'9'];
 IF testchar THEN out# := ORD(inchar) - ORD('0');
 char2real := testchar;
END; { of : function char2real }

FUNCTION str2real(VAR inputstr  : str255;
		  VAR real#     : REAL) : BOOLEAN;
{
Comment : Parses a string that represents a real number and calculates
the corresponding value.Unlike the Pascal/Z parser it is not upset if
the string contains a period without a preceding zero. As of 9/15/82 I
have not yet incorporated checks to prevent floating input underflow
or overflow.These should be added in the future.
Requires :       FUNCTION  length;
                    "      index;
                    "      char2real;
                 PROCEDURE setlength;
}
VAR
	temp#,mult	: REAL;
	
        p,               { location of decimal point }
        e,               {   "      "  E [for exponential factor]}
	intpart,         {   "      " last CHAR before decimal point }
	dec1st,          {   "      "  1st    "  after decimal point }
	declast,         {   "      "  last   "    "   point but before E }
	explength,	 { number of CHARs in exponent including +/- }
	l,i,sig#s	: INTEGER;

	negative,good#	: BOOLEAN;

	newstr		: str255;

        digit		: CHAR;

PROCEDURE expone(n : INTEGER); { internal to str2real : used in factoring
                                 in the exponent term.}
VAR
	temp1,
	factor : REAL;
BEGIN
  factor := 1.0;
  good# := good# AND char2real(inputstr[n],temp#);
  IF (good# AND (temp# > 0.0))
  THEN for i := 1 TO TRUNC(temp#) DO factor := factor * ABS(mult);
  IF mult < 0 
     THEN BEGIN
           temp1 := real# / factor;
           temp1 := real# -  (temp1 * factor);
           real# := (real# + temp1)/factor;
          END
     ELSE real# := real# * factor;
END; { of : procedure expone }

BEGIN { str2real }
  real#    := 0.0;
  negative := FALSE;
  good#    := TRUE;
  l        := length(inputstr);
  IF inputstr[1] IN ['+','-']    { if a sign character used get the sign
                                   and then snip off the sign character! }
     THEN BEGIN
           negative := (inputstr[1] = '-');
           setlength(newstr,(l - 1));
           FOR i := 1 TO (l - 1) DO newstr[i] := inputstr[i + 1];
           inputstr := newstr;
          END;                   { now there is no + or - }
  l := length(inputstr);
  p := index(inputstr,'.');      { where is the decimal point? }
  e := index(inputstr,'E');
  IF e = 0 THEN e := index(inputstr,'e'); { is there an exponent ? }
  IF p > 0 THEN BEGIN
                 intpart := p - 1;
                 dec1st  := p + 1;
                 IF e > 0 THEN declast := e - 1 ELSE declast := l;
                END
           ELSE BEGIN
                 IF e > 0 THEN intpart := e - 1 ELSE intpart := l;
                 dec1st  := 0;
                 declast := 0;
                END;
  FOR i := 1 to l DO { look for any invalid characters in the string }
    BEGIN
     digit := inputstr[i];
     good# := good# AND
               ( (digit IN ['0'..'9']) OR
                 ((digit = '.') AND (i = p)) OR
                 ((digit IN ['E','e']) AND (e > 0) AND (i = e)) OR
                 ((digit IN ['+','-']) AND (e > 0) AND (i = (e + 1)))
               );
    END;
  IF good# THEN { start actual conversion here : IF string is ok! }
   BEGIN
    mult  := 1;
    FOR i := intpart DOWNTO 1 DO
             BEGIN   { calculate the value of the part to the left of period }
              good# := good# AND char2real(inputstr[i],temp#);
              IF good#
                 THEN BEGIN
                      real# := real# + (mult * temp#);
                      mult  := mult * 10;
                      END;
             END;
    mult := 1;
    IF (dec1st + declast) > 0
      THEN BEGIN { Calculate the value of the part to the right of period.
                   Note the recursive call to str2real.}
            setlength(newstr,(declast - dec1st + 5));
            i     := dec1st - 1;
            sig#s := 0;
            REPEAT
             i := i + 1;
             IF (inputstr[i] > '0') or (sig#s > 0)
                THEN BEGIN
                      sig#s         := sig#s + 1;
                      newstr[sig#s] := inputstr[i];
                     END;
            UNTIL (sig#s > 6) or (i = declast);
            newstr[sig#s + 1] := 'e';
            newstr[sig#s + 2] := '-';
            i := i - dec1st + 1;
            IF i < 10
               THEN BEGIN
                     newstr[sig#s + 3] := CHR(i + ORD('0'));
                     setlength(newstr,(sig#s + 3));
                    END
               ELSE BEGIN
                     newstr[sig#s + 3] := CHR((i DIV 10) + ORD('0'));
                     newstr[sig#s + 4] := CHR((i MOD 10) + ORD('0'));
                     setlength(newstr,(sig#s + 4));
                    END;
            good# := good# AND str2real(newstr,temp#);
            real# := real# + temp#;
           END; { of : calculating in the fractional part }
    IF e = 0 THEN explength := 0 ELSE explength := l - e;
    CASE explength OF        { Last step : factor in the exponent if present }
       0 : BEGIN
           END;              { no exponent.}
       1 : BEGIN             { only 1 char after the e : positive by default }
            mult := 10.0;
            expone(l);
           END;
       2 : BEGIN             { 2 char : signed or unsigned exponent ? }
             IF (inputstr[l - 1] = '-')
                THEN BEGIN
                      mult := -10.0;
                      expone(l);
                     END
                ELSE BEGIN
                      mult := 10.0;
                      expone(l);
                      IF inputstr[l-1] <> '+'
                         THEN BEGIN
                               mult := 100;
                               expone(l-1);
                              END;
                     END;
           END; { case explength = 2 }
       3 : BEGIN          { 3 char exponent : 1st MUST be the sign }
             good# := good# AND (inputstr[l - 2] IN ['+','-']);
             IF good#
                THEN BEGIN
                      IF inputstr[l-2] = '+'
                         THEN mult :=  10.0
                         ELSE mult := -10.0;
                      expone(l);
                      mult := mult * 10.0;
                      expone(l-1);
                     END;
           END; { case explength = 3 }
       ELSE  : good# := FALSE
     END; { of : case list for factoring in the exponent }
    IF negative THEN real# := 0 - real#;
  END; { of : conversion }
  str2real := good#;        
END; { of : function str2real }

FUNCTION readreal(VAR realvar : REAL) : BOOLEAN;

{
 Comment : Readreal allows a REAL variable to be input from the console 
 in a more forgiving and flexible manner than do  the Pascal/Z standard 
 READ and READLN utilities.It should be noted that the basically lousy
 error checking of Pascal is so because it was not originally conceived
 of as an interactive language.That is it was designed for a batch
 processing system that could not permit runtime correction of input
 errors.That does not,however excuse Ithaca's highly inconsistent methods
 of error trapping.
          Using readreal , the input REAL may have a period as the first 
 or second character,(e.g. .123 , or +.123 , or -.123) or be a null string
 (i.e.'',produced by hitting RETURN).If null ,the variable is set to 0 &
 the return value of the function readreal is FALSE.Otherwise the real is
 set to the input string equivalent and readreal returns TRUE.This allows
 you to set any other default value for a null by checking  ((readreal =
 FALSE) AND (realvar = 0.0)).(Pascal/Z has the  annoying habit of crashing 
 out of your program if you give such inputs to its READ or READLN utility).
 The conversion from STRING input to REAL uses the procedures str2real and
 char2real.
          On detecting invalid characters readreal gives an error message
 and loops,rather than crashing.
         Note that it is readreal that accepts the null string and str2real
 that accepts the period without a preceding zero.
         Hopefully at some time soon ITHACA will polish up the input error
 checking for REALS allowing this function to be eliminated or cut in size.
 
 Requires :                    FUNCTION  length;
                               FUNCTION  index;
                               PROCEDURE setlength;

}
VAR
	realstring	: str255;
        done		: BOOLEAN;


BEGIN { readreal }
 REPEAT
 READLN(realstring);
 IF LENGTH(realstring) = 0
  THEN BEGIN
        realvar  := 0.0;
        readreal := FALSE;
        done     := TRUE;
       END
  ELSE BEGIN
        readreal := TRUE;
        done     := str2real(realstring,realvar);
        IF NOT done THEN WRITELN('error in real input : try again.');
       END; { of : if length = 0 then..else... }
 UNTIL done;
END;   { of : procedure readreal }
