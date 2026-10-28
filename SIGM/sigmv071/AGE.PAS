
program xage; {$c-,f-,m-}
type
byte=0..255;

date=record
	month:byte;
	day:byte;
	year:byte;
	end;

var
reference_date,current_date,birthday:date;
cont:char;
continue:boolean;

function age (current_date,birthday:date):real;
var
days_elapse_from_birth_to_current_date,years,days,months:integer;
years_of_age:byte;
months_of_age:real;
days_from_reference_to_current_date,days_birthday_to_reference:integer;




function elapse_time(date_to_use:date):integer;  {internal function}
var
pastdays:byte;

begin
years:=0;
days:=0;
years:= (date_to_use.year - reference_date.year); 

case date_to_use.month of 
1:	days:= 0;
2:	days:= 31;
3:	days:= 59;
4:	days:= 90;
5:	days:= 120;
6:	days:= 151;
7:	days:= 181;
8:	days:= 212;
9:	days:= 243;
10:	days:= 273;
11:	days:= 304;
12:	days:= 334;
end;

days:= days + date_to_use.day + (years div 4); {+ days so far in month
						  and correct for leap years}
days:= days + (years*365); {now add in days of years gone by}
{days should now = total days from date of test to reference year }
elapse_time:=days;
end; {of internal procedure elapse time}



begin { of function age}
years_of_age:=0;
months_of_age:=0;

days_from_reference_to_current_date:= elapse_time(current_date);
days_birthday_to_reference:= elapse_time(birthday);

days_elapse_from_birth_to_current_date:=
 (days_from_reference_to_current_date - days_birthday_to_reference); 

years_of_age:= days_elapse_from_birth_to_current_date div 365;
months_of_age:=
	(days_elapse_from_birth_to_current_date mod 365) div 30;

writeln('years and months of age are= ',years_of_age:3,months_of_age:5:3);
{debug}


if months_of_age > 9 then months_of_age:= months_of_age/100 else 
		          months_of_age:= months_of_age/10;

{convert months of age to decimal representing number of months, not
 fraction of year, eg. age = 12.5 means 12 years and 5 months}


age:= years_of_age + months_of_age;

end; {of procedure}


begin {of main program}
continue:= true;

reference_date.month:=1;
reference_date.day:=1;
reference_date.year:=40;

while continue do
	begin
	writeln(chr(27),'[2J',chr(27),'[1;1H'); {clear screen}
   writeln('Calculate the age of a patient given birth and current date.');

write('Enter current date as  mm, dd,  yy   ');
readln(current_date.month, current_date.day, current_date.year);

writeln;
write('Enter date of birth as mm, dd, yy  ');
readln(birthday.month, birthday.day, birthday.year);



writeln;
writeln;
writeln('Age is : ',age(current_date,birthday):2:2, ' years');

readln(cont);
if cont = chr(27) then continue:= false;
end; {of while}
end. 