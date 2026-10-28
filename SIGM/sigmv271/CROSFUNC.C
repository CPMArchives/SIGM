 /* C-function cross reference generator 85-08-31 Ver 2.12*/

#include <stdio.h>
#include <ctype.h>
#include <cpm.h>

#define VERSION	   "Ver 2.12 85-08-31"
#define ERROR      1
#define READ       "r"
#define WRITE      "w"
#define EOF	   (-1)

#define TSIZE      10000
#define OSIZE      2000
#define FSIZE	   2000
#define NSIZE      500
#define CHARMAX    256

#define NEWLINE    '\n'
#define CR	   '\r'
#define SPACE      0x20
#define OTHERS     0
#define TOKENSTART 1
#define TOKENCONTINUE 2

#define CR_MAP1	   1
#define CR_FUNC	   2

#define getchar fgetc

struct occ {
	int         line;		/* appearance line	 	*/
	struct occ  *next;		/* next occ addr pointer 	*/
	};

struct node {
	char        	*cont;		/* ptr to name table	 	*/
	int         	defline;	/* function definition line	*/
	struct funcdef	*funcp;		/* ptr to funcdef		*/
	int		nextdef;	/* next definition function no	*/
	struct occ  	*occp;		/* ptr to occ  table	 	*/
	struct node *left, *right;	/* ptr to next node		*/
	};

struct funcdef {
	struct node	*nodep;		/* ptr to node			*/
	struct funcdef	*nextp;		/* ptr to next funcdef		*/
	};

struct occ 	oheap[OSIZE];
struct node 	nheap[NSIZE] = 	   {NULL};
char 		chtable[CHARMAX] = {NULL};
struct node 	*keyword = NULL;
FILE 		*fp1,*fp2;

int 	firstfp  = 0;			/* index to first *fheap	*/
struct  node     *deffunc = {NULL};	/* ptr to function name(node)	*/
int 	brace    = 0;
int tp = NULL, tpnew = NULL, op = NULL, np = NULL, printcol = NULL;
int fp = NULL;

int	page     = 0;
int	line	 = 60;
char	*headp	 = {NULL};
char	*secondp = {NULL};
char	*ttl[10] = {
     "Function Cross Reference Map (Alphabetic Order & Line-no)",
     "  Funcname            def       ref",
     "Function Cross Reference Map (Referance Function Map)"
		   };

int  	hlength  = 10;
int 	tblp     = 0;
char 	chtbl[512];
int 	ln;

main(argc,argv)

int argc;
char *argv[];
{
	char tsave[TSIZE];
	FILE	*fopen();
	struct node *insertfile();
	struct node *root;
	int i, c;
	char *s;
	int truefunc(), keycheck();

	chtbl[0]=NULL;
     strcat(chtbl,"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_\n");
     strcat(chtbl,"0123456789\n");
     strcat(chtbl,"int char struct union unsigned auto extern register ");
     strcat(chtbl,"short long ");
     strcat(chtbl,"typedef static goto sizeof break continue return ");
     strcat(chtbl,"if else for do while switch case default entry ");
     strcat(chtbl,"define ifdef ifndef undef include line ");
	if (argc<2 || argc >4) {
		printf("usage : A>crosfunc objectfile [x_r_file] [-s -l]\n");
		exit();
	}
	if( argc == 3 && *argv[2]=='-') {
		if (*(argv[2]+1)=='s')
			hlength=10;
		if (*(argv[2]+1)=='l')
			hlength=20;
		--argc;
	}
	if( argc == 4 && *argv[3]=='-') {
		if (*(argv[3]+1)=='s')
			hlength=10;
		if (*(argv[3]+1)=='l')
			hlength=20;
		--argc;
	}
	for (i=0; i<CHARMAX; i++)
		chtable[i] = OTHERS;
	if (argc == 2)
		fp1=(EOF);
	else {
		s = argv[2];
		if  ((fp1=fopen(s,READ)) == ERROR) {
			printf("Can 't open %s\n",s);
			exit();
		}
	}
	while ((c = getsym(fp1)) != NEWLINE && c != CR) {
		if (c == EOF) {
			printf("unexpected eof\n");
			exit();
		}
 		chtable[c] = TOKENSTART;
	}
	while ((c = getsym(fp1)) != NEWLINE && c != CR) {
		if (c == EOF) {
			printf("unexpected eof\n");
			exit();
		}
		chtable[c] = TOKENCONTINUE;
	}
	
	tp = 0;
	op = 0;
	np = 0;
	keyword = insertfile(fp1, truefunc,tsave,FALSE);
	if(fp1!=EOF) close(fp1);
	if ( (fp2=fopen(argv[1],READ)) == ERROR) {
		printf("Can 't open %s\n",argv[1]);
		exit();
	}
	op = 0;ln=0;/* line pointer reset */
	root = insertfile(fp2, keycheck,tsave,TRUE);
	close(fp2);
	headp  = ttl[0];	/* set headinf title */
	secondp= ttl[1];
	print(root,CR_MAP1);
	headp  = ttl[2];
	secondp= ttl[1];
	line=60;
	print(root,CR_FUNC);
        printf("\n");
}



