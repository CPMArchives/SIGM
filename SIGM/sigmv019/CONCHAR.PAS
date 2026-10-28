(********************************************************
**  PROGRAM TITLE:	ConChar
**
**  WRITTEN BY:		RAYMOND E. PENLEY
**  DATE WRITTEN:	19 June 1980
**
**  WRITTEN FOR:	PASCAL/Z USERS
**
**
********************************************************)
Program CONCHARDEMO;
LABEL	999; { Fatal error }
CONST
  default = 80;		{ Default length of strings }
  input   = 0;		{ *** Implementation dependent *** }
  strmax  = 255;
  space   = ' ';
TYPE
  Linebuffer = STRING 80;{ Command line input buffer }
(*---Pascal/Z needs these TYPE definitions---<UGLY UGLY UGLY>---*)
  str0	   = STRING 0 ;
  str255   = STRING strmax;
VAR
  bell		: char;
  Cmlline	: STRING default;{ this prgms Console input buffer }
  Cmllen	: integer;
  fatal_error	: boolean;
  Text_file,
  Work_file	: Text;

(*---Pascal/Z needs these definitions---<UGLY UGLY UGLY>---*)
Function length(x: str255): integer; external;
Procedure setlength(var x: str0; y: integer); external;

Procedure GCML( VAR Line : Linebuffer;
		VAR len  : integer );
{	Read the system input buffer.
	This MUST be the first read in the
	entire program.
RETURNS:
  len = 0 if buffer is empty
	else the length of line
  Line = operating system buffer
	 <in uppercase>

GLOBAL	Linebuffer : string 80;
}
begin
  setlength(line,0);
  len := 0;
  If not eoln(input) then
    begin{  read from the input buffer  }
	readln(line);
	len := length(line);
    end{  read from the input buffer  };
End{of GCML};

Procedure ConnectFiles;
LABEL	3;
CONST	FSpecLeng = 14;	{ Max length of total CP/M file Identifier }

TYPE	   fspecs = array[1..FSpecLeng] of char;
	FileSpecs = array[1..2] of fspecs;
	extension = array[1..4] of char;
	FileNames = array[1..FSpecLeng] of char;

VAR	fspec: FileSpecs;
	 flen: 0..FSpecLeng;
       Cmlptr: 1..80;
	CmlCh: char;
ext_specified: boolean;
	  pos: 0..255;

   Procedure FILE_SCAN;
   begin
   (* OPEN file "fspec[2]" for READ<INPUT> assign Text_file *)
	RESET(fspec[2],Text_file);
     If not EOF(Text_file) then
   (* OPEN file "fspec[1]" for WRITE<OUTPUT> assign Work_File *)
	REWRITE(fspec[1],Work_File)
      Else
        begin
          Write('File ', fspec[2],'not found.');
          {EXIT}fatal_error := true;
        end;
   end{of file scan};

   Procedure QUIT;
   begin
     Writeln(bell,' Command Line error.');
     Writeln('Your Command line --->',Cmlline);
     Writeln('You entered ',Cmllen:3,' characters');
     writeln;
     write(  '< (dr unit:)Input File name.PAS > ');
     writeln('< (dr unit:)Output File name(.XRF) >');
     writeln;
     writeln('Input file must be a Pascal progam.');
     writeln('Output file name may have an extension of your choice.');
     writeln('If not specified the output file ext = .XRF');
     writeln('() = otional');
     writeln;writeln;
     fatal_error := true;
   end;

   Procedure Next_ClmCh;
   begin
     If (Cmlptr >= Cmllen) then fatal_error := true
     Else
       begin
	 Cmlptr := Cmlptr + 1;
	 CmlCh := Cmlline[Cmlptr];
       end;
   end;

   Procedure GetFspec( IO: integer; dfltext: extension );
   LABEL	4;

      Procedure Get_Next;
      begin
        If (flen >= FSpecLeng) then fatal_error := true
	Else
	  begin
	     FSPEC[IO][flen] := CmlCh;
             flen := flen + 1;
	     Next_ClmCh;
	  end;
      end;

   begin{ get fspec }
     FSPEC[IO] := '              ';
     flen := 1;
     ext_specified := false;
     while CmlCh IN ['A'..'Z','0'..'9',':','.'] do
       begin
         If not ext_specified then
	    ext_specified := (CmlCh='.');
         Get_Next;If fatal_error then{EXIT}goto 4;
       end;
     If (flen > 1) and (not ext_specified) then
       for pos := 1 to 4 do
         begin
	   FSPEC[IO][flen] := dfltext[pos];
	   flen := flen + 1;
         end;
   4:
   end{ Get Fspec };

begin{  ConnectFiles  }
{  Read the system input buffer into Cmlline   }
  GCML(CmlLine,Cmllen);
  If (Cmllen=0) then{EXIT}
     begin fatal_error := true;goto 3 end;
  CmlCh := CmlLine[1];
  Cmlptr := 1;
  Cmllen := Cmllen + 1;
  CmlLine[Cmllen] := space;
  While (CmlCh = space) AND (not fatal_error) do Next_ClmCh;
  Getfspec(2,'.PAS');
  If flen=1 then
    begin
	Write( 'No Input File Specified.');
	fatal_error := true;
	{EXIT}goto 3;
    end;
  Next_ClmCh;
  While (CmlCh = space) AND (not fatal_error) do Next_ClmCh;
  Getfspec(1,'.XRF');
  If flen=1 then
    begin
	Write( 'No Output File Specified.');
	fatal_error := true;
	{EXIT}goto 3;
    end;
   FILE_SCAN;
3: If fatal_error then QUIT;
end{ Connect files };

Procedure Initialize;
LABEL	5;
begin
  fatal_error := false;
  bell := chr(7);
  ConnectFiles;
  If fatal_error then goto 5;
  {					}
  {  continue with initialization now   }
  {					}
5:
end;

begin(*---ConChar Demo---*)
  writeln(' ':15,'---   Command Line Input Demo  ---');
  writeln;writeln;
  writeln('This program reads directly from the system buffer.');
  writeln('Proper execution will provide your program with:');
  writeln(' 1. a drive unit and a file name so you can');
  writeln('    open a file for input.');
  writeln(' 2. A drive unit and a file name for an output');
  writeln('    file. The extension defaults to .XRF if not specified.');
  Writeln('Execute this program like so:');
  writeln('   CONCHAR  A:input file.PAS  B:output file.XRF');
  writeln;writeln;
  Initialize;
  If fatal_error then{HALT} goto 999;
  Writeln('---End of program');
  writeln;
999:{Fatal error}
end.

