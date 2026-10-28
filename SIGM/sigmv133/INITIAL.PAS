EXTERNAL LINEAR::INITIAL(2);

Procedure INITIAL;
{$E+}
VAR	Rcd,		{Record counter}
	I,J : integer;
	sum : real;
	XEOF,		{End of File flag for a NON text File}
	firstin : boolean;
	B : ROW;
	C : COL;
begin
  For I:=1 to maxrow do
    For J:=1 to maxcol do ABAR[I,J] := 0.0 ;
  firstin := false;
  Rcd := 0;{start at the beginning}
  READ(fa:Rcd+bias, F);
  XEOF := (F.tag=99);
  If F.tag=0 then
    begin
      firstin	:= true;
      Pname	:= F.name;
      M		:= F.num1; {No. Rows}
      N		:= F.num2; {No. Columns}
      MP	:= M + 2;
      M1	:= M + 1;
      PRINTH
    end(* IF *)
  Else
    begin
      writeln;
      writeln(' Bad file format');
      writeln;
      Result := 2
    end(* ELSE *);
  While (firstin) AND (NOT XEOF) do
    begin
    With F do
      CASE TAG of
	1: begin(* heading *)
	   heading := header;
	   hdrflag := true
	   end;
	2: begin(* row_name & RHS *)
	   Rowname[Rindex] := Rname;
	   B[Rindex] := RHS
	   end;
	4: begin(* col_name & OBJ *)
	   Colname[Cindex] := Cname;
	   C[Cindex] := OBJ
	   end;
	6: ABAR[R,S] := T;
       99: (* NULL *)
      End{With/Case};
    Rcd := Rcd + 1;
    READ(fa:Rcd+bias, F);
    XEOF := (F.tag=99);
    end(* While *);
  If firstin then
    begin
    PRINTC(B,C);
    For J:=1 to N do ABAR[M1,J] := C[J];
    For I:=1 to M do
      If B[I]<0.0 then
	begin
	B[I] := -B[I];
	For J:=1 to N do ABAR[I,J] := -ABAR[I,J]
	end;
    For J:=1 to N do
      begin
	SUM := 0.0;
	For I:=1 to M do SUM := SUM - ABAR[I,J];
	ABAR[MP,J] := SUM
      end;
    B[M1] := 0.0;
    SUM := 0.0;
    For I:=1 to M do SUM := SUM - B[I];
    B[MP] := SUM;
    For I:=1 to MP do
      begin
	X[I] := B[I];
	list[I] := N +I;
	For J:=1 to MP do U[I,J] := 0.0
      end;
    For I:=1 to MP do U[I,I] := 1.0;
    PRINTD;
    Rowname[M1] := '       M+1          ';
    Rowname[MP] := '       M+2          ';
    {PRINTX	OMITTED FOR LINPROG}
    end(* If firstin *);
  Writeln
end(*---of INITIAL---*);
 .
