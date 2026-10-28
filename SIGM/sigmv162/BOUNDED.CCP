program demo;

var notfull,notempty: semaphore;
    x : integer;


procedure process1;
begin
  while true do
  begin
     wait(notfull);
     writeln('process 1');
     readln(x);
     signal(notempty);
  end;
end;

procedure process2;
begin
  while true do
  begin
     wait(notempty);
     writeln('process 2');
     writeln(x);
     signal(notfull);
  end;
end;

begin
  writeln('start');
  notfull := 1; notempty := 0;
  cobegin process1;process2 coend;
end.
