EXTERNAL LINEAR::PRINT(1);

Procedure PRINTH;
begin
  writeln;
  writeln(' PROGRAM NAME = ', Pname);
  writeln(' Number of Rows   = ', M:6);
  writeln(' Number of Columns   = ', N:6);
  writeln
end(*---of PRINTH---*);

Procedure PRINTC( B : row ; C : col );
VAR	I : integer;
begin
  writeln;
  writeln('  ---Initial Data---');
  writeln;
  writeln(' Objective Vector, Cost of Feeds');
  writeln;
  For I:=1 to N do
    writeln( Colname[I]:22, C[I]:14:8 );
  writeln;
  writeln(' RHS Vector, Nutrient Requirements');
  WRITELN;
  For I:=1 to M do
    writeln( Rowname[I]:22, B[I]:14:8 );
  writeln
end(*---of PRINTC---*);

Procedure PRINTD;
VAR	I, J : integer;
begin
  writeln;
  writeln(' ABAR array');
  writeln;
  For J:=1 to N do
    For I:=1 to M do
      Writeln(I:6,J:6,'  ', Rowname[I]:22, Colname[J]:22, ABAR[I,J]:14:8);
  writeln;
  {writeln(' ABAR(M+1), ABAR(M+2)'); this section omitted as meaningless
  writeln;
  For I:=1 to N do
    writeln( Colname[I]:22, ABAR[M1,I]:14:8, ABAR[MP,I]:14:8 );}
  writeln
end(*---of PRINTD---*);

Procedure PRINTX;
VAR	I : integer;
	S : STRING 20;
begin
  writeln;
  writeln(' List and X Arrays');
  writeln('                         FEED               LBS (CWT)');
  writeln;
  For I:=1 to MP do
    begin
    S := '                    ';
    If (list[I]<=N) then S := Colname[ List[I] ];
    If I>M then S := Rowname[I] ;
    writeln( I:8,'  ', S:22, list[I]:7, X[I]:18:8 )
    end(*FOR*);
  writeln('               "M+1" is cost of ration times (-1)');
  writeln
end(*---of PRINTX---*);
 .
_8þ(G+++Ë†þ ËÆËŽ#Np+yÑÁþ É++Nwy+ËÆËÎï!IÃýRead beyon