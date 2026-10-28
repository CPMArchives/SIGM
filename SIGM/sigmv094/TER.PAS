
external terms::ter(2);



{COPYRIGHT 1982 (C) BY CRAIG RUDLIN, M.D.  ALL RIGHTS RESERVED.}






{*************************** clear screen *******************************}
PROCEDURE CLEAR_SCREEN;
{$C-}
{$R-}
{$M-}
{$F-}
{$U-}

var i,j:byte;
BEGIN
write(chr(27),'[2J',chr(27),'[1;1H');
for i:= 1 to 30 do for j:= 1 to 30 do; {delay so terminal can clear screen}

END;

{*********************** position cursor on screen ***********************}
PROCEDURE MOVE_CURSOR (X,Y:BYTE);
{$C-}
{$F-}
{$M-}
{$U-}
{$R-}
var
lenx,leny:byte;
BEGIN
	begin
	lenx:= trunc(1+ ln(x)/2.30259);
	leny:= trunc(1+ ln(y)/2.30259);
	write(chr(27),'[',y:leny,';',x:lenx,'H');
	end;
END;


{******************* erase lines of text ****************************}
PROCEDURE ERASE_LINES(STARTING_LINE,NUMBER_OF_LINES:BYTE);
{$C-}
{$F-}
{$M-}
{$U-}
{$R-}
VAR
len,I:BYTE;

BEGIN

FOR I:= 1 TO NUMBER_OF_LINES DO
  BEGIN
	move_cursor(1,starting_line);
	 write(chr(27),'[2K'); {code to erase a line}
 STARTING_LINE:=STARTING_LINE + 1;
 END;
END;


{**************** place message on screen ****************************}
PROCEDURE PROMPT (X,Y,LENGTH:BYTE; P:$STRING80;
		  PROTECTED_FIELD_DESIRED:BOOLEAN);
{$R-}
{$C-}
{$F-}
{$M-}
{$U-}
VARŠUNDERLINE:STRING 80;
I:BYTE;

