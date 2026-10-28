PROCEDURE popstats(VAR a          : list;
                   n1st,nlast     : INTEGER;
                   VAR parameters : varrecord);
{$c-    [ control C checking off] }
{
Comment  :  Popstats will calculate the mean , mode , median , variance ,
standard deviation,standard error of the mean,coefficients of skewness 
and kurtosis,standard errors of skewness and kurtosis,and range (smallest
and largest values) of the population of observations in the array "a" (of 
real numbers ) from a[n1st] to a[nlast].
If you wish to analyse the whole array then just set n1st = 1 & nlast = N
where N is the order of the array.
The above statistics ,if no errors occurr ,are returned as the return value
of the variable corresponding to "parameters".This variable is structured as
a variable record of type varrecord which MUST be defined at a higher level
exactly as follows :

TYPE
	varrecord	= RECORD
	  CASE success : BOOLEAN OF
               TRUE    : ( mean,
                           mostfreq,
                           middle,
                           variance,
                           stddevtn,
                           stderrmn,
                           skewness,
                           kurtosis,
			   semedian,
			   seskewns,
			   sekurtss : REAL;
			   range    : ARRAY[1..2] OF REAL);
               FALSE   : ( errmsg1,
                           errmsg2,
                           errmsg3,
                           errmsg4  : BOOLEAN );
               END; 

The record field success will indicate if ANY errors occurred.If success
is FALSE then the other fields will indicate the type of error.
                       errmsg1 : TRUE means n < 1;
                       errmsg2 : TRUE means n < 4;
                       errmsg3 : TRUE means array is uniform;

Externals required := FUNCTIONS median and select

}
CONST
	nbins		= 15; { (MUST be ODD) = 1 : number of bins that
                               data are counted into when calculating mode.
                                                2 : scaling factor to code
                               the range of observations when calculating
                               sums powers of the deviations from the mean.}
        large           = 150;{ value of n above which simpler calculations
                                are used for skewness and kurtosis }
VAR
	popular,
	bindex,
	n,i,bin#	: INTEGER;

        bin		: ARRAY[1..nbins] OF INTEGER;

	temp1,
	temp2,
	ratio1,
	ratio2,
	ratio3,
	ratio4,
	ratio5,
	ratio6,
	ratio7,
	vcoded,
	midval,
	smallest,
	biggest,
        binwidth,
	yc,ycsq,
	ycqd,yc4d,
	syc,sycsq,
	sycqd,syc4d	: REAL;

