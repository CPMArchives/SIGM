External GRAPHICS::INIT(2);
(*$E+ *)

{ set default parameter values }
procedure Initialize;
begin
  Done := false;
  NumPols := 0;
  NumDisplay := 0;
  NumVtces := 0;
  NumPts := 0;
  with EyePt do
    begin
      X:=5.0;
      Y:=-5.0;
      Z:=3.0
    end;
  with CntrInt do
    begin
      X:=0.0;
      Y:=0.0;
      Z:=0.0;
    end;
  WindowSize := 4;
  with Window[1] do
    begin
      X:=-4.0;
      Y:=-3.0;
      Z:=16.0
    end;
  with Window[2] do
     begin
       X:=-4.0;
       Y:= 3.0;
       Z:=16.0
     end;
  with Window[3] do
    begin
      X:= 4.0;
      Y:= 3.0;
      Z:=16.0
    end;
  with Window[4] do
    begin
      X:= 4.0;
      Y:=-3.0;
      Z:=16.0
    end;
  GetScreenScale;
  GetPlanes(Window,WindowSize);
  with ScreenCtr do
    begin
      X:=DotsAcross/2;
      Y:=DotsDown/2
    end
end;	{ Initialize }
.
    NumClp:=NumVtx;	(* protect original data *)
	    ClipIn(TmpPoly,NumClp); (* clip to veiw window *)
	    if NumCl