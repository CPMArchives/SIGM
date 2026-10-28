FUNCTION select(VAR list : real_array;first,last,k : INTEGER) : BOOLEAN;

{$c-,m-,f-,r-  [turn off checking options for speed : select is debugged]}
{
Original Authors  : Robert W.Floyd,Stanford U.,Ca. &
		    Ronald L.Rivest,M.I.T.,Ma.
Original language : Algol
Reference	  : Algorithm 489 Collected Algorithms A.C.M.

Modified 1982 for Pascal/z by G.M.Acland,U. of Penn.

Comment : Does a partial sort of the array list (using a partitioning technic
similar to that used in QUICKSORT,QUICKERSORT etc.),such that :
	1 : list[k] ends up containing the (k - first +1)th smallest value.
	2 : all values for list[i] such that i =< k , will be =< list[k].
		i.e. the left "half" of the array will contain only values
	    equal to or less than the (k - first + 1)th smallest.
	3 : all values for list[i] such that i >= k , will be >= list[k].
		i.e. the right "half" contains only values equal to or
	    greater than the (k - first + 1)th smallest.
	The most frequent use for this type of procedure is in finding the
median of an array.In this case one sets first = 1 , last = n , where n is the 
order of the array,and k := (first+last)DIV 2 for n = ODD.Where n is even the
median calculation is more complex.The FUNCTION median demonstrates this use.
       If the function is called with ((last - first) < 1 ) , or if k is
< first or > last , it returns FALSE.
}

CONST
	multiplier	= 0.1;
	cutoff		= 100; { segment size below which the algorithm
				 does not sample but only partitions. }
VAR
	left,right,
	leftpart,
	rightpart,
	newleft,
	newright	: INTEGER;
	altleft,
	altright,
	leftside,
	rightside,
	samplesize,
	listsize,
	lnlistsize,
        tempreal,
	estimate,sd,
	sd1,sd2		: REAL;
	dummy		: BOOLEAN;

FUNCTION larger(a,b:INTEGER):INTEGER;
 BEGIN
  IF a > b THEN larger := a ELSE larger := b;
 END;

FUNCTION smaller(a,b:INTEGER):INTEGER;
 BEGIN
  IF a < b THEN smaller := a ELSE smaller := b;
 END;

PROCEDURE exchange(VAR a,b:REAL);
VAR temp : REAL;
 BEGIN
  temp := a;
  a    := b;
  b    := temp;
 END;

BEGIN { function SELECT }
 IF ((last - first) < 1)
 OR (k < first)
 OR (k > last) THEN select:= FALSE
 ELSE BEGIN
   select := TRUE;
   right := last;
   left  := first;
   WHILE right > left DO
    BEGIN
      IF (right - left) > cutoff THEN
        BEGIN
  
        {comment : use SELECT recursively on a sample of size "samplesize"
  	to get an estimate of the (k - left + 1)th smallest element into
  	list[k],biased slightly so that the (k - left + 1)th element is
  	expected to lie in the smaller set after partitioning , and so
  	that this partition is kept as small as possible.}
  
          listsize   := right - left + 1;
          leftside   := k - left + 1;
          lnlistsize := LN(listsize);
          samplesize := multiplier * EXP(2 * lnlistsize / 3);
          sd1        := 2 * leftside/listsize - 1;
          sd2        := sqrt(lnlistsize * samplesize 
                                   * (listsize - samplesize)/listsize);
          sd         := multiplier * sd2 * sd1;
          tempreal   := samplesize/listsize;
          altleft    := k - (leftside * tempreal) + sd;
          newleft    := larger(left,ROUND(altleft));
          altright   := k + ((listsize - leftside) * tempreal) + sd;
          newright   := smaller(right,ROUND(altright));
          dummy      := select(list,newleft,newright,k)
        END;

{comment : the following code partitions list[left..right] about"estimate".}

      estimate  := list[k];
      leftpart  := left;
      rightpart := right;
      exchange(list[left],list[k]);
      IF list[right] > estimate THEN exchange(list[right],list[left]);
      WHILE leftpart < rightpart DO
        BEGIN
         exchange(list[leftpart],list[rightpart]);
         leftpart  := leftpart  + 1;
         rightpart := rightpart - 1;
         WHILE list[leftpart]  < estimate DO leftpart  := leftpart  + 1;
         WHILE list[rightpart] > estimate DO rightpart := rightpart - 1;
        END;
      IF list[left] = estimate THEN exchange(list[left],list[rightpart])
       ELSE BEGIN
        rightpart := rightpart + 1;
        exchange(list[rightpart],list[right])
       END;
{comment : now adjust left & right so they surround the subset containing
	   the (k - left + 1)th smallest element. }
      IF rightpart <= K THEN left  := rightpart + 1;
      IF k <= rightpart THEN right := rightpart - 1;
    END;
 END; { of : if n < 1 }
END;  { of : function select }
