PROGRAM removecc;

{ Program to read a disk file   }
{ and remove any control characters or change them to }
{ a sequence of printable characters.   }
{ Also finds any high-bit-set characters,  }
{ strips the high bit and optionally prefixes the char }
{ with an escape character. }

{Assume the escape char for control chars is chosen to  }
{be "%".  Then this table shows how control codes are   }
{represented in the output file.  }

{  binary char value (ORD)    representation
  -------------------------   --------------
    0  NUL  %@
    1  SOH  %A
    2  STX  %B
    .        .
    .        .
    .        .
   25  EM   %Y
   26  SUB  %Z
   27  ESC  %[
   28  FS   %\
   29  GS   %]
   30  RS   %^
   31  US   %_
   92  %    %%       ***** note this special representation!
  127  DEL  %?       ***** note this special representation!
 }



CONST
   version = '1.1';
   sector_size = 128;   {#bytes in a sector}

   carriage_return = 13; {^M}
   line_feed  = 10;      {^J}
   eof_char  = 26;       {^Z}

TYPE
   byte = 0..255;
   sector_array = PACKED ARRAY [1..sector_size] OF byte;
   sector_file  = FILE OF sector_array;

   outch_array = PACKED ARRAY [1..3] OF byte;
   char12 = PACKED ARRAY [1..12] OF CHAR;
VAR
   infile   :sector_file;
   infilename   :char12;

   outfile   :sector_file;
   outfilename   :char12;

   list_flag   :BOOLEAN;    {list output}


   s_recno     :INTEGER;
   in_buffer   :sector_array;
   in_bufptr   :INTEGER;
 
   out_buffer   :sector_array;
   out_bufptr   :INTEGER;

   ctr_highbit   :INTEGER;
   ctr_cc        :INTEGER;

   esc_highbit_char   :byte;  {escape char for highbit chars}
   esc_control_char   :byte;  {escape char for control chars}

   status   :INTEGER;

{----------------------------------------------------------}
{----------------------------------------------------------}
 
PROCEDURE ask_escape_chars;

VAR
   flag   :BOOLEAN;
   response   :CHAR;

BEGIN
   flag := TRUE;
   WHILE flag DO BEGIN
      WRITE ('Enter the control-chars escape character: ');
      READLN (response);
      IF response=' ' THEN BEGIN
         WRITELN ('No escape char; control codes remain as is.');
         esc_control_char := 0;
         flag := FALSE;
         END
      ELSE IF response IN ['!', '#', '$', '%', '&', '*',
                           '|', '~', '`', '''', '{', '}',
                           '=', '"', '<', '>', '/']
         THEN BEGIN
             flag := FALSE;
             esc_control_char := ORD (response);
         END
      ELSE BEGIN
            WRITELN('*** Not an acceptable character. Try again.');
      END{IF};
   END{WHILE};

   flag := TRUE;
   WHILE flag DO BEGIN
      WRITE ('Enter the highbit-chars escape character: ');
      READLN (response);
      IF response=' ' THEN BEGIN
         WRITELN ('No escape char; high bits will be stripped.');
         esc_highbit_char := 0;
         flag := FALSE;
         END
      ELSE IF response IN ['!', '#', '$', '%', '&', '*',
                           '|', '~', '`', '''', '{', '}',
                           '=', '"', '<', '>', '/']  THEN BEGIN
          flag := FALSE;
          esc_highbit_char := ORD (response);
          END
      ELSE BEGIN
            WRITELN('*** Not an acceptable character. Try again.');
      END{IF};
      IF (esc_highbit_char>0) AND
            (esc_control_char = esc_highbit_char) THEN BEGIN
         WRITELN ('*** Cannot be the same as the control escape char.');
         WRITELN ('    Try again. ');
         flag := TRUE;
      END{IF};
   END{WHILE};
END{PROCEDURE};


{--------------------------------------------------}

{ Translates the char in in_char into a 1 to 3 byte}
{ sequence stored in out_chars.  Sets nchars to the}
{ # of chars. }

PROCEDURE xlate_char ( in_char :byte;
                   VAR out_chars :outch_array;
                   VAR nchars :INTEGER );

BEGIN{PROCEDURE}
   nchars := 0;
   IF in_char > 127 THEN BEGIN
      {Handle high-bit chars}
      in_char := in_char - 128;
      ctr_highbit := ctr_highbit + 1;
      IF esc_highbit_char > 0  THEN BEGIN
         nchars := nchars + 1;
         out_chars[nchars] := esc_highbit_char;
      END{IF};
   END{IF};

   IF (in_char>31) AND (in_char<127) THEN BEGIN
      {Handle "ordinary" characters. }
      nchars := nchars + 1;
      out_chars[nchars] := in_char;
      IF (in_char=esc_control_char) OR 
         (in_char=esc_highbit_char)
      THEN BEGIN
         nchars := nchars + 1;
         out_chars[nchars] := in_char;
      END{IF};
     END
   ELSE IF (in_char=carriage_return) OR
           (in_char=line_feed) THEN BEGIN
         nchars := nchars + 1;
         out_chars[nchars] := in_char; 
      END
   ELSE IF (in_char<=31) OR (in_char=127) THEN BEGIN
      { Handle control chars. }
      { We have already excluded CR and LF}
      ctr_cc := ctr_cc + 1;
      IF esc_control_char=0 THEN BEGIN
         nchars := nchars + 1;
         out_chars[nchars] := in_char;
         END
      ELSE BEGIN
         nchars := nchars + 1;
         out_chars[nchars] := esc_control_char;
         nchars := nchars + 1;
         out_chars[nchars] := in_char + ORD('@');
         IF in_char=127  THEN out_chars[nchars] := ORD('?');
      END{IF};
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

FUNCTION open_outfile   :INTEGER;

BEGIN{FUNCTION}
   WRITE('Enter the output filename: ');
   outfilename := '            ';
   READLN (outfilename);

   REWRITE (outfilename,outfile);

   out_bufptr := 0;

   open_outfile := 0;
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
{Purge the last buffer load to the output file.}

PROCEDURE put_purge;

VAR
   i       :INTEGER;
   remaining   :INTEGER;
   status   :INTEGER;

BEGIN{PROCEDURE}
   remaining := sector_size - out_bufptr;
   FOR i:= 1 TO remaining DO BEGIN
      status := put_char (eof_char);
   END{FOR};
END{PROCEDURE};


{--------------------------------------------------------}

PROCEDURE pause;
 
VAR
   response   :CHAR; 

BEGIN{PROCEDURE}
   WRITELN('enter CR to continue');
   READLN(response);
END{PROCEDURE};

{--------------------------------------------------}
FUNCTION copy_file  :INTEGER;

VAR
   status   :INTEGER;
   i        :INTEGER;
   in_char  :byte;
   out_chars   :outch_array;
   nchars   :INTEGER;

BEGIN{FUNCTION}
   status := 0;
   WHILE status = 0  DO BEGIN
      status := get_char (in_char);
      IF status <> 0 THEN BEGIN
         put_purge;
        END
      ELSE BEGIN
         xlate_char (in_char, out_chars, nchars);
         FOR i := 1 TO nchars DO BEGIN
            IF status = 0 THEN status := put_char (out_chars[i]);
         END{FOR};
      END{IF};
   END{WHILE};
   copy_file := status;
END{FUNCTION};


{--------------------------------------------------}
{--------------------------------------------------}

BEGIN{PROGRAM}
   WRITELN ('RemoveCC  Version ',version);

   ctr_cc := 0;
   ctr_highbit := 0;

   status := open_infile; 
   IF status <> 0 THEN BEGIN
      WRITELN('Could not open file ', infilename);
   END{IF};

   IF status = 0 THEN BEGIN
      status := open_outfile;
      IF status <> 0 THEN BEGIN
         WRITELN('Could not open output file ',outfilename);
      END{IF};
   END{IF};

   IF status=0 THEN BEGIN
      ask_escape_chars;
   END{IF};


   IF status = 0 THEN BEGIN
      status := copy_file;
   END{IF};

   WRITELN(ctr_cc, ' control chars.  ',
           ctr_highbit, ' high-bit chars.');

   status := close_input;
   status := close_output;

END{PROGRAM}.
