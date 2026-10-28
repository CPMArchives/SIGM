* MENU.SIG  08/14/83
* This is the traffic cop of the system - routes you to
* the proper data base
* make sure all is written
RESET 
ERASE
STORE t TO forever
STORE '?' TO command
DO WHILE forever
    @  2,12 SAY "SIG/M AMATEUR COMPUTER GROUP OF NEW JERSEY"
    @  5,25 SAY "MAIN MENU"
    @  8,17 SAY "1 - Run Orders Program"
    @ 10,17 SAY "2 - Run Inventory Program"
    @ 12,17 SAY "3 - Quit to dBASEII"
    @ 14,17 SAY "4 - Quit to CP/M"
    @ 16,21 SAY "ENTER SELECTION"
    @ 16,38 GET command picture '9'
    READ
    DO CASE
        CASE command = '1'
            USE
            DO main.sig
        CASE command = '2'
            USE   
            DO main.inv
        CASE command = '3'
            ERASE
            RESET
            @ 08,00 SAY "HIT ESCAPE KEY for dBASE - - any other key to continue this program"
            WAIT
            ERASE
            STORE '?' TO command
        CASE command = '4'
            STORE f TO forever
            SET CONSOLE OFF
            ERASE
            QUIT
    ENDCASE
ENDDO while forever
