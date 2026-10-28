* <<<=======================================================================>>>
*     This program is Copyrighted and the Sole Property of Keith R. Plossl
* 
*			Program Name	: DATELIB.CMD
*			Author		: Keith R. Plossl
*			Date Written	: February 1984
*
*  <++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++>
*  <           C O P Y R I G H T E D   S O F T W A R E   N O T I C E        >
*  <           =====================================================        >
*  <  This software is copyrighted under the laws of the United States of   >
*  <  America and all rights are reserved by Keith R. Plossl.  This program >
*  <  may be freely copied for non-commercial use provided the title block, >
*  <  modification history and this notice remain intact.  Copying this     >
*  <  program for Resale or for any other commercial purpose is STRICTLY    >
*  <  FORBIDDEN and subject to federal prosecution.       KRP 2/5/84        >
*  <++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++>
*
*                 M O D I F I C A T I O N    H I S T O R Y
*
*      Date			What				Who
*
* <<<=======================================================================>>>
*
*
*                  >>>> ----- W A R N I N G ----- <<<<
*
*  THE FOLLOWING IS LIST OF VARIABLES USED BY THIS LIBRARY.  CONSIDER THEM
*  TO BE RESERVED WORDS OR YOUR VARIABLES WITH THE SAME NAME WILL BE GONE.
*
*	 	DATE 			SYSD    
*		DAY            		JULDATE   
*		MONTH            	BASEDATE 
*		SYSDATE                 LEAP
*               ERRX			MM
*		DD			YY
*               BLNKS1			YEAR
*		OK
*
* <<<=======================================================================>>>
*
*   ------------------------  Date Routines -----------------------
*                                Library
*
*       This program is a date function library for DBASE II.
*
* <<<=======================================================================>>>
*
*
*   	 	  ----- Date Validation Routine -----
*     -----------------------------------------------------------
*     | Function Call: VDT             Input Parameters: DATE   |
*     |					Output Variable: OK     |
*     |                                 Possible Output: ERRX   |
*     -----------------------------------------------------------
*
*
*     Routine to Validate the variable DATE
*
*
if !(FUNCTION) = 'VDT' .and. type(DATE) <> 'U'
	store '                                                  ' to BLNKS1
	store $(BLNKS1,1,42)	   to ERRX
	store F to OK
*
*                   Initialize Month, Day and Year Variables
*
	store val($(DATE,1,2))    to MM
	store val($(DATE,4,2))    to DD
	store val($(DATE,7,2))    to YY
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
*    If none of the above apply the date is OK - Set Flag 
*
          otherwise
		store T to OK
	endcase
	release BLNKS1, ERRX, MM, DD, YY
endif (FUNCTION = 'VDT')
* <<------------------------------------------------------------------------->>
*
do case
*
* <<<=======================================================================>>>
*
*   	 ----- Fundamental Julian Date Calcuator Routine -----
*     -----------------------------------------------------------
*     | Function Call: JDT             Input Parameters: DATE   |
*     |					Output Variable: JULDATE|
*     -----------------------------------------------------------
*
	case !(FUNCTION) = 'JDT' .and. type(DATE) <> 'U'
		store DATE			to DATE
		store val($(DATE,1,2))		to MONTH
		store val($(DATE,4,2))		to DAY
		store val($(DATE,7,2))+1900	to YEAR
		store int(30.57*MONTH) + int(365.25*YEAR-395.25) + DAY 	to JULDATE
		release DATE, MONTH, DAY, YEAR
*
* <<<=======================================================================>>>
*
*
*      ----- Reconstruct Julian Date to Normal Date Routine -----
*     -----------------------------------------------------------
*     | Function Call: SDT             Input Parameters: JULDATE|
*     |					Output Variable: SYSDATE|
*     -----------------------------------------------------------
*
*
	case !(FUNCTION) = 'SDT' .and. type(JULDATE) <> 'U'
		store INT(JULDATE/365.26) + 1		to YEAR
		store JULDATE + int(395.25-365.25*YEAR)	to DAY
		if int(YEAR/4) * 4 = YEAR
			store 1 to LEAP
		else
			store 2 to LEAP
		endif
		if DAY > (91 - LEAP)
			store DAY + LEAP	to DAY
		endif
		store int(DAY/30.57)	to MONTH
		store DAY - int(30.57*MONTH) to DAY
		if MONTH > 12
			store 1 	to MONTH
			store YEAR + 1	to YEAR
		endif
		store YEAR - 1900	to YEAR
		store str(MONTH,2) + '/' + str(DAY,2) + '/' + str(YEAR,2) to SYSDATE
		release JULDATE, YEAR, MONTH, DAY, LEAP
*
* <<<=======================================================================>>>
*
*
*      ----- Generate Base Year Julian Format Date Routine -----
*     -----------------------------------------------------------
*     | Function Call: BDT             Input Parameters: DATE   |
*     |					Output Variable: BASDATE|
*     -----------------------------------------------------------
*
* Routine uses Jan 1, 1980 as Base (722830)
*
	case !(FUNCTION) = 'BDT' .and. type(DATE) <> 'U'
		store 722830		to BASEDATE
		store DATE		to SYSD
		store val($(SYSD,1,2))	to MONTH
		store val($(SYSD,4,2))	to DAY
		store val($(SYSD,7,2))+1900	to YEAR
		store int(30.57*MONTH) + int(365.25*YEAR-395.25) + DAY 	to JD
		store JD - BASEDATE	to BASDATE
		release BASEDATE, SYSD, MONTH, DAY, YEAR
*
* <<<=======================================================================>>>
*
*       Reconstruct Base Year Julian Date to Normal Date Routine 
*     -----------------------------------------------------------
*     | Function Call: SBT             Input Parameters: BASDATE|
*     |					Output Variable: SYSDATE|
*     -----------------------------------------------------------
*
* Routine uses Jan 1, 1980 as Base (722830)
*
*       
	case !(FUNCTION) = 'SBT' .AND. type(BASDATE) <> 'U'
		store 722830		to BASEDATE
		store BASDATE + BASEDATE		to JD
		store INT(JD/365.26) + 1		to YEAR
		store JD + int(395.25-365.25*YEAR)	to DAY
		if int(YEAR/4) * 4 = YEAR
			store 1 to LEAP
		else
			store 2 to LEAP
		endif
		if DAY > (91 - LEAP)
			store DAY + LEAP	to DAY
		endif
		store int(DAY/30.57)	to MONTH
		store DAY - int(30.57*MONTH) to DAY
		if MONTH > 12
			store 1 	to MONTH
			store YEAR + 1	to YEAR
		endif
		store YEAR - 1900	to YEAR
		store str(MONTH,2) + '/' + str(DAY,2) + '/' + str(YEAR,2)  to SYSDATE
		release BASDATE, BASEDATE, JD, YEAR, MONTH, DAY, LEAP
*
* <<<=======================================================================>>>
*
*		----- >>>  Otherwise Undefined <<< -----
*
	case !(FUNCTION) = 'VDT'
*		do nothing further
	otherwise
		store 'UNKNOWN' to FUNCTION
	endcase
if FUNCTION <> 'UNKNOWN'
	release FUNCTION
endif
return
*
*
* <<<=======================================================================>>>
*
*                      End of Date Routines Library 
*
* <<<=======================================================================>>>
*     This program is Copyrighted and the Sole Property of Keith R. Plossl
* <<<=======================================================================>>>
*

