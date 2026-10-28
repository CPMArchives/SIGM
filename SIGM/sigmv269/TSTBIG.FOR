C	* Test of BIGCHR *			[TSTBIG.FOR]
C
      Yoshio MONMA	85-03-20
C
      INTEGER*1	   VPOS
      REAL*8	   ASTR,STRING
C
      DATA	   ASTR/'A String'/
C
      WRITE(2,200)
  200   FORMAT(1H0,5X,'* Test of BIGCHR *')
C
      VPOS = 10
      MODE = 0
      CALL BIGCHR(VPOS,ASTR,MODE1)
C		* Enlarged mode and return with elite
      MODE2 = 1
      CALL BIGCHR(20,'Test OK?',MODE2)
C		* Subsitution of string is nvalid in F80
      VPOS = 30
      STRING = 'BIGCHR'
      MODE3 = 2
      CALL BIGCHR(VPOS,STRING,MODE3)
C		* Return with condensed mode
      CALL BIGCHR(30,'BIGCHR',2)
      WRITE(2,210)
  210   FORMAT(1H0,5X,'* END of Test *')
      STOP
      END
      SUBROUTINE   BIGCHR(VPOS,STRING,MODE)
C
C	* Print STRING in Enlarged Mode at VPOS *
C
C	Written by Yoshio MONMA on 85-03-20
C
C     Arguments:
C        VPOS      Vertical position
C        STRING    Character string (A8), must be given in exact length
C        MODE	   Mode to be set after the printing STRING
C             = 0  Standard (Pica, 10char/inch)
C             = 1  Elite (Elite, 12char/inch) 
C             = 2  Condensed (15char/inch)
C
C	This routine is for EPSON RP-80 Printer.
C
      INTEGER*1    BIGM,ESC,LETF,NUL,SI,SO
      INTEGER*1    VPOS
      REAL*8       STRING
C
      DATA         ESC/Z'1B'/,  NUL/'00'/, SI/Z'0F'/, SO/Z'0E'/
      DATA         BIGM/Z'4D'/, LETF/Z'66'/
C
      WRITE(2,200) ESC,LETF,NUL,VPOS,SO,STRING
  200   FORMAT(1H ,5A1,A8)
      IF (MODE.EQ.1) WRITE(2,210) ESC,BIGM
  210   FORMAT(1H ,2A1)
      IF (MODE.EQ.2) WRITE(2,210) SI
      RETURN
      END
