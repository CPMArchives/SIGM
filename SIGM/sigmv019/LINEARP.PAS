Program LINEAR;
(*  PROGRAM TITLE:	Linear Programming
**
**  WRITTEN BY:		W.M. Yarnall
**			19 Angus Lane
**			Warren, N.J. 07060
**  DATE WRITTEN:	March 1980
**
**  WRITTEN FOR:	S100 MICROSYSTEMS
**			MAR 1980
**
**  SUMMARY:		Minimize a cost function to constraints.
**			Maximize negative of 'profit' function.
**			This program uses the Revised Simplex Algorithm.
**
**  MODIFICATION RECORD:
**	25 MAY 1980	-MODIFIED FOR PASCAL/Z BY RAYMOND E. PENLEY
**
**		---NOTE---
**
** The first logical record in Pascal/Z is No.1, NOT record
** No. 0 as in Pascal/M or UCSD Pascal. This can be rectified
** very eaisly by adding a "BIAS" to each record number.
**	Pascal/Z : bias = 1	|	Pascal/M : bias = 0
**
*)
LABEL	99;	  { File not found exit }

CONST
  maxrow = 32;
  maxcol = 64;
  bias   =  1;	   (* Bias added to each record *)
  FID_LENGTH = 14; (* MAXIMUM LENGTH ALLOWED FOR A FILE NAME *)

TYPE
  FID  = STRING FID_LENGTH;
  ROW = array [1..maxrow] of real;
  COL = array [1..maxcol] of real;
  Frec = record
	   CASE TAG : integer of
	    0: (name : STRING 6; num1, num2 : integer);
	    1: (header : STRING 64);
	    2: (Rname : STRING 6; Rindex : integer; RHS : real);
	    4: (Cname : STRING 6; Cindex : integer; OBJ : real);
	    6: (R, S : integer; T : real);
	   99: () {End_Of_File}
	 end;

  STRING80 = STRING 80;

VAR
  ABAR 		: array [1..maxrow, 1..maxcol] of real;
  Colname 	: array [1..maxcol] of STRING 6;
  fa		: FILE of Frec;	(*---File descriptor <FCB>---*)
  File_ID	: FID;		(*---File Identifier <FID>---*)
  F		: Frec;
  heading	: STRING 64;
  hdrflag	: boolean;
  list		: array [1..maxrow] of integer;
  M, N,
  MP, M1	: integer;
  PNAME		: STRING 6;
  Result	: integer;
  Rowname 	: array [1..maxrow] of STRING 6;
  U 		: array [1..maxrow, 1..maxrow] of real;
  X,XIK		: ROW;

PROCEDURE GETID( MESSAGE : STRING80; VAR ID: FID );
(**
	FID_LENGTH = 14;
	STRING80 = STRING 80;
	FID      = STRING FID_LENGTH;
**)
CONST	SPACE = ' ';
TYPE
(*----Required for PASCAL/Z supplied functions----*)
  STR0 = STRING 0;
  STR255 = STRING 255;
		(*----required by PASCAL/Z----*)
	FUNCTION  LENGTH(X: STR255): INTEGER; EXTERNAL;
	PROCEDURE SETLENGTH(VAR X: STR0; Y: INTEGER); EXTERNAL;

begin{GetID}
  SETLENGTH(ID,0);
  writeln;
  write(message);
  READLN(ID);
  While Length(ID)<FID_LENGTH DO APPEND(ID,SPACE)
End{---of GETID---};

Procedure PRINTH;
begin
  writeln;
  writeln(' PROG. NAME = ', Pname);
  writeln(' No. Rows   = ', M:6);
  writeln(' No. Cols   = ', N:6);
  writeln
end(*---of PRINTH---*);

