EXTERNAL flptdemo :: basicops(1);

{-------------------------------------------------------------------}
{								    }
{    PROGRAM TITLE  :  EXTENDED PRECISION FLOATING POINT PACKAGE    }
{			      BASIC OPERATIONS MODULE		    }
{								    }
{    WRITTEN BY     :  LANFRANCO EMILIANI			    }
{		       MAURITS DE BRAUWWEG 11			    }
{		       2597-KD DEN HAAG				    }
{		       THE NETHERLANDS				    }
{								    }
{    INITIAL ISSUE  :  DECEMBER 1982			            }
{							            }
{    PRESENT ISSUE  :  DECEMBER 1982				    }
{								    }
{    DOCUMENTED IN  :  FILE FLPTPACK.DOC			    }
{								    }
{-------------------------------------------------------------------}

{$F-,R- to increase the speed of execution }

function absol(u : newreal) : newreal;
begin
absol.s := plus;
absol.f := u.f;
absol.e := u.e
end;

function isequal(u, v : newreal) : boolean;
var
	i	: integer;
begin
if ((u.s = plus) and (v.s = minus)) or
   ((u.s = minus) and (v.s = plus)) or
   (u.e <> v.e)
	then isequal := false 
	else
	begin
	i := 1;
	while (u.f[i] = v.f[i]) and (i < n) do i:= i + 1;
	if u.f[i] = v.f[i] then isequal := true else isequal := false
	end;
end;

function isgreater(u, v : newreal) : boolean;
var
	i	: integer;
begin
if (u.s = plus) and (v.s = minus) then isgreater := true
  else
  begin
  if (u.s = minus) and (v.s = plus) then isgreater := false
    else {like signs}
    begin
    if u.e > v.e then isgreater := true
      else
      begin
      if u.e < v.e then isgreater := false
	else {like signs and exponents}
	begin
	i := 1;
	while (u.f[i] = v.f[i]) and (i < n) do i := i + 1;
	if u.f[i] > v.f[i] then isgreater := true else isgreater := false
	end
      end
    end
  end
end;

function islower(u, v : newreal) : boolean;
begin
if isgreater(u, v) or isequal(u, v) then islower := false
else islower := true
end;

function iseqgreat(u, v : newreal) : boolean;
begin
if islower(u, v) then iseqgreat := false else iseqgreat := true
end;

function iseqlower(u, v : newreal) : boolean;
begin
if isgreater(u,v) then iseqlower := false else iseqlower := true
end;

function isinteger(u : newreal) : boolean;
{WARNING : the following listing is only valid for n <= 6}
var
	i	: integer;
begin
if ((u.e > 0) and (u.e < 129)) or (u.e > (128 + n)) then isinteger := false
  else
    begin
	i := n;
	while (u.f[i] = 0) and (i > 0) do i := i - 1;
	case u.e of
	  0  :  if i = 0 then isinteger := true else isinteger := false;
	129  :  if i = 1 then isinteger := true else isinteger := false;
	130  :  if i = 2 then isinteger := true else isinteger := false;
	131  :  if i = 3 then isinteger := true else isinteger := false;
	132  :  if i = 4 then isinteger := true else isinteger := false;
	133  :  if i = 5 then isinteger := true else isinteger := false;
	134  :  if i = 6 then isinteger := true else isinteger := false
	end {case}
    end
end;


function intadd(u, v : newinteger) : newinteger;
{called by add}
var
	carry	: 0..1;
	j	: integer;
	result  : newinteger;
	cplmt	: newinteger;
begin
carry := 0;
if u.s = v.s then	{like signs}
	begin
	intadd.s := u.s;
	for j := n downto 1 do 
		intadd.f[j] := byteadd(carry, u.f[j], v.f[j]);
	intadd.f[0] := carry
	end
