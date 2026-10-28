program profile;
{$E-,C-,T-
  Read the file A:PROFILER.DAT created by a run of
  a program with execution-profiling set on.  Format
  the data and write A:PROFILER.PRN, a histogram.

  The input file consists of a number of 16-bit integers
  in Pascal/Z format, i.e. BACKWARDS to the usual Intel,
  CP/M, etc way of storing an integer, with the most
  significant byte first.

  The first integer is the count of statements profiled.
  It may be zero -- if the T+ option was not on -- or it
  may be greater than "maxstmt," especially if the file
  is garbage.

  The second integer is the statement number of the first
  statement profiled (traced), and the third is the number
  of the last statement.

  Then follows the array of statement-count integers.
}
const
    maxstmt = 4000; { max number of statements allowed }

type
    inum = record   { binary integer in file }
	    val : integer
	end;
    s_range = 1..maxstmt;

var
    inf : file of inum;
    ouf : text;
    inname,
    otname  : array[1..14] of char;
    data    : array[s_range] of real;
    idata   : array[s_range] of integer;
    lostmt,
    histmt,
    nstmt   : s_range;
    sumexec : real;
    n : integer;
{
    read the next integer from the file
}
function iread : integer;
    var i : inum;
    begin
	if not eof(inf) then begin
	    read(inf,i);
	    iread := i.val
	    end
	else begin
	    writeln('I boobed and read past EOF');
	    iread := 0
	    end
    end;
{
    read an integer -- which might be over 32767 and
    hence "negative" -- and convert to real.
}
function fread : real;
    var r : real;
    begin
	r := iread; {implicit conversion to float}
	if r<0 then r := r+65536.0;
	fread := r
    end;
{
    read all the statement counts and convert to float.
    sum all statement counts for scaling purposes.
}
procedure readem;
    var i : s_range; r : real;
    begin
	sumexec := 0.0;
	for i := 1 to nstmt do begin
	    r := fread;
	    sumexec := sumexec+r;
	    data[i] := r
	    end
    end;
{
    Scale the data so that each point is on a scale of
    0..50, a two-percent fraction of the total count of
    all statements executed.
}
procedure scalem;
    var i : s_range; r : real;
    begin
	for i := 1 to nstmt do begin
	    r := 100.0 * ( data[i]/sumexec );
	    idata[i] := round(r) div 2
	    end
    end;
{
    Print the scaled data, one line per profiled
    statement, formatted so:

SSSS  NNNNN|*********					      |

    where SSSS is the statement number, NNNNN is the raw count,
    and there are from 0 to 50 stars, as per the scaled data.
}
procedure printem;
    var i,s : s_range;
	aster : integer;
	j : 1..50; stars : array[1..50] of char;
    begin
	rewrite(otname,ouf);
	s := lostmt;
	for i := 1 to nstmt do begin
	    write(ouf,s:4, data[i]:7:0,'|');
	    aster := idata[i];
	    for j := 1 to 50 do
		if j<=aster then stars[j]:='*'
		else		 stars[j]:=' ';
	    write(ouf,stars);
	    writeln(ouf,'|');
	    s := s+1
	end
    end;
{
    main routine
}
begin
    inname := 'A:PROFILER.DAT';
    otname := 'A:PROFILER.PRN';
    reset(inname,inf);
    if not eof(inf) then begin { file exists }
	n := iread;
	if n<=maxstmt then begin { ..and is probably valid }
	    nstmt := n;
	    lostmt := iread;
	    histmt := iread;
	    if nstmt>0 then begin { ..and has data in it }
		readem;
		scalem;
		printem
		end
	    else
		writeln('No statements traced in ',inname)
	    end
	else
	    writeln('Too many statements traced -- ',n)
	end
    else
	writeln(inname,' not found or empty')
end.
   end
	else
	    writeln('Too many statements trace