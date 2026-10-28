 
/*  cmpbuflc - compare two buffers of length "n" changing
               any alphas to lower case for comparison  */
cmpbuflc (s1, s2, n)
/******************/
    char *s1, *s2;
    int n;
    {
    for ( ; n != 0; --n, ++s1, ++s2)
        if (tolower(*s1) != tolower(*s2))
            return (FALSE);
    return (TRUE);
    }  /* cmp_buf_lc */
