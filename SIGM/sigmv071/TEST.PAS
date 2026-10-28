Program bbtest; {$i+ }

{ Program to illustrate the external routines BSET, RESET, and
  TEST which set, reset and test the value of an individual bit
  within a given byte, respectively.  The .SRC file for the 
  external routines is the file BITBANG.SRC}




type
   byte = 0..255;

var i,j,k: integer;
    x,a,b,c: byte;

procedure  bset( var x: byte; y: byte ); external;
procedure reset( var x: byte; y: byte ); external;
function   test(     x: byte; y: byte ): boolean; external;


procedure show_bits;

{notice that the procedure test returns a boolean value, true if the 
 bit is set (1) and false if not (0).  }

begin
writeln;
writeln('the binary represenation of the byte is: ');	
	for x:= 7 downto 0 do write(test(a,x):6); 
writeln;
writeln;
end;


begin
writeln( 'Bit banger test program' );
   repeat


	write( 'input decimal value for byte  ---> ' );
	readln( a );
	writeln;

	show_bits;

      write( 'Input number of Bit to set in byte ---> ' );
      readln( b );

      bset( a, b );
      writeln( 'new value of byte is: ', a);

	show_bits;

	writeln;
	writeln('Will now reset that same bit. ');
        reset( a, b );

       writeln('The value of the byte is now: ',a);
       writeln;

	show_bits;
      
	write('Input number of bit to test to see if it is set ---> ');
	readln(b);

      writeln( ' bit is: ', test( a, b ));
   until false;
end.