Procedure PRINTC( B : row ; C : col );
VAR	I : integer;
begin
  writeln;
  writeln('  ---Initial Data---');
  writeln;
  writeln(' Objective Vector');
  writeln;
  For I:=1 to N do
    writeln( Colname[I]:8, C[I]:14:8 );
  writeln;
  writeln(' RHS Vector');
  WRITELN;
  For I:=1 to M do
    writeln( Rowname[I]:8, B[I]:14:8 );
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
      Writeln(I:6, J:6,'  ', Rowname[I]:8, Colname[J]:8, ABAR[I,J]:14:8);
  writeln;
  writeln(' ABAR(M+1), ABAR(M+2)');
  writeln;
  For I:=1 to N do
    writeln( Colname[I]:8, ABAR[M1,I]:14:8, ABAR[MP,I]:14:8 );
  writeln
end(*---of PRINTD---*);

Procedure PRINTX;
VAR	I : integer;
	S : STRING 6;
begin
  writeln;
  writeln(' List and X Arrays');
  writeln;
  For I:=1 to MP do
    begin
    S := '      ';
    If (list[I]<=N) then S := Colname[ List[I] ];
    If I>M then S := Rowname[I] ;
    writeln( I:8,'  ', S:8, list[I]:7, X[I]:18:8 )
    end(*FOR*);
  writeln
end(*---of PRINX---*);

Procedure EXITER(exitcode, X : integer);
begin
  CASE exitcode of
   1:	begin
	Result := 1; (* Normal exit *)
	Writeln(' End of Phase 1 for ', Pname, ' after', X:3,
		' Iterations');
	PRINTX
	end;
   2:	begin
	Result := 2; (* Error exit *)
	Writeln(' Error in Iteration', X:3);
	PRINTX
	end;
   3:	begin
	Result := 3; (* No feasible solution *)
	Writeln(' No feasible solution after', X:3, ' Iterations');
	PRINTX
	end;
   4:	begin
	Result := 1; (* Normal exit *)
	Writeln(' End of Phase 2 for ', Pname, ' after', X:3,
		' Iterations');
	PRINTX
	end;
   5:	begin
	Result := 2; (* Unbounded solution *)
	Writeln(' Unbounded solution for ', Pname);
	PRINTX
	end
   end(* CASE exitcode of *)
end(*---of EXITER---*);

Procedure INITIAL;
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
    Rowname[M1] := 'M+1   ';
    Rowname[MP] := 'M+2   ';
    PRINTX
    end(* If firstin *);
  Writeln
end(*---of INITIAL---*);

Procedure PHASE1;
LABEL	304; (* Exit point *)
CONST	TOL = 1.0E-5;
VAR	iter, I, J, L, ksave : integer;
	sum, temp, theta, Z  : real;
	XL, XLK		     : real;
	DEL, V, W	     : ROW;
	test		     : boolean;
begin
  writeln(' Start Phase 1');
  writeln;
  iter := 0;
  While true do
    begin
    If ABS(X[MP])<tol then {normal exit}
	begin EXITER(1,iter); goto 304 end;
    If X[MP]>tol then {error exit}
	begin EXITER(2,iter); goto 304 end;
    iter := iter +1;
    For J:=1 to N do
      begin
	SUM := 0.0;
	For I:=1 to MP do
	  SUM := SUM + U[MP,I] * ABAR[I,J];
	DEL[J] := SUM
      end;
    test := true;
    For J:=1 to N do
      If DEL[J]<0.0 then test := false;
    If test then {no feasible solution exit}
      begin EXITER(3,iter); goto 304 end;
    temp := 1.0E+36;
    ksave := 0;
    For J:=1 to N do
      If DEL[J]<temp then
	begin temp := DEL[J]; ksave := J end;
    For I:=1 to MP do
      begin
	SUM := 0.0;
	For J:=1 to MP do
	  SUM := SUM + U[I,J] * ABAR[J,ksave];
	XIK[I] := SUM
      end;
    theta := 1.0E+36;
    L := 0;
    For I:=1 to M do
      If XIK[I]>0.0 then
	begin
	Z := X[I] / XIK[I];
	If (Z=theta) AND (list[I]>N) then
	  L := I
	Else
	  If Z<theta then
	    begin theta := Z; L := I end
	end;
    If L=0 then
      begin EXITER(2,iter); goto 304 end;
    list[L] := ksave;
    For I:=1 to MP do
      begin
	V[I] := XIK[I] / XIK[L];
	W[I] := U[L,I]
      end;
    XL := X[L];
    XLK := XIK[L];
    For I:=1 to MP do
      begin
	Z := theta;
	If (list[I]<>ksave) then Z := X[I] - XL * V[I];
	X[I] := Z;
	For J:=1 to M do
	  begin
	    Z := W[J] / XLK;
	    If I<>L then Z := U[I,J] - W[J] * V[I];
	    U[I,J] := Z
	  end
      end;
    writeln(' Iteration', iter:3, ' of ', Pname);
    PRINTX
    end(* While true *);
