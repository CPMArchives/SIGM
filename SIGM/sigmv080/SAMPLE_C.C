/* Program in BDS C to count to 10,000 */

#define START_NUMBER 1
#define END_NUMBER 10000
#define INTERVAL 1000

int number ;
char go ;

main ()

  { printf ("\7\nCounting program in BDS C\n\n") ;
    printf ("Press <RETURN> to start: ") ;
    go = getchar () ;
    printf ("\nCounting ...\n\n") ;

    for (number = START_NUMBER; number <= END_NUMBER; number ++)
    /*	(Remove next two comment indicators for version 2 of program) */
    /*	if ((number % INTERVAL) == 0)
	  printf ("%5u\n",number)	 */ ;

     printf ("\7\nFinished -- Good-bye\n\n") ;
  }
    /*	if ((number % INTERVAL) == 0)
	  printf ("%5u\n",