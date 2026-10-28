program indexer; {$c-,e+,f-,i-,j-,m-,p+,r+,s+,t-,u+	      }
{-------------------------------------------------------------}
{							      }
{	     INDEX  CREATION  FROM  THE  KEYBOARD	      }
{							      }
{    David E. Cortesi, 2340 Tasso St., Palo Alto CA 94301.    }
{		   (compuserve 72155,450)		      }
{							      }
{ Accepts index entries for a book from the keyboard, sorts   }
{ the entries and sub-entries, collates page references,      }
{ and creates an ASCII file that can be printed or edited.    }
{							      }
{ Term Recall is an unusual feature of the user interaction.  }
{ If, when entering an index term, the user hits the ESC key, }
{ the program will find the least term that matches the input }
{ to that point and fill in its characters on the input line. }
{ Hitting ESC again retracts those letters and displays the   }
{ letters of the next-higher matching term.  This can save    }
{ considerable typing -- a long term can be entered as only   }
{ a couple of letters plus ESC -- and it allows the user to   }
{ review the terms entered to that point in alpha order.      }
{							      }
{ Creates files INDEXER.OUT, the index-document file, and     }
{ INDEXER.TRE, an internal record of the tree which will be   }
{ reloaded on the next run if it then exists.		      }
{-------------------------------------------------------------}

const
   nullch = 0;		       { the null, end-of-string      }
   strmax = 65; 	       { max size of a string (64,00h)}
   sbufsize = 2046;	       { page size of a string buffer }
   sbufnum = 16;	       { allow up to 32K of buffers   }
   maxdepth = 20;	       { stack size for tree-walks    }
   asciibel = 7;	       { names for ascii characters   }
   asciibs = 8;
   asciilf = 10;
   asciicr = 13;
   asciiesc = 27;
   asciiblank = 32;
   asciidel = 127;

