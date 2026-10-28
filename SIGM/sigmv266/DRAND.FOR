        SUBROUTINE      DRAND  (ISEED,RNUM)
C////////////////////////////////////////////////////////////////
C/                                                              /
C/      Program-id.     DRAND                                   /
C/      Date-written.   Jan. 16th 1984                          /
C/      File-name.      DRAND.FOR                               /
C/      Remarks.        Subroutine DRAND.FOR page 96.           /
C/                      Generates a uniformly distributed 	/
C/                      random variable between 0.0 and 1.0.    /
C/                      This is a pseudo-random number and was  /
C/                      modified for IBM 1130 subroutine 	/
C/                                                              /
C////////////////////////////////////////////////////////////////
C
C	* This is a dummy; real work is done by RANDU.
C
        CALL    RANDU(ISEED,RNUM)
        RETURN
        END
