* <<<=======================================================================>>>
*     This program is Copyrighted and the Sole Property of Keith R. Plossl
* 
*			Program Name	: MATHLIB.CMD
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
* This program is a mathematics function library for DBASE II.  This file
* will need to have the function called by a name to execute the case.
* Load the three character function code in a variable called FUNCTION.
* Load the parameters as required by the function needed and say: DO MATHLIB
*
*                  >>>> ----- W A R N I N G ----- <<<<
*
*  THE FOLLOWING IS LIST OF VARIABLES USED BY THIS LIBRARY.  CONSIDER THEM
*  TO BE RESERVED WORDS OR YOUR VARIABLES WITH THE SAME NAME WILL BE GONE.
*
*	 	A 			PASS    
*		ABSX            	POWRX   
*		ATNX            	RADIANS 
*		COSX            	RD      
*		CSX			RNDX            
*		DELTA           	SEED    
*		EXPO            	SEPX    
*		EXPX            	SINX    
*		FACT            	SLOGX   
*		LOGX            	SNX
*		LOGO            	SQRD    
*		NUMBER          	SQRX    
*       	NX              	TANX    
*
do case
* <<<=======================================================================>>>
*
*	      ----- >>> Absolute Value Function <<< -----
*     -----------------------------------------------------------
*     | Function Call: ABS             Input Parameters: NUMBER |
*     |					Output Variable: ABSX   |
*     -----------------------------------------------------------
*
	case !(FUNCTION) = 'ABS' .AND. TYPE(NUMBER) <> 'U'
		if NUMBER < 0
			store -1*NUMBER	 to ABSX
		endif
		release NUMBER
* <<<=======================================================================>>>
*
*	      ----- >>> Random Number Function <<< -----
*     -----------------------------------------------------------
*     | Function Call: RND             Input Parameters: SEED   |
*     |	Default Seed = .375	        Output Variable: RNDX   |
*     -----------------------------------------------------------
*
	case !(FUNCTION) =  'RND' .AND. TYPE(SEED) <> 'U'
		if SEED <= 0 .OR. SEED >= 1
			store .375 to SEED
		endif
		store (SEED*9821+.211327)-int(SEED*9821+.211327) to SEED
		store SEED to RNDX
* <<<=======================================================================>>>
*
*	       ----- >>> Square Root Function <<< -----
*     -----------------------------------------------------------
*     | Function Call: SQR             Input Parameters: NUMBER |
*     |					Output Variable: SQRX   |
*     -----------------------------------------------------------
*
	case !(FUNCTION) = 'SQR' .AND. TYPE(NUMBER) <> 'U'
		if NUMBER < 0
			store -1*NUMBER	 to NUMBER
		endif
		store 1 to A, SQRX
		store F  to SQRD
		do while .not. SQRD
			store .5*(A + NUMBER/A) to SQRX
			store SQRX-A  to DELTA
			if DELTA < 0
				store -1*DELTA to DELTA
			endif
			if DELTA < .000001
				store T  to SQRD
			else
				store SQRX to A
			endif
		enddo
		release NUMBER, A, SQRD, DELTA

* <<<=======================================================================>>>
*
*	     ----- >>> Normal Probability Function <<< -----
*
*     It computes the area under the normal curve such that a number
*     of zero yields a 50% or .5000 area.
*     -----------------------------------------------------------
*     | Function Call: PRB             Input Parameters: NUMBER |
*     |					Output Variable: PRBX   |
*     -----------------------------------------------------------
*
	case !(FUNCTION) = 'PRB' .AND. TYPE(NUMBER) <> 'U'
		store F to FLG
		if NUMBER < 0
			store T to FLG
			store -1*NUMBER	 to NUMBER
		endif
		if NUMBER < 3.08 .and. NUMBER > -3.08
			store .436184 to A
			store -.120168 to B
			store .937298 to C
			store .398942 to D2
			store -1.000000*NUMBER*NUMBER/2.000000 to D1
			store D1 to NX, POWRX
			store 1.000000+NX to EXPX
			store 1.000000 to DELTA, FACT, PASS
			do while PASS < 14
				store PASS + 1 to PASS
				store PASS*FACT to FACT
				store POWRX*NX to POWRX
				store EXPX to EXPO
				store EXPX+POWRX/FACT to EXPX
			enddo
			store EXPX to DX
			store DX * D2 to DX
			release NX, EXPO, EXPX, DELTA, POWRX, FACT, PASS
			store 1.000000/(1.000000 + .3326 * NUMBER) to EX
			store 1.00 - DX * (A*EX + B*EX*EX + C*EX*EX*EX) to PRBX
			store str(PRBX,6,4) to SEPX
			store &SEPX to PRBX
		else
			store .999999 to PRBX
		endif
		if FLG
			store 1.00 - PRBX to PRBX
		endif
		release A, B, C, D1, D2, DX, EX, FLG, NUMBER, SEPX

* <<<=======================================================================>>>
*
*	----- >>> Exponential Function (e to X power) <<< -----
*     -----------------------------------------------------------
*     | Function Call: EXP             Input Parameters: NUMBER |
*     |					Output Variable: EXPX   |
*     -----------------------------------------------------------
*
	case !(FUNCTION) = 'EXP' .AND. TYPE(NUMBER) <> 'U'
		store NUMBER to NX, POWRX
		store 1+NX to EXPX
		store 1 to DELTA, FACT, PASS
		do while DELTA > .0001
			store PASS + 1 to PASS
			store PASS*FACT to FACT
			store POWRX*NX to POWRX
			store EXPX to EXPO
			store EXPX+POWRX/FACT to EXPX
			store EXPX-EXPO to DELTA
		enddo
		store STR(EXPX,12,4) to SEPX
		store &SEPX to EXPX
		release NUMBER, NX, EXPO, DELTA, POWRX, FACT, SEPX, PASS
