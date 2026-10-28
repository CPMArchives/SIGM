{********** Pascal/Z compiler options **********}
{$C-}{ control-c keypress checking OFF		}
{$M-}{ integer mult & divd error checking OFF	}
{********** Pascal/Z compiler options **********}



PROGRAM SuperMetrics;
{ PROGRAM TITLE: An Automatic Metric Conversion Program		}
{ WRITTEN BY:	 David A. Mundie				}
{								}
{ 12/15/82 - modified for Pascal/Z by Raymond E. Penley		}
{								}
{ SUMMARY:
	The program distinguishes rigorously between customary units,
 primary metric units, and secondary metric units. By "primary" metric
 units is meant the System International (SI) base units such as metre,
 kilogram, kelvin, and so on, as well as the derived units such as
 watt, newton, m/s, pascal, and volt.  By "secondary" metric units is
 meant units like degree C and km/h which are accepted but not part of
 SI, along with the formulas for derived units with special names, eg.
 kg m/s as the formulas for the newton.

	The program automatically converts customary and secondary units
 to primary units.  Primary units may be converted to customary by using
 the "c" command, while the "s" command converts them to secondary units.

 PREFIXES USED BY SUPERMETRIC FOR MEASURMENTS OTHER THAN VOLUMES & AREAS.

        power   prefix  abbreviation
	-----	------	------------
	10^18	exa	 E
	10^15	peta	 P
	10^12	tera	 T
	10^9	giga	 G
	10^6	mega	 M
	10^3	kilo	 k
	10^-3	milli	 m
	10^-6	micro	 u
	10^-9	nano	 n
	10^-12	pico	 p
	10^-15	femto	 f
	10^-18	atto	 a


 PREFIXES USED BY SUPERMETRIC FOR VOLUMES AND AREAS

        power   prefix  abbreviation
	-----	------	------------
	10^3	kilo	 k
	10^2	hecto	 h
	10^1	deka	 da
	10^-1	deci	 d
	10^-2	centi	 c
	10^-3	milli	 m

 DIFFERENCES BETWEEN SUPERMETRIC AND CORRECT System International (SI) SYMBOLS.

    correct SI form        SUPERMETRIC
	mu			u
	da			D
	.			* (multiplication)
	o			$ (degrees)
	m2, etc.		m2


}
CONST 
  CmdLine = 'COMMANDS: c(ustomary, h(elp, s(econdary, l(ist, f(inished';
  normp   = 'afpnum kMGTPE';	{ normal prefixes }
  specp   = 'mcd Dhk';		{ special prefixes for areas and volumes }
  maxentries = 100;
  z	  = 48;			{ ord('0')     }

TYPE 
  index		= 0..maxentries;
  strng		= STRING 40;
  entry		= RECORD
	            left,right: strng;
	            factor : real
	          END;

  string0	= STRING 0;
  string255	= STRING 255;

VAR 
  bell		: char;		{ console bell }
  curtop	: index;	{ current top of table }
  current	: index;	{ points to current entry }
  finished	: boolean;
  leftside	: boolean;
  line		: strng;	{ one line of user input }
  m		: real;		{ the measurement }
  maxcust	: index;	{ top of customary section of table }
  oldm,oldf	: real;
  p		: integer;	{ the precision }
  table		: ARRAY [ index ] OF entry;
  top		: index;	{ permanent top of table }
  u		: strng;	{ the unit }

{*********************** Utilities ******************************************}

FUNCTION length ( source: string255 ): integer;
	external;

FUNCTION pos ( PATTERN, SOURCE: string255 ): integer;
	external;

PROCEDURE delete ( var source: string0; start, count: integer );
	external;

PROCEDURE copy ( var sub: string0; source: string255; here, count: integer );
	external;

PROCEDURE insert ( pattern: string255; var dest: string0; posn: integer);
	external;

PROCEDURE concat ( var new: string0; arg1,arg2: string255 );
	external;

{*********************** mathematical utilities *****************************}

FUNCTION floor ( r: real ): integer;
BEGIN
  floor := trunc( r - ord( (r<0.0) AND (r<>trunc(r)) ) )
END;

FUNCTION nl ( a: real ): real;
BEGIN
  IF a < 1.0
     THEN nl := -LN( a )
     ELSE nl := LN( a )
END;

FUNCTION power ( i,j: integer ): real;
BEGIN
  power := exp ( nl(abs(i)) * j)
END;

FUNCTION log ( r: real ): real;
BEGIN
  log := nl(abs(r)) / LN(10.0)
END;

