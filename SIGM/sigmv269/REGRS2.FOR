C [REGRS2.FOR]
C
      PROGRAM	REGRS2
C							85-03-21
C	** Scatter Diagram for Residuals **
C
C	Written by Yoshio MONMA (JUG-CP/M N.43)
C
C        This program must be executed immediately after REGRS1 (REG1.COM).
C     Before you adopt the results of REGRS1, you should examine carefully
C     the output from this program.
C
C	 This program is good for EPSON's RP-80 Printer.  To apply other
C     types of printer, you should modify BIGCHR and GRAPH1.
 
      REAL*4	   CMNT(18),X(100,16),S(16,16)
      REAL*4       YEST(100),RES(100)
      REAL*4	   YL1(100),YL2(100),YU1(100),YU2(100)
      REAL*8       SAMP
C
C				* Restore the saved data
      REWIND 10
      READ(10) IN,JPY,IRES,JGRH
      READ(10) CMNT,SAMP
      DO 90 J=1,JPY
        READ(10) (X(I,J),I=1,IN)
   90 CONTINUE
      JP = JPY-1
      JPY1 = JPY+1
      READ(10) S(JPY1,JPY),(S(J,JPY),J=1,JP)
      IF (IRES.NE.1) GOTO 92
      WRITE(1,1199)
 1199   FORMAT(1H ,'*** Error: IRES = 1')
      STOP
   92 DO 94 I=1,IN
	READ(10) YEST(I),RES(I),YL2(I),YL1(I),YU1(I),YU2(I)
   94 CONTINUE
C
      WRITE(1,1200) SAMP
 1200   FORMAT(1H ,'* REGRS2: Sample = ',A8)
      CALL BIGCHR(80,SAMP,2)
      WRITE(2,1040) CMNT
 1040   FORMAT(1H ,5X,18A4)
      WRITE(2,2090)
 2090   FORMAT(1H0,10X,'* Scatter Diagram: X-Axis = Y(est),',
     1       ' Y-Axis = Residuals *'/)                                  
      CALL MINMAX(YEST,IN,YMIN,YMAX)                                    
      CALL MINMAX(RES,IN,RMIN,RMAX)                                     
      CALL GRAPH1(YEST,1,'Estimate',YMIN,YMAX,RES,1,'Residual',         
     1           RMIN,RMAX,IN)                                     
      IF (JGRH.NE.1)                    GOTO 100
C                                                                       
      DO 100 J=1,JP                                                     
         WRITE(2,1100)
 1100      FORMAT(1H1)
         CALL BIGCHR(80,SAMP,2)
         WRITE(2,1040) CMNT
         WRITE(2,2100) J                                                 
 2100      FORMAT(1H0,10X,'* Scatter Diagram: X-Axis = X(',I2,'), ',       
     1          'Y-axis = Residual *'/)                                  
         DO 95 I=1,IN                                                   
            YEST(I) = X(I,J)                                            
   95   CONTINUE                                                        
         CALL MINMAX(YEST,IN,YMIN,YMAX)                                 
         CALL GRAPH1(YEST,1,'  X(J)  ',YMIN,YMAX,RES,1,'Residual', 
     1               RMIN,RMAX,IN)                                 
  100 CONTINUE                                                          
      WRITE(2,1100)
      STOP
      E N D                                                             
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
      SUBROUTINE   MINMAX(A,N,AMIN,AMAX)
C
C     * Minimum and Maximum value of Vector *
C
C     * Reference, T.Haga & S.Hashinoto: ¢¶²·ÌÞÝ¾· Ä ¼­¾²ÌÞÝÌÞÝ¾·£, P.20
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
      SUBROUTINE   GRAPH1(X,LX,XAXIS,XMIN,XMAX,                         
     1                    Y,LY,YAXIS,YMIN,YMAX,N)                  
C                                                                       
C     ** Scatter Diagram with Marks **                                  
C                                                                       
C     * Arguments                                                       
C     X,Y          The data
C     LX,LY        Every LX,LY of X,Y are plotted
C     XAXIS,YAXIS  Heading for X-Axis and Y-Axis (A8)                   
C     XMIN,XMAX    Min. and max. of X
C     YMIN,YMAX    Min. and max. of Y
C     N            No. of data points to be plotted (N <= 100)
C                                                                       
C     * Reference, T.Haga & S.Hashimoto: ¢¶²·ÌÞÝ¾· Ä ¼­¾²ÌÞÝÌÞÝ¾·£, P.56  
C                                                                       
      INTEGER*1    HSP,HX,HY,HP(37,101),HMARK(100),HM(100)
      REAL*4       SCALE(11),X(LX,1),Y(LY,1)
      REAL*8       XAXIS,YAXIS
