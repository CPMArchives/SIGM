maclib DISKDEF.LIB

;*****************************************************
;*						     *
;*	disk parameter blocks for four drives:	     *
;*						     *
;*****************************************************
;
;	a standard four drive CP/M system is defined by
		disks	4
		diskdef 0,1,26,6,1024,243,64,64,2
	dsk	set	0
		rept	3
	dsk	set	dsk+1
		diskdef %dsk,0
		endm
		endef
;
		end