FUNCTION norm ( r: real ): real;
BEGIN
  norm := r / power(10,floor(log(r)))
END;


{************ convert a string to a real number *****************************}

FUNCTION value ( VAR s: strng; VAR p: integer ): real;
{ returns p = number of significant digits }
CONST 
  limit = 1.67772E6; { (2**23)/5) }
VAR 
  a,y : real;
  e,i,j,p2 : integer;
  neg, negexp, gtl : boolean;
  digits: SET OF char;

	FUNCTION val ( a : real; ch: char ): real;
	BEGIN
	  val := 10.0 * a + ord(ch)-z
	END{val};

BEGIN
  i := 1;
  p := 0;
  p2 := 0;
  gtl := false;
  digits := ['0'..'9'];
  append(s,'%'); { safety character }
  a := 0.0;
  e := 0;
  neg := (s[i]='-');
  WHILE s[i]=' ' DO
     i := i + 1;
  IF (s[i]='+') OR (neg) THEN
     i := i + 1;
  WHILE s[i] IN digits DO BEGIN
     IF s[i]='0' THEN
        p2 := p2 + 1
     ELSE BEGIN
        p := p+p2+1;
        p2 := 0;
        gtl := true
     END;
     IF a<limit THEN
        a := val ( a, s[i] )
     ELSE
	e := e + 1;
      i := i + 1
  END;
  IF s[i]='.' THEN BEGIN
     p := p + p2;
     i := i + 1;
     IF NOT (s[i] IN digits) THEN BEGIN
        insert ( '0',s,i );
        i := i + 1
     END
  END;
  p2 := 0;
  WHILE s[i]='0' DO BEGIN
     p2 := p2 + 1;
     IF a<limit THEN BEGIN
        a := val ( a, s[i] );
        e := e - 1
     END;
     i := i + 1
  END;
  IF gtl THEN
     p := p + p2;
  WHILE s[i] IN digits DO BEGIN
     p := p+1;
     IF a<limit THEN BEGIN
        a := val ( a,s[i] );
        e := e - 1
     END;
     i := i+1
  END;
  IF (s[i] IN ['E','e']) THEN BEGIN
     i := i + 1;
     j := 0;
     negexp := (s[i]='-');
     IF (s[i]='+') OR negexp THEN
        i := i+1;
     WHILE s[i] IN digits DO BEGIN
        IF j<limit THEN
	   j := 10*j+ord(s[i]) - z;
        i := i +1
     END;
     IF negexp THEN
       e := e - j
     ELSE
       e := e + j
  END;
  y := a;
  IF neg THEN
     y := -y;
  IF e<0 THEN
     value := y/power(10,-e)
  ELSE IF e<>0 THEN
     value := y*power(10,e)
  ELSE
     value := y;
  WHILE s[i]=' ' DO
     i := i+1;
  copy ( s,s,i,length(s)-i)
END{value};


{************* Write a real in appropriate format and return a blank *********}

FUNCTION f ( r:real ): char;
CONST 
  width = 23;
VAR 
  intpart,decimals,floating: integer;
BEGIN
  intpart := floor(log(r));
  decimals := p - intpart - 1;
  IF (r>10000.0) OR (r<0.0001) THEN {floating point}
     write ( r:width )
  ELSE IF decimals <= 0 THEN {integer}
     write ( round(r): width )
  ELSE  {fixed point}
     write ( r:width:decimals );
  f := ' '
END;


{*************** Special handling for temperatures ***************************}

PROCEDURE temperature ( VAR m: real; b: boolean; fact: integer );
VAR d: integer;
BEGIN
  d := p - floor(log(m))-1;
  m := m + fact * 273.15 + fact * 186.52 * ord( b );
  p := d + floor(log(m)) + 1
END;


{*************** Find u in the table of units *******************************}

FUNCTION inlist: boolean;
VAR	t: strng;

	FUNCTION match ( s: strng ): boolean;
	BEGIN
	   match := ((u=s) OR (t=s))
	END;

BEGIN
  { start scan with left list }
  leftside := true;
  current := 1;
  t := u;
  IF length(t) > 1 THEN
     delete(t,1,1);
  WHILE (NOT(match(table[current].left))) and (current<=curtop) DO
     current := current + 1;
  IF current<=curtop THEN
     inlist := true
  ELSE BEGIN
     { scan the right list starting at the top working towards the bottom }
     current := curtop;
     leftside := false;
     WHILE (NOT(match(table[current].right))) and (current>0) DO
        current := current - 1;
     inlist := (current>0)
  END
END{inlist};


