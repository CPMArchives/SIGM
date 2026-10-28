/* MARGIN.C 22nd Feb 1981

	Prompts user to set margins on diablo daisy wheel printer,
	for use with a cut sheet feeder

	By	Bill Bolton
		Software Tools
		P.O. Box 80
		Newport Beach
		NSW, 2106
		Australia
*/

#define MINMARG 0
#define MAXMARG	156
#define MAXTAB 125
#define LSIDE '9'
#define RSIDE '0'
#define HT  0x09
#define ESC 0x1b
#define STDIN 0
#define STDOUT 1
#define LST 2

int	odevice;
int	idevice;
int	ldevice;

main (argc,argv)

int	argc;
char	*argv[];

{
	int	lmargin;
	int	rmargin;
	char	lstr[6];
	char	rstr[6];

	lmargin = 0;			/* intialisation */
	rmargin = 0;
	odevice = STDOUT;
	idevice = STDIN;
	ldevice = LST;
	sprintf(lstr,"left ");
	sprintf(rstr,"right");

	fprintf(odevice,"\n\tCopyright (C) 1981, Software Tools, Sydney,\
 Australia.\n");
	fprintf(odevice,"\tMARGIN Version 1.0 (Diablo)\n\n");
	fprintf(odevice,"\tThis program sets the margins on a Diablo daisy\
 wheel printer, margin\n");
	fprintf(odevice,"\tpositions can only be set in the range 0 to %d\
 from this program.\n\n\t",MAXMARG);
	while (rmargin <= lmargin) {
		fprintf(odevice,"Right margin must be greater than left\
 margin.\n\n");
		lmargin = get_margin(lstr);
		rmargin = get_margin(rstr);
		if (rmargin <= lmargin) {
			fprintf(odevice,"\007\tRight margin error. ");
		}
	}
	fprintf(odevice,"\n\tLeft  margin is set to %d\n",lmargin);
	fprintf(odevice,"\tRight margin is set to %d\n",rmargin);
	set_margin(++lmargin,LSIDE);
	set_margin(++rmargin,RSIDE);
	putc('\r',ldevice);
}

/* prompts user for required margin, does range check and return margin */

get_margin(str)

char	*str;

{
	int	margin;
	char	reply[8];

	fprintf(odevice,"\tEnter position for %s margin  : ",str);
	fgets(reply,idevice);
	margin = atoi(reply);
	while (margin > MAXMARG || margin < MINMARG) {
		fprintf(odevice,"\007\n\tMargin MUST be in the range 0\
 to %d, renter.\n\n",MAXMARG);
		margin = get_margin(str);
	}
	return(margin);
}


set_margin(margin,side)

int	margin;
int	side;

{
	int	i;

	if(margin > MAXTAB) {
		fprintf(ldevice,"%c%c%c",ESC,HT,MAXTAB);
		for( i = 1; i <= (margin - MAXTAB); i++)
			putc(' ',ldevice);
	}
	else {
		fprintf(ldevice,"%c%c%c",ESC,HT,margin);
	}
	fprintf(ldevice,"%c%c",ESC,side);
}