304: (* Exit point *)
end(*---of PHASE1---*);

Procedure PHASE2;
LABEL	403; (* Exit point *)
CONST	TOL = -1.0E-5;
VAR	I, J, L, iter, ksave : integer;
	SUM, temp, theta, Z  : real;
	XL, XLK		     : real;
	DEL, V, W	     : ROW;
	test		     : boolean;
begin
  iter := 0;
  writeln(' Start Phase 2');
  writeln;
  While true do
    begin
    For J:=1 to N do
      begin
	SUM := 0.0;
	For I:=1 to MP do
	  SUM := SUM + U[M1,I] * ABAR[I,J];
	DEL[J] := SUM
      end;
    test := true;
    For J:=1 to N do
      If DEL[J]<tol then test := false;
    If test then
      begin EXITER(4,iter); goto 403 end;
    iter := iter +1;
    temp := 1.0E+36;
    ksave := 0;
    For J:=1 to N do
      If DEL[J]<temp then
	begin temp := DEL[J]; ksave := J end;
    For I:=1 to MP do
      begin
	SUM := 0.0;
	For J:=1 to MP do
	  SUM := SUM + U[I,J] * ABAR[J,ksave];
	XIK[I] := SUM
      end;
    test := true;
    For I:=1 to MP do
      If XIK[I]>0.0 then test := false;
    If test then
      begin EXITER(5,iter); goto 403 end;
    theta := 1.0E+36;
    L := 0;
    For I:=1 to M do
      If XIK[I]>0.0 then
	begin
	  Z := X[I] / XIK[I];
	  If Z<theta then
	    begin theta := Z; L := I end
	end;
    List[L] := ksave;
    For I:=1 to MP do
      begin
	V[I] := XIK[I] / XIK[L];
	W[I] := U[L,I];
      end;
    XL := X[L];
    XLK := XIK[L];
    For I:=1 to MP do
      begin
	Z := theta;
	If (list[I]<>ksave) then Z := X[I] - XL * V[I];
	X[I] := Z;
	For J:=1 to M do
	  begin
	    Z := W[J] / XLK;
	    If I<>L then Z := U[I,J] - W[J] * V[I];
	    U[I,J] := Z
	  end
      end;
    writeln(' Iteration', iter:3, ' of ', Pname);
    PRINTX;
    end(* While true *);
403: (* Exit point *)
end(*---of PHASE2---*);

Procedure CLEAR;
(* simple screen clear routine *)
VAR	ix : 1..25;
begin
  for ix:=1 to 25 do writeln
end;

BEGIN (***   MAIN PROGRAM   ***)
  CLEAR;
  GETID(' Enter data File Name ---> ', File_ID);
  RESET(File_ID, fa);	(*---RESET( <FID> , <FCB> )---*)
  If EOF(fa) then
    begin
	Writeln(CHR(7),'File ',File_ID,'not found');
	{exit}goto 99
    end;
  Writeln;
  INITIAL;
  If Result<>2 then PHASE1;
  If Result=1 then PHASE2;
  If hdrflag then Writeln(' ', heading);
99: {File not found exit};
  Writeln;Writeln;Writeln;Writeln;Writeln
end(*---of Linear---*).
