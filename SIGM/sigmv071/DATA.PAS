 

program xdata;{$P+}
{$c-,m-,f-}
label 1;
const
defaultpad = '                                                           ';
male = true;
female = false;

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
normal_value_flag, error, terminate, continue,escape:boolean;
rec:integer;
strvalue:$string80;
x_axis_label,y_axis_label: array[1..14] of axis_label;


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

function strtoreal (str:$string80):real;
label 1;

var
decval,sign,val:real;
decimal,error:boolean;
l,i,len:integer;

begin
val:=0.0;
decval:=0.0;
len:=length(str);
l:=len;
error:=false;
decimal:=false;
i:=1;
sign:= 1.0;

if len = 0 then
	begin
	error:= true;
	goto 1;
	end;

while (decimal = false) and (i < len + 1 ) do
begin
	case str[i] of
	'-': sign:= -1.0;
	'.': decimal:= true;
	'0','1','2','3','4','5','6','7','8','9':
		val:=(val*10) + (ord(str[i]) - 48);
	end;
i:= i+ 1;
end;

while (decimal) and (l > i-1) do
	begin
		if str[l] in ['0'..'9'] then
		decval:= (decval*0.1) + ((ord(str[l])-48)*0.1);
		l:=l-1;
	end;
1:
strtoreal:=sign*(decval+val);
end;

function input_data (x,y,len:byte; alphanumeric:boolean;
	             maximum_value,minimum_value:real):$string80;

label 1;
var
data:$string80;
realdata:real;
i:byte;

procedure correct(x,y:byte);
var 
i,a,b:byte;
begin
	erase_lines(1,1);
	write(chr(7));
	move_cursor(1,1);
	
	if (length(data)> len) then write ('TERM TOO LONG');

	if (alphanumeric = false) and
	((realdata > maximum_value) or (realdata < minimum_value)) then
	write ('VALUE OUT OF RANGE');

	move_cursor(x,y);
	write(' ');
	a:=x;
	b:=y;

	for i:= 1 to length(data) do
	begin
		move_cursor(a,b);
		write (' ');
		a:= a + 1;
	end;

	move_cursor(x,y);
	write('_');
	a:=x;
	b:=y;
	for i:= 1 to (len-1) do
		begin
		move_cursor(a,b);
		write('_');
		a:= a+ 1;
		end;
	move_cursor(x,y);
	read(data);
	realdata:=strtoreal(data);
	erase_lines(1,1);

end;


begin
move_cursor(x,y);
read(data);
if (length(data) > 0) and (ord(data[1]) <> 27) then
		realdata:=strtoreal(data) else goto 1;

while (length(data) > len) or ((alphanumeric = false) and
	((realdata > maximum_value) or (realdata < minimum_value)))
				do correct(x,y);

1:  if length(data) = 0 then data:= '-999';

if length(data) < len then for i:= length(data) to len do append(data,' ');
input_data:=data;
end;


function ucase (x:$string80):$string80;
label 1;
var
i,len,ascii:integer;
ucasex:$string80;

begin
setlength(ucasex,0);
len:=length(x);
if (len = 0) or (len > 4) then goto 1;
for i:= 1 to len do
	if (ord(x[i]) > 96) and (ord(x[i]) < 123) then
	append(ucasex,chr(ord(x[i])-32)) else
	append(ucasex,x[i]);
ucase:=ucasex;
1:
  end;


procedure calculate(current_number_of_records:integer);
var
i,thm,hm,o,t,h,th:byte;
begin
o:=0;
t:=0;
h:=0;
thm:=0;
hm:=0;
th:=current_number_of_records div 1000;
thm:= current_number_of_records mod 1000;
h:= thm div 100;
hm:= thm mod 100;
t:= hm div 10;
o:= hm mod 10;

with  data do
begin
chart_number[1]:= '0';
chart_number[2]:= '0';
chart_number[3]:= chr(th + 48);
chart_number[4]:= chr(h + 48);
chart_number[5]:= chr(t + 48);
chart_number[6]:= chr(o + 48);

end;
end;


procedure create_first_record;
var
j,i:byte;
number:integer;