* <<<=======================================================================>>>
*
*		   ----- >>> Radians Function <<< -----
*     -----------------------------------------------------------
*     | Function Call: RAD             Input Parameters: DEGREES|
*     |					Output Variable: RADIANS|
*     -----------------------------------------------------------
*
	case !(FUNCTION) = 'RAD' .and. type(DEGREES) <> 'U'
		store DEGREES*3.1415962/180.000000 to RADIANS
		release DEGREES
*
* <<<=======================================================================>>>
*
*		   ----- >>> Sine Function <<< -----
*     -----------------------------------------------------------
*     | Function Call: SIN             Input Parameters: RADIANS|
*     |					Output Variable: SINX   |
*     -----------------------------------------------------------
*
	case !(FUNCTION) = 'SIN' .AND. TYPE(RADIANS) <> 'U'
		store RADIANS	to RD
		store RD-RD*RD*RD/6+RD*RD*RD*RD*RD/120-RD*RD*RD*RD*RD*RD*RD/5040 to SINX
		store SINX+RD*RD*RD*RD*RD*RD*RD*RD*RD/362880 to SINX
		release RADIANS, RD
* <<<=======================================================================>>>
*
*		  ----- >>> Cosine Function <<< -----
*     -----------------------------------------------------------
*     | Function Call: COS             Input Parameters: RADIANS|
*     |					Output Variable: COSX   |
*     -----------------------------------------------------------
*
	case !(FUNCTION) = 'COS' .AND. TYPE(RADIANS) <> 'U'
		store RADIANS	to RD
		store 1-RD*RD/2+RD*RD*RD*RD/24-RD*RD*RD*RD*RD*RD/720 to COSX
		store COSX+RD*RD*RD*RD*RD*RD*RD*RD/40320 to COSX
		store COSX-RD*RD*RD*RD*RD*RD*RD*RD*RD*RD/3628800 to COSX
		release RADIANS, RD
* <<<=======================================================================>>>
*
*		 ----- >>> Tangent Function <<< -----
*     -----------------------------------------------------------
*     | Function Call: TAN             Input Parameters: RADIANS|
*     |					Output Variable: TANX   |
*     -----------------------------------------------------------
*
	case !(FUNCTION) = 'TAN' .AND. TYPE(RADIANS) <> 'U'
		store RADIANS to RD
		store RD-RD*RD*RD/6+RD*RD*RD*RD*RD/120-RD*RD*RD*RD*RD*RD*RD/5040 to SNX
		store SNX+RD*RD*RD*RD*RD*RD*RD*RD*RD/362880 to SNX
		store 1-RD*RD/2+RD*RD*RD*RD/24-RD*RD*RD*RD*RD*RD/720 to CSX
		store CSX+RD*RD*RD*RD*RD*RD*RD*RD/40320 to CSX
		store CSX-RD*RD*RD*RD*RD*RD*RD*RD*RD*RD/3628800 to CSX
		store SNX/CSX to TANX
		release RADIANS, RD, SNX, CSX
		
* <<<=======================================================================>>>
*
*		 ----- >>> Arc Tangent Function <<< -----
*     -----------------------------------------------------------
*     | Function Call: ATN             Input Parameters: NUMBER |
*     |					Output Variable: ATNX   |
*     -----------------------------------------------------------
*
	case !(FUNCTION) = 'ATN' .AND. TYPE(NUMBER) <> 'U'
		store NUMBER to NX
		if NX*NX < 1
			store NX-NX*NX*NX/3+NX*NX*NX*NX*NX/5-NX*NX*NX*NX*NX*NX*NX/7 to ATNX
			store ATNX+NX*NX*NX*NX*NX*NX*NX*NX*NX/9 to ATNX
		else
			store 1.5707963-1/NX+1/(3*NX*NX*NX)-1/(5*NX*NX*NX*NX*NX) to ATNX
			store ATNX+1/(7*NX*NX*NX*NX*NX*NX*NX)-1/(9*NX*NX*NX*NX*NX*NX*NX*NX*NX) to ATNX
		endif
		release NUMBER, NX

* <<<=======================================================================>>>
*
*	   ----- >>> Natural (Naperian) Logarithm <<< -----
*     -----------------------------------------------------------
*     | Function Call: LNX             Input Parameters: NUMBER |
*     |					Output Variable: LOGX   |
*     -----------------------------------------------------------
*
	case !(FUNCTION) = 'LNX' .AND. TYPE(NUMBER) <> 'U'
		store (NUMBER-1.000000)/(NUMBER+1.000000) to NX, POWRX, LOGX
		store 1 to DELTA, PASS
		do while DELTA > .001
			store PASS + 2 to PASS
			store POWRX*NX*NX to POWRX
			store LOGX  to LOGO
			store LOGX+POWRX/PASS to LOGX
			store LOGX-LOGO to DELTA
		enddo
		store 2.00*LOGX to LOGX
		store STR(LOGX,12,4) to SLOGX
		store &SLOGX to LOGX
		release NUMBER, NX, LOGO, DELTA, POWRX, PASS, SLOGX
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
*       	End of DBASE II  Mathematical Function Library
*
* <<<=======================================================================>>>
*     This program is Copyrighted and the Sole Property of Keith R. Plossl
* <<<=======================================================================>>>
*