BEGIN
if length = 0 then underline:=' ' else UNDERLINE:='_';{don't put any unnec -}
	FOR I:= 1 TO LENGTH DO APPEND(UNDERLINE,'_');
move_cursor(x,y);
if protected_field_desired = false then WRITE(P,UNDERLINE) else
  write(chr(27),'[0m',P,underline,chr(27),'[1m');
END;


{***************** ASK YES/NO QUESTION *********************************}
FUNCTION QUERY(X,Y:BYTE;MESSAGE:$STRING80):BOOLEAN;
{$C-}
{$M-}
{$F-}
{$R-}
{$U-}
VAR
ANSWER:CHAR;

BEGIN
REPEAT
MOVE_CURSOR(X,Y);
WRITE(MESSAGE);
KEYIN(ANSWER);
UNTIL ANSWER IN ['Y','y','N','n'];
QUERY:= ((ANSWER='Y') OR (ANSWER = 'y')); {Equivalent to if then}
ERASE_LINES(Y,1);
END; {OF PROCEDURE}



procedure check_code(new:boolean;xcode:real;recno:integer);
{$C-}
{$M-}
{$F-}
{$R-}
{$U-}
var
dummy:integer;
used,answer:boolean;


procedure ok_code;  {internal procedure}
{$C-}
{$M-}
{$F-}
{$R-}
{$U-}

label 2;

var
xcode:real;
field:data;

begin

answer:=query(1,24,'DO YOU WANT TO USE THE SAME CODE? Y/N ');
if answer = false then
	begin
	field:=blanks;	

	end_of_input:=false;
	end_of_record:=false;
	end_of_field:=false;

	prompt(1,22,10,'ENTER NEW CODE <TAB>: ',false);
	field:= input(17,22,10, lower_case,alphanumric,field);	

2:xcode:= arraytoreal(field);
	
		if error then 
		begin
		field:=blanks;
		prompt(17,22,10,' ',false); {erase incorrect entry}
		end_of_record:=false;{re-set flag}
		repeat
		field:= input(17,22,10, lower_case,alphanumric,field);
		until (end_of_field) or (end_of_record) ;
		error:=false;
		goto 2; {try this again!}
		end;





	
	if new then newterms.code:=xcode else terms.code:=xcode;
	end;

end; {of internal procedure}


begin {******* of check code *******}



answer:=true;
used:=false;


dummy:=2;  {first term is in record number 2}

repeat
read(fnumterms:dummy,terms);
if xcode = terms.code then 
		begin
		if used = false then
			begin
			clear_screen;
 		prompt(1,1,0,'FOLLOWING TERMS HAVE THE SAME CODE:',false);
			writeln;
			end;
			writeln(terms.term);
			used:=true;
			end;
dummy:=dummy + 1;
until dummy > numrecs - 1; {******** should this be minus 1 or just numrecs?}

if used then ok_code;

end;



procedure show_information(hardcopy:boolean);
{$C-}
{$R-}
{$F-}
{$M-}
{$U-}
var
output:text;
num:integer;
dummy:byte;
assigned_units:xtest_units;

begin
with terms do
begin

if hardcopy then rewrite('lst:',output) else rewrite('con:',output);

write(output,term:21);
if needs_units = false then writeln(output,code:10:2) else
		begin
		write(output,trunc(code):10);
		num:=trunc(((code-trunc(code))+0.001)*100.0);
		for dummy:= 1 to num do assigned_units:= succ(assigned_units);
		writeln(output,'UNITS: ':10,assigned_units:8);
		end;


end;
end;




function input (x,y,len:byte;xucase,xletters_only:boolean;field:data):data;
{$R-}
{$C-}
{$M-}
{$F-}
{$U-}
var
end_of_field:boolean;
dummy,counter:byte;
letter:char;



procedure delete_letter;
{$C-}
{$R-}
{$M-}
{$F-}
{$U-}


begin
if counter > 1 then counter:=counter - 1;
write(chr(8),' ',chr(8));
field[counter]:=' ';{erase letter in that position}
end;


procedure add_letter;
{$C-}
{$R-}
{$M-}
{$F-}
{$U-}

begin
field[counter]:=letter;
counter:=counter +1;
write(letter);
end;


{***** procedure input ******}
begin
counter:=1;
end_of_field:=false;
move_cursor(x,y);
repeat

	keyin(letter);
	
	case ord(letter) of

	08: {backspace}  delete_letter;
			
	27: {esc}begin
		terminate:=true; {let procedure add know to stop}
 		end_of_input:=true;
		end;
	13: {cr}  end_of_field:=true;

	09: {tab} end_of_record:=true;

	ELSE: begin

		if (counter = 1) and (letter = ' ') then delete_letter else

		if (xucase) and ((ord(letter) < 123) and (ord(letter) > 96))

		   THEN
			begin
 			letter:=chr(ord(letter)-32); {translate lc to uc}
			add_letter;
			end
		ELSE  {exclude #s, punctuation and ^ chars if letters only}

		if (xletters_only) and (not(ord(letter) in
 		    [0..31,33..64, 91..96, 123..126]))
 			THEN  add_letter
						
		ELSE if (xletters_only = false) and
 			 (ord(letter) in [32..126])
			then add_letter

              end;


	end; {of case}


if counter = len+1 then  {don't allow user to enter too many letters}
	begin
	move_cursor(1,24);  {ring bell and place warning message on screen}
	write(chr(7),'YOU HAVE ENTERED MORE THAN ',len:2,
		' CHARACTERS. PLEASE RE-ENTER.');
	move_cursor(x+len,y); {reposition cursor to end of field}
	for dummy:= 1 to len do delete_letter; {erase entry, re-set counter}
	end;


until (end_of_input) or (end_of_record) or (end_of_field);
erase_lines(24,1);
writeln;
input:=field;

end; {of procedure}





function arraytoreal(field:data):real;
{$C-}
{$R-}
{$M-}
{$F-}
{$U-}


var
decval,sign,val:real;
decimal:boolean;
dummy,junk:byte;


begin
decval:=0.0;
val:=0.0;
error:=false;
decimal:=false;

dummy:=1; {first position in array of char}

sign:=1.0;

while (decimal = false) and (dummy < 81) do
begin

case field[dummy] of 

'-': sign:=-1.0;

'.': decimal:=true;

'0','1','2','3','4','5','6','7','8','9': 
	val:=(val*10) + (ord(field[dummy]) - 48);  {48 = ord of zero}

' ': ; {ignore spaces}

else: error:=true; {warn if there are letters, control chars, etc}

end; {of case}

dummy:=dummy + 1;

end; {of while}


junk :=80; {maximum or last position in array of char}

while (decimal = true) and (junk > dummy - 1) do  {dummy - 1 because inc above}

begin

	case field[junk] of 

	'0','1','2','3','4','5','6','7','8','9': 
		decval:=(decval* 0.1) + ((ord(field[junk]) - 48) * 0.1);

	' ': ; {ignore spaces}

	else: error:= true;  {catch trash}


	end; {of case}


junk:= junk - 1;


end; {of while}

if error then prompt(1,24,0,'INVALID CODE. RE-ENTER!', false);

if val > 32000 then 
	begin
	error:= true;
	prompt (1,24,0,'CODE MUST NOT EXCEED 32000',FALSE);
	end; 



if val < 1 then
	begin
	error:=true;
	prompt (1,24,0,'CODE CANNOT BE LESS THAN 1.0',false);
	end;


if needs_units AND (decval > 0) then
	begin
	error:=true;
prompt(1,24,0,'CODE MUST NOT HAVE DIGITS TO THE RIGHT OF THE DECIMAL!',false);
	end;


arraytoreal:=sign*(decval + val);

end; {of procedure} 



function realtoarray(number:real):data;
{$C-}
{$R-}
{$M-}
{$F-}
{$U-}

var
digit,d,i:byte;
temp:data;
value,decimal,power:real; 



begin

digit:=0;
d:=1;
for i:= 1 to 80 do temp[i]:=' ';


if number < 0.0 then		{check for minus number}
	begin
	temp[1]:='-';
	number:=number* (-1.0);
	d:=2;
	end;


{correct for error induced by floating point hardware...recall that }
{Pascal/Z has 4 significant digits..}

if number < 1000.0 then number:=number + 0.0001 else 
			 number:=number + 0.001;


{get the decimal part of the number, ie digits to the right of the decimal}

decimal:=number-trunc(number);


{now determine the number of digits to the left of the decimal}

power:=10.0;

number:=number - decimal;  {remove the digits to right of decimal}

while trunc(number/power) > 0 do power:=power * 10.0;


power:= power/10.0;


{translate the digits to the left of the decimal into an array of char}

while ( d < 81) and ( power >= 1.0) do

begin
digit:= trunc(number/power);  {get digit}
temp[d]:=chr(digit + 48);     {48 = ord of zero}
d:= d + 1;
number:= number - (power*digit);
power:= power/10.0;
end;



temp[d]:='.';  {put in the decimal point}
d:= d + 1;

{now translate the digits to right of decimal into array of char}
{we know there can be only 4 since accurracy after that is not present}


for i:= d to d+ 2 do
	begin
	value:=decimal*10.0;
	digit:= trunc(value);
	temp[i]:=chr(digit + 48);
	decimal:= value - digit;
	end;

realtoarray:=temp;

end;






procedure get_info(new:boolean);
{$R-}
{$M-}
{$C-}
{$F-}
{$u-}
{new is true if this is a new terms;  false if terms already in file}

{these constants, types and variables need not be global to entire program;}
{rather, they may be local to procedure that calls function input.....     }

{end_of_input is not used at this time since this is not a stand alone     }
{procedure, but is rather called by add and change...hence it is included  }
{only for completeness and future use...                                   } 


label 2;


var
field:array[1..2] of data;
num,i,dummy:byte;
des_code:real;
units:char;
assigned_units:xtest_units;


procedure print_form;  {internal proc display the form for user to "fill in"}
{$C-}
{$R-}
{$M-}
{$F-}
{$U-}


begin
clear_screen;
prompt(1,2,24,'TERM: ',true); 
prompt(30,2,0,'CODE: ',true);
end;



procedure unit_prompt;


var
x,y,d:byte;

begin


assigned_units:=fake;
for d:= 1 to 13 do 
	begin
	move_cursor(1,d+2);
	assigned_units:=succ(assigned_units);
	writeln(chr(d + 64),'- ',assigned_units);
	end;



for d:= 14 to 24 do 
	begin
	move_cursor(40,d-11);
	assigned_units:=succ(assigned_units);
	writeln(chr(d+64),'- ',assigned_units);
	end;
prompt(1,18,1,'ENTER LETTER CORRESPONDING TO UNITS: ',false);

end;



procedure encode; {internal procedure}

var
answer:char;

begin

repeat
move_cursor(45,18);
keyin(answer);
write(answer);
until answer in ['A'..'X','a'..'x'];

{allow for either upper or lower case  letter}

if answer in ['A'..'Y'] then num:= ord(answer) - 64 else
			     num:= ord(answer) - 96;
end;



{****************** GET INFO **********************}
begin
with terms do
begin
	end_of_input:=false;
	end_of_record:=false; 
	

	{now get the information for each field}

	{note the sublte use of "recursion" in that field is passed}
	{as parameter into function that defines it...this allows  }
	{the user to correct a field, or leave it alone, as the user}
	{proceeds through entering information for record}

	{field #	variable        length of variable             	}

	{field 1	term                    21			}
	{field 2	code			10 			}
	
	{The following are all integers:  parent
					  left
					  right
									}


print_form;  {display the "form" for the user to "fill in"}
prompt(1,20,0,'ENTER A <CR> TO MOVE FROM ITEM TO ITEM.',true);
prompt(1,21,0,'ENTER A <TAB> WHEN ALL INFORMATION IS COMPLETE AND CORRECT.',
	true);
prompt(1,22,0,'ENTER A <ESC> TO RETURN TO THE MAIN MENU.',true);



{initialize field to all spaces}
for dummy:= 1 to 2 do field[dummy]:=blanks;

if not new then  {show current values; set fields = current values}
	begin
	move_cursor(6,2);
	write(term);
	move_cursor(35,2);
	if needs_units = false then write(code:5:2) else
		begin
		write(trunc(code):5);
		num:=trunc(((code-trunc(code))+0.001)*100.0);
		for dummy:= 1 to num do assigned_units:= succ(assigned_units);
		writeln('UNITS: ',assigned_units:15);
		end;



	
	{now assign previous values to fields}

	for dummy:= 1 to 21 do field[1,dummy]:=term[dummy];
	field[2]:=realtoarray(code);
end;


dummy:=1;
repeat
		case dummy of 

		1:  field[1]:= input( 6,2,21,ucase,alphanumeric,field[1]);
		2:  field[2]:= input(35,2,10, lower_case,alphanumeric,field[2]);
		end;


		if dummy < 2 then dummy:= dummy + 1 else
						 dummy:= 1;
	
until (end_of_record) or (end_of_input);

if not end_of_input then
begin 

{now assign each field to record's variable}

for dummy:= 1 to 21 do  term[dummy]:= 	field[1,dummy];

2:des_code:= arraytoreal(field[2]);
	
		if error then 
		begin
		field[2]:=blanks;
		prompt(35,2,10,' ',true); {erase incorrect entry}
		end_of_record:=false;{re-set flag}
		repeat
		field[2]:= input(35,2,10, lower_case,alphanumric,field[2]);
		until end_of_record ;
		error:=false;
		goto 2; {try this again!}
		end;


if needs_units then {add a fraction to code that represents units...}
	begin
	unit_prompt;
	encode;
	des_code:= des_code + (num/100) + 0.001;
	end;






case new of
true: 	begin
	print_flag:=false; {init this field}
	code:=des_code;
	newterms:=terms;
	end;

false:if des_code <> 0.0 then code:=des_code;

end;

end; {of if not end of input}
end; {of with terms}
end;

procedure search(recno:integer;key:real;key1:char21; delete:boolean);
{$R-}
{$C-}
{$F-}
{$M-}
{$U-}
begin
with terms do
begin
found:=false;
reference_number:=0;
last_rec:=0;

read(fnumterms:recno,terms);

if (key = code) and (key1 <> term) then { = codes stored to left in tree}
				if left = 0 then found:=false else
						search(left,key,key1,delete)

ELSE

if (key = code) and (key1 = term) then
	begin
	found:=true;
	last_rec:=parent;
	reference_number:=recno;
	if (delete = false) {ie only need to change term assigned code}
		then
			begin
			term:=newterms.term;{change term, don't lose pointers}
 			write(fnumterms:recno,terms);{rewrite with new term}
			end;
	end

ELSE

if key < code then if left = 0 then found:=false else
			search (left,key,key1,delete)

ELSE

if key > code then if right = 0 then found:=false else
			search (right,key, key1, delete);



end;
end;

procedure find(code:boolean;flag:byte);
 {flag indicates whether find was called from menu (=0),change (=1)}
 {it also = 1 if called from delete since delete will display term}
 {code indicates whether to search for diagnostic term }

{procedure to find if a term exists in the file. The terms is located}
{by a "key" which is the terms.}
{$C-}
{$F-}
{$M-}
{$R-}
{$U-}
label 1;

var
found,correct,continue:boolean;
key:char21;
counter,dummy:integer;


procedure ask_term;  {internal procedure}
{$C-}
{$R-}
{$M-}
{$F-}
{$U-}

var
field:data;
dummy,x,y:byte;


begin
end_of_input:=false;
end_of_record:=false;
field:=blanks;{init}

if recursive = false then
		begin
		x:=17;
		y:=1;
 		clear_screen;
		end
else begin
	x:=17;
	y:=20;
	end;

write('ENTER TERM ---> ');
field:=input(x,y,21,true,false,field);
for dummy:= 1 to 21 do key[dummy]:=field[dummy];

end;


procedure list_terms(letter:char);
{$C-}
{$R-}
{$M-}
{$F-}
{$U-}


var
dummy:integer;
counter:byte;
scrolling:char;

begin

counter:=1;

with terms do
begin
for dummy:= 2 to numrecs do
begin
read(fterms:dummy,terms);
if (letter = term[1]) and (code <> -999.0){ie not deleted}  then
		begin
		counter:=counter + 1;
		if counter < 19 then move_cursor(1,counter)
				 	
			  else
			if counter < 38 then move_cursor(45,counter-19)

			else
 			begin			
		prompt(1,20,0,'ENTER ANY CHARACTER TO CONTINUE. ',false);
			keyin(scrolling);	
			clear_screen;
			counter:=3;
			move_cursor(1,counter);
			end;

		write(term:21);
		if needs_units then writeln(trunc(code):10) 
				ELSE writeln(code:10:3);
		end;
end;
end;{of with}
end; {of internal procedure}




procedure search(recno:integer; key:char21); 
{$C-}
{$R-}
{$M-}
{$F-}
{$U-}


{internal procedure}


begin
with terms do
begin
found:=false;
reference_number:=0;  {set = 0 as flag to calling procedure}
last_rec:=0;
read(fterms:recno,terms);

if (key = term) then
	begin
 	found:=true;
	last_rec:=parent;
	reference_number:=recno;  {return the recno for DELETE and CHANGE}
	end

 ELSE

	if key < term then
		if left = 0 then found:=false
 		            ELSE search(left,key)

	ELSE 

	if key > term then
		if right = 0 then found:=false

 		             ELSE search(right,key);
end;{of with}
end;{of procedure}



begin {************* of procedure find ***************}

continue:=true;

while continue do
begin
counter:=0;
correct:=true;{exit condition}
ask_term; 

search(1,key);

1: if (found) and (flag = 0) then
	begin
	 clear_screen;{don't show if called from CHANGE or DELETE}
	show_information(false);
	end;
	

if not found then
	begin
	clear_screen;
	writeln('TERM NOT FOUND! TERMS BEGINNING WITH ',key[1]:1);
	counter:=3;
	list_terms(key[1]);	{list all names with same letter}
	end;


if (found = false) and (counter <> 0) {counter acts as flag here} then
	begin
	continue:= query(1,20,'WOULD YOU LIKE TO RE-ENTER THE TERM? Y/N  ');
	if continue then
			begin
			recursive:=true;
 			find(false,flag);
			end;
	end;

if (flag = 0) and (counter = 0) then
 {don't even ask unless find was called from menu}
 	continue:= query(1,20,'WOULD YOU LIKE TO FIND ANOTHER TERM? Y/N  ')
 ELSE
	continue:=false;

end; {of while continue}
end;



procedure add(change,numfile:boolean);
{$C-}
{$M-}
{$U-}
{$R-}
{$F-}
label 2;
type
which_pointer = (xleft,xright);

var
num_next,dup_rec_no,dup_left,i,f_numrecs,f_left,f_right,next,dummy:integer;
key:char21;
used_code,answer,duplicate: boolean; 



{*********** find correct place in file and put record there ************}
procedure update(recnum:integer;d:which_pointer;numfile:boolean);
{$C-}
{$R-}
{$M-}
{$F-}
{$U-}

var
parent_node:integer;

begin
with terms do
begin

{load variable terms with proper information; this step is necessary since }
{when insert checked to see if any codes were used previously, it read the}
{file, and hence reassigned values to terms different than those last assigned}
{in procedure insert...  					          }


if numfile = false then
	begin
	 read(fterms:recnum,terms);
	 {determine pointer to change; make it point to new rec}
	case d of          
	xright: right:=next;
	xleft:  left:=next; 
	end;
	end

ELSE
	BEGIN
	read(fnumterms:recnum,terms); 
	{determine pointer to change; make it point to new rec}
	case d of          
	xright: right:=num_next;
	xleft:  left:=num_next; 
	end;
	end;
parent_node:=recnum;  {set pointer in new record to point to predecessor}

{update rec; ie point to new rec}
if numfile = false then write(fterms:recnum,terms)
                   else write(fnumterms:recnum,terms);
 


{now add new rec to end of file}

terms:=newterms;  {assign new information to the variable terms}
right:=0;
left:=0;

parent:=parent_node; {set pointer to predecessor}

if duplicate then left:=dup_left; {true only num file since dup terms not poss}


if numfile = false then write(fterms:next,terms)  {write new record to file}
		   else write(fnumterms:num_next,terms);


{write code to array in terms.num using a 1:1 correspondence of rec number  }
{and position in the array...at this point, just update array. At conclusion}
{when first record is updated, update the actual disk file..................}

if numfile = false then 
{update counter for first record of file to reflect increase in # of recs}
begin
next:=next +1;{increment number of records}
f_numrecs:=next;
numrecs:=next; {update so procedure check will keep searching}
end

ELSE num_next:=num_next + 1; {update counter for the .nx file}

end; {of with}
end; {of procedure}




{******************* find where in num file to put record ******************}
procedure num_insert(rec_no:integer;key:real);
{$C-}
{$R-}
{$M-}
{$F-}
{$U-}


label 1;
begin
duplicate:=false;

with terms do
begin


read(fnumterms:rec_no,terms);

if key = code then
	begin
	dup_rec_no:=rec_no;
	dup_left:=left;
	duplicate:=true;
 	update(dup_rec_no,xleft,true);
	goto 1;
	end;

if key < code then
               if left <> 0 then num_INSERT(left,key)  
                    {keep going until you find appropriate place in tree}

                            ELSE
				 UPDATE(rec_no,xleft,true)
				
ELSE

if key > code then
             if right <> 0 then num_INSERT(right,key)

                            ELSE
				 UPDATE(rec_no,xright,true);

1:
end;
end;



{********************* add a term to the file *********************}
Procedure Insert( rec_no:integer;key:char21);
{$C-}
{$R-}
{$M-}
{$F-}
{$U-}


label 1;
var
answer,duplicate: boolean; 
dup_rec_no,dup_left:integer;
dummy,dummy1:byte;


begin  {of procedure insert}
duplicate:=false;
used_code:=false;
with terms do
begin
read(fterms:rec_no,terms);

if key = term then
	begin
	prompt(1,24,0,'TERM ALREADY IN FILE!',FALSE); 	
	for dummy:= 1 to 40 do for dummy1:= 1 to 30 do; {delay to read msg}
	GOTO 1;
	END;


if key < term then
               if left <> 0 then INSERT(left,key)  
                    {keep going until you find appropriate place in tree}

                            ELSE
				begin
				if change = false then { * see note below}
					begin
					check_code(true,newterms.code,rec_no);
				 	num_insert(1,newterms.code);
					end;
				UPDATE(rec_no,xleft,false);
				end
				
ELSE

if key > term then
             if right <> 0 then INSERT(right,key)

                            ELSE
				begin
				if change = false then
					begin
					check_code(true,newterms.code,rec_no);
					num_insert(1,newterms.code);
					end;
				 UPDATE(rec_no,xright,false);
				end;
1:


end; {of with}
end; {of procedure}

{ * note: if called from change, do not add to num file from here, since  }
{ if just term was changed, and not code, need not create new record in num}
{ file.  On other hand, if both code and term were changed, procedure change}
{ will make sure both files -- num and dx -- are modified...              }


{****************** begin of procedure add ****************************}
begin
terminate:=false;
read(fterms:1,terms);  {find next available record number}
next:=trunc(terms.code);
numrecs:=next;

if next > 32700 then 
	begin
	clear_screen;
	writeln('SORRY, FILE IS FULL! NO ADDITIONAL TERMS CAN BE ADDED.');
	for dummy:= 1 to 40 do for i:= 1 to 40 do; {delay to read message} 
	goto 2;
	end;

read(fnumterms:1,terms);{the number of recs in this file will not = that in}
num_next:=trunc(terms.code);
 			{.dx file because when a term is changed, it is de-}
			{leted from .dx, and new term added, thereby incre-}
			{menting numrecs (next), whereas only the term is  }
			{modified in .nx and no new record is added}

if change = false then
begin

repeat
get_info(true); {the parameter true means that this is info for a new record}
used_code:=false;
key:=newterms.term;
if not terminate then
	BEGIN
	duplicate:=false;
 	insert(1,key);
	end;
until terminate;



end {of if change = false}


ELSE {change=true,ie add was called from procedure change }

if numfile then num_insert(1,newterms.code)  
ELSE
begin
duplicate:=false;
insert(1,newterms.term);
end;


if numfile = false then 
begin  {update the first record in the .dx file}
read(fterms:1,terms);
terms.code:=f_numrecs;
write(fterms:1,terms);
end;

{update the first record of the .nx file since whether change code or term }
{this value changes...}
read(fnumterms:1,terms);
terms.code:=num_next;
write(fnumterms:1,terms);

2:
terminate:=false;  {reset this global variable so program won't terminate}
end;


{procedure to delete a name from the file based on term}


procedure delete(change,numfile:boolean);
{$C-}
{$M-}
{$F-}
{$R-}
{$U-}
var
cur_parent,cur_right,cur_left,cur_recno,new_left:integer;
continue,correct:boolean;
dummy:byte;
x:fxterms; {dummy variable to save a lot of if statements!}
recall_term:char21;
recall_code:real;


{************ rewrite pointers thereby deleting record ***************}
procedure del (recno:integer;numfile:boolean);
{$C-}
{$R-}
{$M-}
{$F-}
{$U-}


label 1;
var
point:integer;

begin
with terms do
begin
if numfile then reset(num_file,x) else reset(term_file,x);


if (left = 0) or (right = 0) then  {case 1 or no descendents}
	begin
	{determine value to place in pointers of last record}
	if left = 0 then point:=right else point:= left;
	read(x:last_rec,terms);
	{determine which pointer of last record to update}
	if left = recno then left:=point else right:=point;
	write(x:last_rec,terms);
	terms.term:='ZZZZZZZZZZZZZZZZZZZZZ';
	terms.code:=-999.0;
	write(x:reference_number,terms);{marked rec deleted}
	goto 1;
	end;




{in the case of two descendents, move right most branch of 1st }
{descendent on left, to the node that is being deleted       }
{note that right most branch will have pointers of left = 0, right = 0}
{in essence, just substituting name, address, "vital signs"...pointers}
{remain intact}



if (left <> 0) and (right <> 0) then    {case of two descendents}
	begin

{store pointers of record being deleted}
	cur_left:=left;
	cur_right:=right;
	cur_recno:=recno;
	cur_parent:=parent;

{per algorithm, move one node to left}
	read(x:cur_left,terms);
	last_rec:=cur_left;

{now go as far right as possible}
	while right <> 0 do
		begin
		last_rec:=right;
	  	read(x:right,terms); 
		end;

{take the terms information in this node, and move it to "deleted" node }
	right:=cur_right;
	left:=cur_left;
	parent:=cur_parent;
	write(x:cur_recno,terms);

{set right = 0 for node that used to point to last node on right}
	read(x:last_rec,terms);
	right:=0;
	write(x:last_rec,terms);

	end;
{$E-}		
1:
end;{of with}
end;{of internal procedure del}


{************************ begin of procedure delete *********************}

begin
if change = false then
begin
continue:=true;
while continue do
begin
find(false,1);

recall_code:=terms.code; {need to remember these for del .num since values of}
recall_term:=terms.term; {term and code change during del .dx                }

if last_rec = 0 {ie name not found} then
	begin
	clear_screen;
	prompt(1,12,0,'NO DELETION PERFORMED.',false);
	end

ELSE

if last_rec <> 0 {ie name found} then
begin
clear_screen;
show_information(false);
correct:=query(1,24,'IS IT OK TO DELETE THIS TERM? Y/N');
	if correct then
		begin
 		del(reference_number,false);{remove term from file}
		

		search(1,recall_code,recall_term,true);

		del(reference_number,true);
		clear_screen;
		prompt(1,12,0,'TERM DELETED FROM FILE!!',false);
		end;


end;

continue:=query(1,24,'WOULD YOU LIKE TO DELETE ANOTHER TERM? Y/N');
end; {of while continue}

end {of if change = false}


ELSE {if delete is called from change}

if numfile then del(reference_number,true)  {if numfile is to be modified}

	ELSE del(reference_number,false); {if .dx file is to be modified}

end;



procedure change;
{$C-}
{$R-}
{$M-}
{$F-}
{$U-}


label 1;
var
continue:boolean;
recall_code:real;
recall_term:char21;


{there are four possibilities or cases with respect to changing the files:}
{	TERM		CODE	} 
{				}
{	same		same	}
{	changed         changed }
{	same            changed }
{	changed		same	}
{				}






begin

continue:=true;
while continue do
begin

find(false,1);  {returns,if term is found: found:=true; reference number = }
	        {recno for that term and last rec = parent for that term   }
 
if reference_number > 0 {ie terms is in file}  then
	begin
	recall_code:=terms.code; {remember the original information}
	recall_term:=terms.term;

	newterms:=terms; {save all pointers}

	get_info(false);  {false means terms already exists;get new info}
	newterms.term:=terms.term; {assign new values}
	newterms.code:=terms.code;
	

{CASE ONE:}
	{if neither the term nor the code has changed, SKIP TO QUERY}
	if (recall_code = newterms.code) and (recall_term = newterms.term)
		then
			begin
			clear_screen;
 			goto 1;
			end;

	{if the code has been changed, make sure it is ok}
{CASE TWO:}
 		
	{if code has changed, but not term then (1) must change code and}
	{rewrite record in .dx file, and (2) delete original code's record}
	{in .num file, and write new record with new code in .num file    }



	if (recall_code <> newterms.code) and (recall_term = newterms.term)
 		then 
			begin
			check_code(false,newterms.code,reference_number);

			write(fterms:reference_number,newterms);

			{find orig record in .num file and delete}
			search(1,recall_code,recall_term,true);
			{should return, if code found: found:=true,      }
			{reference number = recno for code, last rec = parent}


			delete(true,true);{true=called from change; true =}
					  {modify numfile ...		  } 

			{now add new term and code to .num file}
			add(true,true);
			end;

{CASE THREE:}

	{if term has changed, but not code then (1) must delete old term from}
	{.dx file and (2) rewrite new term in file and (3) change term in    }
	{ .num file..if code has changed, then situation taken care of above }
	
	if (recall_term <> newterms.term) and (recall_code = newterms.code)
 		then
	begin
	delete(true,false); {true=called from change; false=not numfile}
	add(true,false);

	search(1,recall_code,recall_term,false);{false means write new info}
	{in this case, search will change term in .num file}
	end;

	
	{if BOTH code and term changed then must (1) delete orig code from  }
	{.num file (2) delete orig term from .dx file (3) add new code to   }
	{.num file (4) add new term and code to .dx file.....    	    }


{CASE FOUR:}

	if (recall_code <> newterms.code) and (recall_term <> newterms.term)
	   then
		begin
		delete(true,false);{these two lines handle the .dx file}
		add(true,false);

		
		{find orig record in .num file and delete}
		search(1,recall_code,recall_term,true);
		delete(true,true);{true=called from change; true =}
				  {modify numfile ...		  } 

		{now add new term and code to .num file}
		add(true,true);
		end;


	clear_screen;
	prompt(1,10,0,'TERM HAS BEEN MODIFIED.',false);
	end


else {term was not found so no modification possible}
	begin
	clear_screen;
	prompt(1,10,0,'NO MODIFICATION POSSIBLE!',false);
	end;
1:
continue:=query
    (1,24,'WOULD YOU LIKE TO MODIFY INFORMATION ON ANOTHER TERM? Y/N ');

end; {of while}

end; {of procedure}



procedure menu;
{$R-}
{$U-}
{$F-}
{$M-}
{$C-}
var
selection:char;
dummy,dummy1:byte;


begin
recursive:=false;
clear_screen;
writeln;{these two lines delay the program for terminal to react to clear scr}
writeln; 
writeln
('TERMS MANAGEMENT PROGRAM. COPYRIGHT 1982 BY CRAIG RUDLIN,MD':70);
writeln;
writeln;
writeln('1- ADD a new term ');
writeln;
writeln('2- DELETE a term ');
writeln;
writeln('3- CHANGE a term or a term''s code');
writeln;
writeln('4- DISPLAY a term and it''s code');
writeln;
writeln('5- DISPLAY ALL terms on the screen'); 
writeln;
writeln('6- PRINT all terms'); 
writeln;
writeln;
writeln('7- SWITCH to another file of terms');
writeln;
writeln('0- EXIT this program.');
writeln;
writeln;
write('ENTER THE NUMBER OF YOUR SELECTION ---> ');
keyin(selection);
write(selection);

case selection of
'1': add(false,false);
'2': delete(false,false);
'3': change;
'4': find(false,0);
'5': print_terms(false);
'6': print_terms(true);
'7': begin
     command_line:=blanks;
     initialize;
     end;
'0': begin
     terminate:=true;
     clear_screen;  {clear screen upon exiting program}
     end;
else: menu; {don't except an invalid answer}

end; {of case}

end; {of procedure}

. {end of separate compilation}