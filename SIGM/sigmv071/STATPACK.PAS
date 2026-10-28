program ogorman;
{$c-,m-,f-}
type 
byte = 0..255;

var
statistics:array[1..1000] of real;
xx,number:integer;
stop:char;

procedure clear_screen;
begin
write(chr(27),'[2J',chr(27),'[1;1H');
end;

procedure stat_average;
var
standard_deviation,max,min,average,sum:real;
counter:integer;
ii,i:byte;
ch:char;


procedure calc_variance;
var
i:byte;
variance,xvariance:real;

begin
xvariance:=0.0;
for i:= 1 to 1000 do
if statistics[i] <> -1.0 then
	xvariance:=xvariance + sqr(statistics[i]-average);
variance:=xvariance/(counter-1);
standard_deviation:= sqrt(variance);
end;

begin
clear_screen;
writeln('STATISTICAL ANALYSIS FOR TEST ');
writeln;
writeln;

sum:= 0.0;
counter:= 0;

max:= statistics[1];				{init max,min to first value}
if statistics[1] = -1.0 then
	min:= -1.0 else min:= statistics[1];

for ii:= 1 to 1000 do
begin
	if statistics[ii] <> -1.0 then 
		begin
		sum:= sum + statistics[ii];
		counter:= counter + 1;
		if statistics[ii] > max then
		  max:= statistics[ii];
 		if statistics[ii] < min then
		min:= statistics[ii];
		end;
end;
average:= sum/counter;
if (average = 0.0) or (average = -1.0) then
	write('no average calculated ':18) else
		begin
		calc_variance;
		write('  average: ',average:7:1);
		write('  n = ',counter:4,'  S.D.= ',standard_deviation:7:1);
		end;

if max <> -1.0 then write('  max = ',max:7:1) else
			  write('  no max ':7);
if min <> -1.0 then write('  min = ',min:7:1) else
		          write('  no min ':7);
writeln;

end;


begin	{MAIN PROGRAM}


repeat
clear_screen;
for xx:= 1 to 1000 do statistics[xx]:=-1.0;  {initialize array}

writeln('At prompt, enter value. Enter a value of -1 to stop entering data ');

xx:=0;

repeat
xx:=xx+1;

repeat
write(xx:2,' --->  ');
read(statistics[xx]);
until (statistics[xx] < 1000.0) and (statistics[xx] > -1.1);{check limits}

until statistics[xx] = -1.0;  {input values until = -1 ie done}

stat_average;

writeln;
write('Do you have additional data to analyze?  y/n  ');
read (stop)
until (stop = 'n') or (stop = 'N');
end.