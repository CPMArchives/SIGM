* -----------------------------------------------------------------------------
*			Program Name	: VALDATE.TST
*			Author		: Keith R. Plossl
*			Date Written	: January 1982
* -----------------------------------------------------------------------------
*  Program to Obtain and Validate the Date if System Date is Not Set
*
*  dBase II has date checking if it has been set already bypass
*  everything else -- set OK to T and MM = 0 to bypass it all
*
if DATE() = '00/00/00'
     store F   to OK
else
     store T   to OK
     store 0   to MM
endif
do while .not. OK
*
*                   Initialize Loop Variables
*
     store $(BLNKS,1,8)            to DATE:VAR
     store $(BLNKS,1,42)	   to ERRX
*
*                   Get Date Input
*
     @ 18,15 say 'Enter Date as MM/DD/YY '
     @ 18,43 get DATE:VAR  picture '##/##/##'
     read
*
*                   Initialize Month, Day and Year Variables
*
     store val($(DATE:VAR,1,2))    to MM
     store val($(DATE:VAR,4,2))    to DD
     store val($(DATE:VAR,7,2))    to YY
*
*                   Date Validation Routine
*
     do case
*
*    If Month or Day exceeds 12 or 31 or is less than 1 or if 
*    Year is less than 1980 then Error Results
*
          case MM<1 .or. MM>12 .or. DD<1 .or. DD>31 .or. YY<80
               store '       Invalid Date - Reenter'   to ERRX
*
*     If the Month is Apr., Jun., Sep. or Nov. Test Number of
*     days for over 30.  If over Set Error Message
*
          case MM=4 .or. MM=6 .or. MM=9 .or. MM=11 
	       if DD>30
               store 'Thirty Days hath September, etc. - Reenter'   to ERRX
	       else
		    store T to OK
	       endif
*
*     If the Month is Feb. Check for Number of Days and Leap Year
*     if not leap year and Days = 29 then Set Error Message
*
          case MM=2 .and. DD>28 .and. ((1900 + YY)/4)<>int(((1900 + YY)/4))
               store '     Not a leap year - Try Again'   to ERRX
*
*    If the Month is Feb. and the Days exceed 29 Set Error Message
*
          case MM=2 .and. DD>29
               store 'February has a Maximum of 29 Days - Reenter' to ERRX
*
*    If none of the above apply the date is OK - Set Flag and Loop out
*
          otherwise
               @ 20,00
               store T   to OK
               loop
     endcase
     @ 20,00
     @ 20,15 say ERRX
enddo (.not. OK)
*
*    If Valid Date Was Entered at dBase II start Bypass Variable 
*    release and Date Set.  Month is > Zero if not set at start.
*
if MM>0
     release ERRX, OK, MM, DD, YY
     set date to &DATE:VAR
     clear gets
endif
return
*
*		End of Date Validation Program
*