*
*               showmem.cmd
*
*               This command module is used to display memory
*               on the console.  Only printable characters show,
*               non-printable characters are shown as a period.
*               Memory is displayed in 64-byte chunks.
*
set echo off
set talk off
set bell off
erase
*
*       display memory
*
store '0123456789ABCDEF' to hextable
store ' ' to line
store '    ' to start
store '    ' to end
store t to reading
do while reading
    erase
    store t to badans
    do while badans
        @ 1,0 say '       To exit this function enter XXXX  '
        @ 2,0 say 'Enter the starting address to display (in hex 0-F) ===>';
              get start;
              picture '!!!!'
*
        read
*
        if  start = 'XXXX'
            return
        endif  start
*
        @ 3,0 say 'Enter the ending address to display   (in hex 0-F) ===>';
              get end;
              picture '!!!!'
*
        read
*
        store $(start,1,1) to start1
        store $(start,2,1) to start2
        store $(start,3,1) to start3
        store $(start,4,1) to start4
*
        store $(end,1,1)   to end1
        store $(end,2,1)   to end2
        store $(end,3,1)   to end3
        store $(end,4,1)   to end4
*
        store @(start1,hextable)  to st1
        store @(start2,hextable)  to st2
        store @(start3,hextable)  to st3
        store @(start4,hextable)  to st4
*
        store @(end1,hextable)    to en1
        store @(end2,hextable)    to en2
        store @(end3,hextable)    to en3
        store @(end4,hextable)    to en4
*
        if  st1 = 0 .or.;
            st2 = 0 .or.;
            st3 = 0 .or.;
            st4 = 0 .or.;
            en1 = 0 .or.;
            en2 = 0 .or.;
            en3 = 0 .or.;
            en4 = 0     
            store t to badans
            @ 23,0 say 'ERROR - use only 0-F to enter the address'
        else
	    store f to badans
            @ 23,0 say '                                         '
        endif  st1/en1
*
    enddo  badans
*
    store (st1-1)*(16*16*16) to saddr1
    store (st2-1)*(16*16)    to saddr2
    store (st3-1)*(16)       to saddr3
    store (st4-1)            to saddr4
*
    store saddr1 + saddr2+ saddr3 + saddr4 to saddr
*
    store (en1-1)*(16*16*16) to eaddr1
    store (en2-1)*(16*16)    to eaddr2
    store (en3-1)*(16)       to eaddr3
    store (en4-1)            to eaddr4
*
    store eaddr1 + eaddr2 + eaddr3 + eaddr4 to eaddr
*
    erase
    ? 'Displaying from &start hex to &end hex'
    ? '       Press escape to interrupt'
    ? ' '
    store 0 to cnt
    store ' ' to line
    do while cnt < (eaddr - saddr)
        do while len(line) < 65
            store chr(peek(saddr+cnt)) to byte
            if  byte < ' ' .or.;
                byte > '~'
                store '.' to byte
            endif  byte
*
            store line + byte to line
            store cnt + 1 to cnt
        enddo  line
*
        ? '===>' + $(line,2,64) + '<==='
        store ' ' to line
    enddo  cnt
*
    store ' ' to ans
    set intensity off
    set colon off
    ? ' '
    ? ' '
    ? 'Press any key to continue'
    @ 0,0 get ans
*
    read
*
    set intensity on
    set colon on
*
enddo reading
          store line + byte to line
            store cnt + 1 to cnt
        enddo  line
*
        ? '===>' + $(line,2,64) +       showmem.cmd
*
*               This command module is used to display memory
*               on the console.  Only printable characters show,
*               non-printable characters are shown as a period.
*               Memory is displayed in 64-byte chunks.
*
set echo off
set talk off
set bell off
erase
*
*       display memory
*
store '0123456789ABCDEF' to hextable
store ' ' to line
store '    ' to start
store '    ' to end
store t to reading
do while reading
    er