{*************** Add correct metric prefix **********************************}

PROCEDURE prefix ( m: real; u: strng );

	PROCEDURE pref ( a: strng; fac,term: integer );
	VAR i,range: integer;
	BEGIN
  	  range := floor ( log(m) / fac );
	  IF abs(range) > term THEN BEGIN
{***	     range := term * ( 1 - (2 * ord( (range<(-term)) )) ); ***}
	     range := term * ( 1 - (2 * ord( (range<=term) )) );
	  END;
	  m := m / power ( 10,(fac*range) );
	  IF range<>0 THEN BEGIN
	     a := a[range+term+1];
	    concat ( u,a,u );{ u := concat(a,u); }
	    writeln(f(m),u )
	  END
	END{pref};

BEGIN{prefix}
   IF pos('2',u)=2 THEN
      pref(specp,2,3)
   ELSE IF pos('3',u)=2 THEN
      pref(specp,3,3)
   ELSE
      pref(normp,3,6)
END{prefix};


{******************** Convert to primary units *******************************}

PROCEDURE primary;
VAR oldp: integer;
BEGIN
  WITH table[current] DO BEGIN
     IF u='mpg' THEN
	m := 1.0 / m;
     IF length(u)=2 THEN
	IF (u[1]='$') AND (u[2] IN ['F','C']) THEN
	   temperature(m,(u[2]='F'),1);
     oldm := m;
     oldf := factor;
     oldp := p;
     p := p + ord( norm(m) * norm(factor) >= 10.0 );
     u := right;
     m := m * factor;
     writeln ( f(m),u );
     prefix(m,u);
     p := oldp;
     leftside := false
  END
END{primary};


{*************** check metric prefix and adjust if necessary *****************}

PROCEDURE normalize ( VAR m: real; VAR u: strng );
VAR s: strng;

 PROCEDURE depref ( a: strng; fac,term: integer );
 VAR	range,k  : integer;
	needspref: boolean;
 BEGIN
   needspref := ( floor( log(m)/fac )<>0 );
   IF pos(s,u)=2 THEN BEGIN
      range := term+1;
      FOR k:=1 TO length(a) DO BEGIN
         IF u[1]=a[k] THEN
	    range := k-term-1
      END;
      k := range+term+1;
      IF (k>=1) AND (k<=(term*2+1)) THEN BEGIN
         m := m * power ( 10,fac*range );
         delete(u,1,1);
	 writeln( f(m),u )
      END
      ELSE
         writeln('illegal prefix ignored')
   END;
   IF needspref THEN
      prefix(m,u)
 END{depref};

BEGIN{normalize}
  WITH table[current] DO BEGIN
     IF leftside
	THEN s := left
	ELSE s := right
  END;
  IF pos('2',s) = 2 THEN
     depref(specp,2,3)
  ELSE IF pos('3',s)=2 THEN
     depref(specp,3,3)
  ELSE
     depref(normp,3,6)
END{normalize};


{*************** Convert to customary or secondary units *********************}

PROCEDURE custandsec ( m: real );
VAR oldp: integer;
BEGIN
  WITH table[current] DO BEGIN
     oldp := p;
     p := p + ord( norm(oldm) * norm(oldf/factor) >= 10.0 );
     m := m / factor;
     IF (u='m3/m') AND (current<=maxcust) THEN
	m := 1.0 / m;
     IF u='K' THEN
	temperature ( m, (left[2]='F'), -1 );
     writeln ( f(m), left );
     IF current > maxcust THEN
	prefix ( m, left );
     p := oldp
  END
END{custandsec};


{********** Pascal/Z compiler options **********}
{$F-}{ floating point error checking OFF	}
{$R-}{ range checking OFF			}
{********** Pascal/Z compiler options **********}


{*********************** Set up the table ***********************************}

PROCEDURE initialize;

 PROCEDURE data ( L,R: strng; f: real );
 BEGIN
   curtop := curtop+1;
   WITH table[curtop] DO BEGIN
      left := L;
      right := R;
      factor := f;
   END
 END;

