program trio;
const forever = false;

procedure writer(i:integer);
begin
  repeat
    writeln('process # ',i);
  until forever;
end;
	(* tab test *)
begin
  cobegin
        writer(1);
        writer(2);
        writer(3);
  coend 
end.
