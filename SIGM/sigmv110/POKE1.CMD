*
*               poke1.cmd
*
set echo off
set talk off
erase
*
*       display current fcb
*
store (5*16)+13 to fcb1
store 0         to count
store ' '       to s
*
do  while count<12
    store s+chr(peek(fcb1+count)) to s
    store count+1                 to count
enddo  count
*
store len(s) to lenofs
@ 10,0  say 'Current fcb ===>'+$(s,2,lenofs)+'<==='
*
*        blank the fcb
poke fcb1,32,32,32,32,32,32,32,32,32,32,32,0,0,0,0,0
*
store 0         to count
store ' '       to s
*
do  while count<12
    store s+chr(peek(fcb1+count)) to s
    store count+1                 to count
enddo  count
@ 12,0  say 'fcb after poke ===>'+'&s'+'<==='
*
*        get parameters for called pgm
*
*store 'abc def **' to param
store '                    ' to param
@ 23,0 say 'Enter a string to use in the poke';
       get param
*
read
*
*
*        truncate, capitalize for CP/M
*
store trim(param) to param
****store !(param)    to param
*
*        convert ascii to decimal
*
store ' !"#$%&'       to tab1a
store chr(39) to tab1b
store '()'  to tab1c
store '*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`' to tab2
store 'abcdefghijklmnopqrstuvwxyz{|}~' to tab3
store tab1a + tab1b + tab1c + tab2 + tab3 to table
*
store 31   to base
store ' '  to dstring
store 0    to pointer
*
do  while pointer<len(param)
    store $(param,pointer+1,1)               to srchchar
    store @(srchchar,table)                  to position
    store dstring+str(position+base,3) + ',' to dstring
    store pointer + 1                        to pointer
*   ? 'srchchar=',srchchar
*   ? 'position=',position
*   wait
enddo  pointer
*
*        take off last comma
*
store len(dstring)        to leng
store $(dstring,1,leng-1) to dstring
*
*        poke the fcb
*
store 5*(16)+13 to fcb1
poke fcb1,&dstring
*
store 0         to count
store ' '       to s
*
do  while count<len(param)
    store s+chr(peek(fcb1+count)) to s
    store count+1                 to count
enddo  count
@ 14,0 say 'fcb after param poke ===>'+'&s'+'<==='
*
*        set up the call address
*
store 10*(16*16*16)  to ca
store ca+(4*(16*16)) to ca
set call to ca
store 'dummy' to adress 
*
*        do the call
*
*   call adress
return
+tab3 to table

*
store 31   to base
store ' '  to dstring
store 0    to pointer
*
do  while pointer<len(param)
    store $(param,pointer+1,1)               to srchchar
    store @(srchchar,table)                  to position
    store dstring+str(position+ba='
*
*        set up the call address
*
store 10*(16*16*16)  to ca
store ca+(4*(16*16)) to ca
set call to ca
store 'dummy' to adress 
*
*        do the call
*
*   call adress
return
