External Graphics::Util(4);
(*$E+ *)

{ The field of vision for a 3 dimensional display is bounded
  by 'clipping planes', the coefficients of which are calculated
  in this procedure. } 
procedure GetPlanes( var Poly : OnePoly; NumPts : counter);
var
  I,LstI : counter;
  TmpPoly : OnePoly;
begin { compute plane equation coefficients for polygon edges }
  LstI := NumPts;  { leading vertex of the edge }
  for I := 1 to NumPts do
    begin
      with Poly[I] do
	begin { vector cross product using edge endpoints }
	TmpPoly[I].X := Y * Poly[LstI].Z - Z * Poly[LstI].Y;
	TmpPoly[I].Y := Z * Poly[LstI].X - X * Poly[LstI].Z;
	TmpPoly[I].Z := X * Poly[LstI].Y - Y * Poly[LstI].X;
	end; { with Poly[I] }
      LstI := I;
    end;	{ for loop }
    for I := 1 to NumPts do	{copy back to input polygon }
      with TmpPoly[I] do
        begin
          Poly[I].X := X;
          Poly[I].Y := Y;
          Poly[I].Z := Z;
        end { with TmpPoly[I] }
end;	{ Getplanes }
(*$L+ *)

procedure GetScreenScale;
{ get window to screen scale factor }
var
  I : counter;
  MaxX,MinX,MaxY,MinY : real;

begin
  MaxX:=0.0;
  MinX:=0.0;
  MaxY:=0.0;
  MinY:=0.0; {window must include Z-axis}
  for I := 1 to WindowSize do
    with Window[I] do
      begin
	if X/Z > MaxX then MaxX := X/Z;
	if X/Z < MinX then MinX := X/Z;
	if Y/Z > MaxY then MaxY := Y/Z;
	if Y/Z < MinY then MinY := Y/Z;
      end; { with Window[I] }
  MaxX := MaxX - MinX;
  MaxY := MaxY - MinY;
  if MaxY > (0.75 * MaxX)  {standard display is 3 unit high by 4 units wide}
  then ScreenScale.Z := (MaxY * 4 / 3)
  else ScreenScale.Z := MaxX;
  ScreenScale.X := DotsAcross / ScreenScale.Z;
  ScreenScale.Y := (DotsDown * 4 / 3) / ScreenScale.Z;
end;	{ GetScreenScale }
.
if Dra