C
      DATA	   IY,IX,LL,MM /37,101,11,100/
      DATA         MM,HSP,HX,HY /100,' ','-','+'/                        
      DATA   HMARK/'1','2','3','4','5','6','7','8','9','0','A','B','C', 
     1             'D','E','F','G','H','I','J','K','L','M','N','O','P', 
     2             'Q','R','S','T','U','V','W','X','Y','Z','a','b','c',
     3		   'd','e','f','g','h','i','j','k','l','m','n','o','p',
     4		   'q','r','s','t','u','v','w','x','y','z','#','$','%',
     5		   '&','?','@','\','±','²','³','´','µ','¶','·','¸','¹',
     6		   'º','»','¼','½','¾','¿','À','Á','Â','Ã','Ä','Å','Æ',
     7		   'Ç','È','É','Ê','Ë','Ì','Í','Î','Ï'/
C
C        		* Get the unit scale
      DX = (XMAX-XMIN)/FLOAT(IX-1)                                      
      DY = (YMAX-YMIN)/FLOAT(IY-1)                                      
C                                                                       
C        		* Fill spaces
      DO 20 I=1,IY                                                      
         DO 10 J=1,IX                                                   
            HP(I,J) = HSP                                               
   10    CONTINUE                                                       
   20 CONTINUE                                                          
C                                                                       
      DO 30 K=1,N                                                       
         I = (YMAX-Y(1,K))/DY+1.5                                       
         J = (X(1,K)-XMIN)/DX+1.5                                       
         IF (I.LT.1) I = 1                                              
         IF (I.GT.IY) I = IY                                            
         IF (J.LT.1) J = 1                                              
         IF (J.GT.IX) J = IX                                            
         M = MOD(K-1,MM)+1                                              
         IF (HP(I,J).EQ.HSP) HP(I,J) = HMARK(M)                         
         HM(K) = HP(I,J)                                                
   30 CONTINUE                                                          
C			* Coordinates
      IF (XMIN*XMAX.GT.0)               GOTO 50                         
      J = -XMIN/DX+1.5                                                  
      DO 40 I=1,IY                                                      
         IF (HP(I,J).EQ.HSP) HP(I,J) = HY                               
   40 CONTINUE                                                          
   50 IF (YMIN*YMAX.GT.0.0)             GOTO 70                         
      I = YMAX/DY+1.5                                                   
      DO 60 J=1,IX                                                      
         IF (HP(I,J).EQ.HSP) HP(I,J) = HX                               
   60 CONTINUE                                                          
C                                                                       
   70 DX = 10.0*DX                                                      
      SCALE(1) = XMIN                                                   
      DO 80 J=2,LL                                                      
         SCALE(J) = SCALE(J-1)+DX                                       
   80 CONTINUE                                                          
      WRITE(2,200) (SCALE(J),J=1,LL)                                    
      YW = YMAX                                                         
      WRITE(2,220) YAXIS                                              
      DO 90 I=1,IY                                                      
         WRITE(2,250) YW,(HP(I,J),J=1,IX),YW                          
         YW = YW-DY                                                     
   90 CONTINUE                                                          
      WRITE(2,220) YAXIS                                              
      WRITE(2,200) (SCALE(J),J=1,LL)                                    
      WRITE(2,265) XAXIS                                                
C                                                                       
      K2 = 0                                                            
  100 K1 = K2+1                                                         
      K2 = K2+40                                                        
      IF (K2.GT.N) K2 = N                                               
      WRITE(2,270) (K,K=K1,K2)                                          
      WRITE(2,280) (HM(K),K=K1,K2)                                      
      IF (K2.LT.N)                      GOTO 100                        
      RETURN                                                            
  200 FORMAT(1H ,9X,11F10.3)                                            
  220 FORMAT(1H ,7X,A8,1H+,10(10H.........+))                            
  250 FORMAT(1H ,F13.3,2H -,101A1,1H-,F10.3)                             
  265 FORMAT(1H0,60X,A8)
  270 FORMAT(1H0,6X,'No. ',40I3)                                        
  280 FORMAT(1H0,6X,'Mark',40(2X,A1))
      E N D                                                             