begin
rewrite(filename,fin);
with data do
	begin
	name:='                              ';
	chart_number:='000001';
	date.month:='00';
	date.day:='00';
	date.year:='00';
	sex:=true;
	weight:= 0.0;
	height:= 0.0;
	surface_area:=0.0;
	chronological_age:=0.0;
	bone_age:= 0.0;
	height_age:=0.0;
	percent_overweight_for_height:=0.0;
	total_body_water:= 0.0;
	pad:=defaultpad;
	for i:= 1 to 18 do
		for j:= 1 to 14 do values[i,j]:= -999.0;
	write(fin:1,data);
	end;
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
	create_first_record;
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



procedure axis(pass:byte);
var
i:byte;

begin
writeln('     ');{DEBUG delay...terminal does not seem to respond fast enough}
for i:= 6 to 19 do
	begin
	move_cursor(1,i);
	write(x_axis_label[i-5]:4);
	end;
if pass <> 2 then
	begin
	prompt(1,21,0,'max',false);
	prompt(1,22,0,'min',false);
	prompt(1,23,0,'ave',false);
	prompt(1,24,0,'peak',false);
	end;

move_cursor(3,3);
write('chart number: ',data.chart_number:6,'Name: ':10,data.name:30);

case pass of
1:    	move_cursor(9,5);
3:	move_cursor(1,5);
else:   move_cursor(6,5);
end;

if pass = 3 then write ('TIME     PATIENT   NORMAL (AVE)   DEVIATION') else
for i:= 1 to 14 do
	write(y_axis_label[i]:5);
end;


procedure get_chart_number;
label 1;
var
xchart_number:id;
xname:array[1..30] of char;
numrecs,i:integer;
number:$string80;
cno,found:boolean;
ch:char;

begin
cno:=false;
clear_screen;
move_cursor(1,8);
write('Enter ''NORMAL'' if you wish to display or alter normal values.');
prompt(1,10,6,'Enter either the patient''s name or chart number: ',false);
number:= input_data(50,10,30,true,0.0,0.0);
writeln;
writeln('One moment, please.');
if (ord(number[1]) > 47) and (ord(number[1]) < 58) then
	begin
	cno:= true;
	for i:= 1 to 6 do xchart_number[i]:= number[i];
	end;
if cno = false then 
	begin
	for i:= 1 to 30 do
	xname[i]:=number[i];
	end;

reset(filename,fin);
numrecs:=number_records(filename);
i:=0;
normal_value_flag:= false;
error:= false;
with data do
begin
if (xname = 'NORMAL                        ')
or (xname = 'normal                        ') then
	begin
	normal_value_flag:= true;
	read(fin:1,data);
	norms.values:=data.values;
	rec:=1;
	goto 1;
	end;

repeat
i:= i+1;
read(fin:i,data);
case cno of
true:if xchart_number = data.chart_number then found:= true else found:= false;
false:if xname = data.name then found:=true else found:= false;
end; {of case}
until (found) or (i = numrecs);
if found then rec:= i else error:= true;

1:end;
if error then
	begin
	clear_screen;
	move_cursor(1,10);
	if cno then writeln('Chart number not found !') else 
	            writeln('Name not found !');
	writeln;
	writeln('Enter any character to continue.');
	keyin(ch);
	end;
clear_screen;
end;



procedure display_values(normal_value_flag, displayed_for_correction:boolean);
var
x,y,i:byte;
continue:char;

begin
clear_screen;
escape:=false;
writeln('      '); {DEBUG for terminal delay}
axis(1);
if normal_value_flag then
	begin
	move_cursor(3,3);
	write('NORMAL VALUES');
	end;
x:= 7;
y:= 6;
for time:= 1 to 18 do
	begin
	for results:= 1 to 14 do
		begin
		move_cursor(x,y);
		if abs(data.values[time,results]) <> 999.0 then
			write(data.values[time,results]:4:1)  else
			write('    '); {4 spaces}
		x:= x + 5;
		end;
	y:= y + 1;
	if y = 20 then y:= 21;
	x:= 7;
	end;
