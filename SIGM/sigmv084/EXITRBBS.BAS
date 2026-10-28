100	'  EXITRBBS.BAS, version 1.1
120	'  Routine to allow users to leave comments before logging off
140	'  Original by Brian Kantor & Skip Hansen 09/81 (?)
160	'  Minor text changes, bye call, and time-on-system stuff added
180	'            by Ben Bronson, 10/11/81
200	'     Note that this is meant to be compiled and called "BYE.COM"
220	'  Modified for Macrostore-R 10-18-81 -CAF
240	'  Main routine for users to leave comments before logging off
241	' --------------------------------------------------------
242	' 15/Jun/82 Added clock routines from ENTRBBS to allow exit
243	' time of caller to be recorded. Caller status is checked from
244	' and recorded in CALLERS along with out time. TWit status callers
245	' don't get a chance to leave comments. TWit status may be entered
246	' LASTCALR in ENTRBBS (from USERS) or by a password utility like
247	' UTIL that a user has tried to break into. SYSOP bypasses the
248	' out time recording as he never makes it into CALLERS. Added date
249	' and "exit" to COMMENTS enteries so you can tell when and where
250	' they were entered (MINIRBBS enters "Mini"). Bill Bolton
251	' --------------------------------------------------------
252	' 09/Aug/82 Added routine from MINIRBBS to give time on system.
253	' Bill Bolton
254	' --------------------------------------------------------
260	'
280	DEFINT A-Z
300	DIM H(6),HT(6),HD(6),TOD(5),DOY(5)
320	ERS$=CHR$(8)+" "+CHR$(8)
330	MAGIC$ = "SUPER"
340	OPEN "I",1,"A:LASTCALR":
	INPUT #1,N$,O$,F$,DT$:
	CLOSE
360	PRINT
370	IF F$ = "TW" THEN
		GOTO 720
380	PRINT "Want to leave any comments (Y/N)? ";:
	C=1:
	GOSUB 980:
	C=0
400	IF LEFT$(B$,1)="N" OR LEFT$(B$,1)="n" THEN
		720
420	IF LEFT$(B$,1)<>"Y" AND LEFT$(B$,1)<>"y" THEN
		380
440	PRINT
460	OPEN "R",1,"A:C"+CHR$(&HCF)+"MMENTS. "+CHR$(&HA0),65:
	FIELD#1,65 AS RR$
480	GET#1,1:
	RE=VAL(RR$)+1:
	RL=65
500	IF RE=1 THEN
		RE=2
520	S$="From: "+N$+" "+O$+" "+DT$+" (Exit)":
	GOSUB 1200
540	PUT#1,RE
560	PRINT "Enter comments, <return> to end, (16 lines max)"
580	PRINT
600	PRINT "-->";
620	GOSUB 980
640	IF B$="" THEN
		700	
660	RE=RE+1:
	S$=B$:
	RL=65:
	GOSUB 1200:
	PUT#1,RE 
680	GOTO 600
700	S$=STR$(RE):
	RL=65:
	GOSUB 1200:
	PUT#1,1:
	CLOSE
720	GOSUB 1660:
	GOSUB 2300
730	IF N$ = MAGIC$ THEN
		GOTO 920		'Skip callers time out for SYSOP
740	OPEN "R",1,"A:CALLERS",60:
	FIELD#1, 60 AS RR$:
	GET #1,1
760	RE = VAL(RR$) + 1:
	RL = 60
780	GET #1,RE:
	INPUT#1,S$
800	IF INSTR(S$,":") THEN
		POINTER = INSTR(S$,":")
	ELSE
		POINTER = LEN(S$)
820	S$ = LEFT$(S$,POINTER + 2)  + " to " + TI$ + " " + F$ + MID$(S$,POINTER + 3)
840	GOSUB 1200
860	PUT #1,RE:
	CLOSE #1
880	'
920	PRINT
930	GOSUB 44000
940	RUN "A:SUPER.COM"
960	END
980	'
1000	'  Accept string into B$ from console
1020	'
1040	GOSUB 1320
1060	B$=SAV$
1080	IF LEN(B$)=0 THEN
		RETURN
1100	IF C=0 THEN
		1180
1120	FOR ZZ=1 TO LEN(B$)
1140		MID$(B$,ZZ,1)=CHR$(ASC(MID$(B$,ZZ,1))+32*(ASC(MID$(B$,ZZ,1))>96))
1160	NEXT ZZ
1180	RETURN
1200	'
1220	'  Fill and store disk record
1240	'
1260	LSET RR$=LEFT$(S$+SPACE$(RL-2),RL-2)+CHR$(13)+CHR$(10)
1280	RETURN
1300	'
1320	CHC=0:
	SAV$=""
1340	NCH=ASC(INPUT$(1))
1360	IF NCH=127 THEN
		1500
1380	IF NCH<32 THEN
		1560
1400	IF CHC>=62 THEN
		PRINT CHR$(7);:
		GOTO 1340
1420	SAV$=SAV$+CHR$(NCH):
	CHC=CHC+1:
	PRINT CHR$(NCH);
1440	IF CHC=55 THEN
		PRINT CHR$(7);
1460	GOTO 1340
1480	'
1500	IF CHC=0 THEN
		1340
	ELSE
		PRINT RIGHT$(SAV$,1);:
		 GOTO 1540
1520	IF CHC=0 THEN
		1340
	ELSE
		PRINT ERS$;
1540	CHC=CHC-1:
	SAV$=LEFT$(SAV$,CHC):
	GOTO 1340
