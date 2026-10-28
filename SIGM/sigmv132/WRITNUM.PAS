          {Modified from Z/PUG Vol. 16 by John A. McCulloch}
{	This was part of a Pascal Course, as program listing #5 of Welsh &}  
{Elder, Page 101. It has been modified from the listing in Volume 16 as   }
{formatted by Gerald Hewett. Furthur changes may be made to expand the    }
{range of amounts handled. As set up it will handle amounts to $9,999.99. }
{	Addition of the fixed point package, or conversion of numerical   }
{data to strings will allow this to work within a computational package.  }

Program Writnum;


Var
	     k,h,t,u : char;
             i,ct,cu : char;
	      amount : array [1..7] of char;
		   x : integer;

Procedure units (i : char);
	Begin
		Case i of
			'0' : write( 'NO ');
			'1' : write( 'One ');
			'2' : write( 'Two ');
			'3' : write( 'Three ');
			'4' : write( 'Four ');
			'5' : write( 'Five ');
			'6' : write( 'Six ');
			'7' : write( 'Seven ');
			'8' : write( 'Eight ');
			'9' : write( 'Nine ');
		end;
	end;		{units}

Procedure teens (i : char);
	Begin	
		Case i of
			'0' : write( 'Ten ');
			'1' : write( 'Eleven ');
			'2' : write( 'Twelve ');
			'3' : write( 'Thirteen ');
			'4' : write( 'Fourteen ');
			'5' : write( 'Fifteen ');
			'6' : write( 'Sixteen ');
			'7' : write( 'Seventeen ');
			'8' : write( 'Eighteen ');
			'9' : write( 'Nineteen ');
		end;
	end;		{teens}

Procedure tens (i : char);
	Begin
		Case i of
			'0' : ;
			'2' : write( 'Twenty');
			'3' : write( 'Thirty');
			'4' : write( 'Forty');
			'5' : write( 'Fifty');
			'6' : write( 'Sixty');
			'7' : write( 'Seventy');
			'8' : write( 'Eighty');
			'9' : write( 'Ninety');
		end;
		if (u > '0') and (t > '1') then write( '-')
			else write( ' ');
	end;		{tens}

Procedure convert;
	Begin
	x := 0;
	u := '0';
	t := '0';
	h := '0';
	k := '0';
	If amount <> '       ' then Repeat
		x := x + 1;
	Until (amount[x] = '.') or (x = 7);
	if (x-1) > 0 then u := amount[x-1];
	if (x-2) > 0 then t := amount[x-2];
	if (x-3) > 0 then h := amount[x-3];
	if (x-4) > 0 then k := amount[x-4];
	ct := amount[x+1];
	cu := amount[x+2];
	end; 		{convert}

Procedure listout;
	Begin
	if k > '0' then Begin
		units(k);
		write( 'Thousand ');
		end;
 	if h > '0' then Begin
		units(h);
		write( 'Hundred ');
		end;
	if t = '1' then teens(u)
		else begin
			tens(t);
			units(u);
			end;
	end;		{convert}

begin
	Writeln; Writeln;
	Repeat
		Write( 'Enter amount to be written out....$');
		Readln( amount);
		if amount <> '       ' then Begin
			convert;
			listout;
			writeln( 'Dollars and ', ct:1, cu:1, ' cents.');
			end;
		Writeln; Writeln;
	Until amount = '       ';
end.
