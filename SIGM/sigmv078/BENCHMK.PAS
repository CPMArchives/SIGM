PASCAL BENCHMARK LISTINGS BM1 to 9 

LISTINGS OF BM1 to BM8 FROM COMPUTING EUROPE JULY 27 1978

NOTE: The branch out of a nested "FOR" 
loop is not legal in Pascal/Z or in MT+


program bm1;
VAR k:integer;

BEGIN
	write('Start bm1');
	for k:=1 to 1000 do;
	write('e');
END.
                             
----------------------

program bm2;
VAR k:integer;

BEGIN         
	write('Start bm2');
	k:=0;
	REPEAT
		k:=k+1;
	UNTIL k=1000;
	write('e');
END.
                              
----------------------

program bm3;
VAR k,a:integer;

BEGIN
	write('Start bm3);
	k:=0;
	REPEAT
		k:=k+1;
		a:=k div k*k+k-k;
	UNTIL k=1000;
	write('e');
END.
                              
----------------------

program bm4;
VAR k,a:integer;

BEGIN
	write('Start bm4');
	k:=0;
	REPEAT
		k:=k+1;
		a:=k div 2*3+4-5;
	UNTIL k=1000;
	write('e');
END.
     
----------------------

program bm5;
VAR k,a:integer;
                        
procedure gosub;
BEGIN
END;

BEGIN
	write('Start bm5');
	k:=0;
	REPEAT
		k:=k+1;
		a:=k div 2*3+4-5;
		gosub;
	UNTIL k=1000;
	write('e');
END.

----------------------
                            
program bm6;
VAR l,k,a:integer;
m:array[1..5] of integer;

procedure gosub;
BEGIN
END;

BEGIN
	write('Start bm6');
	k:=0;
	REPEAT
		k:=k+1;
		a:=k div 2*3+4-5;
		gosub;
		for l:=1 to 5 do
	UNTIL k:=1000;
	write('e');
END.

----------------------

program bm7;
VAR l,k,a:integer;
m:array{1..5] of integer;

procedure gosub;
BEGIN
END;

BEGIN
	write('Start bm7');
	k:=0;
	REPEAT
		k:=k+1;
		a:=k div 2*3+4-5;
		gosub;
		for l:=1 to 5 do m[l]:=a;
	UNTIL k=1000;
	write('e');
END.

----------------------

program bm8;
VAR k:integer;
a,b,c:real;

BEGIN
	write('Start bm8');
	k:=0;
	REPEAT
		k:=k+1;
		a:=sqr(k);
		b:=ln(k);
		c:=sin(k);
	UNTIL k=100;
	write('e');
END.

----------------------

program bm9;
LABEL 1,2,3;
VAR k,l,m,n:integer;

BEGIN
	writeln('Start bm9');
	for n:=1 to 1000 do
	BEGIN
		for k:=2 to 500 do
		BEGIN
			m:=n mod k;
			l:=n div k;
			if l=0 then goto 2;
			if l=1 then goto 1;
			if m>0 then goto 1;
			if m=0 then goto 3;
		1:END;
		2:writeln(n);
	3:END;
	write('e');
END.

----------------------
