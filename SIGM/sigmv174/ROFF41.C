/********************************************************/
/*							*/
/*		    ROFF4, Version 1.60			*/
/*							*/
/*(C) 1983,4 by Ernest E. Bergmann			*/
/*		Physics, Building #16			*/
/*		Lehigh Univerisity			*/
/*		Bethlehem, Pa. 18015			*/
/*							*/
/* Permission is hereby granted for all commercial and	*/
/* non-commercial reproduction and distribution of this	*/
/* material provided this notice is included.		*/
/*							*/
/********************************************************/
/*Jan 8, 1984*/
#include "roff4.h"
/**********************************************************
Removes white-space characters at start of string.
***********************************************************/
skip_blanks ( string )
char *string;	/* cursor to original string */
{char *p;	/* cursor to 'final' string */
for(p=string;*string==BLANK||*string==TAB||*string==NEWLINE;
	string++);
while(*(p++) = *(string++));
}
/*************************************************************/
int comtyp (line)
char *line;
{char let1, let2;
let1 = toupper( line[1] );
let2 = toupper( line[2] );

if ( let1==COMMAND )		return( IG );
if ( let1=='I' && let2=='G')	return( IG );
if ( let1=='F' && let2=='I')	return( FI );
if ( let1=='F' && let2=='O')	return( FO );
if ( let1=='T' && let2=='I')	return( TI );
if ( let1=='B' && let2=='P')	return( BP );
if ( let1=='B' && let2=='R')	return( BR );
if ( let1=='C' && let2=='E')	return( CE );
if ( let1=='H' && let2=='E')	return( HE );
if ( let1=='I' && let2=='N')	return( IN );
if ( let1=='L' && let2=='S')	return( LS );
if ( let1=='N' && let2=='F')	return( NF );
if ( let1=='P' && let2=='L')	return( PL );
if ( let1=='R' && let2=='M')	return( RM );
if ( let1=='S' && let2=='P')	return( SP );
if ( let1=='S' && let2=='T')	return( ST );
if ( let1=='N' && let2=='E')	return( NE );
if ( let1=='F' && let2=='F')	return( FF );
if ( let1=='S' && let2=='C')	return( SC );
if ( let1=='O' && let2=='W')	return( OW );
if ( let1=='T' && let2=='S')	return( TS );
if ( let1=='O' && let2=='H')	return( OH );
if ( let1=='O' && let2=='F')	return( OF );
if ( let1=='E' && let2=='H')	return( EH );
if ( let1=='E' && let2=='F')	return( EF );
if ( let1=='A' && let2=='B')	return( AB );
if ( let1=='D' && let2=='B')	return( DB );
if ( let1=='T' && let2=='C')	return( TC );
if ( let1=='T' && let2=='R')	return( TR );
if ( let1=='C' && let2=='F')	return( CF );
if ( let1=='I' && let2=='C')	return( IC );
if ( let1=='O' && let2=='U')	return( OU );
if ( let1=='J' && let2=='U')	return( JU );
if ( let1=='N' && let2=='J')	return( NJ );
if ( let1=='F' && let2=='R')	return( FR );
if ( let1=='W' && let2=='H')	return( WH );
if ( let1=='E' && let2=='M')	return( EM );
if ( let1=='D' && let2=='M')	return( DM );
if ( let1=='D' && let2=='S')	return( DS );
if ( let1=='R' && let2=='G')	return( RG );
if ( let1=='D' && let2=='I')	return( DI );
if ( let1=='E' && let2=='D')	return( ED );
if ( let1=='S' && let2=='O')	return( SO );
if ( let1=='P' && let2=='C')	return( PC );
if ( let1=='S' && let2=='A')	return( SA );
if ( let1=='B' && let2=='J')	return( BJ );

if ( let1=='M')
      { if (let2=='1')		return( M1 );
	if (let2=='2')		return( M2 );
	if (let2=='3')		return( M3 );
	if (let2=='4')		return( M4 );
      }
return( UNKNOWN );		/* no match */
}
/*************************************************************
gets the number ( if any ) associated with any command 
*************************************************************/
int get_val ( line, typ )
char *line, *typ;
{int i;
char local[ MAXLINE ];
strcpy (local, line);	/* local copy */
/* skip over the command line */
for(i=1; local[i]!=' '&&local[i]!='\t'&&local[i]!='\n' ;i++);

skip_blanks (&local[i]);	/* find the number */
*typ = local[i];	/* relative or absolute */
if ( *typ=='+' || *typ=='-' )	i++;
else if ( !isdigit( *typ ) )	return( NO_VAL );
return ( atoi( &local[i] ));
}
/*************************************************************
 sets a global parameter like SPVAL, PAGESTOP, etc.
 Also checks that the new value is within the range of that 
 parameter.  Assigns the default for that parameter if no value
  is specified.
*************************************************************/
set ( param, val, arg_typ, defval, minval, maxval )
int *param, val, defval, minval, maxval;
char arg_typ;
{if(val==NO_VAL) *param = defval;	/* defaulted */
else if(arg_typ == '+') *param += val;	/* relative + */
else if(arg_typ == '-')	*param -= val;	/* relative - */
else	*param = val;			/* absolute */
*param = min (*param,maxval);
*param = max (*param, minval);
if DEBUG fprintf(STDERR,"\tSET *param = %d\n", *param);
}
/*************************************************************
	end current filled line 
**************************************************************/
brk()
{int l;
if DEBUG fprintf(STDERR,"brk: OUTBUF=<%s>\n", OUTBUF);
if (OUTPOS) put(OUTBUF);
OUTW=OUTPOS=OUTTOP=OUTBOT=OUTWRDS = 0;
OUTBUF[0] = '\0';
}

