
{$K1} {$K2} {$K4} {$K7} {$K12} {$K13} {$K14} { symbol table space reduction }

module cpsinterpreter;


{$I global.inc }

var
   cc:	external integer;	{character counter}
   lc: external integer;	{program location counter}
   ll:	external integer;	{length of current line}
   ch: external char;
   errs: external set of er;
   errpos: external  integer;
   progname:external  alfa;
   skipflag: external boolean;
   constbegsys, typebegsys, blockbegsys, facbegsys, statbegsys: external symset;
   key:external  array
      [1.. nkw] of alfa;
   ksy:external  array
      [1.. nkw] of symbol;
   sps:external  array
      [char]	of symbol; 			{special aymbols}
   t, a, b, sx, c1, c2: external integer;	{indices to tables}
   stantyps: external  typset;
   display:external  array
      [0.. lmax] of integer;
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
      [1.. amax] of		 {array-table}
   packed record
	      inxtyp, eltyp: types;
	      elref, low, high,	elsize,	size: index;
	   end;
   btab: external array
      [1..bmax] of 		{block-table}
   packed record
	      last, lastpar, psize, vsize: index
	   end;
   stab: external packed array
      [0.. smax] of char;		{string table}
   code: external array
      [0.. cmax] of order;		{ interpreter	declarations }
   ir:	order;				{instruction buffer}
   ps:					{processor status}
      (run, fin, divchk, inxchk, stkchk, linchk, lngchk, redchk,
	deadlock);
   lncnt,				{number of lines}
   chrcnt: integer;			{number of characters	in lines}
   h1,	h2, h3,	h4: integer;		{local variables}
   s: array
      [1.. stmax] of	integer;	{the stack}

{process table-one entry for each process}
   ptab:  array
      [ptype] of record
		       t, b,	 {top, bottom of stack}
		       pc,	 {program counter}
		       stacksize: integer;	{stack limit}
		       display:	array
			  [1..	lmax] of integer;
		       suspend:	integer;	{0 or	index of semaphore}
		       active: boolean 		{procedure active flag}
		    end;
   npr, 			{number of concurrent	processes}
   curpr: ptype;		{current process executing}
   stepcount:  integer;		{number of steps before switch}
   seed: real;			{random seed}
   pflag: boolean;		{concurrent call flag	}


function ran: real;

{ random number generator. output : 0 < ran < 1 .
  bowles,k. microcomputer problem solving using pascal, p. 257 }

   const
      mult = 27.182813;
      incr = 31.415917; 

   begin
      seed := seed * mult + incr;
      seed := seed - trunc(seed);
      ran := seed;
   end	{ran};

{functions to	convert	integers to booleans and converesely}

function itob(i: integer): boolean;

   begin
      if i = tru
      then
	  itob := true
      else
	  itob := false
   end	{itob};


function btoi(b: boolean): integer;

   begin
      if b
      then
	  btoi := tru
      else
	  btoi := fals
   end	{btoi};


procedure initialize;

var cpf : ptype;

   begin
      s[1] := 0;
      s[2] := 0;
      s[3] := - 1;
      s[4] := btab[1].last;
      with ptab[0] do
	  begin
	     b := 0;
	     suspend :=	0;
	     display[1] := 0;
	     t := btab[2].vsize - 1;
	     pc	:= tab[s[4]].adr;
	     active := true;
	     stacksize := stmax	- pmax * stkincr
	  end;
      for cpf   := 1 to pmax do
	  with ptab[cpf] do
	     begin
		active := false;
		display[1] :=	0;
		pc := 0;
		suspend	:= 0;
		b := ptab[cpf - 1].stacksize + 1;
		stacksize := b + stkincr - 1;
		t := b - 1
	     end;
      npr := 0;
      curpr :=	0;
      pflag :=	false;
      seed := 1.23456789; { seed for random number generator }
      stepcount := 0;
      ps := run;
      lncnt :=	0;
      chrcnt := 0;
   end	{initialize};

{ because of limitations of procedure length in pascal/mt the case statement of
  the interpreter has been split into four procedures.
}

