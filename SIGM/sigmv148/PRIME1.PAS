external  prime::prime1(2);

procedure instructions;
{writes a screen full of instructions}
begin
writeln('PRIME gets a seed number from you and determines whether it');
writeln('is prime.  It then decrements the number and tries again.');
writeln('the process continues until a prime is found.');
writeln; writeln;
writeln('To exit without running the program enter a number less than three.');
writeln;
writeln('note: the long integer procedures, for some odd reason, require');
writeln('two carriage returns after a number entry.  Otherwise the program');
writeln('will hang.');
writeln;
writeln('The program will write periods to the screen to indicate that it');
writeln('is indeed working.  ');
end;

procedure get_n(var n:longint);
{get the seed number from the operator}
begin
writeln;
writeln('        2 <cr> to follow');
write('Enter the starting number to test for prime:  ');
getlong(stdin,n);
end;

procedure if_even(var n:longint);
{if the number is even, it is obviously not prime.  Therefore, subract
1 to make it odd.  The UNIT1 set has no function 'odd' as in Pascal integer
arithmetic, but using the divlong procedure and checking the modulus works
just fine}
var
  one, two, quot, modu: longint;
begin
  cvi(2,two);
  cvi(1,one);
  divlong(n,two,quot,modu);
  if iszero(modu) then sub(n,one,n);
end;

procedure n_prime(n:longint; var prm:boolean);
{This is the Knuth algorithm that tests for primeness.  It is the real
guts of the program.  
}
label
  1;
const
  k = 10;
var
  two, one, zero,
  modu,
  n1, n2, x, y, z, r, p,
  quot,
  temp: longint;
  rn, i: integer;

begin
  seedrand;
  cvi(2,two);
  cvi(1,one);
  cvi(0,zero);
  repeat
    for i := 1 to k do
    begin		{x=2 + int((n-2)*rnd(0)}
    rn := trunc(random(100));
    writeln;
    cvi(rn,r);  
    sub(n,two,n1);
    multlong(n1,r,n2);
    divlong(n2,two,n2,modu);	{int}
    multlong(n2,two,n2);
    add(n2,two,x);
    y := one;
    sub(n,one,p);
    repeat
    write('.');
      divlong(p,two,quot,modu);
      if not iszero(modu) then
      begin			{this section only if p is odd}
        multlong(y,x,y);
        divlong(y,n,temp,y);
      end;			{no else clause}
    multlong(x,x,x);
    divlong(x,n,temp,x);
    divlong(p,two,p,modu);
    until iszero(p);
    if equal(y,one) then
    begin
      prm := true;
      goto 1;
    end
    else prm := false;
    end;			{for i loop}
  1:
  if not prm then
    begin
    putlong(stdout,n,16);
    writeln(' is not prime.');
    sub(n,two,n);    
    end
  else
    begin
    putlong(stdout,n,16);
    writeln(' is probably prime.');
    sub(n,one,n1);
    divlong(n1,three,quot,modu);
    if iszero(modu) then writeln(' ... but poor choice.');
    end;
  until prm;
end;
.   


