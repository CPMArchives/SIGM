{Donated by Warren Smith, Feb 1982}

Program PAYMENTS ;

Var	AnnRate, Years, Amount, Monthly : real ;
	Dollars, Cents_tens, Cents_ones : integer ;
{--------------------------------------------
I modified Screen Clear since the original was an
external so you'll have to change this (maybe).
			----Charlie		}
Procedure ScreenClr;

BEGIN
	WRITELN(CHR(26));
END;

Function Pmt (Amount, AnnRate, Years : real) : real ;

  Var
	MonRate, Months : real ;

  Function XTOY (X, Y : real) : real ;

    Begin { XTOY }
    If (Y = 0.0) then
      XTOY := 1.0
    else
      If (Y = 1.0) then
        XTOY := X
      else
        If (Y < 0.0) then
          XTOY := 1.0 / exp(-Y * ln(X))
        else
          XTOY := exp(Y * ln(X))
    end;  { XTOY }

  Begin { Pmt }
  MonRate := AnnRate / 100.0 / 12.0 ;
  Months := Years * 12.0 ;
  Pmt := Amount * MonRate / (1.0 - XTOY(1.0+MonRate,-Months)) ;
  End;  { Pmt }

Begin { Main }

ScreenClr; ;
Writeln ;
Writeln ;
Writeln('Input the following:') ;
Writeln ;
Writeln('  Annual    Years    Amount') ;
Writeln('Percentage  before  Financed') ;
Writeln('   Rate     Paid') ;
Writeln ;
Readln (AnnRate, Years, Amount) ;
Monthly := Pmt(Amount, AnnRate, Years) ;
Writeln ;
Writeln ;
Dollars := Trunc(Monthly) ;
Cents_tens := Trunc((Monthly-Dollars)*10.0) ;
Cents_ones := Trunc((Monthly-Dollars)*100.0) mod 10 ;
Writeln ('Monthly payments : $', Dollars:1,'.',Cents_tens:1,Cents_ones:1) ;
Writeln ;
Writeln ;
Writeln ;
Writeln ;
Writeln

End.  { dummy }
