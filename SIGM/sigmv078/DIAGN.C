 
/*  disgnostic - output error message  */
diagnostic (fatal, arg1, arg2, arg3, arg4, arg5, arg6)
/**********************/
    int fatal;
    char *arg1, *arg2, *arg3, *arg4, *arg5, *arg6;
    {
    if (arg1 != NULL) 
        {fputs (arg1, std_err);
         if (arg2 != NULL)
             {fputs (arg2, std_err);
              if (arg3 != NULL)
                  {fputs (arg3 ,std_err);
                   if (arg4 != NULL)
                       {fputs (arg4, std_err);
                        if (arg5 != NULL)
                            {fputs (arg5, std_err);
                             if (arg6 != NULL)
                                 fputs (arg6, std_err);
        }    }    }    }    }
    fputs ("\n", std_err);
    if (fatal)
        exit();
    }  /* diagnostic */
ge;
        fputs ("-\t-\t-\t-\t-\t-\t-\t-\t-\t-", 