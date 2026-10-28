C [PRBSUB.FOR]
C	** Function Subprograms on Satistical Distributions **
C
C	Written by Yshio MONMA (JUG-CP/M N.43)
C
      FUNCTION     PF(Q,N1,N2)
C
C     ** Percentage Point of F-Distribution **
C
C     * REFERENCE, T.Haga & S.Hashimoto: ¢Ä³¹²¶²¾· PROGRAM É ·¿£, P.94
C
C     * Parameters:
C     Q       	Upper Probability
C     N1,N2   	Degree of Freedom
C
C                                       * (6.37)
       F(X,D1,D2,DIM2) = (X/D1)*(1.0+(X-DIM2)/(2.0*D2)
     1   +(4.0*X*X-11.0*DIM2*X+DIM2*(7.0*D1-10.0))/(24.0*D2*D2)
     2   +(2.0*X*X*X-10.0*DIM2*X*X+DIM2*(17.0*D1-26.0)*X
     3   -DIM2*DIM2*(9.0*D1-6.0))/(48.0*D2*D2*D2))
C
      DF1 = N1
      DF2 = N2
      IF (N2.EQ.1)                      GO TO 10
      IF (N2.EQ.2)                      GO TO 30
      IF (N1.EQ.1)                      GO TO 20
      IF (N1.GT.N2)                     GO TO 30
                                        GO TO 40
C                                       * 1/T**2 (6.36)
   10 W = 1.0
      IF (MOD(N1,2).EQ.1) W = 2.0/3.14159
      IF (N1.LE.2)                      GO TO 14
      II = (N1-1)/2
      G = (DF1-1.0)/2.0
      DO 12 I=1,II
         W = W*G/(G-0.5)
         G = G-1.0
   12 CONTINUE
   14 PF = (W/Q)**2/DF1
      RETURN
C                                       * T**2 (6.31)
   20 PF = PT(Q/2.0,N2)**2
      RETURN
C                                       * 1/Chi-2 (6.33) & (6.37)
   30 PF = 1.0/F(PCHI2(1.0-Q,N2),DF2,DF1,DF2-2.0)
      RETURN
C                                       * Chi-2 (6.37)
   40 PF = F(PCHI2(Q,N1),DF1,DF2,DF1-2.0)
      IF (N2.GT.10) RETURN
C
C	Mean of two approximation      * (6.38)
      A1 = 2.0/(9.0*DF1)
      AA1 = 1.0-A1
      A2 = 2.0/(9.0*DF2)
      AA2 = 1.0-A2
      U = PNOR(Q)
      PFF = ((AA1*AA2+U*SQRT(AA1**2*A2+AA2**2*A1-A1*A2*U**2))
     1        /(AA2**2-A2*U**2))**3.0
      PF = (PF+PFF)/2.0
C
      RETURN
      END
      FUNCTION     PT(Q,NDF)
C
C     ** Percentage Point of t-Distribution **
C
C     * REFERENCE, T.Haga & S.Hashimoto Ä³¹²¶²¾· PROGRAM É ·¿, P.91
C
C     * Parameters:
C     Q       Upper Probability of t-Distribution
C     NDF     Degree of Freedom
C
C
      DF = NDF
      U = PNOR(Q)
      U2 = U*U
      PT = U*(1.0+(U2+1.0)/(4.0*DF)
     1    +((5.0*U2+16.0)*U2+3.0)/(96.0*DF*DF)
     2    +(((3.0*U2+19.0)*U2+17.0)*U2-15.0)/(384.0*DF*DF*DF)
     3    +((((79.0*U2+776.0)*U2+1482.0)*U2-1920.0)*U2-945.0)
     4         /(92160.0*DF*DF*DF*DF)
     5    +(((((27.0*U2+339.0)*U2+930.0)*U2-1782.0)*U2-765.0)*U2
     6          +17955.0)/(368640.0*DF*DF*DF*DF*DF))
C
      RETURN
      END
      FUNCTION     PCHI2(Q,NDF)
C
C     ** PERCENTAGE POINT OF CHI-SQUARE DISTRIBUTION **
C
C     * REFERENCE, T.HAGA & S.HASHIMOTO: Ä³¹²¶²¾· PROGRAM É ·¿, P.88
C
C     * PARAMETERS:
C     Q     Upper probability
C     NDF   Degree of freedom
C
C
      IF (NDF.EQ.1)                     GO TO 10
      IF (NDF.EQ.2)                     GO TO 20
                                        GO TO 30
C                                       * N = 1 (6.23)
   10 PCHI2 = PNOR(Q/2.0)**2
      RETURN
