External GRAPHICS::MAKE(3);
(*$E+ *)

procedure Start;
{ clear screen }
var
  I,J : counter;
begin
  for I := 0 to DotsAcross do
    for J := 0 to DotsDown do
      Screen[I,J] := false
end;	{ start }

(*$L+ *)
procedure Finish;
{ display output for H-19 terminal }
var
  I,J : counter;
begin
  write(chr(escape),'E');	{ clear screen & home cursor }
  write(chr(escape),'F');	{ put terminal into graphics mode }
  write(chr(escape),'w');	{ no wraparound at end of line }
  J := DotsDown;
  while J>0 do
    begin
      for I := 0 to DotsAcross do
	if (Screen[I,J] and Screen[I,J-1])
          then write('q')
          else if Screen[I,J-1]
                 then write('l')
		 else if Screen[I,J]
		        then write('o')
			else write(' ');
         if J>1
           then J:=J-2	{ count down by two }
	   else J := 0;
         if J>0
           then writeln		{ CR/LF unless last line }
    end; { while }
  write(chr(escape),'G');	{ exit graphics mode }
  write(chr(escape),'j');	{ save cursor position }
  write(chr(escape),'x','1');{ enable 25th line }
  write(chr(escape),'Y','8',' ');{ put cursor at start of 25th }
  with EyePt do write('eye:',X:4:1,Y:4:1,Z:4:1);
  with CntrInt do write(' cent:',X:4:1,Y:4:1,Z:4:1);
  readln(CmdChar);		{ get <CR> before continuing }
  write(chr(escape),'l');	{ erase entire line }
  write(chr(escape),'k');	{ restore cursor position }
  write(chr(escape),'v')	{ permit wraparound }
end;	{ Finish }

(*$L+ *)
procedure MoveTo( X,Y : real);
begin
  ScreenX := X;  ScreenY := Y;
end; { MoveTo }

(*$L+ *)
procedure DrawTo( X,Y : real);
var
  I : counter;
  Dx,Dy,Length,StepX,StepY,Xpos,Ypos : real;
begin
  Dx := X - ScreenX;
  Dy := Y - ScreenY;
  if abs(Dx) > abs(Dy)
    then Length := abs(Dx)
    else Length := abs(Dy);
  if Length < 1.0
    then Length := 1.0; { catch zero length lines }
  StepX := Dx/Length;
  StepY := Dy/Length;
  Xpos := ScreenX;
  Ypos := ScreenY;
  for I := 0 to trunc(Length) do
    begin
      Screen[round(Xpos),round(Ypos)] := true;
      Xpos := Xpos + StepX;
      Ypos := Ypos + StepY;
    end; { for }
  ScreenX := X;
  ScreenY := Y;
end;   { DrawTo }

(*$L+ *)
procedure MakePicture;
  { transform and clip, then display polygons }
var
  I,J,NumClp : counter;
  TmpPoly : OnePoly;

  function DotProd( Pt1,Pt2 : Point) : real;
    begin	{ vector dot product }
      DotProd := Pt1.X * Pt2.X + Pt1.Y * Pt2.Y + Pt1.Z * Pt2.Z;
    end; { DotProd }

  procedure Ident(var Mtx : Matrix);
    var
      I,J : counter;
  begin    { initialize matrix to identity matrix }
    for I := 1 to 4 do
      for j := 1 to 4 do
        if I=J
          then Mtx[I,J] := 1.0
          else Mtx[I,J] := 0.0;
  end; { Ident }

  procedure MatrixMult(Mt1,Mt2 : Matrix; var Result : Matrix);
    var
      I,J,K : counter;
  begin	{ multiply two 4 by 4 matrices }
    for I := 1 to 4 do
      for J := 1 to 4 do
        begin
          Result[I,J] := 0.0;
            for K := 1 to 4 do
              Result[I,J] := Result[I,J] + Mt1[K,J]*Mt2[I,K]
        end
  end;

(*$L+ *)
{ This procedure will transform the vertices of a polygon
  using a four-by-four matrix. }
  procedure Transform(Pt : Point; Mtx : Matrix; var NewPt : Point );
  begin
    NewPt.X := Pt.X*Mtx[1,1]+Pt.Y*Mtx[1,2]+Pt.Z*Mtx[1,3]+Mtx[1,4];
    NewPt.Y := Pt.X*Mtx[2,1]+Pt.Y*Mtx[2,2]+Pt.Z*Mtx[2,3]+Mtx[2,4];
    NewPt.Z := Pt.X*Mtx[3,1]+Pt.Y*Mtx[3,2]+Pt.Z*Mtx[3,3]+Mtx[3,4];
  end; { Transform }

