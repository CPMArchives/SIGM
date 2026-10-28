 
/*  skip - output "n" blank lines  */
skip (n)
/******/
    int n;
    {
    int t;
 
    t = n;
    while (t-- > 0)
        fputs ("\n", dev_lst);
    return (n);
    }  /* skip */
 
#define margin1 0      /* top of page to title line */
#define margin2 2      /* title line to body */
#define margin3 8      /* body to bottom of page */
#define page_size 66
 
char *title;
int line_of_page;
int page;
 
/* paginate - separate stream of buffers into pages */
paginate (buf)
/************/
    char *buf;
    {
    if (page != 0)  /* M. A. Jacksons's program inversion */
        goto resume;   /* technique used */
    /* read */
    while (buf != NULL)   /* while not end of file */
        {
        ++page;
        fputs ("\f", dev_lst);
        line_of_page = skip (margin1);
        if (title != NULL)  /* output title and page nr. */
            {
            fprintf (dev_lst, "%-60spage %1d",
                              title, page);
            line_of_page += skip (margin2);
            }
        while (buf != NULL && line_of_page < page_size - margin3)
            {
            fputs (buf, dev_lst);
            ++line_of_page;
            /* read */
            return;
        resume: ;
            }
        line_of_page = 0;
        }
    page = 0;
    }  /* paginate */
