(*
In CP/M-80, the Turbo Pascal "filesize(filvar)" function will return the
number of records in the named file.  Each record consumes 128 bytes.  So,
the Kilobyte size is calculated by:  RECS x 128.  When the file is saved
in CP/M, file space is allocated in increments of 2K bytes.  The following
example will calculate the K's.
*)
program find_k;
type
   filename = string[12];
var
   fname : filename;
   kfile : file;
   remain : boolean;
   i,recs,k,bytes : integer;
begin
   write('Enter the filename: ');
   readln(fname);
   for i:=1 to length(fname) do
      fname[i]:=upcase(fname[i]);
   assign(kfile,fname);
   reset(kfile);
   recs:=filesize(kfile);
   close(kfile);
   bytes:=recs*128;          { how many 128 byte records }
   k:=bytes div 1024;          { get the nearest k. oKay? }
   remain:=(bytes mod 1024)<>0;          { do I need another k? }
   if remain then k:=k+1;
   if (k=0) or odd(k) then k:=k+1;     { add another k for CP/M filesaves }
   writeln('That file is ',k,'K long')
end.