(*$L+ *)
{ Distance and veiwing angle transforms are determined by this
  this procedure, which builds a transformation matrix based
  on the relationship between the coordinates of the eyepoint
  and those of the center of interest. }
  procedure GetEyeSpace( EyePt,Cntrint : Point);
    var
      Mtx : Matrix;
      C1,C2 : Point;
      Hypotenuse,CosA,SinA : real;
  begin
    Ident(Eyespace);
    with EyePt do	{ load eyepoint translation }
      begin
        EyeSpace[1,4] := -X;
        EyeSpace[2,4] := -Y;
        EyeSpace[3,4] := -Z
      end;
    Transform(Cntrint,EyeSpace,C1); {translate center of interest }
    Ident(Mtx);	{load rotation about Z-axis }
    with C1 do
      Hypotenuse := sqrt( X*X + Y*Y);
    if Hypotenuse > 0.0 then
      begin
        CosA := C1.Y / Hypotenuse;
        SinA := C1.X / Hypotenuse;
        Mtx[1,1] := CosA;
        Mtx[2,1] := SinA;
        Mtx[1,2] := -SinA;
        Mtx[2,2] := CosA;
        MatrixMult(EyeSpace,Mtx,EyeSpace)
      end;
    Transform(CntrInt,EyeSpace,C2); {rotate center of interest }
    Ident(Mtx);		{load rotation about X-axis }
    with C2 do
      Hypotenuse := sqrt(Y*Y + Z*Z);
    if Hypotenuse > 0.0 then 
      begin
        CosA := C2.Y / Hypotenuse;
        SinA := -C2.Z / Hypotenuse;
        Mtx[2,2] := CosA;
        Mtx[3,2] := SinA;
        Mtx[2,3] := -SinA;
        Mtx[3,3] := CosA;
        MatrixMult(EyeSpace,Mtx,Eyespace)
      end;
    Ident(Mtx);	{ load switch between Y and Z axes }
    Mtx[2,2] := 0.0;
    Mtx[3,3] := 0.0;
    Mtx[2,3] := 1.0;
    Mtx[3,2] := 1.0;
    MatrixMult(EyeSpace,Mtx,EyeSpace)
  end;	{ GetEyeSpace }

(*$L+ *)
  Procedure MakeDisplayable(Var Pt : Point);
{ This procedure achieves a perspective effect by dividing
  the x and y coordinates of each vertex by the z coordinate. }
  begin
    Pt.X := ScreenScale.X * Pt.X / Pt.Z + ScreenCtr.X;
    Pt.Y := ScreenScale.Y * Pt.Y / Pt.Z + ScreenCtr.Y;
  end;	(* MakeDisplayable *)

(*$L+ *)
  Function FacesEye( Poly : OnePoly ) : boolean;
{ This function determines whether or not a polygon will be
  hidden by another part of the same surface in a three-
  dimensional display. }
  var
    TmpPt : Point;
    TmpPoly : OnePoly;
  begin
    with Poly[2] do	{ make copy of second vertex }
      begin
        TmpPt.X:=X;
        TmpPt.Y:=Y;
        TmpPt.Z:=Z
      end;
    TmpPoly[1].X := Poly[1].X - Poly[2].X;	{ directed vector }
    TmpPoly[1].Y := Poly[1].Y - Poly[2].Y;	{ from 2nd to 1st }
    TmpPoly[1].Z := Poly[1].Z - Poly[2].Z;	{ vertex }
    TmpPoly[2].X := Poly[3].X - Poly[2].X;	{ directed vector }
    TmpPoly[2].Y := Poly[3].Y - Poly[2].Y;	{ from 2nd to 3rd }
    TmpPoly[2].Z := Poly[3].Z - Poly[2].Z;	{ vertex }
    GetPlanes( TmpPoly,2 );	{ get plane coefficients }
    if (DotProd( TmpPt,TmpPoly[1] ) <= 0.0 )
      then FacesEye := false
      else FacesEye := true
  end;	(* FacesEye *)