1560	IF NCH=8 THEN
		1520
1580	IF NCH=13 THEN
		PRINT:
		RETURN
1600	IF NCH=21 THEN
		PRINT " #":
		GOTO 1320
1620	IF NCH<>24 OR CHC=0 THEN
		1340
1640	FOR BCC=1 TO CHC:
		 PRINT ERS$;:
	NEXT BCC:
	GOTO 1320
1660 ' Date getting subroutine
1680	BASEPORT = &H50
1700	CMDPORT = BASEPORT + 10
1720	DATAPORT = CMDPORT + 1
1740 '**********************************************************
1760 '*		READ THE DATE DIGITS			*
1780 '**********************************************************
1800	FOR DIGIT = 12 TO 7 STEP -1
1820		OUT CMDPORT,(&H10 + DIGIT)
1840		DOY(DIGIT - 7) = INP(DATAPORT)
1860	NEXT DIGIT
1880	YEAR= (DOY(5) * 10) + DOY(4)
1900	MONTH10 = DOY(3)
1920	MONTH1  = DOY(2)
1940	DAY10 = DOY(1)
1960	DAY1  = DOY(0)
1980 '**********************************************************
2000 '*		FORMAT THE FIRST DATE STRING		*
2020 '**********************************************************
2040	DATE1$="        "
2060	MID$(DATE1$,1,1) = RIGHT$(STR$(DAY10),1)
2080	MID$(DATE1$,2,1) = RIGHT$(STR$(DAY1),1)
2100	MID$(DATE1$,3,1) = "/"
2120	MID$(DATE1$,4,1) = RIGHT$(STR$(MONTH10),1)
2140	MID$(DATE1$,5,1) = RIGHT$(STR$(MONTH1),1)
2160	MID$(DATE1$,6,1) = "/"
2180	MID$(DATE1$,7,2) = RIGHT$(STR$(YEAR),2)
2200	DZ$ = DATE1$
2220	DT$ = LEFT$(DATE1$,5)
2240	DD$ = MID$(DATE1$,1,2)
2260	DM$ = MID$(DATE1$,4,2)
2280	RETURN
2300 '
2320 ' Time-finding subroutine
2340	FOR DIGIT = 5 TO 0 STEP -1
2360		OUT CMDPORT,(&H10 + DIGIT)
2380		TOD(DIGIT) = INP(DATAPORT)
2400		IF DIGIT = 5 THEN TOD(DIGIT) = TOD(DIGIT) AND 3
2420	NEXT DIGIT
2440	H(1) = TOD(5)
2460	H(2) = TOD(4)
2480	H(3) = TOD(3)
2500	H(4) = TOD(2)
2520	H(5) = TOD(1)
2540	H(6) = TOD(0)
2560	DH$ = "  ":
	DI$ = "  ":
	DS$ = "  "
2580	MID$(DH$,1,1) = RIGHT$(STR$(H(1)),1):
	MID$(DH$,2,1) = RIGHT$(STR$(H(2)),1):
	MID$(DI$,1,1) = RIGHT$(STR$(H(3)),1):
	MID$(DI$,2,1) = RIGHT$(STR$(H(4)),1):
	MID$(DS$,1,1) = RIGHT$(STR$(H(5)),1):
	MID$(DS$,2,1) = RIGHT$(STR$(H(6)),1)
2600	TI$=DD$+"-"+DH$+":"+DI$
2620	TD$=DH$+":"+DI$+":"+DS$
2640	RETURN
44000 '
44002 'CLOCK ROUTINES
44005 '
44270	PRINT:
	PRINT "The time now is (Hrs:Mins:Secs).... ";
44280	TF$="#"
44290	FOR I=1 TO 6
44300		PRINT USING TF$;H(I);
44310		IF I=2 THEN 
			PRINT ":";
44320		IF I=4 THEN 
			PRINT ":";
44330	NEXT I
44340	PRINT
44700 '  Now get hh/mm/ss stored by enterbbs
44710	HT(1)=PEEK(74):
	HT(2)=PEEK(75):
	HT(3)=PEEK(76)
44720	HT(4)=PEEK(77):
	HT(5)=PEEK(78):
	HT(6)=PEEK(79)
44730 '  And calculate the difference...
44740	IF H(6)<HT(6) THEN 
		H(6)=H(6)+10:
		H(5)=H(5)-1
44750	IF H(5)<HT(5) THEN 
		H(5)=H(5)+6:
		H(4)=H(4)-1
44760	IF H(4)<HT(4) THEN 
		H(4)=H(4)+10:
		H(3)=H(3)-1
44770	IF H(3)<HT(3) THEN 
		H(3)=H(3)+6:
		H(2)=H(2)-1
44780	IF H(2)<HT(2) THEN 
		H(2)=H(2)+10:
		H(1)=H(1)-1
44790	HD(6)=H(6)-HT(6):
	HD(5)=H(5)-HT(5):
	HD(4)=H(4)-HT(4)
44800	HD(3)=H(3)-HT(3):
	HD(2)=H(2)-HT(2):
	HD(1)=H(1)-HT(1)
44810	PRINT "You've been on the system for...... ";
44820	TF$="#"
44830	FOR I=1 TO 6
44840		PRINT USING TF$;HD(I);
44850		IF I=2 THEN 
			PRINT ":";
45860		IF I=4 THEN 
			PRINT ":";
45870	NEXT I
45880	PRINT:
	PRINT
45890	RETURN
