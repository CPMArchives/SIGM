PROGRAM newfile ;	{$e+ error msgs}

  TYPE
	$STRING0 =	STRING 0;
	$STRING255 = 	STRING 255;

  VAR
	new_file:	TEXT;	{output file}
	file_name:	STRING 12;

	in_string:	STRING 80;

	nchars:		INTEGER;
	line_count:	INTEGER;	{#lines in file}

{PROCEDURE}

FUNCTION LENGTH (x: $STRING255) :INTEGER;  EXTERNAL;


  BEGIN  {main procedure}
	READLN(file_name);
	WRITELN('Create new file named ',file_name);

	REWRITE(file_name, new_file);
	nchars := 99;  {not zero}
	WHILE nchars <> 0 DO BEGIN
		WRITELN(':');
		READLN(in_string);
		nchars := LENGTH (in_string);
		IF nchars > 0 THEN BEGIN
			WRITELN(new_file,in_string);
		END{IF};
	END{WHILE};

	WRITELN(line_count,' lines in file ',file_name);
END{PROGRAM new_file}.
