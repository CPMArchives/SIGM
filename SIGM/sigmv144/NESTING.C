#define A
#define C

main()

{


#ifdef	A

printf("A is defined\n");


#ifdef	B

printf("A and B are  defined\n");

#else	/*B*/

printf("A is defined, but B is not\n");

#ifdef	C

printf("C is defined\n");


#else	/*C*/

printf("C is NOT defined\n");

#endif	/*C*/

#endif	/*B*/


#endif	/*A*/


#ifdef	B

printf("B are  defined\n");

#endif	/*B*/



}