else			{unlike signs}
	begin
	if u.s = plus then
		for j := n downto 1 do
			result.f[j] := bytesub(carry, u.f[j], v.f[j])
	else
		for j := n downto 1 do
			result.f[j] := bytesub(carry, v.f[j], u.f[j]);
	if carry = 0 then
		begin
		result.f[0] := carry;
		result.s := plus
		end
	else
		begin
		result.s := minus;
		carry := 0;
		for j:= n downto 1 do
			cplmt.f[j] := bytesub(carry, 0, result.f[j]);
		cplmt.f[0] := 0;
		result.f := cplmt.f
		end;
	intadd := result
	end;
end;

procedure increm (var carry : carrytyp; var u : fraction);
{called by add and by divde}
var
	i	: integer;
begin
carry := 0;
u[n] := byteadd(carry, u[n], 1);
if carry = 1 then
	begin
	for i := (n-1) downto 1 do u[i] := byteadd(carry, u[i], 0);
	if carry =1 then
		begin
		for i := (n-1) downto 1 do u[i+1] := u[i];
		u[1] := 1
		end;
	end;
end;


function add(u, v : newreal) : newreal;
var
	aux		: newreal;
	shift, exponent : integer;
	i, j		: integer;
	dummy1, dummy2, dummy3  : newinteger;
	temp		: byte;
	carry		: carrytyp;

begin
shift := u.e - v.e;
if shift < 0 then
		begin
		aux := u; u := v; v := aux; shift := -shift
		end;
if shift >= (n+2) then add := u
	else
		begin
		exponent := u.e;
		v.f[0] := 0;
		i := 0;
		while i <> shift do
			begin
			for j := n downto 1 do v.f[j] := v.f[j-1];
			i := i + 1
			end;
		dummy1.s := u.s;
		dummy1.f := u.f;
		dummy2.s := v.s;
		dummy2.f := v.f;
		dummy3 := intadd(dummy1, dummy2);
		add.s := dummy3.s;
		if dummy3.f[0] <> 0 then
			begin
			temp := dummy3.f[n];
			for j := (n-1) downto 0 do
				dummy3.f[j+1] := dummy3.f[j];
			dummy3.f[0] := 0;
			exponent := exponent + 1;
			{rounding if required}
			if (mode = rounded) and ((temp > 128) or
			  ((temp = 128) and odd(dummy3.f[n] + 1))) then
				begin
				increm(carry, dummy3.f);
				if carry = 1 then
					exponent := exponent + 1
				end;
			end
		else
			begin
			{remove leading zeros}
			i := 1;
			while (dummy3.f[1] = 0) and (i <> n) do
				begin
				for j := 1 to (n-1) do
				   dummy3.f[j] := dummy3.f[j+1];
				dummy3.f[n] := 0;
				exponent := exponent - 1;
				i := i + 1
				end;
			{the result is zero}
			if dummy3.f[1] = 0 then
				begin
				add.s := plus;
				exponent := 0
				end;
			end;
		dummy3.f[0] := 0;
		add.f := dummy3.f;
		if (exponent>=0) and (exponent<=255) then add.e:=exponent
			else
		   begin
		   if exponent < 0 then
			begin
			writeln('SUM OR DIFF EXPONENT UNDERFLOW !');
			add.s := plus;
			for i := 0 to n do add.f[i] := 0;
			add.e := 0
			end
		   else
			begin
			writeln('SUM OR DIFF EXPONENT OVERFLOW !');
			add.f[0] := 0;
			for i := 1 to n do add.f[i] := 255;
			add.e := 255
			end;
		   end;
		end;
end;

function sub(u, v : newreal) : newreal;
begin
if v.s = plus then v.s := minus else v.s := plus;
sub := add(u, v)
end;

procedure incr (var carry : carrytyp; var u : double_fraction);
{called by mult}
var
	i	: integer;
begin
carry := 0;
u[n] := byteadd(carry, u[n], 1);
if carry = 1 then
	begin
	for i := (n-1) downto 1 do u[i] := byteadd(carry, u[i], 0);
	if carry =1 then
		begin
		for i := (n-1) downto 1 do u[i+1] := u[i];
		u[1] := 1
		end;
	end;
