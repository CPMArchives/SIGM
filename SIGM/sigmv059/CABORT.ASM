;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; JAN 2, 1982	user level abort() for BCS C, vers 1.44	      ;
; uses MAC with CMAC.LIB and BDS.LIB, suitable for 8080       ;
; by Ernest E. Bergmann					      ;
;    Physics, Building #16				      ;
;    Lehigh University					      ;
;    Bethlehem, Pa. 18015				      ;
;							      ;
;	To use:	initialize in main():	abort(); /* =0 */     ;
;					next: ...	      ;
;		subsequently, at			      ;
;		any level:		abort(); /* #0 */     ;
;	will cause program flow back to			      ;
;	main() at location "next:"			      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	maclib	bds
	maclib	cmac

	direct
	define	abort
	enddir

	prelude	abort

	reloc lhld,spsave	; first time: (spsave)=0
	mov	a,h		; is it first time?
	ora	l
	reloc jz,initab		; if so, initialize
	xchg			; save (spsave) in de
	reloc lhld,bcsave	; restore original bc
	mov	b,h
	mov	c,l
	reloc lhld,pcsave	; restore original ret addr
	xchg			; (spsave) back to hl
	sphl			; old sp restored
	push	d		; restoring original ret addr
	ret			; abort() <> 0 for
				; subsequent calls

initab	pop	d	; here if first time called
	dad	sp	; initializes spsave,pcsave,bcsave
	reloc shld,spsave
	xchg
	reloc shld,pcsave
	push	h
	mov	l,c
	mov	h,b
	reloc shld,bcsave
	lxi	h,0	; return abort() = 0
	ret		; for initial call

bcsave	dw	0
pcsave	dw	0
spsave	dw	0

	postlude abort

	end
ubsequently, at			      ;
;		any level:		abort(); /* #0 */     ;