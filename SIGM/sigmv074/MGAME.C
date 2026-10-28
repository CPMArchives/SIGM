/* New maths game for kids, based on an idea by Michael Mannington

     By	Bill Bolton,
	Software Tools,
	P.O. Box 80,
	NSW, 2106,
	AUSTRALIA

	June 14, 1981	Version 1.0 (Initial Release)

*/	

#include BDSCIO.H	/* useful definitions etc. */

#define STDIN 0		/* CP/M console input */
#define STDOUT 1	/* CP/M console output */
#define SCALE 10	/* Maximum value of random number, change to make the
			   game harder as child gets older */

int	odevice;	/* All functions should know about I/O devices */
int	idevice;

main()

{
	int	right;	/* Number of correct answers */
	int	plays;	/* Number of turns */ 

	right = 0;	/* Initialisation */
	plays = 0;
	odevice = STDOUT;	/* Change for different I/O */
	idevice = STDIN;

	/* Set up the game */

	fprintf(odevice,"\n\tSoftware Tools Presents\n");
	fprintf(odevice,"\n\tLETS PLAY......NUMBERS\n\n");
	srand1("Press any key to start.\n\n");
	getchar(); /* Clear answer to srand1 prompt from input */

	/* Play the game, always at least one turn */

	do {
		turn(&right,&plays);
	} while(more());

	/* Report results and say goodbye */

	fprintf(odevice,"Thanks for playing, you got %d right from %d turns\n",
			right,plays);
}

/* Gets two randomly generated numbers and asks the question, evaluates the
   the answer and displays the response, checks for numeric answer */

turn(right,plays)

int	*right;		/* pointer to munber of right answers */
int	*plays;		/* pointer to number of turns */

{
	int	first;	/* first randomly generated  number */
	int	second;	/* second  ditto */
	int	result;	/* players answer as a number */
	char	answer[10];	/* players answer as a string */

	do {
		first = rand()%SCALE;	/* change SCALE in header to change */
		second = rand()%SCALE;	/* range of random numbers */
	} while((first + second) == 0); /* eliminate 0 + 0 */ 
	ask(first,second,answer);
	while((result = atoi(answer)) == 0) { /* only accept numbers */
		fprintf(odevice,"You MUST answer with a number, try again.\n\n");
		ask(first,second,answer);
	}

	/* test answer for correctness, only two choices : right or wrong */

	if(result == (first + second)) {
		fprintf(odevice,"GREAT, you got it RIGHT !\n\n");
		(*right)++;
	}
	else {
		fprintf(odevice,"Sorry, the right answer was %d\n\n",
			first + second);
	}
	(*plays)++;
}

/* Asks the question and gets the players answer as a string */

ask(first,second,answer)

int 	first;	/* local copy of first number */
int	second;	/* local copy of second number */
char	*answer;	/* pointer to string */

{
	fprintf(odevice,"What is   %d  +  %d     ",first,second);
	fgets(answer,idevice);
}

/* Asks if the player wants another turn, returns 1 if Yes */

more()

{
	char	c;

	fprintf(odevice,"Another turn ? .... type N for NO or Y for YES....");
	c = getc(idevice);
	fprintf(odevice,"\n\n");
	return((toupper(c) == 'N') ? 0 : 1);
}
