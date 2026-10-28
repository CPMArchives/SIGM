External GRAPHICS::FILES(1);
(*$E+ *)

Procedure DefineObject;
var
  Pts,PtsObj,PolsObj,PtsPol,I,J : counter;
  X,Y,Z,Xpos,Ypos,Zpos : real;
  ObjFile : file of char;
begin
  write('Name of file: ');readln(Filename);	{get file name}
  rewrite(Filename,Objfile);			{open object file}
  write('Number of points: '); readln(PtsObj);
  write('Number of polygons: '); readln(PolsObj);
  writeln(ObjFile,PtsObj,PolsObj);
  writeln('Pnt	X,Y,Z');
  for I := 1 to PtsObj do
    begin
      write(I:2);write('	');readln(X,Y,Z);
      writeln(ObjFile,X,Y,Z);
    end;
  for I := 1 to PolsObj do
    begin
      write('# of pnts in ',I:2,' polygon: ');readln(PtsPol);
      write(ObjFile,PtsPol);   { write polygon vertex pointers }
      for J := 1 to PtsPol do
        begin
	  read(Pts);
          write(ObjFile,Pts)
        end;
      writeln(ObjFile)  { read past end of line }
    end
  end;  { DefineObject }

(*$L+ *)
procedure ReadObject(FileName : $string255);
  { read in object from disk }
var
  PtsObj,PolsObj,PtsPol,I,J : counter;
  Xpos,Ypos,Zpos : real;
  ObjFile : file of char;
begin
  write('Position for ',Filename,' X Y Z : ');
  readln(Xpos,Ypos,Zpos);
  reset(Filename,Objfile);   {open object file }
  readln(ObjFile,PtsObj,PolsObj);
  write('Number of points: '); writeln(PtsObj:4);
  write('Number of polygons: '); writeln(PolsObj:4);
  for I := 1 to PtsObj do
    with Points[I+NumPts] do
      begin
        readln(ObjFile,X,Y,Z);
        X := X+Xpos;
        Y := Y+Ypos;
        Z := Z+Zpos;
        writeln('Point: ',I,'	',X:6:1,Y:6:1,Z:6:1)
      end;
  for I := 1 to PolsObj do
     begin
       read(ObjFile,PtsPol);   { read polygon vertex pointers }
       writeln('Polygon ',I:2,' has ',PtsPol:4,' vertices');
       write('They are: ');
       for J := 1 to PtsPol do
         begin
           read(ObjFile,Vertices[J+NumVtces]);
           Vertices[J+NumVtces] := Vertices[J+NumVtces]+NumPts;
	   write(Vertices[J+NumVtces]:3)
         end;
       readln(ObjFile);  { read past end of line }
       writeln;
       with Polygons[I+NumPols] do
         begin
           Start := NumVtces;
           NumVtx := PtsPol;
         end;
       NumVtces := NumVtces + PtsPol;
    end;
  NumPts := NumPts + PtsObj;
  NumPols := NumPols + PolsObj;
  readln(CmdChar)	{ leave display until cr }
end;  { ReadObject }
.
    writeln; wri