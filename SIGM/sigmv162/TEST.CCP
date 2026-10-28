PROGRAM DEMO;


VAR I : INTEGER;
    B : BOOLEAN;
    C : CHAR;
BEGIN   
   FOR I:= 1 TO 5 DO WRITELN('>',I,'<');
   I:= 100;
   B := TRUE;
   C := 'A';
   WRITE(I);
   WRITELN;
   WRITELN(I);
   WRITELN(C);
   WRITELN(B);
   WRITELN('>',C,'<');
END.

