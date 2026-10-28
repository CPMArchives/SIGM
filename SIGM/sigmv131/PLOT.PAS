



PROCEDURE PLOT(VAR M:INTEGER;VAR X,Y,YCALC:DATA_ARRAY);

{M is the number of data points in the transmitted arrays.}
{X is the array of the independent variable.}
{Y is the array of the dependent variable.}
{YCALC is the array of the Expected values of Y.}

{This procedure plots Y and YCALC as functions of X for M points.}
{If M is negative,only Y is plotted.}

{From: MILLER,A.R;PASCAL PROGRAMS FOR SCIENTISTS AND ENGINEERS      }
{          Berkeley,CA;SYBEX 1981;   p.146                          }

            {MODIFIED BY G.M.ACLAND:AUGUST 1981.}

CONST
   BLANK=' ';
   LINEL=51;

VAR
   YLABEL:ARRAY[1..6] OF REAL;
   OUT:ARRAY[1..LINEL] OF CHAR;
   LINES,I,J,JP,L,N:INTEGER;
   ISKIP,YONLY:BOOLEAN;
   XLOW,XHIGH,XNEXT,XLABEL,XSCALE,SIGNXS,
   YMIN,YMAX,CHANGE,YSCALE,YS10:REAL;

FUNCTION PSCALE(P:REAL):INTEGER;

BEGIN {PSCALE}
  PSCALE:=TRUNC((P-YMIN)/YSCALE + 1)
END {PSCALE};

PROCEDURE OUTLIN(XNAME: REAL);
{OUTPUT A LINE}

VAR
  I,MAX:INTEGER;

BEGIN {OUTLIN}
  WRITE(XNAME:8:2,'|') {LINE LABEL};
  MAX:= LINEL + 1;
  REPEAT  {SKIP BLANKS ON END OF LINE}
    MAX:=MAX-1
  UNTIL(OUT[MAX]<>BLANK)OR(MAX=1);
FOR I:=1 TO MAX DO
  WRITE(OUT[I]);
WRITELN;
FOR I:=1 TO MAX DO
  OUT[I]:=BLANK  {BLANK NEXT LINE}
END {OUTLIN};

PROCEDURE SETUP(INDEX:INTEGER);
{SETUP THE SYMBOLS FOR PLOTTING Y AND YCALC}

CONST
  STAR='*';
  PLUS='+';

VAR
  I:INTEGER;

BEGIN {SETUP}
  I:= PSCALE(Y[INDEX]);
  OUT[I]:=PLUS;
  IF NOT YONLY THEN
    BEGIN {SETUP FOR YCALC ALSO}
      I:=PSCALE(YCALC[INDEX]);
      OUT[I]:= STAR
    END  {SETUP FOR YCALC}
END {SETUP};

BEGIN  {MAIN PLOTTING ALGORITHM}
  IF M>0 THEN  {PLOT BOTH Y AND YCALC}
    BEGIN
      N:=M;
      YONLY:=FALSE
    END
  ELSE  {ONLY PLOT Y}
    BEGIN
      N:=-M;
      YONLY:=TRUE
    END;
{NOW SPACE OUT ALTERNATE LINES}
LINES:=2*(N-1)+1;
WRITELN;
XLOW:=X[1];
XHIGH:=X[N];
YMAX:=Y[1];
YMIN:=YMAX;
XSCALE:=(XHIGH-XLOW)/(LINES-1);
SIGNXS:=1.0;
IF XSCALE <0.0 THEN SIGNXS:=-1.0;
FOR I := 1 TO N DO
  BEGIN
    IF Y[I]<YMIN THEN YMIN:=Y[I];
    IF Y[I]>YMAX THEN YMAX:=Y[I];
    IF NOT YONLY THEN
      BEGIN
        IF YCALC[I]<YMIN THEN YMIN:=YCALC[I];
        IF YCALC[I]>YMAX THEN YMAX:=YCALC[I]
      END {IF YONLY}
  END;
YSCALE:=(YMAX-YMIN)/(LINEL-1);
YS10:=YSCALE*10;
YLABEL[1]:=YMIN  {Y AXIS};
FOR I:=1 TO 4 DO
  YLABEL[I+1]:=YLABEL[I]+YS10;
YLABEL[6]:=YMAX;
FOR I:=1 TO LINEL DO
  OUT[I]:=BLANK  {BLANK LINE};
SETUP(1);
L:=1;
XLABEL:=XLOW;
ISKIP:= FALSE;

WRITE('Y=');
FOR I:= 1 TO 6 DO
  WRITE(YLABEL[I]:8:1,'  ');
WRITELN;
WRITE(' ');
FOR I:= 1 TO 6 DO
  WRITE(' - - - -|-');
WRITELN;
WRITELN('     X  |');
WRITELN('     "  |');
FOR I:= 2 TO LINES DO  {SET UP A LINE}
  BEGIN
    XNEXT:=XLOW + XSCALE*(I-1);
    IF ISKIP THEN WRITELN('     -  |')
    ELSE
      BEGIN
       L:=L+1;
       WHILE
        (X[L]-(XNEXT-0.5*XSCALE))*SIGNXS <= 0.0
       DO BEGIN
         SETUP(L)  {SETUP PRINT LINE};
         L:=L+1
       END {WHILE LOOP};
       OUTLIN(XLABEL)  {PRINT A LINE};
       FOR J:=1 TO LINEL DO
         OUT[J]:= BLANK  {BLANK LINE}
    END {IF ISKIP BLOCK};
  IF (X[L]-(XNEXT+0.5*XSCALE))*SIGNXS>0.0
   THEN ISKIP:=TRUE
  ELSE
   BEGIN
     ISKIP:=FALSE;
     XLABEL:=XNEXT;
     SETUP(L)  {SETUP PRINT LINE}
   END
  END {FOR LOOP};
 OUTLIN(XHIGH)  {LAST LINE};
 WRITE(' ');
 FOR I:=1 TO 6 DO
   WRITE(' - - - -|-');
 WRITELN;
 WRITE(' ');
 FOR I:= 1 TO 6 DO
   WRITE(YLABEL[I]:9:1,BLANK);
 WRITELN;
END {PLOT};
