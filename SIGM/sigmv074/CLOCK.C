#include	CLOCK.H

#define	CENTURY	19		/* 20th Century at the moment */

/*
   By Bill Bolton,
   Software Tools,
   P.O. Box 80,
   Newport Beach,
   NSW, 2106,
   AUSTRALIA

   Source Address TCY-396
   Phone (+61 2) 997-1018

   Version 1.0 for Mountain Hardware 100,000 day clock 11/5/81
   Version 1.1 for Godbout Systsen Support 1 clock 19/1/82 */


/* date(srt,format) will fill a string with date formatted as follows:

	format = 0	"May 11, 1981"
	format = 1	"Monday, May 11, 1981"
	format = 2	"11/5/1981"
	format = 3	"Monday, 11/5/1981"
	format = 4	"11/5/81"
	format = 5	"Monday, 11/5/81"
*/

date(str,format)

char	*str;		/* pointer to date string */
int	format;		/* format identifier */

{
	char	wname[10];	/* string for week day proper name */
	char	mname[12];	/* string for month proper name */
	int	year[1];	/* year, range 1978 to ????? */
	int	month[1];	/* month of the year, range 1 to 12 */
	int	mday[1];	/* day of the current month, range 0 to 31 */
	int	wday[1];	/* day of the week, range 0 to 6 */ 

	if (get_date(year,month,mday,wday)){
		printf("No clock board present in system\07\n");
		return(-1);
	} 
	name_month(mname,month);
	name_week(wname,wday);
	switch(format){
	case 0:
		sprintf(str,"%s %d, %d%d",mname,*mday,CENTURY,*year);
		return(0);
	case 1:
		sprintf(str,"%s, %s %d, %d%d",wname,mname,*mday,CENTURY,*year);
		return(0);
	case 2:
		sprintf(str,"%d/%d/%d%d",*mday,*month,CENTURY,*year);
		return(0);
	case 3:
		sprintf(str,"%s, %d/%d/%d%d",wname,*mday,*month,CENTURY,*year);
		return(0);
	case 4:
		sprintf(str,"%d/%d/%d",*mday,*month,*year);
		return(0);
	case 5:
		sprintf(str,"%s, %d/%d/%d",wname,*mday,*month,*year);
		return(0);
	default:
		printf("Date format argument ERROR !\07\n\n");
		return(-1);
	}
}

/* get_date(year,month,mday,wday) provides the basic data for formatting
   a date string, fetched from the clock board and converted to a useable
   set of values */

int get_date(year,month,mday,wday)

int	*year;		/* pointer to current year */
int	*month;		/* pointer to current month */
int	*mday;		/* pointer to day of the month */
int	*wday;		/* pointer to day of the week */

{
	if (inp(CDATA) == 0XFF )      /* no clock board present */
		return(-1);
	*year =  (read_digit(YEAR10) * 10) + read_digit(YEAR1);
	*month = ((read_digit(MONTH10) & 1) * 10) + read_digit(MONTH1);
	*mday = ((read_digit(DAY10) & 3) * 10) + read_digit(DAY1);
	*wday = read_digit(WDAY);
	outp(CLKCMD,0);
	return(0);
}


int read_digit(address)

int	address;

{
	int	instruct;

	instruct = address + CREAD;
	outp(CLKCMD,instruct);
	return (inp(CDATA));
}

/* name_month(mname,month) fills a string with the name of the the
   current month.
*/

int name_month(mname,month)

char	*mname;		/* pointer to month name string */
int	*month;		/* pointer to current month */

{
	switch(*month){
	case 1:
		strcpy(mname,"January");
		return(0);
	case 2:
		strcpy(mname,"February");
		return(0);
	case 3:
		strcpy(mname,"March");
		return(0);
	case 4:
		strcpy(mname,"April");
		return(0);
	case 5:
		strcpy(mname,"May");
		return(0);
	case 6:
		strcpy(mname,"June");
		return(0);
	case 7:
		strcpy(mname,"July");
		return(0);
	case 8:
		strcpy(mname,"August");
		return(0);
	case 9:
		strcpy(mname,"September");
		return(0);
	case 10:
		strcpy(mname,"October");
		return(0);
	case 11:
		strcpy(mname,"November");
		return(0);
	case 12:
		strcpy(mname,"December");
		return(0);
	default:
		printf("Month name ERROR ! Month was %d\n",*month);
		return(-1);
	}
}

/* name_week(wname,wday) fills a string with the name of the current
   week day.
*/

int name_week(wname,wday)

char	*wname;		/* pointer to week name string */
int	*wday;		/* pointer to current week day */

{
	switch(*wday){
	case 0:
		strcpy(wname,"Sunday");
		return(0);
	case 1:
		strcpy(wname,"Monday");
		return(0);
	case 2:
		strcpy(wname,"Tuesday");
		return(0);
	case 3:
		strcpy(wname,"Wednesday");
		return(0);
	case 4:
		strcpy(wname,"Thursday");
		return(0);
	case 5:
		strcpy(wname,"Friday");
		return(0);
	case 6:
		strcpy(wname,"Saturday");
		return(0);
	default:
		printf("Weekday name ERROR !\n");
		return(-1);
	}
}

/* time(str,format) fills a string with the time of day in the 
   following formats :

	format 0 	1800:15
	format 1	18:00:15
	format 2	18:00
*/

time(str,format)

char	*str;		/* string to fill with time */
int	format;		/* flag for format of string */

{
	int	t[6];

	if (read_clock(t)){
		printf("No clock board present in system !\07\n");
		return(-1);
	} 
	switch(format){
	case 0:
		sprintf(str,"%d%d%d%d:%d%d",t[0],t[1],t[2],t[3],t[4],t[5]);
		return(0);
	case 1:
		sprintf(str,"%d%d:%d%d:%d%d",t[0],t[1],t[2],t[3],t[4],t[5]);
		return(0);
	case 2:
		sprintf(str,"%d%d:%d%d",t[0],t[1],t[2],t[3]);
		return(0);
	default:
		printf("Time of day format argument ERROR !\07\n\n");
		return(-1);
	}
}

/* read_clock(t) fills an array with the time of day digits read from
   the clock board
*/

int read_clock(t)

int	*t;		/* array to store clock digits */

{
	int	ptr;	/* pointer into digit array */

	if (inp(CDATA) == 0XFF )	/* no clock board present */
		return(-1);
	t[0] = (read_digit(HOUR10) & 3);
	t[1] = read_digit(HOUR1);
	t[2] = (read_digit(MIN10) & 7);
	t[3] = read_digit(MIN1);
	t[4] = (read_digit(SEC10) & 7);
	t[5] = read_digit(SEC1);
	outp(CLKCMD,0);
	return(0);
}