struct node *insertfile(ibuf,cfunc,tsave,mode)
FILE *ibuf;
int (*cfunc)();
char tsave[];
int  mode;
{
struct node *insert();
register int c;
struct node *tree;

	tree = 0;
	ln = 1;
	c = getsym(ibuf);
	while (c != EOF){
		if (chtable[c] != TOKENSTART) {
			if(c=='"')
				c=scanstr(ibuf);
			else if(c=='\'')
				c=scanquo(ibuf);
			else if(c=='/') { 
				if((c=getsym(ibuf))==EOF)
					break;
				else if(c=='*')
					c=skipcom(ibuf);
			}
			else if(c=='{') {
				++brace;
				c = getsym(ibuf);
			}
			else if(c=='}') {
				--brace;
				c = getsym(ibuf);
			}
			else
				c = getsym(ibuf);
		}
		else {
			tpnew = tp;
			while (c != EOF && chtable[c] != OTHERS) {
				if (tpnew > TSIZE - 1) {
					printf("text buffer overflow\n");
					exit();
				}
				tsave[tpnew++] = c;
				c = getsym(ibuf);
			}
			tsave[tpnew++] = NULL;
			if(mode==TRUE)
				c=skipbk(ibuf,c);
			if((mode==FALSE) | (c=='(')) {
				if ((*cfunc)(&tsave[tp])) {
					if (op > OSIZE) {
						printf("occ table overflow\n");
						exit();
					}
					oheap[op].line    = ln;
					tree = insert(&tsave[tp],tree);
					op++;
				}
			}
		}
	}
	return(tree);
}

skipbk(ibuf,c)
register int c;
FILE     *ibuf;
{          
	while(c==SPACE)
		c=getsym(ibuf);
	return(c);
}

struct node *insert(w, p)
char *w;
struct node *p;
{
struct node *q;
	if (p == NULL) {  /* first appearance */
		if (np >= NSIZE) {
			printf("node table overflow\n");
			exit();
		}
		q = &nheap[np];
		np++;
		q->left  = NULL;
		q->right = NULL;
		q->cont  = w;
		q->funcp = NULL;
		if(brace>0) {/* inner function */
			q->defline = NULL;
			setfunc(q);
		}
		else {
			q->defline = ln;
			deffunc = q;
		}
		tp = tpnew ;
		q->occp = &oheap[op];
		oheap[op].next = NULL;
		return(q);
	}
	else {
		switch (compare(w, p->cont)) {
			case -1 : p->left = insert(w, p->left);
				  break;
			case  0 : oheap[op].next = p->occp;
				  p->occp = &oheap[op];
				  if(brace==0) {
					p->defline = ln;
					deffunc    = p;
				  }
			          else {  /* inner function */
					setfunc(p);
				  }
				  break;
			case  1 : p->right = insert(w, p->right);
				  break;
		}
		return(p);
	}
}

setfunc(p)
struct node *p;
{
struct funcdef *q,*malloc();
	if(deffunc->funcp==NULL) { /* First allocation */
		q = deffunc->funcp = malloc(sizeof(q));
		q->nextp=NULL;
		q->nodep=p;
	}
	else {
		q = deffunc->funcp;
		while(q->nextp!=NULL) {
			q = q->nextp;
		}
		q->nextp  = malloc(sizeof(q));
		q	  = q->nextp;	/*new sell */
		q->nextp  = NULL;
		q->nodep  = p;
	}
}

