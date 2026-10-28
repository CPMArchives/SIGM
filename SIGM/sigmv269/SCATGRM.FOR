C [SCATGRM.FOR of JUGCPM Vol.12]
C
C     ** SCATTER DIAGRAM BY GRAPH0 **  [»ÝÌß½Þ] 
C        Yoshio MONMA       84-04-12
C
C        This program has been written in FORTRAN-80 and the output
C     printer has been assumed to be EPSON's RP-80.  The input data 
C     must be in FORT0X.DAT (X=6-10).  So, you have to prepare the 
C     data file as follows:
C
C             REN FORT0X.DAT=SCATGRM.DAT
C     or
C             PIP FORT0X.DAT=SCATGRM.DAT
C
C        Also note that the data file (FORT0X.DAT) must be placed on 
C     the same disk with the .COM file.
C
C     * Reference *
C       T. Haga & S. Hashimoto: "Fundamentals of Programming for 
C       Statistical Analysis" (Ä³¹²¶²¾· PROGRAM É ·¿),
C       JUSE (Æ¯¶·ÞÚÝ), 1980.
C
C     * LIST OF INPUT DATA *
C       (I5)      INPT                            (CON)
C       (2I5)     N,KDTA                          (DK)
C       (15A4)    TITLE                           (DK)
C       (2A8)     XAXIS,YAXIS                     (DK)
C       (15A4)    VFRMT                           (DK)
C       (VFRMT)   X(I),Y(I) <N pairs>             (DK)
C       (4F10.2)  XMIN,XMAX,YMIN,YMAX             (DK)
C       (2I5)     N,KDTA <Next data set>          (DK)
C
      PROGRAM    SCATGRM
C
      INTEGER*1  ESC,BIGM
      REAL*4     TITLE(15),VFRMT(15),X(300),Y(300)
      REAL*8     XAXIS,YAXIS
C
      DATA       ESC,BIGM/Z'1B',Z'4D'/
C
C                Set RP-80 Printer in Elite Size
      WRITE(2,200) ESC,BIGM
  200   FORMAT(1H ,2A1)
      WRITE(1,100) 
  100   FORMAT(1H0,11X,'** SCATTER DIAGRAM BY GRAPH0 (SCATGRM) ** '/)
C
   10 WRITE(1,110)
  110  FORMAT(1H ,5X,'Input data file [FORT0X.DAT], 6<=X=<10: ')
      READ(1,500) INPT
  500   FORMAT(2I5)
      IF ((INPT.NE.0).AND.(INPT.LT.6.OR.INPT.GT.10)) GOTO 10
   20 READ(INPT,500) N,KDTA
      IF (N.NE.0) GOTO 25
      WRITE(2,250)
      STOP
C
   25 READ(INPT,510) TITLE
  510   FORMAT(1X,15A4)
      READ(INPT,520) XAXIS,YAXIS
  520   FORMAT(1X,2A8)
      WRITE(2,100)
      WRITE(2,210) TITLE
  210   FORMAT(1H ,10X,15A4/)
      WRITE(2,220) INPT,N,KDTA
  220   FORMAT(1H ,10X,'INPT =',I2,', N =',I3,', KDTA =',I2)
C
      READ(INPT,510) VFRMT
      WRITE(1,120) N
  120 FORMAT(1H0,5X,'Data Size =',I3,', Reading data from DK...')
      DO 30 I=1,N
        READ(INPT,VFRMT) X(I),Y(I)
   30 CONTINUE
      IF (KDTA.EQ.1)          GOTO 50
      WRITE(2,230)
  230   FORMAT(1H0,10X,'* INPUT DATA *'/15X,'I',6X,'X(I)',11X,'Y(I)'/)
      DO 40 I=1,N
        WRITE(2,240) I,X(I),Y(I)
  240     FORMAT(1H ,I15,1P2E15.5)
   40 CONTINUE
C
   50 READ(INPT,530) XMIN,XMAX,YMIN,YMAX
  530   FORMAT(4F10.2)
C
      IF (KDTA.NE.1) WRITE(2,250) TITLE
  250   FORMAT(1H1/11X,15A4)
      WRITE(1,130)
  130   FORMAT(1H0,5X,'Call GRAPH0')
      CALL GRAPH0(XAXIS,YAXIS,X,Y,N,XMIN,XMAX,YMIN,YMAX)
                              GOTO 20
      END
C
      SUBROUTINE  GRAPH0(XAXIS,YAXIS,X,Y,N,XMIN,XMAX,YMIN,YMAX)
C
C  ** PLOT OF SCATTER DIAGRAM **
C
C     * Reference *
C       T. Haga & S. Hashimoto: "Fundamentals of Programming for 
C       Statistical Analysis" (Ä³¹²¶²¾· PROGRAM É ·¿),
C       JUSE (Æ¯¶·ÞÚÝ), 1980.
C
      INTEGER*1  H(37,73)
      DIMENSION  X(1),Y(1),SCALE(9)
      REAL*8     XAXIS,YAXIS
C
      DATA       II,JJ,LL/37,73,9/
C     
      DX = (XMAX-XMIN)/(JJ-1)
      DY = (YMAX-YMIN)/(II-1)
      DO 20 I=1,II
        DO 10 J=1,JJ
          H(I,J) = ' '
   10   CONTINUE
   20 CONTINUE
C
      IF (XMAX*XMIN.GE.0.0) GOTO 40
      J = -XMIN/DX+1.5
      DO 30 I=1,II
        H(I,J) = Z'96'
   30 CONTINUE
   40 IF (YMAX*YMIN.GE.0.0) GOTO 60
      I = YMAX/DY+1.5
      DO 50 J=1,JJ
        H(I,J) = Z'95'
   50 CONTINUE
   60 DO 70 K=1,N
        I = (YMAX-Y(K))/DY+1.5
        J = (X(K)-XMIN)/DX+1.5
        H(I,J) = Z'EC'
   70 CONTINUE
      SCALE(1) = XMIN
      DO 80 L=2,LL
        SCALE(L) = SCALE(L-1)+LL*DX
   80 CONTINUE
      WRITE(2,600) XAXIS,YAXIS
      WRITE(2,610) SCALE 
      WRITE(2,620)
      DO 100 I=1,II
   90     WRITE(2,630) YMAX,(H(I,J),J=1,JJ),YMAX
        YMAX = YMAX-DY
  100 CONTINUE
      WRITE(2,620)
      WRITE(2,610) SCALE
      WRITE(2,640)
C
  600 FORMAT(1H0,10X,'XAXIS = ',A8,', YAXIS = ',A8/)
  610 FORMAT(1H ,6X,9F9.3)
  620 FORMAT(1H ,11X,1H:,8('........:'))
  630 FORMAT(1H ,F9.3,' -',73A1,1H-,F9.3)
  640 FORMAT(1H0)
C
      RETURN
      END
           