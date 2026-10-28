{ Donated by Warren Smith, Feb 1982 }

Module CRT_Televideo;

{ This set of routines is designed to support a Televideo 912/920 type	}
{ of terminal.  If you have trouble adapting it to your terminal, give	}
{ me a call.								}

Const
	Direct_IO = 6 ;
	Crt_Status_Port = $5D;	{ Godbout System Support 1 serial status port }
	Char_Rcvd_Bit	= 2;	{ may be unique to the Signetics 2651 U/SART }

{ This is an external function supplied with Pascal MT+ which gives	}
{ you a hook into CPM.							}
External Function @BDOS (Func, Parm : integer) : integer;

Function Con_In : char ;	{ non-echoed input from the console	}

  Const
	Parm = 255;

  Begin { Con_In }
  Con_In := chr(@BDOS(Direct_IO, Parm))
  end ; { Con_In }

Procedure Con_Out (Out_Char : char) ;

  Var
	Dummy : integer ;

  Begin { Con_Out }
  Dummy := @BDOS(Direct_IO, ord(Out_Char))
  end ; { Con_Out }

Function KeyPressed : Boolean ;

  Begin { KeyPressed }
  KeyPressed := Tstbit (Inp[$5D], 1)	{ Specific to System Support board }
  end ; { KeyPressed }

Function Get_Console : char ;	{ waits for a single character from the	}
				{ console.				}
  Begin { Get_Console }
  While not KeyPressed do;
  Get_Console := Con_In
  end ; { Get_Console }

Procedure GoToXY (X, Y : integer) ;

Const X_PLAC = 4 ;
      Y_PLAC = 3 ;
      MAX_X  = 80 ;
      MAX_Y  = 24 ;
      X_OFF  = 31 ;
      Y_OFF  = 31 ;

  Var BUFFER : array [1..4] of char ;

  Begin { GoToXY }
  BUFFER [1] := chr(27) ;
  BUFFER [2] := '=' ;
  If X < 1 Then
    BUFFER [X_PLAC] := chr(X_OFF)
  else
    If X > MAX_X then
      BUFFER [X_PLAC] := chr(MAX_X + X_OFF)
    else
      BUFFER [X_PLAC] := chr(X + X_OFF) ;

  If Y < 1 then
    BUFFER [Y_PLAC] := chr(Y_OFF)
  else
    If Y > MAX_Y then
      BUFFER [Y_PLAC] := chr(MAX_Y + Y_OFF)
    else
      BUFFER [Y_PLAC] := chr(Y + Y_OFF) ;

  Con_Out(Buffer[1]) ;
  Con_Out(Buffer[2]) ;
  Con_Out(Buffer[3]) ;
  Con_Out(Buffer[4])

  end ; { GoToXY }

Procedure Home ;

  Begin { Home }
  Con_Out (chr($1E))
  end ; { Home }

Procedure ScreenClr ;

  Begin { ScreenClr }
  Con_Out (chr(26))
  end ; { ScreenClr }

Procedure LineClr;

  Begin { LineClr }
  Con_Out (chr(27));
  Con_Out ('t')
  end;  { LineClr }

Procedure Read_Cursor (Var X, Y : integer);

    Var
	Discard : char;

    begin { Read_Cursor }
	{ request cursor coordinates from TeleVideo 912 or 920 }
    ConOut (chr(27));
    ConOut ('?');
    While not KeyPressed do;
    Y := ord(ConIn) - $1F;
    While not KeyPressed do;
    X := ord(ConIn) - $1F;
    While not KeyPressed do;
    Discard := ConIn	{ this last character is supposed to be a CR }
    end;  { Read_Cursor }

ModEnd.
