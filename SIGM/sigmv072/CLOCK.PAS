{ Donated by Warren Smith, Feb 1982 }

Module Clock;		{ This is a collection of routines to access	}
			{ an OKI MSM5832 clock chip.			}

Const
	{ Ports used by the clock	}
	Clk_Cmd_Port	= $5A;
	Clk_Data_Port	= $5B;
	Zero		= 0;
	Dig_Mask	= $0F;
	Rd_Bit		= $10;
	Wr_Bit		= $20;
	Hold_Bit	= $40;
	Min_Time_Index	= 0;
	Max_Time_Index	= 5;
	Day_of_Week	= 6;
	Min_Date_Index	= 7;
	Max_Date_Index	= 12;

Type
	Time_Array	= array [Min_Time_Index .. Max_Time_Index] of byte;
	Date_Array	= array [Min_Date_Index .. Max_Date_Index] of byte;

{ These external routines are only used by the last procedure and may	}
{ be erased if that routine is unused.					}
External Procedure GotoXY (X, Y : integer);

External Procedure Read_Cursor (Var X, Y : integer);

Function Combine (Byte1, Byte2 : byte) : integer;

    begin { Combine }
    Combine := Byte1 * 10 + Byte2
    end;  { Combine }

Procedure DisComb (Value : integer; Var Byte1, Byte2 : byte);

    begin { DisComb }
    Byte1 := (Value DIV 10) MOD 10;
    Byte2 := Value MOD 10
    end;  { DisComb }

Function Rd_Clock (Digit : byte) : byte;

    begin { Rd_Clock }
    Out [Clk_Cmd_Port] := Digit ! Rd_Bit;
    Rd_Clock := Inp [Clk_Data_Port];
    Out [Clk_Cmd_Port] := Zero
    end;  { Rd_Clock }

Procedure Wrt_Clock (Digit, Value : byte);

    begin { Wrt_Clock }
    Digit := Digit & Dig_Mask;
    Out [Clk_Cmd_Port]  := Hold_Bit;
    Out [Clk_Cmd_Port]  := Digit ! Hold_Bit;
    Out [Clk_Data_Port] := Value;
    Out [Clk_Cmd_Port]  := Digit ! Hold_Bit ! Wr_Bit;
    Out [Clk_Cmd_Port]  := Digit ! Hold_Bit;
    Out [Clk_Cmd_Port]  := Zero
    end;  { Wrt_Clock }

Procedure Get_Time (Var Seconds, Minutes, Hours : Integer);

    Var
	I, Hours10 : integer;
	Time : Time_Array;

    begin { Get_Time }
    For I := Min_Time_Index to Max_Time_Index do
	Time [I] := Rd_Clock (I);
    Hours10 := Min_Time_Index + 5;
  { Mask out 12/24 format and AM/PM bit }
    Time [Hours10] := Time [Hours10] & 3;
    I := Min_Time_Index;
    Seconds := Combine (Time[I+1], Time[I]);
    I := I + 2;
    Minutes := Combine (Time[I+1], Time[I]);
    I := I + 2;
    Hours   := Combine (Time[I+1], Time[I])
    end;  { Get_Time }

