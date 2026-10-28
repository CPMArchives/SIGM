
program pascals(input,output);
{author:
	n. wirth, e. t. h. ch-8092 zurich, 1.3.76}
{modified:
 	m.ben-ari, tel aviv univ., 1980}
{modified for Pascal/MT+ V.5.5 : 
	m. haberler, university of economics / vienna, 1983}

label
   99;

const
   nkw	= 26;		{no. of key words}
   alng = 10;		{no. of significant chars in indentifiers}
   llng = 121;		{inputline lenght}
   kmax = 15;		{max no. of significant digitis}
   tmax = 70;		{size	of table}
   bmax = 20;		{size	of block-table}
   amax = 10;		{size	of array table}
   cmax = 500;		{size	of code}
   lmax = 7;		{maximum level}
   smax = 150;		{size	of string table}
   omax = 63;		{highest order code}
   xmax = 32767;	{2**15 - 1}
   nmax = maxint;
   lineleng = 132;	{output line lenght}
   linelimit =	400;	{max lines to	print}
   stmax = 2800;	{stacksize}
   stkincr = 200;	{stacksize for	each process}
   pmax = 7;		{max concurrent processes}

{ interpreter	declarations }

   stepmax = 8;		{max steps befors process switch}
   tru	= 1;		{integer value of true}
   fals = 0;		{integer value of false}
   charl = 0;		{lowest character ordinal}
   charh = 255;		{highest character ordinal}

type
   pstrg  = ^string;
   fntyp  = string[16];
   symbol =
      (intcon,	charcon, string, notsy,	plus, minus, times, idiv, imod,
	andsy, orsy, eql, neq, geq, gtr, lss, leq, lparent, rparent,
	lbrack,	rbrack,	comma, semicolon, period, colon, becomes, constsy
	, typesy, varsy, functionsy, proceduresy, arraysy, programsy,
	ident, beginsy,	ifsy, repeatsy,	whilesy, forsy,	endsy, elsesy,
	untilsy, ofsy, dosy, tosy, thensy);
   index = - xmax .. +	xmax;
   alfa = packed array
      [1.. alng] of char;
   object =
      (konstant, variable, type1, prozedure, funktion);
   types =
      (notyp, ints, bools, chars, arrays);
   er =
      (erid, ertyp, erkey, erpun, erpar, ernf,	erdup, erch, ersh, erln);
   symset = set of symbol;
   typset = set of types;
   item = record
	      typ: types;
	      ref: index;
	   end;
   order = packed record
		      f: - omax	.. + omax;
		      x: - lmax	.. + lmax;
		      y: - nmax	.. + nmax;
		   end;
   ptype = 0..pmax;		{index over processes}

var
   ptr: pstrg;
   sfn: fntyp;	{ variables to  retrieve command line args (source file name)}
   sy:	symbol;		{last	symbol read by insymbol}
   id:	alfa;		{identifier freom insymbol}
   inum: integer;	{integer from insymbol}
   rnum: real;		{real	number from insymbol}
   sleng: integer;	{string length}
   ch:	char;		{last	character read from source program}
   line: array
      [1.. llng] of char;
   cc:	integer;	{character counter}
   lc:	integer;	{program location counter}
   ll:	integer;	{length of current line}
   errs: set of er;
   errpos: integer;
   progname: alfa;
   skipflag: boolean;
   constbegsys, typebegsys, blockbegsys, facbegsys, statbegsys: symset;
   key: array
      [1.. nkw] of alfa;
   ksy: array
      [1.. nkw] of symbol;
   sps: array
      [char]	of symbol;		{special aymbols}
   t, a, b, sx, c1, c2: integer;	{indices to tables}
   stantyps: typset;
   display: array
      [0.. lmax] of integer;		
   tab: array
      [0.. tmax] of 			{identifier table}
   packed record
	      name: alfa;
	      link: index;
	      obj: object;
	      typ: types;
	      ref: index;
	      normal: boolean;
	      lev: 0.. lmax;
	      adr: integer;
	   end;
   atab: array
      [1.. amax] of 			{array table}
   packed record
	      inxtyp, eltyp: types;
	      elref, low, high,	elsize,	size: index;
	   end;
   btab: array
      [1..bmax] of 			{block-table}
   packed record
	      last, lastpar, psize, vsize: index
	   end;
   stab: packed array
      [0.. smax] of char;		{string table}
   code: array
      [0.. cmax] of order;
   command : char;


external function @cmd:pstrg;  { returns CP/M command line tail }

{ contents of initialization overlay }

external [1] procedure init_reserved_words;
external [1] procedure init_predefined_identifiers;


{ contents of compiler overlay }

external [2] procedure nextch;
external [2] procedure errormsg;
external [2] procedure emit(fct : integer);
external [2] procedure error(n: er);
external [2] procedure fatal(n:integer);
external [2] procedure insymbol;
external [2] procedure block(fsys: symset; isfun: boolean; level: integer);

{ interpreter overlay }

external [3] procedure interpret;


begin { main program }

   writeln('Concurrent Pascal-S compiler');
{ get command line tail & open input file }
   ptr := @cmd;
   sfn := ptr^;
   assign(input,sfn);
   reset(input);
   init_reserved_words;
   constbegsys	:= [plus, minus, intcon, charcon, ident];
   typebegsys := [ident, arraysy];
   blockbegsys	:= [constsy, typesy, varsy, proceduresy, functionsy,
      beginsy];
   facbegsys := [intcon, charcon, ident, lparent, notsy];
   statbegsys := [beginsy, ifsy, whilesy, repeatsy, forsy];
   stantyps :=	[notyp, ints, bools, chars];
   lc := 0;
   ll := 0;
   cc := 0;
   ch := ' ';
   errpos := 0;
   errs := [];
   t := - 1;
   a := 0;
   b := 1;
   sx := 0;
   c2 := 0;
   init_predefined_identifiers;
   insymbol;
   display[0] := 1;
   skipflag :=	false;
   if sy <> programsy
   then
      error(erkey)
   else
      begin
	  insymbol;
	  if sy	<> ident
	  then
	     error(erid)
	  else
	     begin
		progname := id;
		insymbol;
	     end
      end;
   with btab[1] do
      begin
	  last := t;
	  lastpar := 1;
	  psize	:= 0;
	  vsize	:= 0
      end;
   block(blockbegsys +	statbegsys, false, 1);
   if sy <> period then
      error(erpun);
   if btab[2].vsize > stmax - stkincr * pmax	then
      error(erln);
   emit(31);		{halt}
{  if not eof(input) then
      readln; }
   if errs = []
   then
      begin
	  assign(input,'CON:');
	  repeat
            reset(input);
	    writeln;	
	    interpret;
	    writeln;writeln('enter  e  to exit, anything else to continue');
	    if eof(input) then reset(input);
	    readln(command);	
	  until (command = 'e') or (command = 'E');
      end
   else
      errormsg;
99: writeln
end {pascals}.
