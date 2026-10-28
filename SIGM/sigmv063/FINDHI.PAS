PROGRAM findhi;

 {Program to read a disk file using Pascal I/O }
 {and locate and count high-bit characters.}



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

   char12 = PACKED ARRAY [1..12] OF CHAR;
VAR
   infile   :sector_file;
   infilename   :char12;

   list_flag   :BOOLEAN;    {list output}

   s_recno     :INTEGER;
   in_buffer   :sector_array;
   in_bufptr   :INTEGER;
 

   ctr_highbit   :INTEGER;
   ctr_cc        :INTEGER;

   status   :INTEGER;

{----------------------------------------------------------}
{----------------------------------------------------------}
{--------------------------------------------------}
{ Translates the char in in_char into a 1 to 3 byte}
{ sequence stored in out_chars.  Sets nchars to the}
{ # of chars. }

PROCEDURE count_char ( in_char :byte );

BEGIN{PROCEDURE}
   IF in_char > 127 THEN BEGIN
      in_char := in_char - 128;
      ctr_highbit := ctr_highbit + 1;
      list_flag := TRUE;
   END{IF};

   IF in_char < 32 THEN BEGIN
      IF (in_char <> carriage_return) AND (in_char <> line_feed) THEN BEGIN
         ctr_cc := ctr_cc + 1;
      END{IF};
     END
   ELSE IF in_char = 127 THEN BEGIN
      ctr_cc := ctr_cc + 1;
   END{IF};
END{PROCEDURE};


{-------------------------------------------------------------}

FUNCTION open_infile  :INTEGER;

BEGIN{FUNCTION}
   WRITE('Enter the input filename: ');
   infilename := '            ';
   READLN(infilename);

   RESET(infilename,infile);

   in_bufptr := sector_size + 1;

   open_infile := 0;
   IF EOF(infile) THEN open_infile := -1;

END{FUNCTION};

{-------------------------------------------------------------}
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

FUNCTION close_infile  :INTEGER;

BEGIN{FUNCTION}
   close_infile := 0;
END{FUNCTION};


{-----------------------------------------}

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

{--------------------------------------------------}
FUNCTION count_file  :INTEGER;

VAR
   status   :INTEGER;
   i        :INTEGER;
   in_char  :byte;

BEGIN{FUNCTION}
   status := 0;
   WHILE status = 0  DO BEGIN
      status := get_char (in_char);
      IF status=0 THEN BEGIN
         count_char (in_char);
         IF list_flag THEN WRITE (CHR(in_char));
      END{IF};
   END{WHILE};
   count_file := status;
END{FUNCTION};


{--------------------------------------------------}
{--------------------------------------------------}

BEGIN{PROGRAM}
   WRITELN ('FindHi  Version ',version);

   list_flag := FALSE;
   ctr_cc := 0;
   ctr_highbit := 0;

   status := open_infile; 
   IF status <> 0 THEN BEGIN
      WRITELN('Could not open file ', infilename);
   END{IF};

   IF status = 0 THEN BEGIN
      status := count_file;
   END{IF};

   WRITELN(ctr_cc, ' control charó.  ',
           ctr_highbit, ' high-bit chars.');

   status := close_input;

END{PROGRAM}.
