*
*   start.cmd
*
*   Glenn Story - 1/1/83
*
*  This command procedure starts up DBASE
*
set talk off
*
*  First get the date from the CPS card
*  we poke a small assembler routine to convert a DBASE string descriptor
* to an MBASIC string descriptor
* the code we are poking is as follows:
*
* CLOCK: MOV A,M;  get string length
*  STA DESC;  store into descriptor
*  INX H;  bump pointer
*  SHLD DESC+1;  store address
*  LXI H,DESC;  point to new descriptor
*  JMP 0f300h;  jump to clock driver in bdos
*
* DESC EQU CLOCK+20H
store 41984 to clock
poke clock, 126,32,164,34, 33, 164, 35, 33, 32, 164, 195, 0, 243
store "                   " to tod
set call to clock
call tod
*
*  now we have the time we can extract the date
*
store $(tod,2,8) to date
*
*  now tell the system
*
set date to &date
*  all my files, lord, are on drive b
set default to b
*
? "Current date set to ",date
? "dBASE II is ready"
set talk on





8   ;ZERO-PAGE,Y MODE   <LDX, STX>
       ;NONE OF ABOVE, DEFAULT TO ABSOLUTE OR IMPLICIT MODE
;---------------------------------------------------------
;
       DB    1           ;MAKE ONE PATCH
       DW    ORIGIN      ;DESTINATION OF DRIVER
       DW    CEND-CLOCK  ;LENGTH OF DRIVER
       DB    1           ;PAt get the date from the CPS card
*  we poke a small assembler routine to convert a DBASE string descriptor
* to an MBASIC string descriptor
* the code we are poking is as follows:
*
*  MOV A,M;  get string length
*  STA DESC;  store *   start.cmd
*
*   Glenn Story - 1/1/83
*
*  This command procedure starts up DBASE
*
set talk off
*
*  First get the date from the CPS card
*  we poke a small assembler routine to convert a DBASE string descriptor
* to an MBASIC string descriptor
* the code we are poking is as follows:
*
* CLOCK: MOV A,M;  get string length
*  STA DESC;  store into descriptor
*  INX H;  bump pointer
*  SHLD DESC+1;  store address
*  LXI H,DESC;  point to new descriptor
*  JMP 0f300h;  jump to clock dr