truefunc()
{ return(1); }


keycheck(w)
char *w;
{ return(search(w, keyword)); }


search(w, tree)
char *w;
struct node *tree;
{
	if (tree == NULL)
		return(1);
	else
		switch (compare(w, tree->cont)) {
			case -1 : return(search(w, tree->left));
			case  0 : return (0);
			case  1 : return(search(w, tree->right));
		}
}


print(p,mode)
struct node *p;
int         mode;
{
	if (p != NULL) {
		print(p->left,mode);
		newline(1);
		printf("%-20s",p->cont);
		printcol = 0;
		if(p->defline!=NULL)
			printf("%6d%1s",p->defline," ");
		else
			printf("%7s"," ***** ");
		switch(mode) {
			case CR_MAP1 : printl(p->occp);
				       break;
			case CR_FUNC : prinfunc(p->funcp);
				       break;
		}
		print(p->right,mode);
	}
}


printl(o)	/* Print Crossreference list by line no */
struct occ *o;
{
	if (o != NULL) {
		printl(o->next);
		if (printcol >= hlength) {
			newline(1);
			printf("%27s"," ");
			printcol = 0;
		}
		printf("%5d",o->line);
		printcol++;
	}
}

prinfunc(f)	/* Print Crossreference list by function name */
struct funcdef *f;
{
	if (f != NULL) {
		if (printcol > hlength) {
			newline(1);
			printf("%27s"," ");
			printcol = 0;
		}
		printf("%-15s",f->nodep->cont);
		printcol+=4;
		prinfunc(f->nextp);
	}
}
newline(count)
int count;
{
int i;
	if(line>=60) {
		page++;
		printf("\n\f");
		printf("%50s  %17s  %5s %4d",headp,VERSION," PAGE",page);
		printf("\n%-79s\n\n",secondp);
		line=2;
	}
	else if (count>0)
		for(i=1;i<=count;i++) {
			line++;
			printf("\n");
		}
}

compare(a, b)
char *a, *b;
{
	while (*a == *b) {
		if (*a == NULL)
			return(0);
		a++;
		b++;
	}
	if (*a<*b)
		return(-1);
	else
		return(1);
}
getsym(fp)
FILE *fp;

{
register int c;
	if(fp==(EOF))
		c=chtbl[tblp++];
	else {
		c=getchar(fp);
		if(c == NEWLINE) {
			ln++;
			c=getsym(fp);
		}
	}
	return(c);
}

scanstr(fp)
FILE *fp;
{
register int	c;
	if((c=getsym(fp))==EOF)
		return(EOF);
        do {
        	while('"'!=c)
			if((c=getsym(fp))==EOF)
				return(EOF);
		if((c=getsym(fp))==EOF)
			return(EOF);
          } while(c=='"');
	return c;
}

scanquo(fp)
FILE *fp;
{
register int	c;
	if((c=getsym(fp))==EOF)
		return(EOF);
	for(;;) {
		while((c!='\'')&&(c!='\\'))
			if((c=getsym(fp))==EOF)
				return(EOF);
		if(c=='\\') {
			c=getsym(fp);
			if(c==EOF)
				return(EOF);
			else
				if(c=='\'')
				if((c==getsym(fp))==EOF)
					return(EOF);
				else
					break;
		}
		else
			break;
	}
	/* c=='\'' */
	if((c=getsym(fp))==EOF)
		return(EOF);
	return c;
}

skipcom(fp)
FILE *fp;
{
register int	c;
	if((c=getsym(fp))==EOF)
		return(EOF);
        do {
                while(c!='*')
			if((c=getsym(fp))==EOF)
				return(EOF);
		if((c=getsym(fp))==EOF)
			return(EOF);
           } while(c!='/');
	return(getsym(fp));
}
p))==EOF)
				return(EOF);
		if((c=getsym(fp))==EOF)
			return(EOF);
           } while(c!='/');
	return(getsym(