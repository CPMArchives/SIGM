


program xstat;{$P+}
{$c-,m-,f-}
label 1;
const
defaultpad ='                                                           ';

type
id = array[1..6] of char;
calendar = array [1..2] of char;
date_of_test = record
		month:calendar;
		day:calendar;
		year:calendar
		end;
lab_data = record
	name: array [1..30] of char;
	chart_number:id;
	date: date_of_test;  
	sex:boolean;
	weight: real;
	height: real;
	surface_area: real;
	chronological_age: real;
	bone_age: real;
	height_age:real;
	percent_overweight_for_height:real;
	total_body_water: real;
	values:array[1..18,1..14] of real;
	pad:array[1..59] of char;
	end;

xstatistical = array[1..20,1..14,1..18] of real;


byte = 0..255;
$string0 = string 0;
$string255 = string 255;
$string80 = string 80;
$string14 = string 14;
$string4 = string 4;
f = file of lab_data;
axis_label = array[1..4] of char;

var
filename:$string14;
norms,data:lab_data;
num_values, peak_time,time,results,x,y,i:byte;
fin:f;
average,max,min,sum:real;
hardcopy,normal_value_flag, error, terminate, continue,escape:boolean;
rec:integer;
strvalue:$string80;
x_axis_label,y_axis_label: array[1..14] of axis_label;
statistics:xstatistical;
output:text;





{************************* init labels for axis *************************}
procedure initialize;
var
i:byte;
begin
x_axis_label[1]:= '-30 ';
x_axis_label[2]:= '-1  ';
x_axis_label[3]:= '15  ';
x_axis_label[4]:= '30  ';
x_axis_label[5]:= '45  ';
x_axis_label[6]:= '60  ';
x_axis_label[7]:= '90  ';
x_axis_label[8]:= '120 ';
x_axis_label[9]:= '150 ';
x_axis_label[10]:= '180 ';
x_axis_label[11]:= '210 ';
x_axis_label[12]:= '240 ';
x_axis_label[13]:= '300 ';
x_axis_label[14]:= '360 ';

y_axis_label[1]:= 'BS  ';
y_axis_label[2]:= 'IRI ';
y_axis_label[3]:= 'GH  ';
y_axis_label[4]:= 'LH  ';
y_axis_label[5]:= 'FSH ';
y_axis_label[6]:= 'F   ';
y_axis_label[7]:= 'PRL ';
y_axis_label[8]:= 'TSH ';
y_axis_label[9]:= 'T   ';
y_axis_label[10]:= 'DS  ';
y_axis_label[11]:= 'ACTH';
y_axis_label[12]:= 'T4  ';
y_axis_label[13]:= 'TBG ';
y_axis_label[14]:= 'TT3 ';

end;


procedure setlength (var x:$string0; y:integer);external;
function length (x:$string255):integer; external;
procedure keyin(var cix:char);external;


procedure clear_screen;
begin
write (chr(27),'*',chr(0),chr(0),chr(0),chr(0));
end;

procedure erase_lines(starting_line,number_of_lines:byte);
const
blanks = '                                        ';
var
i:byte;

begin
for i:= 1 to number_of_lines do
	begin
	write(chr(27),'=',chr(starting_line + 31),chr(32),blanks,blanks);
	starting_line:= starting_line + 1;
	end;
end;

procedure move_cursor(x,y:byte);
begin
write(chr(27),'=',chr(y+31),chr(x+31));
end;

procedure prompt (x,y,length:byte; p:$string80;
	          protected_field_desired:boolean);

var
underline:string 80;
i:byte;
begin
setlength(underline,0);
for i:= 1 to length do append (underline,'_');
if protected_field_desired = false then
	write(chr(27),'=',chr(y+31),chr(x+31),p,underline)
	else
	write(chr(27),'=',chr(y+31),chr(x+31),chr(27),')',p,
		underline,chr(27),'(');
end;


function query(x,y:byte; message:$string80):boolean;  {ask y/n question}
var 
answer:char;
begin
repeat
move_cursor(x,y);
write(message);
keyin(answer);
until answer in ['y','n','Y','N'];
query:= ((answer = 'y') or (answer = 'Y'));
erase_lines(y,1);
end;





function number_records(filenam:$string14):integer;
label 1;
var
num:integer;
i:byte;

begin
num:= 0;
reset (filename,fin);
if eof(fin) then
	begin
	num:= 1;
	goto 1;
	end;
with data do
begin
read(fin:1,data);
for i:= 1 to 6 do num:= num*10 + ord(chart_number[i])-48;
end;
1: number_records:= num;
end;

