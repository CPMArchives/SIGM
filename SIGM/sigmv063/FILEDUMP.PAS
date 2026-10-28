PROGRAM t;

 {Program to read a disk file using Pascal direct I/O }

CONST
   version = '1.0';

TYPE
   byte = 0..255;
   sector_array = PACKED ARRAY [1..128] OF byte;
   
   char12 = PACKED ARRAY [1..12] OF CHAR;

VAR
   infile   :FILE OF sector_array;
   infilename   :char12;

   s_recno     :INTEGER;
   s_buffer   :sector_array;

{----------------------------------------------------------}
{----------------------------------------------------------}

PROCEDURE dump_buffer (size :INTEGER) ;

VAR
   first   :INTEGER;
   nchars   :INTEGER;
   col     :INTEGER;
   i       :INTEGER;

BEGIN{PROCEDURE}
   first := 1;
   WHILE size > 0 DO BEGIN
      nchars := size;
      IF nchars > 78 THEN nchars := 78;
      FOR col := first TO first+nchars-1 DO BEGIN
         i := s_buffer[col];
         IF (i<32) OR (i>126) THEN i := ORD('?');
         WRITE ( CHR(i) );
      END{FOR};
      WRITELN; 
      first := first + nchars;
      size := size - nchars;
   END{WHILE};
END{PROCEDURE};


{-------------------------------------------------------------}

PROCEDURE open_file;  

BEGIN{PROCEDURE}
   WRITE('Enter the input filename: ');
   infilename := '            ';
   READLN(infilename);
   WRITELN(' Filename=',infilename);

   RESET(infilename,infile);
END{PROCEDURE};

{--------------------------------------------}
PROCEDURE pause;
 
VAR
   response   :CHAR; 

BEGIN{PROCEDURE}
   WRITELN('enter CR to continue');
   READLN(response);
END{PROCEDURE};

{--------------------------------------------------}
{--------------------------------------------------}

BEGIN{PROGRAM}
   WRITELN('FileDump  Version ',version);

   open_file; 

   s_recno := 0;
   WHILE NOT EOF(infile) DO BEGIN
      s_recno := s_recno + 1;
      READ (infile:0, s_buffer);

      WRITELN('Sector #', s_recno:4);

      dump_buffer (128);
  
      pause;

   END{WHILE};
END{PROGRAM}.
