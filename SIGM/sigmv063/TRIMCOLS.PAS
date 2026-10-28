PROGRAM trimline;

{$e+}

 {Program to read a file, trim the rightmost columns, }
 {then trim trailing blanks, and then output into a }
 {second file. }


CONST
   version = '1.0';
   maxline = 255;    {longest line we can handle}

TYPE
   byte = 0..255;
   char12 = PACKED ARRAY [1..12] OF CHAR;

   STRING0 = STRING 0;
   STRING255 = STRING 255;
   line_string = STRING maxline;
   
VAR
   status   :INTEGER;
  
   flag        :BOOLEAN;
   trim_flag   :BOOLEAN;
   list_flag   :BOOLEAN;
   debug_flag  :BOOLEAN;


   inf_name   :char12;
   inf_file   :TEXT;  {input file variable}

   outf_name   :char12;
   outf_file   :TEXT;  {output file variable}
   rec_count, rec_thousands   :INTEGER;


   this_line   :line_string;
   
   trunc_length   :INTEGER;   {truncate lines to this length}

{-----------------------------------------------------------}
{-----------------------------------------------------------}
{-----------------------------------------------------------}

FUNCTION LENGTH ( str: STRING255) :INTEGER;  EXTERNAL;
FUNCTION INDEX  ( stra, strb :STRING255 ):INTEGER; EXTERNAL;
PROCEDURE SETLENGTH (VAR str :STRING0; len :INTEGER); EXTERNAL;

{-----------------------------------------------------------}


PROCEDURE trim_blanks  ( VAR this_line :line_string );
 
 {Trim trailing blanks }

VAR
   col   :INTEGER;
   flag   :BOOLEAN;

BEGIN{PROCEDURE}
   col := LENGTH (this_line);
   flag := FALSE;
   WHILE (col>0) AND (NOT flag) DO BEGIN
      IF this_line[col] = ' ' THEN BEGIN
         col := col - 1;
         END
      ELSE BEGIN
         flag := TRUE;
      END{IF};
   END{WHILE};

   SETLENGTH (this_line, col);

   IF debug_flag THEN BEGIN
      col := LENGTH (this_line);
      WRITELN ('%exit trim_blanks: length=', col:4);
      WRITELN (this_line);
   END{IF};

END{PROCEDURE};

{--------------------------------------------------------}

PROCEDURE truncate_line (VAR this_line :line_string);

VAR
   len   :INTEGER;

BEGIN{PROCEDURE}
   len := LENGTH (this_line);
   IF len > trunc_length THEN BEGIN
      SETLENGTH (this_line, trunc_length);
   END{IF};

   IF debug_flag THEN BEGIN
      len := LENGTH (this_line);
      WRITELN ('%exit trunc_line: length=', len:4);
      WRITELN (this_line);
   END{IF};

END{PROCEDURE};


{--------------------------------------------------------}


FUNCTION upper_case (in_char :CHAR) :CHAR;

BEGIN
   upper_case := in_char;
   IF in_char IN ['a'..'z'] THEN BEGIN
      upper_case := CHR( ORD(in_char) - 32 );
   END{IF};
END{FUNCTION};


{--------------------------------------------------------}
 
FUNCTION ask_yes_or_no  :BOOLEAN;

VAR
   flag   :BOOLEAN;
   response   :CHAR;
BEGIN{FUNCTION}
   flag := FALSE;
   WHILE NOT flag DO BEGIN
      WRITE ('(Y or N)');
      READLN(response);
      response := upper_case (response);
      IF (response='Y') OR (response='N') THEN BEGIN
         flag := TRUE;
         END
      ELSE BEGIN
         WRITELN('Try again. ');
      END{IF};
   END{WHILE};

   ask_yes_or_no :=  response='Y';
END{FUNCTION};


{--------------------------------------------------------}

FUNCTION get_open :INTEGER;

VAR
   result   :INTEGER;

BEGIN{FUNCTION};
   result := 0;

   WRITE ('Enter the input file name: ');
   READLN (inf_name);

   RESET (inf_name, inf_file);

   IF EOF(inf_file) THEN result := -1;

   get_open := result;
END{FUNCTION};


