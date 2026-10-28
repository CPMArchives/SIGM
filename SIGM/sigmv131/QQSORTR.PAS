FUNCTION qqsort_real( VAR A :real_array ;
                      left_1st,right_1st : INTEGER ) : BOOLEAN;
{
 Original Author : Richard C. Singleton (Sept 17, 1968)
 Reference       : Algorithm 347 ;Collected Algorithms of ACM.
	This function sorts the REAL array A ,from A[left_1st] to
  A[right_1st] , into ASCENDING order . To sort the entire array  A set
  left_1st := 1 , and right_1st := N ,where N is the order of the array.
  If the value passed for left_1st is less than or equal to the value
  passed for right_1st then no sorting is done and the function returns
  false.
	The sort method used is similar to QUICKERSORT by  R. S. Scowen
  (alg.271 ACM) which in turn is similar to the sort algorithm given by 
  T.N.Hibbard and to C.A.R.Hoare's QUICKSORT ( alg.64 ACM ) .Unlike the
  original QUICKSORT it is not truly recursive.
	The initial segment of the array A is split into left and right
  "halves" composed of elements smaller and larger respectively than the
  median of the leftmost , middle and rightmost members of the initial
  segment.The smaller of the 2 "halves" is split similarly and the basic
  process repeated until a subsegment is produced with fewer than eleven
  elements.Once such a subsegment is formed it is sorted by a straight 
  sinking insertion sort.
	The left and right bounds of the larger subsegment at each 
  iteration are "stacked" in the arrays "left_bound" & "right_bound" and
  "popped off"  once the smaller segment is fully sorted.Then the popped
  of segment is  treated as was the initial segment etc. until the entire
  initial segment is done.

Modified for Pascal/Z : October 1980 : Ray Penley
		        September 82 : Greg Acland
}
CONST
	konst		= 20;
VAR
	middle,
	tempvar		: REAL;
	left,right,
	newleft,newright,
	mid_index,
	element,pointer : INTEGER;
	left_bound,
	right_bound	: ARRAY [0..konst] OF INTEGER;
			 {Permit sorting up to 2EXP(konst + 1)-1 elements}
	alldone,
	past_midpoint,
	first,ok_array  : BOOLEAN;

BEGIN 				{$C-,M-,F-}
  left		:= left_1st;
  right		:= right_1st;
  pointer	:= 0;
  first		:= TRUE;
  alldone	:= FALSE;
  ok_array	:= left < right;
  IF ok_array THEN BEGIN
   REPEAT
     IF ((right-left) > 10)      {IF   : the segment has > 10 members}
     OR ( first )                {OR   : it is the initial segment   }
      THEN BEGIN                 {THEN : use splitting algorithm     }
       IF first THEN first := FALSE;
     { step 1 = find the middle element of the segment }
       mid_index	:= (left+right) DIV 2;
       middle		:= A[mid_index];
       newright		:= left;
       newleft		:= right;
     { step 2 = sort the left,middle and right elements of the segment }
       IF (A[left] > middle) THEN { swap them! }
	    BEGIN
	     A[mid_index]    := A[left];
             A[left]     := middle;
             middle := A[mid_index]
	    END;
       IF (A[right] < middle) THEN { swap them,then see if left element... }
	   BEGIN
	      A[mid_index]    := A[right];
              A[right]     := middle;
              middle := A[mid_index];
	      IF (A[left] > middle) THEN { ..left needs swapping again!}
		BEGIN
		  A[mid_index]    := A[left];
                  A[left]     := middle;
                  middle := A[mid_index]
		END;
	    END; { of : if A[right] < middle }
      { now the middle value is the median of left,middle and right values }
	past_midpoint := FALSE;
	REPEAT
      { step 3 = starting @ the rightmost  end seek a value
                 less than that of the middle element }
	  REPEAT
	    newleft := newleft - 1;
	  UNTIL A[newleft] <= middle;
          {and from the left seek a value greater than the middle}
	  REPEAT
	      newright := newright + 1;
	  UNTIL A[newright] >= middle;
	  IF (newright <= newleft) THEN { the found values are in the wrong }
	      BEGIN                     { halves  so swap them!  }
	        tempvar     := A[newleft];
                A[newleft]  := A[newright];
                A[newright] := tempvar;
	      END ELSE past_midpoint := TRUE;
         { when you pass the middle you have separated all elements 
           > middle to the right and all those < middle to the left. }
	UNTIL past_midpoint;
      IF (newleft-left) > (right-newright) THEN { keep the smaller half }
	    BEGIN                               { and stack the larger. }
            left_bound[pointer]   := left;
            right_bound[pointer]  := newleft;
            left 		  := newright
            END ELSE BEGIN
            left_bound[pointer]   := newright;
            right_bound[pointer]  := right;
            right       	  := newleft
            END;
       pointer := pointer + 1;
       END ELSE BEGIN { For each segment with < 11 members ( except the
			initial segment ) sort using a straight "sinking"
			insertion sort , by interchange of adjacent pairs.}
	 FOR element := (left+1) TO right DO
	   BEGIN
	     middle   := A[element];
	     newright := element - 1;
	     IF A[newright] > middle THEN
	       BEGIN
                 REPEAT
                   A[newright+1] := A[newright];
                   newright      := newright - 1;
                 UNTIL A[newright] <= middle;
                 A[newright+1]   := middle;
	       END;
	   END; { of : For element := (left + 1) ...}
	 pointer := pointer - 1;
	 IF pointer >= 0 THEN
	   BEGIN
	     left  := left_bound[pointer];
	     right := right_bound[pointer];
	   END ELSE alldone := TRUE;
       END;      { of : outermost if-then-else block }
  UNTIL alldone; { end of outermost repeat loop }
 END;            { of : if ok_array                  }
 qqsort_real := ok_array;
END;             { of : function qqsort_real }	{$C+,M+,F+}