procedure init_statistical_array;
begin
clear_screen;
writeln;
writeln('Initializing and loading values into matrix. One moment,  please.');
for rec:= 1 to 20 do
	for results:= 1 to 14 do
		for time:= 1 to 18 do
			statistics[rec,results,time]:= -999.0;
end;


procedure axis;
var
i:byte;

begin
writeln; {DEBUG delay...terminal does not seem to respond fast enough}
for i:= 6 to 19 do
	begin
	move_cursor(1,i-1);
	write(x_axis_label[i-5]:4);
	end;

move_cursor(9,4);
for i:= 1 to 14 do
	write(y_axis_label[i]:4,' ');
end;

procedure display_values;
var
x,y,i:byte;
continue:char;

begin
clear_screen;
escape:=false;
with data do
begin
writeln('      '); {DEBUG for terminal delay}
axis;
move_cursor(1,1);
write('name: ',name:30,'chart #: ':10,data.chart_number:6,
		'date: ':8,date.month:2,'/',date.day:2,'/',date.year:2);
if sex then writeln('sex: male') else writeln('sex: female');
write('ht: ',height:5:1,'wt: ':6,weight:5:1,
	'S.A.:':5,surface_area:5:1);
writeln('% OWt: ':8,percent_overweight_for_height:5:1,
        'T.B.W.: ':10,total_body_water:5:1);
writeln('age:':5,chronological_age:5:1,'B.A.: ':8,bone_age:5:1,
	'H.A.: ':8,height_age:5:1);



x:= 7;
y:= 5;
for time:= 1 to 14 do
	begin
	for results:= 1 to 14 do
		begin
		move_cursor(x,y);
		if abs(values[time,results]) <> 999.0 then
			write(values[time,results]:4:1)  else
			write('    '); {4 spaces}
		x:= x + 5;
		end;
	y:= y + 1;
	x:= 7;
	end;

end; {of with data}
end;

 

procedure values_calculation;
var
num:byte;


begin
with data do 
begin

for results:= 1 to 14 do
begin
max:= values[1,results];
peak_time:= 1;

if values[1,results] = -999.0 then
	begin
	sum:= 0.0;
	num_values:= 0;
	min:=999.0;
	end;

if values[1,results] > -999.0 then
	begin
	sum:= values[1,results] ;
	num_values:= 1;
	min:= values[1,results];
	end;

	for time := 2 to 14 do
	begin
	if max < values[time,results] then
		begin
		max:= values[time,results];
		peak_time:= time;
		end;
	
	if (values[time,results] > -999.0) and (min > values[time,results])
				then min:= values[time,results];

	if values[time,results] > -999.0 then
			begin
			sum:= sum + values[time,results] ;
			num_values:= num_values + 1;
			end;
	end;

average:= sum/num_values;
values[15,results]:= max;
values[16,results]:= min;
if average = 0.0 then values[17,results]:= -999.0 else
		      values[17,results]:= average;

case peak_time of 
1: values[18,results]:= -30.0;
2: values[18,results]:= -1.0;
3: values[18,results]:= 15.0;
4: values[18,results]:= 30.0;
5: values[18,results]:= 45.0;
6: values[18,results]:= 60.0;
7: values[18,results]:= 90.0;
8: values[18,results]:= 120.0;
9: values[18,results]:= 150.0;
10: values[18,results]:= 180.0;
11: values[18,results]:= 210.0;
12: values[18,results]:= 240.0;
13: values[18,results]:= 300.0;
14: values[18,results]:= 360.0;
end;

if average = 0.0 then values[18,results]:= -999.0;
end;
end;
end;



procedure mistake;
label 1,2;
var
strtime,strtest:$string80;
xtime,xtest: axis_label;
matrix,i,ii,j,time,test:byte;
found,finished:boolean;

begin
finished:= false;
repeat
1: erase_lines(1,1);
move_cursor(1,1);
write('Enter test and time of incorrect data, e.g. BS <cr> 30 <cr> ');
move_cursor(65,1);
i:=0;
	repeat
	i:= i + 1;
	keyin(xtest[i]);
	write(xtest[i]);
	until (xtest[i] = chr(13)) or (i = 4);
	if xtest[i] = chr(13) then
		for ii:= i to 4 do xtest[ii]:= ' ';

	if xtest[1] = chr(27) then
		begin
		finished:= true;
		goto 2;
		end;