if displayed_for_correction = false then
	begin
	move_cursor(1,1);
	write('Enter any character to continue or ''ESC'' to return to menu.');
	keyin(continue);
	if ord(continue) = 27 then escape:= true;
	end;
end;



procedure print(desire_hardcopy:boolean);

label 1,2;
var
i:integer;
continue:char;
recursive,all,more:boolean;

procedure hardcopy(normal_value_flag:boolean);
var
counter,j:byte;
output:text;

begin
rewrite('lst:',output);

if recursive = false then
begin
write('Prepare printer, then enter any character to initiate listing. ');
keyin(continue);
clear_screen;
writeln('Now printing results.');
end;

write(output,chr(12));
for counter:= 1 to 3 do writeln(output);
with data do
begin

if normal_value_flag then chart_number:= 'NORMAL';
writeln(output,'chart_number: ',chart_number, ' Name: ',name);
writeln(output);
write(output,'    '); {4 spaces}
for counter:= 1 to 14 do write(output,y_axis_label[counter]:8);
writeln(output);

for counter:= 1 to 18 do
	begin
	if counter < 15 then write(output,x_axis_label[counter]:4,' ') else
		case counter of
		15: write(output,'max  ');
		16: write(output,'min  ');
		17: write(output,'ave  ');
		18: write(output,'peak ');
		end;

for j:= 1 to 14 do
	if abs(values[counter,j]) = 999.0 then
		write(output,' ':8) else
		write(output,values[counter,j]:8:1);

	writeln(output);
	writeln(output);
	end;

end;
end;

begin   {of procedure print}
reset(filename,fin);
if eof(fin) then
	begin
	writeln('NO FILE PRESENT!');
	writeln;
	write('Enter any character to continue. ');
	keyin(continue);
	goto 1;
	end;

clear_screen;
all:= query(1,10,'Do you wish to display all results for ALL patients? y/n ');

case all of
false:	begin
	repeat
	get_chart_number;
	
	case desire_hardcopy of
	true:	if error = false then hardcopy(normal_value_flag) else
				      erase_lines(10,3);
	false:  if error = false then display_values(false,false) else
			              erase_lines(10,3);
	end;
if (error) or (escape) then goto 1;  {goto menu if record not found or done}

error:=false;
erase_lines(1,1);
more:=query(1,1,'Do you wish to display data for another patient? y/n  ');
	until more  = false;
	end;

true:	begin
	rec:= number_records(filename);
	recursive:=false;
	for i:= 1 to rec do
		begin
		escape:= false;
		read(fin:i,data);
			case desire_hardcopy of
			true: if i= 1 then hardcopy(true) else hardcopy(false);
			false: if i= 1 then display_values(true,false) else
				            display_values(false,false);
			end;
		recursive:= true;
		if escape then goto 1;
		end;
	end;
end;	{of case}
1:
end;
 

procedure values_calculation;

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


y:=21;
prompt(1,21,0,'max',false);
prompt(1,22,0,'min',false);
prompt(1,23,0,'ave',false);
prompt(1,24,0,'peak',false);
for time:= 1 to 4 do
	begin
	for results:= 1 to 14 do
		begin 
		move_cursor(results*5+2,y);
		if (abs(values[time+14,results]) = 999.0) then
			write('    ') else
			write(values[time+14,results]:4:1);
		end;
	y:= y+ 1;
	end;
end; {of with data}
end;



procedure mistake (shift_over_x_axis_flag:boolean);
label 1,2;
var
strtime,strtest:$string80;
xtime,xtest: axis_label;
matrix,shift,i,j,time,test:byte;
found,finished:boolean;

begin
finished:= false;
repeat
erase_lines(1,1);
move_cursor(1,1);
write('Enter test and time of incorrect data, e.g. BS <cr> 30 <cr> ');
1: strtest:= input_data(65,1,4,true,0.0,0.0);
	if strtest[1] = chr(27) then
		begin
		finished:= true;
		goto 2;
		end;
	strtest:= ucase(strtest);
	strtime:= input_data(75,1,4,true,0.0,0.0);
	
	for i:= 1 to 4 do
		begin
		xtime[i]:= strtime[i];
		xtest[i]:= strtest[i];
		end;
