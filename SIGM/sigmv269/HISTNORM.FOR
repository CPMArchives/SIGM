C [HISTNORM.FOR of JUGCPM Vol.12]
C
C     ** HISTOGRAM AND NORMAL DISTRIBUTION **   [¾²·ÌÞÝÌß É ¹ÝÃ²]
C
C        Yoshio MONMA                                     84-05-08   
C
C        This program has been written in FORTRAN-80 and the output
C     printer has been assumed to be EPSON's RP-80.  The input data 
C     must be in FORT0X.DAT (X=6-10).  So, you have to prepare the 
C     data file as follows:
C
C             REN FORT0X.DAT=HISTNORM.DAT
C     or
C             PIP FORT0X.DAT=HISTNORM.DAT
C
C        Also note that the data file (FORT0X.DAT) must be placed on the
C     same disk with the .COM file.
C
C     * Reference *
C       T. Haga & S. Hashimoto: "Fundamentals of Programming for 
C       Statistical Analysis" (Ä³¹²¶²¾· PROGRAM É ·¿),
C       JUSE (Æ¯¶·ÞÚÝ), 1980.
C
C	Nomenclature is as follows:
C
C     INPT  [I*1]  File reference no. for input data (6<=INPT<=10)
C        N  [I*2]  Data size
C     KDTA  [I*2]  Code to specify output of data (KDTA=1: No)
C    TITLE  [R*4]  Title (15A4)
C    VFRMT  [R*4]  Variable FORMAT for data (15A4)
C     X(N)  [R*4]  Array of data
C       KK  [I*1]  No. of classes
C     XMIN  [R*4]  Min. of X(N)
C        D  [R*4]  Width of a class
C
C     * List of input data *
C       INPT (I5)    Standard input file ref. no. of F80 
C ---------------------------------------------------------
C                    6<= INPT <= 10
C       Following data are input from FORTXX.DAT (XX=INPT)
C          N (I5)     Data size
C       KDTA (I5)     Data output (KDTA=1: No)
C      TITLE (15A4)   Title
C      VFRMT (15A4)   Variable format for the array of data X(N)
C       X(N) (VFRMT)  Array of the data
C         KK (I5)     No. of classes
C       XMIN (F10.5)  Lower bound of the data
C          D (F10.5)  Width of the class
C ---------------------------------------------------------
C       INPT (I5)     [Next data set]
C
      PROGRAM      HSTNRM
C
      INTEGER*1    SI,INPT,KDTA,KK
      REAL*4       X(500),TITLE(15),VFRMT(15)
C
      DATA         ESC,BIGM/Z'1B',Z'4D'/
C
      WRITE(1,1000)
 1000   FORMAT(1H ,5X,'** Histogram and Normal Distribution ',
     1         '(HISTNORM) **'/)
      WRITE(2,2000) ESC,BIGM
 2000   FORMAT(1H ,2A1)
C
   10 WRITE(1,1010)
 1010   FORMAT(1H ,8X,'Specify input file [FORT0X.DAT], X in I5) =')
      READ(1,1020) INPT
 1020   FORMAT(16I5)
      IF (INPT.LT.6.OR.INPT.GT.10)       GOTO 10
   20 READ(INPT,1020) N,KDTA
      IF (N.LE.0) STOP
C
      WRITE(2,1000)
      READ(INPT,6010) TITLE
 6010   FORMAT(1X,15A4)
      READ(INPT,6010) VFRMT
      WRITE(1,1030) N
 1030   FORMAT(1H0,5X,'DATA SIZE =',I4,', Reading data from DK...')
      READ(INPT,VFRMT) (X(I),I=1,N)
      READ(INPT,6020) KK,XMIN,D
 6020   FORMAT(I5,2F10.5)
      WRITE(2,2010) TITLE
 2010   FORMAT(1H0,5X,15A4)
      WRITE(2,2020) N,KDTA
 2020   FORMAT(1H0,10X,'N =',I4,5X,'KDTA =',I2)
      IF (KDTA.NE.1) WRITE(2,2030) (X(I),I=1,N)
 2030   FORMAT(1H ,1P5E14.5)
