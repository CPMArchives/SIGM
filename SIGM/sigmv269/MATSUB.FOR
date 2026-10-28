C [MATSUB.FOR]
C	*** SUBROUTINES FOR VECTOR AND MATRIX HANDLING ***
C
C	Writen by Yoshio MONMA (JUG-CP/M No.43)
C
      SUBROUTINE   TRNSV0(INP0,NX,X,IND)
C
C     ** TRANSFORMATION OF A VECTOR X(NX) **
C
C	* Arguments:
C	 INP0	   Input data file no. (6-9)
C        NX        Data size, size of vector
C        X(NX)     Data, a vector
C        IND       Transformation code:
C            = 0   No transformation
C            = 1   Linear: (X --> A*X+B)
C            = 2   Inversion: (X --> 1/X)
C            = 3   (X --> LOG10(X))
C            = 4   (X --> LOG(X))
C            = 5   (X --> SQRT(X))
C            = 6   (X --> X**2)
C            = 7   (X --> X**P)
C            = 8   (X --> 10.0**X)
C            = 9   (X --> EXP(X))
C            = 10  Logistic: (X --> LOG(X/1.0-X))
C
C	AUTHOR AND DATE: YOSHIO MONMA, 80-05-02
C
      INTEGER*1	   BEL
      REAL*4       X(NX)
C
      DATA BEL/Z'07'/
C
      IF (NX.LE.0.OR.IND.LT.0.OR.IND.GT.10)  GOTO 99
      IF (IND.EQ.0) RETURN
C
      WRITE(2,600)
  600   FORMAT(1H0,10X,'* Transformation of Vector *')
      IF (IND.EQ.1) READ(INP0,500) A,B
  500   FORMAT(2F10.1)
      IF (IND.EQ.7) READ(INP0,500) P
C
      IF (IND.EQ. 1) WRITE(2,601) A,B
      IF (IND.EQ. 2) WRITE(2,602)
      IF (IND.EQ. 3) WRITE(2,603)
      IF (IND.EQ. 4) WRITE(2,604)
      IF (IND.EQ. 5) WRITE(2,605)
      IF (IND.EQ. 6) WRITE(2,606)
      IF (IND.EQ. 7) WRITE(2,607) P
      IF (IND.EQ. 8) WRITE(6,608)
      IF (IND.EQ. 9) WRITE(6,609)
      IF (IND.EQ.10) WRITE(6,610)
  601 FORMAT(1H0,10x,'(X --> A*X+B), A =',1PE10.3,', B =',E10.3)
  602 FORMAT(1H0,10X,'(X --> 1/X)')
  603 FORMAT(1H0,10X,'(X --> LOG10(X))')
  604 FORMAT(1H0,10X,'(X --> LOG(X))')
  605 FORMAT(1H0,10X,'(X --> SQRT(X))')
  606 FORMAT(1H0,10X,'(X --> X**2')
  607 FORMAT(1H0,10X,'(X --> X**P), P =',1PE10.3)
  608 FORMAT(1H0,10X,'(X --> 10.0**X)')
  609 FORMAT(1H0,10X,'(X --> EXP(X))')
  610 FORMAT(1H0,10X,'Logistic: (X --> LOG(X/(1.0-X))')
C
   10 DO 100 I=1,NX
         GOTO (11,12,13,14,15,16,17,18,19,20), IND
   11    X(I) = A*X(I)+B
                                        GOTO 100
   12    IF (X(I).EQ.0.0)               GOTO 99
         X(I) = 1.0/X(I)
                                        GOTO 100
   13    IF (X(I).LE.0.0)               GOTO 99
         X(I) = ALOG10(X(I))
                                        GOTO 100
   14    IF (X(I).LE.0.0)               GOTO 99
         X(I) = ALOG(X(I))
                                        GOTO 100
   15    IF (X(I).LT.0.0)               GOTO 99
         X(I) = SQRT(X(I))
                                        GOTO 100
   16    X(I) = X(I)**2
                                        GOTO 100
   17    X(I) = X(I)**P
                                        GOTO 100
   18    X(I) = 10.0**X(I)
                                        GOTO 100
   19    X(I) = EXP(X(I))
                                        GOTO 100
   20    X(I) = ALOG(X(I)/(1.0-X(I)))    
  100 CONTINUE
      RETURN
C                                       * ERROR PROCESS
   99 WRITE(2,299) BEL,IND
  299 FORMAT (1H0,A1,'*** Error in TRNSV0: IND =',I3)
      STOP 99
      END

      SUBROUTINE   MATPRI(TITLE,A,IA,JA,IN,JP)                          
C                                                                       
C     ** PRINT-OUT OF A MATRIX **                                         
C                                                                       
C     * Arguments:
C     TITLE	Title of the matrix (2A8)                             
C     A         Input matrix (one dimensional)
C     IA	Every Ia elements are printed out in the column
C     JA	Every JA elements are printed out in the row
C     IN	No. of columns to be printed out
C     JP	No. of rows to be printed out
C                                                                       
C     * REFERENCE, T.Haga & S.Hashimoto: ¢¶²·ÌÞÝ¾· Ä ¼­¾²ÌÞÝÌÞÝ¾·£, P.11  
C                                                                       
      REAL*4       A(1)                                                 
      REAL*8	   TITLE(2)