erase_lines(1,1);

time:= 255;
test:= 255;
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
 
if shift_over_x_axis_flag then shift:= 4 else shift:= 2;

prompt(test*5+shift,time+5,0,'     ',false);
strvalue:= input_data(test*5+shift,time+5,4,false,9999.0,0.0);
if strvalue = '-999' then
	data.values[time,test]:= -999.0 else
	data.values[time,test]:= strtoreal(strvalue);

2: until finished;
erase_lines(1,1);
values_calculation;
end;


procedure update_first_record (number_recs:integer);
begin
reset(filename,fin);
with data do
begin
	read(fin:1,data);
	calculate(number_recs);
	data.name:='                              ';{DEBUG}
	write(fin:1,data);
	end;
end;



procedure get_vital_statistics;
var
xname,xchartnumber,xheight,xweight,xage,xboneage,xheightage:$string80;
xmonth,xday,xyear:$string80;
correction,i:byte;
correct:boolean;
wrong,xsex:char;


procedure get_patient_data (entry:byte);  {this procedure internal to above}
begin
case entry of
1:	begin
	prompt(1,2,30,'{1} Name: ',false);
	xname:= input_data(10,2,30,true,0.0,0.0);
	xname:=ucase(xname);
	end;
2:	begin
	prompt(50,2,6,'{2} Chart Number: ',false);
	xchartnumber:= input_data(67,2,6,true,0.0,0.0);
	end;
3:	begin
	repeat
	move_cursor(1,4);
	write('{3} Sex (m/f) ');
	read(xsex);
	until xsex in ['m','f','M','F'];
	end;
4:	begin
	prompt(20,4,0,'{4} Height (cm): ',false);
	xheight:= input_data(41,4,5,false,200.0,0.0);
	end;
5: 	begin
	prompt(50,4,0,'{5} Weight (kg): ',false);
	xweight:= input_data(71,4,5,false,300.0,0.0);
	end;
6:	begin
	prompt(1,6,0,'{6} Age (yr.mo): ',false);
	xage:= input_data(20,6,5,false,30.0,0.1);
	end;
7:	begin
	prompt(30,6,0,'{7} Bone Age (yr.mo): ',false);
	xboneage:= input_data(52,6,4,false,20.0,0.0);
	end;
8:	begin
	prompt(1,8,0,'{8} Height Age (yr.mo): ',false);
	xheightage:= input_data(25,8,4,false,20.0,0.0);
	end;
9:	begin
	prompt(1,10,2,'{9} date: ',false);
	prompt(13,10,0,'/',false);
	prompt(16,10,0,'/',false);
	xmonth:= input_data(10,10,2,true,0.0,0.0);
	xday:= input_data(14,10,2,true,0.0,0.0);
	xyear:= input_data(17,10,2,true,0.0,0.0);
	end;
end; {of case}
end; {of procedure}


begin
clear_screen;
writeln;
prompt(1,2,0,'{1} Name: ',false);
prompt(50,2,0,'{2} Chart Number: ',false);
prompt(1,4,0,'{3} Sex (m/f): ',false);
prompt(20,4,0,'{4} Height (cm):',false);
prompt(50,4,0,'{5} Weight (kg):',false);
prompt(1,6,0,'{6} Age (yr.mo):',false);
prompt(30,6,0,'{7} Bone Age (yr.mo):',false);
prompt(1,8,0,'{8} Height Age (yr.mo):',false);
prompt(1,10,0,'{9} date: ',false);
prompt(13,10,0,'/',false);
prompt(16,10,0,'/',false);

for i:= 1 to 9 do get_patient_data(i);
repeat
correct:= query(1,15,'Is information correct as entered? y/n');
if correct = false then
	begin
	repeat
	erase_lines(15,1);
	move_cursor(1,15);
	write('Enter number corresponding to incorrect data: ');
	keyin(wrong);
	correction:= ord(wrong) - 48;
	until correction in [1..9];
	erase_lines(15,1);
	get_patient_data(correction);
	end;
