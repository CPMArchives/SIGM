(****************************************************
*
*		PROGRAM FOR TRIG TABLE
*
*	Simple program to generate a short trig chart.
*  Written by Ray Penley while trying to overcome a
*  bug.
*
*  Donated Sept 1980
*******************************************************

PROGRAM TRIG4;
{	Computes the SIN, COS, and TAN of an angle "x",
+	expressed in radians, from 10 degrees to 85 degrees.
+
+	This program uses the supplied SIN function
+	but a new COSINE routine.			}
const
	{+ CONVERSION FACTOR DEGREES TO RADIANS +}
	C = 1.745329E-02; {+++ = PI/180   +++}
var	g: real;
	angle,rads : real;

FUNCTION COSINE(X:REAL):REAL; EXTERNAL;

function TAN(x: real): real;
{+  angle "x" must be in radians  +}
begin
  TAN := SIN(X) / COSINE(x);
end;

begin
  writeln('        SINE         COSINE        TANGENT',
		  '       RADIANS        DEGREES');
  g := 10.0;
  While (g < 90.0) Do
    begin
      writeln( SIN(g*c):8:6, COSINE(g*c):8:6, TAN(g*c):8:6, g*c:8:6, g:4:2);
      g := g + 5.0;
    end;
end.

