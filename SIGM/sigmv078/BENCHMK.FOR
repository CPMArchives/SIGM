FORTRAN BENCHMARK LISTINGS BM1 to 9 

LISTINGS OF BM1 to BM8 FROM COMPUTING EUROPE JULY 27 1978
 
      PROGRAM BM1          
      WRITE(3,1)           
    1 FORMAT(9H Start BM1)       
      DO 2 K=1,1000        
    2 CONTINUE             
      WRITE(3,3)           
    3 FORMAT(2H E)         
      STOP                 
      END                  
                           
                           
----------------------  

      PROGRAM BM2           
      WRITE(3,1)            
    1 FORMAT(9H Start BM2)        
      K=0                   
    2 K=K+1                 
      IF(K.LT.1000)GOTO 2   
      WRITE(3,3)            
    3 FORMAT(2H E)          
      STOP                  
      END                   
                            
----------------------  

      PROGRAM BM3        
      WRITE(3,1)         
    1 FORMAT(9H Start BM3)
      K=0                
    2 K=K+1              
      A=K/K*K+K-K        
      IF(K.LT.1000)GOTO 2
      WRITE(3,3)         
    3 FORMAT(2H E)       
      STOP               
      END                

      SUBROUTINE GOSUB    	
      RETURN              
      END                 

----------------------  

      PROGRAM BM4          
      WRITE(3,1)           
    1 FORMAT(9H Start BM4)       
      K=0                  
    2 K=K+1                
      A=K/2*3+4-5          
      IF(K.LT.1000) GO TO 2
      WRITE(3,3)           
    3 FORMAT(2H E)         
      STOP                 
      END                  
                           
----------------------  
                            
      PROGRAM BM5           
      WRITE(3,1)            
    1 FORMAT(9H Start BM5)        
      K=0                   
    2 K=K+1                 
      A=K/2*3+4-5           
      CALL GOSUB            
      IF(K.LT.1000)GOTO 2   
      WRITE(3,3)            
    3 FORMAT(2H E)          
      STOP                  
      END                   
                                                       
----------------------  

      PROGRAM BM6        
      DIMENSION M(5)     
      WRITE(3,1)         
    1 FORMAT(9H Start BM6)     
      K=0                
    2 K=K+1              
      CALL GOSUB         
      DO 4 L=1,5
    4 CONTINUE           
      IF(K.LT.1000)GOTO 2
      WRITE(3,3)         
    3 FORMAT(2H E)       
      STOP               
      END                

---------------------

      PROGRAM BM7            
      DIMENSION M(5)         
      WRITE(3,1)             
    1 FORMAT(9H Start BM7)         
      K=0                    
      K=K+1                  
      A=K/2*3+4-5            
      CALL GOSUB             
      DO 3 L=1,5             
      M(L)=A                 
    4 CONTINUE               
      IF(K.LT.1000)GOTO 2    
      WRITE(3,3)             
    3 FORMAT(2H E)           
      STOP                 
      END                  
                           
      SUBROUTINE GOSUB    	
      RETURN              
      END                 
                                 
----------------------  

      PROGRAM BM8           
      WRITE(3,1)            
   1  FORMAT(9H Start BM8)        
      K=0                   
   2  K=K+1                 
      A=K**2                
      FK=K                  
      B=ALOG(FK)            
      C=SIN(FK)             
      IF(K.LT.101)GOTO 2    
      WRITE(3,3)            
   3  FORMAT(2H E)          
      STOP                  
      END                   
                            
----------------------  

      PROGRAM BM9       
      WRITE(3,1)        
    1 FORMAT(9H Start BM9)    
      DO 2 N=1,1000     
      DO 3 K=2,500      
      FN=N              
      FM=FN/K    PP     
      L=INT(FM)         
      IF(L .EQ.0)GOTO 4
      IF(L .EQ.1)GOTO 3     
      IF(FM.GT.L)GOTO 3     
      IF(FM.EQ.L)GOTO 2     
    3 CONTINUE              
    4 WRITE(3,6) N          
    6 FORMAT(1H ,I3)        
    2 CONTINUE              
      WRITE(3,7)            
    7 FORMAT(2H E)          
      STOP                  
      END                   

-------------------- 