end;


function multp(u, v : newreal) : newreal;
var
	aux		: double_fraction;
	k		: byte;
	i, j, exponent	: integer;
	carry		: carrytyp;
begin
if u.s = v.s then multp.s := plus else multp.s := minus;
exponent := u.e + v.e - 128;
for j := 0 to twicen do aux[j] := 0;
for j := n downto 1 do
	begin
	k := 0;
	for i := n downto 1 do bytemul(k, aux[i+j], u.f[i], v.f[j]);
	aux[j] := k
	end;
{remove leading zeros}
j := 1;
while (aux[1] = 0) and (j <> twicen) do
	begin
	for i := 1 to (twicen - 1) do aux[i] := aux[i+1];
	aux[twicen] := 0;
	exponent := exponent - 1;
	j := j + 1
	end;
if aux[1] = 0 then  {the result is zero}
	begin
	multp.s := plus;
	exponent := 0
	end;
{rounding if required}
if (mode = rounded) and ((aux[n+1] > 128) or
  ((aux[n+1] = 128) and odd(aux[n] + 1))) then
	begin
	incr(carry, aux);
	if carry = 1 then exponent := exponent + 1
	end;
for i := 0 to n do multp.f[i] := aux[i];
if (exponent >= 0) and (exponent <= 255) then multp.e := exponent
	else
   begin
   if exponent < 0 then
		begin
		writeln('PRODUCT EXPONENT UNDERFLOW !');
		multp.s := plus;
		for i := 0 to n do multp.f[i] := 0;
		multp.e := 0
		end
	else
		begin
		writeln('PRODUCT EXPONENT OVERFLOW !');
		multp.f[0] := 0;
		for i := 1 to n do multp.f[i] := 255;
		multp.e := 255
		end;
   end;
end;

procedure dvd(u : double_fraction; v : fraction; var q, r : fraction);
{called by divde and by modu}
var
	aa		: fraction;
	d		: 1..128;
	k, newk		: byte;
	kk		: carrytyp;
	i, j		: integer;
	t1		: real;
	qu		: byte;
begin
d := 256 div (v[1] + 1);
if d = 1 then u[0] := 0 else
	begin  {normalisation}
	k := 0;
	for i := twicen downto 1 do u[i] := byt1mul(k, u[i], d);
	u[0] := k;
	k := 0;
	for i := n downto 1 do v[i] := byt1mul(k, v[i], d);
	end;  {normalisation}
v[0] := 0;
for j := 0 to n do
	begin
	if u[j] >= v[1] then qu := 255
	else
	t1 := (u[j]*256.0 + u[j+1]) / v[1];
	if t1 < 254.5 then qu := round(t1) else qu := 255;
	while (v[1]*256.0 + v[2]*1.0)*qu >
		(u[j]*0.655360E5 + u[j+1]*256.0 + u[j+2]*1.0) do
		qu := qu - 1;
	k := 0;
	for i := n downto 1 do aa[i] := byt1mul(k, qu, v[i]);
	aa[0] := k;
	kk := 0;
	for i := n downto 0 do u[j+i] := bytesub(kk, u[j+i], aa[i]);
	q[j] := qu;
	if kk = 1 then
		begin
		q[j] := qu - 1;
		kk := 0;
		for i := n downto 0 do u[j+i] := byteadd(kk, u[j+i], v[i]);
		end;
	end;
if d = 1 then for i := 1 to n do r[i] := u[i+n]
   else
	begin
	k := 0;
	for i := 1 to n do
		begin
		byt1div(newk, r[i], k, u[i+n], d);
		k := newk
		end;
	end;
end;


function divde(u, v : newreal) : newreal;
label 999;
var
	i, j	: integer;
	exponent: integer;
	alfa	: double_fraction;
	gamma, delta : fraction;
	carry	: carrytyp;