type
   strindex = 1..strmax;       { indices over strings	      }
   strlength= 0..strmax;       { lengths of strings	      }
   relation = (less,equal,more); { result of comparisons      }
   nchar = 0..255;	       { numeric characters are bytes }
   str = record 	       { an independent string is     }
	   len : strlength;    { ..a length and some bytes,   }
	   val : array[strindex] of nchar  { ending in 00h    }
	   end;
   strbuff = record	       { a string buffer is a compact }
	   free : 0..sbufsize; { collection of strings.       }
	   data : array[1..sbufsize] of nchar
	   end;
   stref = record	       { an indirect string is the    }
	   nb : 1..sbufnum;    { index of an strbuff's address}
	   bo : 1..sbufsize    { and an index into it.	      }
	   end;
   page = record	       { a page on which a term is    }
	   next : ^page;       { ..referenced, and ^next one  }
	   num	: integer
	   end;
   ppage = ^page;
   node = record	       { one node of a binary tree    }
	   lson, rson,	       { descendant trees	      }
	   subt : ^node;       { subtree of sub-terms	      }
	   iref, uref : stref; { original and uppercase terms }
	   phead : ppage;      { head of chain of page-refs   }
	   skip : boolean;     { phony node "M" starts a tree }
	   end;
   pnode = ^node;
   treewalk = record	       { current state of an inorder  }
	   current : pnode;    { ..walk of a tree: this node, }
	   top : 0..maxdepth;  { stack-top pointer, stacked   }
	   stack : array[1..maxdepth] of pnode;{ nodes, mark  }
	   goneleft : boolean  { true when backing out of leaf}
	   end;

var
   sbufptrs : array[1..sbufnum] of ^strbuff; { blocks of bytes}
   sbufcnt  : 0..sbufnum;      { how many blocks are active   }
   maintree : pnode;	       { root of the term-tree	      }
   initerm  : str;	       { "M" term for starting trees  }
   indlevel : 0..9;	       { subterm nesting (indent) lev.}
   outfile  : text;	       { the output document	      }

{-------------------------------------------------------------}
{	 routines operating on independent strings	      }
{ Pascal/Z string type was avoided to maximize portability.   }
{-------------------------------------------------------------}

function upcase(c:nchar) : nchar;
   { force character to uppercase }
   begin
       if (c>=ord('a')) and (c<=ord('z')) then
	   upcase := c-32
       else
	   upcase := c
   end;

procedure stucase(var a,b:str);
   { duplicate a string, forcing uppercase }
   var j : strlength;
       c : nchar;
   begin
       j := 0;
       repeat
	   j := j+1;
	   c := a.val[j];
	   b.val[j] := upcase(c);
       until c=nullch;
       b.len := j-1
   end;

{-------------------------------------------------------------}
{	    routines operating on stored strings	      }
{ To keep all stored terms in string form (P/Z or our version)}
{ would use far too much storage. Here we pack strings into   }
{ large blocks.  The blocks are allocated as needed, to a max }
{ of 32K -- limit enforced by compiler range checking.	      }
{-------------------------------------------------------------}

procedure stput(var a:str; var b:stref);
   { stow string a in latest buffer, return indirect reference}
   var bp : ^strbuff;
       j : strindex;
       k : 1..sbufsize;
   begin
       bp := sbufptrs[sbufcnt]; { ^latest string buffer       }
       if bp^.free<(a.len+1) then begin { not enough room!    }
	   new(bp);	       { make, count new buffer page  }
	   sbufcnt := sbufcnt+1; { range error here when full }
	   sbufptrs[sbufcnt] := bp;
	   bp^.free := sbufsize
       end;

       b.nb := sbufcnt;        { save buffer-page number      }
       j := 1;
       k := 1+sbufsize-bp^.free;
       b.bo := k;	       { save buffer-page offset      }

       while j <= a.len do begin
	   bp^.data[k] := a.val[j];
	   j := j+1;
	   k := k+1
       end;
       bp^.data[k] := nullch;  { mark end of stored string    }
       bp^.free := sbufsize-k  { adjust bytes left in block   }
   end;

procedure stget(var b:stref; var a:str);
   { retrieve stored string from buffer into string-record }
   var bp : ^strbuff;
       j : strindex;
       k : 1..sbufsize;
       c : nchar;
   begin
       bp := sbufptrs[b.nb];   { point to the buffer page     }
       k := b.bo;	       { ..and offset into it	      }
       j := 1;
       repeat		       { copy the stored string out   }
	   c := bp^.data[k];
	   a.val[j] := c;
	   j := j+1;
	   k := k+1;
       until (c=nullch);
       a.len := j-2
   end;

function sbcomp(var a:str; var b:stref) : relation;
   { EXACT comparison of a string to a stored string value --
     if "a" is initially equal but shorter, it is "less." }
   var bp : ^strbuff;
       j  : strindex;
       k  : 1..sbufsize;
       x,y : nchar;
       r  : relation;
   begin
       bp := sbufptrs[b.nb];
       k := b.bo;
       j := 1;
       repeat
	   x := a.val[j];
	   y := bp^.data[k];
	   j := j+1;
	   k := k+1
       until (x<>y) or (x=nullch);
       if x=y then r := equal
       else if x<y then r := less
	    else	r := more;
       sbcomp := r
   end;

function sxcomp(var a:str; var b:stref) : relation;
   { APPROXIMATE comparison of a string to a stored string --
    if "a" is initially equal but shorter, it is "equal." }
  var bp : ^strbuff;
       j  : strindex;
       k  : 1..sbufsize;
       x,y : nchar;
       r  : relation;
   begin
       bp := sbufptrs[b.nb];
       k := b.bo;
       j := 1;
       repeat
	   x := a.val[j];
	   y := bp^.data[k];
	   j := j+1;
	   k := k+1
       until (x<>y) or (x=nullch);
       if (x=y) or (x=nullch) then r := equal
       else if x<y then r := less
	    else	r := more;
       sxcomp := r
   end;

{-------------------------------------------------------------}
{	    routines operating on the binary trees	      }
{ Each tree node represents one index term.  The term itself  }
{ is stored two ways, as typed and all-caps.  The latter is   }
{ used for comparison of terms, so that "Apple" = "apple".    }
{ A node anchors a sorted chain of page-numbers, and may hold }
{ the root of an independent sub-tree of sub-terms.  The tree }
{ is ordered so that all terms off the .lson are less than,   }
{ and all terms off the .rson are greater, than this term.    }
{-------------------------------------------------------------}

function makenode(var a, ua : str) : pnode;
   { make a new tree node given term-strings }
   var tn : ^node;
   begin
       new(tn);
       tn^.lson := nil;
       tn^.rson := nil;
       tn^.subt := nil;
       stput(a,tn^.iref);
       stput(ua,tn^.uref);
       tn^.phead := nil;
       tn^.skip := false;
       makenode := tn
   end;

procedure startree(var t:pnode);
   { begin a tree with an artificial node whose term
      is "M" to encourage early balance }
   begin
      t := makenode(initerm,initerm);
      t^.skip := true
   end;

function insert(tree:pnode; var a:str) : pnode;
   { put a new term into a tree, or find it if it is there.
      either way, return the term's node's address.	    }
   var o,p,q : ^node;
       ua    : str;
       r     : relation;
   begin
       stucase(a,ua);
       p := tree;

       repeat
	   r := sbcomp(ua,p^.uref);
	   if r<>equal then
	       if r=less then q := p^.lson
	       else	      q := p^.rson
	   else q := p;
	   o := p;
	   p := q
       until (r=equal) or (p=nil);

       if r=equal then insert := p
       else begin { term doesn't exist in the tree }
	   q := makenode(a,ua);
	   if r=less then o^.lson := q
	   else 	  o^.rson := q;
	   insert := q
       end;
end;

{-------------------------------------------------------------}
{ routines for tree-walking.  These routines abstract the     }
{ idea of an in-order tour of the tree into a single record.  }
{ The usual algorithm for a walk is recursive (see J&W 11.5), }
{ which is not convenient for this program.		      }
{-------------------------------------------------------------}

procedure initwalk(t:pnode; var w:treewalk);
   { initialize for a walk over the given tree }
   begin
       w.current := t;	       { start at the top node,       }
       w.goneleft := false;    { ..but descend left first off }
       w.top := 0	       { stack is empty 	      }
   end;

procedure push(pn: pnode; var w: treewalk);
   { push a given node onto the walk-stack }
   begin
       if w.top<maxdepth then begin
	   w.top := w.top+1;
	   w.stack[w.top] := pn
       end
   end;

function pop(var w:treewalk) : pnode;
   { pop the top node from the walk-stack }
   begin
       if w.top>0 then begin
	   pop := w.stack[w.top];
	   w.top := w.top-1
       end
       else pop := nil
   end;

function treestep(var w:treewalk) : pnode;
   { step to the next node in lexical order in a tree.
       return that node as result, and save it in the walk
       record as "current."  Return nil if end of tree.       }
   var t : pnode;
   begin
       t := w.current;
       repeat
	   if not w.goneleft then begin { descend to the left }
	       if t<> nil then
		   while t^.lson<>nil do begin
		       push(t,w);
		       t := t^.lson
		   end;
	       w.goneleft := true { t^ a left-leaf of tree }
	   end
	   else { been down; have handled current; go up/right}
	       if t<> nil then
		   if t^.rson <> nil then begin
		       t := t^.rson;	    { jog right, then }
		       w.goneleft := false  { drop down again }
		   end
		   else { nowhere to go but up }
		       t := pop(w)
       until w.goneleft; { repeats when we jog right }
       w.current := t;
       treestep := t
   end;

function setscan(tree: pnode; var w: treewalk; var a: str)
						: pnode;
   { given a partial term "a," a tree "tree," and a tree-
   walk record "w," set up w so that a series of calls on
   function treestep will return all the nodes that are
   initially equal to a in ascending order.  If there are
   none such, return nil.  This function sets up for Term
   Recall when the escape key is pressed during input.

   The algorithm is to find the matching term that is
   highest in the tree, then use treestep to find the
   lexically-least node under that term (which may not be
   a match) and then to treestep to the first match.}

   var ua : str;
       p,t : pnode;
       r : relation;
       quit : boolean;
   begin
       stucase(a,ua);
       initwalk(tree,w);
       t := tree;
       if t=nil then setscan := nil  { no matches possible    }
       else begin
	   { step 1 is to find any part-equal node at all     }
	   quit := false;
	   repeat
	       r := sxcomp(ua,t^.uref);
	       case r of
		   less : if t^.lson<>nil then t := t^.lson
					  else quit := true;
		   more : if t^.rson<>nil then t := t^.rson
					  else quit := true;
		   equal : quit := true
	       end
	   until quit;
	   { If we have a match, it may not be the least one.
	     If this node has a left-son, there can be lesser
	     matches (and nonmatches) down that branch. }
	   if r<>equal then setscan := nil { no match a-tall  }
	   else begin
	       w.current := t;
	       if t^.lson=nil then w.goneleft := true
	       else begin { zoom down in tree }
		   w.goneleft := false;
		   repeat
		       t := treestep(w);
		       r := sxcomp(ua,t^.uref)
		   until r=equal
	       end;
	       setscan := t
	   end
       end
   end;

{-------------------------------------------------------------}
{		routines for phase 1 -- input		      }
{-------------------------------------------------------------}

procedure indent;
   { indent the cursor for the current nesting level }
   var i : 0..9;
   begin
       for i := 1 to indlevel do write('. . ')
   end;

function readnc : nchar;
   { get one byte from the keyboard, bypassing the
     usual pascal procedures and going straight to CP/M }
   const bdos=5;
	 inchar=1;
	 asciicr=13;
	 asciilf=10;
   type regs = record
		   a : 0..255;
		   bc,de,hl : integer
	       end;
   var r : regs;
   procedure call(var x:regs; addr:integer); external;
   begin
       r.bc := inchar;
       call(r,bdos);
       readnc := r.a
   end;

procedure getterm(tree: pnode; var a:str; var cont: boolean);
   { get a term from the user, with control keys used thus:
       cr : end the term.
       lf : end the term, begin a subterm of it.
       esc: try to complete the term with the next (first)
	    matching term from the present tree-context.
       del: cancel esc-completion, return to original entry.  }
   var
       c       : nchar;
       j, oj   : strindex;
       k       : strlength;
       x,ua    : str;
       quit    : boolean;
       tw      : treewalk;
       p       : pnode;

   procedure backup;
       { backup the screen and the "a" string to the original
	   term that was entered. }
       var qj  : strindex;
       begin
	   for qj := j downto (oj+1) do
	     write(chr(asciibs),chr(asciiblank),chr(asciibs));
	   j := oj;
	   a.val[j] := nullch
       end;

   procedure startscan;
       { set up for an alphabetical scan over all terms that
	 are an initial match to user entry thus far.  Setscan
	 does most of the work. }
       begin
	   stucase(a,ua); { for stepscan's benefit }
	   p := setscan(tree,tw,a);
	   if p<>nil then { phony node only if a.len=0 }
	       if p^.skip then p := treestep(tw);
	   if p<>nil then begin { this node has to be equal }
	       stget(p^.iref,x);
	       k := x.len+1
	   end
	   else k := 0
       end;

   procedure stepscan;
       { find the next match to the original string, leaving
	 its value in x, or k=0 if there is none.  }
       begin
	   k := 0;
	   p := treestep(tw);
	   if p<>nil then
	       if p^.skip then p := treestep(tw);
	   if p<>nil then
	       if equal=sxcomp(ua,p^.uref) then begin
		   stget(p^.iref,x);
		   k := x.len+1
	       end
       end;

   begin { the main Get Term procedure }
       indent; write('term: ');
       j := 1; oj := j;        { no data in the a-string      }
       k := 0;		       { no esc-scan working	      }
       quit := false;	       { not finished yet (hardly!)   }
       repeat
	   a.val[j] := nullch; { keep "a" a finished string   }
	   a.len := j-1;       { ..at all times 	      }
	   c := readnc;
	   case c of

	   asciibs :	       { destructive backspace	      }
	       if j>1 then begin
		   write(chr(asciiblank),chr(asciibs));
		   j := j-1;
		   oj := j;    { the current scan is accepted }
		   k := 0;     { ..and no scan is underway    }
	       end;

	   asciicr :	       { normal completion	      }
	       begin
		   write(chr(asciilf));
		   quit := true
	       end;

	   asciilf :	       { complete, move on to subterm }
	       begin
		   write(chr(asciicr));
		   quit := true
	       end;

	   asciiesc :	       { automatic scan for match     }
	       begin
		   backup;     { wipe rejected match if any   }
		   if k=0 then startscan else stepscan;
		   if k=0 then { no (further) match found     }
		       write(chr(asciibel))
		   else        { next (first?) match found    }
		       while j<k do begin
			   a.val[j] := x.val[j];
			   write(chr(a.val[j]));
			   j := j+1
		       end
	       end;

	   asciidel :	       { cancel search for match      }
	       begin
		   backup;
		   k := 0      { no active scan 	      }
	       end;

	   else :	       { ordinary (?) character       }
	       if (c<asciiblank) or (j=strmax) then
		   write(chr(asciibel))
	       else begin
		   a.val[j] := c;
		   j := j+1;
		   oj := j;	{ the current scan has been   }
		   k := 0	{ ..accepted and is over      }
	       end
	   end {case}
       until quit;
       cont := c=asciilf
   end;

procedure getpage(var i: integer);
   { read a page number into an integer.  If page numbers
     are not simple integers, eg "3-17" and the like, this
     routine would have to build a string. }
   begin
       indent;
       write('page: ');
       readln(i)
   end;

procedure makepage(var p:ppage; i:integer);
   { make a page record and install its address }
   begin
       new(p);
       p^.next := nil;
       p^.num  := i
   end;

procedure addpage(np: pnode; pg: integer);
   { add a page number to the chain off a node.  This is
     a classic case of an algorithm that requires a 2-exit
     loop; the scan of the chain has to stop when a higher
     page number is found OR when the end of the chain is
     reached.  It could be done with Repeat or While, but
     it actually looks cleaner with Goto. }
   label 99,101,102,103;
   var p1, p2, p3: ppage;
   begin
       p1 := np^.phead;
       if p1=nil then makepage(np^.phead,pg)
       else  { some pages already noted, search chain }
	   if pg<p1^.num then begin
	       makepage(p2,pg); { this page less than all }
	       p2^.next := p1;
	       np^.phead := p2
	   end
	   else begin { this page goes somewhere in chain }
	   99: p2 := p1^.next;
	       if p2=nil then goto 101;
	       if pg<p2^.num then goto 102;
	       p1 := p2;
	       goto 99;
	   101: { p1^ last number in chain, pg is => it }
	       begin
		   if pg>p1^.num then
		       makepage(p1^.next,pg);
		   goto 103
	       end;
	   102: {p1^.num <= pg <p2^.num; pg goes between }
	       begin
		   if pg>p1^.num then begin
		       makepage(p3,pg);
		       p3^.next := p2;
		       p1^.next := p3
		   end
	       end;
	   103: ;
	   end
   end;

procedure load(var atree:pnode);
   { input control: load terms into a tree from the keyboard.
     the code is recursive; if the user wants to do a subterm
     this routine calls itself to load the sub-tree of the
     superior term's node.  A page number of zero is a disaster
     when we reload the saved tree, so one is converted to -1.}
   var aterm : str;
       anode : pnode;
       apage : integer;
       cont  : boolean;
   begin
       repeat
	   getterm(atree,aterm,cont);
	   if aterm.len>0 then begin
	       anode := insert(atree,aterm);
	       if not cont then begin
		   getpage(apage);
		   if apage=0 then apage := 32767;
		   addpage(anode,apage)
	       end
	       else begin { user hit lf, wants to recurse }
		   if anode^.subt=nil then
		       startree(anode^.subt);
		   indlevel := indlevel+1;
		   load(anode^.subt);
		   indlevel := indlevel-1
	       end
	   end;
       until (aterm.len=0) or (indlevel>0)
   end;

{-------------------------------------------------------------}
{	       routines for phase 2 -- output		      }
{-------------------------------------------------------------}

procedure filenode(np: pnode; var oc: nchar);
   { write one node's contents, term + pages, to the output.
     It is at this level that we insert a blank line on a break
     in the sequence of main-term initial letters.  Once more,
     a loop over an ordered chain is cleaner with Goto. }
   label 99;
   var a : str;
       p : ppage;
       i : 0..9;
       j : strindex;
       k1, k2 : integer;
       ic : nchar;
   begin
       if not np^.skip then begin { ignore phony nodes }
	   stget(np^.iref,a);
	   ic := upcase(a.val[1]);
	   if (indlevel=0) and	{ main-term initial change? }
		(oc<>ic) then writeln(outfile);
	   oc := ic;
	   for i := 1 to indlevel do write(outfile,'   ');
	   for j := 1 to a.len do write(outfile,chr(a.val[j]));
	   p := np^.phead;
	   while p<>nil do begin
	       write(outfile,' ');
	       k1 := p^.num;
	       k2 := k1+1;
	    99:p := p^.next;   { elide sequential numbers     }
	       if p<>nil then
		   if p^.num=k2 then begin
		       k2 := k2+1;
		       goto 99
		   end;
	       write(outfile,k1:1); { write "17" or "17-19"   }
	       if (k1+1)<k2 then write(outfile,'-',k2-1:1);
	       if p<>nil then write(outfile,',');
	   end;
       writeln(outfile);
       end
   end;

procedure filetree(intree: pnode);
   { walk through a (sub-) tree and write each node }
   var tree    : pnode;
       tw      : treewalk;
       oc      : nchar;
   begin
       oc := nullch;
       initwalk(intree,tw);
       tree := treestep(tw);
       while tree<>nil do begin
	   filenode(tree,oc);
	   if tree^.subt<>nil then begin
	       indlevel := indlevel+1;
	       filetree(tree^.subt);
	       indlevel := indlevel-1
	   end;
	   tree := treestep(tw)
       end
   end;

procedure dump;
   begin
       rewrite('INDEXER.OUT',outfile);
       filetree(maintree)
   end;

{-------------------------------------------------------------}
{	   routines for phase 0 -- initialization	      }
{-------------------------------------------------------------}

procedure init;
   { initialize the various mechanisms }
   begin
       indlevel := 0;
       new (sbufptrs[1]);
       sbufcnt := 1;
       sbufptrs[1]^.free := sbufsize;
       initerm.val[1] := ord('M');
       initerm.val[2] := nullch;
       initerm.len := 1;
       startree(maintree);
   end;

procedure loadall;
   { if a saved-tree file INDEXER.TRE exists, load its values
       into the tree.	       }
   var loadtree : file of nchar;
       x   : str;
       j   : strindex;
       p   : pnode;
       k   : integer;
       k1,k2 : 0..255;

   procedure reload(t:pnode);
       { reload one (sub-)tree from the saved-tree file }
       { the recorded form of one node of a tree is:
	   termlength (1..strmax-1),
	   that many term bytes in reverse order,
	   page numbers as high byte, low byte,
	   page number of (zero,zero).
       the file is a sequence of terms as above. a tree ends
       with a byte of zero.  a sub-tree is introduced with a
       byte of strmax.					      }

       begin {$r-  range checks off during byte i/o }
	   read(loadtree,j);
	   while j<>nullch do begin
	       x.len := j;
	       for j := j downto 1 do read(loadtree,x.val[j]);
	       x.val[x.len+1] := nullch;
	       p := insert(t,x);
	       repeat
		   read(loadtree,k1,k2);
		   k := (k1*256)+k2;
		   if k<>0 then addpage(p,k)
	       until k=0;
	       read(loadtree,j);
	       if j=strmax then begin { a sub-tree }
		   startree(p^.subt);
		   reload(p^.subt);
		   read(loadtree,j)
	       end
	   end
       end; {$r+ }

   begin
       reset('INDEXER.TRE',loadtree);
       if not eof(loadtree) then reload(maintree)
   end;

{-------------------------------------------------------------}
{	      routines for phase 3 -- termination	      }
{-------------------------------------------------------------}

procedure saveall;
   { save the term-tree in the file INDEXER.TRE so it can
       be reloaded for additions later, if need be. }
   var savetree    : file of nchar;
       x   : str;

   procedure unload(t:pnode);
       { dump the contents of a (sub-) tree to disk in
	   "preorder," a sequence such that the exact layout
	   of the tree will be reconstructed if the tree is
	   reloaded from the file. }
       label 99;
       var j   : strindex;
	   p   : ppage;
	   k   : integer;
	   k1, k2 : nchar;
       begin  {$r-  range checks off during byte i/o }
	   if t^.skip then goto 99; { dump not the phony node }
	   stget(t^.iref,x);
	   write(savetree,x.len);
	   for j:=x.len downto 1 do write(savetree,x.val[j]);
	   p := t^.phead;
	   while p<>nil do begin
	       k := p^.num;
	       k1 := k div 256; k2 := k mod 256;
	       write(savetree,k1,k2);
	       p := p^.next
	   end;
	   write(savetree,nullch,nullch); { flag end of pages }
	   if t^.subt<>nil then begin
	       write(savetree,strmax);{ flag start of subtree }
	       unload(t^.subt);
	       write(savetree,nullch) { flag end of subtree }
	   end;
       99: if t^.lson<>nil then unload(t^.lson);
	   if t^.rson<>nil then unload(t^.rson);
       end; {$r+ }

   begin
       rewrite('INDEXER.TRE',savetree);
       unload(maintree);
       write(savetree,nullch)  { flag end of main tree }
   end;

{-------------------------------------------------------------}
{ The main program, at last.....			      }
{-------------------------------------------------------------}

begin
   init;
   loadall;
   load(maintree);
   saveall;
   dump
end.
-----------------------------------------