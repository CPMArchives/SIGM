 
/*  instr - find first occurence in string of member of set  */
instr (p, s)
/**********/
    char *p, *s;
    {
    char *c;
 
    for ( ; *s; s++)
        for (c = p; *c; c++)
            if (*c == *s)
                goto out;
    out:
    return c - p;
    }  /* instr */
);
    }  /* cmp_buf_lc */
