/* ED8.C */

/* altered for Software Toolworks compiler with M80 option */
#include ed0.c
#include ed1.ccc
cpmcall(o,c) int o; char c;	/* new: cpmcall absent from original listing */
{
#asm
	POP	H	;RETURN
	POP	D	;CHAR C -- INPUT OR OUTPUT
	POP	B	;INT O -- OPCODE
	PUSH	B
	PUSH	D
	PUSH	H	;REPLACE RETURN
	CALL	5
	MOV	L,A
	MVI	H,0
/*	RET		 Note: Software Tookworks compiler supplies RET */
#endasm
}	/* added */
syscstat()
{
int c;
	c=cpmcall(6,-1);
	if (c==0){		/* correction of original version */
		return(-1);
	}
	else {
		return(c);
	}
}
syscin()	/* extensively altered to recognize escape sequences */
{		/* from H19/H89 special keys */
int s,c;
	while ((c=cpmcall(6,-1))==0) {
		;
	}
	if (c==ESC1) {
		while ((c=cpmcall(6,-1))==0) {
			;
		}
		if (c=='?') {
			while ((c=cpmcall(6,-1))==0) {
				;
			}
/* "switch" and "case" construct can be altered to a sequence of	    */
/* "else if" statements if compiler lacks "switch".			    */
/* Looks slow, but main body is executed only in command mode and only	    */
/* for escape sequences */
			switch (c) {
				case 'q': return(UP1);
				case 'x': return(UP2);
				case 'r': return(DOWN2);
				case 't': return(LEFT1);
				case 'v': return(RIGHT1);
				case 'w': return(INS1);
				case 'M': return(ESC1);
				case 'y': return(DEL1);
				case 'p': return(GTOCH);
				case 's': return(ZAP1);
				case 'n': return(DTOCH);
				case 'u': return(HOME);
				default: continue;
			}
		}
		else {
			switch (c) {
				case 'S': return(DSCROL);
				case 'W': return(USCROL);
				case 'U': return(GOTO);
				case 'V': return(LSTRT);
				case 'Q': return(ABT1);
				case 'P': return(EDIT1);
				case 'T': return(LEND);
				case 'R': return(ESC1);
				case 'J': return(ERASE);
				default: return(c);
			}
		}
	}
	else {
		return(c);
	}
}
syscout(c) char c;
{
	cpmcall(6,c);
	return(c);
}
syslout(c) char c;
{
	cpmcall(5,c);
	return(c);
}
sysend()
{
#asm
	LHLD	6
	DCX	H
/*	RET		 Note: Software Tookworks compiler supplies RET */
#endasm
}	/* added */
sysopen(name,mode) char *name, *mode;
{
int file;
	if ((file=fopen(name,mode))==0) {
		return(ERR);
	}
	else {
		return(file);
	}
}
sysclose(file) int file;
{
	fclose(file);
	return(OK);
}
sysrdch(file) int file;
{
int c;
	if ((c=getc(file))==-1) {
		return(EOF);
	}
	else if (c==LF) {	/* map LF to CR for Software Toolworks	*/
		return(CR);	/* compiler */
	}
	else {
		return(c);
	}
}
syspshch(c,file) char c; int file;
{
	if (c==CR) {		/* map CR to LF for Software Toolworks	 */
		if (putc(LF,file)==-1) {	/* compiler */
			error("disk write failed");
			return(ERR);
		}
	}
	else if (putc(c,file)==-1) {
		error("disk write failed");
		return(ERR);
	}
	else {
		return(c);
	}
}
syspopch(file) int file;
{
	error("syspopch() not implemented");
	return(ERR);
}
syschkfn(args) char *args;
{
	if (args[0] == EOS) {	/* add check for zero-length file name */
		message("no file name");
		return(ERR);
	}
	else {
		return(OK);
	}
}
syscopfn(args,buffer) char *args, *buffer;
{
int n;
	n=0;
	while (n<SYSFNMAX-1) {
		if (args[n]==EOS) {
			break;
		}
		else {
			buffer[n]=args[n];
			n++;
		}
	}
	buffer[n]=EOS;
}
sysdnmov(n,d,s) int n,d,s;
{
/* extensively altered to allow LDDR for Z80 processors using parity check
   for processor type.	Also checks for zero-length move to avoid moving
   everything */
#asm
	POP	PSW	;RETURN
	POP	H	;SOURCE
	POP	D	;DESTINATION
	POP	B	;LENGTH
	PUSH	PSW	;RESTORE RETURN
	MOV	A,C
	ORA	B
	JZ	SYSDN3
	MVI	A,2
	INR	A
	JPE	SYSDN1
	DB	0EDH,0B8H	;LDDR INSTRUCTION FOR Z80
	JMP	SYSDN3
;
SYSDN1: MOV	A,B
	ORA	C
	JZ	SYSDN3
	MOV	A,M
	STAX	D
	DCX	H
	DCX	D
	DCX	B
	JMP	SYSDN1
;
SYSDN3: POP	H
	PUSH	H
	PUSH	H
	PUSH	H
	PUSH	H
/*	RET		 Note: Software Tookworks compiler supplies RET */
#endasm
}	/* added */
sysupmov (n,d,s) int n,d,s;
/* extensively altered to allow LDIR for Z80 processors using parity check
   for processor type.	Also checks for zero-length move to avoid moving
   everything */
{
#asm
	POP	PSW	;RETURN
	POP	H	;SOURCE
	POP	D	;DESTINATION
	POP	B	;LENGTH
	PUSH	PSW	;RESTORE RETURN
	MOV	A,C
	ORA	B
	JZ	SYSUP3
	MVI	A,2
	INR	A
	JPE	SYSUP1
	DB	0EDH,0B0H	;LDIR INSTRUCTION FOR Z80
	JMP	SYSUP3
;
SYSUP1: MOV	A,B
	ORA	C
	JZ	SYSUP3
	MOV	A,M
	STAX	D
	INX	H
	INX	D
	DCX	B
	JMP	SYSUP1
;
SYSUP3: POP	H
	PUSH	H
	PUSH	H
	PUSH	H
	PUSH	H
/*	RET		 Note: Software Tookworks compiler supplies RET */
#endasm
}	/* added */
pmax){
		editp++;
		outx