PROCEDURE confine(VAR x_in,x_out : real_array;
			n,
			std_devs : INTEGER	);

VAR
	average,
	diffrnce,
	max		: REAL;
	datum		: INTEGER;

BEGIN
x_out[1]	:= x_in[1];
FOR datum := 2 TO (n - 1) DO BEGIN
 average	:= (x_in[datum - 1] + x_in[datum + 1])/2.0;
 diffrnce	:= x_in[datum] - average;
 max		:= std_devs * SQR(x_in[datum]);
 IF ABS(diffrnce) < ABS(max)
  THEN x_out[datum] := x_in[datum]
  ELSE BEGIN
   IF diffrnce > 0 
     THEN x_out[datum] := x_in[datum] - max
     ELSE x_out[datum] := x_in[datum] + max;
  END;  { of : IF ABS(... THEN.. ELSE }
 END;   { of : FOR loop }
 x_out[n]	:= x_in[datum];
END; { of : PROCEDURE confine }
