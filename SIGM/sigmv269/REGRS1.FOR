C [REGRS1.FOR]
C
C     ** MULTIPLE LINEAR REGRESSION ANALYSIS WITH INTERVAL ESTIMATION **
C        (¾Ý¹² ¼Þ­³¶²· ÌÞÝ¾· Ä ¸¶Ý½²Ã²)
C
C	Yoshio MONMA (JUG CP/M No.43)			85-03-21	
C	1514-63 Takata-cho, Khohoku-ku
C	Yokohama 223, Japan
C
C
	PROGRAM	REGRS1
C
C       The following declaration are for the machines with 56k TPA.
C    You can increase the data and variable sizes as
C       '80' ---> '100' and '13' ---> '16'
C    if your system has 64k TPA.

      INTEGER*1    BEL,SI
      INTEGER*2    ITRS(13),JIN(13),RP80
      REAL*4       CMNT(18),FMT(18),VARS(18)
      REAL*4       X(80,13),S(13,13),R(13,13),XX(20,13)	
      REAL*4       AVGX(13),SIGX(13),TOL(13),YY(20)             
      REAL*4       YEST(80),RES(80),WRK(80),XMIN(13),XMAX(13)
      REAL*8	   DAY,SAMP
C                                                                       
      EQUIVALENCE  (ITRS(1),JIN(1)), (RES(1),WRK(1))
C
      DATA         BEL,RP80,SI/Z'07',Z'1B40',Z'0F'/, LX,LS/80,13/
      data day/'85-03-21'/
C
      WRITE(1,1000)
 1000   FORMAT(1H1,5X,'** Multiple Linear Regression Analysis **'/)
   10 WRITE(1,1010)
 1010   FORMAT(1H ,8X,'Specify input file (FORT0X.DAT, X in I1) = ')
      READ(1,1020) INP0
 1020   FORMAT(I1)
      IF (INP0.LT.6.OR.INP0.GT.9) 	GOTO 10
C	Set RP-80 to condensed mode
      WRITE(2,2000) SI
 2000   FORMAT(1H ,A1)
C			* Get initial parameters (14I5)
      READ(INP0,500) IN,JPY,MPL,INP1,KDTA,ISWP,IRES,JGRH,INTV,
     1               ICFL1,IPRB1,ICFL2,IPRB2,NPRD                     
  500   FORMAT(16I5)
C
C	You may modify '80' --> '100' and '12' ---> '15' in the following
C       statement, if your system has 64k TPA.
      IF (IN.GT.80.OR.JPY.GT.12.OR.MPL.GT.5) GOTO 199
      IF (INTV.GT.5.OR.NPRD.GT.20) GOTO 199   
C				If the system has the feature
C     CALL DATE(DAY)                                                    
C                                                                       
      READ(INP0,510) CMNT,SAMP
  510   FORMAT(1X,18A4,A8)
C                                                                       
      WRITE(2,2010) DAY,SAMP
 2010   FORMAT(1H /11X,'** Multiple Linear Regression Analysis with ',
     1  'Interval Estimation **'//14X,'Yoshio MONMA',60X,'Date ',A8/14X,
     2  'JUG CP/M No.43'//11X,
     3  'Program Name = REGRS1',30X,'Sample = ',A8)
      CALL BIGCHR(85,SAMP,2)
      WRITE(1,1030) SAMP
 1030   FORMAT(1H ,50X,'Sample = ',A8)
      WRITE(1,1040) CMNT
 1040   FORMAT(1H ,5X,18A4)
      WRITE(2,1040) CMNT
      WRITE(1,1050) IN,JPY,INP1,KDTA,ISWP,IRES,JGRH,
     1              INTV,ICFL1,IPRB1,ICFL2,IPRB2,NPRD                    
 1050   FORMAT(1H0,'* Initial Parameters *'/11X,'IN =',I4,
     1    ', JPY =',I3,', INP1 =',I2,', KDTA =',I2,', ISWP =',I2,    
     2    ', IRES =',I2,', JGRH =',I2/11X,'INTV =',I2,', ICFL1 =',I3,   
     3    ', IPRB1 =',I3,', ICFL2 =',I3,', IPRB2 =',I3,', NPRD =',I3/)
      WRITE(2,1050) IN,JPY,INP1,KDTA,ISWP,IRES,JGRH,
     1              INTV,ICFL1,IPRB1,ICFL2,IPRB2,NPRD                    