(*$L+ *)
  Procedure ClipIn(Var Poly : OnePoly; Var NumPts : counter);
{ Procedure to determine if any vertices of a polygon lie
  outside previously defined clipping planes; if so the
  polygon is modified accordingly. }
  var
    I,J,LstJ,TmpPts : counter;
    D1,D2,A : Real;
    TmpPoly : OnePoly;
  begin
    for I := 1 to WindowSize do	(* for each window edge *)
      if NumPts > 0 then
        begin
	  D1 := DotProd( Poly[NumPts],Window[I] );
	  LstJ := NumPts;
	  TmpPts := 0;
	  for J:= 1 to NumPts do	(* for each polygon edge *)
	    begin
	      if D1 > 0.0 then	(* is leading vertex inside? *)
		begin
		  TmpPts := TmpPts +1;
		  with TmpPoly[TmpPts] do
		    begin	(* copy leading vertex *)
		      X:=Poly[LstJ].X;
       		      Y:=Poly[LstJ].Y;
		      Z:=Poly[LstJ].Z
		    end
		end;	(* if leading vertex inside *)
	      D2:=DotProd(Poly[J],Window[I] );
	      if D1 * D2 < 0.0 then (* does edge straddle window? *)
		begin
		  A := D1 / (D1 - D2);
		  TmpPts := TmpPts + 1;
		  with TmpPoly[TmpPts] do
		    begin
		      X:=A*Poly[J].X + (1.0-A)*Poly[LstJ].X;
		      Y:=A*Poly[J].Y + (1.0-A)*Poly[LstJ].Y;
		      Z:=A*Poly[J].Z + (1.0-A)*Poly[LstJ].Z
		    end
		end;
	      LstJ := J;
	      D1 := D2
	    end;	(* NumPts loop *)
	  for J:=1 to TmpPts do	(* copy polygon back to input *)
	    with TmpPoly[J] do
	      begin
	        Poly[J].X:=X;
	        Poly[J].Y:=Y;
	        Poly[J].Z:=Z
	      end;
	  NumPts := TmpPts
	end	(* WindowSize Loop *)
  end;	(* ClipIn *)

(*$L+ *)
  Procedure InsertSort(Poly : OnePoly ; NumPts : counter);
{ Based on the average value of their z coordinates,
  polygons are sorted by their distance from the eyepoint
  in this binary insertion sort procedure. }
    var
      I,J,K : counter;
      AvDepth : real;
  begin	(* binary insertion sort on average depth *)
    AvDepth:= 0.0;
    for I := 1 to NumPts do
      with Poly[I] do	(* store vertices and find averge depth *)
	begin
	  OutVtces[NumVtxOut + I + 1].X := X;
	  OutVtces[NumVtxOut + I + 1].Y := Y;
	  OutVtces[NumVtxOut + I + 1].Z := Z;
	  AvDepth := AvDepth + Z	{ sum depths }
	end;
    AvDepth := AvDepth / NumPts;	{ divide for average }
    OutVtces[NumVtxOut + 1].Z := AvDepth; { store for later }
    J:=0;	(* initialize for insertion search *)
    I:=(NumDisplay + 1) div 2;
    K:=NumDisplay;
    while (J<>I) do	(* binary search for insertion point *)
      if (AvDepth < OutVtces[OutPolys[I].Start ].Z) then
	begin
	  K:=I;
	  I:=(I+J) div 2
	end
	else
	  begin
	    J:=I;
	    I:=(I+K+1) div 2
	  end;
    for J:=NumDisplay downto I+1 do { found it, now insert }
      begin
	OutPolys[J+1].Start := OutPolys[J].Start;  { move everything above }
	OutPolys[J+1].NumVtx := OutPolys[J].NumVtx { insertion point up one }
      end;
    OutPolys[I+1].Start := NumVtxOut + 1;	{ store new entry }
    OutPolys[I+1].NumVtx := NumPts;
    NumVtxOut := NumVtxOut + NumPts + 1;	{ vertex count }
    NumDisPlay := NumDisplay + 1		{ polygons stored }
  end;	(* InsertSort *)

