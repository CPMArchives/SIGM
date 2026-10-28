PROGRAM fcount;

 {Program to read a disk file }
 {and count the number of chars and lines. }
 {Program will also allow splitting a long file }
 {into several pieces. }


CONST
   version = '1.0';
   sector_size = 128;   {#bytes in a sector}

   carriage_return = 13; {^M}
   line_feed  = 10;      {^J}
   eof_char  = 26;       {^Z}

TYPE
   byte = 0..255;
   sector_array = PACKED ARRAY [1..sector_size] OF byte;
   sector_file  = FILE OF sector_array;

   ctr_array  = PACKED ARRAY [1..2] OF INTEGER;  {1=units, 2=thousands}

   outch_array = PACKED ARRAY [1..3] OF byte;
   char12 = PACKED ARRAY [1..12] OF CHAR;

VAR
   infile   :sector_file;
   infilename   :char12;

   outf_flag   :BOOLEAN;  {true if outfile present}
   outfile   :sector_file;
   outfilename   :char12;

   list_flag   :BOOLEAN;    {list output}


   in_buffer   :sector_array;
   in_bufptr   :INTEGER;
 
   out_buffer   :sector_array;
   out_bufptr   :INTEGER;

   char_ctr   :ctr_array;
   line_ctr   :ctr_array;
   line_mod_ctr   :ctr_array;
   line_thousands_limit  :INTEGER;


   status   :INTEGER;
   i        :INTEGER;

{----------------------------------------------------------}
{----------------------------------------------------------}
{ Increment a symbolic name.  Eg  XXX021 to XXX022. }

PROCEDURE incr_name (VAR name :char12);

VAR
   i    :INTEGER;
   col   :INTEGER;
   flag   :BOOLEAN;

BEGIN{PROCEDURE}
   col := 12;
   WHILE (col>=1) AND (name[col]=' ') DO  col := col - 1;

   flag := TRUE;
   WHILE flag AND (col>=1) DO BEGIN
      i := ORD (name[col]) + 1;
      IF i <= ORD('9') THEN BEGIN
         flag := FALSE;
         name[col] := CHR(i);
        END
      ELSE  BEGIN
         name[col] := '0';
         col := col - 1;
      END{IF};
   END{WHILE};
END{PROCEDURE};


{--------------------------------------------------}
{Reset a big-counter to zero } 

PROCEDURE ctr_reset (VAR ctr :ctr_array);

BEGIN{PROCEDURE}
   ctr[1] := 0;
   ctr[2] := 0;
END{PROCEDURE};

{--------------------------------------------------}
{Increments a big-counter. }

PROCEDURE ctr_count  (VAR ctr :ctr_array);

BEGIN{PROCEDURE}
   ctr[1] := ctr[1] + 1;
   IF ctr[1] >= 1000 THEN BEGIN
      ctr[2] := ctr[2] + 1;
      ctr[1] := 0;
   END{IF};
END{PROCEDURE};


{-------------------------------------------------------------}
{Test a counter against another counter}
{Returns TRUE if counter A is bigger than counter B}

FUNCTION ctr_gtr (ctra :ctr_array;
                  ctrb :ctr_array )
                 : BOOLEAN;
BEGIN{FUNCTION} 
   ctr_gtr := FALSE;

   IF ctra[2] > ctrb[2] THEN ctr_gtr := TRUE;

   IF ctra[2] = ctrb[2] THEN ctr_gtr :=  ctra[1] > ctrb[1];
END{FUNCTION};


{-------------------------------------------------------------}
{Print a big-counter }

PROCEDURE ctr_print (ctr :ctr_array);

BEGIN{PROCEDURE}
   WRITE (ctr[2], ',' ,  ctr[1]:3 );
END{PROCEDURE};


{-------------------------------------------------------------}
PROCEDURE get_outfilename;

BEGIN{PROCEDURE}
   WRITE('Enter the output filename: ');
   outfilename := '            ';
   READLN (outfilename);

   outf_flag := TRUE;
   IF outfilename = '            '  THEN outf_flag := FALSE;

END{PROCEDURE};

{-------------------------------------------------------------}
PROCEDURE get_infilename;

BEGIN{PROCEDURE}
   WRITE('Enter the input filename: ');
   infilename := '            ';
   READLN (infilename);
END{PROCEDURE};

{------------------------------------------------------------}
FUNCTION get_limit  :INTEGER; 

VAR 
   result   :INTEGER;

BEGIN{FUNCTION}
   READLN (result);
   IF result=0 THEN result := MAXINT-1;
   get_limit := result;
END{FUNCTION};


{------------------------------------------------------------}

FUNCTION open_infile  :INTEGER;

VAR
   result   :INTEGER; 

BEGIN{FUNCTION}
   RESET(infilename,infile);

   in_bufptr := sector_size + 1;

   result := 0;
   IF EOF(infile) THEN result := -1;

   WRITELN('Open input file: ',infilename:12,
           '   result=', result );

   open_infile := result;

END{FUNCTION};

{-------------------------------------------------------------}

FUNCTION open_outfile   :INTEGER;

VAR
   result   :INTEGER;

BEGIN{FUNCTION}
   REWRITE (outfilename, outfile);

   out_bufptr := 0;

   result := 0;

   WRITELN('Open output file: ', outfilename,
           '   result=', result );

END{FUNCTION};

{--------------------------------------------------------}
{Opens the next output file in sequence.}
{Returns 0 if no error, <0 if error. }

FUNCTION open_next_outfile  :INTEGER;

VAR
   result   :INTEGER;

BEGIN{FUNCTION}
   incr_name (outfilename);

   result := open_outfile;
   
   open_next_outfile := result;
END{FUNCTION};


{--------------------------------------------------------}
{Reads the next sector from the input file. }
{Returns 0 = normal;  -1 = error or EOF. }

FUNCTION read_infile  :INTEGER;

BEGIN{FUNCTION}
   IF EOF(infile) THEN BEGIN
      read_infile := -1;
      in_bufptr := sector_size + 1;
      END
   ELSE BEGIN
      READ (infile, in_buffer);
      in_bufptr := 0;
      read_infile := 0;
   END{IF};
END{FUNCTION};

{--------------------------------------------------------}
{Writes the next sector into the output file. }
{Returns 0 = normal,  <0 if error. }

FUNCTION write_outfile    :INTEGER;

BEGIN{FUNCTION}
   WRITE(outfile, out_buffer);
   out_bufptr := 0;
   write_outfile := 0;
END{FUNCTION};
  

{--------------------------------------------------------}

FUNCTION close_infile  :INTEGER;

BEGIN{FUNCTION}
   close_infile := 0;
END{FUNCTION};


{--------------------------------------------------------}

FUNCTION close_outfile  :INTEGER;
BEGIN{FUNCTION}
   close_outfile := 0;
END{FUNCTION};


{--------------------------------------------------------}
{Gets the next char (pseudochar, a byte) from the input buffer.}
{Signals EOF by returning -1.  Returns 0 if get a char. }


FUNCTION get_char ( VAR in_char :byte )  :INTEGER; 

VAR
   status   :INTEGER;

BEGIN{FUNCTION}
   status := 0;
   IF in_bufptr >= sector_size THEN BEGIN
      status := read_infile;
   END{IF};

   IF status = 0 THEN BEGIN
      in_bufptr := in_bufptr + 1;
      in_char := in_buffer[in_bufptr];
      IF in_char = eof_char THEN status := -1;
   END{IF};

   get_char := status;
END{FUNCTION};

{--------------------------------------------------------}

FUNCTION put_char (out_char :byte)  :INTEGER;

VAR
   status   :INTEGER;

BEGIN
   status := 0;

   out_bufptr := out_bufptr + 1;
   out_buffer[out_bufptr] := out_char;
   
   IF out_bufptr >= sector_size THEN BEGIN
      status := write_outfile;
   END{IF};

   put_char := status;
END{FUNCTION};


{--------------------------------------------------------}
{Purge any chars still remaining in the output buffer}

PROCEDURE put_purge;

VAR
   i       :INTEGER;
   remaining   :INTEGER;
   status   :INTEGER;

BEGIN{PROCEDURE}
   status := put_char (eof_char);  {ensure at least 1 EOL}
   remaining := sector_size - out_bufptr;
   FOR i:= 1 TO remaining DO BEGIN
      status := put_char (eof_char);
   END{FOR};
END{PROCEDURE};


{--------------------------------------------------------}

PROCEDURE putout_char (in_char :byte);

VAR
   result   :INTEGER;

BEGIN{PROCEDURE}
   IF outf_flag THEN BEGIN
      result := put_char (in_char);
      IF line_mod_ctr[2] > line_thousands_limit THEN BEGIN
         put_purge;
         result := open_next_outfile;
         ctr_reset (line_mod_ctr);
      END{IF};
   END{IF};
END{PROCEDURE};

{----------------------------------------------------}

PROCEDURE count_char (in_char :byte);

BEGIN{PROCEDURE}
   ctr_count (char_ctr);

   IF in_char = carriage_return THEN BEGIN
      ctr_count (line_ctr);
      ctr_count (line_mod_ctr);
   END{IF};
END{PROCEDURE};


{--------------------------------------------------}

FUNCTION count_file   :INTEGER;

VAR
   i        :INTEGER;
   status   :INTEGER;
   in_char  :byte;
   out_chars :outch_array;
   îchars   :INTEGER;

BEGIN{FUNCTION}
   status := 0;
   ctr_reset (line_ctr);
   ctr_reset (line_mod_ctr);
   ctr_reset (char_ctr);

   WHILE status = 0  DO BEGIN
      status := get_char (in_char);
      IF (status<>0) AND outf_flag THEN BEGIN
         put_purge;
        END
      ELSE BEGIN
         count_char (in_char);
         IF outf_flag THEN putout_char (in_char);
      END{IF};
   END{WHILE};
   count_file := status;
END{FUNCTION};


{--------------------------------------------}
{--------------------------------------------}

BEGIN{PROGRAM}
   WRITELN ('Fcount  Version ', version);

   get_infilename;
   status := open_infile;
   IF status<>0 THEN BEGIN
      WRITELN('*** Could not open input file ', infilename);
   END{IF};

   IF status=0  THEN BEGIN
      get_outfilename;
      IF outf_flag THEN BEGIN
         status := open_outfile;
         IF status<>0 THEN BEGIN
            WRITELN('*** Could not open ouput file ', outfilename);
         END{IF}; 
      END{IF};
   END{IF};
     
   IF status=0 THEN BEGIN
      WRITE('Enter max #lines per file (in thousands: ');
      line_thousands_limit := get_limit;
      IF line_thousands_limit > 0 THEN BEGIN
         WRITELN('NOTE that filename should be xxxxx.001');
      END{IF};
   END{IF};

   IF status=0 THEN BEGIN
      status := count_file;
   END{IF};
 
   ctr_print (line_ctr);
   WRITE (' lines. ');
   ctr_print (char_ctr);
   WRITE (' characters.');
   WRITELN;

   status := close_input;

   IF outf_flag THEN BEGIN
      status := close_output;
   END{IF};

END{PROGRAM}.
