EXTERNAL progname::date;

{	This is a complete collection of the various date routines,
	set up for separate compilation under Pascal/Z, ver 3.2 or
	later.

	DATE.LIB contains the necessary subprogram calls for inclusion
	in the main program.

	Note that <progname> has to be substituted with the name of the
	main program to be separately compiled.

	The following global declarations must be made in the main
	program:
		TYPE	string0 = string 0;
			string255 = string 255;
			byte = 0..255;
		PROCEDURE setlength;
		FUNCTION length;
}

PROCEDURE prompt (msg : string255);

CONST	msglength = 12;	{ should be longer than longest message }
	leader = '.';	{ could be a space if desire }
	endprompt = ' =>  ';

VAR	count : integer;
	esc : char;

begin
	append (msg,' ');
	if length(msg) < msglength then
		for count := succ(length(msg)) to msglength do
			append (msg,leader);
	write (msg,endprompt)
end;

PROCEDURE getdate (msg : string255; VAR mo, da, yr : byte);

CONST	yrspan = 89;
	yrbase = 10;

VAR	ch : char;
	good : boolean;
	temp : integer;

begin
  	repeat
		good := true;
		prompt (msg);
		readln (mo,ch,da,ch,temp);
		temp := temp mod 100 - yrbase;
		if (da < 1) or (da > 31) or (mo < 1) or (mo >12)
			or (temp < 0) or (temp > yrspan) then
			begin
				good := false;
				writeln (' *** Bad date ***')
			end
	until good;
	yr := temp
end;

FUNCTION makedate (msg : string255) : integer;

CONST	yrbase = 10;

VAR	days : integer;
	da, mo, yr : byte;
	str : string255;

begin
	getdate (msg,mo,da,yr);
	case mo of
		1 : days := 0;
		2 : days := 31;
		3 : days := 59;
		4 : days := 90;
		5 : days := 120;
		6 : days := 151;
		7 : days := 181;
		8 : days := 212;
		9 : days := 243;
		10 : days := 273;
		11 : days := 304;
		12 : days := 334;
		end;
	days := days + (yr*365) + (yr div 4) + da;
	if ((yr + yrbase) mod 4 = 0) and (mo > 2) then days := days + 1;
	makedate := days
end;

PROCEDURE rgetdate (msg : string255; minyr, maxyr : byte;
			VAR mo, da, yr : byte);

CONST	yrspan = 89;
	yrbase = 10;

VAR	ch : char;
	good : boolean;
	temp : integer;

begin
  	repeat
		good := true;
		prompt (msg);
		readln (mo,ch,da,ch,temp);
		temp := temp mod 100;
		if (da < 1) or (da > 31) or (mo < 1) or (mo >12)
			or (temp < minyr) or (temp > maxyr) then
			begin
				good := false;
				writeln (' *** Bad date ***')
			end
	until good;
	yr := temp - yrbase
end;

FUNCTION rmakedate (msg : string255; minyr, maxyr : byte) : integer;

CONST	yrbase = 10;

VAR	days : integer;
	da, mo, yr : byte;
	str : string255;

begin
	rgetdate (msg,minyr,maxyr,mo,da,yr);
	case mo of
		1 : days := 0;
		2 : days := 31;
		3 : days := 59;
		4 : days := 90;
		5 : days := 120;
		6 : days := 151;
		7 : days := 181;
		8 : days := 212;
		9 : days := 243;
		10 : days := 273;
		11 : days := 304;
		12 : days := 334;
		end;
	days := days + (yr*365) + (yr div 4) + da;
	if ((yr + yrbase) mod 4 = 0) and (mo > 2) then days := days + 1;
	rmakedate := days
end;

PROCEDURE brkdate (days : integer; VAR mo, da, yr, weekday : byte);

CONST	yrbase = 10;
	yrfix = yrbase - 1;

VAR	data, temp, adjust, yradj : integer;