{--------------------------------------------------------}
 
FUNCTION get_close  :INTEGER;

BEGIN{FUNCTION}
   get_close := 0;
END{FUNCTION};


{--------------------------------------------------------}

FUNCTION get_line (VAR this_line :line_string) :INTEGER;

VAR
   result   :INTEGER;
   len    :INTEGER;

BEGIN{FUNCTION}
   result := 0;

   IF EOF(inf_file) THEN BEGIN
      result := -1;
      SETLENGTH (this_line, 0);
      END
   ELSE BEGIN

      READLN (inf_file, this_line);

      IF debug_flag THEN BEGIN
         len := LENGTH (this_line);
         WRITELN ('Input line: status=', result:4, 
                  '  length=', len:3);
         WRITELN (this_line);
      END{IF};
   END{IF};

   get_line := result;
END{FUNCTION};


{--------------------------------------------------------}

FUNCTION put_open :INTEGER;

VAR
   result   :INTEGER;

BEGIN{FUNCTION};
   result := 0;

   WRITE ('Enter the output file name: ');
   READLN (outf_name);

   REWRITE (outf_name, outf_file);

   rec_count := 0;
   rec_thousands := 0;
 
   put_open := result;
END{FUNCTION};


{-----------------------------------------------------------}

FUNCTION put_close :INTEGER;

VAR
   result   :INTEGER;

BEGIN{FUNCTION}
   result := 0;

   WRITELN (rec_thousands:4, ',', rec_count:3,
            ' output records in file ', outf_name );
   
   put_close := result;
END{FUNCTION};


{--------------------------------------------------------}

FUNCTION put_line (VAR this_line :line_string ) :INTEGER;

VAR
   result   :INTEGER;
   len      :INTEGER;

BEGIN{FUNCTION}
   result := 0;

   IF list_flag and debug_flag THEN BEGIN
      len := LENGTH (this_line);
      WRITE (len:2, ' ');
   END{IF};

   IF list_flag THEN WRITELN (this_line );
   WRITELN (outf_file, this_line );

   rec_count := rec_count + 1;
   IF rec_count >= 1000 THEN BEGIN
      rec_thousands := rec_thousands + 1;
      rec_count := 0;
   END{IF};

   put_line := result;
END{FUNCTION};



{-------------------------------------------------------}
{-------------------------------------------------------}
{-------------------------------------------------------}

BEGIN{PROGRAM}
   WRITELN
   ('Trim File Program  Version ', version);

   WRITELN ('This program reads an input file, trims the ');
   WRITELN ('last N columns from the lines, then trims any');
   WRITELN ('trailing blanks,');
   WRITELN ('and writes lines into output file.');

   WRITE('Debugging on? ');
   debug_flag := ask_yes_or_no;
   IF debug_flag THEN WRITELN('Debug is on.');

   WRITE('List the lines as they are read? ');
   list_flag := ask_yes_or_no;

   flag := FALSE;
   WHILE NOT flag DO BEGIN
      WRITE ('Enter column# to which we will truncate: ');
      READLN (trunc_length);
      IF (trunc_length < 1)  OR  (trunc_length > 255) THEN BEGIN
         WRITELN ('*** Too small or too big.  Try again.');
         END
      ELSE BEGIN
         WRITELN ('Lines longer than ', trunc_length:3,
                   ' will be truncated.');
         flag := TRUE;
      END{IF};
   END{WHILE};

   WRITE('Trim trailing blanks from output lines? ');
   trim_flag := ask_yes_or_no;

   status := get_open;
   IF status <> 0 THEN WRITELN ('Cannot open input file.');

   IF status=0 THEN BEGIN
      status := put_open;
      IF status <>0 THEN WRITELN ('Cannot open output file.');
   END{IF};

   IF status=0 THEN BEGIN
      WHILE status = 0  DO BEGIN
         status := get_line (this_line);
      
         IF status = 0 THEN BEGIN
            truncate_line (this_line);
            IF trim_flag THEN trim_blanks (this_line);
            status := put_line (this_line);
         END{IF};
      END{WHILE};
   END{IF};

   status := get_close;
   status := put_close;

   WRITELN('End of Trim');

END{PROGRAM}
.
