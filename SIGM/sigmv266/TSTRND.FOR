C	[TSTRND.FOR of JUGPDS Vol.8]
C
	program	tstrnd
C
C	This is a test program for DRAND and RANDU.
C
	integer*4	isum
	dimension	irand(500),rand(500)
	data 	bel/Z'07'/
C
	write(1,100)
  100	  format(1h1,5x,'** Test of Random Number Routine **'/)
   10	write(1,110)
  110 	  format(1h ,'Enter number of sets to be generated (I4): ')
	read(1,200) iset
  200     format(I4)
	if (iset.le.500) goto 20
	write(1,120) bel
  120	  format(1h ,A1,'Too big (ISET<=500)!'/)
					goto 10
   20	write(1,130)
  130	  format(1h ,'Enter the seed (I4): ')
	read(1,200) iseed
C
	isum = 0
	sum = 0.0
	ix = iseed
	do 300 i=1,iset
	  call	drand(ix,rnum)
	  ix = ix * rnum
	  irand(i) = ix
	  rand(i) = rnum
	  isum = isum + ix
	  sum = sum + rnum
  300	continue
	write(1,400) (irand(i),rand(i),i=1,iset)
  400	  format(1h ,4(i10,f10.4))
	imean = isum /float(iset)
	xmean = sum / iset
	write(1,500) imean,xmean
500	format(1h0,'Mean: ',I10,2x,f6.4)
	stop
	end

	