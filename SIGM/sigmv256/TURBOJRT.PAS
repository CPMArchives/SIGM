(* TURBOJRT.PAS is a collection of subroutines for JRT Pascal that
   do the same thing as built in functions in Turbo Pascal. This set
   of procedures must be included in your program prior to the main
   program itself. Use the JRT compiler directive:  %INCLUDE('TURBOJRT.PAS')
   to accomplish this.


   Author:  Stephen Cebula
            2349 Packard Avenue
            Huntingdon Valley, PA 19006


   Note: JRT Pascal became a public domain program ever since JRT Systems
   went bankrupt. It can be found in the SIG/M library of your local computer
   club or distribution center. Although it does not have all the fancy
   features of Turbo Pascal (tm), it is good enough and reasonable enough ($$)
   to serve as a valuable teaching tool for the Pascal language.
*)

procedure gotoxy(x,y: integer);
begin
   write( chr(27), chr(ord('=')), chr(32+y), chr(32+x));
(* write( chr(27), chr(ord('Y')), chr(32+y), chr(32+x)); *)  (* for Heath *)
   end;

procedure clrscr;
begin
   write( chr(26));  (* clear screen on Osborne, Kaypro, or Televideo *)
(* write( chr(27), chr(ord('E'))); *)    (* clear screen on Heath computer *)
   end;

procedure clreol;
begin
   write( chr(27), chr(84)); (* clear 'til end of line on Osborne  ESC T *)
   end;

procedure LowVideo;  (* Osborne I/Televidio 920c screen function *)
begin
   write( chr(27), chr(ord(')')));  (* ESC )  *)
   end;

procedure NormVideo; (* opposite of LowVideo procedure *)
begin
   write( chr(27), chr(ord('(')));   (* ESC (  *)
   end;

procedure DelLine;   (* Delete line on Osborne I *)
begin
   write( chr(27), chr(ord('R')));   (* ESC R  *)
   end;

procedure InsLine;   (* Insert line on Osborne I *)
begin
   write( chr(27), chr(ord('E')));   (* ESC E  *)
   end;

procedure CrtInit;   (* fill in your own command to initialize screen *)
begin
   write;
   end;

procedure CrtExit;   (* fill in your own command to exit screen *)
begin
   write;
   end;


begin
   write;
   end;

procedure CrtExit; 