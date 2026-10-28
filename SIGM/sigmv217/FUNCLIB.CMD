* <<<=======================================================================>>>
*     This program is Copyrighted and the Sole Property of Keith R. Plossl
* 
*			Program Name	: FUNCLIB.CMD
*			Author		: Keith R. Plossl
*			Date Written	: March 1984
*
*  <++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++>
*  <           C O P Y R I G H T E D   S O F T W A R E   N O T I C E        >
*  <           =====================================================        >
*  <  This software is copyrighted under the laws of the United States of   >
*  <  America and all rights are reserved by Keith R. Plossl.  This program >
*  <  may be freely copied for non-commercial use provided the title block, >
*  <  modification history and this notice remain intact.  Copying this     >
*  <  program for Resale or for any other commercial purpose is STRICTLY    >
*  <  FORBIDDEN and subject to federal prosecution.       KRP 3/1/84        >
*  <++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++>
*
*                 M O D I F I C A T I O N    H I S T O R Y
*
*      Date			What				Who
*
* <<<=======================================================================>>>
*
* This program is a general function library for DBASE II.  This file
* will need to have the function called by a name to execute the case.
* Load the five character function code in a variable called FUNCTION.
* Load the parameters as required by the function needed and say: DO FUNCLIB
*
*                  >>>> ----- W A R N I N G ----- <<<<
*
*  THE FOLLOWING IS LIST OF VARIABLES USED BY THIS LIBRARY.  CONSIDER THEM
*  TO BE RESERVED WORDS OR YOUR VARIABLES WITH THE SAME NAME WILL BE GONE.
*
*		FLD
*		C:CNT           	
*		C:NUM	
*		ENDS
*       	SPCD
*
do case
* <<<=======================================================================>>>
*
*	      ----- >>> Lower Case ASCII Function <<< -----
*     -----------------------------------------------------------
*     | Function Call: LCASE           Input Parameters: FIELDV |
*     |					Output Variable: FIELDV |
*     -----------------------------------------------------------
*
	case !(FUNCTION) = 'LCASE' .AND. TYPE(FIELDV) <> 'U'
		store 1		to C:CNT
		store len(trim(FIELDV)) to ENDS
		do while C:CNT <= ENDS
			store rank($(FIELDV,C:CNT,1)) to C:NUM
			if C:NUM >= 65 .and. C:NUM <= 90
				if C:CNT = 1
					store CHR(C:NUM+32) to FLD
				else
					store FLD + CHR(C:NUM+32) to FLD
				endif
			else
				store FLD + CHR(C:NUM) to FLD
			endif
			store C:CNT + 1 to C:CNT
		enddo
		store FLD to FIELDV
	release 
* <<<=======================================================================>>>
*
*	    ----- >>> Normalize Case ASCII Function <<< -----
*     -----------------------------------------------------------
*     | Function Call: NORMA           Input Parameters: FIELDV |
*     |					Output Variable: FIELDV |
*     -----------------------------------------------------------
*
	case !(FUNCTION) = 'NORMA' .AND. TYPE(FIELDV) <> 'U'
		store 2		to C:CNT
		store F		to SPCD
		store len(trim(FIELDV)) to ENDS
		store $(!(FIELDV),1,1)	to FLD
		do while C:CNT <= ENDS
			store rank($(FIELDV,C:CNT,1)) to C:NUM
			if C:NUM >= 65 .and. C:NUM <= 90
				store C:NUM + 32 to C:NUM
			endif
			if C:NUM >= 97 .and. C:NUM <= 122
				if SPCD
					store FLD + !(CHR(C:NUM)) to FLD
					store F to SPCD
				else
					store FLD + CHR(C:NUM) to FLD
				endif
			else
				if C:NUM = 32
					store T to SPCD
				else
					store F to SPCD
				endif
				store FLD + CHR(C:NUM) to FLD
			endif
			store C:CNT + 1 to C:CNT
		enddo
		store FLD to FIELDV
	release FLD, C:CNT, C:NUM, ENDS, SPCD
* <<<=======================================================================>>>
*
*		----- >>>  Otherwise Undefined <<< -----
*
	otherwise
		store 'UNKNOWN' to FUNCTION
		
endcase
if FUNCTION <> 'UNKNOWN'
	release FUNCTION
endif
return
* <<<=======================================================================>>>
*
*       	End of DBASE II  General Function Library
*
* <<<=======================================================================>>>
*     This program is Copyrighted and the Sole Property of Keith R. Plossl
* <<<=======================================================================>>>
*