C
      WRITE(2,1060) 
 1060   FORMAT(1H0,10X,'* Description of Variables *'/7X,
     1	       'Var No',10X, 'Description')                                  
      DO 20 J=1,JPY                                                     
         READ(INP0,510) VARS
         WRITE(2,1070) J,VARS
 1070      FORMAT(1H ,I10,10X,18A4)
   20 CONTINUE                                                          
      JP = JPY-1
      JPY1 = JPY+1                                                      
      IF (MPL.GT.1) JPY1 = JPY1+MPL-1                                   
      IF (INP0.NE.INP1) REWIND INP1
      READ (INP0,510) FMT
      DO 30 I=1,IN                                                      
         READ(INP1,FMT) (X(I,J),J=1,JPY)                  
         X(I,JPY1) = 1.0                                                
   30 CONTINUE                                                          
      IF (NPRD.EQ.0)                    GOTO 35                         
C			* Get the data for prediction
      READ(INP0,510) FMT
      READ(INP0,FMT) ((XX(I,J),J=1,JP),I=1,NPRD)
C			* Transformation of variables
   35 READ(INP0,500) (ITRS(J),J=1,JPY)
      DO 44 J=1,JPY                                                     
         DO 40 I=1,IN                                                   
            WRK(I) = X(I,J)                                            
   40    CONTINUE                                                       
         CALL TRNSV0(INP0,IN,WRK,ITRS(J))
         DO 42 I=1,IN                                                   
            X(I,J) = WRK(I)                                            
   42    CONTINUE                                                       
   44 CONTINUE                                                          
      IF (NPRD.EQ.0)                    GOTO 50                         
      DO 50 J=1,JP                                                      
         DO 45 I=1,IN                                                   
            WRK(I) = XX(I,J)                                           
   45    CONTINUE                                                       
         CALL TRNSV0(INP0,NPRD,WRK,ITRS(J))
         DO 50 I=1,IN                                                   
            XX(I,J) = WRK(I)                                           
   50 CONTINUE                                                          
C                                                                       
      IF (MPL.LE.1)                     GOTO 60                         
      WRITE(2,1080) MPL
 1080   FORMAT(1H0,10X,'* Polynomial Regression, Order =',I2,' *')
      JPY = JPY+MPL-1                                                   
      MPL = JPY-1                                                       
      DO 55 I=1,IN                                                      
         X(I,JPY) = X(I,2)                                              
         DO 53 J=2,MPL                                                  
            X(I,J) = X(I,1)**J                                          
   53    CONTINUE                                                       
   55 CONTINUE                                                          
      IF (NPRD.EQ.0)                    GOTO 60                         
      DO 59 I=1,IN                                                      
         DO 57 J=2,MPL                                                  
            XX(I,J) = XX(I,1)**J                                        
   57    CONTINUE                                                       
   59 CONTINUE                                                          
C                                                                       
   60 IF (KDTA.NE.1) CALL MATPRI('Data Matrix     ',X,1,LX,IN,JPY)              
C                                                                       
C        		* Copy the data matrix to FORT10.DAT
      REWIND 10
      DO 66 I=1,IN                                                      
         DO 63 J=1,JPY                                                  
            WRK(J) = X(I,J)                                             
   63    CONTINUE                                                       
         WRITE(10) (WRK(J),J=1,JPY)                    
   66 CONTINUE                                                          
C
C        			* SS matrix (Í²Î³Ü¥¾·Ü ·Þ®³ÚÂ)
      CALL SSSP(IN,JPY,S,LS,WRK)
C
      DO 70 J=1,JPY1                                                    
         TOL(J) = 0.00001*S(J,J)                                        
   70 CONTINUE                                                          
C				* Statistics
      DF = IN-1
      DO 75 J=1,JPY 
         AVGX(J) = S(JPY1,J)                                            
         SIGX(J) = SQRT(S(J,J)/DF)                                      
         CALL MINMAX(X(1,J),IN,XMIN(J),XMAX(J))                         
   75 CONTINUE                                                          
