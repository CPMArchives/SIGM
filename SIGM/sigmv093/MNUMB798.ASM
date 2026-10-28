;
;			MNUMB797.ASM
;
;	Telephone number overlay file for MODEM797.
;
; This file can be edited to make a new library of telephone
; numbers for MODEM7. Each entry must be 32 bytes long and
; no more than 26 (A-Z) telephone numbers are allowed. Follow
; the format for the library entries already in the file; be
; sure spaces are used, not tabs. R at the end of a number
; indicates a ringback system.
;
; Procedure for use:
;
;	1) Edit this file for new numbers,
;	2) Assemble the file,
;	3) Overlay MODEM797.COM with MNUMB797.HEX using DDT,
;	4) SAVE 64 MODEM797.COM
;
; NOTE FOR THOSE REVISING MODEM7: Check the location of NUMBLIB in
; MODEM7 to make sure the ORG is correct in this file.
;
;
	ORG	0617H
;
NUMBLIB:
;	'----5---10---15---20---25-----32'
DB	'A=Amrad             703-734-1387'	;'A'
DB	'B=Ben Bronson       312-955-4493'	;'B'
DB	'C=CBBS Pasadena     213-799-1632'	;'C'
DB	'D=PMMI              703-379-0303'	;'D'
DB	'E=Tech. CBBS        313-846-6127'	;'E'
DB	'F=Ron Fowler       313-729-1905R'	;'F'
DB	'G=Gasnet NASA       301-344-9156'	;'G'
DB	'H=Dave Hardy        313-846-6127'	;'H'
DB	'I=Wayne Hammerly    301-953-3753'	;'I'
DB	'J=RBBS Pasadena     213-356-1034'	;'J'
DB	'K=David Kozinn      216-334-4604'	;'K'
DB	'L=Program Store     202-337-4694'	;'L'
DB	'M=Kelly Smith       805-527-9321'	;'M'
DB	'N=SuperBrain Sys    617-862-0781'	;'N'
DB	'O=R.L.Plouffe       703-524-2549'	;'O'
DB	'P=K.Petersen       313-759-6569R'	;'P'
DB	'Q=Cranford,NJ RBBS  201-272-1874'	;'Q'
DB	'R=Bill Earnest      215-398-3937'	;'R'
DB	'S=SYSOP BBS (pw rq) 313-885-0506'	;'S'
DB	'T=Roger Amidon (pw) 609-799-7598'	;'T'
DB	'U=Frank Caperello   609-771-8133'	;'U'
DB	'V=Bruce Ratoff      201-272-1037'	;'V'
DB	'W=                              '	;'W'
DB	'X=                              '	;'X'
DB	'Y=                              '	;'Y'
DB	'Z=                              '	;'Z'
;	'----5---10---15---20---25-----32'
;
	END
;
