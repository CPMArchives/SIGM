
{ Donated By Warren Smith, Feb 1982 }

Program PARM;
{***************************************************************}
{                  Parameter Manipulation                       }
{                   for Pascal/Z programs                       }
{ this code is designed to facilitate the coding of parsing     }
{ routines embedded in Pascal/Z programs                        }
{***************************************************************}

Const PARM_LEN = 12 ; {Arbitrary max length for any parameter}
      LINE_LEN = 255; {Max buffer size allowed by Pascal/Z   }
                      {for disk files                        }

Type  SET_CHAR = set of char ;
      PARAMTER = Record
                   PARM_STR : 1..255 ;
                   PARM_END : 1..255
                 end ;
      LINE_IDX = 1..LINE_LEN ;
      CARD_MGE = Array [LINE_IDX] of char ;
      BUFFER   = Record
                   CHARS    : CARD_MGE ;
                   CUR_PTR  : LINE_IDX ;
                   PARM     : PARAMTER
                 end ;


Procedure GET_PTRS (Var IN_BUFF  : BUFFER ;
                    Var SLOUGHS,
                        DELIMS   : SET_CHAR ;
                        MAX_LEN  : integer) ;

  Function NXT_CHAR (Var INPUT_LN : BUFFER) : char ;

  Begin {NXT_CHAR}
  If INPUT_LN.CUR_PTR > LINE_LEN then
    NXT_CHAR := chr(0)
  else
    NXT_CHAR := INPUT_LN.CHARS[INPUT_LN.CUR_PTR]
  end ; {NXT_CHAR}

Begin {GET_PTRS}

  {Slough off leading chars to find start of parameter}

While (NXT_CHAR(IN_BUFF) in SLOUGHS) and
      (IN_BUFF.CUR_PTR <= LINE_LEN)  do
  IN_BUFF.CUR_PTR := IN_BUFF.CUR_PTR + 1 ;

With IN_BUFF do
  Begin {With}
  PARM.PARM_STR := CUR_PTR ;

  {Find the end of the parameter}

  While (not(NXT_CHAR(IN_BUFF) in SLOUGHS) andŠ        (CUR_PTR <= LINE_LEN))             do
    CUR_PTR := CUR_PTR + 1 ;

  PARM.PARM_END := CUR_PTR ;

  If PARM.PARM_END - PARM.PARM_STR > MAX_LEN then
    PARM.PARM_END := PARM.PARM_STR + MAX_LEN ;

  end   {with}
end ; {GET_PTRS}



Begin {dummy main program}
end.  {dummy main program}