procedure exec1;  
var hx : integer;
   begin
      with ptab[curpr] do
	  case ir.f of
	     0:
		begin {load address}
		   t :=	t + 1;
		   if t	> stacksize
		   then
		      ps := stkchk
		   else
		      s[t] :=	display[ir.x]	+ ir.y
		end;
	     1:
		begin {load value}
		   t :=	t + 1;
		   if t	> stacksize
		   then
		      ps := stkchk
		   else
		      s[t] :=	s[display[ir.x] + ir.y]
		end;
	     2:
		begin {load indirect}
		   t :=	t + 1;
		   if t	> stacksize
		   then
		      ps := stkchk
		   else
		      s[t] :=	s[s[display[ir.x] +	ir.y]]
		end;
	     3:
		begin {update display}
		   h1 := ir.y;
		   h2 := ir.x;
		   h3 := b;
		   repeat
		      display[h1] := h3;
		      h1 := h1 - 1;
		      h3 := s[h3 + 2]
		   until h1 = h2
		end;
	     4:	{cobegin}
		pflag := true;
	     5:	{coend}
		begin
		   pflag := false;
		   ptab[0].active := false
		end;
	     6:
		begin {wait}
		   h1 := s[t];
		   t :=	t - 1;
		   if s[h1] >	0
		   then
		      s[h1] := s[h1] - 1
		   else
		      begin
			 suspend := h1;
			 stepcount := 0
		      end
		end;
	     7:
		begin {signal}
		   h1 := s[t];
		   t :=	t - 1;
		   h2 := pmax +	1;
		   h3 := trunc(ran * h2);
		   while (h2 >=	0) and (ptab[h3].suspend <> h1) do
		      begin
			 h3 := (h3 + 1)	mod (pmax + 1);
			 h2 := h2 - 1
		      end;
		   if h2 < 0
		   then
		      s[h1] := s[h1] + 1
		   else
		      ptab[h3].suspend := 0
		end;
	     8:
		case ir.y of
		   17:
		      begin
			 t := t	+ 1;
			 if t >	stacksize
			 then
			    ps := stkchk
			 else
			    s[t] := btoi(eof(input))
		      end;
		   18:
		      begin
			 t := t	+ 1;
			 if t >	stacksize
			 then
			    ps := stkchk
			 else
			    s[t] := btoi(eoln(input))
		      end;
		end;
	     10:
		pc := ir.y;	{jump}
	     11:
		begin {conditional jump}
		   if s[t] = fals then
		      pc := ir.y;
		   t :=	t - 1
		end;
	     14:
		begin {for1up}
		   h1 := s[t -	1];
		   if h1 <= s[t]
		   then
		      s[s[t -	2]] := h1
		   else
		      begin
			 t := t	- 3;
			 pc := ir.y
		      end
		end;
	  end;
   end	{exec1};

procedure exec2;
var hx :integer;

   begin
      with ptab[curpr] do
	  case ir.f of
	     15:
		begin {for2up}
		   h2 := s[t -	2];
		   h1 := s[h2] + 1;
		   if h1 <= s[t]
		   then
		      begin
			 s[h2] := h1;
			 pc := ir.y
		      end
		   else
		      t	:= t - 3;
		end;
	     18:
		begin
		   h1 := btab[tab[ir.y].ref].vsize;
		   if t	+ h1 > stacksize
		   then
		      ps := stkchk
		   else
		      begin
			 t := t	+ 5;
			 s[t -	1] := h1 - 1;
			 s[t]	:= ir.y
		      end;
		end;
	     19:
		begin
		   active := true;
		   h1 := t - ir.y;
		   h2 := s[h1 + 4];	{h2 points to	tab}
		   h3 := tab[h2].lev;
		   display[h3 + 1] :=	h1;
		   h4 := s[h1 + 3] + h1;
		   s[h1 + 1] := pc;
		   s[h1 + 2] := display[h3];
		   if pflag
		   then
		      s[h1 + 3] := ptab[0].b
		   else
		      s[h1 + 3] := b;
		   for hx := t + 1 to h4 do
		      s[hx] := 0;
		   b :=	h1;
		   t :=	h4;
		   pc := tab[h2].adr
		end;
	     21:
		begin {index}
		   h1 := ir.y;	{h1 points to	atab}
		   h2 := atab[h1].low;
		   h3 := s[t];
		   if h3 < h2
		   then
		      ps := inxchk
		   else
		      if h3 > atab[h1].high
		      then
			 ps := inxchk
		      else
			 begin
			    t := t - 1;
			    s[t] := s[t] + (h3 - h2) * atab[h1].
			       elsize
			 end
		end;
	     22:
		begin {load block}
		   h1 := s[t];
		   t :=	t - 1;
		   h2 := ir.y +	t;
		   if h2 > stacksize
		   then
		      ps := stkchk
		   else
		      while t <	h2 do
			 begin
			    t := t + 1;
			    s[t] := s[h1];
			    h1 := h1 + 1
			 end
		end;
	     23:
		begin {copy block}
		   h1 := s[t -	1];
		   h2 := s[t];
		   h3 := h1 + ir.y;
		   while h1 < h3 do
		      begin
			 s[h1] := s[h2];
			 h1 := h1 + 1;
			 h2 := h2 + 1
		      end;
		   t :=	t - 2
		end;
	  end;
   end	{exec1};



