program  diningphilosophers; 

const   forever = false;
var     fork : array [0..4] of semaphore;
        room ,screen  : semaphore;
        i : integer;
procedure eat(i:integer);
begin
  wait(screen);
  writeln('philosopher ',i,' eating');
  signal(screen);
end;

procedure think(i:integer);
begin
  wait(screen);
  writeln('philosopher ',i,' thinking');
  signal(screen);
end;

procedure philosopher(i :integer);
begin
  repeat
        think(i);
        wait(room);
        wait(fork[i]);
        wait(fork[(i+1) mod 5]);
        eat(i);
        signal(fork[i]);
        signal(fork[(i+1) mod 5]);
        signal(room);
   until forever;
end;

begin (* main program *)
  room := 4;                             (* 4 seats for philosophers *)
  screen := 1;
  for i := 0 to 4 do fork[i] := 1;       (* 1 fork for each seat *)
  cobegin                                (* now let the guys in  *)
        philosopher(0);
        philosopher(1);
        philosopher(2);
        philosopher(3);
        philosopher(4);
  coend 
end.