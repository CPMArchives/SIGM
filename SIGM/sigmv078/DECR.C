/*	This command strips CRLFs from a given file.
	Usage:
		A>decr infile outfile (-s)<cr>
	written by Les Bell         Sept, 1981           */

#include "bdscio.h"
main(argc,argv)
char **argv;
{
	int ifd, ofd;
	char ibuf[BUFSIZ];
	char obuf[BUFSIZ];
	char linebuf1[135];
	char linebuf2[135];

	if ((argc != 3)&&(argc !=4)) {
		printf("Usage: decr infile outfile (-s)\n");
		exit();
	}

	if ((ifd = fopen(argv[1], ibuf)) == ERROR) {
		printf("cannot open: %s\n",argv[1]);
		exit();
	}

	if((ofd = fcreat(argv[2], obuf)) == ERROR) {
		printf("cannot open: %s\n",argv[2]);
		exit();
	}

	strcpy(linebuf2,'\n');

	while (fgets(linebuf1,ibuf)) {
		if(strcmp(linebuf1,"--more--\n") == 0) {
			fgets(linebuf1,ibuf);
		}
		if¨ (argc == 4)&&(isspace(linebuf1[0]))) {
			fprintf(obuf¬ "%s\n"¬ linebuf2);
			strcpy(linebuf2,linebuf1);
		}
		else if( isspace(linebuf1[0])) {
			fprintf(obuf, "%s", linebuf2);
			strcpy(linebuf2,linebuf1);
		}
		else {
			linebuf2[strlen(linebuf2)-1] = ' ';
			linebuf2[strlen(linebuf2)] = '\0';
			fprintf(obuf, "%s", linebuf2);
			strcpy(linebuf2, linebuf1);
		}
	}
	fflush(obuf);
	fclose(obuf);
}
