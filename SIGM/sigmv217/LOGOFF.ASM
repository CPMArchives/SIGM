org 100h
xra a
sta 05bh
mvi	c,9
lxi	d,msg
call	5
mvi	c,1
jmp	5
msg:	db 'Logged OFF -- Press any key to logon',13,10,'$'
end 100h
