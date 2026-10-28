#define MAX 1000

main()     /* program to print primes to 1000 */
{

     int next, itest, limit;

     next = 3;
     printf("Starting...\n2");
     do {
	  itest = 2;
/*          limit = sqr(next,5);
*/
	  limit = next/2;
          while(next % itest != 0) {
               itest++;
               if(itest > limit) {
		    printf(" %d",next);
		    break;
	       }
          }
     next += 2;
     } while (next < MAX);
}

sqr(n,k)
int n,k;
{
     if(k==0) return (n/2);
     else return((sqr(n,k-1)+n/sqr(n,k-1))/2);
}
