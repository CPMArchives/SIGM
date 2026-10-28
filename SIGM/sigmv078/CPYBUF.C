 
/* cpybuf - copy buffer "s" to "d" for "n" bytes */
cpy_buf (d, s, n)
/***************/
    char *d, *s;
    int n;
    {
    int i;
 
    for (i = n; i != 0; --i)
        *d++ = *s++;
    return (n);
    }  /* cpy_buf */