Procedure Set_Time (Seconds, Minutes, Hours : integer);

    Const
	Mode_24 = 8;	{ 24 hour mode bit }

    Var
	I, Hours10 : integer;
	Time : Time_Array;

    begin { Set_Time }
    Hours10 := Min_Time_Index + 5;
    I := Min_Time_Index;
    DisComb (Seconds, Time[I+1], Time[I]);
    I := I + 2;
    DisComb (Minutes, Time[I+1], Time[I]);
    I := I + 2;
    DisComb (Hours,   Time[I+1], Time[I]);
    Time [Hours10] := Time [Hours10] ! Mode_24;{set 24 hour mode in hours 10's}
    For I := Min_Time_Index to Max_Time_Index do
	Wrt_Clock ( I, Time [I])
    end;  { Set_Time }

Procedure Get_Date (Var Day, Month, Year : integer);

    Var
	I, Days10 : integer;
	Date : Date_Array;

    begin { Get_Date }
    For I := Min_Date_Index to Max_Date_Index do
	Date [I] := Rd_Clock (I);
    Days10 := Max_Date_Index - 4;
    Date [Days10] := Date [Days10] & 3;		{ mask out leap year bit }
    I := Min_Date_Index;
    Day   := Combine (Date[I+1], Date[I]);
    I := I + 2;
    Month := Combine (Date[I+1], Date[I]);
    I := I + 2;
    Year  := Combine (Date[I+1], Date[I])
    end;  { Get_Date }

Procedure Set_Date (Day, Month, Year : integer);

    Const
	Leap_Bit = 8;

    Var
	I, Days10 : integer;
	Date : Date_Array;

    begin { Set_Date }
    Days10 := Max_Date_Index - 4;
    I := Min_Date_Index;
    DisComb (Day,   Date[I+1], Date[I]);
    I := I + 2;
    DisComb (Month, Date[I+1], Date[I]);
    I := I + 2;
    DisComb (Year,  Date[I+1], Date[I]);
    if (Month <= 2) AND ((Year Mod 4) = 0) then
	Date[Days10] := Date[Days10] ! Leap_Bit;  { set leap bit in Days 10's}
    For I := Min_Date_Index to Max_Date_Index do
	Wrt_Clock (I, Date[I])
    end;  { Set_Date }

Procedure Get_Day (Var Day : integer);

    begin { Get_Day }
    Day := Rd_Clock (Day_of_Week)
    end;  { Get_Day }

Procedure Set_Day (New_Day : integer);

    begin { Set_Day }
	{ make sure it is in valid range }
    If (New_Day >= 0) and (New_Day <= 6) then
	Wrt_Clock (Day_of_Week, New_Day)
    end;  { Set_Day }

Procedure Wrt_AM_PM (Var Outfile : Text; Seconds, Minutes, Hours : integer);

    Var
	AP : array [ 1 .. 2 ] of char;

    begin { Wrt_AM_PM }
    If Hours > 12 then
	begin
	Hours := Hours - 12;
	AP := 'pm'
	end
    else
	If Hours = 12 then
	    AP := 'pm'
	else
	    AP := 'am';
    Write (Outfile, (Hours MOD 100):2, ':',
		    ((Minutes DIV 10) MOD 10):1, (Minutes MOD 10):1, ':',
    		    ((Seconds DIV 10) MOD 10):1, (Seconds MOD 10):1, ' ',AP)
    end;  { Wrt_AM_PM }

Procedure Wrt_Time (Var Outfile : Text; Seconds, Minutes, Hours : integer);

    begin { Wrt_Time }
    Write (Outfile, ((Hours DIV 10) MOD 10):1, (Hours MOD 10):1, ':',
		    ((Minutes DIV 10) MOD 10):1, (Minutes MOD 10):1, ':',
    		    ((Seconds DIV 10) MOD 10):1, (Seconds MOD 10):1)
    end;  { Wrt_Time }

Procedure Wrt_Date (Var Outfile : Text; Day, Month, Year : integer);

    Var
	Mon : array [ 1 .. 3 ] of char;

    begin { Wrt_Date }
    Case Month of
	1  : Mon := 'Jan';
	2  : Mon := 'Feb';
	3  : Mon := 'Mar';
	4  : Mon := 'Apr';
	5  : Mon := 'May';
	6  : Mon := 'Jun';
	7  : Mon := 'Jul';
	8  : Mon := 'Aug';
	9  : Mon := 'Sep';
	10 : Mon := 'Oct';
	11 : Mon := 'Nov';
	12 : Mon := 'Dec';
	else Mon := 'OOP'
	end;

    Write (Outfile, Mon, ' ', Day:1, ',', ' 19', (Year MOD 100):2)
    end;  { Wrt_Date }

Procedure Wrt_Day (Var OutFile : Text; Day : integer);

    Var
	New_Day : array [ 1 .. 3 ] of char;

    begin { Wrt_Day }
    Case Day of
	0 : New_Day := 'Sun';
	1 : New_Day := 'Mon';
	2 : New_Day := 'Tue';
	3 : New_Day := 'Wed';
	4 : New_Day := 'Thu';
	5 : New_Day := 'Fri';
	6 : New_Day := 'Sat';
	else New_Day := 'DAY'
	end;
    Write (OutFile, New_Day)
    end;  { Wrt_Day }

Procedure Time_Block (X, Y : integer);

    Var
	Seconds, Minutes, Hours,
	Day_of_Week,
	Day, Month, Year : integer;
	Old_X, Old_Y : integer;

    begin { Time_Block }
    Read_Cursor (Old_X, Old_Y);
    Get_Time (Seconds, Minutes, Hours);
    Get_Date (Day, Month, Year);
    Get_Day (Day_of_Week);
    GotoXY (X, Y);
    Wrt_Day (OutPut, Day_of_Week);
    GotoXY (X, Y + 1);
    Wrt_Date (OutPut, Day, Month, Year);
    GotoXY (X, Y + 2);
    Wrt_AM_PM (OutPut, Seconds, Minutes, Hours);
    GotoXY (Old_X, Old_Y)
    end;  { Time_Block }

Modend.