move_cursor(75,1);
i:= 0;
		repeat
	i:= i + 1;
	keyin(xtime[i]);
	write(xtime[i]);
	until (xtime[i] = chr(13)) or (i = 4);
	if xtime[i] = chr(13) then
		for ii:= i to 4 do xtime[ii]:= ' ';

erase_lines(1,1);

time:= 255;
test:= 255;
matrix:= 1;
found:= false;
repeat
if xtime = x_axis_label[matrix] then
		begin
		found:= true;
		time:= matrix;
		end;
matrix:= matrix + 1;
until (found) or (matrix > 14);
matrix:= 1;
found:= false;
repeat
if xtest = y_axis_label[matrix] then
		begin
		found:= true;
		test:= matrix;
		end;
matrix:= matrix + 1;
until (found) or (matrix > 14);

if time = 255 then
	begin
	erase_lines(1,1);
	move_cursor(1,1);
write('You have entered an invalid time, please reenter test & time: ');
	goto 1;
	end;

if test = 255 then
	begin
	erase_lines(1,1);
	move_cursor(1,1);
write('You have entered an invalid test, please reenter test & time: ');
	goto 1;
	end;
 
prompt(test*5+4,time+2,0,'omit',false);
data.values[time,test]:= -999.0;

2: until finished;
erase_lines(1,1);
values_calculation;
end;



procedure choose_and_exclude_test;
var
test:char;

begin
	clear_screen;
	writeln;
	writeln('A-  BLOOD SUGAR');
	writeln('B-  INSULIN');
	writeln('C-  GROWTH HORMONE');
	writeln('D-  LH');
	writeln('E-  FSH');
	writeln('F-  CORTISOL');
	writeln('G-  PROLACTIN');
	writeln('H-  TSH');
	writeln('I-  TESTOSTERONE');
	writeln('J-  DS');
	writeln('K-  ACTH');
	writeln('L-  T4');
	writeln('M-  TBGI');
	writeln('N-  TT3');
	writeln('O-  finished excluding tests');
	writeln;
	write('Please enter the letter corresponding to the test: ');
repeat
	repeat
	move_cursor(61,19);
	keyin(test);
	if (ord(test) > 96) and (ord(test) < 123) then
		test:= chr(ord(test)-32);
	write(test);
	until test in ['A'..'O'];
	results:= ord(test)-64;
	if results < 15 then
		begin
writeln;
write('Values for ',y_axis_label[results],' will be ignored during analysis.');
	for time:= 1 to 18 do
	data.values[time,results]:= -999.0
	end;
until results = 15;
end;

procedure offer_hardcopy;
var
ch:char;

begin
clear_screen;
repeat
move_cursor(1,5);
write('Do you want a hardcopy of the data? y/n  ');
keyin(ch);
until ch in ['y','n','Y','N'];
if ch in ['y','Y'] then hardcopy:= true else hardcopy:= false;
clear_screen;
if hardcopy = false then rewrite('con:',output) else 
	begin
	rewrite('lst:',output);
writeln('Prepare printer, then enter any character to initiate printing.');
	keyin(ch);
	end;
end;


procedure load_statistical_array;
label 1;
var
continue:char;
last_record:integer;
exclude:boolean;

procedure select_data;
label 1;
var
exclusion:char;

begin
	display_values;
	move_cursor(1,19);
writeln('Considering this patient''s lab results, choose one: ');
writeln('1-  Accept all data as displayed for statistical analysis.');
writeln('2-  Exclude all values for 1 or more test(s) from analysis.');
writeln('3-  Exclude only one or more value(s) from statistical analysis.');
writeln('4-  Exclude patient''s entire lab values from analysis.');
repeat
move_cursor(55,19);
keyin(exclusion);
until exclusion in ['0'..'4'];
erase_lines(19,5);
exclude:=false;
case exclusion of
'1': goto 1;
'2': choose_and_exclude_test;
'3': mistake;
'4': exclude:= true;
end;

1:
end; {of procedure}


procedure print_raw_data;
var
stop,start:integer;
i:byte;
ch:char;

begin
for results:= 1 to 14 do
begin
start:= 2;
	repeat
	if (start + 7) > last_record then stop:= last_record else
					  stop:= start + 7;
	if hardcopy then write(output,chr(12)) else
		begin
		erase_lines(1,1);
		move_cursor(1,1);
		write('Enter any character to continue. ');
		keyin(ch);  
		clear_screen;
		end;
for i:= 1 to 3 do writeln(output);

