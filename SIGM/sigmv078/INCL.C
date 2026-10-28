 
/*  include - include file  */
include (file, func)
/******************/
    char *file;
    int (*func)();
    {
    char *alloc();
    struct _buf *iobuf;
 
    iobuf = alloc (BUFSIZ);
    if (fopen (file, iobuf) == ERROR)
        diagnostic (FALSE, "can't open ", file, NULL);
    else
        {
        (*func)(file, iobuf);
        fclose (iobuf);
        }
    free (iobuf);
    }  /* include */

    int n;
    char file[20];
    int list()