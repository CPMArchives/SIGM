{$S+}  {recursion on}

{$K1} {$K2} {$K7} {$K12} {$K13} {$K14}  { reduce symbol table space }

module compiler;

{$I global.inc}

var
   sy:	external symbol;		{last symbol read by insymbol}
   id:	external alfa;			{identifier from insymbol}
   inum: external integer;		{integer from insymbol}
   rnum: external real;			{real number from insymbol}
   sleng: external integer;		{string length}
   ch:  external char;			{last character read from source program}
   line: external array
      [1.. llng] of char;
   cc:	external integer;		{character counter}
   lc:  external integer;		{program location counter}
   ll:	external integer;		{length of current line}
   errs: external set of er;
   errpos: external integer;
   progname: external  alfa;
   skipflag: external  boolean;
   constbegsys, typebegsys, blockbegsys, facbegsys, statbegsys: external symset;
   key: external array
      [1.. nkw] of alfa;
   ksy: external array
      [1.. nkw] of symbol;
   sps: external array
      [char]	of symbol;		{special aymbols}
   t, a, b, sx, c1, c2: external integer;	{indices to tables}
   stantyps: external typset;
   display: external array
      [0.. lmax] of integer;		{identifier table}
   tab: external array
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
   atab: external  array
      [1.. amax] of 			{array table}
   packed record
	      inxtyp, eltyp: types;
	      elref, low, high,	elsize,	size: index;
	   end;
   btab: external array
      [1..bmax] of 			{block-table}
   packed record
	      last, lastpar, psize, vsize: index
	   end;
   stab: external  packed array
      [0.. smax] of char;		{string table}
   code: external array
      [0.. cmax] of order;
   tabchar  : char;			{holds tab char for scanner }

procedure abort;
{ return to CP/M }