begin
if v.f[1] = 0 then
	begin
	if u.f[1] <> 0 then
		begin
		writeln('ATTEMPTED DIVISION BY ZERO !');
		{quotient set to max positive value}
		divde.s := plus;
		divde.f[0] := 0;
		for i := 1 to n do divde.f[i] := 255;
		divde.e := 255
		end
	   else
		begin
		writeln('ATTEMPTED DIVISION OF ZERO BY ZERO !');
		{quotient set to plus one}
		divde.s := plus;
		divde.f[0] := 0;
		divde.f[1] := 1;
		for i := 2 to n do divde.f[i] := 0;
		divde.e := 129
		end;
	goto 999
	end;
if u.s = v.s then divde.s := plus else divde.s := minus;
exponent := u.e - v.e + 128;
for i := 1 to n do alfa[i] := u.f[i];
for i := (n+1) to twicen do alfa[i] := 0;
dvd(alfa, v.f, gamma, delta);
if gamma[0] <> 0 then
	begin
	for i := (n-1) downto 0 do gamma[i+1] := gamma[i];
	gamma[0] := 0;
	exponent := exponent + 1
	end
   else
	begin
	{remove leading zeros}
	i := 1;
	while (gamma[1] = 0) and (i <> n) do
		begin
		for j := 0 to (n-1) do gamma[j] := gamma[j+1];
		gamma[n] := 0;
		exponent := exponent - 1;
		i := i + 1
		end;
	if gamma[1] = 0 then {the result is zero}
		begin
		divde.s := plus;
		exponent := 0
		end;
	end;
{rounding if required}
if mode = rounded then
	begin
	{doubling the remainder}
	carry := 0;
	for i := n downto 1 do delta[i] := byt1mul(carry, delta[i], 2);
	delta[0] := carry;
	{comparing the divisor with twice the remainder}
	i := 0;
	v.f[0] := 0;
	while (v.f[i] = delta[i]) and (i < n) do i := (i+1);
	if (v.f[i]<delta[i]) or ((v.f[i]=delta[i]) and odd(gamma[n]+1))
	then
		begin
		increm(carry, gamma);
		if carry = 1 then exponent := exponent + 1
		end;
	end;
divde.f := gamma;
if (exponent >= 0) and (exponent <= 255) then divde.e := exponent
		else
	begin
	if exponent < 0 then
		begin
		writeln('QUOTIENT EXPONENT UNDERFLOW !');
		divde.s := plus;
		for i := 0 to n do divde.f[i] := 0;
		divde.e := 0
		end
	else
		begin
		writeln('QUOTIENT EXPONENT OVERFLOW !');
		divde.f[0] := 0;
		for i := 1 to n do divde.f[i] := 255;
		divde.e := 255
		end;
	end;
999 :
end;

function modu(u, v : newreal) : newreal;
label 9999;
var
	zero, aux, w		: newreal;
	i, j, k, exponent, limit: integer;
	alfa			: double_fraction;
	gamma, delta		: fraction;
