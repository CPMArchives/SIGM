{ The command FF n resets the printer and issues n form feeds.
  This program is written for the I.D.S. 460G "Paper Tiger" printer. }

{ Author:   Peter Grogono }

program FF;

var
printer : text;
n, nff : 0..255;

begin
read(nff);
rewrite('LST:',printer);
write(printer,chr(17));        { Select printer }
write(printer,chr(2));         { Normal mode }
write(printer,chr(6));         { Fixed spacing }
write(printer,chr(5));         { No justification }
write(printer,chr(30));        { 12 c.p.i. }
write(printer,chr(27),'B8');   { 8/48" = 6 l.p.i. }
write(printer,chr(13));        { CR }
for n := 1 to nff do 
write(printer,chr(12))       { Form feeds }
end. { FF }