begin 
  inline("JMP/ $00/ $00)
end;
 
procedure errormsg;

   var
      k: er;
      msg: array
	  [er] of alfa;

   begin
      msg[erid] :=  'identifier';
      msg[ertyp] := 'type      ';
      msg[erkey] := 'keyword   ';
      msg[erpun] := 'punctuatio';
      msg[erpar] := 'parameter ';
      msg[ernf] :=  'not found ';
      msg[erdup] := 'duplicate ';
      msg[erch] :=  'character ';
      msg[ersh] :=  'too short ';
      msg[erln] :=  'too long  ';
      writeln('compilation errors');
      writeln;
      writeln('key words');
      for k :=	erid to	erln do
	  if k in errs then
	     writeln(ord(k), ' ', msg[k])
   end	{errormsg};


procedure endskip;

   begin {underline skips part of input}
      while errpos < cc do
	  begin
	     write('-');
	     errpos := errpos +	1
	  end;
      skipflag	:= false
   end	{endskip};


procedure nextch;

{read	next character;	process	line end}

   begin
      if cc = ll
      then
	  begin
	     if	eof(input) then
		begin
		   writeln;
		   writeln('program incomplete');
		   errormsg;
		   {goto	99}
		   abort;
		end;
	     if	errpos <> 0 then
		begin
		   if skipflag then
		      endskip;
		   writeln;
		   errpos := 0
		end;
	     write(lc: 5, ' ');
	     ll	:= 0;
 	     cc	:= 0;
	     while not eoln(input) do
		begin
		   ll := ll + 1;
		   read(ch);
		   write(ch);
		   line[ll] := ch
		end;
	     writeln;
	     ll	:= ll +	1;
	     read(line[ll]);
	  end;
      cc := cc	+ 1;
      ch := line[cc];
   end	{nextch};


procedure error(n: er);

   begin
      if errpos = 0 then
	  write('****');
      if cc > errpos then
	  begin
	     write(' ':	cc - errpos, '^', ord(n): 2);
	     errpos := cc + 3;
	     errs := errs + [n]
	  end
   end	{error};


procedure fatal(n: integer);

   var
      msg: array
	  [1..6] of alfa;

   begin
      writeln;
      errormsg;
      msg[1]	:= 'identifier';
      msg[2]	:= 'procedures';
      msg[3]	:= 'string    ';
      msg[4]	:= 'arrays    ';
      msg[5]	:= 'level     ';
      msg[6]	:= 'code      ';
      writeln('compiler table for ', msg[n],	' is too small');
      { goto 99;  terminate compilation}
      abort;
   end	{fatal};


procedure insymbol;

{reads next symbol}

   label
      1, 2, 3;

   var
      i, j, k,	e: integer;

   begin {insymbol}
   1: while ch	in [' ',tabchar] do
	  nextch;
      case ch of
 	  'a', 'b', 'c', 'd', 'e', 'f',	'g', 'h', 'i', 'j', 'k', 'l', 'm'
	     , 'n', 'o', 'p', 'q', 'r',	's', 't', 'u', 'v', 'w', 'x', 'y'
	     , 'z':
	     begin {identifier	or wordsymbol}
		k := 0;
		id := '		 ';
		repeat
		   if k	< alng then
		      begin
			 k := k	+ 1;
			 id[k] := ch
		      end;
		   nextch
		until not (ch in [
		'a' .. 'z', '0'	.. '9']);
		i := 1;
		j := nkw;		{binary search}
		repeat
		   k :=	(i + j)	div 2;
		   if id <= key[k] then
		      j	:= k - 1;
		   if id >= key[k] then
		      i	:= k + 1
		until i	> j;
		if i - 1 > j
		then
		   sy := ksy[k]
		else
		   sy := ident
	     end;
	  '0', '1', '2', '3', '4', '5',	'6', '7', '8', '9':
	     begin {number}
		k := 0;
		inum :=	0;
		sy := intcon;
		repeat
		   inum	:= inum	* 10 + ord(ch) - ord('0');
		   k :=	k + 1;
		   nextch
		until not (ch in [
		'0' .. '9']);
		if (k >	kmax) or (inum > nmax) then
		   begin
		      error(erln);
		      inum := 0;
		      k	:= 0
		   end;
	     end;
	  ':' {, col}:
	     begin
		nextch;		{mod mh}
		if ch =	'='
		then
		   begin
		      sy := becomes;
		      nextch
		   end
		else
		   sy := colon
	     end;
	  '<':
	     begin
		nextch;
		if ch =	'='
		then
		   begin
		      sy := leq;
		      nextch
		   end
		else
		   if ch = '>'
		   then
		      begin
			 sy := neq;
			 nextch
		      end
		   else
		      sy := lss
	     end;
	  '>':
	     begin
		nextch;
		if ch =	'='
		then
		   begin
		      sy := geq;
		      nextch
		   end
		else
		   sy := gtr
	     end;
	  '.':
	     begin
		nextch;
		if ch =	'.'
		then
		   begin
		      sy := colon;
		      nextch
		   end
		else
		   if ch = ')'
		   then
		      begin
			 sy := rbrack;
			 nextch
		      end
		   else
		      sy := period
	     end;
 	  '''':
	     begin
		k := 0;
	     2:	nextch;
		if ch =	'''' then
		   begin
		      nextch;
		      if ch <> '''' then
			 goto 3
		   end;
		if sx +	k = smax then
		   fatal(3);
		stab[sx + k] := ch;
		k := k + 1;
		if cc =	1
		then
		   begin {end of line}
		      k	:= 0;
		   end
		else
		   goto	2;
	     3:	if k = 1
		then
		   begin
		      sy := charcon;
		      inum := ord(stab[sx])
		   end
		else
		   if k	= 0
		   then
		      begin
			 error(ersh);
			 sy := charcon;
			 inum := 0
		      end
		   else
		      begin
			 sy := string;
			 inum := sx;
			 sleng := k;
			 sx := sx + k
		      end
	     end;
	  '(':
	     begin
		nextch;
		if ch =	'.'
		then
		   begin
		      sy := lbrack;
		      nextch
		   end
		else
		   if ch <> '*'
		   then
		      sy := lparent
		   else
		      begin {comment}
			 nextch;
			 repeat
			    while ch <>	'*' do
			       nextch;
			    nextch
			 until ch = ')';
			 nextch;
			 goto 1
		      end
	     end;
	  '+', '-', '*', ')', '=', ',',	';','[',']' :
	     begin
		sy := sps[ch];
		nextch
	     end;
	  '$', '!', '@', '^', '?',
     {'""',}
           '&', '/','\' :
	     begin
		error(erch);
		nextch;
		goto 1
	     end
      end
   end	{insymbol};


procedure enterstandardids(x0: alfa; x1: object; x2: types; x3: integer);

   begin
      t := t +	1;
{enter standard identifier}
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


procedure enterarray(tp: types; l, h: integer);

   begin
      if l > h	then
	  error(ertyp);
      if (abs(l) > xmax) or (abs(h) > xmax) then
	  begin
	     error(ertyp);
	     l := 0;
	     h := 0;
	  end;
      if a = amax
      then
	  fatal(4)
      else
	  begin
	     a := a + 1;
	     with atab[a] do
		begin
		   inxtyp := tp;
		   low := l;
		   high	:= h
		end
	  end {enterarray};
   end	{enterarray};

{fix mh}


procedure enterblock;

   begin
      if b = bmax
      then
	  fatal(2)
      else
	  begin
	     b := b + 1;
	     btab[b].last := 0;
	     btab[b].lastpar := 0
	  end
   end	{enterblock};


procedure emit(fct: integer);

   begin
      if lc = cmax then
	  fatal(6);
      code[lc].f := fct;
      lc := lc	+ 1;
   end	{emit};


procedure emit1(fct, b: integer);

   begin
      if lc = cmax then
	  fatal(6);
      with code[lc] do
	  begin
	     f := fct;
	     y := b
	  end;
      lc := lc	+ 1;
   end	{emit1};


procedure emit2(fct, a, b: integer);

   begin
      if lc = cmax then
	  fatal(6);
      with code[lc] do
	  begin
	     f := fct;
	     x := a;
	     y := b
	  end;
      lc := lc	+ 1;
   end	{emit2};


procedure block(fsys: symset; isfun: boolean; level: integer);

   type
      conrec =	record
		   tp: types;
		   i: integer
		end;

   var
      dx: integer;	{data	allocation index}
      prt: integer;	{t-index of this procedure}
      prb: integer;	{b-index of this procedure}
      x: integer;


   procedure skip(fsys: symset; n: er);

      begin
	  error(n);
	  skipflag := true;
	  while	not (sy	in fsys) do
	     insymbol;
	  if skipflag then
	     endskip;
      end {skip};


   procedure test(s1, s2: symset; n: er);

      begin
	  if not (sy in	s1) then
	     skip(s1 + s2, n)
      end {test};


   procedure testsemicolon;

      begin
	  if sy	= semicolon
	  then
	     insymbol
	  else
	     error(erpun);
	  test([ident] + blockbegsys,	fsys, erkey);
      end {testsemicolon};


    procedure  enter(id:	alfa; k: object);

      var
	  j, l:	integer;

      begin
	  if t = tmax
	  then
	     fatal(1)
	  else
	     begin
		tab[0].name := id;
		j := btab[display[level]].last;
		l := j;
		while tab[j].name <> id do
		   j :=	tab[j].link;
		if j <>	0
		then
		   error(erdup)
		else
		   begin
		      t	:= t + 1;
		      with tab[t] do
			 begin
			    name := id;
			    link := l;
			    obj	:= k;
			    typ	:= notyp;
			    ref	:= 0;
			    lev	:= level;
			    adr	:= 0
			 end;
		      btab[display[level]].last := t
		   end
	     end
      end {enter};


   function loc(id: alfa): integer;

      var
	  i, j:	integer;	{locate id in	table}

      begin
	  i := level;
	  tab[0].name	:= id;	{sentinel}
	  repeat
	     j := btab[display[i]].last;
	     while tab[j].name <> id do
		j := tab[j].link;
	     i := i - 1;
	  until	(i < 0)	or (j <> 0);
	  if j = 0 then
	     error(ernf);
	  loc := j
      end {loc};


   procedure entervariable;

      begin
	  if sy	= ident
	  then
	     begin
		enter(id, variable);
		insymbol
	     end
	  else
	     error(erid)
      end {entervariable};


   procedure constant(fsys: symset; var c: conrec);

      var
	  x, sign: integer;

      begin
	  c.tp := notyp;
	  c.i := 0;
	  test(constbegsys, fsys, erkey);
	  if sy	in constbegsys
	  then
	     begin
		if sy =	charcon
		then
		   begin
		      c.tp := chars;
		      c.i := inum;
		      insymbol
		   end
		else
		   begin
		      sign := 1;
		      if sy in [plus, minus] then
			 begin
			    if sy = minus then
			       sign := - 1;
			    insymbol
			 end;
		      if sy = ident
		      then
			 begin
			    x := loc(id);
			    if x <> 0 then
			       if tab[x].obj <> konstant
			       then
				  error(ertyp)
			       else
				  begin
				     c.tp := tab[x].typ;
				     c.i := sign * tab[x].adr
				  end;
			    insymbol
			 end
		      else
			 if sy = intcon
			 then
			    begin
			       c.tp := ints;
			       c.i := sign * inum;
			       insymbol
			    end
			 else
			    skip(fsys, erkey)
		   end;
		test(fsys, [], erkey);
	     end
      end {constant};


   procedure typ(fsys:	symset;	var tp:	types; var rf, sz: integer);

      var
	  x: integer;
	  eltp:	types;
	  elrf:	integer;
	  elsz,	offset,	t0, t1:	integer;


      procedure arraytyp(var aref, arsz: integer);

	  var
	     eltp: types;
	     low, high:	conrec;
	     elrf, elsz: integer;

	  begin
	     constant([colon, rbrack, ofsy] +	fsys, low);
	     if	sy = colon
	     then
		insymbol
	     else
		error(erpun);
	     constant([rbrack,	comma, ofsy] +	fsys, high);
	     if	high.tp	<> low.tp then
		begin
		   error(ertyp);
		   high.i := low.i
		end;
	     enterarray(low.tp,	low.i, high.i);
	     aref := a;
	     if	sy = comma
	     then
		begin
		   insymbol;
		   eltp	:= arrays;
		   arraytyp(elrf, elsz)
		end
	     else
		begin
		   if sy = rbrack
		   then
		      insymbol
		   else
		      error(erpun);
		   if sy = ofsy
		   then
		      insymbol
		   else
		      error(erkey);
		   typ(fsys, eltp, elrf, elsz)
		end;
	     with atab[aref] do
		begin
		   arsz	:= (high - low + 1) * elsz;
		   size	:= arsz;
		   eltyp := eltp;
		   elref := elrf;
		   elsize := elsz
		end;
	  end {arraytyp};


      begin {typ}
	  tp :=	notyp;
	  rf :=	0;
	  sz :=	0;
	  test(typebegsys, fsys, erid);
	  if sy	in typebegsys
	  then
	     begin
		if sy =	ident
		then
		   begin
		      x	:= loc(id);
		      if x <> 0	then
			 with tab[x] do
			    if obj <> type1
			    then
			       error(ertyp)
			    else
			       begin
				  tp :=	typ;
				  rf :=	ref;
				  sz :=	adr;
				  if tp	= notyp	then
				     error(ertyp)
			       end;
		      insymbol
		   end
		else
		   if sy = arraysy
		   then
		      begin
			 insymbol;
			 if sy = lbrack
			 then
			    insymbol
			 else
			    error(erpun);
			 tp := arrays;
			 arraytyp(rf, sz)
		      end
		   else
		      test(fsys, [], erkey);
	     end
      end {typ};


   procedure parameterlist;	{formal parameter list}

      var
	  tp: types;
	  rf, sz, x, t0: integer;
	  valpar: boolean;

      begin
	  insymbol;
	  tp :=	notyp;
	  rf :=	0;
	  sz :=	0;
	  test([ident,	varsy], fsys +	[rparent], erpar);
	  while	sy in [ident, varsy] do
	     begin
		if sy <> varsy
		then
		   valpar := true
		else
		   begin
		      insymbol;
		      valpar :=	false
		   end;
		t0 := t;
		entervariable;
		while sy = comma do
		   begin
		      insymbol;
		      entervariable;
		   end;
		if sy =	colon
		then
		   begin
		      insymbol;
		      if sy <> ident
		      then
			 error(erid)
		      else
			 begin
			    x := loc(id);
			    insymbol;
			    if x <> 0 then
			       with tab[x] do
				  if obj <> type1
				  then
				     error(ertyp)
				  else
				     begin
					tp := typ;
					rf := ref;
					if valpar
					then
					   sz := adr
					else
					   sz := 1
				     end;
			 end;
		      test([semicolon,	rparent], [comma, ident] +
			 fsys, erpun)
		   end
		else
		   error(erpun);
		while t0 < t do
		   begin
		      t0 := t0 + 1;
		      with tab[t0] do
			 begin
			    typ	:= tp;
			    ref	:= rf;
			    normal := valpar;
			    adr	:= dx;
			    lev	:= level;
			    dx := dx + sz
			 end
		   end;
		if sy <> rparent then
		   begin
		      if sy = semicolon
		      then
			 insymbol
		      else
			 error(erpun);
		      test([ident, varsy], [rparent] + fsys, erkey);
		   end
	     end;
	  if sy	= rparent
	  then
	     begin
		insymbol;
		test([semicolon, colon], fsys, erkey);
	     end
	  else
	     error(erpun)
      end {parameterlist};


   procedure constdeclaration;

      var
	  c: conrec;

      begin
	  insymbol;
	  test([ident], blockbegsys, erid);
	  while	sy = ident do
	     begin
		enter(id, konstant);
		insymbol;
		if sy =	eql
		then
		   insymbol
		else
		   error(erpun);
		constant([semicolon, comma, ident] + fsys, c);
		tab[t].typ :=	c.tp;
		tab[t].ref :=	0;
		tab[t].adr :=	c.i;
		testsemicolon
	     end
      end {constdeclaration};


   procedure typedeclaration;

      var
	  tp: types;
	  rf, sz, t1: integer;

      begin
	  insymbol;
	  test([ident], blockbegsys, erid);
	  while	sy = ident do
	     begin
		enter(id, type1);
		t1 := t;
		insymbol;
		if sy =	eql
		then
		   insymbol
		else
		   error(erpun);
		typ([semicolon, comma,	ident]	+ fsys,	tp, rf,	sz);
		with tab[t1] do
		   begin
		      typ := tp;
		      ref := rf;
		      adr := sz
		   end;
		testsemicolon
	     end
      end {typedeclaration};


   procedure vardeclaration;

      var
	  t0, t1, rf, sz: integer;
	  tp: types;

      begin
	  insymbol;
	  while	sy = ident do
	     begin
		t0 := t;
		entervariable;
		while sy = comma do
		   begin
		      insymbol;
		      entervariable;
		   end;
		if sy =	colon
		then
		   insymbol
		else
		   error(erpun);
		t1 := t;
		typ([semicolon, comma,	ident]	+ fsys,	tp, rf,	sz);
		while t0 < t1 do
		   begin
		      t0 := t0 + 1;
		      with tab[t0] do
			 begin
			    typ	:= tp;
			    ref	:= rf;
			    lev	:= level;
			    adr	:= dx;
			    normal := true;
			    dx := dx + sz
			 end
		   end;
		testsemicolon
	     end
      end {variab|edeclaration};


   procedure procdeclaration;

      var
	  isfun: boolean;

      begin
	  isfun	:= sy =	functionsy;
	  insymbol;
	  if sy	<> ident then
	     begin
		error(erid);
		id := '		 ';
	     end;
	  if isfun
	  then
	     enter(id, funktion)
	  else
	     enter(id, prozedure);
	  tab[t].normal := true;
	  insymbol;
	  block([semicolon] +	fsys, isfun, level + 1);
	  if sy	= semicolon
	  then
	     insymbol
	  else
	     error(erpun);
	  emit(32 + ord(isfun))	{exit}
      end {proceduredeclaration};



   procedure statement(fsys: symset);

      var
	  i: integer;
	  x: item;


      procedure expression(fsys: symset; var x: item);
	  forward;


      procedure selector(fsys:	symset;	var v: item);

	  var
	     x:	item;
	     a,	j: integer;

	  begin
	     if	sy <> lbrack then
		error(ertyp);
	     repeat
		insymbol;
		expression(fsys	+ [comma, rbrack], x);
		if v.typ <> arrays
		then
		   error(ertyp)
		else
		   begin
		      a	:= v.ref;
		      if atab[a].inxtyp <> x.typ
		      then
			 error(ertyp)
		      else
			 emit1(21, a);
		      v.typ := atab[a].eltyp;
		      v.ref := atab[a].elref
		   end
	     until sy <> comma;
	     if	sy = rbrack
	     then
		insymbol
	     else
		error(erpun);
	     test(fsys,	[], erkey);
	  end {selector};


      procedure call(fsys: symset; i: integer);

	  var
	     x:	item;
	     lastp, cp,	k: integer;

	  begin
	     emit1(18, i);		{markstack}
	     lastp := btab[tab[i].ref].lastpar;
	     cp	:= i;
	     if	sy = lparent
	     then
		begin			 {actual parameter list}
		   repeat
		      insymbol;
		      if cp >= lastp
		      then
			 error(erpar)
		      else
			 begin
			    cp := cp + 1;
			    if tab[cp].normal
			    then
			       begin 	{value parameter}
				  expression(fsys + [comma, colon,
				     rparent],	x);
				  if x.typ = tab[cp].typ
				  then
				     begin
					if x.ref <> tab[cp].ref
					then
					   error(ertyp)
					else
					   if x.typ = arrays then
					      emit1(22,	atab[x.ref].
						 size)
				     end
				  else
				     if	x.typ <> notyp then
					error(ertyp);
			       end
			    else
			       begin	 {variable	parameter}
				  if sy	<> ident
				  then
				     error(erid)
				  else
				     begin
					k := loc(id);
					insymbol;
					if k <>	0
					then
					   begin
					      if tab[k].obj <> variable
					      then
						 error(erpar);
					      x.typ := tab[k].typ;
					      x.ref := tab[k].ref;
					      if tab[k].normal
					      then
						 emit2(0, tab[k].lev,
						    tab[k].adr)
					      else
						 emit2(1, tab[k].lev,
						    tab[k].adr);
					      if sy = lbrack then
						 selector(fsys + [comma,
						    colon, rparent], x);
					      if (x.typ	<> tab[cp].typ)
						 or (x.ref <> tab[cp].
						 ref)
					      then
						 error(ertyp)
					   end
				     end
			       end
			 end;
		      test([comma, rparent], fsys, erkey);
		   until sy <> comma;
		   if sy = rparent
		   then
		      insymbol
		   else
		      error(erpun)
		end;
	     if	cp < lastp then
		error(erpar);		{too few actual parameters}
	     emit1(19, btab[tab[i].ref].psize - 1);
	     if	tab[i].lev < level then
		emit2(3, tab[i].lev, level)
	  end {call};


      function	resulttype(a, b: types): types;

	  begin
	     if	(a > ints) or (b > ints)
	     then
		begin
		   error(ertyp);
		   resulttype := notyp
		end
	     else
		if (a =	notyp) or (b = notyp)
		then
		   resulttype := notyp
		else
		   resulttype := ints
	  end {resulttyp};


      procedure expression;

	  var
	     y:	item;
	     op: symbol;


	  procedure simpleexpression(fsys: symset; var x: item);

	     var
		y: item;
		op: symbol;


	     procedure term(fsys: symset; var x: item);

		var
		   y: item;
		   op: symbol;
		   ts: typset;


		procedure factor(fsys: symset; var x: item);

		   var
		      i, f: integer;

		   begin {factor}
		      x.typ := notyp;
		      x.ref := 0;
		      test(facbegsys, fsys, erpun);
		      while sy in facbegsys do
			 begin
			    if sy = ident
			    then
			       begin
				  i := loc(id);
				  insymbol;
				  with tab[i]	do
				     case obj of
					konstant:
					   begin
					      x.typ := typ;
					      x.ref := 0;
					      emit1(24,	adr)
					   end;
					variable:
					   begin
					      x.typ := typ;
					      x.ref := ref;
					      if sy = lbrack
					      then
						 begin
						    if normal
						    then
						       f := 0
						    else
						       f := 1;
						    emit2(f, lev, adr);
						    selector(fsys, x);
						    if x.typ in	stantyps
						    then
						       emit(34)
						 end
					      else
						 begin
						    if x.typ in	stantyps
						    then
						       if normal
						       then
							  f := 1
						       else
							  f := 2
						    else
						       if normal
						       then
							  f := 0
						       else
							  f := 1;
						    emit2(f, lev, adr)
						 end
					   end;
					type1, prozedure:
					   error(ertyp);
					funktion:
					   begin
					      x.typ := typ;
					      if lev <>	0
					      then
						 call(fsys, i)
					      else
						 emit1(8, adr)
					   end
				     end {case, with}
			       end
			    else
			       if sy in	[charcon, intcon]
			       then
				  begin
				     if	sy = charcon
				     then
					x.typ := chars
				     else
					x.typ := ints;
				     emit1(24, inum);
				     x.ref := 0;
				     insymbol
				  end
			       else
				  if sy	= lparent
				  then
				     begin
					insymbol;
					expression(fsys	+ [rparent], x);
					if sy =	rparent
					then
					   insymbol
					else
					   error(erpun)
				     end
				  else
				     if	sy = notsy then
					begin
					   insymbol;
					   factor(fsys,	x);
					   if x.typ = bools
					   then
					      emit(35)
					   else
					      if x.typ <> notyp	then
						 error(ertyp)
					end;
			    test(fsys, facbegsys, erkey);
			 end {while}
		   end {factor};


		begin {term}
		   factor(fsys + [times, idiv,	imod, andsy], x);
		   while sy in [times,	idiv, imod, andsy] do
		      begin
			 op := sy;
			 insymbol;
			 factor(fsys + [times,	idiv, imod, andsy], y);
			 if op = times
			 then
			    begin
			       x.typ :=	resulttype(x.typ, y.typ);
			       if x.typ	= ints then
				  emit(57)
			    end
			 else
			    if op = andsy
			    then
			       begin
				  if (x.typ = bools) and (y.typ	= bools)
				  then
				     emit(56)
				  else
				     begin
					if (x.typ <> notyp) and	(y.typ <>
					   notyp)
					then
					   error(ertyp);
					x.typ := notyp
				     end
			       end
			    else
			       begin {op in[idiv, imod]}
				  if (x.typ = ints) and	(y.typ = ints)
				  then
				     if	op = idiv
				     then
					emit(58)
				     else
					emit(59)
				  else
				     begin
					if (x.typ <> notyp) and	(y.typ <>
					   notyp)
					then
					   error(ertyp);
					x.typ := notyp
				     end
			       end
		      end
		end {term};


	     begin {simpleexpression}
		if sy in [plus, minus]
		then
		   begin
		      op := sy;
		      insymbol;
		      term(fsys	+ [plus, minus], x);
		      if x.typ > ints
		      then
			 error(ertyp)
		      else
			 if op = minus then
			    emit(36)
		   end
		else
		   term(fsys + [plus, minus, orsy], x);
		while sy in [plus, minus, orsy] do
		   begin
		      op := sy;
		      insymbol;
		      term(fsys	+ [plus, minus, orsy], y);
		      if op = orsy
		      then
			 begin
			    if (x.typ =	bools) and (y.typ = bools)
			    then
			       emit(51)
			    else
			       begin
				  if (x.typ <> notyp) and (y.typ <> notyp)
				  then
				     error(ertyp);
				  x.typ	:= notyp
			       end
			 end
		      else
			 begin
			    x.typ := resulttype(x.typ, y.typ);
			    if x.typ = ints then
			       if op = plus
			       then
				  emit(52)
			       else
				  emit(53)
			 end
		   end
	     end {simpleexpression};


	  begin	{expression};
	     simpleexpression(fsys + [eql, neq, lss, leq, gtr,	geq], x);
	     if	sy in [eql, neq, lss, leq, gtr, geq]
	     then
		begin
		   op := sy;
		   insymbol;
		   simpleexpression(fsys, y);
		   if (x.typ in	[notyp, ints, bools, chars]) and (x.typ
		      =	y.typ)
		   then
		      case op of
			 eql:
			    emit(45);
			 neq:
			    emit(46);
			 lss:
			    emit(47);
			 leq:
			    emit(48);
			 gtr:
			    emit(49);
			 geq:
			    emit(50);
		      end
		   else
		      error(ertyp);
		   x.typ := bools
		end
	  end {expression};


      procedure assignment(lv,	ad: integer);

	  var
	     x,	y: item;
	     f:	integer;		{tab[i]. obj in [variable,prozedure]}

	  begin
	     x.typ := tab[i].typ;
	     x.ref := tab[i].ref;
	     if	tab[i].normal
	     then
		f := 0
	     else
		f := 1;
	     emit2(f, lv, ad);
	     if	sy = lbrack then
		selector([becomes, eql] + fsys, x);
	     if	sy = becomes
	     then
		insymbol
	     else
		error(erpun);
	     expression(fsys, y);
	     if	x.typ =	y.typ
	     then
		if x.typ in stantyps
		then
		   emit(38)
		else
		   if x.ref <> y.ref
		   then
		      error(ertyp)
		   else
		      if x.typ = arrays
		      then
			 emit1(23, atab[x.ref].size)
		      else
			 error(ertyp)
	  end {assignment};


      procedure compoundstatement;

	  begin
	     insymbol;
	     statement([semicolon, endsy] + fsys);
	     while sy in [semicolon] + statbegsys do
		begin
		   if sy = semicolon
		   then
		      insymbol
		   else
		      error(erpun);
		   statement([semicolon, endsy] + fsys)
		end;
	     if	sy = endsy
	     then
		insymbol
	     else
		error(erkey)
	  end {compoundstatement};


      procedure ifstatement;

	  var
	     x:	item;
	     lc1, lc2: integer;

	  begin
	     insymbol;
	     expression(fsys + [thensy, dosy], x);
	     if	not (x.typ in [bools, notyp])	then
		error(ertyp);
	     lc1 := lc;
	     emit(11);		{jmpc}
	     if	sy = thensy
	     then
		insymbol
	     else
		error(erkey);
	     statement(fsys + [elsesy]);
	     if	sy = elsesy
	     then
		begin
		   insymbol;
		   lc2 := lc;
		   emit(10);
		   code[lc1].y := lc;
		   statement(fsys);
		   code[lc2].y := lc
		end
	     else
		code[lc1].y := lc
	  end {ifstatement};


      procedure repeatstatement;

	  var
	     x:	item;
	     lc1: integer;

	  begin
	     lc1 := lc;
	     insymbol;
	     statement([semicolon, untilsy] +	fsys);
	     while sy in [semicolon] + statbegsys do
		begin
		   if sy = semicolon
		   then
		      insymbol
		   else
		      error(erpun);
		   statement([semicolon, untilsy] + fsys)
		end;
	     if	sy = untilsy
	     then
		begin
		   insymbol;
		   expression(fsys, x);
		   if not (x.typ in [bools, notyp]) then
		      error(ertyp);
		   emit1(11, lc1)
		end
	     else
		error(erkey)
	  end {repeatstatement};


      procedure whilestatement;

	  var
	     x:	item;
	     lc1, lc2: integer;

	  begin
	     insymbol;
	     lc1 := lc;
	     expression(fsys + [dosy], x);
	     if	not (x.typ in [bools, notyp])	then
		error(ertyp);
	     lc2 := lc;
	     emit(11);
	     if	sy = dosy
	     then
		insymbol
	     else
		error(erkey);
	     statement(fsys);
	     emit1(10, lc1);
	     code[lc2].y := lc
	  end {whilestatement};


      procedure forstatement;

	  var
	     cvt: types;
	     x:	item;
	     i,	lc1, lc2: integer;

	  begin
	     insymbol;
	     if	sy = ident
	     then
		begin
		   i :=	loc(id);
		   insymbol;
		   if i	= 0 then
		      cvt := tab[i].typ;
		   if tab[i].obj = variable
		   then
		      begin
			 cvt :=	tab[i].typ;
			 if not	tab[i].normal
			 then
			    error(ertyp)
			 else
			    emit2(0, tab[i].lev, tab[i].adr);
			 if not	(cvt in	[notyp, ints, bools, chars])
			 then
			    error(ertyp)
		      end
		   else
		      begin
			 error(ertyp);
			 cvt :=	ints
		      end
		end
	     else
		skip([becomes,	tosy, dosy] + fsys, erid);
	     if	sy = becomes
	     then
		begin
		   insymbol;
		   expression([tosy, dosy] + fsys, x);
		   if x.typ <> cvt then
		      error(ertyp);
		end
	     else
		skip([tosy, dosy] + fsys, erpun);
	     if	sy = tosy
	     then
		begin
		   insymbol;
		   expression([dosy] + fsys, x);
		   if x.typ <> cvt then
		      error(ertyp)
		end
	     else
		skip([dosy] +	fsys, erkey);
	     lc1 := lc;
	     emit(14);
	     if	sy = dosy
	     then
		insymbol
	     else
		error(erkey);
	     lc2 := lc;
	     statement(fsys);
	     emit1(15, lc2);
	     code[lc1].y := lc
	  end {forstatement};


      procedure standproc(n: integer);

	  var
	     i,	f: integer;
	     x,	y: item;

	  begin
	     case n of
		1, 2:
		   begin {read}
		      if sy = lparent
		      then
			 begin
			    repeat
			       insymbol;
			       if sy <>	ident
			       then
				  error(erid)
			       else
				  begin
				     i := loc(id);
				     insymbol;
				     if	i <> 0
				     then
					if tab[i].obj	<> variable
					then
					   error(ertyp)
					else
					   begin
					      x.typ := tab[i].typ;
					      x.ref := tab[i].ref;
					      if tab[i].normal
					      then
						 f := 0
					      else
						 f := 1;
					      emit2(f, tab[i].lev,
						    tab[i].adr);
					      if sy = lbrack then
						 selector(fsys + [comma,
						    rparent], x);
					      if x.typ in [ints, chars,
						 notyp]
					      then
						 emit1(27, ord(x.typ))
					      else
						 error(ertyp)
					   end
				  end;
			       test([comma, rparent],	fsys, erkey)
			    until sy <>	comma;
			    if sy = rparent
			    then
			       insymbol
			    else
			       error(erpun)
			 end;
		      if n = 2 then
			 emit(62)
		   end;
		3, 4:
		   begin {write}
		      if sy = lparent
		      then
			 begin
			    repeat
			       insymbol;
			       if sy = string
			       then
				  begin
				     emit1(24, sleng);
				     emit1(28, inum);
				     insymbol
				  end
			       else
				  begin
				     expression(fsys + [comma,	colon,
					rparent], x);
				     if	not (x.typ in stantyps)	then
					error(ertyp);
				     emit1(29, ord(x.typ))
				  end
			    until sy <>	comma;
			    if sy = rparent
			    then
			       insymbol
			    else
			       error(erpun)
			 end;
		      if n = 4 then
			 emit(63)
		   end;
		5, 6: {wait, signal}
		   if sy <> lparent
		   then
		      error(erpun)
		   else
		      begin
			 insymbol;
			 if sy <> ident
			 then
			    error(erid)
			 else
			    begin
			       i := loc(id);
			       insymbol;
			       if i <> 0
			       then
				  if tab[i].obj <> variable
				  then
				     error(ertyp)
				  else
				     begin
					x.typ := tab[i].typ;
					x.ref := tab[i].ref;
					if tab[i].normal
					then
					   f :=	0
					else
					   f :=	1;
					emit2(f, tab[i].lev, tab[i].
					   adr);
					if sy =	lbrack then
					   selector(fsys + [rparent],	x
					      );
					if x.typ = ints
					then
					   emit(n + 1)
					else
					   error(ertyp)
				     end
			    end;
			 if sy = rparent
			 then
			    insymbol
			 else
			    error(erpun)
		      end;
	     end {case}
	  end {standproc};


      begin {statement}
	  if sy	in statbegsys +	[ident]
	  then
	     case sy of
		ident:
		   begin
		      i	:= loc(id);
		      insymbol;
		      if i <> 0
		      then
			 case tab[i].obj of
			    konstant, type1:
			       error(ertyp);
			    variable:
			       assignment(tab[i].lev,	tab[i].adr);
			    prozedure:
			       if tab[i].lev <> 0
			       then
				  call(fsys, i)
			       else
				  standproc(tab[i].adr);
			    funktion:
			       if tab[i].ref = display[level]
			       then
				  assignment(tab[i].lev + 1, 0)
			       else
				  error(ertyp)
			 end
		   end;
		beginsy:
		   if id = 'cobegin   '
		   then
		      begin
			 emit(4);
			 compoundstatement;
			 emit(5)
		      end
		   else
		      compoundstatement;
		ifsy:
		   ifstatement;
		whilesy:
		   whilestatement;
		repeatsy:
		   repeatstatement;
		forsy:
		   forstatement;
	     end;
	  test(fsys, [], erpun)
      end {statement};


   begin {block}
      tabchar := chr(9);	
      dx := 5;
      prt := t;
      if level	> lmax then
	  fatal(5);
      test([lparent, colon, semicolon], fsys, erpun);
      enterblock;
      display[level]	:= b;
      prb := b;
      tab[prt].typ := notyp;
      tab[prt].ref := prb;
      if (sy =	lparent) and (level > 1) then
	  parameterlist;
      btab[prb].lastpar := t;
      btab[prb].psize := dx;
      if isfun
      then
	  if sy	= colon
	  then
	     begin
		insymbol;	{function type}
		if sy =	ident
		then
		   begin
		      x	:= loc(id);
		      insymbol;
		      if x <> 0	then
			 if tab[x].obj <> type1
			 then
			    error(ertyp)
			 else
			    if tab[x].typ in stantyps
			    then
			       tab[prt].typ := tab[x].typ
			    else
			       error(ertyp)
		   end
		else
		   skip([semicolon] +	fsys, erid)
	     end
	  else
	     error(erpun);
      if sy = semicolon
      then
	  insymbol
      else
	  error(erpun);
      repeat
	  if sy	= constsy then
	     constdeclaration;
	  if sy	= typesy then
	     typedeclaration;
	  if sy	= varsy	then
	     vardeclaration;
	  btab[prb].vsize := dx;
	  while	sy in [proceduresy, functionsy] do
	     procdeclaration;
	  test([beginsy], blockbegsys	+ statbegsys, erkey)
      until sy	in statbegsys;
      tab[prt].adr := lc;
      insymbol;
      statement([semicolon, endsy] +	fsys);
      while sy	in [semicolon] + statbegsys do
	  begin
	     if	sy = semicolon
	     then
		insymbol
	     else
		error(erpun);
	     statement([semicolon, endsy] + fsys)
	  end;
      if sy = endsy
      then
	  insymbol
      else
	  error(erkey);
      test(fsys + [period], [], erkey);
   end	{block};

modend.
