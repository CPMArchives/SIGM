/*  get_name - extract file name from line  */
get_name (line, file)
/*******************/
    char *line, *file;
    {
    char *delim;
    int n;
 
    while (*line == ' ' || *line == '\t')
        ++line;
    if (*line == '\n')
        n = 0;
    else
        {
        n = 0;
        if (*line == '"')
            {
            delim = "\"\n";
            ++line;
            }
        else if (*line == '<')
            {
            delim = ">\n";
            ++line;
            }
        else
            delim = " \t\n";
        n += cpy_buf (file+n, line, instr(line, delim));
        *(file+n) = eos;
        }
    return (n);
    }  /* get_name */
;
        line = skip (