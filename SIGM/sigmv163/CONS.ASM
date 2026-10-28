	;CONS - A PROGRAM TO TURN ON THE CAPTURE BUFFER
	;       THIS ALSO TURNS ON THE FOLLOWING:
	; 

	CPFLAG 	EQU 	0FD79H
	CPCNT  	EQU	0FD7DH
	CBUFP  	EQU	0FD7CH
	MTOP   	EQU	0FD7AH
        
		ORG	100H

	        PUSH H
		PUSH D

                XRA  A
                STA  CPCNT
                STA  CPCNT+1
                INR  A
		STA  CPFLAG

		LHLD (0006)
		SHLD MTOP
		LXI  D,4000H
		DB   0EDH,052H
		SHLD CBUFP

		POP  D
		POP  H
		JMP  0000H
		END