C
      CALL VECPRI('Mean    ',AVGX,1,JPY)
      CALL VECPRI('Sigma   ',SIGX,1,JPY)
      CALL VECPRI('Min.    ',XMIN,1,JPY)
      CALL VECPRI('Max.    ',XMAX,1,JPY)
      IF (NPRD.GT.0) CALL MATPRI('For Prediction  ',XX,1,20,NPRD,JP)
      IF (ISWP.EQ.1) CALL MATPRI('S.S. Matrix     ',S,1,LS,JPY1,JPY1)   
C                                                                       
C        			* Correlation matrix
      CALL CORREL(S,LS,JPY,R,LS)                                        
      CALL MATPRI('Correl. Matrix  ',R,1,LS,JPY,JPY)             
C                                                                       
      IF (ISWP.EQ.1) WRITE(2,1090)
 1090   FORMAT(1H0,10X,'* Sweep Process *')
      WRITE(1,1090)
C                                                                       
      JP = JPY-1                                                        
      SYY = S(JPY,JPY)                                                  
      DO 80 J=1,JP                                                      
         JIN(I) = -1                                                    
   80 CONTINUE                                                          
      JIN(JPY) = 0                                                      
      JIN(JPY1) = 1                                                     
      DFE = DF                                                          
      DO 85 J=1,JP                                                      
         IF (S(J,J).LT.TOL(J))          GOTO 85                         
         CALL SWEEP1(S,LS,J,JPY1)                                       
         JIN(J) = 1                                                     
         DFE = DFE-1.0                                                  
      IF (ISWP.EQ.1) CALL MATPRI('1/S             ',S,1,LS,JPY1,JPY1)
   85 CONTINUE                                                          
C				* Save data matrix and reg. coef.
      WRITE(1,1095)
 1095   FORMAT(1H0,5X,'* Saving ... data matrix & reg. coef.')
      REWIND 10
      WRITE(10) IN,JPY,IRES,JGRH
      WRITE(10) CMNT,SAMP
      DO 90 J=1,JPY
        WRITE(10) (X(I,J),I=1,IN)
   90 CONTINUE
      WRITE(10) S(JPY1,JPY),(S(J,JPY),J=1,JP)
C
C				 * Analysis of variance
      CALL ANOVA(S,LS,JIN,SIGX,IN,JPY,SYY,DFE,SE)                       
C
      IF (IRES.EQ.1) GOTO 100
      WRITE(2,1100)
 1100   FORMAT(1H1/)
      CALL BIGCHR(85,SAMP,2)
      WRITE(2,1040) CMNT
C					* Estimate
      CALL ESTIM(S,LS,X,LX,JIN,IN,JPY,DFE,YEST,RES,SE,            
     1           INTV,ICFL1,IPRB1,ICFL2,IPRB2,XX,NPRD,YY)              
