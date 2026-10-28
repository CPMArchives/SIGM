{ Donated by Warren Smith, Feb 1982 }

Program Terminal;

Var
	Modem_Mode : byte;	{ must be used to hold modem's mode }
	I	: integer;
	Number	: string;
	Xoff	: boolean;
	ESC_Char,
	Answer	: char;

{ ** Found in CRT.PAS ** }
External Procedure ScreenClr;

External Function ConIn : char;

External Procedure ConOut (Out_Char : char);

External Function KeyPressed : boolean;

External Function Get_Console : char;

External Procedure GotoXY (X, Y : integer);

{ ** Found in UTILITY.PAS ** }
External Function Upper (In_Char : char) : char;

{ ** Found in either DCMODEM.PAS or ACOUSTIC.PAS ** }
External Procedure Init_Modem;

External Procedure Set_Modem (Modebyte : byte);

External Procedure Go_Onhook (Var Modem_Mode : byte);

External Procedure Go_Offhook (Var Modem_Mode : byte);

External Procedure Set_Ans_Mode (Var Modem_Mode : byte);

External Procedure Set_Org_Mode (Var Modem_Mode : byte);

External Procedure Set_110bps (Var Modem_Mode : byte);

External Procedure Set_300bps (Var Modem_Mode : byte);

External Procedure Enable_Xmit (Var Modem_Mode : byte);

External Procedure Disable_Xmit (Var Modem_Mode : byte);

External Function Carrier_Present : boolean;

External Function Ringing : boolean;

External Function Modem_Char_Rdy : boolean;

External Function Modem_In : char;

External Function Modem_Out (OutChar : char) : boolean;

External Procedure Delay;	{ delay's for 10 millisecond }

External Procedure Dial_a_Number (Var Modem_Mode : byte; Number : string);

Procedure Dumb;

  Var
	Terminator, In_Char, In_Mod,
	Control_Char, Dummy_Char	: char;
	Half_Duplex, Dummy_Boolean,
	Test_Line			: boolean;

  begin { Dumb }
  In_Char := chr(0);
  Terminator := chr(26);

  Half_Duplex := TRUE;
  Test_Line := FALSE;

  While In_Char <> Terminator do
    begin
    If KeyPressed then
      begin
      In_Char := ConIn;
      If In_Char = chr(13) then	{ carriage return }
	In_Char := chr(19);	{ control-S used by X-off protocols  }
      If In_Char = ESC_char then
	begin
	Control_Char := Get_Console;
	Dummy_Char := Get_Console;
	Case Control_Char of
	  'A' : begin	{ Toggle between Full and Half Duplex	}
		Half_Duplex := not Half_Duplex;
		If Half_Duplex then
		  Writeln ('Half_Duplex')
		else
		  Writeln ('Full Duplex')
		end;
	  'B' : In_Char := Terminator;	{ Terminates session }
	  'C' : Test_Line := not Test_Line;	{ Causes display of control }
						{ characters coming in on   }
						{ the modem.		    }
	  else
	  end
	end
      else
	If Modem_Out (In_Char) then
	  begin
	  If Half_Duplex then
	    ConOut (In_Char)
	  end
	else
	  begin
	  Writeln ('Carrier Lost');
	  In_Char := Terminator
	  end
      end;

    If Modem_Char_Rdy then
      begin
      In_Mod := Modem_In;
      If Test_Line then
	If (In_Mod >= ' ') AND (In_Mod <= '~') then
	  ConOut (In_Mod)
	else
	  begin
	  WriteHex (Output, In_Mod, 1);	{ This routine outputs in hex }
	  Writeln
	  end
      else
	ConOut (In_Mod)
      end;

    If not Carrier_Present then
      begin
      Writeln ('Carrier Lost');
      In_Char := Terminator
      end
    end
  end;  { Dumb }

begin { Main }

ESC_Char := chr(01);	{ Used by escape sequences, you may want to	}
			{ change it to the ASCII ESC character		}

ScreenClr;

Write('Will you be using X-Off (carriage return = cntl-S) (Y or N)? ');
Read (Answer);
Writeln;
Xoff := Upper(Answer)='Y';

Modem_Mode := 0;

Init_Modem;

Write ('Number Please - ');
Readln (Number);

Writeln ('Dialing');

Dial_a_Number (Modem_Mode, Number);

Set_300bps (Modem_Mode);

Set_Org_Mode (Modem_Mode);

Enable_Xmit (Modem_Mode);

I := 0;		{ Set up for 20 second timeout }
While (I < 2000) AND (not Carrier_Present) do
  begin
  Delay;
  I := I + 1
  end;

If Carrier_Present then
  begin
  Writeln ('Connection made');
  Dumb
  end
else
  Writeln ('No carrier found, check number - ', Number);

Go_Onhook (Modem_Mode);

Writeln ('Hanging Up');

Writeln ('Program terminated')

end.
