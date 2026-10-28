{	This was part of a Pascal Course (this is program 
Listing 5 of Welsh & Elder, page 101). It has been modified 
only very slightly to provide a better input/output format.
Donated by Gerald Hewett }


Program Checkln;

     type range =0..999;

     var  dollars : range;
            cents : 0..99;

     Procedure convertintowords (x : range);

          type digit = 0..9;
          var  h,t,u : digit;

          Procedure units (i : digit);
               Begin
                    case i of
                         0 : ;
                         1 : write ('One ');
                         2 : write ('Two ');
                         3 : write ('Three ');
                         4 : write ('Four ');
                         5 : write ('Five ');
                         6 : write ('Six ');
                         7 : write ('Seven ');
                         8 : write ('Eight ');
                         9 : write ('Nine ');
                    end
               end;      (*Units*)

          Begin
               h := x div 100;
               t := x mod 100 div 10;
               u := x mod 10;
               if h >0 then 
                    begin 
                         units (h);
                         write('Hundred ');
                    end;
               if t = 1 then case u of 
                    0 : write('Ten ');
                    1 : write('Eleven ');
                    2 : write('Twelve ');
                    3 : write('Thirteen ');
                    4 : write('Fourteen ');
                    5 : write('Fifteen ');
                    6 : write('Sixteen ');
                    7 : write('Seventeen ');
                    8 : write('Eighteen ');
                    9 : write('Nineteen ');
              end   Š          


             else begin
                case t of
                    0 : ;
                    2 : write('Twenty ');
                    3 : write('Thirty ');
                    4 : write('Forty ');
                    5 : write('Fifty ');
                    6 : write('Sixty ');
                    7 : write('Seventy ');
                    8 : write('Eighty ');
                    9 : write('Ninety ');
               end;
               units(u)
          end  
     end;     (*Converttowords*)

     Begin
          writeln;
          writeln('Enter the amount to be printed.');
          writeln('Use a space, not a period!');
          read(dollars);
          while dollars >= 0 do
               begin
               read(cents);
               write(dollars : 4, cents : 3, ' ' : 5);
               if (dollars=0) and (cents=0) then
                    write('Nil')
               else begin
                    if dollars > 0 then
                         begin
                              convertintowords (dollars);
               write('Dollaró and ',cents : 2,' cents.')
                              end;
                         end;
               writeln;
               read(dollars)
          end
     end.