begin
with zero do begin s := plus; for i := 0 to n do f[i] := 0; e := 0 end;
if (v.f[1] = 0) or (v.s = minus) then
	begin
	writeln('ATTEMPTED COMPUTING REMAINDER FOR ZERO OR NEG DIVISOR');
	writeln('	   VALUE OF MODULO SET TO ZERO');
	modu := zero
	end
  else
  begin
  if (u.f[1] = 0) or (iseqlower(absol(u), v)) then modu := zero
    else
    begin
    aux := u;
    exponent := v.e;
    {start the division and then, for (u.e - v.e) div n times,
     continue dividing after replacement of the dividend by the
     remainder of the previous division}
    limit := (u.e - v.e) div n;
    for k := 0 to limit do
	begin
	for i := 1 to n do alfa[i] := aux.f[i];
	for i := (n+1) to twicen do alfa[i] := 0;
	delta[0] := 0; {value not set within divd}
	dvd(alfa, v.f, gamma, delta);
	{remove leading zeros}
	i := 1;
	while (delta[1] = 0) and (i <> n) do
		begin
		for j := 0 to (n-1) do delta[j] := delta[j+1];
		delta[n] := 0;
		exponent := exponent - 1;
		i := i + 1
		end;
	if delta[1] = 0 then {the result is zero}
		begin
		modu := zero;
		goto 9999
		end;
	aux.f := delta;
	if exponent >= 0 then aux.e := exponent 
		else 
		begin
		writeln('MODULO EXPONENT UNDERFLOW !');
		modu := zero;
		goto 9999
		end;
	end;
    limit := (u.e - v.e) mod n;
    aux.e := aux.e + limit;
    {as long as the remainder exceeds the divisor keep subtracting
     the divisor from it}
    aux := absol(aux); {to speed up the steps which follow}
    w := v;
    w.e := w.e + limit - 1;
    repeat
    while isgreater(aux, w) do aux := sub(aux, w);
    if w.e > 0 then w.e := w.e - 1;
    limit := limit - 1;
    until limit = - 1;
    aux.s := u.s;      {to set the correct sign again}
    modu := aux
    end
  end;
9999:
end;


function putnreal(inp : extdatum) : newreal;
{called by do_read}
var
	carry	: digits;
	i, j, k	: integer;
	t	: integer;
	u	: array[1..3] of digits;
	v	: array[1..nn] of digits;
	w	: array[1..(nn+3)] of digits;
	ten, one, pointone, aaa, auxiliary		: newreal;

begin
for j := 1 to nn  do v[j] := inp.f[j];
u[1] := 2; u[2] := 5; u[3] := 6;
aaa.s := inp.s;
aaa.f[0] := 0;
for i := 1 to n do
	begin
	{multiplication}
	for j := 1 to (nn+3) do w[j] := 0;
	for j := nn downto 1 do
		begin
		carry := 0;
		for k := 3 downto 1 do
			begin
			t := u[k]*v[j] + w[k+j] + carry;
			w[k+j] := t mod 10;
			carry := t div 10
			end;
		w[j] := carry
		end;
	{getting the byte}
	aaa.f[i] := w[1]*100 + w[2]*10 + w[3];
	{left shift}
	for j := 1 to 3 do
		begin
		for k := 1 to (nn+2) do w[k] := w[k+1];
		w[nn] := 0
		end;
	{re-assignment}
	for j := 1 to nn do v[j] := w[j]
	end;
aaa.e := 128;
{finalizing the transformation}
if inp.e = 0 then
{apart from normalisation putnreal can be set equal to aaa}
   begin
   {remove leading zeros}
   {this would not be necessary if the calling procedure is do_read}
   j := 1;
   while (aaa.f[1] = 0) and (j <> n) do
	begin
	for i := 1 to (n - 1) do aaa.f[i] := aaa.f[i + 1];
	aaa.f[n] := 0;
	aaa.e := aaa.e - 1;
	j := j + 1
	end;
   {the result is zero}
   if aaa.f[1] = 0 then
	begin
	aaa.s := plus;
	aaa.e := 0
	end;
   putnreal := aaa
   end
	else
		begin
		with one do
			begin
			s := plus; f[0] := 0; f[1] := 1;
			for i := 2 to n do f[i] := 0;
			e := 129 end;
		auxiliary := one;
		if inp.e > 0 then
			begin
			with ten do
				begin
				s := plus; f[0] := 0; f[1] := 10;
				for i := 2 to n do f[i] := 0;
				e := 129 end;
			for i := 1 to inp.e do
			auxiliary := multp(auxiliary, ten)
			end
		   else {exponent < 0}
			begin
			with pointone do 
				begin
				s := plus; f[0] := 0; f[1] := 25;
				for i := 2 to n do f[i] := 153;
				if mode = rounded then f[n] := 154;
				e := 128 end;
			for i := inp.e to -1 do
			auxiliary := multp(auxiliary, pointone);
			end;
		putnreal := multp(aaa, auxiliary)
		end;
