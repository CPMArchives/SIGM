program strip8;

(*************************************************)
(*                                               *)
(*  This program inhales a text file containing  *)
(*  characters with the 8th bit set (like those  *)
(*  produced by WordStar), and outputs the text  *)
(*  to another file, with the 8th bit cleared.   *)
(*                                               *)
(*************************************************)

const
  bufsize = 16384;

type
  name = string[14];

var
  infile, outfile: text;
  inname, outname: name;
  indata, inputchar: char;
  buffer: array[1..bufsize] of char;
  bufpoint, outpoint : integer;

function clearbit8(inchar: char): char;

  begin
    clearbit8 := chr(ord(inchar) and 127);
  end;

function exists(filename: name): boolean;

  var tempfile: text;
      found: boolean;

  begin
    assign(tempfile, filename);
    (*$I-*) reset(tempfile) (*I+*);
    found := (IOresult = 0);
    if found then close(tempfile);
    exists := found;
  end;

begin
  inputchar := 'Y';
  clrscr;
  write('Enter Name of Input text file? ');
  readln(inname);
  if exists(inname) then begin
    write('Enter Name of Output file? ');
    readln(outname);
    if exists(outname) then begin
      write('*File Exists: Overwrite (Y/N)? ');
      read(inputchar);
      writeln;
    end;
    if upcase(inputchar) = 'Y' then begin
      assign(infile, inname);
      reset(infile);
      assign(outfile, outname);
      rewrite(outfile);
      while not eof(infile) do begin
        bufpoint := 0;
        while (bufpoint < bufsize) and not eof(infile) do begin
          bufpoint := bufpoint + 1;
          read(infile, indata);
          buffer[bufpoint] := clearbit8(indata);
        end;
        if bufpoint > 0 then for outpoint := 1 to bufpoint do
          write(outfile, buffer[outpoint]);
      end;
      close(infile);
      close(outfile);
      writeln('Conversion complete.');
    end;
  end
  else writeln('Input file not found.');
end.