C                                       * N = 2 (6.23)
   20 PCHI2 = -2.0*ALOG(Q)
      RETURN
C                                       * N > 2 (6.24)
   30 U = PNOR(Q)
      W = 2.0/(9.0*NDF)
      PCHI2 = NDF*(1.0-W+U*SQRT(W))**3
      IF (PCHI2.LT.0.0) PCHI2 = 0.0
      IF (NDF.GT.10)                    RETURN
      G = 1.0
      IF (MOD(NDF,2).EQ.1) G = 1.772454
      N2 = (NDF+1)/2-1
      DO 40 I=1,N2
         G = G*(NDF/2.0-I)
   40 CONTINUE
      F = (PCHI2/2.0)**(NDF/2.0-1.0)*EXP(-PCHI2/2.0)/2.0
      PCHI2 = PCHI2+(QCHI2(PCHI2,NDF)-Q)/(F/G)
C
      RETURN
      END
	FUNCTION     QCHI2(CHI2,NDF)
C
C     ** Upper Probability of Chi-Square Distribution **
C
C     * REFERENCE, T.Haga & S.Hashimoto: ¢Ä³¹²¶²¾· PROGRAM É ·¿£, P.87
C
C     * Parameters:
C     CHI2    Chi-Square
C     NDF     Degree of freedom
C
C
      IF (CHI2.LE.0.0)                  GO TO 90
      IF (NDF.GT.10)                    GO TO 50
      QCHI2 = 0.0
      IF (CHI2.GT.400.0)                RETURN
      A = EXP(-CHI2/2.0)
      IF (MOD(NDF,2).EQ.0)              GO TO 10
C                                       * NDF is odd (6.20)
      CHI = SQRT(CHI2)
      QCHI2 = 2.0*QNOR(CHI)
      A = 0.7978845*A/CHI
      I1 = 1
                                        GO TO 20
C                                       * NDF is even (6.20)
   10 QCHI2 = A
      I1 = 2
   20 IF (NDF.LE.2)                     RETURN
      I2 = NDF-2
      DO 30 I=I1,I2,2
         A = A*CHI2/I
         QCHI2 = QCHI2+A
   30 CONTINUE
      RETURN
C                                       * N > 10 (6.22)
   50 W = 2.0/(9.0*NDF)
      U = ((CHI2/NDF)**(1.0/3.0)-1.0+W)/SQRT(W)
      CHI2 = QNOR(U)
      RETURN
C
   90 QCHI2 = 1.0
C
      RETURN
      END
      FUNCTION     QNOR(U)
C
C     ** Upper Probability of Normal Distribution **
C
C     * REFERENCE, T.Haga & S.Hashimoto: ¢Ä³¹²¶²¾· PROGRAM É ·¿£, P.81
C
C     * Parameters:
C       U = (X-MU)/SIGMA for the normal distribution function;
C
C	F(X) = (1/(SQRT(2*PI)*SIGMA))*EXP(-(X-MU)**2/(2*SIGMA**2))
C
      DATA         N/12/
C
      FJ = N
      QNOR = 0.0
      X = ABS(U)
      X2 = X*X
      IF (X2.GT.300.0)                  GO TO 40
      F = EXP(-0.5*X2)*0.398942
      IF (X.LT.2.4)                     GO TO 20
      DO 10 I=1,N
         QNOR = FJ/(X+QNOR)
         FJ = FJ-1.0
   10 CONTINUE
      QNOR = F/(X+QNOR)
                                        GO TO 40
C
   20 S = -1.0
      DO 30 I=1,N
         QNOR = FJ*X2/(2.0*FJ+1.0+S*QNOR)
         S = -S
         FJ = FJ-1.0
   30 CONTINUE
      QNOR = 0.5-F*X/(1.0-QNOR)
C
   40 IF (U.LT.0.0) QNOR = 1.0-QNOR
C
      RETURN
      END
      FUNCTION     PNOR(Q)
C
C     ** Percentage Point of Normal Distribution **
C
C     * REFERENCE, T.Haga & S.Hashimoto: ¢Ä³¹²¶²¾· PROGRAM É ·¿£, P.83
C
C     * PARAMETER:
C     Q     Upper probability of normal distribution
C
      QQ = Q
      IF (Q.GT.0.5) QQ = 1.0-Q
      Z = SQRT(-2.0*ALOG(QQ))
      PNOR = Z-(0.27061*Z+2.30753)/((0.04481*Z+0.99229)*Z+1.0)
      D = QNOR(PNOR)-QQ
      PNOR = PNOR+D/(0.398942*EXP(-0.5*PNOR*PNOR))
      IF (Q.GT.0.5) PNOR = -PNOR
C
      RETURN
      END