BEGIN
WITH parameters DO BEGIN
 success := FALSE;
 errmsg1 := FALSE;
 errmsg2 := FALSE;
 errmsg3 := FALSE;
 errmsg4 := FALSE;
 IF (median(a,n1st,nlast,midval) = FALSE) { checks list size & gets median }
 THEN BEGIN
       errmsg1 := TRUE;     { To indicate that n < 1 , median failed }
      END
 ELSE BEGIN
       n        := nlast - n1st + 1;
       IF n < 4
       THEN errmsg2 := TRUE
       ELSE BEGIN
         smallest := a[n1st];
         biggest  := smallest;
         FOR  i   := n1st TO nlast DO
           BEGIN
            IF a[i] > biggest
              THEN biggest := a[i]
              ELSE BEGIN
                    IF a[i] < smallest THEN smallest := a[i];
                   END;
           END;
         IF biggest = smallest
         THEN BEGIN
               errmsg3 := TRUE; { To indicate that array is uniform! }
              END
         ELSE BEGIN             { now to calculate the parameters.   }
               success  := TRUE;
               range[1] := smallest;
               range[2] := biggest;
               binwidth := (biggest - smallest) / nbins;
               FOR   i  := 1    TO nbins DO bin[i] := 0;
               FOR   i  := n1st TO nlast DO
                BEGIN
                 bin#      := TRUNC((a[i] - smallest) / binwidth) + 1;
                 IF bin# > nbins THEN bin# := nbins; { to allow the biggest
                                                       value to go into the 
                                                       correct bin.         }
                 bin[bin#] := bin[bin#] + 1;
                END;
               bindex  := 1;
               popular := bin[1];
               FOR i := 2 TO nbins DO
                BEGIN
                 IF bin[i] > popular
                    THEN BEGIN
                          bindex  := i;
                          popular := bin[i];
                         END;
                END;
               mostfreq := smallest + (binwidth * (bindex - 0.5));{ mode is 
                                                                    done ! }
             { now get the rest of the parameters }
               syc      := 0.0;
               sycsq    := 0.0;
               sycqd    := 0.0;
               syc4d    := 0.0;
               FOR  i := n1st TO nlast DO
                 syc := syc + (a[i] - midval);
                 { comment : by determining the sum of the differrences from
                   the median you will end up with a much smaller number than
                   if you add the raw values.This avoids loss of precision
                   when n is large and the sum of the data can be many orders
                   larger than any individual datum.All you have to do then
                   is the reverse coding to get the true mean.}
               mean := (syc/n) + midval;
               syc  := 0.0;
               FOR  i := n1st TO nlast DO
                BEGIN
                 yc     := (a[i] - mean)/binwidth;
                           { code deviations so they lie in a small range 
  			     about zero, to avoid the problems with raising 
  			     large or small #s to their 3rd & 4th powers.}
                 ycsq  := yc * yc;
                 ycqd  := yc * yc * yc;
                 syc   := syc +  yc;
                 sycsq := sycsq +  ycsq;
                 sycqd := sycqd + ycqd;
                 syc4d := syc4d + ycqd * yc;
                END;
              vcoded     := sycsq /(n - 1);
              variance   := vcoded * binwidth * binwidth;
              stddevtn   := SQRT(variance);
              middle     := midval;
              stderrmn   := stddevtn/(SQRT(n));
              semedian   := 1.2533 * stderrmn;
              IF n > large { use simpler equations for skewness + kurtosis }
                THEN BEGIN
                     skewness :=  sycqd/(n * vcoded * SQRT(vcoded));
                     kurtosis := (syc4d/(n * SQR(vcoded))) - 3.0;
                     seskewns := SQRT(6.0/n);
                     sekurtss := SQRT(24.0/n)
                     END
                ELSE BEGIN  {If n is not large then you have to correct the
                             estimates of skewness and kurtosis for sample
                             size bias.This complicates the equations by
                             adding factors of the order of n to both their
                             numerators and their denominators.This in turn
                             creates significant risks of arithmetic errors
                             such as overflow and loss of precision.To avoid
                             these the calculations are done indirectly at a
                             cost of space,time and readability,unfortunately.}

                     ratio1   := n/(n - 1);       {First set up these ratios..}
                     ratio2   := (n - 1)/(n - 3); {..all of which will be ... }
                     ratio3   := (n - 1)/(n - 2); {..approx. = 1.0 }
                     ratio4   := ratio2 * ratio3;
                     ratio5   := (n + 1)/(n - 2);
                     ratio6   := n/(n + 1);
                     ratio7   := ratio1 * ratio5;
                     temp2    := sycqd/vcoded;
                     temp1    := ratio1 * temp2;
                     temp1    := temp1/(n - 2);
                     skewness := temp1/(SQRT(vcoded));
                     temp1    := syc4d / (SQR(vcoded));
                     temp2    := ratio7 * temp1 / (n -3);
                     kurtosis := temp2 - (3.0 * ratio4);
                     seskewns := SQRT((6.0*ratio6*ratio3)/(n+3));
                     temp2    := 24.0 / (n + 3);
                     temp1    := ratio4 * temp2;
                     sekurtss := SQRT(temp1/(n +5));
                    END;
            END; { of : calculation of parameters }
      END; { of : if n < 4 }
  END; { of : IF median }
 END;  { of : WITH parameters DO }
END;   { of : PROCEDURE popstats }



