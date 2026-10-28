PROGRAM animals;    {Requires Pascal/Z 3.3 or later, CP/M 2.2 or later}
                    {$E+}
CONST
    filepfx  = 'BEASTS';
    inviter  = 'Would you like to play the animal guessing game';
    insulted = 'Well, exCUUUUSE ME!!  So you don''t want to play, huh?';
    start1   = 'You think of an animal, and I''ll try to guess what it is.';
    start2   = 'When you''re ready to begin, press the <RETURN> key.';
    askagain = 'Would you like to play another round';
    maxlen   = 240;
    bufsize  = 256;
    maxx     = 256;                     {No. entries per XFILE block  }

TYPE
    x$shorti = 0..255;                  {One-byte integer             }
    questx   = 0..maxlen;               {Index to a question text     }
    bufx     = 1..bufsize;              {Index to a QFILE buffer      }
    dirx     = 1..maxx;                 {Index to an XFILE block      }
    recty    = (quest,ctl);
    qstring  = string maxlen;
    question = RECORD;                  {QUESTION logical record      }
        ident    : integer;             {Record number (1..MAXINT)    }
        typcode  : recty;               {Record type                  }
        CASE recty OF
            quest: (nextyes : integer;  {Next Q if answer = yes       }
                    nextno  : integer;  {Next Q if answer = no        }
                    query   : qstring); {Current question             }
            ctl  : (lastq   : integer;  {Last recno in QFILE          }
                    lastqbl : integer;  {Last QFILE block used        }
                    lastxbl : integer;  {Last XFILE block used        }
                    beastct : integer)  {No. animals known            }
        END; {question record}

    buffer   = PACKED ARRAY [bufx] OF x$shorti;
    qrec     = RECORD;
        qentry   : buffer
        END; {qrec record}
    queryfile= file of qrec;

    xbuffr   = ARRAY [dirx] OF integer;
    xrec     = RECORD;
        xentry   : xbuffr
        END; {xrec record}
    directory= FILE OF xrec;

    filestring = string 14;
    $string0   = string 0;
    $string255 = string 255;
    charset    = SET OF CHAR;
{$L+}
VAR
    db       : text;        {Debugging output file                    }
    dbugging : boolean;     {Is debugging active?                     }
    moreokay : boolean;     {Indicator - keep playing?                }
    runabort : boolean;     {Indicator - fatal error has occurred     }
    zerochr  : char;        {One byte of binary zero                  }
    vowels   : charset;     {Set of all vowels                        }
    shiftup  : integer;     {Factor to shift from lower to upper case }
    replytxt : qstring;     {Text of a console reply                  }
    maxquery : integer;     {Maximum question number in file          }
    highblok : integer;     {Relative block# of last QFILE block      }
    highxblk : integer;     {Relative block# of last XFILE block      }
    maxanimals : integer;   {No. animals file now knows               }
    currblok   : integer;   {Relative block# - current QFILE block    }
    currxblk   : integer;   {Relative block# - current XFILE block    }
    qimage     : qrec;      {Current qfile block image                }
    ximage     : xrec;      {Current xfile block image                }
    currec     : question;  {Current question file record             }
    i          : integer;

    qfile      : queryfile; {Questions file                           }
    xfile      : directory; {Directory to Questions file              }

{ - - - - - VIDEO TERMINAL CONTROL SEQUENCES - - - - - - - - - - - - -}
    return    : CHAR;       {Return cursor to left edge of screen     }
    bell      : CHAR;       {Ring bell (or alarm, if you prefer)      }
    clear     : STRING 4;   {Clear screen                             }
    reverse   : STRING 4;   {Shift to black-on-white display mode     }
    invert    : STRING 4;   {Shift to white-on-black display mode     }
    blink     : STRING 4;   {Start blinking-text area                 }
    unblink   : STRING 4;   {End blinking-text area                   }
    lndelete  : STRING 4;   {Delete current line                      }


FUNCTION  length    (x: $string255):    integer;    EXTERNAL;
FUNCTION  index     (x, y: $string255): integer;    EXTERNAL;
PROCEDURE setlength (VAR x: $string0;  y: integer); EXTERNAL;
{$L+}
PROCEDURE setupvdt;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{* Initialize video terminal control sequences                       *}
{* (This implementation is for Televideo 920C terminal)              *}
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

VAR
    esc : CHAR;

BEGIN {setupvdt procedure}
    esc     := CHR(27);
    return  := CHR(13);
    bell    := CHR(7);

    clear   := esc;
    append(clear,'*');

    reverse := esc;
    append(reverse,'j');

    invert  := esc;
    append(invert,'k');

    blink   := esc;
    append(blink,'^');

    unblink := esc;
    append(unblink,'_');

    lndelete := esc;
    append(lndelete,'R')
END; {setupvdt procedure} {$L+}
FUNCTION cnvrt (VAR arr: buffer;  pnt: bufx): integer;            {$C-}

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{* Given buffer ARR, with PNT pointing to the leftmost of a pair of  *}
{* entries in ARR, return the integer value of the two-byte pair     *}
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

CONST
    maxint = 32767;

VAR
    i : integer;

BEGIN {cnvrt function}
    IF arr[pnt]>127
      THEN
        BEGIN
          i := (256*(arr[pnt] MOD 128)) + arr[pnt+1];
          cnvrt := i - maxint - 1
        END
      ELSE cnvrt := (256*arr[pnt]) + arr[pnt+1]
END; {cnvrt function}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}

PROCEDURE revert (VAR buff: buffer;  ptr: bufx;  x: integer);
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{* Given an integer X, store it as two bytes as location PTR in      *}
{* buffer BUFF.  This procedure complements function CNVRT.          *}
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

BEGIN {revert}
    buff[ptr]   := x DIV 256;
    buff[ptr+1] := x MOD 256
END; {revert procedure} {$L+}
PROCEDURE error (errnumbr: integer);

CONST
    set1 = 'I''ve just been told that error number ';
    set2 = ' (whatever THAT means) has occurred.';
    set3 = 'Ain''t that the pits?!!';
    intro    = 'FATAL PROGRAM OR FILE ERROR.  DESCRIPTION:';
    err1     = 'Invalid record number passed to GETRECORD procedure.';
    err2     = 'Invalid block pointer found in .QQX file.';
    err3     = 'Invalid block number passed to BLOKFETCH procedure.';
    err4     = 'APPENDSEG1 procedure invoked for a too-full block.';
    err5     = '.QQQ record not found where .QQX file says it should be.';
    unknown  = '(Undefined error code)';

VAR
    message  : string 75;

BEGIN {error procedure}
    writeln;
    writeln(set1, errnumbr:2, set2);
    writeln(set3);
    writeln;
    writeln(intro);
    IF errnumbr=1
            THEN message := err1
    ELSE IF errnumbr=2
            THEN message := err2
    ELSE IF errnumbr=3
            THEN message := err3
    ELSE IF errnumbr=4
            THEN message := err4
    ELSE IF errnumbr=5
            THEN message := err5
            ELSE message := unknown;
    writeln('    ',message);
    writeln;
    runabort := true
END; {error procedure} {$L+}
FUNCTION getyes: boolean;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{* Secure from the console a reply of yes (y) or no (n).             *}
{* Return "true" if yes, "false" otherwise.                          *}
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

LABEL 1;

CONST
    suffix = '? (Y/N)  ';
    prompt = '     Please reply yes (Y) or no (N):  ';
    yes    = 'YES';
    no     = 'NO';

VAR
    reply    : string 10;
    ans      : char;
    gotreply : boolean;
    messy    : BOOLEAN;

PROCEDURE keyin (VAR c:char); EXTERNAL;

BEGIN {getyes function}
    write(suffix,invert);
    gotreply := false;
    messy    := FALSE;
    WHILE gotreply=false DO
      BEGIN {while}
        keyin(ans);
        IF ord(ans)=3       {Check for Control-C}
          THEN GOTO 1;
        CASE ans OF
            'Y', 'y': BEGIN {YES processor}
                        IF messy
                          THEN WRITE(return,lndelete);
                        WRITELN(yes);
                        gotreply := TRUE;
                        getyes := true
                      END;  {YES processor}
            'N', 'n': BEGIN {NO processor}
                        IF messy
                          THEN WRITE(return,lndelete);
                        WRITELN(no);
                        gotreply := TRUE;
                        getyes := false
                      END {NO processor}
          END; {case}
        IF NOT gotreply
          THEN
            BEGIN
              IF messy
                THEN WRITE(return,lndelete,prompt);
              WRITELN(bell,ans);
              WRITE(blink,prompt,unblink);
              messy := TRUE
            END {then}
      END; {while}
1:  {Exit here on Control-C }
END;  {getyes function} {$L+}
PROCEDURE shiftxt (VAR arr: buffer;
                       org: bufx;
                       len: bufx;
                   VAR trg: qstring); {$C-}
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{* Append a sequence of characters from ARR to TRG.  Transcription   *}
{* is of LEN consecutive bytes, beginning with byte ORG of ARR.      *}
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

VAR
    i, j : integer;

BEGIN {shiftxt procedure}
    i := 1;
    j := org;
    WHILE i<=len DO
        BEGIN {while}
            append(trg,CHR(arr[j]));
            i := i + 1;
            j := j + 1
        END {while}
END; {shiftxt procedure} {$L+}
FUNCTION dirfetch (recno: integer): dirx;
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{* Given RECNO (logical record number of a desired QFILE record),    *}
{* return the XIMAGE.XENTRY entry number for that record.            *}
{*                                                                   *}
{* Side effects:                                                     *}
{*      highxblk - may be incremented +1                             *}
{*      currxblk - set to relative block# of current index block     *}
{*      ximage   - will contain the current index block              *}
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

VAR
    xblkno   : integer;
    i        : dirx;

BEGIN {dirfetch function}
    xblkno := (recno DIV maxx) + 1;
    IF xblkno=(highxblk+1)
        THEN BEGIN
                currxblk := highxblk + 1;
                FOR i := 1 TO maxx DO
                    ximage.xentry[i] := 0;
                WRITE(xfile:currxblk,ximage);
                highxblk := currxblk
            END; {then}
    IF xblkno>highxblk
        THEN BEGIN
                error(2);
                xblkno := -1
            END {then}
        ELSE BEGIN
                IF xblkno<>currxblk
                    THEN READ(xfile:xblkno,ximage);
                currxblk := xblkno
            END; {else}
    dirfetch := (recno MOD maxx) + 1
END; {dirfetch function} {$L+}
PROCEDURE blokfetch (blokno: integer;
                 VAR buff  : qrec);
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{* Fetch a specified relative QFILE block into a given buffer        *}
{*                                                                   *}
{* Side effects:                                                     *}
{*      highblok - may be incremented +1                             *}
{*      currblok - set to block# of current qfile block              *}
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

VAR
    i : bufx;

BEGIN {blokfetch procedure}
    IF blokno=(highblok+1)
        THEN BEGIN
                currblok := blokno;
                FOR i := 1 TO bufsize DO
                    buff.qentry[i] := 0;
                WRITE(qfile:currblok,buff);
                highblok := currblok
            END; {then}
    IF (blokno<1) OR (blokno>highblok)
        THEN error(3)
        ELSE BEGIN
                IF blokno<>currblok
                    THEN READ(qfile:blokno,buff);
                currblok := blokno
            END {else}
END; {blokfetch procedure} {$L+}
FUNCTION findrec (recno: integer;  buff : buffer):  bufx;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{* Return a pointer to the starting byte of a requested record       *}
{* number in a given buffer.                                         *}
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

VAR
    i        : integer;
    found    : boolean;

BEGIN {findrec function}
    found := false;
    i := 1;
    WHILE ((i<(bufsize-3)) AND (buff[i]<>0) AND (NOT found)) DO
        BEGIN {while}
            IF cnvrt(buff,i+2)=recno
                THEN found := true
                ELSE i := i + buff[i]
         END; {while}
    IF NOT found
        THEN error(5);
    findrec := i
END; {findrec function} {$L+}
FUNCTION buildctl (VAR buff: qrec): question;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{* Given BUFF, with control record image, return the equivalent      *}
{* control record.                                                   *}
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

VAR
    equivalent : question;

BEGIN {buildctl function}
    WITH buff, equivalent DO
        BEGIN {with}
            lastq   := cnvrt(qentry,6);
            lastqbl := cnvrt(qentry,8);
            lastxbl := cnvrt(qentry,10);
            beastct := cnvrt(qentry,12)
        END; {with}
    buildctl := equivalent
END; {buildctl function} {$L+}
FUNCTION getrecord (recno  : integer): question;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{* Return from QFILE the RECNO record.                               *}
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

VAR
    ptr      : bufx;
    xptr     : dirx;
    questn   : question;
{$L+}
FUNCTION buildquest (VAR buff: qrec;  pnt: bufx):  question;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{* Return the question-record that begins at position PNT of BUFF    *}
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

VAR
    blokno     : integer;
    equivalent : question;

BEGIN {buildquest function}
    WITH equivalent, buff DO
        BEGIN {with}
            ident   := cnvrt(qentry,pnt+2);
            typcode := quest;
            nextyes := cnvrt(qentry,pnt+5);
            nextno  := cnvrt(qentry,pnt+7);
            setlength(query,0);
            shiftxt(qentry,pnt+9,qentry[pnt]-9,query);
            IF qentry[pnt+1]<>1
                THEN BEGIN
                        blokno := currblok + 1;
                        blokfetch(blokno,buff);
                        IF NOT runabort
                            THEN pnt := findrec(recno,qentry);
                        IF NOT runabort
                            THEN shiftxt(qentry,pnt+4,qentry[pnt]-4,query)
                    END {then}
        END; {with}
    buildquest := equivalent
END; {buildquest function} {$L+}
BEGIN {getrecord function}
    IF ((recno<0) OR (recno>maxquery))
        THEN BEGIN
                WRITELN('INVALID RECORD NUMBER ',recno:1);
                error(1)
            END {then}
        ELSE WITH qimage, questn DO
                BEGIN {with}
                    xptr := dirfetch(recno);
                    IF NOT runabort
                       THEN blokfetch(ximage.xentry[xptr],qimage);
                    IF NOT runabort
                        THEN ptr := findrec(recno,qentry);
                    IF NOT runabort
                        THEN BEGIN
                                ident := recno;
                                IF qentry[ptr+4]=ord(quest)
                                    THEN typcode := quest
                                    ELSE typcode := ctl;
                                CASE typcode OF
                                    quest: questn := buildquest(qimage,ptr);
                                    ctl  : questn := buildctl(qimage)
                                END {case}
                            END {then}
                END; {with and else}
    IF NOT runabort
        THEN getrecord := questn
END; {getrecord function} {$L+}
PROCEDURE reshift (VAR buff    : buffer;
                       tbyte   : bufx;
                       source  : qstring;
                       sbyte   : questx;
                       len     : questx);
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{* Copy to BUFF, starting at TBYTE, LEN consecutive characters of    *}
{* SOURCE, starting at byte SBYTE.  Pad BUFF with ZEROCHR.           *}
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

VAR
    sptr     : questx;
    tptr     : integer;

BEGIN {reshift procedure}
    tptr := tbyte;
    FOR sptr := sbyte TO (sbyte+len-1) DO
      BEGIN {for}
        buff[tptr] := ORD(source[sptr]);
        tptr := tptr + 1
      END; {for}
    WHILE tptr<=bufsize DO
      BEGIN
        buff[tptr] := 0;
        tptr := tptr + 1
      END
END; {reshift procedure} {$L+}
PROCEDURE appendseg1 (txt      : qstring;
                      nyes, nno: integer;
                  VAR buff     : qrec;
                      ptr      : bufx);
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{* In BUFF at point PTR, build segment 1 of the logical record       *}
{* expressed by TXT, NYES, NNO.                                      *}
{*                                                                   *}
{* Side effects:                                                     *}
{*      maxquery - becomes the new record's record-ID.               *}
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

LABEL 1;

TYPE
    switcher = 0..1;

VAR
    avl      : bufx;
    need     : integer;
    shiftlen : integer;
    seglength: integer;
    lastind  : switcher;

BEGIN {appendseg1 procedure}
    need := length(txt) + 9;
    avl  := bufsize - ptr + 1;
    IF avl<9
        THEN BEGIN
                error(4);
                GOTO 1
            END;
    WITH buff DO
        BEGIN {with}
            IF avl<need
                THEN seglength := avl
                ELSE seglength := need;
            IF seglength=need
                THEN lastind := 1
                ELSE lastind := 0;
            qentry[ptr]   := seglength;
            qentry[ptr+1] := lastind;
            revert(qentry,ptr+2,maxquery+1);
            qentry[ptr+4] := ord(quest);
            revert(qentry,ptr+5,nyes);
            revert(qentry,ptr+7,nno);
            IF avl<need
                THEN shiftlen := length(txt) - (need-avl)
                ELSE shiftlen := length(txt);
            reshift(qentry,ptr+9,txt,1,shiftlen)
        END; {with}
1:
END; {appendseg1 procedure} {$L+}
PROCEDURE addrecord (txt : qstring;
                     nyes, nno: integer);
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{* Given the three data elements of a question record, append that   *}
{* record to the question file.                                      *}
{*                                                                   *}
{* Side effects (updated as required):                               *}
{*      xfile                                                        *}
{*      highblok, highxblk, maxquery, maxanimals                     *}
{*      qfile file control record                                    *}
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

LABEL 1;

VAR
    newaddr  : integer;
    xptr     : dirx;
{$L+}
FUNCTION appendrec (txt  : qstring;
                     nyes, nno: integer): integer;
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{* Given the three data elements of a question record, append the    *}
{* record to QFILE, assigning it record number MAXQUERY+1.  Return   *}
{* block address.                                                    *}
{*                                                                   *}
{* Side effects:                                                     *}
{*      maxquery - used but not changed.                             *}
{*      highblok - may be incremented +1.                            *}
{*      currblok - equal to new highblok.                            *}
{*      qimage   - contains image of new highblok.                   *}
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

LABEL 1;

VAR
    objblok  : integer;
    i        : bufx;
    available: integer;
    required : bufx;
{$L+}
BEGIN {appendrec function}
    WITH qimage DO
        BEGIN {with}
            required := length(txt) + 9;
            available:= 0;
            objblok  := highblok - 1;
            WHILE available<9 DO
                BEGIN {while}
                    objblok   := objblok + 1;
                    blokfetch(objblok,qimage);
                    IF runabort
                        THEN GOTO 1;
                    i := 1;
                    WHILE ((i<bufsize) AND (qentry[i]<>0)) DO
                        i := i + qentry[i];
                    available := bufsize - i + 1
                END; {while}
            appendseg1(txt,nyes,nno,qimage,i);
            IF runabort
                THEN GOTO 1;
            appendrec := objblok;
            write(qfile:objblok,qimage);
            IF qentry[i+1]<>1
                THEN BEGIN
                        objblok := objblok + 1;
                        blokfetch(objblok,qimage);
                        IF runabort
                            THEN GOTO 1;
                        qentry[1] := required-available+4;
                        qentry[2] := 1;
                        revert(qentry,3,maxquery+1);
                        reshift(qentry,5,txt,available-8,required-available);
                        write(qfile:objblok,qimage)
                    END; {then}
1:      END {with}
END; {appendrec function} {$L+}
BEGIN {addrecord procedure}
    newaddr := appendrec(txt,nyes,nno);
    IF runabort
        THEN GOTO 1;
    xptr := dirfetch(maxquery+1);
    ximage.xentry[xptr] := newaddr;
    write(xfile:highxblk,ximage);

    IF ((nyes=0) AND (nno=0))
        THEN maxanimals := maxanimals + 1;
    maxquery := maxquery + 1;
    blokfetch(1,qimage);
    IF runabort
        THEN GOTO 1;
    revert(qimage.qentry, 6,maxquery);
    revert(qimage.qentry, 8,highblok);
    revert(qimage.qentry,10,highxblk);
    revert(qimage.qentry,12,maxanimals);
    write(qfile:1,qimage);
1:
END; {addrecord procedure} {$L+}
PROCEDURE initializefiles;

VAR
    qfilename : string 15;
    xfilename : string 15;
{$L+}
PROCEDURE newfile;

CONST
    firstquestion = 'Does it live in the water';
    yesguess      = 'octopus';
    noguess       = 'moose';

VAR
    i        : dirx;
    newq     : queryfile;
    newx     : directory;

BEGIN {newfile procedure}
    rewrite(qfilename,newq);
    rewrite(xfilename,newx);
    FOR i := 1 TO 4 DO
        ximage.xentry[i] := 1;          {First 4 records to block 1   }
    FOR i := 5 TO maxx DO
        ximage.xentry[i] := 0;
    write(newx,ximage);

    WITH qimage DO
        BEGIN {with}
            FOR i := 1 TO bufsize DO
                qentry[i] := 0;
            qentry[1]  := 13;           {Control record length is 13  }
            qentry[2]  := 1;            {This is last & only segment  }
            qentry[5]  := ord(ctl);     {Identify as control rec  }
            qentry[7]  := 3;            {Highest question# is 3       }
            qentry[9]  := 1;            {Last question block used is 1}
            qentry[11] := 1;            {Last index block used is 1   }
            qentry[13] := 2             {File contains 2 animals      }
        END; {with}
    i := 14;
    maxquery := 0;
    appendseg1(firstquestion,2,3,qimage,i);
    i := i + 9 + length(firstquestion);
    maxquery := 1;
    appendseg1(yesguess,0,0,qimage,i);
    i := i + 9 + length(yesguess);
    maxquery := 2;
    appendseg1(noguess,0,0,qimage,i);
    write(newq,qimage)
END; {newfile procedure} {$L+}
FUNCTION testexist:  boolean;
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{* Test for existence of disk files QFILENAME and XFILENAME.         *}
{* Return FALSE if either one is missing, TRUE if both there.        *}
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

VAR
    testxfile : directory;
    testqfile : queryfile;
    missing   : boolean;

BEGIN {testexist function}
    reset(qfilename,testqfile);
    reset(xfilename,testxfile);
    missing := (eof(testqfile) OR eof(testxfile));
    testexist := NOT missing
END; {testexist function} {$L+}
BEGIN {initializefiles procedure}
    qfilename := filepfx;
    append(qfilename,'.QQQ ');
    xfilename := filepfx;
    append(xfilename,'.QQX ');
    IF NOT testexist
        THEN newfile;

    reset(qfilename,qfile);
    reset(xfilename,xfile);
    currblok   := -1;
    currxblk   := -1;
    highblok   :=  1;
    highxblk   :=  1;
    maxquery   :=  3;
    maxanimals :=  2;

    read(xfile:1,ximage);
    currxblk := 1;
    read(qfile:1,qimage);
    currblok := 1;
    currec   := buildctl(qimage);
    maxquery   := currec.lastq;
    highblok   := currec.lastqbl;
    highxblk   := currec.lastxbl;
    maxanimals := currec.beastct
END; {initializefiles procedure} {$L+}
PROCEDURE guessing;

LABEL 1;

CONST
    bell      = 7;           {ordinal of ASCII code for terminal bell }
    boast     = 'How about that - - - I WON!';
    delay     = 8000;

VAR
    guesstime : boolean;
    success   : boolean;
    nextquest : integer;
    prevquest : integer;
    querytxt  : string maxlen+1;
    holdguess : qstring;
    i         : integer;
{$L+}
FUNCTION voweler (noun: qstring):  qstring;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{* Given a noun, return a string with the correct choice of "a" or   *}
{* "an" preceding the noun.                                          *}
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

VAR
    holder : qstring;

BEGIN {voweler function}
    IF noun[1] IN vowels
        THEN holder := ' an '
        ELSE holder := ' a ';
    append(holder,noun);
    voweler := holder
END; {voweler function}

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}

PROCEDURE lowerize (VAR txt: qstring);

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{* In a given string, change all upper-case letters to lower-case,   *}
{* unless it looks like the mix is intended.                         *}
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

VAR
    i      : integer;
    letter : char;
    sloppy : boolean;

BEGIN {lowerize procedure}
    sloppy := true;
    FOR i := 1 TO 4 DO
        IF i<=length(txt)
            THEN IF txt[i] in ['a'..'z']
                    THEN sloppy := false;
    IF sloppy
        THEN FOR i := 1 TO length(txt) DO
                BEGIN {for}
                    letter := txt[i];
                    IF ((letter>='A') AND (letter<='Z'))
                        THEN txt[i] := chr(ord(letter)-shiftup)
                END {for}
END; {lowerize procedure} {$L+}
PROCEDURE askabout (qtext: qstring);

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{* Publish a given question.                                         *}
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

CONST
    maxline  = 69;

VAR
    i, j     : questx;
    holder   : qstring;

BEGIN {askabout procedure}
    write(reverse);
    IF length(qtext)<=maxline
      THEN write(qtext)
      ELSE
        BEGIN
          i := maxline;
          WHILE (i>(maxline-20)) AND (qtext[i]<>' ') DO
            i := i - 1;
          IF i>(maxline-20)
            THEN
              BEGIN
                setlength(holder,i-1);
                FOR j := 1 to (i-1) DO
                  holder[j] := qtext[j];
                writeln(holder,invert);
                holder := '    ';
                append(holder,reverse);
                FOR j := (i+1) TO length(qtext) DO
                  append(holder,qtext[j]);
                write(holder)
              END {then}
            ELSE write(qtext)
        END {else}
END; {askabout procedure} {$L+}
PROCEDURE learning (oldguess  : qstring;
                    prevquest : integer);
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{* Given an old (wrong) guess (in the form "a fish" or "an egret",   *}
{* and the record number of the question that led to that guess,     *}
{* secure from the player the correct answer, and a yes-or-no        *}
{* question that would have led to it.  Insert the new question and  *}
{* and animal into the question file linkage.                        *}
{*                                                                   *}
{* Side effects:                                                     *}
{*      maxanimals - updated                                         *}
{*      I/O variables as required (see subordinate procedures)       *}
{*      currec (used to build new record & view old guess)           *}
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

CONST
    humbler  = 'Oh!  I didn''t know about';
    request1 = 'I''d like to learn more about animals.';
    request2 = 'What''s a yes-or-no question to discriminate between';
    clarify1 = 'Which answer to that question would mean';
    clarify2 = ' - yes or no';
    thanks   = 'Thank you!  Now I know ';

VAR
    holdright  : qstring;
    rightbeast : qstring;
    newbeast   : boolean;
    newquery   : qstring;
    qhold      : qstring;




PROCEDURE depunctuate (VAR dtext: qstring);

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{* Trim off any terminating punctuation marks.                       *}
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

CONST
    endset   = '.!?';

BEGIN {depunctuate procedure}
    WHILE index(endset,dtext[length(dtext)])<>0 DO
        setlength(dtext,length(dtext)-1)
END; {depunctuate procedure} {$L+}
FUNCTION getbeast: qstring;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{* Return the name of the animal the player had in mind.             *}
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

CONST
    puzzled  = 'Really?  What sort of animal is it, then?';

VAR
    altered  : boolean;
    oldlen   : questx;
    holder   : qstring;

{$L+}
PROCEDURE markout (VAR btext: qstring;  word: qstring);

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{* Given a BTEXT, find any instances of WORD appearing as distinct   *}
{* words.  If there are any, eliminate from BTEXT all characters to  *}
{* and including WORD.                                               *}
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

CONST
    blank1 = ' ';

VAR
    i, j     : questx;
    offset   : questx;
    padword  : qstring;
    padlen   : questx;

BEGIN {markout procedure}
    padword := word;
    append(padword,blank1);
    padlen  := length(padword);
    WHILE index(btext,padword)=1 DO
        BEGIN {while}
            setlength(btext,length(btext)-padlen);
            FOR i := 1 TO length(btext) DO
                btext[i] := btext[i+padlen];
            WHILE btext[1]=blank1 DO
                BEGIN {while}
                    setlength(btext,length(btext)-1);
                    FOR i := 1 TO length(btext) DO
                        btext[i] := btext[i+1]
                END {while}
        END; {while}
    padword := blank1;
    append(padword,word);
    append(padword,blank1);
    padlen := length(padword);
   j := index(btext,padword);
    WHILE j<>0 DO
        BEGIN {while}
            offset := j + padlen - 1;
            setlength(btext,length(btext)-offset);
            FOR i := 1 TO length(btext) DO
                 btext[i] := btext[offset+i];
            WHILE btext[1]=blank1 DO
                BEGIN {while}
                    setlength(btext,length(btext)-1);
                    FOR i := 1 TO length(btext) DO
                        btext[i] := btext[i+1]
                END; {while}
            j := index(btext,padword)
        END {while}
END; {markout procedure} {$L+}
BEGIN {getbeast function}
    writeln(puzzled);
    readln(holder);
    depunctuate(holder);
    lowerize(holder);
    oldlen := length(holder);
    altered := (holder[1]='A');
    IF altered
        THEN holder[1] := 'a';
    markout(holder,'a');
    markout(holder,'an');
    IF (altered AND (oldlen=length(holder)))
        THEN holder[1] := 'A';
    getbeast := holder
END; {getbeast function} {$L+}
PROCEDURE insertquestion (qstn : qstring;
                          ind  : boolean;
                          ytxt : qstring;
                          rec  : question;
                          prev : integer);
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{* Insert a new question and guess into the question file, with      *}
{* all required linkages.  QUESTN is the new question, YTXT is the   *}
{* name of the new animal to be guessed.  If IND is true, then YTST  *}
{* is the guess for a YES answer, and the animal in REC for NO;      *}
{* otherwise, it's the other way around.  PREV is the question#      *}
{* that led to this question;  the new question is to be substituted *}
{* for REC in that question.                                         *}
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

LABEL 1;

VAR
    newqstnum : integer;
    newansnum : integer;
    oldansnum : integer;
    newyes    : integer;
    newno     : integer;
{$L+}
PROCEDURE amendrec (recno, nyes, nno: integer);

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{* For a given question record, update the NEXTYES and NEXTNO ptrs.  *}
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

LABEL 1;

VAR
    blokno   : integer;
    xptr     : dirx;
    ptr      : bufx;

BEGIN {amendrec procedure}
    xptr := dirfetch(recno);
    IF runabort
        THEN GOTO 1;
    blokno := ximage.xentry[xptr];
    blokfetch(blokno,qimage);
    IF runabort
        THEN GOTO 1;
    ptr := findrec(recno,qimage.qentry);
    IF runabort
        THEN GOTO 1;
    revert(qimage.qentry,ptr+5,nyes);
    revert(qimage.qentry,ptr+7,nno);
    write(qfile:blokno,qimage);
1:
END; {amendrec procedure} {$L+}
BEGIN {insertquestion procedure}
    newqstnum := maxquery + 1;
    newansnum := maxquery + 2;
    oldansnum := rec.ident;
    IF ind
        THEN BEGIN
                newyes := newansnum;
                newno  := oldansnum
            END {then}
        ELSE BEGIN
                newyes := oldansnum;
                newno  := newansnum
            END; {else}
    addrecord(qstn,newyes,newno);
    IF runabort
        THEN GOTO 1;
    addrecord(ytxt,0,0);
    IF runabort
        THEN GOTO 1;
    rec := getrecord(prev);
    IF runabort
        THEN GOTO 1;
    IF rec.nextyes=oldansnum
        THEN rec.nextyes := newqstnum
        ELSE rec.nextno  := newqstnum;
    amendrec(prev,rec.nextyes,rec.nextno);
1:
END; {insertquestion procedure} {$L+}
BEGIN {learning procedure}
    rightbeast := getbeast;
    holdright  := voweler(rightbeast);
    writeln(humbler,holdright,'.');
    writeln(request1);
    qhold := request2;
    append(qhold,holdright);
    append(qhold,' and');
    append(qhold,oldguess);
    append(qhold,'?');
    askabout(qhold);
    writeln(invert);
    readln(newquery);
    depunctuate(newquery);
    lowerize(newquery);
    IF ((newquery[1]>='a') AND (newquery[1]<='z'))
        THEN newquery[1] := chr(ord(newquery[1])+shiftup);
    qhold := clarify1;
    append(qhold,holdright);
    append(qhold,clarify2);
    askabout(qhold);
    IF getyes
        THEN newbeast := true
        ELSE newbeast := false;
    insertquestion(newquery,newbeast,rightbeast,currec,prevquest);
    writeln;
    IF NOT runabort
        THEN writeln(thanks,maxanimals:1,' animals.')
END; {learning procedure} {$L+}
BEGIN {guessing procedure} {$C+}
    guesstime := false;
    nextquest := 1;
    WITH currec DO
        BEGIN {with}
            WHILE NOT guesstime DO
                BEGIN {while}
                    currec := getrecord(nextquest);
                    IF runabort
                        THEN GOTO 1;
                    guesstime := (nextyes=0) AND (nextno=0);
                    IF NOT guesstime
                        THEN BEGIN
                                prevquest := ident;
                                askabout(query);
                                IF getyes
                                    THEN nextquest := nextyes
                                    ELSE nextquest := nextno
                            END {then}
                END; {while}
            querytxt  := 'Is it';
            holdguess := voweler(query);
            append(querytxt,holdguess);
            askabout(querytxt);
            IF getyes
                THEN BEGIN
                        writeln;
                        writeln(chr(bell),boast);
                        FOR i := 1 TO delay DO;
                    END {then}
                ELSE learning(holdguess,prevquest)
        END; {with}
1:
END; {guessing procedure} {$L+}
PROCEDURE explain;

CONST
    l01a = '                      WELCOME to the Ani';
    l01b = 'mal Guessing Game!';
    l02  = 'Here''s how it works:';
    l03a = 'You think of some particular kind of ani';
    l03b = 'mal (like, say, an octopus), and I''ll';
    l04a = 'try to figure out what animal you''re thi';
    l04b = 'nking of, by asking you some yes-or-no';
    l05a = 'questions.  If I guess correctly, I win;';
    l05b = '  if you stump me, you win.  If you';
    l06a = 'want to win, you''d better pick a hard on';
    l06b = 'e, though --- I already know ';
    l06c = 'animals!';
    l07a = 'There is one catch.  I like winning a LO';
    l07b = 'T better than losing, so if you manage';
    l08a = 'to stump me with your animal, I''ll ask y';
    l08b = 'ou to teach me about that animal, so I';
    l09a = 'can get it right next time.  That way, I';
    l09b = ' get smarter every time I play!';
    l10a = 'A word about how we converse:  when I as';
    l10b = 'k a yes-or-no question, you can reply';
    l11a = 'by pressing just the Y key or the N key ';
    l11b = '(no need to spell out "yes" or "no").';
    l12a = 'For any other questions, please key in y';
    l12b = 'our answer, then press the <RETURN> key';
    l13a = ' (the gray key shaped sort of like a bac';
    l13b = 'kwards L).';

BEGIN {explain procedure}
    WRITELN(l01a,l01b);
    WRITELN;
    WRITELN(l02);
    WRITELN;
    WRITELN(l03a,l03b);
    WRITELN(l04a,l04b);
    WRITELN(l05a,l05b);
    WRITELN(l06a,l06b,maxanimals:1);
    WRITELN(l06c);
    WRITELN;
    WRITELN(l07a,l07b);
    WRITELN(l08a,l08b);
    WRITELN(l09a,l09b);
    WRITELN;
    WRITELN(l10a,l10b);
    WRITELN(l11a,l11b);
    WRITELN(l12a,l12b);
    WRITELN(l13a,l13b);
    WRITELN
END; {explain procedure} {$E+}
BEGIN {mainline procedure of program}
    runabort := false;
    vowels   := ['A','E','I','O','U','a','e','i','o','u'];
    shiftup  := ord('A') - ord('a');
    setupvdt;
{   rewrite('LST: ',db);  }
{   dbugging := false;    }
    initializefiles;
    WRITE(clear);
    explain;
    write(inviter);
    moreokay := getyes;
    IF NOT moreokay
      THEN
        BEGIN
          WRITELN;
          WRITELN(insulted)
        END; {then}
    WHILE moreokay DO
      BEGIN {while}
        writeln(clear,start1);
        writeln(start2);
        readln(replytxt);
        WRITE(clear);
        guessing;
        IF runabort
          THEN moreokay := false
          ELSE
            BEGIN
              WRITE(askagain);
              moreokay := getyes
            END {else}
      END; {while}
    IF runabort
      THEN writeln('TERMINATING DUE TO PROGRAM OR FILE ERROR')
      ELSE writeln('Okay!  Goodbye!')
END. {Animals program}
