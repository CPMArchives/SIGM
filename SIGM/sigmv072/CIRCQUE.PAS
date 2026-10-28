{ Donated by Warren Smith, Feb 1982 }

Module Circular_Queue ;

{ This set of routines is intended only as a guide for handling	}
{ circular buffers or queues.  Normally, I/O buffering would	}
{ be handled through this type of data structure and operations.}

Type
	Q_range	      = Min_Q..Max_Q ;
	Q_Type	      = byte ;
	Queue	      = record
			Q_not_empty,
			Q_not_full	: boolean ;
			Q_head,
			Q_tail		: Q_Range ;
			Q		: array [Q_Range] of Q_Type ;
		    end ;

Function Put_Q (Var Cur_Q : Queue ; Var Cur_Entry : Q_Type) : boolean ;

  begin { Put_Q }
  With Cur_Q do
    If Q_not_full then
      begin
      Q[Q_head] := Cur_Entry ;
      If Q_head = Max_Q then
        Q_head := Min_Q
      else
        Q_head := Q_head + 1 ;
      Q_not_full := Q_head <> Q_tail ;
      Q_not_empty := TRUE ;
      Put_Q := TRUE
      end
    else
      Put_Q := FALSE
  end ; { Put_Q }

Function Get_Q (Var Cur_Q : Queue ; Var Cur_Entry : Q_Type) : boolean ;

  begin { Get_Q }
  With Cur_Q do
    If Q_not_empty then
      begin
      Cur_Entry := Q[Q_tail] ;
      If Q_tail = Max_Q then
        Q_tail := Min_Q
      else
        Q_tail := Q_tail + 1 ;
      Q_not_full := TRUE ;
      Q_not_empty := Q_head <> Q_tail ;
      Get_Q := TRUE
      end
    else
      Get_Q := FALSE
  end ; { Get_Q }

ModEnd.