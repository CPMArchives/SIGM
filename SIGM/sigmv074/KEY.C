/*
This utility will program strings under the keys in the numeric keypad
on an ADM-31 terminal with version 4.00 or later firmware. The maximum
number of characters that can be stored under ALL the keys is 80.

Version	1.0	Initial release in 'C', 10/March/1982	

By		Bill Bolton
		Software Tools,
		P.O. Box 80,
		Newport Beach,
		NSW, 2106,
		AUSTRALIA

*/

#include	BDSCIO.H

main()

{
	int	i;
	int	length;
	char	answer;
	char	string[10][80];

	/* Clear any existing programming */

	printf(CLEARS);
	for(i = 0; i < 10; i++) {
		printf("H%d%c!%d%s",i,ESC,i,CLEARS);
		}

	/* Tell them what we are about */

	printf("ADM-31 Keypad Programming Utility, by Bill Bolton, ");
	printf("Software Tools, 1982\n\n"); 
	printf("This utility will program the numeric key pad");
	printf(" on a Lear Siegler ADM-31\n");
	printf("terminal with revision 4.xx firmware.\n\n");
	printf("A maxiumum of 80 characters may be programmed");
	printf(" under all keys.\n\n");
	printf("If you don't want to program a key just press 'Return'.\n\n");

	/* Now fetch the strings to be programmed under keys,
	   if <CR> pressed, make the string the numeric value on the
	   key top under the key...i.e. no change */
		
	length = 0;
	for (i = 0; i < 10; i++) {
		printf("String for numeric pad key %d :",i);
		gets(string[i]);
		if(string[i][0] == 0)
			sprintf(string[i],"%d",i);
		length += strlen(string[i]);
		if(length >= 80) {
			printf("\nTerminal key buffer full !\7\n");
			printf("Hit any key to program strings entered so");
			printf(" far or Control-C to quit");
			getchar();
			break;
			}
		printf("Terminal buffer space remaining = %d\n",80 - length);
		}

	/* Clear the screen */

	printf(CLEARS);

	/* Program the keys */

	for (i = 0; i < 10; i++) {
		printf("H%s%c!%d%s",string[i],ESC,i,CLEARS);
		}

	/* Finish up */

	printf("Do you want to enable programmed functions");
	printf(" (Y/N 'Return' = Y) ");
	if((answer = toupper(getchar())) != 'N') {
		printf("\n%c!YKeys programmed!",ESC);
		}
	printf("\n\nFinished programming numeric keys.\n");
	exit();
}
