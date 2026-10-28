* main.sig 08/18/83
* main command program of inventory data base
* get the drive letter from where we have hidden it
* NOTE - in all cases label what the endif is the if for and
* the enddo is the do for. saves a lot of time debugging.
STORE CHR(PEEK(063))TO dr
USE &dr.:sig/m INDEX &dr.:orders
STORE t TO first
* set up the forever loop for this data base
DO WHILE t
    * to speed things up - only change the parts of the
    * screen that you have to
    IF first
        * if you want intensity - set intensity on here and off after endif first
        * that way the data stands out.
        * set up screen and prompts
        ERASE
        STORE '<F>orward, <B>ackward, <D>elete/Recall, <H>elp' TO prompt1
        STORE '<S>earch, <M>aintenance, <P>rint, <V>oucher, <R>eports' TO prompt2
        STORE '<A>dd, <E>dit, <Q>uit to main menu' TO prompt3
        STORE 'Main Order Module ' TO mode
        @  1,25 SAY mode
        @  2, 0 SAY "+--------------------------------------"
        @  2,39 SAY "----------------------------------------+"
        @  3, 5 SAY "ORDER NUMBER:"
        @  3,43 SAY "Complete:"
        @  4, 8 SAY "Last name:"
        @  4,46 SAY "First:"
        @  5,10 SAY "Address:"
        @  6, 9 SAY "(line 2):"
        @  7, 9 SAY "(line 3):"
        @  8,13 SAY "City:"
        @  8,46 SAY "State:"
        @  8,65 SAY "ZIP:"
        @ 10, 2 SAY "Volumes:"
        @ 12, 3 SAY "Amount:"
        @ 12,46 SAY "Enter:"
        @ 12,64 SAY "Ship:"
        @ 13, 2 SAY "Remarks:"
        @ 14, 2 SAY "Remarks:"
        @ 16, 0 SAY "Backorder:"
        @ 17,44 SAY "Catalog:"
        @ 18, 2 SAY "Shipped:"
        @ 18,26 SAY "Shipped:"
        @ 18,62 SAY "Update:"
        @ 19, 0 SAY "+--------------------------------------"
        @ 19,39 SAY "----------------------------------------+"
        @ 20,12 SAY prompt1
        @ 21,12 SAY prompt2
        @ 22,12 SAY prompt3
    ENDIF first
    STORE f TO first
    STORE '?' TO command
    * check if record marked for deletion
    IF *
        STORE 'Deleted' TO deleted
    ELSE
        STORE '       ' TO deleted
    ENDIF *
    @  1, 0 SAY deleted
    @  3,19 SAY order
    @  3,53 SAY comp
    @  4,19 SAY lname
    @  4,53 SAY fname
    @  5,19 SAY addr1
    @  6,19 SAY addr2
    @  7,19 SAY addr3
    @  8,19 SAY city
    @  8,53 SAY state
    @  8,70 SAY zip
    @ 10,11 SAY vol1
    @ 12,11 SAY amt using '$###.##'
    @ 12,53 SAY entered
    @ 12,70 SAY shipped
    @ 13,11 SAY rem1
    @ 14,11 SAY rem2
    @ 16,11 SAY bo
    @ 17,53 SAY catalog
    @ 18,11 SAY bo:ship
    @ 18,35 SAY bo2:ship
    @ 18,70 SAY dayu
    @ 22,56 SAY 'WHAT NEXT?'
    @ 22,70 GET command PICTURE '!'
    READ
    CLEAR GETS
    DO CASE
        CASE command = 'A'
            DO add.sig
            * note the comma will go to last record as well as 'B'
        CASE (command = 'B' .OR. command = ',')
            * move backwards one record
            SKIP -1
        CASE command = 'D'
            * switch the current record from deleted to recalled
            IF *
                RECALL
            ELSE
                DELETE
            ENDIF
        CASE command = 'E'
            DO edit.sig
            * note the period will go forward one record as well as F
        CASE (command = 'F' .OR. command = '.')
            * move forward one record
            SKIP
        CASE command = 'H'
            * display a screen full of instructions
            STORE t TO first
            ERASE
            @ 05,07 SAY 'This program works - or at least we have not yet been able'
            @ 06,07 SAY 'to find major bugs, so let us assume YOU are doing something'
            @ 07,07 SAY 'causing the problem. Before you call us, please try to solve it.'
            @ 09,07 SAY 'Remember, the message above the top line tells you the '
            @ 10,07 SAY 'program module you are in, and whether the file is marked'
            @ 11,07 SAY 'for deletion (to actually delete you must also run the purge'
            @ 12,07 SAY 'program on the maintenance menu.) The material below the '
            @ 13,07 SAY 'bottom line tells you what choice of action you have. They'
            @ 14,07 SAY 'are logical and only one of the listed options will work.'
            @ 15,07 SAY '(Other than a few built in aids, such as a period advancing'
            @ 16,07 SAY 'one record, a comma going back one and a "Q" as an exit'
            @ 17,07 SAY 'from a menu with letter options.)    SO..........'
            @ 19,07 SAY 'Relax for a few minutes - and try again!'
            @ 22,20 SAY 'Hit RETURN to Continue '
            SET CONSOLE OFF
            WAIT
            SET CONSOLE ON
        CASE command = 'M'
            DO maintain.sig
        CASE command = 'P'
            DO print.sig
        CASE command = 'Q'
          ERASE
          STORE t TO forever
          RETURN
      CASE command = 'R'
            DO report.sig
        CASE command = 'S'
            DO search.sig
        CASE command = 'V'
            DO voucher.sig
    ENDCASE
ENDDO while t
