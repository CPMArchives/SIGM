{ Donated by Warren Smith, Feb 1982 }

Module DC_Hayes_Modem;

{ This set of routines was originally written in Pascal MT+ so there may }
{ be some discrepencies you will have to iron out.  In particular, there }
{ is use of some built in routines, TSTBIT, CLRBIT, SETBIT.  These       }
{ routines perform the following functions -				 }
{			TSTBIT - returns TRUE if the bit is set		 }
{			CLRBIT - clears the bit number specified	 }
{			SETBIT - sets the bit number specified		 }
{ All of these routines operate on variables of type BYTE = 0..255	 }

{ PortIn and PortOut are used here even though Pascal MT+ doesn't need   }
{ them.  I hope the syntax is correct for your compiler.		 }

{ Port assignments for D.C. Hayes S-100 Modem board }
Const
	Reg1Modem	= $11;
	Reg2Modem	= $12;
	Status_Reg_Modem= $11;
	Modem_Rcv_Reg	= $10;
	Modem_Xmit_Reg	= $10;


Procedure Init_Modem;

  Const	Char_Length     = 3;	{ 8 data bits	}
	Stop_bits	= 0;	{ 1 stop bits	}
	Parity_Inhibit	= 1;	{ no parity	}
	Parity_Type	= 1;	{ even parity	}

  begin { Init_Modem }
	{ This routine is intended for use as an initializing routine	}
	{ if your serial port needs it.  You should set up your port	}
	{ to match the comments above. }
  PortOut (Reg1Modem, Parity_Inhibit*16 + Stop_Bits*8 + Char_Length*2 +
			Parity_Type)
  end;  { Init_Modem }

Procedure Set_Modem (Modebyte : byte);

  begin { Set_Modem }
	{ This routine lets you change the various modes of the modem.	}
  PortOut (Reg2Modem, Modebyte)
  end;  { Set_Modem }

Procedure Go_Onhook (Var Modem_Mode : byte);

  begin { Go_Onhook }
  Clrbit (Modem_Mode, 7);
  Set_Modem (Modem_Mode)
  end;  { Go_Onhook }

Procedure Go_Offhook (Var Modem_Mode : byte);

  begin { Go_Offhook }
  SetBit (Modem_Mode, 7);
  Set_Modem (Modem_Mode)
  end;  { Go_Offhook }

Procedure Set_Ans_Mode (Var Modem_Mode : byte);

  begin { Set_Ans_Mode }
  Clrbit (Modem_Mode, 2);
  Set_Modem (Modem_Mode)
  end;  { Set_Modem_Mode }

Procedure Set_Org_Mode (Var Modem_Mode : byte);

  begin { Set_Org_Mode }
  Setbit (Modem_Mode, 2);
  Set_Modem (Modem_Mode)
  end;  { Set_Org_Mode }

Procedure Set_110bps (Var Modem_Mode : byte);

  begin { Set_110bps }
  Clrbit (Modem_Mode, 0);
  Set_Modem (Modem_Mode)
  end;  { Set_110bps }

Procedure Set_300bps (Var Modem_Mode : byte);

  begin { Set_300bps }
  Setbit (Modem_Mode, 0);
  Set_Modem (Modem_Mode)
  end;  { Set_300bps }

Procedure Enable_Xmit (Var Modem_Mode : byte);

  begin { Enable_Xmit }
  Setbit (Modem_Mode, 1);
  Set_Modem (Modem_mode)
  end;  { Enable_Xmit }

Procedure Disable_Xmit (Var Modem_Mode : byte);

  begin { Disable_Xmit }
  Clrbit (Modem_Mode, 1);
  Set_Modem (Modem_Mode)
  end;  { Disable_Xmit }

Function Carrier_Present : boolean;

  Var
	Status	: byte;

  begin { Carrier_Present }
  PortIn (Status_Reg_Modem, Status);
  Carrier_Present := Tstbit (Status, 6)
  end;  { Carrier_Present }

Function Ringing : boolean;

  Var
	Status	: byte;

  begin { Ringing }
  PortIn (Status_Reg_Modem, Status);
  Ringing := not Tstbit (Status, 7)
  end;  { Ringing }

Function Modem_Char_Rdy : boolean;

  Var
	Status	: byte;

  begin { Modem_Char_Rdy }
	{ Returns TRUE if data is available in the input port	}
	{ (does NOT read the data) }
  PortIn (Status_Reg_Modem, Status);
  Modem_Char_Rdy := Tstbit (Status, 0)
  end;  { Modem_Char_Rdy }

Function Modem_In : char;

  Var
	In_Char	: byte;

  begin { Modem_In }
	{ Reads the data port of the acoustic coupler.  May have to	}
	{ mask off bit 7 of the data if the sender is not treating it	}
	{ as part of the data byte sent. }
  PortIn (Modem_Rcv_Reg, In_Char);
  Modem_In := chr(In_Char & $7F)
  end;  { Modem_In }

Function Modem_Out (OutChar : char) : boolean;

  Var
	Status : byte;

  Function Modem_Busy : boolean;

    Var
	Status	: byte;

    begin { Modem_Busy }
	{ Returns TRUE if the transmit buffer empty bit of status port	}
	{ indicates that the UART is still transmitting.		}
    PortIn (Status_Reg_Modem, Status);
    Modem_Busy := not Tstbit (Status, 1)
    end;  { Modem_Busy }

  begin { Modem_Out }
  While Modem_Busy do;
  If Carrier_Present then
    begin
    PortOut (Modem_Xmit_Reg, ord(OutChar));
    Modem_Out := TRUE
    end
  else
    Modem_Out := FALSE
  end;  { Modem_Out }

Procedure Delay;	{ delay's for 10 millisecond }

  Const
	Count = 477;
  Var
	I : integer;
  begin { Delay }
	{ Very machine dependent.  I am using a 5 MHz 8085, running	}
	{ Pascal MT+ 5.5 if that helps. }
  For I := 1 to Count do
  end;  { Delay }

Procedure Dial_a_Number (Var Modem_Mode : byte; Number : string);

  Var
	I, J, K, Pulse_Count : integer;

  Procedure Pulse_Line;

    Var
	I : integer;
    begin { Pulse_Line }
    Go_Onhook (Modem_Mode);
    For I := 1 to 5 do
      Delay;			{ leave on for 50 ms }
    Go_Offhook (Modem_Mode);
    For I := 1 to 5 do
      Delay			{ leave off for 50 ms }
    end;  { Pulse_Line }

  begin { Dial_a_Number }
  Go_Offhook (Modem_Mode);
  For I := 1 to 100 do		{ Wait for dial tone	}
    Delay;
  For I := 1 to Length(Number) do
    If (Number[I] < '0') OR (Number[I] > '9') then
      begin
      Write (Number[I]);
      For J := 1 to 300 do	{ wait 3 seconds for non_digit }
	Delay
      end
    else
      begin
      Pulse_Count := ord(Number[I]) - $30;
      If Pulse_Count = 0 then
	Pulse_Count := 10;
      Write (Number[I]);
      For J := 1 to Pulse_Count do
	Pulse_Line;
      For J := 1 to 60 do
	Delay			{ 600 ms delay between digits }
      end;
  Writeln
  end;  { Dial_a_Number }

Modend.
