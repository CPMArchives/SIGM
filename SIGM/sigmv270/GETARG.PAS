{ [GETARG.PAS of JUGCPM Vol.11]

      getarg(argc,argv);

      TURBO Pascal version
      by T. Nomura

      RESTRICTION: The length of argvs must be less than 31 chars in 
                   this TURBO version.
}

program GetArgTest(input,output);
const
     MAXARG = 10;     { max. number of argv[max] }
     ARGLEN = 20;     { max. length of argv[i] }
     NULL   =  0;     { terminator }
type
    arg = array[1..MAXARG] of string[ARGLEN];
    argl = string[255];
var i,len:integer;
    argc:integer;
    argv:arg;

procedure GetArgList(var arglist:argl);
var
   len,i:integer;
begin
     arglist[0] := chr(mem[$80]);
     len := mem[$80];
     for i := 1 to len do
         arglist[i] := chr(mem[$80+i]);
end;

procedure getarg(var argc:integer;var argv:arg);
var
   i,len:integer;
   argnum:integer;
   arglist:argl;
   first:boolean;
begin
     GetArgList(arglist);
     len := length(arglist);
     argnum := 1;
     for i := 1 to MAXARG do
         argv[i] := '';
     i := 1;
     first := true;

     { pass the spaces }
     while ( i <= len ) and ( arglist[i] = ' ') do
           i := i + 1;
     if i > len then
           argc := 1
     else
      begin
           while ( i <= len ) and (argnum <= MAXARG+1) do
            begin
                 if arglist[i] = ' ' then
                  begin
                       if first then
                        begin
                             argnum := argnum + 1;
                             first := false;
                        end
                  end
                 else
                  begin
                       argv[argnum] := argv[argnum] + arglist[i];
                       first := true;
                  end;
                 i := i + 1;
            end;
           if first then
              argc := argnum + 1
           else
               argc := argnum;
           if argnum > MAXARG+1 then
              writeln('Error : Argv overflow');
     end;
end;

{------------------------------------------------------------------------}
{ MAIN }
{ test program }
begin
     getarg(argc,argv);
     writeln('argc = ',argc);
     for i := 1 to argc-1 do
         writeln(argv[i]);
end.
