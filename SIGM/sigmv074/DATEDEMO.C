#include	CLOCK.H

#define	CENTURY	19		/* 20th Century at the moment */

/* Example program for real time system clocks.

   This main program simply calls the date function and time function,
   displaying the returned strings.

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

main()

{
	char	date_str[35];	/* string (character array) for date */
	char	time_str[8];	/* string for time */

	if (date(date_str,0)){
		printf("Exiting to CP/M\07\n");
		exit();
	}
	printf("Demonstration of 'C' functions for the ");
	printf("Godbout System Support 1 clock.\n\n");
	printf("\tBy Bill Bolton, Software Tools\n");
	printf("\tP.O. Box 80,\n\tNewport Beach,\n");
	printf("\tNSW, 2106, AUSTRALIA\n\n");
	printf("\Date format 0 is %s\n",date_str);
	date(date_str,1);
	printf("Date format 1 is %s\n",date_str);
	date(date_str,2);
	printf("Date format 2 is %s\n",date_str);
	date(date_str,3);
	printf("Date format 3 is %s\n",date_str);
	date(date_str,4);
	printf("Date format 4 is %s\n",date_str);
	date(date_str,5);
	printf("Date format 5 is %s\n",date_str);
	date(date_str,6);

	time(time_str,0);
	printf("Time of day format 0 = %s\n",time_str);
	time(time_str,1);
	printf("Time of day format 1 = %s\n",time_str);
	time(time_str,2);
	printf("Time of day format 2 = %s\n",time_str);
	time(time_str,3);
	date(date_str,1);
	time(time_str,0);
	printf("Printed at %s Hours on %s.\n\n",
			time_str,date_str);
 }

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

/* ndays(year) returns the number of days in the current year.
*/

int ndays(year)

int	*year;		/* pointer to current year */

{
	return(leap(*year) ?  366 : 365);
}

/* leap(year) returns a flag to indicate if current year is a leap year.
*/

int leap(year)

int	year;		/* current year */

{
	return (year%4 == 0 && year%100 != 0 || year%400 == 0);
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