begin
	adjust := 1 + yrfix mod 4 + (((yrfix mod 28) div 4) * 5);
	yradj := (yrbase mod 4) * 365;
	weekday := (days + adjust) mod 7;
	data := trunc((days + yradj) / 365.25) - yrbase mod 4;
	yr := data + yrbase;
	temp := days - (365 * data) - (data + yrfix mod 4) div 4;
	mo := 0;
	data := 0;
	repeat
		if (data < temp) then
			begin
			mo := mo + 1;
			temp := temp - data
			end;
		case mo of
			1,3,5,7,8,10,12 : data := 31;
			4,6,9,11 : data := 30;
			2 : if (yr mod 4 = 0) then data := 29
				else data := 28
			end
	until (data >= temp) or (mo = 12);
	da := temp
end;

FUNCTION dastrlong (days : integer; withday : boolean) : string255;

CONST	zero = 48;

VAR	day, mo, date, yr : byte;
	str, str2 : string255;

begin
	brkdate (days,mo,date,yr,day);
	if withday then
		begin
		case day of
			0 : str := 'Sunday';
********************************************************************************************************************************;
			6 : str := 'Saturday'
			end;
		append (str,', ')
		end
		else setlength (str,0);
 	case mo of
		1 : str2 := 'January';
		2 : str2 := 'February';
		3 : str2 := 'March';
		4 : str2 := 'April';
		5 : str2 := 'May';
		6 : str2 := 'June';
		7 : str2 := 'July';
		8 : str2 := 'August';
		9 : str2 := 'September';
		10 : str2 := 'October';
		11 : str2 := 'November';
		12 : str2 := 'December'
		end;
	append (str,str2);
	append (str,' ');
	if (date > 9) then append (str,chr((date div 10) + zero));
	append (str,chr((date mod 10) + zero));
	append (str,', 19');
	append (str,chr((yr div 10) + zero));
	append (str,chr((yr mod 10) + zero));
	dastrlong := str
end;

FUNCTION dastrshort (days : integer; withday : boolean) : string255;

CONST	zero = 48;

VAR	day, mo, date, yr : byte;
	str, str2 : string255;

begin
	brkdate (days,mo,date,yr,day);
	if withday then
		begin
			case day of
				0 : str := 'Sun';
				1 : str := 'Mon';
				2 : str := 'Tues';
				3 : str := 'Wed';
				4 : str := 'Thurs';
				5 : str := 'Fri';
				6 : str := 'Sat'
				end;
			append (str,', ')
		end
		else setlength (str,0);
	case mo of
		1 : str2 := 'Jan';
		2 : str2 := 'Feb';
		3 : str2 := 'Mar';
		4 : str2 := 'Apr';
		5 : str2 := 'May';
		6 : str2 := 'June';
		7 : str2 := 'July';
		8 : str2 := 'Aug';
		9 : str2 := 'Sept';
		10 : str2 := 'Oct';
		11 : str2 := 'Nov';
		12 : str2 := 'Dec'
	end;
	append (str,str2);
	append (str,' ');
	if (date > 9) then append (str,chr((date div 10) +********************************************************************************************************************************chr((yr mod 10) + zero));
	dastrshort := str
end;

FUNCTION strbyte (val : byte; withspace : boolean) : string255;

CONST	zero = 48;

VAR	ch : char;
	str : string255;

begin
	setlength (str,0);
	if (val div 10 = 0) and withspace
		then str := ' '
		else str := chr (val div 10 + zero);
	append (str,chr(val mod 10 + zero));
	strbyte := str
end;

FUNCTION dastrfixed (days : integer; spaces : boolean) : string255;

CONST	zero = 48;
	separator = '-';

VAR	day, mo, da, yr : byte;
	str : string255;

begin
	brkdate (days,mo,da,yr,day);
	setlength (str,0);
	append (str,strbyte(mo,spaces));
	append (str,separator);
	append (str,strbyte(da,spaces));
	append (str,separator);
	append (str,strbyte(yr,false));
	dastrfixed := str
end;



