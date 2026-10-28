 
/*  detab - replace tabs with blanks  */
detab (s, d)
/**********/
    char *s, *d;
    {
    int i;
 
    for (i = 0; *d = *s; ++s)
        if (*s == '\t')
            do
                *d++ = ' ';
            while (++i%8);
        else
            {
            ++i;
            ++d;
            }
    return (++i);
    }  /* detab */
