#include <b:bdscio.h>
 
/*   clist - list 'c' source files   */
 
#define eos '\0'
#define std_err 4
#define dev_lst 2
 
int n_flag, h_flag;
 
#include "cpybuf.c"
 
#include "cmpbuflc.c"
 
#include "instr.c"
 
#include "diagn.c"
 
#include "pagin8.c"
 
#include "incl.c"
 
#include "filenm.c"
 
#include "detab.c"
 
/*  check include - do possible include processing  */
check_include (line)
/******************/
    char *line;
    {
    int n;
    char file[20];
    int list();
    int abort;
 
    for ( ; isspace(*line) ; ++line);  /* skip leading spaces */
    if (cmpbuflc (line, "#include ", 9))
        {
        n = get_name (line+9, file);
        if (n == 0 || n > 20)
            {
            if (n > 20)
                abort = TRUE;
            else
                abort = FALSE;
            diagnostic (abort, "error in file name ",
                        file, NULL);
            }
        else
            {
            if (cmpbuflc (&file[n-2], ".h", 2))  /* header file */
                {
                if (h_flag)
                    include (file, &list);
                }
            else
                if (n_flag)  /* non-header file */
                    include (file, &list);
            }
        }
    }  /* check_include */
 
/*  list - label and print lines of "file"  */
list (file, iobuf)
/*********/
    char *file;
    struct _buf *iobuf;
    {
    char *fgets();
    char *buf, *line;
    int line_number;
    char *alloc();
 
    buf = alloc (170);
    line = alloc (150);
    line_number = 0;
    strcpy (buf, file);
    while (strlen(buf) < 17)
        strcat (buf, " ");
    while (fgets (line, iobuf))
        {
        sprintf (&buf[14], "%3d", ++line_number);
        strcat (buf, ": ");
        detab (line, buf+19);
        paginate (buf);
        if (n_flag || h_flag)
            check_include (line);
        }  /* while */
    free (buf);
    free (line);
    } /* list */
 
 
main (argc, argv)
/***************/
    int argc;
    char **argv;
    {
    _allocp = NULL;
    n_flag = TRUE;
    h_flag = FALSE;
    page = 0;
    if (argc <= 1)
        diagnostic (TRUE, 
        "Usage A>clist file1 file2 ... filen <cr>\n", NULL);
    --argc;
    ++argv;
    do {
       title = *argv;
       include (title, &list);
       paginate (NULL);
       }
    while (++argv, --argc);
    }
***/
    char *line;
    {
    int n;
    char file[20];
    int list()