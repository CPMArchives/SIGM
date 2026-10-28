#include   <stdio.h>
#include   <cpm.h>


#define   ALPHALENG      10
#define   BLANK     "          "
#define   RLEVMAX 8

struct    item {char name[ALPHALENG];
                int  count;
                struct item *left;
                struct item *right; };
char      ch;
char      w[ALPHALENG];
int       eoln,eofmode;
struct    item *root;

main()
{
int  prinname(),princont();
     root=NULL;
     ch=' ';
     eofmode=NO;
     while(eofmode==NO) {
          if(('A'<=ch & ch<='Z') | ('a'<=ch & ch<='z')) {
               scanname();
               enter(&root);
          }
          else if(ch=='"') 
               scanstr();
          else if(ch=='\'')
               scanquo();
          else if(ch=='/') {
               nextch();
               if(ch=='*')
                    skipcom();
          }
          else
               nextch();
     }
     crlf();
     crlf();
     showtree(prinname);
     crlf();
     crlf();
     showtree(princont);
}
          
nextch()
{
int  prinname(),princont();
     if(eofmode==YES) {
          printf("?eof");
          crlf();
          crlf();
          showtree(prinname);
          crlf();
          crlf();
          showtree(princont);
          exit();
     }
     else
          if((ch=getchar())==EOF)
               eofmode=YES;
}

scanname()
{
int       wx;
          filchr(w,' ',ALPHALENG);
          wx=1;
          w[wx]=ch;
          nextch();
          while((('A'<=ch) & (ch<='Z'))
              | (('a'<=ch) & (ch<='z'))
              | (('0'<=ch) & (ch<='9'))) {
               wx+=1;
               if(wx<=ALPHALENG)
                    w[wx]=ch;
               nextch();
          }
}

scanstr()
{
          nextch();
          do {
               while('"'!=ch)
                    nextch();
               nextch();
          } while(ch=='"');
}
scanquo()
{
          nextch();
          if(ch=='\\')        /* '\?' */
               nextch();
          nextch(); nextch();
}

skipcom()
{
          nextch();
          do {
               while(ch!='*')
                    nextch();
               nextch();
          } while(ch!='/');
          nextch();
}

filchr(wd,chr,leng)
register char *wd;
register char chr;
int          leng;
{
int i;
     i=0;
     while((i++)<leng)
          *(wd++)=chr;
}

enter(pt)
struct item *(*pt);
{
int    *malloc();
struct item *ptr;
     ptr=(*pt);
     if(*pt==NULL) {
          *pt=ptr=malloc(ALPHALENG+12);
          strcpy(ptr->name,w);
          ptr->count=1;
          ptr->left=NULL;
          ptr->right=NULL;
     }
     else {
          if(strcmp(w,ptr->name)==0)
               ptr->count++;
          else if(strcmp(w,ptr->name)<0)
               enter(&(ptr->left));
          else                     /* strcmp(w,ptr->name)>0 */
               enter(&(ptr->right));
     }
}

showtree(qq)
int  (*qq) ();
{
int  printree ();
int  vline[RLEVMAX];
     printree(root,1,qq,vline);
}

printree(pt,rlev,prinnode,vline)
struct item    *pt;
int            rlev;
int            vline[];
int            (*prinnode) ();
{
struct item    *ptr;
     ptr=pt;
     (*prinnode) (ptr);
     if(ptr->left!=NULL)
          vline[rlev]=YES;
     else
          vline[rlev]=NO;
     if((ptr->right!=NULL) & (rlev<RLEVMAX-1)) {
          printf("--");
          printree(ptr->right,rlev+1,prinnode,vline);
     }
     else {
          if(ptr->right!=NULL)
               printf("+++++");
          crlf();
          printvl(rlev,vline);
          crlf();
     }
     if(ptr->left!=NULL) {
          printvl(rlev-1,vline);
          printree(ptr->left,rlev,prinnode,vline);
     }
}

printvl(r,vline)
int  r;
int  vline[];
{
register  int  i;
     for(i=1;i<=r;i++) {
          if(vline[i]==YES)
               printf("I            ");
          else
               printf("             ");
     }
}

prinname(p)
struct    item      *p;
{
register  int  i,j;
     strcpy(w,p->name);  /* Extract name */
     i=ALPHALENG;
     if(p->right!=NULL) {
          while(w[i]==' ') {
               w[i]='-';
               --i;
          }
     }
     printf("*%s",w);
}

princont(p)
struct    item      *p;
{
     printf("*< %d >",p->count);
     if(p->right!=NULL)
          printf("-----");
}

crlf()
{
     printf("\n");
}

    printf("*< %d >",p