writeln(output,'RAW DATA FOR TEST    :',y_axis_label[results]:4);
writeln(output);
write(output,'   ');
for i:= start to stop do write(output,'#':5,i:2);
writeln(output);
for time:= 1 to 18 do
	begin
	if time < 15 then write(output,x_axis_label[time]:4) else
	case time of
	15: write(output,'max ');
	16: write(output,'min ');
	17: write(output,'ave ');
	18: write(output,'peak');
	end;

for rec:= start to stop do
	if abs(statistics[rec,results,time]) <> 999.0 then
	write(output,statistics[rec,results,time]:7:1) else
	write(output,' ':7);
	writeln(output);
	end;
start:= start + 8;
until start > last_record;

end;
end;


begin
reset(filename,fin);
if eof(fin) then
	begin
	clear_screen;
	writeln('FILE NOT FOUND!');
	writeln;
	writeln('Enter any character to continue. ');
	keyin(continue);
	goto 1;
	end;
last_record:= number_records(filename);
with data do
begin
for rec:= 2 to last_record do
	begin
	read(fin:rec,data);
	select_data;
	for results:= 1 to 14 do
		for time:= 1 to 18 do
		if exclude = true then statistics[rec,results,time]:=-999.0
		else statistics[rec,results,time]:= values[time,results];
	end;
offer_hardcopy;
print_raw_data;
end;
1:
end; {of procedure}


procedure stat_average;
var
standard_deviation,max,min,average,sum:real;
last_record,counter:integer;
i:byte;
ch:char;


procedure calc_variance;
var
i:byte;
variance,xvariance:real;

begin
xvariance:=0.0;
for i:= 2 to last_record do
if abs(statistics[i,results,time]) <> 999.0 then
	xvariance:=xvariance + sqr(statistics[i,results,time]-average);
variance:=xvariance/(counter-1);
standard_deviation:= sqrt(variance);
end;

begin
clear_screen;
offer_hardcopy;
last_record:= number_records(filename);
writeln;
if hardcopy then writeln('Now printing.');
for results:= 1 to 14 do
	begin
	if hardcopy then write(output,chr(12)) else
	begin
	erase_lines(1,1);
	move_cursor(1,1);
	write('Enter any character to continue. ');
	keyin(ch);
	clear_screen;
	end;
for i:= 1 to 3 do writeln(output);

writeln(output,'STATISTICAL ANALYSIS FOR TEST   : ',y_axis_label[results]);
writeln(output);
writeln(output,'ave':9,'n':5,'s.d.':7,'max':6,'min':7);   
writeln(output);

for time:= 1 to 18 do
begin
sum:= 0.0;
counter:= 0;
max:= statistics[1,results,1];
if statistics[1,results,1] = -999.0 then
	min:= 999.0 else min:= statistics[1,results,1];
	
if time < 15 then write(output,x_axis_label[time]:4) else
	case time of 
	15: write(output,'max ');
	16: write(output,'min ');
	17: write(output,'ave ');
	18: write(output,'peak');
	end;
for rec:= 2 to last_record do
	begin
	if abs(statistics[rec,results,time]) <> 999.0 then
		begin
		sum:= sum + statistics[rec,results,time];
		counter:= counter + 1;
		if statistics[rec,results,time] > max then
		  max:= statistics[rec,results,time];
 		if statistics[rec,results,time] < min then
		  min:= statistics[rec,results,time];
		end;
	end;

average:= sum/counter;
if (average = 0.0) or (abs(average) = 999.0) then
	write(output,' ':18) else
		begin
		calc_variance;
		write(output,average:7:1);
		write(output,counter:4,standard_deviation:7:1);
		end;

if abs(max) <> 999.0 then write(output,max:7:1) else
			  write(output,' ':7);
if abs(min) <> 999.0 then write(output,min:7:1) else
		          write(output,' ':7);
writeln(output);

if hardcopy then writeln(output);	
end;
end;
end;


procedure get_filename;
var
newfile:boolean;

begin
clear_screen;
writeln;
writeln('Enter name of patient data file as:      drive:name.extension ');
writeln;
writeln('Drive is either ''A'' or ''B''  .');
writeln('Name may be up to 14 letters.   ');
writeln('Extention may be up to 3 letters.');
move_cursor(10,10);
write('---->   ');
read(filename);

reset(filename,fin);
if eof(fin) then
	begin
	prompt(10,15,0,'A file by that name is NOT FOUND. ',false);
	newfile:= query(10,16,'Is this a new file?    y/n');
	if newfile then rewrite(filename,fin) else get_filename;
	end;
end;

{*************************** main program *******************************}
begin
get_filename;
initialize;
init_statistical_array;
load_statistical_array;
stat_average;
end.
