program demo;
{$c-,m-,e-,f-}

{Program to demonstrate how the use of bit manipulation can reduce
 data storage requirements.  In this case, instead of requiring 8
 bytes --one for each boolean variable-- a single byte is used.}

type
xxtest = (glucose,sodium, potassium, bun, chloride, hemoglobin,
        hematocrit, wbc);

byte = 0..255;

var
xtest:array [0..7] of xxtest;
done:boolean;
i,test_ordered,ordered:byte;

{these two procedures contained in BITBANG.SRC/REL}
procedure bset(var x:byte; y:byte);external;
function test (x:byte; y:byte):boolean; external;

begin {of main program}

xtest[0]:=glucose;
xtest[1]:=sodium;
xtest[2]:=potassium;
xtest[3]:=bun;
xtest[4]:=chloride;
xtest[5]:=hemoglobin;
xtest[6]:=hematocrit;
xtest[7]:=wbc;

writeln ('Available tests include: ');
for i:= 0 to 7 do
	writeln (i:2,': ',xtest[i]:10);
writeln ('8':2,': ','no additional test');

test_ordered:= 0;  {initialize byte to 00000000, i.e. no test ordered}


done:=false;
while not done do
begin
write('Enter number for test ordered: ');
readln(ordered);
if ordered < 8 then bset(test_ordered,ordered)
	else done:=true;  {if ordered, set bit to 1}
end;

for i := 0 to 7 do
	if test(test_ordered,i) then writeln (xtest[i]:15);

end.