until correct;
with data do
begin
for i:= 1 to 30 do name[i]:= xname[i];
for i:= 1 to 6  do chart_number[i]:= xchartnumber[i];
if xsex in ['m','M'] then sex:= male else sex:= female;
height:= strtoreal(xheight);
weight:= strtoreal(xweight);
chronological_age:= strtoreal(xage);
bone_age:=strtoreal(xboneage);
height_age:=strtoreal(xheightage);
for i:= 1 to 2 do 
	begin
	date.month[i]:=xmonth[i];
	date.day[i]:= xday[i];
	date.year[i]:= xyear[i];
	end;
{calc_percent_overweight_for_height;}
surface_area:=exp((0.425*ln(weight)) + (0.725*ln(height)) + 4.274);

		{S.A.= weight^.425 * height^.725 * 71.84  according to}
	        {DuBois & DuBois Arch Int Med 17:863 (1916)}
		
percent_overweight_for_height:=0.0;
total_body_water:= -10.313 + 0.252*weight + 0.154*(height);
end; {of with data}

end; {of procedure}


procedure get_data(flag:byte);
label 1;
var
rec:integer;
esc,num:byte;

begin
reset(filename,fin);
if eof(fin) then create_first_record;
rec:= number_records(filename) + 1;
repeat
with data do
begin
pad:= defaultpad;

if flag > 0 then get_vital_statistics;

clear_screen;
writeln;
move_cursor(1,1);
if flag = 0 then write('   Enter NORMAL laboratory values: ') else
	         write('   Enter patient''s laboratory values: ');
axis(0);
x:= 7;
y:= 6;
for results:= 1 to 14 do
	begin
		time:= 1;
		while (time < 15) do
		begin
		strvalue:= input_data(x,y,4,false,9999.0,0.0);
		case ord(strvalue[1]) of
		27:	begin
			for esc:= time to 14 do 
				values[time,results]:= -999.0;
			time:= 15;
			end;
		else:  begin
			if strvalue = '-999' then
			values[time,results]:= -999.0 else
			values[time,results]:= strtoreal(strvalue);
			time:= time + 1;
			y:= y+ 1;
			end;
		end; {of case}
		end; {of while}
x:= x+ 5;
y:= 6;
end;

continue:= query(1,1,'Is information correct as entered? y/n ');
if continue = false then mistake(false);

values_calculation;
case flag of 
0: write(fin:1,data);
else: write(fin:rec,data);
end;

if flag = 0 then continue:= false else
	continue:= query(1,1,'Do you wish to add another record? y/n ');
if continue then rec:= rec + 1;
end; {of with data}
until continue = false;
if flag > 0 then update_first_record(rec);
end;


procedure set_normal_values;
begin
get_data(0);
end;


procedure get_normal_values;
begin
reset(filename,fin);
read(fin:1,norms);
end;


procedure print_individual_test_results (desire_hardcopy:boolean);
label 1;
var
x,y:byte;
test,continue:char;
output:text;


procedure choose_test;
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
	writeln('O-  display values for a different patient');
	writeln('P-  return to the menu');
	writeln;
	write('Please enter the letter corresponding to the test: ');
	repeat
	move_cursor(61,19);
	keyin(test);
	if (ord(test) > 96) and (ord(test) < 123) then
		test:= chr(ord(test)-32);
	write(test);
	until test in ['A'..'P'];
	results:= ord(test)-64;
	clear_screen;
end;

begin
reset(filename,fin);
if eof(fin) then
	begin
	error:= true;
	goto 1;
	end;
if desire_hardcopy then rewrite('lst:',output);

get_chart_number;
if normal_value_flag = false then get_normal_values;
choose_test;
while results < 16 do
begin

if results = 15 then
	begin
	get_chart_number;
	choose_test;
	end;
if desire_hardcopy = false then axis(3) else
	begin
	clear_screen;
write('Prepare printer, then enter any character to initiate printing.');
	keyin(continue);
	erase_lines(1,1);
	writeln;
	write('Now printing results.');
	end;
with data do
begin

if desire_hardcopy = false then
	begin
	move_cursor(20,3);
	write(y_axis_label[results]);
	end;