C                                                                       
C
      CALL DWRTIO(RES,IN,DWR)                                           
      WRITE(2,2080) DWR
 2080   FORMAT(1H0,10X,'* Durbin-Watson ratio *'//14X,'DWR =',F7.4)       
  100 WRITE(2,1100)
      STOP
C
  199 WRITE(1,1900) BEL
 1900   FORMAT(1H ,A1,'*** Error in the Initial Parameter(s)!')
      STOP ERROR
C                                                                       
      END
C
      SUBROUTINE   BIGCHR(VPOS,STRING,MODE)
C
C	** Print STRING in Enlarged Mode at VPOS **
C
C	Written by Yoshio MONMA on 85-03-20
C
C     Arguments:
C        VPOS      Vertical position
C        STRING    Character string (A8), must be given in exact length
C        MODE      Mode to be set after the printing STRING
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
C
      SUBROUTINE   SSSP(II,JJ,S,LS,X)
C
C     ** Sum of Squares and Sum of Products **
C
C     * Reference, T.Haga & S.Hashimoto: ¢¶²·ÌÞÝ¾· Ä ¼­¾²ÌÞÝÌÞÝ¾·£, P.27
C
C	Arguments:
C	II	Data ize
C	JJ	No. of variables
C	S	S.S. matrix
C	X	Work area
C
C	This routine reads the data matrix from FORT10.DAT.
C
      REAL*4       S(LS,1),X(1)
C
      JJ1 = JJ+1
      DO 14 J=1,JJ
         S(JJ1,J) = 0.0
         DO 12 J1=1,J
            S(J,J1) = 0.0
   12    CONTINUE
   14 CONTINUE
C
      REWIND 10
      DO 20 I=1,II
         READ(10) (X(J),J=1,JJ)
         FI = I
         F = (FI-1.0)/FI
         DO 18 J=1,JJ
            X(J) = X(J)-S(JJ1,J)
            S(JJ1,J) = S(JJ1,J)+X(J)/FI
            DO 16 J1=1,J
               S(J,J1) = S(J,J1)+X(J)*X(J1)*F
   16       CONTINUE
   18    CONTINUE
   20 CONTINUE
C
      DO 24 J=1,JJ
         S(J,JJ1) = -S(JJ1,J)
         DO 22 J1=1,J
            S(J1,J) = S(J,J1)
   22    CONTINUE
   24 CONTINUE
C
      S(JJ1,JJ1) = 1.0/FI
C
      RETURN
      END
C
      SUBROUTINE   ANOVA(S,LS,JIN,SIGX,IN,JPY,SYY,DFE,SE)               
C                                                                       
C     ** Analysis of Variance and Multiple Correlation **               
C                                                                       
C     * Reference, T.Haga & S.Hashimoto: ¢¶²·ÌÞÝ¾· Ä ¼­¾²ÌÞÝÌÞÝ¾·£, P.27
C
C     * Arguments
C     S         Sweeped out SS matrix
C     LS        Size of S
C     JIN       JIN(I)=1 if X(J) is adopted for a predictor variable,
C               otherwise JIN(J)=-1                                  
C     SIGX      Standard deviation
C     IN        No. of sample (Data size)
C     JPY       No. of variables (JP+1)                              
C     SYY       Totak sum of squares for Y(I)                        
C     DFE       Degree of freedom for residuals
C     SE        Residual sum of squares
C                                                                       
C     * REFERENCE, T.Haga & S.Hashimoto: ¶²·ÌÞÝ¾· Ä ¼­¾²ÌÞÝÌÞÝ¾·, P.48  
C                                                                       
      INTEGER*2    JIN(1)
      REAL*4       S(LS,LS),SIGX(1)                             
C                                                                       
      FIN = IN                                                          
      JP = JPY-1                                                        
      JPY1 = JPY+1                                                      
      SE = S(JPY,JPY)                                                   
      SR  = SYY-SE                                                      
      DF  = IN-1                                                        
      DFR = DF-DFE                                                      
      IF (DFR.EQ.0.0) DFR = 0.0001                                      
      VR  = SR/DFR                                                      
      VE  = SE/DFE                                                      
      VT = SYY/DF                                                       
      SEE = SQRT(VE)                                                    
      F0 = VR/VE                                                        
C                                                                       
      IJ1 = IN-JP-1
      F95 = PF(0.025,JP,IJ1)
      F99 = PF(0.005,JP,IJ1)
      JTST = '  '                                                       
      IF (F0.GE.F95) JTST = '* '                                        
      IF (F0.GE.F99) JTST = '**'                                        
      WRITE(1,100) SR, DFR, VR, F0, JTST,                               
     1             SE,DFE,VE,SEE,                                       
     2             SYY,DF,VT                                            
  100 FORMAT(1H0/11X,'* Analysis of Variance *'//6X,70('-') /10X,'S.V.',
     1       7X,'S.S.',7X,'D.F.',5X,'M.S.',8X,'F0',5X,'F-test',3X,      
     2       'Sig(E)'  /6X,70('-') /6X,'Regression',F11.4,F9.0,2F11.4,  
     3       4X,A2/6X,'Residual',F13.4,F9.0,F11.4,15X,F12.4 /6X,70('-')
     4      /6X,'Total',F16.4,F9.0,F11.4 /6X,70('-')/)                  
C                                                                       
         WRITE(2,100) SR, DFR, VR, F0, JTST,
     1             SE, DFE, VE, SEE,                                       
     2             SYY, DF, VT
      R2 = 1.0-SE/SYY                                                   
      RR2 = 1.0-VE/VT                                                   
      RRR2 = 1.0-(2.0*FIN-DFE)/(2.0*FIN-DF)*(VE/VT)                     
      R = SQRT(R2)                                                      
      RR = SQRT(RR2)                                                    
      RRR = SQRT(RRR2)                                                  
      WRITE(1,110) R,R2,RR,RR2,RRR,RRR2                                 
  110 FORMAT(1H0,10X,'* Multiple Correlation *'//31X,'R',9X,'R**2' /6X, 
     1       'Ordinary',13X,F6.4,6X,F6.4 /6X,'Adjusted',13X,F6.4,6X,    
     2       F6.4 /6X,'Double Adjusted',6X,F6.4,6X,F6.4/)               
C                                                                       
      WRITE(2,110) R,R2,RR,RR2,RRR,RRR2                                 
      WRITE(1,120)                                                      
  120 FORMAT(1H0,10X,'* Regression Coefficients and t-Test *'/13X,      
     1 'Y = B(0) + B(1)*X(1) + B(2)*X(2) + ... + B(P)*X(P)'//10X,'J',   
     2 7X,'B(J)',10X,'Std-B(J)',5X,'Sig(B)',5X,'t(B)',5X,'t-Test'/)     
      WRITE(2,120)                                                      
      T95 = PT(0.025,IJ1)
      T99 = PT(0.005,IJ1)
      DO 10 J=1,JP                                                      
         IF (JIN(J).LT.0)               GOTO 10                         
         B = S(J,JPY)                                                   
         BB = B*SIGX(JPY)/SIGX(J)                                       
         SIGB = SQRT(VE*S(J,J))                                         
         T = B/SIGB                                                     
         JTST = '  '                                                    
         IF (ABS(T).GE.T95) JTST = '* '                                 
         IF (ABS(T).GE.T99) JTST = '**'                                 
         WRITE(1,130) J,B,BB,SIGB,T,JTST                                
  130      FORMAT(1H ,I10,F14.5,F15.5,F11.4,F10.4,5X,A2)
         WRITE(2,130) J,B,BB,SIGB,T,JTST                                
   10 CONTINUE                                                          
      IF (JIN(JPY1).GT.0) WRITE(1,140) S(JPY1,JPY)                      
  140   FORMAT(1H0,'Constant =',F14.5)
      IF (JIN(JPY1).GT.0) WRITE(2,140) S(JPY1,JPY)                      
      RETURN                                                            
      E N D                                                             
C
      SUBROUTINE  ESTIM(S,LS,X,LX,JIN,IN,JPY,DFE,YEST,RES,SE,     
     1                  INTV,ICFL1,IPRB1,ICFL2,IPRB2,XX,NPRD,YY)       
C                                                                       
C     ** Estimate, Residuals and Interval Estimation **
C
C	Written by Yoshio MONMA (JUG-CP/M No.43)
C
C     * REFERENCE, T.Haga & S.Hashimoto: ¢¶²·ÌÞÝ¾· Ä ¼­¾²ÌÞÝÌÞÝ¾·£, P.189
C
C     * Arguments                                                       
C     S            Sweeped out SS matrix
C     LS           Size of S
C     X(LX,JPY)    Data matrix
C     LX           Maximum data size
C     JIN(J)       Index for variables picked up
C     IN           Data size
C     JPY          No. of variables (p+1)                               
C     DFE          Degree of freedom for residuals
C     RES(I)       Residuals                                             
C     SE           Residual sum of squares
C     INTV = 0     Average estimate only
C          = 1     Avg. + CI (¼Ý×²-¸¶Ý)
C          = 2     Avg. + SCI (ÄÞ³¼Þ-¼Ý×²-¸¶Ý)
C          = 3     Avg. + PI (Ö¿¸-¸¶Ý)
C          = 4     Avg. + TI (·®Ö³-¸¶Ý)
C          = 5     Avg. + STI (ÄÞ³¼Þ-·®Ö³-¸¶Ý)
C     ICFL        Confidence evel (%)
C     IPRB        Probability level (%)
C     XX(I,J)     Specified valies of predictor variables
C     NPRD        No. of specified points (NPRD <= 20)
C     YY(I)       Estimate for XX(I,J)
C
      INTEGER*2    JIN(1)
      REAL*4       S(LS,1),X(LX,1),YEST(1),RES(1)                
      REAL*4       XX(LS,1),YY(NPRD)                                    
      REAL*8	   RESTAB(5)
C
      DATA	RESTAB/'* Table ','of Resid','uals and',' Interva',
     1                 'ls *    '/
C
      JPY1 = JPY+1                                                      
      JP = JPY-1                                                        
      NDF = DFE                                                         
      T95 = PT(0.025,NDF)                                               
      T99 = PT(0.005,NDF)                                               
      VE = SE/DFE                                                       
      ALPH1 = (100.0-ICFL1)/100.0                                       
      ALPH2 = (100.0-ICFL2)/100.0                                       
      GMA1  = (100.0-IPRB1)/100.0                                       
      GMA2  = (100.0-IPRB2)/100.0                                       
C                                                                       
      INTV1 = INTV+1
      GOTO (10,11,12,13,14,15), INTV1
C
   10 WRITE(1,110) RESTAB(1),RESTAB(2),RESTAB(5)
  110   FORMAT(1H0,10X,2A8,'ua',A8)
      WRITE(2,110) RESTAB(1),RESTAB(2),RESTAB(5)
					GOTO 20
   11 WRITE(1,111) RESTAB
  111 FORMAT(1H0,10X,3A8,' Confidence',2A8) 
      WRITE(2,111) RESTAB
					GOTO 20
   12 WRITE(1,112) RESTAB
  112 FORMAT(1H0,10X,3A8,' Simultaneous Confidence',2A8)
      WRITE(2,112) RESTAB
					GOTO 20
   13 WRITE(1,113) RESTAB
  113 FORMAT(1H0,10X,3A8,' Prediction',2A8)
      WRITE(2,113) RESTAB
 					GOTO 20
   14 WRITE(1,114) RESTAB
  114 FORMAT(1H0,10X,3A8,' Tolerance',2A8/)
      WRITE(2,114) RESTAB
					GOTO 20
   15 WRITE(1,115) RESTAB
  115 FORMAT(1H0,10X,3A8,' Simultaneous Tolerance',2A8)
      WRITE(2,115) RESTAB
C
   20 IF (INTV.GE.1.AND.INTV.LE.3) WRITE(2,220) ICFL1,ICFL2
  220  FORMAT(1H0,13X,'Confidence Level =',I3,'% and',I3,'%'/)
      IF (INTV.GE.4) WRITE(2,224) ICFL1,IPRB1,ICFL2,IPRB2
  224   FORMAT(1H0,13X,'Confidence Level =',I3,'% with Probability of',
     1       I3,'%')                                                    
      IF (INTV.EQ.0) WRITE(2,230)
  230   FORMAT(1H0,9X,'I',4X,'Y(obs)',4X,'Y(est)',3X,'Residual',2X,
     1       'Sig(res)',5X,'t',6X,'t-Test'/)
      IF (INTV.NE.0) WRITE(2,235) ICFL2,ICFL1,ICFL1,ICFL2               
  235   FORMAT(1H0,9X,'I',4X,'Y(obs)',4X,'Y(est)',3X,'Residual',2X,
     1       'Sig(res)',5X,'t',6X,'t-Test',12X,'Lower',14X,'Upper'/,    
     2       76X,I3,'%',I10,'%',I8,'%',I10,'%'/)                        
C                                                                       
      DO 30 I=1,IN                                                      
         YEST(I) = 0.0                                                  
C     * C = 1/N + DM2/(N-1), DM2 = Mahalanobis' Generalized Distance
         C = 0.0                                                        
         DO 25 J=1,JPY1                                                 
            IF (JIN(J).LE.0)            GOTO 25                         
            YEST(I) = YEST(I) + X(I,J)*S(J,JPY)                         
            DO 22 J1=1,JPY1                                             
               IF (JIN(J1).LE.0)        GOTO 22                         
               C = C + X(I,J)*S(J,J1)*X(I,J1)                           
   22       CONTINUE                                                    
   25    CONTINUE                                                       
         RES(I) = X(I,JPY)-YEST(I)                                      
         C1 = 1.0-C                                                     
         SIGRES = SQRT(C1*(SE-RES(I)*RES(I)/C1)/(DFE-1.0))              
         T = RES(I)/SIGRES                                              
         JTST = '  '                                                    
         IF (ABS(T).GT.T95) JTST = '* '                                 
         IF (ABS(T).GT.T99) JTST = '**'                                 
C                                       * Interval Estimation
         CALL INTRVL(INTV,ALPH1,ALPH2,GMA1,GMA2,IN,NDF,C,VE,YEST(I),    
     1               YL1,YL2,YU1,YU2)                              
         IF (INTV.NE.0) WRITE(2,240) I,X(I,JPY),YEST(I),RES(I),SIGRES,  
     1                               T,JTST,YL2,YL1,YU1,YU2             
  240      FORMAT(1H ,I10,5F10.4,5X,A2,5X,4F10.4)                      
         IF (INTV.EQ.0) WRITE(2,245) I,X(I,JPY),YEST(I),RES(I),SIGRES,  
     1                               T,JTST                             
  245    FORMAT(1H ,I10,5F10.4,5X,A2)
         WRITE(10) YEST(I),RES(I),YL2,YL1,YU1,YU2   
   30 CONTINUE                                                          
C                                                                       
      IF (NPRD.EQ.0)                    GOTO 50
      WRITE(1,120)                                                      
  120   FORMAT(1H0,10X,'* Prediction for specified X *'/)
      WRITE(2,120)
      DO 50 I=1,NPRD                                                    
         YY(I) = 0.0                                                    
         DO 35 J=1,JP                                                   
            IF (JIN(J).LE.0)            GOTO 35                         
            YY(I) = YY(I) + XX(I,J)*S(J,JPY)                            
   35    CONTINUE                                                       
         YY(I) = YY(I) + S(JPY1,JPY)                                    
         XX(I,JPY) = YY(I)                                              
         XX(I,JPY1) = 1.0                                               
         C = 0.0                                                        
         DO 45 J=1,JPY1                                                 
               IF (JIN(J).LE.0)         GOTO 45                         
            DO 40 J1=1,JPY1                                             
               IF (JIN(J1).LE.0)        GOTO 40                         
               C = C + XX(I,J)*S(J,J1)*XX(I,J1)                         
   40       CONTINUE                                                    
   45    CONTINUE                                                       
         CALL INTRVL(INTV,ALPH1,ALPH2,GMA1,GMA2,IN,NDF,C,VE,YY(I),      
     1               YL1,YL2,YU1,YU2)                              
         IF (INTV.EQ.0) WRITE(2,250) I,YY(I)                            
  250      FORMAT(1H ,I10,10X,F10.4)
         IF (INTV.NE.0) WRITE(2,255) I,YY(I),YL2,YL1,YU1,YU2
  255      FORMAT(1H ,I10,10X,F10.4,30X,12X,4F10.4)
   50 CONTINUE                                                          
C
      RETURN                                                            
      E N D                                                             
C
      SUBROUTINE   INTRVL(INTV,ALPH1,ALPH2,GMA1,GMA2,N,NDF,C,VE,YES,    
     1                    YL1,YL2,YU1,YU2)                         
C                                                                       
C     ** Interval Estmation **                                         
C                                                                       
C	Written by Yoshio MONMA (JUG-CP/M No.43)
C
C     * Arguments                                                       
C     INTV = 0: No Interval Estimation
C          = 1: Confidence Interval
C          = 2: Simultaneous Confidence Interval
C          = 3: Prediction Interval
C          = 4: Tolerance Interval
C          = 5: Simultaneous Tolerance Interval
C     ALPH1,ALPH2  Probability of t-Distribution (conf. level)          
C     GMA1,GMA2    Probability of normal distribution
C     N         Data size (no. of data points)
C     NDF       Degree of freedom (N-P-1) 
C     C       C = 1/n + DM2/(n-1), DM2 = Mahalanobis' Generalized Distance
C     VE        Variance of residuals
C     YES       Estimate
C     YL1,YL2   Lower limits of the interval
C     YU1,YU2   Upper limits of the interval
C                                                                       
C
      IF (INTV.EQ.0) RETURN
      GOTO (10,20,30,40,50), INTV                                       
C                                                                       
   10 AL12 = ALPH1/2.0
      AL22 = ALPH2/2.0
      PT12 = PT(AL12,NDF)
      PT22 = PT(AL22,NDF)
      X0  = SQRT(C*VE)                                                  
   15 X1 = PT12*X0                                                      
      X2 = PT22*X0                                                      
                                        GOTO 60                         
   20 NNDF = N-NDF
      PF1 = PF(ALPH1,NNDF,NDF)
      PF2 = PF(ALPH2,NNDF,NDF)
      X0  = SQRT(C*VE)                                                  
      X1  = SQRT((N-NDF)*PF1)*X0                                        
      X2  = SQRT((N-NDF)*PF2)*X0                                        
                                        GOTO 60                         
   30 AL12 = ALPH1/2.0
      AL22 = ALPH2/2.0
      PT12 = PT(AL12,NDF)
      PT22 = PT(AL22,NDF)
      X0 = SQRT((C+1.0)*VE)                                             
                                        GOTO 15                         
   40 AL14 = ALPH1/4.0
      AL24 = ALPH2/4.0
      PT14 = PT(AL14,NDF)
      PT24 = PT(AL24,NDF)
      X0  = SQRT(C)                                                     
      X1 = PT14*X0                                                      
      X2 = PT24*X0                                                      
   45 GM12 = GMA1/2.0
      GM22 = GMA2/2.0
      Z1 = PNOR(GM12)
      Z2 = PNOR(GM22)
      ALP12 = 1.0-ALPH1/2.0
      ALP22 = 1.0-ALPH2/2.0
      CHI1 = PCHI2(ALP12,NDF)
      CHI2 = PCHI2(ALP22,NDF)
      X1 = SQRT(VE)*(X1 + Z1*SQRT(NDF/CHI1))                            
      X2 = SQRT(VE)*(X2 + Z2*SQRT(NDF/CHI2))                            
                                        GOTO 60                         
   50 AL12 = ALPH1/2.0
      AL22 = ALPH2/2.0
      NNDF = N-NDF
      PF1 = PF(AL12,NNDF,NDF)
      PF2 = PF(AL22,NNDF,NDF)
      X1 = SQRT((N-NDF)*PF1*C)                                          
      X2 = SQRT((N-NDF)*PF2*C)                                          
                                        GOTO 45                         
C                                                                       
   60 YL1 = YES - X1                                                    
      YL2 = YES - X2                                                    
      YU1 = YES + X1                                                    
      YU2 = YES + X2                                                    
C                                                                       
      RETURN                                                            
      E N D                                                             
C
      SUBROUTINE   MINMAX(A,N,AMIN,AMAX)
C
C     ** Minimum and Maximum Value of Vector **
C
C     * REFERENCE, T.Haga & S.Hashinoto: ¢¶²·ÌÞÝ¾· Ä ¼­¾²ÌÞÝÌÞÝ¾·£, P.20
C
      REAL*4       A(1)
C
      AMIN = A(1)
      AMAX = A(1)
C
      DO 10 I=1,N
         IF (A(I).LT.AMIN) AMIN = A(I)
         IF (A(I).GT.AMAX) AMAX = A(I)
   10 CONTINUE
C
      RETURN
      END
C
      SUBROUTINE   DWRTIO(X,N,DWR)
C
C     ** Durbin-Watson Ratio **
C
C     * REFERENCE, T.Haga & S.Hashimoto: ¢¶²·ÌÞÝ¾· Ä ¼­¾²ÌÞÝÌÞÝ¾·£, P.189
C
      REAL*4       X(1)
C
      AX = X(1)
      SX = 0.0
      DW = 0.0
C
      DO 10 I=2,N
         FI = I
         D = X(I)-AX
         AX = AX+D/FI
         SX = SX+D**2*(FI-1.0)/FI
         DW = DW+(X(I)-X(I-1))**2
   10 CONTINUE
C
      DWR = DW/SX
C
      RETURN
      END
