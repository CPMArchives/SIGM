PROGRAM kformat;
{
 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 +								   +
 + PROGRAM TITLE:		FORMAT				   +
 +								   +
 + WRITTEN BY:			K & F.				   +
 +								   +
 +  Translated from the "format" program in the book		   +
 +  "Software Tools" by Kernigan & Flager			   +
 +								   +
 + MODIFICATION RECORD: 					   +
 +   MAR 81 - Pascal/Z v 3.3 and seperately compiled		   +
 +	      modules by Raymond E. Penley, March 1981		   +
 +								   +
 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Zug Editor's comment: This is the MAIN module of a group of programs,
	the following programs are needed:
		KFORMAT.DOC
		KFORMAT.SUB
		KFORMAT.SYM
		KFORMAT.TYP
		STDIO.PAS
		DOCOMM.PAS
		DOTEXT.PAS
		GLOBALS.TOP
		STDFUNC.TOP
	Each PAS progrm gets compiled. The main program must be compiled
first because it makes the additional files *.sym and *typ. Each module
may be edited and recompiled at any time. However, if any changes are 
made in the MAIN module then ALL modules MUST be compiled again. At link
time you should have:
	LINK KFORMAT,STDIO,DOTEXT,DOCOMM

}

{$iGLOBALS.TOP }

{$iSTDFUNC.TOP }


{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{+++ ALL I/O PROCEDURES ARE IN EXTERNAL FILE: STDIO.PAS +++}
{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

PROCEDURE STDOPEN;EXTERNAL;
PROCEDURE getc(var ch: char);EXTERNAL;
PROCEDURE putc(c:CHAR);EXTERNAL;
PROCEDURE puts(VAR LINE:BUFFER);EXTERNAL;
PROCEDURE gets(VAR LINE:BUFFER);EXTERNAL;


{
  Skip chars in string
}
PROCEDURE SKIPCHARS(VAR buf: BUFFER; VAR ppos: int);
begin
  WHILE ( (buf[ppos]<>BLANK)
      AND (buf[ppos]<>TAB)
      AND (buf[ppos]<>newline) ) do ppos := ppos + 1;
end;


{
  Skip blanks in string
}
PROCEDURE SKIPBL(VAR buf:BUFFER; VAR i: int);
BEGIN
  WHILE (buf[i]=BLANK) OR (buf[i]=TAB) DO i := i + 1;
END;


{$iIMINMAX.LIB }

{$iCTOITOC.LIB }


{
  Skip n blank lines
}
PROCEDURE SKIP(s: int);
VAR	i: int;
BEGIN
  FOR i := 1 to s DO PUTC(newline);
END;


PROCEDURE PUTDEC(number,width: int);
VAR	numstr	:DSTRING;
	i,nd	: int;
BEGIN
  numstr := STR(number);
  nd := length(numstr);
  FOR i := (nd+1) TO width DO PUTC(SPACE);
  FOR i := 1 to nd DO PUTC(numstr[i]);
END;


{
  put out title line with optional page number
}
PROCEDURE PUTTL(VAR ttl:BUFFER; pagno: int);
VAR	i: int;
BEGIN
  FOR i := 1 TO LENGTH(ttl) DO
    IF (ttl[i]=PAGENUM)THEN
      PUTDEC(pagno,1)
    ELSE
      PUTC(ttl[i]);
END;


{
	put out page header
}
PROCEDURE PUTHEAD;
BEGIN
  curpag := newpag;
  newpag := newpag + 1;
  IF (m1val > 0) THEN
    BEGIN
      SKIP(m1val-1);
      PUTTL(header,curpag)
    END;
  SKIP(m2val);
  lineno := m1val + m2val + 1;
END;


{
	put out page footer
}
PROCEDURE PUTFOOT;
BEGIN
  SKIP(m3val);
  IF (m4val > 0) THEN
    BEGIN
      PUTTL(footer,curpag);
      SKIP(m4val-1)
    END;
  lineno := 0;				{ *** 3-24-81 *** }
END;


{
	put out a line with proper spacing & indenting
}
PROCEDURE PUTTEXT(VAR ptline:BUFFER);
VAR	i: int;
BEGIN
  IF ((lineno=0) OR (lineno > bottom)) THEN PUTHEAD;
  FOR i := 1 to tival DO PUTC(SPACE);
  tival := inval;
  puts(ptline);
  SKIP(IMIN(lsval-1,bottom-lineno));
  lineno := lineno + lsval;
  IF (lineno > bottom) THEN PUTFOOT;
END;


PROCEDURE DOBREAK;
BEGIN
  IF ( outp > 0 ) THEN
    begin append(outbuf,newline);
	  PUTTEXT(outbuf);
    end;
  outp := 0;
  outw := 0;
  outwds := 0;
  setlength(outbuf,0);		{ * outbuf := ''; * }
END;


{++++++++++++++++++++++++++++++++++}
{$R-}{ RANGE CHECKING OFF	   }
{$S-}{ STACK OVERFLOW CHECKING OFF }
{++++++++++++++++++++++++++++++++++}


PROCEDURE INITGLOBALS;
BEGIN
  EOS	 := CHR(EOSVAL);
  newline := EOS;		{ *** 3-81 *** }
  BACKSPACE := CHR(BACKSPVAL);
  BLANK  := ' ';
  TAB	 := CHR(9);
  spacefill := FALSE;
  direction := FALSE;
  fill	 := TRUE;
  lsval  := 1;
  inval  := 0;
  rmval  := PAGWIDDEF;
  tival  := 0;
  ceval  := 0;
  ulval  := 0;
  spval  := 0;
  curpag := 0;
  newpag := 1;
  lineno := 0;
  plval  := PAGLENDEF;
  m1val  := HEMARGDEF;
  m2val  := 2;
  m3val  := 2;
  m4val  := FOMARGDEF;
  bottom := plval - m3val - m4val;
  setlength(header,0);		{ * header := ''; * }
  setlength(footer,0);		{ * footer := ''; * }
  cmdlist[CMD0] := '  ';
  cmdlist[ fi ] := 'fi';
  cmdlist[ ce ] := 'ce';
  cmdlist[ ul ] := 'ul';
  cmdlist[ ls ] := 'ls';
  cmdlist[ bp ] := 'bp';
  cmdlist[ he ] := 'he';
  cmdlist[ fo ] := 'fo';
  cmdlist[ ind] := 'in'; { ind avoids conflict with keyword in }
  cmdlist[ rm ] := 'rm';
  cmdlist[ ti ] := 'ti';
  cmdlist[ nf ] := 'nf';
  cmdlist[ sp ] := 'sp';
  cmdlist[ pl ] := 'pl';
  cmdlist[ br ] := 'br';
  cmdlist[ sf ] := 'sf';
  cmdlist[UNKN] := 'zz';
  outp := 0;
  outw := 0;
  outwds := 0;
END;


PROCEDURE DOCOMMAND(cmdline:buffer); EXTERNAL;


PROCEDURE DOTEXT(textline:BUFFER); EXTERNAL;


{
	Main program kformat
}
BEGIN {$C+}{ allow control-c checking only in main program }
  STDOPEN;
  INITGLOBALS;
  WHILE not eof(stdin) and not xeof do
    BEGIN
      gets(inbuf);
      IF inbuf[1] = COMNDFLAG THEN
	DOCOMMAND(inbuf)
      ELSE
	DOTEXT(inbuf);
    END;
  IF ( lineno>0 ) THEN DOCOMMAND('.sp 32000  ');
END. {kformat}

