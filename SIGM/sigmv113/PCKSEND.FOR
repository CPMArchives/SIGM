C     This Fortran program should be run on the mainframe in conjunction 
C     with a Basic program on the IBM PC to transfer Kermit.Fix to the PC.
C     Daphne Tzoar, January 1983
C     Columbia University Center for Computing Activities

      integer a(64)
      
      write(6,50)
50    format(' Ready to transfer data......')

C     Get terminal handshake
100   read (5,10,end=35)x
10    format(a1)

C     Get line from file
35    read (7,20,end=90)a
20    format(64a1)

C     Write to tty
      write (6,25)a
25    format(' ',64a1,';')
      goto 100
90    continue

C     Get final handshake
      write (6,30)
30    format(' ',65('@'))
      stop
      end