C
      WRITE(1,1040)
 1040   FORMAT(1H0,5X,'* Call STAT0 *')
      CALL STAT0(X,N,SX,AVGX,SXX,S,V,SIGX,SKEW,FKURT,GEARY)
      WRITE(2,2040) AVGX,SIGX,SKEW,FKURT,GEARY
 2040   FORMAT(1H0,5X,'Avg. =',1PE15.5,', SD =',E15.5/6X,
     1         'Skewness =',0PF8.4,', Kurtosis =',F8.4,
     2         ',  Geary =',F8.4/)
C
      WRITE(1,1050)
 1050   FORMAT(1H0,5X,'* Call HISTGM *')
      CALL HISTGM(X,N,KK,XMIN,D)
C
      WRITE(1,1060)
 1060   FORMAT(1H0,5X,'* Sorting...(SORT1)')
      CALL SORT1(X,N)
C
      WRITE(2,2050)
 2050   FORMAT(1H1)
      WRITE(2,2010) TITLE
      WRITE(1,1070)
 1070   FORMAT(1H0,5X,'* Call NRPLOT *')
      CALL NRPLOT(X,N)
      WRITE(2,2050)
C
                              GOTO 20
      END
C
      SUBROUTINE STAT0 (X,N,SX,AVGX,SXX,S,V,SIGX,SKEW,FKURT,GEARY)
C
C     ** Fundamental Statistics **
C
      DIMENSION X(1)
C
      SX = 0.0
      SXX = 0.0
      DO 10 I=1,N
        SX = SX+X(I)
        SXX = SXX+X(I)*X(I)
   10 CONTINUE
      FN = N
      AVGX = SX/FN
      S = SXX-SX*AVGX
      V = S/(FN-1.0)
      SIGX = SQRT(V)
      S3 = 0.0
      S4 = 0.0
      GEARY = 0.0
      DO 20 I=1,N
         D = X(I) - AVGX
         S3 = S3 + D*D*D
         S4 = S4 + D*D*D*D
         GEARY = GEARY + ABS(D)
   20 CONTINUE
      SKEW = S3/(FN*SIGX**3)
      FKURT = S4/(FN*SIGX**4)
      GEARY = GEARY/(FN*SIGX)
      RETURN
      END
C
      SUBROUTINE   HISTGM(X,II,KK,XMIN,D)
C
C     * Histogram *
C
C     Arguments:           Input        |    Output
C      DTAID     [R*8]  Data id. (A8)   |  <No change> 
C      X(II)     [R*4]  Array of data   |  <No change>     
C         II     [I*2]  Data size       |  <No change>
C         KK     [I*1]  No. of classes  |  <No change>
C       XMIN     [R*4]  Min. of data    |  <No change>   
C          D     [R*4]  Width of class  |  <No change> 
C   
      INTEGER*1    K,KK,KKM,H(51),HSPACE,HVRTL,HSTAR,HPLUS,N(20)
      REAL*4       X(1)
C
      DATA         HSPACE,HVRTL,HSTAR,HPLUS /' ','|',Z'EC','+'/
