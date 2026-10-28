Program Sub; (* revision 8/8/82 - L. Farwell *)
	     (* CP/M File Menu Program *)
type
  string0 = string 0;
  string255  = string 255;
  string128 = string 128;
  scope = 0..7;
  xsub = array[scope] of string128;

var
  asub : xsub;
  command : char;
  drive,		
  drive1,
  drive2,
  name,
  new,
  old : string128;
  count : scope;

function length(source : string255) : integer; external;

procedure submit(asub : xsub; last : scope);

const
  max = 128;

type
  line = string128;

var
  idx : integer;
  fsub : file of line;
  
  procedure put_sub(inbuffer : line);

  var 
    tbuffer : line;
    
  begin (* put_sub *)
    tbuffer := ' ';
    tbuffer[1] := chr(length(inbuffer));
    append(tbuffer, inbuffer);
    repeat
      append(tbuffer, chr(0)); (* pad to end of buffer *)
    until length(tbuffer) = max;
    write(fsub, tbuffer)
  end; (* put_sub*)

begin (* submit *)
  rewrite('$$$.SUB', fsub);
  for idx := last downto 0 do	(* last MUST be even *)
    put_sub(asub[idx]); 							end; (* submit *)

begin (* sub *)
    count := 1;     (* normal end of command buffer *)
    asub[1] := 'SUB';
    writeln('          ----------------------------------------------');
    writeln('          -           CP/M FILE SYSTEM MENU            -');
    writeln('          -                                            -');
    writeln('          - Choose function:                           -');
    writeln('          -                                            -');
    writeln('          -  A) CHECK available disk space             -');
    writeln('          -  B) CHECK disk space used by one file      -');
    writeln('          -  C) LIST command files                     -');
    writeln('          -  D) LIST disk directory                    -');
    writeln('          -  E) ERASE a file                           _');
    writeln('          -  F) ERASE all backup files on a disk       -');
    writeln('          -  G) RENAME a file                          -');
    writeln('          -  H) TRANSFER one file to another disk      -');
    writeln('          -  I) TRANSFER all files to another disk     -');
    writeln('          -  J) FORMAT a disk in B drive               -');
    writeln('          -  K) COPY CP/M to a disk in B drive         -');
    writeln('          -  L) INITIALIZE a new disk in B drive       -');
    writeln('          -  M) COPY system files to disk in B drive   -');
    writeln('          -                                            -');
    writeln('          -  Q) QUIT menu and return to CP/M           -');
    writeln('          -                                            -');
    writeln('          ----------------------------------------------');
    writeln;
    write('           --> ');
    readln(command);
    case command of
      'a', 'A' : begin 
		   count := 3;
		   asub[count] := ' ';
		   asub[2] := 'SUB';
		   asub[1] := 'HOLD';		   
		   writeln;
		   write('       Status of drive A or drive B : ');
		   readln(drive);
		   asub[0] := 'STAT ';
		   append(asub[0], drive);
		   append(asub[0], ':');				       
		 end; (* 'a', 'A' *);
      'b', 'B' : begin		     
		   count := 3;
		   asub[count] := ' ';
		   asub[2] := 'SUB';
		   asub[1] := 'HOLD';		   
		   writeln;
		   write('            File is on drive A or drive B : ');
		   readln(drive);
		   write('            File name is <filename.type> : ');
		   readln(name);					       
		   asub[0] := 'STAT ';
		   append(asub[0], drive);
		   append(asub[0], ':');
		   append(asub[0], name);				       
		 end; (* 'b', 'B' *)					       
      'c', 'C' : begin
		   count := 3;
		   asub[count] := ' ';
		   asub[2] := 'SUB';
		   asub[1] := 'HOLD';		   
		   writeln;
		   write('Command files on drive A or drive B : ');
		   readln(drive);
		   asub[0] := 'DIR ';  
		   append(asub[0], drive);
		   append(asub[0], ':*.COM');
		 end; (* 'c', 'D' *)
     'd', 'D' : begin
		   count := 3;
		   asub[count] := ' ';
		   asub[2] := 'SUB';
		   asub[1] := 'HOLD';
		   writeln;
		   write('   Directory for drive A or drive B : ');
		   readln(drive);
		   asub[0] := 'DIR ';  
		   append(asub[0], drive);
		   append(asub[0], ':');		    
		end; (* 'd', 'D' *)
      'e', 'E' : begin
		   writeln;
		   write('            File is on drive A or drive B : ');
		   readln(drive);
		   write('            File name is <filename.type> : ');
		   readln(name);					       
		   asub[0] := 'ERA ';
		   append(asub[0], drive);
		   append(asub[0], ':');
		   append(asub[0], name);				       
		 end; (* 'e', 'E' *)					       
      'f', 'F' : begin
		   write('            File is on drive A or drive B : ');
		   readln(drive);
		   asub[0] := 'ERA ';
		   append(asub[0], drive);
		   append(asub[0], ':*.bak');
		  end; (* 'f', 'F' *)
      'g', 'G' : begin
		   writeln;
		   write('            File is on drive A or drive B : ');
		   readln(drive);
		   write('            Old file name is <filename.type> : ');
		   readln(old);
		   write('            New file name is <filename.type> : ');
		   readln(new);
		   asub[0] := 'REN ';
		   append(asub[0], drive);
		   append(asub[0], ':');
		   append(asub[0], new);
		   append(asub[0], '=');
		   append(asub[0], drive);
		   append(asub[0], ':');
		   append(asub[0], old);
		 end; (* 'g', 'G' *)					      
      'h', 'H' : begin
		   writeln;
		   write('            Transfer from drive : ');
		   readln(drive1);
		   write('            Transfer to drive : ');
		   readln(drive2);
		   write('            File name is <filename.type> : ');
		   readln(name);
		   asub[0] := 'PIP ';
		   append(asub[0], drive2);
		   append(asub[0], ':=');
		   append(asub[0], drive1);
		   append(asub[0], ':');
		   append(asub[0], name);
		 end; (* 'h', 'H' *)						   'i', 'I' : begin
		   writeln;
		   write('            Transfer ALL files from drive : ');
		   readln(drive1);
		   write('            Transfer to drive : ');
		   readln(drive2);
		   asub[0] := 'PIP ';
		   append(asub[0], drive2);
		   append(asub[0], ':=');
		   append(asub[0], drive1);
		   append(asub[0], ':*.*');
		 end; (* 'i', 'I' *)					       
      'j', 'J' : begin
		   writeln;
		   asub[0] := 'FORMAT';
		 end; (* 'j', 'J' *)					      
      'k', 'K' : begin
		   writeln;
		   writeln('To copy CP/M to formated disk in drive B:');
		   writeln('enter A as source and B as destination.');
		   writeln('Press RETURN key when function is complete.');
		   writeln;
		   asub[0] := 'SYSGEN';
		 end; (* 'k', 'K' *)					      
      'l', 'L' : begin
		   writeln;
		   count := 3;
		   asub[count] := ' ';
		   asub[2] := 'SUB';
		   asub[1] := 'SYSGEN';
		   asub[0] := 'FORMAT';
		 end; (* 'l', 'L' *)
      'm', 'M' : begin
		   writeln;
		   count := 7;
		   asub[7] := 'SUB';
		   asub[6] := 'PIP B:=HOLD.COM'; 
		   asub[5] := 'PIP B:=SYSGEN.COM';
		   asub[4] := 'PIP B:=SUB.COM';
		   asub[3] := 'PIP B:=PIP.COM';
		   asub[2] := 'PIP B:=FORMAT.COM';
		   asub[1] := 'PIP B:=STAT.COM';
		   asub[0] := 'PIP B:=SUBMIT.COM';
		 end; (* 'm', 'M' *)
    end; (* cases *)
  if not (command in ['q', 'Q']) then
    submit(asub, count);
end. (* sub *)
		 end; (* 'm', 'M' *)
    end; (* cases *)
  if not (co