external terms::print(8);



{COPYRIGHT 1982 (C) BY CRAIG RUDLIN, M.D.  ALL RIGHTS RESERVED.}



{***************************** procedure transverse_ tree ****************}


{	This procedure is the main routine for transversing the tree and  }
{printing the nodes.  Here is where the actual work is done.  The procedure}
{reads the master file, sees how many records there are so it knows when to}
{stop, and goes as far down the left side of the tree as possible.  It then}
{starts a while loop, that checks for exit conditions.  The program includes}
{the node in the I/O buffer array and increments the buffer counter  if the}
{node meets the printing conditions.  The procedure then increments the number}
{records looked at.  If there is no right branch from this node, then it calls}
{procedure flag and returns to the top of the while loop.  If there is a right}
{branch, then it sets print flag, and moves to the first node of right branch}
{before going as far left as possible on this branch.  The procedure then}
{once again, returns to the top of the while loop.  Once the exit conditions}
{are satisfied or the I/O buffer is full, the procedure prints the contents}
{of the I/O buffer.  Upon exiting, the while loop the procedure notes how }
{many files were printed and returns to the menu.                         }





procedure print_terms (hardcopy:boolean);
 {main routine for transversing the tree and printing nodes}
{$C-}
{$R-}
{$F-}
{$M-}
{$U-}


type
buffer = array[1..100] of xterms;
dir = (xright,xleft,xparent);


var
output:text;
lines,dummy,counter:byte;
total_printed,page,total_number_recs,recno,num_recs_looked_at:integer;
temp:buffer;
continue:char;



{************************* procedure left_as_possible *****************} 



{	This procedure starts at the current node and goes }
{down the left branch of that node as far as it can go. It will not crash}
{if the node does not  have a left branch.  }



procedure left_as_possible;
{$C-}
{$R-}
{$F-}
{$M-}
{$U-}

{this procedure moves as far left in the binary tree as possible to find the}
{next record to read...}

begin


  with terms do
  begin
	while left <> 0 do  {left = 0 for the last record to the left}
	  begin
	  recno:=left;
	  read(fterms:recno,terms);
	  
	  end;
  end;
end; 

{******************************** move **********************************}

{	This procedure moves through the file in the desired direction.}
{If you're moving to the node's parent then it de-asserts the print_flag,}
{writes the node out to the disk in its new form, and reads in the parent.}
{If you're moving to the right branch then it asserts the print_flag, } 
{writes the old node out to the disk, and reads in the right branch.}


procedure move(direction:dir);
{$C-}Š{$R-}
{$F-}
{$M-}
{$U-}


begin
  with terms do
  begin
	{set flag indicating that record has been printed}
	if direction = xparent then print_flag:=false else print_flag:=true;
	write(fterms:recno,terms);{re-write record with newly updated flag}
	if direction = xparent then recno:=parent else recno:=right;
	read(fterms:recno,terms);  {move on....}
  end;
end;


{************************** procedure put_in_array *********************}


{	This procedure is an I/O buffer to reduce the number of disk read-}
{writes.  It is,in effect a first in,first out stack.  It also prevents }
{the master disk from being printed, and filters out the unwanted records }
{in the case of a special listing.                                        }



{************************** note:*************************************}
{could this be modified by removing the array and having the procedure}
{merely output the record as it is recieved? As there are no disk read-}
{writes involved in printing.}

procedure put_in_array;
{$C-}
{$R-}
{$F-}
{$M-}
{$U-}

{this procedure puts record's information into the temporary array, and }
{when the temporary array is filled, ie 100 records, prints the array}

label 1;




 
begin{of procedure put_in_array}
with terms do
begin

if recno <> 1 then
  {don't print the first record since it is just stats}
	begin
	counter:=counter + 1;
	total_printed:=total_printed + 1;
	temp[counter]:=terms;
	end;		
		if (counter = 100 ) or (counter = total_number_recs - 1) or 
	   (num_recs_looked_at = total_number_recs) then

		begin
		lines:=1;
 		for dummy:= 1 to counter do
			begin
 			
			write(output,temp[dummy].term);
			if needs_units then
			writeln(output,trunc(temp[dummy].code):10) ELSE
			writeln(output,temp[dummy].code:10:3);


			if (hardcopy) and (lines > 56) then
					begin
					writeln(output,chr(12));{formfeed}
	writeln(output,'LISTING OF TERMS','PAGE':35,page:7);
	writeln(output);
					page:=page + 1;
					lines:=2;
					end;

			if (hardcopy = false) and (lines > 16) then
				beginŠprompt(1,24,0,'TYPE ANY LETTER TO CON''T,OR <ESC> TO RETURN TO MENU.',FALSE);
				keyin(continue);
			if ord(continue)=27 then 
			begin
			clear_screen;
			num_recs_looked_at:=total_number_recs+1;
			goto 1;
			end;
				clear_screen;
	writeln(output,'LISTING OF TERMS','PAGE':35,page:7);
	writeln(output);
					page:=page + 1;
					lines:=2;
				end;
			counter:=0;
			end;
		end;
	num_recs_looked_at:=num_recs_looked_at + 1;
end;
1:
end; {of procedure}


procedure flag;
{moves up the tree until it finds a record that has not been printed...}
{$C-}
{$R-}
{$F-}
{$M-}
{$U-}

begin
move(xparent);
if terms.print_flag then flag;
end;



{*************************** procedure transverse_tree ****************}

{The following is just "set up" : checking to see if a hardcopy is desired}
{and if so, if the printer is ready, and also checking to see if there are}
{indeed any termss (nodes) in the file.}



begin

page:=1;
clear_screen;


if hardcopy then
	begin
	prompt(1,12,0,'PREPARE PRINTER AND THEN ENTER ANY CHARACTER.',false);
	keyin(continue);
 	rewrite('lst:',output);
	end
   ELSE rewrite('con:',output);
clear_screen;Š
writeln(output,'LISTING OF TERMS ','PAGE':35,page:7);
writeln(output);

page:=2;

counter:=0;
num_recs_looked_at:=1;
total_printed:=0;

with terms do
begin
	read(fterms:1,terms);
	total_number_recs:=trunc(terms.code) - 1;
	left_as_possible;

	while num_recs_looked_at <= total_number_recs do
	   begin
	   put_in_array;
	   if right = 0 then flag  ELSE
			begin
			move(xright);
			left_as_possible;
			end;

	   end;

writeln(output);
writeln(output,'TOTAL NUMBER OF TERMS: ',total_printed:6);
prompt(1,24,0,'TYPE ANY LETTER TO RETURN TO MENU',false);
keyin(continue)
end;
1:
end; {of procedure transverse_tree}


. {of separate compilation}