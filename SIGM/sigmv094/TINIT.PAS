
external terms::init(5);


{COPYRIGHT 1982 (C) BY CRAIG RUDLIN, M.D.  ALL RIGHTS RESERVED}






procedure make_file_name;
{$R-}
{$U-}
{$M-}
{$F-}
{$C-}

{put term_file in proper CP/M format for a file name}

begin
term_file[9]:='.';
term_file[10]:='T';
term_file[11]:='E';
term_file[12]:='R';

{now assign value to num_file and put it in proper CP/M format}
num_file:=term_file;
num_file[10]:='N';
num_file[11]:='U';
num_file[12]:='M';

end;




function xvalid:boolean; {internal function to see if file is a valid one}
{$R-}
{$U-}
{$M-}
{$F-}
{$C-}

begin
if (term_file = 'PROTOCOLS   ') OR (term_file = 'DIAGNOSES   ') OR
   (term_file = 'TESTS       ') OR (term_file = 'ACCOUNTS    ') OR
   (term_file = 'DRUGS       ') OR (term_file = 'PROCEDURES  ') OR
   (term_file = 'MATERIALS   ')



   then xvalid:= true else xvalid:= false;
end;


procedure get_file(invalid:boolean); {internal procedure to get type of file}
{$R-}
{$U-}
{$M-}
{$F-}
{$C-}


var
answer:data;
dummy:byte;

begin
			clear_screen;

			end_of_field:=false;
			end_of_record:=false;
			end_of_input:=false; 
			answer:=blanks;

			if invalid then
			writeln('YOU HAVE ENTERED AN INVALID FILE.')
		        else
			writeln('YOU DID NOT SPECIFY WHICH FILE TO USE.'); 

			writeln('PLEASE ENTER EITHER:');
      			writeln('PROTOCOLS':35);
			writeln('DIAGNOSES':35);
			writeln('TESTS':35);
			writeln('ACCOUNTS':35);
			writeln('PROCEDURES':35);
			writeln('DRUGS':35);
			writeln('MATERIALS':35);
			writeln;
			write('---> ');
			

			answer:=input(11,11,12,ucase,letters_only,answer);


	for dummy:= 1 to 12 do term_file[dummy]:=answer[dummy];

			if xvalid = false then get_file(true);
		{was a valid type of file answerif not get valid one}



			
end; {of internal procedure get_file}




procedure initialize;
{$R-}
{$U-}
{$M-}
{$F-}
{$C-}


{this procedure first reads the command line to determine which file of terms}
{to use...this allows this single program to create files of diagnoses,tests,}
{protocols, etc.  If the command line is blank, then the procedure asks the  }
{user to enter the appropriate file.  Next, the procedure opens the files. If}
{the file is not found, it is created.					    }

const
clear = '            '; {12 spaces}

var
counter,dummy:byte;
job:array[1..12] of char;




begin {**** of procedure initialize ****}

{read the command line.  If file is specified, then continue on to initialize}
{otherwise, must determine which file to enter. Check to make sure it is a   }
{valid type of file }


for b:= 1 to 80 do blanks[b]:=' '; {establish this filler}


job:= clear;	  {initialize these variables to all spaces}
term_file:=clear;
num_file:= clear;
counter:=1;

if eoln(0) then get_file(false) else
		begin
	    	readln(command_line);

	 

		{was a valid type of file entered? if not get valid one}


		while (command_line[counter] <> ' ') and (counter < 10) do
			begin
			term_file[counter]:=command_line[counter];
			counter:=counter + 1;
			end;

		if xvalid = false THEN  get_file(true);
		end;


clear_screen;
writeln('ONE MOMENT PLEASE.');
writeln;

make_file_name;

dummy:=1; {counter for job's array} 
counter:=counter + 1; {skip the comma in the command line, that separates}
			{the file from the menu selection}


{don't read more characters than in the array for job, ie 12}

while (dummy < 13) and (command_line[counter] <> ' ') do
	begin
	job[dummy]:=command_line[counter];
	counter:=counter + 1;
	dummy:=dummy + 1;
	end;




{open necessary files} 

reset(term_file,fterms);
if eof(fterms) then  {create the file}
	begin

	with terms do
	begin

	term:='MASTER               ';
	print_flag:=false;
	code:=2.0;
	parent:=0;
	left:=0;
	right:=0;


	rewrite(term_file,fterms);
	write(fterms:1,terms);

	rewrite(num_file,fnumterms);
	write(fnumterms:1,terms);

	end;{of with terms}

	numrecs:=2;

	{CP/M does not write the directory listing of a newly created file}
	{until it is closed. Pascal has no provision for explicitly closing}
	{a file. Until the file is closed, and the dir listing is written, }
	{CP/M will not permit the program to read the file...Hence it is   }
	{imperative to force the CP/M to create the directory listing.  This}
	{is done by "reset" the file.					  }

	reset(term_file,fterms);
	reset(num_file,fnumterms);

	end {of if eof}

ELSE
	BEGIN
	{determine number of records in term file}
	read(fterms:1,terms);
	numrecs:= round(terms.code);


	reset(num_file,fnumterms);
	if eof(fnumterms) then
		begin
		writeln('FILE OF ',command_line:10,' CODES NOT ON DISK!');
		terminate:=true;
		end
	END;

{if job is a valid menu selection, then go directly to that procedure and }
{skip the menu at this point}


if terminate = false then
begin

clear_screen;

if ((term_file = 'TESTS   .TER') or (term_file = 'MATERIAL.TER')) then
	needs_units:=true else needs_units:=false;

if job = 'ADD         ' then add(false,false) else
if job = 'DELETE      ' then delete(false,false) else
if job = 'FIND        ' then find(false,0)  else
if job = 'CHANGE      ' then change else
if job = 'DISPLAY     ' then print_terms(false) else
if job = 'PRINT       ' then print_terms(true);  

end;


end; {of procedure}
. {of separate compilation}
