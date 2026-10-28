EXTERNAL KFORMAT::DOCOMM;

{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{+  DO COMMAND MODULE for KFORMAT Text Output Processor.  +}
{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

{ Compiler options for the Pascal/Z compiler. }
{$C-}{ control-c checking OFF }
{$M-}{ integer mult & divd error checking OFF }
{$F-}{ floating point error checking OFF }


PROCEDURE DOCOMMAND(cmdline:BUFFER);
VAR	argval: int;	      { holds value of argument of command }
	argtype: char;	      { holds argument type flag }

  {
	decode command type
  }
  FUNCTION comtype(cmdline:BUFFER):CMDSET;
  { modified for linear search with sentinal 3-18-81/rep }
  VAR	ct    :CMDSET;
	searchkey :CMDVAL;
  BEGIN
    searchkey[1] := cmdline[2];
    searchkey[2] := cmdline[3];
    cmdlist[UNKN] := searchkey; { * insert sentinal * }
    ct := CMD0;
    repeat ct := succ(ct)
    until ( cmdlist[ct]=searchkey );
    { returns either match or UNKN for no match }
    comtype := ct;
  END;

  {
	Get a parameter value from a command line and
	whether it is an absolute or relative value.
  }
  FUNCTION GETVAL(VAR cmdline:BUFFER; VAR argtyp:CHAR):int;
  VAR	i   :int;
  BEGIN
    i := 1;
    SKIPCHARS(cmdline,i);
    SKIPBL(cmdline,i);
    argtyp := cmdline[i];	    { * argument type: +,- or digit * }
    IF (argtyp=PLUS) OR (argtyp=MINUS) THEN i := i + 1;
    GETVAL := CTOI(cmdline,i)		{ *** 3-81 *** }
  END;

  {
     Copy title from buffer cmdline to title buffer.
  }
  PROCEDURE GETTL(cmdline:BUFFER; VAR thettl:BUFFER);
  VAR	i :int;
  BEGIN
    i := 1;			{ * skip command name * }
    SKIPCHARS(cmdline,i);
    SKIPBL(cmdline,i);		{ * find argument * }
    IF (cmdline[i]=SQUOTE) OR (cmdline[i]=DQUOTE) THEN i := i + 1;
    thettl := COPY(cmdline,i,LENGTH(cmdline)-i+1);
  END;

  {
     Set is a general routine for updating a parameter, relatively
     or absolutely or to a default value.
  }
  PROCEDURE SETVAL(VAR param: int; newval: int; argtype: CHAR;
				   defval,minval,maxval: int );
  BEGIN
    case ORD(argtype) of
	 0: {NEWLINE} param := defval;		{ defaulted  }
	43: {PLUS}   param := param + newval;	{ relative + }
	45: {MINUS}  param := param - newval;	{ relative - }
      ELSE:   param := newval			{ absolute   }
    end;
    param := IMIN(param,maxval);
    param := IMAX(minval,param);
  END;

  {
	space n lines or to bottom of page
  }
  PROCEDURE DOSPACE(n:int);
  BEGIN
    DOBREAK;
    IF (lineno <= bottom) THEN
      begin  IF (lineno=0) THEN PUTHEAD;
	     SKIP(IMIN(n,bottom+1-lineno));
	     lineno := lineno + n;
	     IF (lineno > bottom) THEN PUTFOOT;
      end;
  END;

BEGIN {docommand}
  argval := GETVAL(cmdline,argtype);
  case comtype(cmdline) of
    UNKN   :  { * ignore unknown commands * };
    fi	   :  BEGIN			{+ FILL - fills lines/ragged right +}
		DOBREAK;
		fill := TRUE;
	      END;
    ce	   :  BEGIN
		DOBREAK;
		SETVAL(ceval,argval,argtype,1,0,HUGE);
	      END;
    ul	   :	SETVAL(ulval,argval,argtype,1,0,HUGE);	{ *** 3-81 *** }
    ls	   :	SETVAL(lsval,argval,argtype,1,1,HUGE);
    bp	   :  BEGIN
		IF (lineno > 0) THEN DOSPACE(HUGE);
		SETVAL(curpag,argval,argtype,curpag+1,-HUGE,HUGE);
		newpag := curpag;
	      END;
    he	   :  GETTL(cmdline,header);
    fo	   :  GETTL(cmdline,footer);
    ind    :  BEGIN
		SETVAL(inval,argval,argtype,0,0,rmval-1);
		tival := inval;
	      END;
    rm	   :  SETVAL(rmval,argval,argtype,PAGWIDDEF,tival+1,HUGE);
    ti	   :  BEGIN
		DOBREAK;
		SETVAL(tival,argval,argtype,0,0,rmval);
	      END;
    nf	   :  BEGIN		{+ NO FILL - justify and fill OFF +}
		DOBREAK;
		fill := FALSE;
		spacefill := FALSE;
	      END;
    sf	   :  BEGIN		{+ SPACE FILL - justify ON +}
		DOBREAK;
		fill := TRUE;
		spacefill := TRUE;
	      END;
    sp	   :  BEGIN
		SETVAL(spval,argval,argtype,1,0,HUGE);
		DOSPACE(spval);
	      END;
    pl	   :  BEGIN
		SETVAL(plval,argval,argtype,
			PAGLENDEF,(m1val+m2val+m3val+m4val+1),HUGE);
		bottom := plval-m3val-m4val;
	      END;
    br	   :  DOBREAK;
  END {case};
END;  {docommand}

{END EXTERNAL}.

);
		bottom := plval-m3val-m4val;
	    