procedure exec4;
var hx :integer;

   begin
      with ptab[curpr] do
	  case ir.f of
	     38:
		begin {store}
		   s[s[t - 1]] := s[t];
		   t :=	t - 2
		end;
	     45:
		begin
		   t :=	t - 1;
		   s[t] := btoi(s[t] = s[t+ 1])
		end;
	     46:
		begin
		   t :=	t - 1;
		   s[t] := btoi(s[t] <> s[t + 1])
		end;
	     47:
		begin
		   t :=	t - 1;
		   s[t] := btoi(s[t] < s[t	+ 1])
		end;
	     48:
		begin
		   t :=	t - 1;
		   s[t] := btoi(s[t] <= s[t + 1])
		end;
	     49:
		begin
		   t :=	t - 1;
		   s[t] := btoi(s[t] > s[t	+ 1])
		end;
	     50:
 		begin
		   t :=	t - 1;
		   s[t] := btoi(s[t] >= s[t + 1])
		end;
	     51:
		begin
		   t :=	t - 1;
		   s[t] := btoi(itob(s[t]) or itob(s[t + 1]))
		end;
	     52:
		begin
		   t :=	t - 1;
		   s[t] := s[t] + s[t + 1]
		end;
	     53:
		begin
		   t :=	t - 1;
		   s[t] := s[t] - s[t + 1]
		end;
	     56:
		begin
		   t :=	t - 1;
		   s[t] := btoi(itob(s[t]) and itob(s[t + 1]))
		end;
	     57:
		begin
		   t :=	t - 1;
		   s[t] := s[t] * s[t + 1]
		end;
	     58:
		begin
		   t :=	t - 1;
		   if s[t + 1] = 0
		   then
		      ps := divchk
		   else
		      s[t] :=	s[t] div s[t	+ 1]
		end;
	     59:
		begin
		   t :=	t - 1;
		   if s[t + 1] = 0
		   then
		      ps := divchk
		   else
		      s[t] :=	s[t] mod s[t	+ 1]
		end;
	     62:
		if eof(input)
		then
		   ps := redchk
		else
		   readln;
	     63:
		begin
		   writeln;
		   lncnt := lncnt + 1;
		   chrcnt := 0;
		   if lncnt > linelimit	then
		      ps := linchk
		end
	  end;
   end	{exec1};



