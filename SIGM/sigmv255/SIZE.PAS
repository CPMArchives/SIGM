program size;
(*--------------------------------------*)
(*					*)
(*	Get Program Size		*)
(*	  Public Domain Soft  JUG-CP/M  *)
(*		83-1-3	by K.Maeda	*)
(*		84-10-16  revised	*)
(*--------------------------------------*)

type
  head  =  record
		group_type :  byte;
		group_leng :  integer;
		base_value :  integer;
		group_min  :  integer;
		group_max  :  integer
	   end;

  buffer = array[0..127] of byte;

  pstrg  = ^string;

var
  sec_data : buffer;
  leng_seg : integer;
  parm_pt  : pstrg;
  f_name   : string;
  f_get    : file;
  result   : integer;
  sec_pt   : ^head;
  rep_flg  : boolean;

external function @cmd : pstrg;

procedure get_fn;
begin
  writeln;
  write('File Name  (if End, CR-only) : ');
  readln(f_name)
end;

procedure hex(x:byte);
var
  mh,ml : integer;
  ch,cl : char;
begin
  mh:=x div 16;  ml:=x mod 16;
  if mh > 9 then ch:=chr(mh+55) else ch:=chr(mh+48);
  if ml > 9 then cl:=chr(ml+55) else cl:=chr(ml+48);
  write(ch,cl)
end;


procedure size_print;
var
  group_message : string;
  itype , i     : integer;
begin
  writeln;
  writeln;
  writeln('+++++  Header Record of File  -  ',f_name,'  +++++');

  blockread(f_get,sec_data,result,128,0);
  i:=0;
  sec_pt:=addr(sec_data[i]);
  itype:=sec_pt^.group_type;

  while itype > 0 do begin
	case itype of
	  1 : group_message:='Code Segment';
	  2 : group_message:='Data Segment';
	  3 : group_message:='Extra Segment';
	  4 : group_message:='Stack Segment';
	  else group_message:=concat('Others #',chr(itype+48));
	end;

	leng_seg:=(sec_pt^.group_min + 32)  div  64;

	writeln;
	writeln(group_message);
	write('   base address : ');
	hex(hi(sec_pt^.base_value)); hex(lo(sec_pt^.base_value));
	writeln;
	writeln('   min size (KB): ',leng_seg:4);
	i:=i+9;  if i>127 then exit;
	sec_pt:=addr(sec_data[i]);
	itype:=sec_pt^.group_type;
  end; { while }
end;



(*----- Main Procedure -----*)

begin
  parm_pt  := @cmd;			{ get command parameter }
  f_name   := parm_pt^;

  if (f_name='') or (f_name=' ')
   then begin
	rep_flg := false;
	get_fn;
	if length(f_name) = 0		then exit;
   end
  else rep_flg := true;

  repeat
	assign(f_get,f_name);
	reset( f_get );
	if ioresult <> 255 then size_print
			   else writeln('Cannot Open.');
	close( f_get,result );

	if not rep_flg then get_fn;
  until (length(f_name) = 0) or rep_flg
end.