/**************************************************/
initxu()	/*initialize underline,overstrike variables*/
{	XCOL=UCOL=-1;
	setmem(&XBUF,LSZ,' ');
	setmem(&UBUF,LSZ,' ');
}
/****************************************/
need(n)	/*test for space before footer*/
int n;	/*whole lines*/
{if (( VLINENO>=(BOTTOM-n) ) && (BOTTOM>=VLINENO) )
	{space(HUGE); NEWPAG= ++CURPAG;
	}
}
/****************************************/
/*from stdlib1.c, with minor mods*/

free(ap)
struct _header *ap;
{
	struct _header *p, *q;
	p = ap - 1;	/* No need for the cast when "ap" is a struct ptr */

	for (q = _allocp; !(p > q && p < q -> _ptr); q = q -> _ptr)
		if (q >= q -> _ptr && (p > q || p < q -> _ptr))
			break;
	if (p + p -> _size == q -> _ptr) {
		p -> _size += q -> _ptr -> _size;
		p -> _ptr = q -> _ptr -> _ptr;
	 }
	else p -> _ptr = q -> _ptr;

	if (q + q -> _size == p) {
		q -> _size += p -> _size;
		q -> _ptr = p -> _ptr;
	 }
	else q -> _ptr = p;

	_allocp = q;
}
/******************************************/
char *alloc(nbytes)
unsigned nbytes;
{
	struct _header *p, *q, *cp;
	int nunits; 
	nunits = 1 + (nbytes + (sizeof (_base) - 1)) / sizeof (_base);
	if ((q = _allocp) == NULL) {
		_base._ptr = _allocp = q = &_base;
		_base._size = 0;
	 }
	for (p = q -> _ptr; ; q = p, p = p -> _ptr) {
		if (p -> _size >= nunits) {
			if (p -> _size == nunits)
				q -> _ptr = p -> _ptr;
			else {
				p -> _size -= nunits;
				p += p -> _size;
				p -> _size = nunits;
			 }
			_allocp = q;
			return p + 1;
		 }
		if (p == _allocp) {
			if ((cp = sbrk(nunits * sizeof (_base))) == ERROR)
				{fprintf(STDERR,"\nCan't Allocate more buffer space.");
				return NULL;
				}
			cp -> _size = nunits; 
			free(cp+1);	/* remember: pointer arithmetic! */
			p = _allocp;
		}
	 }
}
 -> _ptr -> _ptr;
	 }
	else p -> _ptr = q -> _ptr;
