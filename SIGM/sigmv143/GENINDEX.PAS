{$S+}{}
program index(input,output) ;

{ 
  This PASCAL MT+ index generator program is placed in
  the public domain on the understanding that it is for
  non-profit redistribution via individuals for through
  RCPM systems
  Donated 23/6/83
  Matthew Starr P.O. Box 25 Wahroonga N.S.W 2076
		Australia

  Matthew Starr 13/12/81

  WordStar index generator program which will
  read through WordStar disk file output files
  and include strings delimited by ^Q and ^W as
  Major and Minor references respectively, creating
  an index which is then sorted and output as a
  WordStar source file.

  A required option for the Disk-file print is
  form feed page separation. (See procedure HELP)
}

const
    main_code = 17 ;		{code for boldface ref}
    sub_code = 23 ;		{code for normal ref}
    bold_code = 2 ;		{makes it boldface}
    formfeed = 12 ;
    stringz = 50 ;		{P.S. also change assgmnt}
    max_entries = 500 ;		{max # different entries}
    max_refs = 5 ;		{max # refs of either type}


type
    my_string = packed array[1 .. stringz] of char ;
    pointer = ^entry_type ;
    entry_type =
	record
	    subject : my_string ;
	    n_mains : integer ;
	    mains : array[1 .. max_refs] of integer ;
	    n_subs : integer ;
	    subs : array[1 .. max_refs] of integer ;
	end ; { entry decl. }
    table_type = array[1 .. maxentries] of pointer ;

    ws_file = file of char ;
    index_file = file of entry_type ;


var
    index : index_file ;
    text_in : ws_file ;
    text_out : text ;

    end_file : entry_type ;
    table : table_type ;
    filename,response : string ;
    i, num_entries, result : integer ;


procedure addentry(var table:table_type; var tablength:integer; newentry:entry_type) ;

    begin
	if tablength >= max_entries
	    then writeln('Too many entries - entry table full')
	    else
		begin
		    tablength := tablength+1 ;
		    new(table[tablength]) ;
		    table[tablength]^ := newentry
		end { else there is room }
    end;


procedure readarray(var name:my_string) ;

    var
	ch : char;
	nameindex : 0 .. stringz;

    procedure uppercase(var ch:char) ;
	begin
	    if ord(ch)>127
		then ch := chr( ord(ch) - 128 ) ;
	    if (ch >= 'a') and (ch <='z')
		then ch := chr( ord(ch)-(ord('a')-ord('A')) );
	end ; {uppercase}

    begin
	name := '                                                  ' ;
	nameindex := 0 ;
	read(text_in,ch) ;
	uppercase(ch) ;
	while (name_index<stringz)
	    and (ord(ch)<>main_code) and (ord(ch)<>sub_code) do
	    begin
		nameindex := nameindex+1 ;
		name[nameindex] := ch ;
		read(text_in,ch) ;
		uppercase(ch)
{ and throw away terminating control code }
	    end {while}
    end ; {readarray}


procedure get_main
(var table:tabletype; var tablength:integer; var page, created, added_to:integer);

    var
	name: my_string;
	this_entry: entry_type;
	i: integer;

    begin
	readarray(name);
	i := 1 ;
	while (i<=num_entries) and (name<>table[i]^.subject) do
		i:=i+1 ;
	if i>num_entries	{ i.e. if not found }

	    then
		begin { create a new entry }
		    with this_entry do
			begin
			    created := created + 1 ;
			    subject := name ;
			    n_mains := 1 ;
			    n_subs := 0 ;
			    mains[1] := page
			end { with } ;
		    addentry(table,tablength,this_entry)
		end {then}

	    else {add to the ith entry}
		with table[i]^ do
		    begin
			added_to := added_to + 1 ;
			if n_mains >= max_refs
			    then
				writeln('Too many main references to ',subject)
			    else
				begin
				    n_mains := n_mains+1 ;
				    mains[n_mains] := page
				end {else}
		    end {with}
    end ; {get_main}


procedure get_sub
(var table:tabletype; var tablength:integer; var page, created, added_to:integer);

    var
	name: my_string;
	this_entry: entry_type;
	i: integer;

    begin
	readarray(name);
	i := 1 ;
	while (i<=num_entries) and (name<>table[i]^.subject) do
		i:=i+1 ;

	if i>num_entries	{i.e. was it found ?}
	    then
		begin		{ create a new entry }
		    with this_entry do
			begin
			    created := created + 1 ;
			    subject := name ;
			    n_mains := 0 ;
			    n_subs := 1 ;
			    subs[1] := page ;
			end { with } ;
		    addentry(table,tablength,this_entry)
		end {then}

	    else
		with table[i]^ do
		    begin
			added_to := added_to + 1 ;
			if n_subs >= max_refs
			    then
				writeln('Too many minor references to ',subject)
			    else
				begin
				    n_subs := n_subs+1 ;
				    subs[n_subs] := page
				end {else}
		    end {with}
    end ; {get_sub}


procedure scanfile
(var table:tabletype; var tablength:integer; filename:string);

var
    ch:char ;
    page, created, added_to : integer ;

    begin
	created := 0 ;
	added_to := 0 ;
	assign(text_in,filename) ;
	reset(text_in) ;
	if ioresult = 255
	    then writeln('Could not open ',filename)
	    else
		begin
		    write('Page number start for this file? ');
		    read(page) ;
		    while not eof(text_in) do
			begin
			    read(text_in,ch) ;
			    if ord(ch)=formfeed
				then page := page + 1
			    else if ord(ch)=main_code
				then get_main(table,tablength,page, created, added_to)
			    else if ord(ch)=sub_code
				then get_sub(table,tablength,page, created, added_to)
			end ;
		    writeln(created,' new entries created');
		    writeln(added_to,' references added to existing subjects.')
		end { else file opened successfully }
    end ; { scanfile }


function lessthan(el1,el2 : pointer) : boolean ;
{compare the two entries as per ascii}

    begin
	lessthan := el1^.subject < el2^.subject
    end ; {compare}

procedure swap(var el1,el2 : pointer) ;
{swap two entries pointed to by el1, el2}
    var
	temporary : pointer ;
    begin
	temporary := el1 ;
	el1 := el2 ;
	el2 := temporary
    end {swap} ;


procedure split(	var splitee	:table_type;
			low,high	:integer;
			var midindex	:integer) ;
    var
	middle : pointer ;
	flag,up,down : integer ;
    begin
	up := low ;
	down := high+1 ;
	middle := splitee[low];	{split from first entry}
	flag := 1 ;
	while up < down do
	    if flag = 1
		then {search downwards for a wrong one}
		   begin
			down := down-1 ;
			if (up<>down) and not lessthan(middle,splitee[down])
			    then
				begin
				    flag := 0 ;
				    splitee[up] := splitee[down]
				end {THEN it's out of place}
		    end {THEN try and find a wrong one down}
		else {search upwards for a wrong one}
		    begin
			up := up + 1 ;
			if (up <> down) and lessthan(middle,splitee[up])
			    then
				begin
				    flag := 1 ;
				    splitee[down] := splitee[up]
				end {THEN it's out of place}
		    end {ELSE try finding a wrong one upwards};
	splitee[up] := middle ;	{fit splitting element back}
	midindex := up ;	{where it was split}
    end ; {split}

procedure quicksort(var sortee: table_type; lower,upper:integer) ;
    var
	centre : integer ;
    begin
	if lower < upper
	    then
		begin
		    split(sortee,lower,upper,centre) ;
		    quicksort(sortee,lower,centre-1) ;
		    quicksort(sortee,centre+1,upper)
		end {then}
    end; {quicksort}

procedure writeentry(var outfile:text; item : entry_type) ;

    var
	j : integer ;

    begin
	with item do
	    begin
		write(outfile,subject) ;
		if n_mains <> 0
		    then
			begin
			    write(outfile,chr(bold_code)) ;
			    write(outfile,mains[1]:1) ;
			    for j := 2 to n_mains do
				write(outfile,',',mains[j]:1) ;
			    write(outfile,chr(bold_code)) ;
			    if n_subs <> 0
				then write(outfile,',')
			end ; {then}
		if n_subs <> 0
		    then
			begin
			    write(outfile,subs[1]:1) ;
			    for j := 2 to n_subs do
				write(outfile,',',subs[j]:1)
			end ; { then }
		writeln(outfile)
	    end {with}
    end ; {writeentry}


procedure help;

    var
	null_line : string ;
    begin
	writeln(' This program generates a WordStar source') ;
	writeln('file of an index for manuals, etc.') ;
	writeln(' The index can be compiled from many files') ;
	writeln('which may be scanned at different times.') ;
	writeln(' The cumulative index file is stored in a') ;
	writeln('file called "index" and is updated after') ;
	writeln('each run of this program, so ERAse it when') ;
	writeln('you want to restart the index compilation') ;
	writeln(' The input files you are prompted for MUST') ;
	writeln('be "DISK FILE OUTPUT"s from the WordStar') ;
	writeln('Print command, with the FORMFEED option') ;
	writeln(' The output file is WordStar compatible,') ;
	writeln('and may be ^K Read into an index framework');
	write('Press return') ; read (null_line) ;
	writeln(' To mark an item for inclusion as one of');
	writeln('the main references, use ^KQ.') ;
	writeln(' To mark a minor reference, use ^KW') ;
	writeln(' These markers must SURROUND the reference');
	writeln('as for underlining.') ;
	writeln(' The main references are listed first in');
	writeln('BOLD type, and the minors after that in') ;
	writeln('normal type') ;
	writeln(' All marked text is converted to UPPER case');
	writeln('The max. number of references per subject');
	writeln('is ',max_refs,', and the maximum number of');
	writeln('subjects is ',max_entries)
    end ; {help}


begin {main program}

    assign(index,'index') ;

{ read in as much of the index as has been done already }
    num_entries := 0 ;
    reset(index) ;
    if ioresult <> 255
	then
	    begin
		while (index^.n_mains<>-1) and not eof(index)do
		    begin
			addentry(table,num_entries,index^) ;
			get(index)
		    end {while}
	    end ; {then}
    writeln(num_entries,' entries read from old index file');

{ read in the new WordStar source files to be scanned }
    repeat
	writeln('Enter name of WordStar print file, or CR to continue') ;
	read(filename) ;
	if filename <> ''
	    then
		if (filename = 'help') or (filename = 'HELP')
		    then help
		    else scanfile(table,num_entries,filename)
    until filename = '' ;

{ sort the new index }
    quicksort(table,1,num_entries) ;

{ save the new index }
    rewrite(index) ;
    if ioresult = 255
	then writeln('Could not update index file')
	else
	    begin
{ write index to the file }
		for i := 1 to num_entries do
		    write(index,table[i]^) ;
{ now add end of file mark with n_mains =-1 }
		end_file.n_mains := -1 ;
		write(index,end_file) ;

		close(index,result) ;
		if ioresult = 255
		    then writeln('Could not close index file')
		    else writeln(num_entries,' entries written to index file')
	    end {else} ;

{ ask if a WordStar output file is required yet }
    write('Is a WordStar output file required yet (y/n) ? ') ;
    read(response) ;
    if (response[1] = 'y') or (response[1] = 'Y')
	then
	    begin
		write('What filename ? ') ;
		read(filename) ;
		assign(text_out,filename) ;
		rewrite(text_out) ;
		if ioresult = 255
		    then writeln('Could not create ',filename)
		    else
			begin
			    for i := 1 to num_entries do
				writeentry(text_out,table[i]^);
			    close(text_out,result)
			end {else}
	    end {then}
end. {index}