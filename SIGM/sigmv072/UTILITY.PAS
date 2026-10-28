{ Donated by Warren Smith, Feb 1982 }

Module Utility ;

Function Upper (In_Char : char) : char ;

  Begin { Upper }
  If (In_Char >= 'a') and (In_Char <= 'z') then
    Upper := chr( ord(In_Char) - 32)
  else
    Upper := In_Char
  end ; { Upper }

ModEnd.