C
      WRITE(2,200) KK,XMIN,D
  200   FORMAT(1H0,5X,'No. of classes (KK) =',I3,', XMIN =',F10.3,
     1         ', Width (D) =',F7.3/)
      KKM = KK - 2
      DO 10 K=1,KK
         N(K) = 0
   10 CONTINUE
      DO 15 I=1,II
         K = (X(I)-XMIN)/D+2.0
         IF (K.LT.1) K = 1
         IF (K.GT.KK) K = KK
         N(K) = N(K) + 1
   15 CONTINUE
      NMAX = 0
      DO 20 K=1,KK
         IF (N(K).GT.NMAX) NMAX = N(K)
   20 CONTINUE
      KEISU = (NMAX-1)/50+1
      J5 = 5*KEISU
      J50 = 10*J5
      WRITE(2,210) (J,J=J5,J50,J5)
  210   FORMAT(1H ,21X,1H|,10I5/4X,'From',6X,'To',6X,51('-'))
      XH = XMIN
      NT = 0
      DO 70 K=1,KK
         DO 30 J=1,51
            H(J) = HSPACE
   30    CONTINUE         
         DO 35 J=1,51,10
            H(J) = HVRTL
   35    CONTINUE
         NK = (N(K)+KIESU-1)/KEISU+2
         IF (NK.EQ.1)         GOTO 45
         DO 40 J=2,NK
            H(J) = HSTAR
   40    CONTINUE
   45    NT = NT + N(K)
         J = FLOAT(NT*50)/FLOAT(II)+1.999
         H(J) = HPLUS
         IF (K.EQ.1)          GOTO 50
         IF (K.EQ.KK)         GOTO 55
         WRITE(2,220) XL,XH,N(K),(H(I),I=1,51)
  220      FORMAT(1H ,F7.3,' -',F7.3,I4,1X,51A1)
                              GOTO 60
   50    IF (N(1).NE.0) WRITE(2,230) XH,N(1),(H(I),I=1,51)
  230                     FORMAT(1H ,7X,' -',F7.3,I4,1X,51A1)
                              GOTO 60
   55    IF (N(K).NE.0) WRITE(2,240) XL,N(K),(H(I),I=1,51)
  240                     FORMAT(1H ,F7.3,' -',7X,I4,1X,51A1)
   60    XL = XH
         XH = XH + D
   70 CONTINUE
      WRITE(2,250) (J,J=10,100,10)
  250   FORMAT(1H ,3X,'From',6X,'To',6X,51('-')/22X,1H|,10I5,1H%///)
      RETURN
      END
C
      SUBROUTINE SORT1 (X,N)
C
C     ** SORT IN ASCENDING ORDER **
C
      DIMENSION X(1)
C
      NM1 = N-1
      DO 20 I=1,NM1
        K = I
        IP1 = I+1
        DO 10 J=IP1,N
          IF (X(J).LT.X(K)) K = J
   10   CONTINUE
        W = X(I)
        X(I) = X(K)
        X(K) = W
   20 CONTINUE
      RETURN
      END
C
      SUBROUTINE   NRPLOT(X,II)
C
C     ** NORMAL PROBABILITY PLOT **
C
C      * Must be called after SORT1!
C
      INTEGER*1    H(37,73),HSPACE,HVRTL,HRIZN,HSTAR
      DIMENSION    X(II),SCALE(7)
      DATA         J1,K1,LL,HSPACE,HVRTL,HRIZN,HSTAR /6,12,7,
     1             ' ','|','-',Z'EC'/
C
      WRITE(2,200)
  200   FORMAT(1H0,5X,'* Normal Probability Plot *'/8X,'(Unit of ',
     1         'ordinate = 1 sigma)'/)
      FII = II
      JJ = 6*J1 + 1
      KK = 6*K1 + 1
      FJ1 = J1
      FK1 = K1
      FJ2 = FLOAT(JJ)/2.0+1.0
      FK2 = FLOAT(KK)/2.0+1.0
      CALL STAT0(X,II,SX,AVGX,SXX,SSX,VX,SIGX,SKEW,FKURT,GEARY)
      DO 30 J=1,JJ
         DO 10 K=1,KK
            H(J,K) = HSPACE
   10    CONTINUE
         DO 20 K=1,KK,K1
            H(J,K) = HVRTL
   20    CONTINUE
   30 CONTINUE
      DO 50 K=1,KK
         DO 40 J=1,JJ,J1
            H(J,K) = HRIZN
   40    CONTINUE
   50 CONTINUE
      DO 60 I=1,II
         Q = (FLOAT(I)-0.5)/FII
         QQ = Q
         IF (Q.GT.0.5) QQ = 1.0 - Q
         Z = SQRT(ALOG(1.0/QQ**2))
         P = Z - (0.27061*Z+2.30753)/((0.04481*Z+0.9929)*Z+1.0)
         IF (Q.GT.0.5) P = -P
         J = P*FJ1 + FJ2
         IF (J.LT.1) J = 1
         IF (J.GT.JJ) J = JJ
         K = (X(I)-AVGX)/SIGX*FK1+FK2
         IF (K.LT.1) K = 1
         IF (K.GT.KK) K = KK
         H(J,K) = HSTAR
   60 CONTINUE
      DO 70 L=1,LL
         SCALE(L) = AVGX + SIGX*(L-4)
   70 CONTINUE
      WRITE(2,210) (SCALE(L),L=1,LL)
  210   FORMAT(1H ,F7.2,6F12.2)
      DO 80 J=1,JJ
         WRITE(2,220) (H(J,K),K=1,KK)
  220      FORMAT(1H ,4X,73A1)
   80 CONTINUE
      WRITE(2,210) (SCALE(L),L=1,LL)
      WRITE(2,230)
  230   FORMAT(1H0)
      RETURN
      END
