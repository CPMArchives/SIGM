100 ' Auto-dialling & dumb terminal program for the Modem Technology UDM-1200
110 ' Programmed by Gary Woodman of Sabbath Computer Services 84/12/13
120 ' Written in MBASIC-86 for the IBM PC
130 ' Hardware required:
140 '    IBM PC parallel port (specify address below)
150 '    UDM-1200 modem
160 '    cable to suit:
170 '          IBM                    UDM
180 '   pin 2 (data bit 0)<------>pin 4 (Off-Normal relay)
190 '   pin 3 (data bit 1)<------>pin 5 (Dial relay)
200 '   pin 19 (ground)<--------->pin 1 (ground)
210 '
220 ON ERROR GOTO 840			'particularly ERROR 57
230 DEFINT A-Z				'why not?
240 SER.STAT = &H2FE			'IBM's COM2: 8250 Modem Status Register
250 PAR.PORT = &H378			'this is the port I use
260 OFF.NORM = 0			'Off Normal signal is logic 0
270 ON.NORM  = 1			'return from Off Normal is logic 1
280 BREAK = 0				'Break pulse is logic 0
290 MAKE = 2                            'Make pulse is logic 1
300 DELAY.BREAK = 70			'note spec 62-70 millisec
310 DELAY.MAKE = 35			'note spec 31-35 ms
320 DELAY.OFFNORM = 3600		'note spec 3-6 seconds
330 DELAY.IDP = 1200			'note spec .8-4 sec
340 INPUT "Number to dial";DIAL$	'what's your fancy?
350 CLOSE #1                            'close the COM file (hang up)
360 OPEN "com2:300,n,8,1,cs,ds" AS #1	'open it again (loop the line)
370 FOR PAUSE = 1 TO DELAY.OFFNORM : NEXT PAUSE		'wait spec time
380 OUT PAR.PORT,OFF.NORM+MAKE          'setup UDM Off-Normal, Make pulse
390 FOR PAUSE = 1 TO DELAY.IDP : NEXT PAUSE	'wait spec time
400 FOR DIGIT = 1 TO LEN(DIAL$)		'consider each digit of the number
410     DIAL = VAL(MID$(DIAL$,DIGIT,1))	'take its value
420     GOSUB 720                       'do the dialling
430 NEXT DIGIT
440 OUT PAR.PORT,ON.NORM+MAKE           'return from Off-Normal, Make
450 FOR PAUSE = 1 TO DELAY.IDP : NEXT PAUSE	'wait spec time
460 FOR CDWAIT = 1 TO 2800		'wait approx 12 secs for carrier
470					'time depends on instr.in loop
480     MSR = INP(SER.STAT)             'read modem status
490     IF (MSR AND 128) THEN 510       'wait for carrier
500 NEXT CDWAIT
510 FOR PAUSE = 1 TO 500 : NEXT         'allow spurious carrier to go away
520 FOR CDWAIT = 1 TO 2800
530     MSR = INP(SER.STAT)             'read modem status
540     IF (MSR% AND 128) THEN 580      'wait for carrier
550 NEXT CDWAIT
560 ' The modem failed to connect to another with 300 baud Answer mode
570 PRINT "Sorry, no carrier..." : STOP
580 ' This is the dumb terminal part
590 WHILE 0 = 0				'do this forever
600     KEY.CHAR$ = INKEY$              'get a byte from the keyboard
610     WHILE KEY.CHAR$ <> ""           'if none, go check COM buffer
620 ' This is the terminal emulation exit condition - ^Z
630         IF KEY.CHAR$ = CHR$(26) THEN CLOSE : END
640         PRINT#1,KEY.CHAR$;          'if one, send it to COM port
650         KEY.CHAR$ = ""		'exit this loop
660     WEND
670     WHILE NOT EOF(1)                'if COM buffer empty, go check keyboard
680         COM.CHAR$ = INPUT$(1,#1)    'if not, get character from buffer
690         IF COM.CHAR$ <> CHR$(10) THEN PRINT COM.CHAR$; 'and display it
700     WEND
710 WEND
720 ' Routine to do dialling via one bit of a parallel port 
730 PRINT DIAL;				'display the number we're dialling
740 IF DIAL = 0 THEN DIAL = 10		'not possible to dial 0 pulses
750 FOR TIMES = 1 TO DIAL		'as required
760     OUT PAR.PORT,BREAK              'Break signal
770     FOR PAUSE = 1 TO DELAY.BREAK : NEXT     'hold for spec time
780     OUT PAR.PORT,MAKE               'Make signal
790     FOR PAUSE = 1 TO DELAY.MAKE : NEXT      'hold for spec time
800 NEXT TIMES
810 FOR PAUSE = 1 TO DELAY.IDP : NEXT PAUSE	'wait spec time
820 RETURN
830 ' Single-purpose error-handler for 57 Device I/O Error
840 IF ERR <> 57 THEN PRINT "Error";ERR;"in line";ERL : RESUME
850 LSR = INP(MSR-1)			'this is the Line Status Register
860 IF LSR AND 1 THEN PRINT "Data ready"
870 IF LSR AND 2 THEN PRINT "Overrun"
880 IF LSR AND 4 THEN PRINT "Parity"
890 IF LSR AND 8 THEN PRINT "Framing"
900 IF LSR AND 16 THEN PRINT "Break"
910 IF LSR AND 32 THEN PRINT "THRE"
920 IF LSR AND 64 THEN PRINT "TSRE"
930 RESUME
940 STOP
