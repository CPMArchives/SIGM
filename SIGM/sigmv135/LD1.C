/*      MACHINE LANGUAGE PROGRAM LOADER

            Usage : ld file1 file2 .... filen

        This program will load the specified Intel .HEX
        files and write out object .COM files without
        worrying about the address fields in the .HEX
        files. All object is written to disk in the
        order the of the hex in the input file.

        Program was written to simplify program which
        have bits and pieces floating all over the
        place in RAM. All that is neccesary is to ORG
        the code to the correct address, and then have
        a routine to move it there in your program. What
        this effectively does is turns the ORG statement
        into a  command simmilar to the .PHASE of
        Microsofts MACRO-80. For example, take the
        following program :

          8080                             Z80

        ORG     0100H                   ORG     0100H
DEST:   EQU     08000H          DEST:   EQU     08000H
        LXI     H,ENDP+1                LD      HL,ENDP+1
        LXI     D,DEST                  LD      DE,DEST
        LXI     B,ENDR-START            LD      BC,ENDR-START
LOOP:   MOV     A,M             LOOP:   LD      A,(HL)
        XCHG                            EX      HL,DE
        MOV     M,A                     LD      (HL),A
        XCHG                            EX      HL,DE
        INX     H                       INC     HL
        INX     D                       INC     DE
        DCX     B                       DEC     BC
        MOV     A,B                     LD      A,B
        ORA     C                       OR      C
        JNZ     LOOP                    JMP     NZ,LOOP
        RET                             RET
ENDP:   DB      0               ENDP:   DB      0

          ;START OF MOVABLE PROGRAM
        ORG     DEST                    ORG     DEST
START:  .                       START:  .
         .                               .
          .                               .
           .                               .
            . . . . . . . . . . . . . . . . . . this can be anything
             .                               .
              .                               .
               .                               .
ENDR:   DB      0               ENR:    DB      0

        When assembled it will produce a .HEX file that
        looks like the following (I have expanded this
        to make it more meaningful) :

 N  ADDR    <------------CODE-------------->
:10 0100 00 2116011100800105007EEB77EB23130B 14
:06 0110 00 78B1C2090100 F4
:06 8000 00 010203040500 6B      <- program to execute
:00 0000 00 00

        When using the normal LOAD command, this would
        produce a .COM file such that when executed,
        each hex value above will load strting at the
        address in the ADDR field, padding the gap
        between 0116 -> 8000 with garbage. This is
        undesirable (for me anyway!!), as if I want
        to generate code to reside in high memory
        e.g. CP/M watch-dogs, I must make a
        relocator...a pest. This program will
        LD a file(s) ignoring the ADDR field, although
        it will warn you if the first ADDRess is not
        0100H. This allows the assembler to do all the
        hard work. Just remember that any labels in the
        part to move will have values reflecting the
        move recent ORG. This explains the couple of
        DB 0 statements above. Note that ENDR-START
        is the length of the code to be moved.


        Have fun with it, and tell me if it doesn't
        work. By the way, if you make some good
        patches or fixes to this, document it somewhere
        in this file (preferably above) and then add the
        new version to the VERSION CONTROL below. I have
        tried to make the program "quiet". Please try
        and keep it that way.

                        Thanks,  David Brown

VERSION CONTROL:  (most recent first)

Version     Description                      Author     Date
----------------------------------------------------------------
  1.0      Initial program written            Me !      06/11/82

----------------------------------------------------------------
*/
#include "bdscio.h"     /* Get all the good gear */
#define FLAG char
#define TPA (BASE+0x100)

main(argc, argv)        /* here we go... */
char **argv;
{
        if (argc==1)
                printf("Usage: ld file1 file2 ... filen");

        while (--argc)
                convert(*++argv);        /* process each file in
                                            order of command line */

}

convert(f)
char *f;
{
        char    infil[BUFSIZ], otfil[BUFSIZ];
        char    work[MAXLINE];
        int     iores, num, i;
        FLAG    assume, first, find();

        assume = !find('.',f);   /* find a '.' in f ?? */

        if ((iores=fopen(f,infil))==ERROR) {   /* try and open.. */
                printf("Cannot open : %s",f);
                if (assume) {                      /* if no type try it */
                        printf(", trying .HEX\n"); /*   with a .HEX added */
                        strcpy(work,f);
                        strcat(work,".HEX");
                        if ((iores=fopen(work,infil))==ERROR)
                             printf("Cannot open : %s, skipping..\n",work);
                } else printf(", skipping..\n");
        }
        if (iores != ERROR) {     /* if successfully opened go for it.. */
                if (!assume)      /* get rid of type */
                        f[find('.',f)-1] = '\0';
                strcpy(work,f);
                strcat(work,".COM");
                if (fcreat(work,otfil)==ERROR)
                        printf("Cannot create : %s, skipping..\n",work);
                else {
                        first = TRUE;
                        do {
                            skip(infil,1);
                            num = readhex(infil,2);
                            if (first) {
                              first = FALSE;
                              if (readhex(infil,4) != TPA)
                                  printf("Warning: %s, not at %^4x\n",f,TPA);
                              skip(infil,2);
                              }
                              else skip(infil,6);
                            for (i=1;i<=num;i++)
                                 putc(readhex(infil,2),otfil);
                            skip(infil,4);  /* skip check and CRLF */
                        } while (num != 0);
                        fflush(otfil);
                        fclose(otfil);
                }
                fclose(infil);
        }
}

FLAG find(c,s)
char c, *s;
{
        int pos;        /* position found c in s */

        pos = 1;
        while (*s != '\0')
                if (c == *s) return pos;
                else {
                        s++;
                        pos++;
                }
        return FALSE;
}

skip(f,n)       /* skip n characters from file f */
char *f;
{
        while (n--) getc(f);
}

readhex(f,n)    /* Reads n hex digits from file f. If a non-hex
                   digit is encounted '0' is assumed */
char *f;
{
        unsigned val;
        char c;

        val = 0;
        while(n--) {
                val *= 16;
                c=getc(f);
                if (isdigit(c))
                        val += (c - '0');
                else if (isupper(c) && c < 'G')
                        val += (c - 'A' + 10);
        }
        return val;
}
