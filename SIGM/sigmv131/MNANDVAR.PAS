
PROCEDURE MNANDVAR(VAR A:DATA_ARRAY;
		       N:INTEGER;
		   VAR VARIANCE,MEAN : REAL);
		
          VAR     SUMNSQD: REAL;
                     SUMN: REAL;
                        I: INTEGER;

BEGIN
 SUMNSQD:=0;
 SUMN:=0;
 FOR I:=1 TO N DO BEGIN
   SUMN:=SUMN+A[I];
   SUMNSQD:=SUMNSQD+SQR(A[I]);
   END;  
 VARIANCE:=(SUMNSQD-(SQR(SUMN)/N))/(N-1);
 MEAN:=SUMN/N;
END;