BEGIN{initialize}
   bell := chr(7);
   WITH table[0] DO BEGIN
      left := 'bottom';
      right := 'bottom';
      factor := 0.0
   END;

  curtop := 0;

       { CUSTOMARY UNITS/PRIMARY UNITS/CONVERSION FACTOR }
  data ( '$F',		 'K',		5.5556e-1 );
  data ( 'mpg',		 'm3/m',	2.352e-6 );
  data ( 'horsepower',	 'W',		7.355e2 );
  data ( 'inch of mercury', 'Pa',	3.37685e3 );
  data ( 'mph',		 'm/s',		4.4704e-1 );
  data ( 'yard',	 'm',		9.144e-1 );
  data ( 'yard2',	 'm2',		8.361274e-1 );
  data ( 'acre',	 'm2',		4047.0 );
  data ( 'barrel',	 'm3',		0.159 );
  data ( 'kCal',	 'J',		4.1868e3 );
  data ( 'BTU',		 'J',		1055.0 );
  data ( 'Curie',	 'Bq',		3.7e10 );

  maxcust := curtop;

       { SECONDARY UNITS/PRIMARY UNITS/CONVERSION FACTOR }
  data ( 'L',		 'm3',		1.0e-3 );
  data ( 'N/m2',	 'Pa',		1.0 );
  data ('L/100 km',	 'm3/m',	1.0e-8 );
  data ( 'm/h',		 'm/s',		2.777e-4 );
  data ('kW-h',		 'J',		3.6e6 );
  data ('$C',		 'K',		1.0 );
  data ('N*m',		 'J',		1.0 );

  data ( 'top','top', 0.0 ); { strings left & right must be initted }

  top := curtop
END{initialize};


{*************** Main subprograms *******************************************}

PROCEDURE give_help;
{ WRITTEN BY:	Raymond E. Penley	}
{ DATE WRITTEN:	Dec 15, 1982		}
BEGIN
writeln;
writeln(
 '   The program distinguishes rigorously between customary units,');
writeln(
 'primary metric units, and secondary metric units. By "primary" metric');
writeln(
 'units is meant the System International (SI) base units such as metre,');
writeln(
 'kilogram, kelvin, and so on, as well as the derived units such as');
writeln(
 'watt, newton, m/s, pascal, and volt.  By "secondary" metric units is');
writeln(
 'meant units like degree C and km/h which are accepted but not part of');
writeln(
 'SI, along with the formulas for derived units with special names, eg.');
writeln(
 'kg m/s as the formulas for the newton.');
writeln;
writeln(
 '    Primary units may be converted to customary by using the');
writeln(
 '"c" command, while the "s" command converts them to secondary units.');
writeln;
writeln('Enter commands like:');
writeln('Measure and unit>>5700 kJ');
writeln('           5.70000E+06 J');
writeln('                   5.7 MJ');
writeln;
writeln('Measure and unit>>secondary');
writeln('           5.70000E+06 N*m');
writeln('                   5.7 MN*m');
writeln;  
END{give_help};


PROCEDURE commands;
VAR i: integer;
BEGIN
  CASE line[1] OF
    'F','f':
	finished := true;

    'S','s':
	IF (inlist) AND (current>maxcust) AND  (NOT leftside) THEN
           custandsec(m);

    'H','h':
	give_help;

    'C','c':
	BEGIN
           curtop := maxcust;
           IF inlist THEN
             custandsec ( m );
           curtop := top
        END;

    'L','l':
	BEGIN
	   writeln( 'CUSTOMARY UNITS  PRIMARY UNITS  CONVERSION FACTOR' );
	   FOR i:=1 TO maxcust DO BEGIN
              WITH table[i] DO
                writeln ( left:15, ' ',right:15,' ',factor:15)
	   END;
	   writeln;
	   writeln( 'SECONDARY UNITS  PRIMARY UNITS  CONVERSION FACTOR' );
	   FOR i:=maxcust+1 TO top-1 DO BEGIN
              WITH table[i] DO
                writeln ( left:15, ' ',right:15,' ',factor:15)
	   END;
	END
   ELSE:
	BEGIN
	   writeln;
	   writeln( CmdLine )
	END
  END{case};
  writeln
END{commands};


PROCEDURE process;
BEGIN
  m := value ( line,p );
  u := line;
  oldf := 1.0;
  IF NOT inlist THEN
     writeln(bell, 'unit not available')
  ELSE BEGIN
     IF (current > maxcust) OR (NOT leftside) THEN
        normalize ( m,u );
     IF leftside THEN
	primary
  END;
  writeln
END{process};


BEGIN { SuperMetrics }
  finished := false;
  initialize;
  writeln(' ':22, 'SUPERMETRIC CONVERSION PROGRAM');
  writeln; writeln;
  writeln; writeln;
  writeln ( CmdLine );
  REPEAT
    writeln;
    write('Measure and unit >>');
    readln(line);
    IF (line[1] IN ['0'..'9','+','-']) THEN
       process
    ELSE
       commands
  UNTIL finished
END.
