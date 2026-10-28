
module symbol_table_initialization;

{$I global.inc}		{ include global constants & types }

var
   key: external array
      [1.. nkw] of alfa;
   ksy: external array
      [1.. nkw] of symbol;
   sps: external array
      [char]	of symbol;			{special symbols}

   t, a, b, sx, c1, c2: external integer;	{identifier table}
   tab: external  array
      [0.. tmax] of 				{identifier table}
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

procedure enterstandardids(x0: alfa; x1: object; x2: types; x3: integer);

   begin
      t := t +	1;
      with tab[t] do
	  begin
	     name := x0;
	     link := t - 1;
	     obj := x1;
	     typ := x2;
	     ref := 0;
	     normal := true;
	     lev := 0;
	     adr := x3
	  end
   end	{enter};


procedure init_reserved_words;

begin
   key[1] :=	'and       ';
   key[2] :=	'array	   ';
   key[3] :=	'begin	   ';
   key[4] :=	'cobegin   ';
   key[5] :=	'coend	   ';
   key[6] :=	'const	   ';
   key[7] :=	'div	   ';
   key[8] :=	'do	   ';
   key[9] :=	'else	   ';
   key[10] :=   'end       ';
   key[11] :=   'for       ';
   key[12] :=   'function  ';
   key[13] :=   'if        ';
   key[14] :=   'mod       ';
   key[15] :=   'not       ';
   key[16] :=   'of        ';
   key[17] :=   'or        ';
   key[18] :=   'procedure ';
   key[19] :=   'program   ';
   key[20] :=   'repeat    ';
   key[21] :=   'then	   ';
   key[22] :=   'to	   ';
   key[23] :=   'type	   ';
   key[24] :=   'until	   ';
   key[25] :=   'var	   ';
   key[26] :=   'while     ';
   ksy[1] :=	andsy;
   ksy[2] :=	arraysy;
   ksy[3] :=	beginsy;
   ksy[4] :=	beginsy;
   ksy[5] :=	endsy;
   ksy[6] :=	constsy;
   ksy[7] :=	idiv;
   ksy[8] :=	dosy;
   ksy[9] :=	elsesy;
   ksy[10] := endsy;
   ksy[11] := forsy;
   ksy[12] := functionsy;
   ksy[13] := ifsy;
   ksy[14] := imod;
   ksy[15] := notsy;
   ksy[16] := ofsy;
   ksy[17] := orsy;
   ksy[18] := proceduresy;
   ksy[19] := programsy;
   ksy[20] := repeatsy;
   ksy[21] := thensy;
   ksy[22] := tosy;
   ksy[23] := typesy;
   ksy[24] := untilsy;
   ksy[25] := varsy;
   ksy[26] := whilesy;
   sps['+'] := plus;
   sps['-'] := minus;
   sps['('] := lparent;
   sps[')'] := rparent;
   sps['='] := eql;
   sps[','] := comma;
   sps['[']:=lbrack;	 
   sps[']']:=rbrack;
   sps['#'] := neq;
   sps['&'] := andsy;
   sps[';'] := semicolon;
   sps['*'] := times;
end;

procedure init_predefined_identifiers;

begin
   enterstandardids('          ',variable, notyp, 0);	{sentinel}
   enterstandardids('false     ',konstant, bools, 0);
   enterstandardids('true      ',konstant, bools, 1);
   enterstandardids('char      ',type1, chars, 1);
   enterstandardids('boolean   ',type1, bools, 1);
   enterstandardids('integer   ',type1, ints, 1);
   enterstandardids('semaphore ',type1, ints, 1);
   enterstandardids('eof       ',funktion, bools, 17);
   enterstandardids('eoln      ',funktion, bools, 18);
   enterstandardids('read      ',prozedure, notyp, 1);
   enterstandardids('readln    ',prozedure, notyp, 2);
   enterstandardids('write     ',prozedure, notyp, 3);
   enterstandardids('writeln   ',prozedure, notyp, 4);
   enterstandardids('wait      ',prozedure, notyp, 5);
   enterstandardids('signal    ',prozedure, notyp, 6);
   enterstandardids('          ',prozedure, notyp, 0);
end;

modend.