if desire_hardcopy then
	begin
	write(output,chr(12));
	for x:= 1 to 3 do writeln(output);
	if normal_value_flag then chart_number:= 'NORMAL';
	write(output,'chart number: ',chart_number, y_axis_label[results]:15);
	writeln(output);
	write(output,'PATIENT':20,'NORMAL (AVE)':22, 'DEVIATION':15);
	writeln(output);
	end;

y:= 6;
for time:= 1 to 18 do
 begin
	case desire_hardcopy of
false:	begin
	move_cursor(10,y);
	if (normal_value_flag) or (abs(values[time,results]) = 999.0) then
		write('    ') else
		write(values[time,results]:4:1);    
	move_cursor(20,y);
	if (abs(norms.values[time,results]) = 999.0) then
		write('    ') else
		write(norms.values[time,results]:4:1);    
	move_cursor(35,y);
	if (abs(values[time,results]) = 999.0) or (normal_value_flag) or
	    (abs(norms.values[time,results]) = 999.0) then
		write('    ') else
	if values[time,results] < norms.values[time,results] then
		write('LOW') else
	if values[time,results] > norms.values[time,results] then
		write('HIGH') else write('     ');
	if y = 19 then y:= y + 2 else y:= y + 1;
	end;

true:	begin
	if time < 15 then write (output,x_axis_label[time]) else
	case time of
	15: write(output,'max ');
	16: write(output,'min ');
	17: write(output,'ave ');
	18: write(output,'peak');
	end;

	if (abs(values[time,results]) = 999.0) or (normal_value_flag) then
		write(output,' ':15) else
		write(output,values[time,results]:15:1);

	if (abs(norms.values[time,results]) = 999.0) then
		write(output,' ':15) else
		write(output,norms.values[time,results]:15:1);

	if (abs(values[time,results]) = 999.0) or (normal_value_flag) or
	   (abs(norms.values[time,results]) = 999.0) then
		write(output,' ':15) else
		if values[time,results] < norms.values[time,results] then
		write(output,'LOW':15) else
	if values[time,results] > norms.values[time,results] then
		write(output,'HIGH':15) else write(output,' ':15);

writeln(output);
end;
end;

end; {of time}
move_cursor(1,1);
write('Enter any character to continue ');
keyin(continue);
choose_test;
end; 
end;
1:
end;



procedure correction;
label 1;
var
i:integer;
ch:char;
continue:boolean;

begin
clear_screen;
reset(filename,fin);
if eof(fin) then
	begin
	move_cursor(1,10);
	writeln('File not found!');
	writeln('Enter any character to continue.');
	keyin(ch);
	goto 1;
	end;

continue:= true;
repeat
get_chart_number;
if error = false then
	begin
	display_values(normal_value_flag,true);
	mistake(true);
	write(fin:rec,data);
	end;
continue:= query(1,1,'Do you wish to correct another patient''s record? y/n ');
until continue = false;

1:
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




procedure menu;
var
ch:char;

begin
error:= false;
clear_screen;
writeln;
writeln('Choose one of the following: ');
writeln;
writeln('1-  Establish or set the normal values');
writeln('2-  Add patient results to file');
writeln('3-  Display on terminal selected test results for a patient');
writeln('4-  Print selected test results for a patient');
writeln('5-  Display on terminal all results for a patient');
writeln('6-  Print all results for a patient');
writeln('7-  Correct selected values or results for a patient''s record');
writeln;
writeln('8-  CHANGE NAME OF PATIENT DATA FILE');
writeln('0-  EXIT program');
writeln;
write('Your selection please:  ');
repeat
move_cursor(25,15);
keyin(ch);
write(ch);
until ch in ['0'..'8'];
case ch of
'1': set_normal_value;
'2': get_data(1);
'3': print_individual_test_results(false);
'4': print_individual_test_results(true);
'5': print(false);
'6': print(true);
'7': correction;
'8': get_filename;
'0': terminate:= true;
end;

end;




{**************************** main program *****************************}

begin
initialize;
terminate:= false;
get_filename;
repeat
menu;
until terminate ;
end.
