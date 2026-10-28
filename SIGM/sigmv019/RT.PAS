PROGRAM RT;
(**
 **  PROGRAM TITLE:	Random Files IO
 **
 **  WRITTEN BY:	Raymond E. Penley
 **  DATE WRITTEN:	11 June 1980
 **
 **  WRITTEN FOR:	Users of Pascal/Z
 **)
LABEL	99;	{place to go when all done}
CONST
	terminal = '/EOF/EOF/EOF/EOF/EOF';
	ID	 = 'RAND.TST';
TYPE
  Custype = record
	   name : STRING 20;
	   next : ^cust
         end;

  STR255 = STRING 255;
  Storetype = file of custype;

VAR
	count,		(* Record counter *)
	IX,
	Rcd : INTEGER;
	CTRLE,		(* My End_of_file flag on INPUT *)
	CTRLZ : CHAR;	(* CP/M eof of file marker *)
	XEOF,		(* User supplied EndOfFile flag *)
	EOFS,		(* Flag for CP/M eof marker *)
	done : BOOLEAN;
	Customer : custype;
	Store : Storetype;


FUNCTION INDEX(X,Y: STR255): INTEGER; EXTERNAL;

Procedure SCROLL;
VAR	ix : 1..25;
	jx : INTEGER;
begin
  For ix:=1 to 25 do
    begin
	writeln;
	For jx:=1 to 600 do {dummy};
     end;
end;

Procedure CLEAR;
VAR	ix : 1..25;
begin
  For ix:=1 to 25 do Writeln;
end;

Procedure PAUSE;
VAR	cix : char;
begin
  write('Type return to continue  ');READLN(cix);
end;

FUNCTION SIZE(VAR fx : Storetype): INTEGER;
VAR	ix : integer;
begin
  RESET(ID,fx);
    ix := 1;
    READ(fx,Customer);
    XEOF := INDEX(Customer.NAME,'/EOF/') <> 0;
    While NOT XEOF do
      begin
	ix := ix + 1;
	READ(fx,Customer);
	XEOF := INDEX(Customer.NAME,'/EOF/') <> 0;
      end;
  SIZE := ix - 1;
end{---of SIZE---};

(*$P+	[turn on symbolic output]*)
BEGIN
  CLEAR;
  CTRLZ := CHR(26);
  Customer.name := '--------------------';
  Customer.next := nil;

  writeln(' ':15, 'PASCAL/Z FILE I/O Demo');
  writeln(' ':15, 'File I/O on a NON Text file');
  writeln;writeln;

  writeln(' ':15,'Creating file "RAND.TST"');
  {
	File RAND.TST will be created sequentially but
	may be accessed either randomly or sequentially
  }
  REWRITE(ID,Store);
  FOR IX:=1 TO 20 DO
    begin
	Customer.NAME[ix] := CHR(ix+64);
	WRITE(Store,Customer);
	Writeln;(*---simple scroll here---*)
    end;
  {---NOW mark the End_Of_File---};
  Customer.name := terminal;
  WRITE(Store,Customer);

  WRITELN;
  WRITELN(' ':15,'---TEST ONE - SEQUENTIAL READING---');
  count := SIZE(Store);
  RESET(ID,Store);
  WRITELN('INITIALLY AFTER A RESET EOF(Store) = ', EOF(Store) );
  for ix:=1 to 5000 do {dummy};
    For ix := 1 to count do
      begin
	READ(Store,Customer);
	XEOF := INDEX(Customer.NAME,'/EOF/') <> 0;
	EOFS := (Customer.NAME[1]=CTRLZ);
	writeln;
	IF NOT EOFS THEN WRITELN( ix:3, ': ', Customer.NAME);
	writeln(' ':5,'XEOF = ', XEOF, ' ':5,'EOFS = ', EOFS );
      End;
  PAUSE;
  SCROLL;

  WRITELN(' ':15,'---TEST TWO - RANDOM READING---');
  WRITELN;writeln;
  writeln('Enter <-1> to quit');
  RESET(ID,Store);
    DONE := FALSE;
    REPEAT
	WRITELN;
	WRITE('Enter RECORD to be DISPLAYED  ');READ(Rcd);
	If Rcd=(-1) then
	  begin  Done:=true;goto{exit}99 end;
	If Rcd<=count then
	  begin
		READ(Store:Rcd, Customer);
		XEOF := INDEX(Customer.NAME,'/EOF/') <> 0;
		EOFS := (Customer.NAME[1]=CTRLZ);
		WRITELN;
		IF NOT EOFS THEN WRITELN( Rcd:3, ': ', Customer.NAME);
		writeln(' ':5,'XEOF = ', XEOF, ' ':5,'EOFS = ', EOFS );
	   end
	Else
	  Writeln('Read Beyond End Of File');
    99:{exit here when done}
    UNTIL DONE;
  CLEAR;{always be neat and clear the screen of your garbage}
End{of Program RT}.
