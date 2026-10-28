Program FLPTDEMO(0);
{$IFLPTCONS.PAS  }
{$IFLPTTYPE.PAS  }
{$IFLPTVAR.PAS   }
	i		: integer;
	alfa, beta	: extdatum;
	k, l, a, b, c, d: newreal;
	continue	: boolean;
	ch		: char;
{$IFLPTEXT.PAS   }

begin
{insert here clear screen}
mode := rounded;
writeln('          EXTENDED PRECISION FLOATING POINT PACKAGE');
writeln('		       DEMONSTRATION PROGRAM');
writeln;
writeln;
writeln('Enter the first operand by typing a string of consecutive digits');
writeln(
'(up to but no more than ',prec:1,' ) optionally preceeded by either "+" or');
writeln('"-" and followed by "E" or "e" and then by the exponent. ');
writeln('The number may contain a decimal point as in any standard Pascal');
writeln('implementation. Leading zeros are discarded.');
writeln('Note that :');
writeln('   the absence of sign results in a positive number;');
writeln('   the exponent should consist of a signed or unsigned number');
writeln('   with one, two or three digits.');
writeln('After any operand has been composed, type twice return to indicate');
writeln('completion.');
writeln;
continue := true;
repeat
writeln('Enter the first operand.');
do_read(alfa, k);
writeln;
writeln('Enter the second operand.');
writeln;
do_read(beta, l);
writeln;
writeln;
write('The first operand is equal to  : ');
if alfa.s = plus then write('+') else write('-');
write(alfa.f[1]:1, '.');
for i := 2 to prec do write(alfa.f[i]:1);
if alfa.f[1] <> 0 then
	begin
	write('E');
	if (alfa.e-1) < 0 then write('-') else write('+');
	if abs(alfa.e-1) < 10 then write('0');
	writeln(abs(alfa.e-1):1)
	end
  else
	writeln('+00');
writeln;
write('The second operand is equal to : ');
if beta.s = plus then write('+') else write('-');
write(beta.f[1]:1, '.');
for i := 2 to prec do write(beta.f[i]:1);
if beta.f[1] <> 0 then
	begin
	write('E');
	if (beta.e-1) < 0 then write('-') else write('+');
	if abs(beta.e-1) < 10 then write('0');
	writeln(abs(beta.e-1):1)
	end
  else
	writeln('+00');
writeln;
a := add(k, l);
b := sub(k, l);
c := multp(k, l);
d := divde(k, l);
write('The sum of the first and the second operand is :        ');
do_write(a);
writeln;
writeln;
write('The difference of the first and the second operand is : ');
do_write(b);
writeln;
writeln;
write('The product of the first and the second operand is :    ');
do_write(c);
writeln;
writeln;
write('The quotient of the first and the second operand is :   ');
do_write(d);
writeln;
writeln;
writeln;
writeln('Type "T" to terminate the program. Press any other key to continue.');
read(ch);
if ch = 'T' then continue := false
until continue = false;
writeln;
writeln;
writeln('WARNING : Roundoff errors may affect the least significant digit(s).');
writeln;
writeln;
writeln('                    END OF THE DEMONSTRATION PROGRAM');
end.