C
      WRITE(2,200) TITLE                                                
  200   FORMAT(1H0,10X,2A8/)
      J2 = 0                                                            
   10 J1 = J2+1                                                         
      IF (J2+10.LT.JP) J2 = J2+10
      IF (J2+10.GE.JP) J2 = JP
      WRITE(2,210) (J,J=J1,J2)                                          
  210   FORMAT(1H ,12X,10I10)
      IJ1 = 1+(J1-1)*JA                                                 
      IJ2 = 1+(J2-1)*JA                                                 
      DO 20 I=1,IN                                                      
         WRITE(2,230) I,(A(IJ),IJ=IJ1,IJ2,JA)                           
  230      FORMAT(1H ,I15,10F10.4)
         IJ1 = IJ1+IA                                                   
         IJ2 = IJ2+IA                                                   
   20 CONTINUE                                                          
      IF (J2.EQ.JP) RETURN                                              
      WRITE(2,210)                                                      
                                        GOTO 10                         
      E N D                                                             
      SUBROUTINE   VECPRI(TITLE,A,LA,IN)                                
C                                                                       
C     ** PRINT-OUT OF A VECTOR FROM A MATRIX **                              
C                                                                       
C     * Arguments:
C     TITLE        Identification of the vector (A8)
C     LA           Every LA element is taken up
C     A            Input matrix
C     IN           No. of elements to be printed out
C                                                                       
C     * Reference, T.Haga & S.Hashmoto: ¢¶²·ÌÞÝ¾· Ä ¼­¾²ÌÞÝÌÞÝ¾·£, P.18  
C                                                                       
      REAL*4       A(LA,1)                                              
      REAL*8       TITLE
C
      IF (IN.LT.10) I2 = IN
      IF (IN.GE.10) I2 = 10
      WRITE(2,200) TITLE,(A(1,I),I=1,I2)                                
  200   FORMAT(1H0,7X,A8,10F10.4)
      IF (I2.LT.IN) WRITE(2,210) (A(1,I),I=11,IN)                       
  210   FORMAT(1H ,15X,10F10.4)
      RETURN                                                            
      E N D                                                             
C
      SUBROUTINE   CORREL(S,LS,JP,R,LR)                                 
C                                                                       
C     ** Correlation Matrix **                                            
C                                                                       
C     * Arguments                                                       
C     S         SS matrix (Í²Î³Ü¥¾·Ü ·Þ®³ÚÂ)                         
C     LS	Size of S
C     JP	No. of variables (p)                                 
C     R         Correlation matrix
C     LR	Size of R
C                                                                       
C     * REFERENCE, T.Haga & S.Hashimoto: ¢¶²·ÌÞÝ¾· Ä ¼­¾²ÌÞÝÌÞÝ¾·£, P.22  
C                                                                       
      REAL*4       S(LS,LS), R(LR,LR)                                   
C                                                                       
      DO 10 I=1,JP                                                      
         R(I,I) = SQRT(S(I,I))                                          
   10 CONTINUE                                                          
      DO 30 I=2,JP                                                      
         JJ = I-1                                                       
         DO 20 J=1,JJ                                                   
            R(I,J) = S(I,J)/(R(I,I)*R(J,J))                             
            R(J,I) = R(I,J)                                             
   20    CONTINUE                                                       
   30 CONTINUE                                                          
C                                                                       
      DO 55 I=1,JP                                                      
         R(I,I) = 1.0                                                   
   55 CONTINUE                                                          
      RETURN                                                            
      E N D                                                             
C
      SUBROUTINE   SWEEP1(A,LA,K,JP)                                    
C                                                                       
C     ** SWEEP-OUT OF A SQUARE MATRIX **                                  
C                                                                       
C     * Arguments:
C     A            A square matrix with size of LA                      
C     LA           Size of matrix A
C     K            Location of pivot (A(K,K))                           
C     JP           Size of smaller square matrix to be sweeped out
C                                                                       
C     * REFERENCE, T.Haga & S.Hashimoto: ¶²·ÌÞÝ¾· Ä ¼­¾²ÌÞÝÌÞÝ¾·, P.16  
C                                                                       
      REAL*4       A(LA,LA)                                             
C                                                                       
      AKK = A(K,K)                                                      
      A(K,K) = 1.0                                                      
      DO 10 J=1,JP                                                      
         A(K,J) = A(K,J)/AKK                                            
   10 CONTINUE                                                          
      DO 30 I=1,JP                                                      
         IF (I.EQ.K)                    GOTO 30                         
         AIK = A(I,K)                                                   
         A(I,K) = 0.0                                                   
         DO 20 J=1,JP                                                   
            A(I,J) = A(I,J)-AIK*A(K,J)                                  
   20    CONTINUE                                                       
   30 CONTINUE                                                          
      RETURN                                                            
      E N D
