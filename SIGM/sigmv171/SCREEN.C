/************************************************************************
 *									*
 *  This program takes a Laboratory Microsystems Z80-FORTH screen file  *
 *  and creates a text file from it.  The output format is similar to   *
 *  the format used by Z80-FORTH for listing screens but can be		*
 *  redirected to any device supported on CP/M, or to a disk file which *
 *  can then be edited.  This program can be compiled with the Software *
 *  Toolworks C80 compiler.						*
 *									*
 *  Usage..                                                             *
 *									*
 *  SCREEN <file.SCR >output						*
 *									*
 ************************************************************************/

#define EOF -1
#define MAXLINE 65  /* max number of characters on line + 1 */
#define LINE_PER_SCR 16  /* number of lines per screen */

#include "printf.c"

main()
{  int screen=0, linenum, flag;
   char line[MAXLINE];

   flag=readline(line); 
   while(flag > 0){
	printf("\nScreen # %d\n\n",screen++);
	for(linenum=0; linenum < LINE_PER_SCR; linenum++){
		printf("%2d %s\n",linenum,line);
		flag=readline(line);
	}
   }
}

readline(s)  /* Get a line from screen file, returns 0=EOF; 1=valid line */
char s[];
{  int nblanks,c,i;
   nblanks=0;
   for(i=0; i < MAXLINE-1 && (c=getchar()) != EOF; i++){
	s[i]=c;
	if(c==' ') ++nblanks;
	  else nblanks=0;
   }
   if(c==EOF) return(0);
     else { s[MAXLINE-1-nblanks]='\0'; return(1); }

c==' ') ++nblanks;
	  else nblanks=0;
 