(*$L+ *)
  procedure ClipOut(Poly : OnePoly; var NumPts : Vertex; Place : counter);
 { Once sorted polygons are checked to determine if a polygon
   closer to the eyepoint hides all or part of one that is
   farther away. }
  Var
    I,LstI,NumDrawn : Counter;
    Pt1,Pt2 : Point;
    Drawn : boolean;
	
    procedure ClipAfter(Index : counter; Pt1,Pt2 : Point);
      var
	I : counter;
	D1,D2,A : Real;
	Out : boolean;
	Pt3 : Point;
      begin	(* recursively check polygons for oaverlap with input edge *)
	if (Index < Place) then	 (* is polygon closer than edge? *)
	  with OutPolys[Index] do
	    begin
	      I:=Start + NumVtx;
	      Out:=false;
	      repeat (* for each polygon edge *)
		D1:=DotProd( Pt1,OutVtces[I]);
		D2:=DotProd( Pt2,OutVtces[I]);
		if ( (D1 <= 0.0) and (D2 <= 0.0) ) then
		  begin (* both points visible *)
		    Out := true;
		    ClipAfter(Index+1,Pt1,Pt2)
		  end
		  else if (D1 * D2 < 0.0) then
			 begin (* one point visible *)
			   A:=D1/(D1-D2);
			   Pt3.X:=A*Pt2.X+(1.0-A)*Pt1.X;
			   Pt3.Y:=A*Pt2.Y+(1.0-A)*Pt1.Y;
			   Pt3.Z:=A*Pt2.Z+(1.0-A)*Pt1.Z;
			   if (D1 < 0.0) then
			     begin (* Pt1 visible *)
			       ClipAfter(Index+1,Pt1,Pt3);
			       with Pt3 do
				 begin
				   Pt1.X:=X;
				   Pt1.Y:=Y;
				   Pt1.Z:=Z
				 end
			     end
			     else
			       begin	(* Pt2 visible *)
				 ClipAfter(Index+1,Pt3,Pt2);
				 with Pt3 do
				 begin
				   Pt2.X:=X;
				   Pt2.Y:=Y;
				   Pt2.Z:=Z
				 end
			       end
			end;	(* one point visible *)
		      I:=I-1;
   	        until (Out or (I=Start)) { all visible of edges exhausted }
	      end
	    else
	      begin (* reached end of list of closer polygons *)
	        MakeDisplayable(Pt1);
	        MakeDisplayable(Pt2);
	        Moveto(Pt1.X,Pt1.Y);
	        Drawto(Pt2.X,Pt2.Y);
	        Drawn := true	(* as mark is displayed *)
	      end
     end;	(* Clipafter *)

{ Clipout procedure body }
  begin (* clip each poly edge by all closer polys, draw what's left *)
    NumDrawn := 0;
    LstI := NumPts;
    for I:= 1 to NumPts do
      begin
	with Poly[LstI] do
	  begin
	    Pt1.X:=X;
	    Pt1.Y:=Y;
	    Pt1.Z:=Z
	  end;
	with Poly[I] do
	  begin
	    Pt2.X:=X;
	    Pt2.Y:=Y;
	    Pt2.Z:=Z
	  end;
	Drawn := false;
	ClipAfter(1,Pt1,Pt2);	(* check closer polys, then display *)
	if Drawn then
	  NumDrawn := NumDrawn + 1;
	LstI := I
      end;	(* for loop *)
    if NumDrawn = 0 then
      NumPts := 0	(* mark as hidden *)
  end;	(* ClipOut *)

(*$L+ *)
begin  (* MakePicture procedure body *)
  GetEyeSpace(EyePt,CntrInt );	(* get eyespace matrix *)
  NumDisplay :=0;
  NumVtxOut := 0;	(* set output counters *)
  for I:=1 to NumPols do
    with Polygons[I] do
      begin
	for J:=1 to NumVtx do (* get polygon *)
	  begin
	    with Points[Vertices[Start+J]] do
	      begin
	        TmpPoly[J].X:=X;
	        TmpPoly[J].Y:=Y;
	        TmpPoly[J].Z:=Z
	      end;
	    Transform(TmpPoly[J],EyeSpace,TmpPoly[J]); (* transform *)
	  end;
	if FacesEye(TmpPoly) then
	  begin
	    NumClp:=NumVtx;	(* protect original data *)
	    ClipIn(TmpPoly,NumClp); (* clip to veiw window *)
	    if NumClp>0 then
	      InsertSort(TmpPoly,NumClp);
				(* store in sorted order for display *)
	  end
	end;	(* loop for each polygon *)
(* display surviving polygons, clipping each be closer polygons *)
  Start;	(* initialize and clear display *)
  for I:=1 to NumDisplay do
    with OutPolys[I] do
      begin
	for J:=1 to NumVtx do
	  with OutVtces[Start+J] do
	    begin
	      TmpPoly[J].X:=X;
	      TmpPoly[J].Y:=Y;
	      TmpPoly[J].Z:=Z
	    end;
	ClipOut(TmpPoly,NumVtx,I);  (* clip and display *)
	if NumVtx > 0 then
	  begin
	    GetPlanes(TmpPoly,NumVtx);  (* convert to planes *)
	    for J:=1 to NumVtx do (* copy back for later clipping *)
	      with OutVtces[Start+J] do
		begin
		  X:=TmpPoly[J].X;
		  Y:=TmpPoly[J].Y;
		  Z:=TmpPoly[J].Z
		end
	   end
	end;	(* for loop (1 to NumDisplay) *)
  Finish	(* finalize picture *)
end;	(* MakePicture *)
.
ýåá‰È	 í°!ôÿ9ùëýåá•È	 í°Ív5Ù1ÙýwöýwõÙ1ÙýwôýwóÙ1ÙÝw Ý6ÿÝåýnýý