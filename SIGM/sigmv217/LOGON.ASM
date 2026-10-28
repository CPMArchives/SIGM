;logoff used with logon -- reset system to force signon next time out
;ken prevo, digital dc 
org 100h
xra a
sta 05bh
mvi	c,9
lxi	d,msg
call	5
mvi	c,1
call	5
jmp	0
msg:	db 'System Logged OFF -- Press any key to Logon',13,10,'$'
end 100h
