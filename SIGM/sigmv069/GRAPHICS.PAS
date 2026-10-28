Program Graphics(0);
(*$E+ *)
const
  escape = 27;
  DotsAcross = 79;
  DotsDown = 47;
  MaxPts = 200;
  MaxPols = 200;
  MaxVtx = 800;
  MaxSides = 8;	{ maximum sides on a polygon }

type
  $string14 = string 14;
  $string255 = string 255;
  counter = 0..MaxVtx;
  Point = record X,Y,Z : real end;
  Vertex = 0..MaxPts;
  Matrix = array[1..4,1..4] of real;
  Polygon = record NumVtx : Vertex; Start : counter; end;
  OnePoly = array[1..MaxSides] of Point;

var
  Points : array[1..MaxPts] of Point;		{ original points }
  Polygons : array[1..MaxPols] of Polygon;	{ original polygons }
  Vertices : array[1..MaxVtx] of Vertex;	{ original vertices }
  OutPolys : array[1..MaxPols] of Polygon;	{ displayed polygons }
  OutVtces : array[1..MaxVtx] of Point;		{ displayed points }
  EyeSpace : Matrix;				{ eye space transform }
  Window : OnePoly;				{ display window }
  EyePt, CntrInt : Point;			{ eyepoint & cent of interest}
  ScreenScale,ScreenCtr : Point;
  ScreenX,ScreenY : real;
  Screen : packed array[0..Dotsacross,0..DotsDown] of boolean;
  NumPols,NumVtces,NumPts,Windowsize,I : counter;
  NumDisplay,NumVtxOut : counter;
  CmdChar : char;
  FileName : $string14;
  Done : boolean;

(*$L+ *)
{ The field of vision for a 3 dimensional display is bounded
  by 'clipping planes', the coefficients of which are calculated
  in this procedure. } 
procedure GetPlanes( var Poly : OnePoly; NumPts : counter); External;

{ get window to screen scale factor }
procedure GetScreenScale; External;

{ set default parameter values }
procedure Initialize; External;

{ enter vertices and polygons to define an object; write to disk }
Procedure DefineObject; External;

{ read vertices and polygons from disk }
procedure ReadObject(FileName : $string255); External;

{ transform and clip, then display polygons }
procedure MakePicture; External;

(*$L+ *)
begin	(* main program *)
  Initialize;	(* set up default veiw parameters *)
  while not Done do
    begin
      write(chr(escape),'E');	{ clear screen }
      writeln; writeln;
      writeln('	Menu for Graphics:');
      writeln;
      writeln('	s	start over');
      writeln('	r	read object from file');
      writeln('	d	define object to file');
      writeln('	e	change eyepoint');
      writeln('	c	change center of interest');
      writeln('	w	change window');
      writeln('	p	display picture');
      writeln('	q	quit');
      writeln; write('	choice: ');
      readln(CmdChar);
      case CmdChar of
	'r','R' : begin
	            write('file name: ');
	            readln(Filename);
		    ReadObject(FileName)
	          end;
	'd','D' : DefineObject;
	'e','E' : begin
	            write('eyepoint, X Y Z : ');
		    with EyePt do readln(X,Y,Z)
	          end;
	'c','C' : begin
                    write('center of interest, X Y Z : ');
		    with CntrInt do
		    readln(X,Y,Z)
	          end;
	's','S' : begin
	            NumPols:=0;
	            NumPts:=0
	          end;
	'w','W' : begin
	            write('display window : how many sides? ');
		    readln(WindowSize);
		    for I:=1 to WindowSize do
		      begin
		        write('X Y Z : ');
		        with Window[I] do readln(X,Y,Z)
		      end;
		    GetScreenScale;	(* get window to screen scale *)
		    GetPlanes(Window,WindowSize)  (* get clipping planes *)
	          end;
	'p','P' : MakePicture;
	'q','Q' : Done := true;
    end (* case *)
  end	(* while loop *)
end.	(* main program *)

o readln(X,Y,Z)
		    end;
		GetScreenScale;	(* g