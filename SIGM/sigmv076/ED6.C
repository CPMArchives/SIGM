/* ED6.C */

#include ed0.c
#include ed1.ccc
int outx,outy;
outxget()
{
	return(outx);
}
outyget()
{
	return(outy);
}
outchar(c) char c;
{
	syscout(c);
	outx++;
	return(c);
}
outxy(x,y) int x,y;
{
	outx=x;
	outy=y;
	syscout(27);		/* H19/H89 values */
	syscout('Y');
	syscout(y+32);
	syscout(x+32);
}
outclr()
{
	syscout(27);		/* H19/H89 */
	syscout('E');
}
outdelln()
{
	outxy(0,outy);
	outdeol();
}
outdeol()
{
	syscout(27);		/* H19/H89 */
	syscout('K');
}
outuphas()
{
	return(YES);
}
outdnhas()
{
	return(YES);
}
outsup()
{
	outxy(0,SCRNL1);
	syscout(10);
}
outsdn()
{
	outxy(0,0);
	syscout(27);		/* H19/H89 */
	syscout('L');
}
op())){
			if (bufup()!=OK){
				return(ERR);
			}
			ypos--;
		}
	}