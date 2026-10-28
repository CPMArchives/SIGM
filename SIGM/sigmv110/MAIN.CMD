* main.cmd 02/09/83
* main command program of database
* this is a dBASEII database we use in a number of applications
* it has been adopted to a sample ACGNJ database, and you can
* modify it further to suit your particular application. note that
* the link files has not yet been included in the menu structure.
* also note that we have not implemented all of the features
* we contemplate, so that some program features are not yet
* available. lastly, the starting point on this program was
* Adam Green 's "dBASE II User' s guide " published by Software
* Bank, 1 Faneuil Hall Marketplace, Boston, MA 02109. We highly 
* recommend that book as the best thing around to get started in
* dBASEii and suggest you may even want to start off with
* a Software Bank seminar.
*
*
* this program runs well under both cp/m and cp/m 86. to run
* under cp/m 86 just change the name of this files to main.prg.
* 
* one known bug, if you edit on the duprec format you
* will not see the changes until second viewing. We
* think it relates to too many memory variables.

* comments, suggestions and improvements are welcome.
*                                                    
* Send to:
* Steve Leon
* Department of Law
* 48th floor
* 2 World Trade Center
* New York, NY 10047
* (212)488-7677
* or (201) 886-1658
* display sign-on message while initializing system
DO sign-ON.acg

* initialize variables, set up environment, use files, etc.
DO init.acg

* set up the loop
DO WHILE t
  
  * set up screen and prompts
  SET FORMAT TO SAY-rec
  STORE '<F>orward, <B>ackward, <D>elete/Recall, <H>elp' TO prompt1
  STORE '<S>earch, <E>dit, <P>rint, <R>eports, <M>aintenance' TO prompt2
  STORE '<A>dd or <Q>uit to CP/M' TO prompt3
  STORE 'Main Menu ' TO mode
  STORE '?' TO command
  
  * find out if the current record is marked for deletion
  *  DO delcheck.acg 
   IF *
      STORE 'Deleted' TO deleted
   ELSE
      STORE ' ' TO deleted
   ENDIF * 
  
  
  * show the current record, and find out what to do next
  STORE ' ' TO send
  READ
  
  
  * perform selected function
  DO CASE
      
    CASE command = 'A' 
      DO ADD.acg
      
    CASE (command = 'B' .OR. command = ',' )
      * move backwards one record
      SKIP -1
      
    CASE command = 'D' 
      * switch the current record from deleted to recalled
      * DO DELETE.acg

      IF *
         RECALL
      ELSE
         DELETE
      ENDIF * 

    CASE command = 'E' 
      STORE # TO recordno
      SET INDEX to
      GOTO recordno
      RELEASE recordno
      RECALL 
      DO EDIT.acg
      
    CASE (command = 'F' .OR. command = '.' )
      * move forward one record
      SKIP
      
    CASE command = 'H' 
      DO help.acg
      
    CASE command = 'M' 
      DO maintain.acg
      
    CASE command = 'P' 
      DO PRINT.acg
      
    CASE command = 'Q' 
      * prevent sign-off message
      	SET console OFF
      ERASE
      QUIT
      
      
    CASE command = 'R' 
      DO REPORT.acg
      
    CASE command = 'S' 
      DO search.acg
      
      
  ENDCASE 
  
  * loop back again
ENDDO WHILE t 