end;


procedure do_read(var u : extdatum; var v : newreal);
const
	z		= 48;    {ord('0')}
var
	ch		: char;
	exposign	: signtype;
	i, j		: integer;
	temp, exponent	: integer;
begin
read(ch);
{skipping leading blanks}
while ch = ' ' do read(ch);
if ch = '-' then
	begin
	u.s := minus;
	read(ch)
	end
  else
	begin
	u.s := plus;
	if ch = '+' then read(ch)
	end;
while not (ch in ['0'..'9']) do
  begin
  writeln('INPUT STRING NOT FOUND : PLEASE TRY AGAIN.');
  read(ch)
  end;
{getting the fraction}
exponent := 0;
u.f[0] := 0;
i := 1;
{skipping leading zeros}
while ch = '0' do read(ch);
while (ch in ['0'..'9']) and (i <= prec) do
	begin
	u.f[i] := ord(ch) - z;
	exponent := exponent + 1;
	i := i + 1;
	read(ch)
	end;
if ch = '.' then
	begin
	read(ch);
	{skipping further non significant digits}
	if exponent = 0 then
		begin
		while ch = '0' do
			begin
			read(ch);
			exponent := exponent - 1
			end
		end;
	while (ch in ['0'..'9']) and (i <= prec) do
		begin
		u.f[i] := ord(ch) - z;
		i := i + 1;
		read(ch)
		end
	end;
for j := i to nn do u.f[j] := 0;
if (ch in ['0'..'9']) then writeln(
  'INPUT STRING TOO LONG : DIGITS BEYOND THE ',prec:1,'TH DIGIT ARE IGNORED');
