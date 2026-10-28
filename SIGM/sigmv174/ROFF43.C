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
/*MAR 10, 1984*/
#include "roff4.h"
/****************************************/
regist(s)	/*checks RLIST; creates new entry if needed;
		returns pointer to integer variable*/
char *s;
{int *pw;
char *pc,*s2;
pw=find2(s,RLINK);
if(pw) return(pw); /*else create new entry*/
pw=TREND;
*pw=RLINK;
pc=pw+1;
s2=s;
transfer(&s2,&pc,'\0');
RLINK=TREND;
pw=pc;
*pw=REGDEF;
TREND=pw+1;
return(pw);
}
/****************************************/
dovar()	/*process .RG request*/
{char typ, wbuf[MAXLINE];
int val, *pw;
getwrd(LINE,wbuf);
skip_blanks(LINE);
val=get_val(LINE,&typ);
getwrd(LINE,wbuf);
if(wbuf[0]==NUMSIGN && wbuf[1]=='\0')
	{set(&NEWPAG,val,typ,NEWPAG,1,9999);
	}
else	{pw=regist(wbuf);
	set(pw,val,typ,REGDEF,1,9999);
	}
}
/****************************************/
dodiv()		/*process .DIversion*/
{char wbuf[MAXLINE],*pc,*pc1,*wb;
struct divfd *pd;
int *pw;
getwrd(LINE,wbuf);
if(getwrd(LINE,wbuf)!=WE_HAVE_A_WORD)
	{strcpy(wbuf,"JUNK.$$$");
	fprintf(STDERR,"DIVERSION has no name, %s assumed\n",
				wbuf);
	}
ucstr(wbuf);
if(pd=find2(wbuf,DLINK))	/*if in table*/
	{if(!(pd->bf))		/*if not open*/
	    if(pd->bf = alloc(BUFSIZ)) /*if space for buffer*/
			{if(fcreat(wbuf,pd->bf)!=ERROR)
				fprintf(STDERR,
				"<%s> rewritten for .DI\n",
				wbuf);
			else	{fprintf(STDERR,
				"<%s> cannot be rewritten\n",
				wbuf); exit();
				}
			}
		else	{fprintf(STDERR,
				"\nCan't get space for <%s>\n",
				wbuf); exit();
			}
	}
else	/*not in table*/
	{pw=TREND;
	*pw=DLINK;
	pc1=pc=pw+1;
	wb=wbuf;
	transfer(&wb,&pc,'\0');
	DLINK=TREND;
	pd=pc;
	TREND = pd+1;
	pd->nm = pc1;
	pd->ls = pd->cs = 0;
	if(pd->bf = alloc(BUFSIZ))
		{if(fcreat(wbuf,pd->bf)==ERROR)
			{fprintf(STDERR,
				"Can't create <%s>\n",
				wbuf);
			exit();
			}
		}
	else	{fprintf(STDERR,"Can't allocate buf for %s\n",
			wbuf);
		exit();
		}
	}
while(fgets2(LINE,IOBUF))
	{if((*LINE==COMMAND)&&(comtyp(LINE)==ED)) break;
	if(pc=macq(LINE))
		{pbstr(pc);
		continue;
		}
	/*else*/
	fputs(LINE,pd->bf);
	(pd->ls)++;
	(pd->cs) += 1+strlen(LINE);/*crlf=2*/
	}
}
/****************************************/
source()
{struct divfd *pd;
char name[MAXLINE];
getwrd(LINE,name);
if(getwrd(LINE,name)!=WE_HAVE_A_WORD)
	{fprintf(STDERR,".SO has no name\n");
	return;
	}
ucstr(name);
if(pd=find2(name,DLINK)) dclose(pd);
if(FPTR<FMAX) FSTACK[FPTR++]=IOBUF;
else	{fprintf(STDERR,"FSTACK overflow\n");
	exit();
	}
if(IOBUF=alloc(BUFSIZ))
	{if(fopen(name,IOBUF)!=ERROR) return;
	/*else*/
	fprintf(STDERR,"Can't open <%s>\n",name);
	}
else fprintf(STDERR,".SO can't buffer <%s>\n",name);
endso();
}
/****************************************/
showr()	/*lists register names and contents*/
{int *pw, *pr;
char *pc;
fprintf(STDERR,"REGISTERS and <values>:\n");
pw=RLINK;
while(pw)
	{pc=pw+1;
	fprintf(STDERR,"%s ",pc);
	pr=pc+1+strlen(pc);
	fprintf(STDERR,"<%d>\n",*pr);
	pw=*pw;
	}
dashes();
}
/****************************************/
showd()	/*shows all diversions and status*/
{int *pw;
char *pc;
struct divfd *pd;

fprintf(STDERR, "Diversion files:\n");
pw=DLINK;
while(pw)
	{pc=pw+1;
	fprintf(STDERR,"%s: ",pc);
	pd=pc+1+strlen(pc);
	fprintf(STDERR,"%d characters, %d lines [",
			pd->cs, pd->ls );
	if(pd->bf) fprintf(STDERR,"open]\n");
	else	fprintf(STDERR,"closed]\n");
	pw =*pw;
	}
dashes();
}
/****************************************/
dsclose()	/*flushes and closes all open diversions*/
{int *pw;
char *pc;
struct divfd *pd;

pw = DLINK;
while(pw)
	{pc=pw+1;
	pd=pc+1+strlen(pc);
	if(pd->bf) dclose(pd);
	pw=*pw;
	}
}
/****************************************/
dclose(pd)	/*flushes and closes diversion*/
struct divfd *pd;
{if(pd&&(!(pd->bf))) return(FALSE);
fprintf(STDERR,"closing %s ",pd->nm);
putc(CPMEOF,pd->bf);
fflush(pd->bf);
if(fclose(pd->bf)==ERROR)
	fprintf(STDERR,"****bad close****\n");
else	{fprintf(STDERR,"[O.K.]\n");
	free(pd->bf);
	pd->bf = FALSE;
	}
return(TRUE);
}
/****************************************/
ucstr(s)	/*convert s to upper case*/
char *s;
{while(*s)
	{*s = toupper(*s);
	s++;
	}
}
/****************************************/
endso()	/*called upon EOF to return to previous input file*/
{if(FPTR)
	{fclose(IOBUF);
	free(IOBUF);
	IOBUF=FSTACK[--FPTR];
	}
BINP=0;
}
/****************************************/
dashes()
{fprintf(STDERR,"-----------\n");
}
********************/