procedure exec3;

   begin
      with ptab[curpr] do
	  case ir.f of
	     24:
		begin {literal}
		   t :=	t + 1;
		   if t	> stacksize
		   then
		      ps := stkchk
		   else
		      s[t] :=	ir.y
		end;
	     27:
		begin {read}
		   if eof(input)
		   then
		      ps := redchk
		   else
		      case ir.y	of
			 1:
			    read(s[s[t]]);
			 3:
			    begin
			       read(ch);
			       s[s[t]] := ord(ch)
			    end;
		      end;
		   t :=	t - 1
		end;
	     28:
		begin {write string}
		   h1 := s[t];
		   h2 := ir.y;
		   t :=	t - 1;
		   chrcnt := chrcnt + h1;
		   if chrcnt > lineleng	then
		      ps := lngchk;
		   repeat
		      write(stab[h2]);
		      h1 := h1 - 1;
		      h2 := h2 + 1
		   until h1 = 0
		end;
	     29:
		begin {write1}
		   if ir.y = 3
		   then
		      h1 := 1
		   else
		      h1 := 10;
		   chrcnt := chrcnt + h1;
		   if chrcnt > lineleng
		   then
		      ps := lngchk
		   else
		      case ir.y	of
			 1:
			    write(s[t]);
			 2:
			    write(itob(s[t]));
			 3:
			    if (s[t] < charl)	or (s[t] > charh)
			    then
			       ps := inxchk
			    else
			       write(chr(s[t]))
		      end;
		   t :=	t - 1
		end;
	     31:
		ps := fin;
	     32:
		begin
		   t :=	b - 1;
		   pc := s[b +	1];
		   if pc <> 0
		   then
		      b	:= s[b	+ 3]
		   else
		      begin
			 npr :=	npr - 1;
			 active	:= false;
			 stepcount := 0;
			 ptab[0].active := (npr = 0)
		      end
		end;
	     33:
		begin {exit function}
		   t :=	b;
		   pc := s[b +	1];
		   b :=	s[b + 3]
		end;
	     34:
		s[t] := s[s[t]];
	     35:
		s[t] := btoi(not (itob(s[t])));
	     36:
		s[t] := - s[t];
	  end {case};
   end	{exec3};


procedure interpret;
var hx:integer;
   label
      97, 98;


   procedure chooseproc;

{from	a random starting point	search for a process that is active and
not suspended.	d aborts the interpreter if a deadlock occurs.}

      var
	  d: integer;

      begin
	  d := pmax + 1;
	  curpr	:= (curpr + trunc(ran *	pmax)) mod (pmax + 1);
	  while	((not ptab[curpr].active) or (ptab[curpr].suspend <>
	     0)) and (d	>= 0) do
	     begin
		d := d - 1;
		curpr := (curpr	+ 1) mod (pmax + 1)
	     end;
	  if d < 0
	  then
	     begin
		ps := deadlock;
		writeln('deadlock');
		readln;
	     end
	  else
	     stepcount := trunc(ran * stepmax);
      end {chooseproc};


   begin {interpret}
      initialize;
      repeat
	  if ptab[0].active
	  then
	     curpr := 0
	  else
	     if	stepcount = 0
	     then
		chooseproc
	     else
		stepcount := stepcount - 1;
	  with ptab[curpr] do
	     begin
		ir := code[pc];
		pc := pc + 1
	     end;
	  if pflag then
	     begin
		if ir.f	= 18 {markstack} then
		   npr := npr +	1;
		curpr := npr
	     end;
	  with ptab[curpr] do
	  begin 
	     if	ir.f < 15
	     then
		exec1
	     else if ir.f < 24 
	     then exec2
	     else if ir.f < 37
	     then exec3
	     else exec4;
	end;	
      until ps	<> run;
  98: writeln;
      if ps <>	fin
      then
	  begin
	     with ptab[curpr]	do
		write('	halt at', pc: 3, ' in process',	curpr: 4,
		   ' because of	');
	     case ps of
		deadlock:
		   writeln('deadlock');
		divchk:
		   writeln('division by	0');
		inxchk:
		   writeln('invalid index');
		stkchk:
		   writeln('storage overflow');
		linchk:
		   writeln('too	much output');
		lngchk:
		   writeln('linr too long');
		redchk:
		   writeln('reading past end of	file');
	     end;
	     writeln('process active suspend pc');
	     for hx := 0 to pmax do
		with ptab[hx]	do
		   writeln(hx: 4,' ':4,active:6,' ',suspend:4,' ':4,pc);
	     writeln;
	     writeln('global variables');
	     for hx := btab[1].last +	1 to tmax do
		with tab[hx] do
		   if lev <> 1
		   then
		      goto 97
		   else
		      if obj = variable
		      then
			 if typ	in stantyps
			 then
			    case typ of
			       ints:
				  writeln(name,	' = ', s[adr]);
			       bools:
				  writeln(name,	' = ', itob(s[adr]));
			       chars:
				  writeln(name,	' = ', chr(s[adr] { mod
				  64}));
			    end;
	  end;
  97: writeln
   end	{interpret};
modend.
