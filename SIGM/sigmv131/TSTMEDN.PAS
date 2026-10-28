PROGRAM tstmedn(0);
{$e+  [extended error messages ON] }
CONST
  bigeven#	= MAXINT - 1;
  big#		= 999.0;
  Max_N 	= 5000;
  control_c	= false;
TYPE
  varrecord	= RECORD
	CASE success : BOOLEAN OF
               TRUE    : ( mean,
                           mostfreq,
                           middle,
                           variance,
                           stddevtn,
                           stderrmn,
                           skewness,
                           kurtosis,
                           semedian,
                           seskewns,
                           sekurtss : REAL;
			   range    : ARRAY[1..2] OF REAL);
               FALSE   : ( errmsg1,
                           errmsg2,
                           errmsg3,
                           errmsg4  : BOOLEAN );
               END; { of : definition of type varrecord }
  index 	= 1..Max_N;
  Scalar 	= REAL;
  real_array	= ARRAY[index] OF scalar;
  list          = real_array;
  str8		= STRING 8;
  intarray	= ARRAY[1..55] OF INTEGER;
  byte		= 0..255;
VAR
  parameters	: varrecord;
  timestring	: str8;
  answer	: char;
  n,i,number	: INTEGER;
  result,mean	: scalar;
  A		: real_array;
  randarray	: intarray;
  randindex,
  seed		: INTEGER;
  good#		: BOOLEAN;

Procedure readq(VAR a:char);external;
Procedure time(VAR t:str8 );external;

FUNCTION rndknuth(VAR randarray : intarray) : byte;
{$c-,m-,f-,r-
comment : fills the array "randarray" with 55 pseudo random INTEGERS in
	  the range 0..bigeven#. Knuth originally specified 10^9 for
	  bigeven# . For Pascal/Z the best number = MAXINT - 1.
	  Requires the following definitions globally :
 CONST	bigeven#	= MAXINT - 1;
 TYPE	"intarray"	= ARRAY[1..55] OF INTEGER;
	"byte"		= 0..255;
 VAR	"randarray"	: "intarray";
	   Returns the value 1 ( for reinitializing index to "randarray").
}
VAR
	i,j,k	:  INTEGER;
BEGIN
 FOR i := 1 TO 55 DO
  BEGIN
    k := i + 31;
    IF k > 55 THEN k := k - 55;
    j := randarray[i] - randarray[k];
    IF j < 0 THEN j := j + bigeven#;
    randarray[i] := j
  END;
 rndknuth := 1;
END; { of : FUNCTION rndknuth }

PROCEDURE initknuth(VAR randarray : intarray;seed : INTEGER);
{$c-,m-,f-,r-
comment : Initializes randarray.Has the same requirements as rndknuth ,
	  which FUNCTION  is called by initknuth,plus the input value :
	  "seed" : this may be a zero,one or any other positive
	  INTEGER value.A useful technic when you want to use a "random"
	  seed is to create an integer from the time of day , if you have
	  it available to your computer.
}
VAR
	i,ii,j,k : INTEGER;
BEGIN
 randarray[55]	:= seed;
 j		:= seed;
 k		:= 1;
 FOR i := 1 TO 54 DO
  BEGIN
   ii := (21 * i) MOD 55;
   randarray[ii] := k;
   k := j - k;
   IF k < 0 THEN k := k + bigeven#;
   j := randarray[ii]
  END;
 i := rndknuth(randarray);
 i := rndknuth(randarray);
 i := rndknuth(randarray);
END; { of : PROCEDURE initknuth }

FUNCTION random#r : REAL;
{
comment : Returns a REAL pseudo random number in the range 0.0 .. 1.0.
	  Requires the definitions needed by rndknuth and  initknuth
	  plus the following global :
  VAR	randindex	: INTEGER;
}
BEGIN
 randindex := randindex + 1;
 IF randindex > 55 THEN randindex := rndknuth(randarray);
 random#r  := randarray[randindex]/bigeven#;
END; { of : FUNCTION random#r }

FUNCTION random#n : REAL;
{
comment : Returns a REAL number that is randomly selected from a normally
distributed population whose mean is zero and variance (and standard dev.)
is 1.0.
}
VAR
	n	: INTEGER;
	total	: REAL;
BEGIN
 total := -6.0;
 FOR n := 1 TO 12 DO total := total + random#r;
 random#n := total;
END; { of : function randomn }


procedure initseed;
{$c-,m-,f- }
BEGIN
 timestring := '  :  :  ';
 seed := 0;
 time(timestring);
 FOR i := 1 TO 8 DO seed := seed + ORD(timestring[i]);
END;

Procedure Show;
var
  i: index;
begin
  for i:=1 to N do
    begin
      write(A[i]:10:4);
      if i mod 6 = 0 then writeln;
    end;
  writeln;
end;

{$iB:SELECT.PAS }

{$iB:MEDIAN.PAS }


PROCEDURE popstats(VAR a          : list;
                   n1st,nlast     : INTEGER;
                   VAR parameters : varrecord); EXTERNAL;

BEGIN 
{$c+,m+,f+,r+  [Turn on checks for main program : disabled by median & select]}
 initseed;
 initknuth(randarray,seed);
 REPEAT { until control_c }
  repeat
    writeln;
    writeln('Enter number of items in array');
    writeln(' 10 <= n <= ',Max_N:5);
    write('?');
    readln(N);
    good# := (n > 9) AND (n <= Max_N - 1);
  until good#;

  writeln;
  writeln('Please stand by while I set up.');
  FOR i := 1 TO n DO
    BEGIN
      A[i] := random#n;
      if (i mod 1000 = 0) then write(i);
    END;
  writeln;
  write('random array filled : do you want to see it ?');
  readq(answer);
  writeln;
  IF answer IN ['y','Y'] then show;
  writeln;
  WRITE('Press return when ready to start');
  readq(answer);
  writeln;
  write( CHR(7), 'START @ ');
  time(timestring);
  write(timestring,' ');
  popstats(A,1,N,parameters);
  time(timestring);
  writeln( CHR(7), 'DONE @ ' ,timestring);
  WITH parameters DO 
    BEGIN
     writeln;
     IF success
      THEN BEGIN
        writeln('range   := ',range[1]:8:4,' to',range[2]:8:4);
        writeln('median             := ',middle:8:4);
        writeln('S.E. of median     := ',semedian:8:4);
        writeln('mode               := ',mostfreq :8:4);
        writeln('mean               := ',mean :8:4);
        writeln('variance           := ',variance :8:4);
        writeln('standard deviation := ',stddevtn :8:4);
        writeln('S.E. of the mean   := ',stderrmn :8:4);
        writeln('index of skewness  := ',skewness:8:4);
        writeln('S.E.  of skewness  := ',seskewns:8:4);
        writeln('index of kurtosis  := ',kurtosis:8:4);
        writeln('S.E.  of kurtosis  := ',sekurtss:8:4);
        writeln;
        END
       ELSE BEGIN
        writeln('SHIT!');
        END;
    END;
  write('Print the array (Y/N)?');
  readq(answer);
  writeln;
  If (answer='Y') or (answer='y') then Show;
  readq(answer);
 UNTIL control_c;
END.
