EXTERNAL KFORMAT::DOTEXT;

{+++++++++++++++++++++++++++++++++++++++++++++++++++}
{+ DOTEXT MODULE FOR KFORMAT Text Output Processor +}
{+++++++++++++++++++++++++++++++++++++++++++++++++++}

{ compiler options for Pascal/Z compiler. }
{$C-}{ control-c checking OFF }
{$M-}{ integer mult & divd error checking OFF }
{$F-}{ floating point error checking OFF }

{
	process text
}
PROCEDURE DOTEXT(inbuf:BUFFER);
VAR	i	:int;
	wordbuf :BUFFER;

  {
	delete leading blanks & set tival
  }
  PROCEDURE LEADBL(VAR lbbuf:BUFFER);
  VAR	i :int;
  BEGIN
    DOBREAK;
    i := 1;
    WHILE ((lbbuf[i]=SPACE) and (i < LENGTH(lbbuf))) DO i := i + 1;
    IF (lbbuf[i] <> NEWLINE) THEN tival := tival + i - 1;
    IF ( i<>1 ) THEN DELETE(lbbuf,1,i-1);	{ *** 3-81 *** }
  END;


  {
	width of a printed line
  }
  FUNCTION WIDTH(VAR w:BUFFER):int;
  VAR	i,wdth :int;
  BEGIN
    wdth := 0;
    FOR i := 1 TO LENGTH(w) DO
      IF (w[i]=BACKSPACE) THEN
	wdth := wdth - 1
      ELSE IF (w[i] <> NEWLINE) THEN
	wdth := wdth + 1;
    WIDTH := wdth;
  END;

  {
	centers by setting temporary indent
  }
  PROCEDURE CENTER(VAR cebuf:BUFFER);
  var	k: int;
  BEGIN
    k := ( rmval + tival - WIDTH(cebuf) ) DIV 2;
    tival := IMAX( k,0 );
  END;

  {
	replace non-white space chars with bksp, "_"
  }
  PROCEDURE UNDERLINE(VAR inbuf:BUFFER);
  VAR	u :int;
	ulstr :DSTRING;
  BEGIN
    ulstr := '  ';
    ulstr[1] := BACKSPACE;
    ulstr[2] := '_';
    u := 1;
    WHILE (u <= LENGTH(inbuf)) DO
      begin
      IF ( (inbuf[u] <> SPACE)
       AND (inbuf[u] <> TAB)
       AND (inbuf[u] <> BACKSPACE)
       AND (inbuf[u] <> NEWLINE) ) THEN
	BEGIN  INSERT(ulstr,inbuf,u+1);
	       u := u + 3
	END
      ELSE
	u := u + 1;
      end;
  END;

  {
	spread words to justify right margin
  }
  PROCEDURE SPREAD(VAR outbuf:BUFFER; outp, nextra, outwds:int);
  VAR	nb,	{ number blanks }
	ne,	{ number extra	}
	nholes, { number holes	}
	i, j: int;
  BEGIN
    IF (nextra > 0) THEN
      BEGIN{nextra > 0}
	IF (outwds > 0) and ( spacefill ) THEN
	  BEGIN
	    direction := NOT direction; 	{ tobble bias direction }
	    ne := nextra;
	    nholes := outwds - 1;
	    i := LENGTH(outbuf) - 1;		 { point at final non-blank }
	    WHILE ( ne > 0 ) DO
	      BEGIN
		WHILE ( outbuf[i] <> SPACE ) DO i := i - 1;
		IF ( direction ) THEN
		  nb := (ne-1) DIV nholes + 1	{ rounded }
		ELSE
		  nb := ne DIV nholes;		{ truncated }
		ne := ne - nb;
		nholes := nholes - 1;
		WHILE ( nb > 0 ) DO		{ insert extra blanks }
		  BEGIN
		    INSERT(' ',outbuf,i+1);
		    nb := nb - 1;
		  END;
		i := i - 1
	      END {while ne > 0}
	  END
      END {IF nextra > 0}
  END;

  {
	put a word in outbuf including margin justification
  }
  PROCEDURE PUTWORD(VAR pwbuf:BUFFER);
  VAR	w, last,
	llval, nextra: int;
  BEGIN
    w := WIDTH(pwbuf); { printable width of pwbuf }
    last := LENGTH(pwbuf) + outp + 1;	{ new end of outbuf }
    llval := rmval - tival;  { printable line length }
    IF ((outp > 0)
      AND ( ((outw + w) > llval) OR (last > MAXBUF) ) ) THEN{ too big }
	BEGIN
	  last := last - outp; { remember end of wrdbuf }
	  nextra := llval - outw + 1; { # blanks needed to pad }
	  IF ( spacefill ) THEN
	    SPREAD(outbuf,outp,nextra,outwds);
	  IF ((nextra > 0) AND (outwds > 1)) THEN
	    outp := outp + nextra;
	  DOBREAK { flush previous line }
	END;
    outp := last;
    { *  outbuf := CONCAT(outbuf,pwbuf,space);	* }
    append(outbuf,pwbuf);		{ add new word to outbuf }
    append(outbuf,space);		{ add a blank		 }
    outw := outw + w + 1;		{ update output width	 }
    outwds := outwds + 1;		{ increment the word count }
  END;


  {
	get a non-blank word from inbuf[] to wdbuf[] and
	advance g.  Returns length of wdbuf.
  }
  FUNCTION GETWORD(VAR inbuf: BUFFER; VAR g: int; VAR wdbuf: BUFFER):int;
  VAR	st: int;
  BEGIN
    WHILE (((inbuf[g]=SPACE) OR (inbuf[g]=TAB))
	  AND (g < LENGTH(inbuf))) DO g := g + 1;
    st := g;
    SKIPCHARS(inbuf,g);
    wdbuf := COPY(inbuf,st,g-st);
    GETWORD := LENGTH(wdbuf);
  END;

BEGIN {dotext}
  IF ((inbuf[1]=SPACE) OR (inbuf[1]=NEWLINE)) THEN
    LEADBL(inbuf);			{ * move left, set tival * }
  IF ( ulval > 0 ) THEN 		{ * underlining * }
    BEGIN
      UNDERLINE(inbuf);
      ulval := ulval - 1
    END;
  IF ( ceval > 0 ) THEN 		{ * centering in effect * }
    BEGIN
      CENTER(inbuf);
      PUTTEXT(inbuf);
      ceval := ceval - 1;
    END
  ELSE IF (inbuf[1]=NEWLINE) THEN	{ * all blank line * }
    PUTTEXT(inbuf)
  ELSE IF ( NOT fill ) THEN		{ * un-filled text passes * }
    PUTTEXT(inbuf)			{ * text "as is"	  * }
  ELSE					{ * filled text * }
    BEGIN
      i := 1;
      WHILE ( GETWORD(inbuf,i,wordbuf) > 0 ) DO
	PUTWORD(wordbuf);
    END;
END;  {dotext}

{END EXTERNAL}.

  i := 1;
      WHILE ( GETWORD(inbuf,i,wordbuf) > 0 ) DO
	PUTWORD(wordbuf);
    END