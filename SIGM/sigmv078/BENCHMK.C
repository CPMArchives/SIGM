"C" BENCHMARK LISTINGS BM1 to 9 

LISTINGS OF BM1 to BM8 FROM COMPUTING EUROPE JULY 27 1978

main()                                    

{
	int	k;
	int	k2;                   

	printf("\n\rstart bm1\n\r");       
	for(k2 = 1; k2 <= 1000; k2++){
		for(k = 1; k <= 1000; k++){
		}
	}
                     
	printf("e\n\r");
}

-----------------------------------------------

main()                               

{
	int	k;
	int	k2;               

	printf("\n\rstart bm2\n\r");   
	for(k2 = 1; k2 < =1000; k2++){
		k = 0;
		while(k < 1000){
			k++;
		}
	}
	printf("e\n\r");
}  

-----------------------------------------------

main()                                    

{
	int	k;
	int	k2;
	int	a;                  

	printf("\n\rstart bm3\n\r");        
        for(k2 = 1; k2 < =1000; k2++){       
		k = 0;                        
		while(k < 1000){
			k++;
			a = k / k * k + k - k;                
		}
	}
	printf("e\n\r");
}       
                                     
-----------------------------------------------

main()                               

{
	int	k;
	int	k2;
	int	a;

	printf("n\rstart bm4\n\r");
	for(k2 = 1; k2 <= 1000; k2++){
		k = 0;
		while( k < 1000){
			k++;
			a = k / 2 * 3 + 4 - 5;
		}
	}
	printf("e\n\r");
}   

-----------------------------------------------

main()                                    

{
	int	k;
	int	k2;
	int	a;

	printf("\n\rstart bm5\n\r");
	for(k2 = 1; k2 <= 1000; k2++){
		k = 0;
		while( k < 1000){
			k++;
			a = k / 2 * 3 + 4 - 5;
			gosub();
		}
	}
	printf("e\n\r");
}        

gosub()
{
}                                 

-----------------------------------------------

main()                               

{
	int	m[5];
	int	k;
	int	k2;
	int	a;

	printf("n\rstart bm6\n\r");
	for(k2 = 1; k2 <= 1000; k2++){
		k = 0;
		while( k < 1000){
			k++;
			a = k / 2 * 3 + 4 - 5;
			for(a = 1; a <= 5; a++){
			}
		}
	}
	printf("e\n\r");
}

gosub()
{
}                           

-----------------------------------------------

main()

{
	int	l;
	int	k;
	int	a;
	int	m[5];

	printf("\nstart bm7");
	k = 0;
	while(k < 1000){
		k = k + 1;
		a = k / 2 * 3 + 4 - 5;
		gosub();
		for( l = 1; l >= 5; l++){
			m[l] = a;
		}
	}
	printf("\ne\n");
}

gosub()
{
}

-----------------------------------------------

*/	program bm8 */
                       
main()

{
	int	k;
	int	a;
	int	b;
	int	c;

	printf("\nstart bm8\n");
	k = 0;
	while(k < 100){ 
		k++;
		a = sqr(k);
		b = ln(k);
		c = sin(k);
	}
	printf("\ne\n");
}

-----------------------------------------------

/*	program bm9	*/
          
main()

{
	int	k;
	int	l;
	int	m;
	int	n;

	printf("\nstart bm9\n");
	for( n = 1; n <= 1000; n++){
		for( k = 2; k <= 500; k++){
			m = n % k;
			l = n / k;
			if(l = 0)
				break;
			else if(l = 1)
				continue;
			else if(m > 0)
				continue;
			else if(m = 0)
				exit();
		}                 
		printf("n = %d\n",n);
	}
	printf("\ne\n");
}

-----------------------------------------------