writeln('
  INPUT STRING CONSISTS OF A ',u.s:1,' SIGN AND ',(i-1):1,' DIGIT(S).');
{skipping further digits}
while (ch in ['0'..'9']) do read(ch);
if (ch = 'E') or (ch = 'e') then
	begin
	read(ch);
	temp := 0;
	if ch = '-' then
		begin
		exposign := minus;
		read(ch)
		end
	  else
		begin
		exposign := plus;
		if ch = '+' then read(ch)
		end;
	while not (ch in ['0'..'9']) do
		begin
		writeln('EXPONENT NOT FOUND : PLEASE TRY AGAIN.');
		read(ch)
		end;
	temp := ord(ch) - z;
	i := 1;
	read(ch);
	while (ch in ['0'..'9']) and (i < 3) do
		begin
		temp := 10*temp + ord(ch) - z;
		i := i + 1;
		read(ch)
		end;
	if (ch in ['0'..'9']) then 
	writeln('
	EXPONENT STRING TOO LONG : DIGITS BEYOND THE 3RD ARE IGNORED.');
	writeln('
	EXPONENT CONSISTS OF A ',exposign:1,' SIGN AND ', i:1, ' DIGIT(S).');
	{skipping further digits}
	while (ch in ['0'..'9']) do read(ch);
	if exposign = minus then exponent := exponent - temp
	else exponent := exponent + temp
	end;
u.e := exponent;
v := putnreal(u)
end;


procedure inc(i : integer; var u : long_fraction);
{called by auxmult}
begin
if u[i] <> 9 then u[i] := u[i] + 1
    else
	begin
	u[i] := 0;
	inc(i-1, u)
	end;
end;


function auxmult(u, v : extdatum) : extdatum;
{called by getnreal}
var
	aux		: long_fraction;
	k		: digits;
	t		: 0..maxint;
	i, j, exponent	: integer;
begin
if u.s = v.s then auxmult.s := plus else auxmult.s := minus;
exponent := u.e + v.e;
for j := 1 to twicenn do aux[j] := 0;
for j := nn downto 1 do
	begin
	k := 0;
	for i := nn downto 1 do
		begin
		t := u.f[i]*v.f[j] + aux[i+j] + k;
		aux[i+j] := t mod 10;
		k := t div 10
		end;
	aux[j] := k;
	end;
{remove leading zeros}
j := 1;
while (aux[1] = 0) and (j <> twicenn) do
	begin
	for i := 0 to (twicenn - 1) do aux[i] := aux[i+1];
	aux[twicenn] := 0;
	exponent := exponent - 1;
	j := j + 1
	end;
{rounding if required}
if (mode = rounded) and (aux[nn+1] > 5) then
	begin
	inc(nn, aux);
	if aux[0] <> 0 then
		begin
		for j := (twicenn - 1) downto 0 do aux[j+1] := aux[j];
		aux[0] := 0;
		exponent := exponent + 1
		end;
	end;
auxmult.f[0] :=0;
for i := 1 to nn do auxmult.f[i] := aux[i];
auxmult.e := exponent;
end;


function getnreal(inp : newreal) : extdatum;
{WARNING : the following listing is only valid for n <= 6}
{called by do_write}
var
	carry	: digits;
	i, j, k	: integer;
	t, shift, exponent	: integer;
	u 	: array[1..3] of digits;
	v, aa, bb, cc, dd, ee, ff	: array[1..nn] of digits;
	w, aaa, bbb	: array[0..(nn+3)] of digits;
	ccc, auxiliary, twohun56, one, oneover256 : extdatum;
begin
{(1/256)*10^2}
	aa[1]:=3;	aa[2]:=9;	aa[3]:=0;	aa[4]:=6;
	aa[5]:=2;	aa[6]:=5;
	for i := 7 to nn do aa[i] := 0;
{(1/256^2)*10^4}
	bb[1]:=1;	bb[2]:=5;	bb[3]:=2;	bb[4]:=5;
	bb[5]:=8;	bb[6]:=7;	bb[7]:=8;	bb[8]:=9;
	bb[9]:=0;	bb[10]:=6;	bb[11]:=2;	bb[12]:=5;
	for i := 13 to nn do bb[i] := 0;
{(1/256^3)*10^7}
	cc[1]:=5;	cc[2]:=9;	cc[3]:=6;	cc[4]:=0;
	cc[5]:=4;	cc[6]:=6;	cc[7]:=4;	cc[8]:=4;
	cc[9]:=7;	cc[10]:=7;	cc[11]:=5;	cc[12]:=3;
	cc[13]:=9;	
	if mode=rounded then cc[14]:=1 else cc[14]:=0;
{(1/256^4)*10^9}
	dd[1]:=2;	dd[2]:=3;	dd[3]:=2;	dd[4]:=8;
	dd[5]:=3;	dd[6]:=0;	dd[7]:=6;	dd[8]:=4;
	dd[9]:=3;	dd[10]:=6;	dd[11]:=5;	dd[12]:=3;
	dd[13]:=8;
	if mode=rounded then dd[14]:=7 else dd[14]:=6;
{(1/256^5)*10^12}
	ee[1]:=9;	ee[2]:=0;	ee[3]:=9;	ee[4]:=4;
	ee[5]:=9;	ee[6]:=4;	ee[7]:=7;	ee[8]:=0;
	ee[9]:=1;	ee[10]:=7;	ee[11]:=7;	ee[12]:=2;
	ee[13]:=9;
	if mode=rounded then ee[14]:=3 else ee[14]:=2;
{(1/245^6)*10^14}
	ff[1]:=3;	ff[2]:=5;	ff[3]:=5;	ff[4]:=2;
	ff[5]:=7;	ff[6]:=1;	ff[7]:=3;	ff[8]:=6;
	ff[9]:=7;	ff[10]:=8;	ff[11]:=8;	ff[12]:=0;
	ff[13]:=0;	ff[14]:=5;
for i := 0 to (nn+3) do bbb[i] := 0;
aaa[0] := 0;
for i := 1 to n do
	begin
	u[1] := inp.f[i] div 100;
	u[2] := (inp.f[i] mod 100) div 10;
	u[3] := (inp.f[i] mod 100) mod 10;
	case i of
		1 : begin v := aa; shift := 0 end;
		2 : begin v := bb; shift := 2 end;
		3 : begin v := cc; shift := 5 end;
		4 : begin v := dd; shift := 7 end;
		5 : begin v := ee; shift := 10 end;
		6 : begin v := ff; shift := 12 end;
	end; {case}
	{multiplication}
	for j := 1 to (nn+3) do w[j] := 0;
	for j := nn downto 1 do
		begin
		carry := 0;
		for k := 3 downto 1 do
			begin
			t := u[k]*v[j]+w[k+j]+carry;
			w[k+j] := t mod 10;
			carry := t div 10
			end;
		w[j] := carry
		end;
	{shift to the right}
	for j := 1 to shift do
		begin
		for k := nn+2 downto 1 do w[k+1] := w[k];
		w[1] := 0
		end;
	{addition}
	carry := 0;
	for j := nn+3 downto 1 do 
		begin
		aaa[j] := (bbb[j] + w[j] + carry) mod 10;
		carry := (bbb[j] + w[j] + carry) div 10
		end;
	aaa[0] := carry + aaa[0];  {WARNING : valid only for n <= 9}
	bbb := aaa
	end;
exponent := 1;
{conditional shift to the right}
if aaa[0] <> 0 then
	begin
	for k := nn+2 downto 0 do aaa[k+1] := aaa[k];
	aaa[0] := 0;
	exponent := exponent + 1
	end
   else
	begin
	{remove leading zeros}
	j := 1;
	while (aaa[1] = 0) and (j <> nn+3) do
		begin
		for i := 1 to nn+2 do aaa[i] := aaa[i+1];
		aaa[nn+3] := 0;
		exponent := exponent - 1;
		j := j + 1
		end;
	end;
ccc.s := inp.s;
for i := 0 to nn do ccc.f[i] := aaa[i];
ccc.e := exponent;
{the result is zero}
if ccc.f[1] = 0 then
	begin
	ccc.s := plus;
	ccc.e := 1	{to display an exponent of zero equal to 0}
	end;
if (inp.e = 128) or (ccc.f[1] = 0) then getnreal := ccc
	else
		begin
		one.s := plus;
		one.f[0] := 0;
		one.f[1] := 1;
		for i := 2 to nn do one.f[i] := 0;
		one.e := 1;
		auxiliary := one;
		if inp.e > 128 then 
			begin
			twohun56.s := plus;
			twohun56.f[0] := 0;
			twohun56.f[1] := 2;
			twohun56.f[2] := 5;
			twohun56.f[3] := 6;
			for i := 4 to nn do twohun56.f[i] := 0;
			twohun56.e := 3;
			for i := 129 to inp.e do
			   auxiliary := auxmult(auxiliary, twohun56)
			end
		   else  {exponent < 128}
			begin
			with oneover256 do
				begin s := plus; f[0] := 0; f[1] := 3;
				f[2] := 9; f[3] := 0; f[4] := 6; f[5] := 2;
				f[6] := 5;
				for j := 7 to nn do f[j] := 0;
				e := -2 end;
			for i := inp.e to 127 do
				auxiliary := auxmult(auxiliary, oneover256);
			end;
		getnreal := auxmult(ccc, auxiliary)
		end;
end;

procedure do_write(u : newreal);
var
	aux : extdatum;
	i   : integer;
begin
aux := getnreal(u);
if aux.s = plus then write('+') else write('-');
write(aux.f[1]:1, '.');
for i := 2 to prec do write(aux.f[i]:1);
write('E');
if (aux.e - 1) < 0 then write('-') else write('+');
if abs(aux.e - 1) < 10 then write('0');
write(abs(aux.e - 1):1)
end;

{$F+,R+ }
. {end of the module basicops}
