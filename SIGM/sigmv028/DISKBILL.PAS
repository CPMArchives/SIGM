 
 {Simpleminded billing program for professional services (clinical
 psychology).  Written for ADM-3 CRT.  Copyright 1980 by Richard
 Yensen, Ph.D., 2403 Talbot Rd., Baltimore, MD 21216.  Distribution for 
 profit is prohibited.}
 
 (*$G+*)
 PROGRAM DISKBILL;
 TYPE
 PATIENT=RECORD
 
 NAME:STRING[32];
 STREET,KEY:STRING[40];
 CITYSTATE:STRING[40];
 RATE:REAL;
 RECEIVE, PERCENT:REAL;
 CUT:BOOLEAN;
 HARTMAN:ARRAY[1..2] OF ARRAY[1..18] OF INTEGER;
 DIAGNOSIS:STRING[40];
 SYMPTOMS:STRING[8];
 INSURANCECO:STRING[40];
 ACCTNUMBER:STRING[15];
 SOCSECNUMBER:STRING[10];
 EMPLOYER:STRING[40];
 WKSTREET:STRING[40];
 WKCTYSTATE:STRING[40];
 FIRSTVISIT:STRING[8];
 LASTVISIT:STRING[8];
 BIRTHDATE:STRING[8];
 WORKPHONE:STRING[12];
 HOMEPHONE:STRING[12]
 END;
 
 VAR HANDLE:STRING[32];
 RECNUM:INTEGER;
 BUF:PATIENT;
 TITLE:STRING;
 FID:FILE OF PATIENT;
 GOTCASH,TOTAL,AMT:REAL;
 INDEX,DEFAULT:INTEGER;
 ANSWER:CHAR;
 DATE:ARRAY[1..26] OF STRING[9];
 TIME:ARRAY[1..26] OF REAL;
          SHOWTIME, FOUNDIT, KEEPGOING:BOOLEAN;
 OUT:TEXT;
 
 PROCEDURE WIPESCREEN;
 BEGIN
 WRITE(CHR(26));
 END;

 PROCEDURE SHALI;
 BEGIN
 WIPESCREEN;GOTOXY(12,12);
 WRITELN('Shall we continue?  ');
 READ(ANSWER);
 IF (ANSWER='N') OR (ANSWER='n') THEN KEEPGOING:=FALSE;
 END;
 
 PROCEDURE PROMPT;
 BEGIN
 WIPESCREEN;
 GOTOXY(12,12);
 WRITELN('This is a program to prepare bills.  Please enter the name of');
 WRITELN('the person you would like to prepare a bill for:  ');
 READLN(HANDLE);
 END; (*  PROMPT  *)
 
 PROCEDURE SEARCH;
 VAR ANSWER:CHAR;
 BEGIN
 FOUNDIT:=FALSE;
 RECNUM:=0;
 RESET(FID,'PATIENTS');
 WHILE (NOT FOUNDIT) AND (NOT EOF(FID)) DO
 BEGIN
 WITH FID^ DO
 BEGIN
 IF HANDLE=NAME THEN FOUNDIT:=TRUE;
 END;
 IF NOT FOUNDIT THEN
   BEGIN
 RECNUM:=RECNUM+1;
 SEEK(FID,RECNUM);
 GET(FID);
 END; (* IF NOT FOUNDIT *)
 END; (* WHILE *)
 IF (EOF(FID)) AND (NOT FOUNDIT) THEN 
 BEGIN
 WRITELN('Could not find ',HANDLE,' in the file');
                                           WRITELN('Be sure you put in the full name.');
 WRITELN('TYPE A "C" TO TRY AGAIN OR ANY OTHER CHARACTER TO STOP');
 READ(ANSWER);
 IF (ANSWER='C')OR(ANSWER='c')THEN
 BEGIN
 CLOSE(FID,LOCK);
 PROMPT;
 SEARCH;
 END;
 END;
 END; (*  SEARCH  *)
 
  
 PROCEDURE DODOTS(N:INTEGER)   {PRETTIES UP THE DISPLAY};
 VAR I:INTEGER;
 BEGIN
 FOR I:=1 TO N DO
 BEGIN
 WRITE('-');
 *END;
 END   {DODOTS};
 
 PROCEDURE PUTREAL(D:REAL);
 VAR I:INTEGER;
     B:INTEGER;
 BEGIN
 B:=ABS(ROUND((D-TRUNC(D))*100));
 IF B<10 THEN 
 BEGIN
 WRITE(TRUNC(D):3,'.0',B)
 END
 ELSE  {B>=10}
 BEGIN
 IF D>=1.0 THEN 
 BEGIN
 WRITE(TRUNC(D):3,'.',B) 
 END;
 IF D<1 THEN
 BEGIN
 I:=ROUND(D*100); 
 IF I>0 THEN {D is positive} 
 BEGIN 
 WRITE('  0.',B);
 END;
 IF I<0 THEN   {D is negative} 
 BEGIN
 WRITE(' -0.');
 IF B<10 THEN WRITE('0',B)
 ELSE WRITE(B);
 END;
 IF I=0 THEN WRITE('  0   ');
 END; 
 END  {D>=1.0};
 END  {PUTREAL};
 
 
 PROCEDURE PUTIME(D:REAL);
 VAR I:INTEGER;
     B:INTEGER;
       BEGIN
 B:=ABS(ROUND((D-TRUNC(D))*100));
 IF B<10 THEN 
 BEGIN
 WRITE(TRUNC(D):1,'.0',B)
 END
 ELSE  {B>=10}
 BEGIN
 IF D>=1.0 THEN 
 BEGIN
 WRITE(TRUNC(D):1,'.',B) 
 END;
 IF D<1 THEN
 BEGIN
 I:=ROUND(D*100); 
 IF I>0 THEN {D is positive} 
 BEGIN 
 WRITE('  0.',B);
 END;
 IF I<0 THEN   {D is negative} 
 BEGIN
 WRITE(' -0.');
 IF B<10 THEN WRITE('0',B)
 ELSE WRITE(B);
 END;
 IF I=0 THEN WRITE('  0   ');
 END; 
 END  {D>=1.0};
 END  {PUTIME};
 
 PROCEDURE PRINTAB(I:INTEGER);
 VAR J:INTEGER;
 BEGIN
 FOR J:=1 TO I DO
 BEGIN
 WRITE(OUT,' ');
 END;
 END;
 
 PROCEDURE TAB(I:INTEGER);
 VAR J:INTEGER;
 BEGIN
 FOR J:=1 TO I DO
 BEGIN
 WRITE(' ');
 END;
 END;
 
 PROCEDURE LASTHALFOFRECORD(REC:PATIENT);
 BEGIN
 WITH REC DO
 BEGIN
 WRITELN('Key to sort:              ',KEY);
 WRITELN('Diagnosis:                ',DIAGNOSIS);
 WRITELN('Date of First Symptoms:   ',SYMPTOMS);
 WRITELN('Insurance Company:        ',INSURANCECO);
                                             WRITELN('Account Number:           ',ACCTNUMBER);
 WRITELN('Social Security #:        ',SOCSECNUMBER);
 WRITELN('Employer:                 ',EMPLOYER);
 WRITELN('  Address:                ',WKSTREET);
 WRITELN('  City   State:           ',WKCTYSTATE);
 WRITELN('  Telephone:              ',WORKPHONE);
 WRITELN('Birthdate:                ',BIRTHDATE);
 WRITELN('First Visit:              ',FIRSTVISIT);
 WRITELN('Last Visit:               ',LASTVISIT);
 WRITELN('Home Telephone:           ',HOMEPHONE);
 END;
 END;(*  LASTHALFOFRECORD  *)
 
 PROCEDURE SHOWREC(REC:PATIENT);
 BEGIN
 WRITELN;
 WITH REC DO
 BEGIN
 WRITELN('Name:                     ',NAME);
 WRITELN('Street:                   ',STREET);
 WRITELN('City   State:             ',CITYSTATE);
 WRITE('Hourly Rate:              $');PUTREAL(RATE);WRITELN;
 WRITE('Paid Each Visit In Cash:  $');PUTREAL(RECEIVE);WRITELN;
 WRITE('Professional Discount:    ');
 IF CUT THEN
 BEGIN
 WRITELN('Yes');
                                            WRITE('              Amount:     ');WRITELN (TRUNC(100*PERCENT),'%');
 END
 ELSE WRITELN('No');
 LASTHALFOFRECORD(FID^);
 END; 
 END; (*SHOWREC*)
 
 
 
 PROCEDURE GETREC(VAR REC:PATIENT);
 LABEL 1;
 VAR ANSWER:CHAR;
 S:STRING;
 R:REAL;
 Q:INTEGER;
 
 FUNCTION READSTRING(VAR T:STRING):BOOLEAN;
 BEGIN
 WRITE('                               <esc> Return to skip record'); 
 FOR Q:=1 TO 60 DO
 BEGIN
 WRITE(CHR(8));
 END;
 READLN(S);
 READSTRING:=FALSE;
 IF LENGTH(S)>0 THEN
 IF S[LENGTH(S)]=CHR(27(*  ESC  *)) THEN READSTRING:=TRUE
 ELSE
 T:=S;
 END;(*  READSTRING  *)
 
 FUNCTION READBOOL(VAR T:BOOLEAN):BOOLEAN;
 BEGIN
 READLN(S);
 READBOOL:=FALSE;
 IF LENGTH(S)>0 THEN
 IF S[LENGTH(S)]=CHR(27(*  ESC  *)) THEN READBOOL:=TRUE
 ELSE
 BEGIN
 CASE S[1] OF
 'F','f','N','n':T:=FALSE;
 'T','t','Y','y':T:=TRUE
 END
 END;
 END;(*  READBOOL  *)
 
 FUNCTION READREAL(VAR T:REAL): BOOLEAN;
 BEGIN
 WRITE('SKIP TO THE NEXT FIELD? <Yes or No>');
 READ(ANSWER);
                       IF (ANSWER='N') OR (ANSWER='n') THEN
 BEGIN
 FOR Q :=1 TO 36 DO
 BEGIN
 WRITE(CHR(8));
 END;
 FOR Q :=1 TO 36 DO
 BEGIN
 WRITE(' ');
 END;
 FOR Q :=1 TO 36 DO
 BEGIN
 WRITE(CHR(8));
 END;
 WRITE('$             a minus entry will skip entire record');
 FOR Q:=1 TO 50 DO
 BEGIN
 WRITE(CHR(8));
 END;
 READLN(R);
 IF R<0 THEN READREAL:=TRUE
 ELSE T:=R;
 END;(*  IF ANSWER = N  *)
 IF (ANSWER='Y')OR(ANSWER='y') THEN
 WRITELN;
 
 END;
 
 FUNCTION READPCT(VAR T:REAL): BOOLEAN;
 BEGIN
 WRITE('SKIP TO THE NEXT FIELD? <Yes or No>');
 READ(ANSWER);
 IF (ANSWER='N') OR (ANSWER='n') THEN
 BEGIN
 FOR Q :=1 TO 36 DO
 BEGIN
 WRITE(CHR(8));
 END;
 FOR Q :=1 TO 36 DO
 BEGIN
 WRITE(' ');
 END;
 FOR Q :=1 TO 36 DO
 BEGIN
 WRITE(CHR(8));
 END;
 WRITE('  %          a minus entry will skip entire record');
 FOR Q:=1 TO 50 DO
 BEGIN
 WRITE(CHR(8));
 END;
 READLN(R);
 IF R<0 THEN READPCT:=TRUE
 ELSE T:=R/100;
 END;(*  IF ANSWER = N  *)
 IF (ANSWER='Y')OR(ANSWER='y') THEN
        WRITELN;
 
 END;
 
 BEGIN(*  GETREC  *)
 WRITELN('Entering a return will skip to next item without changing the present item');
   WRITELN;
 WITH REC DO
 BEGIN
 WRITE('Name:                 ');IF READSTRING(NAME) THEN GOTO 1;
 WRITE('Street:               ');IF READSTRING(STREET) THEN GOTO 1;
 WRITE('City   State:         ');IF READSTRING(CITYSTATE) THEN GOTO 1;
 WRITE('Hourly Rate:          ');IF READREAL(RATE) THEN GOTO 1;
 WRITE('Paid Each Session:    ');IF READREAL(RECEIVE) THEN GOTO 1;
 %WRITE('Professional Discount:');IF READBOOL(CUT) THEN GOTO 1;
 IF CUT THEN
 BEGIN
 WRITE('              Percent:');IF READPCT(PERCENT) THEN GOTO 1;
 END
 ELSE PERCENT:=0;
 WRITE('Key to Sort by:        ');IF READSTRING(KEY) THEN GOTO 1;
 WRITE('Diagnosis:             ');IF READSTRING(DIAGNOSIS) THEN GOTO 1;
 WRITE('Date of First Symptoms:');IF READSTRING(SYMPTOMS) THEN GOTO 1;
 WRITE('Insurance Company:     ');IF READSTRING(INSURANCECO) THEN GOTO 1;
                                                 WRITE('Account Number:        ');IF READSTRING(ACCTNUMBER) THEN GOTO 1;
 WRITE('Social Security #:     ');IF READSTRING(SOCSECNUMBER) THEN GOTO 1;
 WRITE('Employer:              ');IF READSTRING(EMPLOYER) THEN GOTO 1;
 WRITE('  Address:             ');IF READSTRING(WKSTREET) THEN GOTO 1;
 WRITE('  City   State:        ');IF READSTRING(WKCTYSTATE) THEN GOTO 1;
 WRITE('  Telephone:           ');IF READSTRING(WORKPHONE) THEN GOTO 1;
 WRITE('Birthdate:             ');IF READSTRING(BIRTHDATE) THEN GOTO 1;
 WRITE('First Visit:           ');IF READSTRING(FIRSTVISIT) THEN GOTO 1;
 WRITE('Last Visit:            ');IF READSTRING(LASTVISIT) THEN GOTO 1;
 WRITE('Home Telephone:       ');IF READSTRING(HOMEPHONE) THEN GOTO 1;
 END;
 1:    
 END;(*  GETREC  *)
 
PROCEDURE DIDNTPAY(VAR REC:PATIENT);
 VAR ANSWER:CHAR;
 CASH:REAL;
 BEGIN
 WITH REC DO
 REPEAT
 GOTCASH:=0;
 IF (RECEIVE>0)  THEN
  REPEAT
 WIPESCREEN;GOTOXY(12,12);
 WRITE('Enter number of times ', NAME ,' did not pay $');
                  PUTREAL(RECEIVE);
 WRITELN;
 READLN(DEFAULT);
 GOTCASH:=RECEIVE*(INDEX-DEFAULT);
 WIPESCREEN;GOTOXY(12,12);
 WRITE('If ',NAME,' paid $');
 PUTREAL(RECEIVE);
 WRITELN(' each visit.');
 WRITE('Then you received $');PUTREAL(GOTCASH);WRITE(' Is this okay?');
 READ (ANSWER);
 IF (ANSWER='Y') OR (ANSWER='y') THEN ANSWER:='X';
 UNTIL ANSWER='X';
 WIPESCREEN;GOTOXY(12,12);
 WRITELN('Have you received any additional cash from ',NAME,' ?');
 READ(ANSWER);
 IF (ANSWER='N')OR(ANSWER='n')OR(ANSWER='F')OR(ANSWER='f')THEN ANSWER:='Q';
 IF (ANSWER ='Y') OR (ANSWER='y') OR (ANSWER ='T') OR (ANSWER='t') THEN
 BEGIN
 REPEAT
 WIPESCREEN;GOTOXY(12,12);
 CASH:=0;
 WRITE('Enter the amount received from ',NAME,' $');
 READLN(CASH);
 WRITE('$');PUTREAL(CASH);
 WRITELN('  Is this okay?');
 READ(ANSWER);
 IF (ANSWER ='Y') OR (ANSWER='y') OR (ANSWER='T') OR (ANSWER='t') THEN ANSWER:='X';
 UNTIL ANSWER='X';
 GOTCASH:=GOTCASH+CASH;
 WIPESCREEN;GOTOXY(0,12);
 WRITE('You have received a total of $');
         PUTREAL(GOTCASH);
 WRITELN(' from ',NAME,' in cash. ');
 WRITE(' Is this Correct?');
 READ(ANSWER);
 END; (* IF THEN *)
   UNTIL (ANSWER='Y')OR(ANSWER='y')OR(ANSWER='T')OR(ANSWER='t')OR(ANSWER='Q'); 
 (*  WITH REC DO *)
 WIPESCREEN;
 END; (*  DIDNTPAY  *)
 
 
 PROCEDURE DATES(VAR REC:PATIENT);
 VAR I:INTEGER;
 SAMETIME:BOOLEAN;
 LONG:REAL;
 BEGIN
 WITH REC DO
 BEGIN
 WIPESCREEN;GOTOXY(12,12);
 I:=0;
 WRITELN('Enter the dates of service followed by the time spent.');
 WRITELN('Hit RETURN to proceed.');
 READ(ANSWER);
 WIPESCREEN;GOTOXY(1,12);
 WRITE('Do you want the time displayed on the bill');
 READ(ANSWER);
 IF (ANSWER='N')OR(ANSWER='n') THEN SHOWTIME:=FALSE ELSE SHOWTIME:=TRUE;
 WIPESCREEN;GOTOXY(1,12);
 WRITE('Does this patient come for the same number of hours each week? ');
 READ(ANSWER);LONG:=0;
 IF (ANSWER='Y')OR(ANSWER='y') THEN
 BEGIN
 WIPESCREEN; GOTOXY(12,12);
 SAMETIME:=TRUE;
 WRITE('How many hours? ');
 READLN(LONG);
 END
 ELSE SAMETIME:=FALSE;
 REPEAT
    I:=I+1;
 WIPESCREEN;GOTOXY(12,12);
 WRITE('date #',I,'=');
 READLN(DATE[I]);
 WIPESCREEN;GOTOXY(12,12);
 WRITE(DATE[I],' Correct?');
 READ(ANSWER);
 IF ANSWER='N' THEN 
 BEGIN
 WIPESCREEN;GOTOXY(12,12);
 WRITE('date #',I,'=');
 READLN(DATE[I]);
 END;
 IF ANSWER='n' THEN 
 BEGIN
 WIPESCREEN;GOTOXY(12,12);
 WRITE('date #',I,'=');
 READLN(DATE[I]);
 END;
 IF NOT SAMETIME THEN
 BEGIN
 WIPESCREEN;GOTOXY(12,12);
 WRITE('length of appointment=');
 READLN(TIME[I]);
 WIPESCREEN;GOTOXY(12,12);
 WRITE(DATE[I],' ', NAME  ,' spent ');
 PUTREAL(TIME[I]);WRITE(' hours.   Correct?');
 READ(ANSWER);
 IF ANSWER='N' THEN 
 BEGIN
 WIPESCREEN;GOTOXY(12,12);
 WRITE('time for ',DATE[I],'= ');
 READLN(TIME[I]);
 END;
 IF ANSWER='n' THEN 
 BEGIN
 WIPESCREEN;GOTOXY(12,12);
 WRITE('time for ',DATE[I],'= ');
 READLN(TIME[I]);
 END;
 END;  (* IF NOT SAMETIME *)
 IF SAMETIME THEN TIME[I]:=LONG;
 UNTIL DATE[I]='';
 INDEX:=I-1;
 END;
 END;(*  DATES  *)
 
 
                                     PROCEDURE DOBILL(VAR REC:PATIENT);
 VAR J:INTEGER;
 BEGIN
 WITH REC DO
 BEGIN
 WIPESCREEN;
 TOTAL:=0;
 TAB(15);
 WRITELN(NAME);
 TAB(15);
 WRITELN(STREET);
 TAB(15);
 WRITELN(CITYSTATE);
 WRITELN;
 WRITELN;
 WRITELN('Individual Psychotherapy:');
 WRITELN;
 WRITELN;
 FOR J:=1 TO INDEX DO
 BEGIN
 WRITE(DATE[J]);
 DODOTS(15-LENGTH(DATE[J]));
 IF SHOWTIME THEN
  BEGIN
 WRITE('(');
 PUTIME(TIME[J]);
 WRITE(' hour');
 IF TIME[J]>1 THEN WRITE('s')
 ELSE WRITE(' ');
 WRITE(')');
 DODOTS(13);
 END
 ELSE DODOTS(25);
 WRITE('$');
 AMT:=(TIME[J]*RATE);
 PUTREAL(AMT);
 WRITELN;
 TOTAL:=TOTAL+AMT;
 END;
 IF (CUT) OR (RECEIVE>0) OR (GOTCASH>0) THEN
 BEGIN
 WRITELN;
 WRITELN;
 WRITE('Total');
 DODOTS(35);
 WRITE('$');
 PUTREAL(TOTAL);
 END;
 IF CUT THEN
 BEGIN
 WRITELN;
 WRITELN;
 WRITE('Professional Discount');
 DODOTS(19);
 WRITE('$');
 PUTREAL(PERCENT*TOTAL);
 TOTAL:=TOTAL-(PERCENT*TOTAL);
 END;
 IF (RECEIVE>0) OR (GOTCASH>0) THEN
 BEGIN
 WRITELN;
 WRITELN;
    WRITE('Received from ',NAME);
 DODOTS(26-LENGTH(NAME));
 WRITE('$');
 PUTREAL(GOTCASH);
 END;
 WRITELN;
 WRITELN;
 WRITE('Balance Due');
 DODOTS(29);
 WRITE('$');
 IF (CUT) OR (RECEIVE>0) OR (GOTCASH>0)THEN TOTAL:=(TOTAL-(GOTCASH));
 PUTREAL(TOTAL);
 END;
 END; (*  DOBILL  *)
 
 PROCEDURE PRINTDOTS(N:INTEGER)   {PRETTIES UP THE DISPLAY};
 VAR I:INTEGER;
 BEGIN
 FOR I:=1 TO N DO
 BEGIN
 WRITE(OUT,'-');
 END;
 END   {PRINTDOTS};
 
 PROCEDURE PRINTREAL(D:REAL);
 VAR I:INTEGER;
     B:INTEGER;
 BEGIN
 B:=ABS(ROUND((D-TRUNC(D))*100));
 IF B<10 THEN 
 BEGIN
 WRITE(OUT,TRUNC(D):3,'.0',B)
 END
 ELSE  {B>=10}
 BEGIN
 IF D>=1.0 THEN 
 BEGIN
 WRITE(OUT,TRUNC(D):3,'.',B) 
 END;
 IF D<1 THEN
 BEGIN
 I:=ROUND(D*100); 
 IF I>0 THEN {D is positive} 
 BEGIN 
 WRITE(OUT,'  0.',B);
 END;
 IF I<0 THEN   {D is negative} 
 BEGIN
 WRITE(OUT,' -0.');
 IF B<10 THEN WRITE(OUT,'0',B)
 ELSE WRITE(OUT,B);
 END;
 IF I=0 THEN WRITE(OUT,'  0   ');
 END; 
 END  {D>=1.0};
                END  {PRINTREAL};
 
 PROCEDURE PRINTIME(D:REAL);
 VAR I:INTEGER;
     B:INTEGER;
 BEGIN
 B:=ABS(ROUND((D-TRUNC(D))*100));
 IF B<10 THEN 
 BEGIN
 WRITE(OUT,TRUNC(D):1,'.0',B)
 END
 ELSE  {B>=10}
 BEGIN
 IF D>=1.0 THEN 
 BEGIN
 WRITE(OUT,TRUNC(D):1,'.',B) 
 END;
 IF D<1 THEN
 BEGIN
 I:=ROUND(D*100); 
 IF I>0 THEN {D is positive} 
 BEGIN 
 WRITE(OUT,'  0.',B);
 END;
 IF I<0 THEN   {D is negative} 
 BEGIN
 WRITE(OUT,' -0.');
 IF B<10 THEN WRITE(OUT,'0',B)
 ELSE WRITE(OUT,B);
 END;
 IF I=0 THEN WRITE(OUT,'  0   ');
 END; 
 END  {D>=1.0};
 END  {PRINTIME};
 
 PROCEDURE PRINTBILL(VAR REC:PATIENT);
 VAR C,Q,M,J,X:INTEGER;
 BEGIN
 WITH REC DO
 BEGIN
 WIPESCREEN;GOTOXY(12,12);
 C:=0;
 WRITELN('How many bills?');
 READLN (M);WRITELN;
 FOR Q:=1 TO M DO
 BEGIN
 WIPESCREEN;GOTOXY(12,12);
 WRITELN('READY WITH BILL IN PRINTER?');
 READ(ANSWER);
 WIPESCREEN;GOTOXY(12,12);
 C:=C+1;WRITELN('THIS IS THE #',C,' COPY I AM ABOUT TO PRINT.  DO YOU WANT MORE THAN ',M,'?');
          READ(ANSWER);WIPESCREEN;
 IF ANSWER='Y' THEN
 BEGIN
 WIPESCREEN;GOTOXY(12,12);
 WRITELN('HOW MANY EXTRA?');
 READ(X);WRITELN;
 M:=M+X;
 END;
 IF ANSWER='y' THEN
 BEGIN
 WIPESCREEN;GOTOXY(12,12);
 WRITELN('HOW MANY EXTRA?');
 READ(X);
 M:=M+X;
 END;
 WRITELN(OUT);
 PRINTAB(12);
 WRITELN(OUT,NAME);
 PRINTAB(12);
 WRITELN(OUT,STREET);
 PRINTAB(12);
 WRITELN(OUT,CITYSTATE);
 WRITELN(OUT);
 WRITELN(OUT);
 WRITELN(OUT);
 WRITELN(OUT);
 WRITELN(OUT);
 WRITELN(OUT,'Individual Psychotherapy:');
 WRITELN(OUT);
 WRITELN(OUT);
 TOTAL:=0;
 FOR J:=1 TO INDEX DO
 BEGIN
 WRITE(OUT,DATE[J]);
 PRINTDOTS(15-LENGTH(DATE[J]));
 IF SHOWTIME THEN
 BEGIN
 WRITE(OUT,'(');
 PRINTIME(TIME[J]);
 WRITE(OUT,' hour');
 IF TIME[J]>1 THEN WRITE(OUT,'s')
 ELSE WRITE(OUT,' ');
 WRITE(OUT,')');
 PRINTDOTS(13);
 END
 ELSE PRINTDOTS(25);
 WRITE(OUT,'$');
 AMT:=(TIME[J]*RATE);
 PRINTREAL(AMT);
 TOTAL:=TOTAL+AMT;
 WRITELN(OUT);
 END;
 IF (CUT) OR (RECEIVE>0) OR (GOTCASH>0) THEN
 BEGIN
          WRITELN(OUT);
 WRITELN(OUT);
 WRITE(OUT,'Total');
 PRINTDOTS(35);
 WRITE(OUT,'$');
 PRINTREAL(TOTAL);
 END;
 IF CUT THEN
 BEGIN
 WRITELN(OUT);
 WRITELN(OUT);
 WRITE(OUT,'Professional Discount');
 PRINTDOTS(19);
 WRITE(OUT,'$');
 PRINTREAL(PERCENT*TOTAL);
 TOTAL:=TOTAL-(PERCENT*TOTAL);
 END;
 IF (RECEIVE>0) OR (GOTCASH>0) THEN
 BEGIN
 WRITELN(OUT);
 WRITELN(OUT);
 WRITE(OUT,'Received from ',NAME);
 PRINTDOTS(26-LENGTH(NAME));
 WRITE(OUT,'$');
 PRINTREAL(GOTCASH);
 END;
 WRITELN(OUT);
 WRITELN(OUT);
 WRITE(OUT,'Balance Due');
 PRINTDOTS(29);
 WRITE(OUT,'$');
 PRINTREAL(TOTAL-GOTCASH);
 END;
 END;
 END; (*  PRINTBILL  *)
 
 PROCEDURE OKAY;
 BEGIN
 WRITELN;
 WRITELN('Is this bill in the form you wish printed?');
 READ(ANSWER);
 IF (ANSWER='N') OR (ANSWER='n') THEN
 BEGIN
 WIPESCREEN;GOTOXY(12,12);
 WRITELN('Is the error in the entry of visits and charges?');
 READ(ANSWER);
 IF (ANSWER='Y') OR (ANSWER='y') THEN
   BEGIN
 DATES(FID^);
 DOBILL(FID^);
 OKAY;
        ANSWER:=' ';
 END;
 END;
 END;  (*  OKAY  *)
 
 
 PROCEDURE ENVELOPE(VAR REC:PATIENT);
 BEGIN
 WITH REC DO
 BEGIN
 WIPESCREEN;GOTOXY(12,12);
 WRITELN('Shall I print an envelope for you?');
 READ(ANSWER);WIPESCREEN;
 IF ANSWER='Y' THEN
 BEGIN
 PRINTAB(30);
 WRITELN(OUT,NAME);
 PRINTAB(30);
 WRITELN(OUT,STREET);
 PRINTAB(30);
 WRITELN(OUT,CITYSTATE);
 END;
 IF ANSWER='y' THEN
 BEGIN
 PRINTAB(30);
 WRITELN(OUT,NAME);
 PRINTAB(30);
 WRITELN(OUT,STREET);
 PRINTAB(30);
 WRITELN(OUT,CITYSTATE);
 END;
   WIPESCREEN;GOTOXY(12,12);
 WRITELN('ANOTHER?');
 READ(ANSWER);WIPESCREEN;
 IF (ANSWER='Y') OR (ANSWER='y') THEN ENVELOPE(FID^);
 END;
 END;
 
 PROCEDURE MOREBILLS;
 BEGIN
 GOTOXY(12,12);
 WRITELN('MORE BILLS WITH SAME ADRESS?');
 READ(ANSWER);WIPESCREEN;
 IF (ANSWER='Y') OR (ANSWER='y') THEN
 BEGIN
 DATES(FID^);
 DIDNTPAY(FID^);
 DOBILL(FID^);
 OKAY;
 PRINTBILL(FID^);
 END;
 END    {MOREBILLS};
 
 
 
 PROCEDURE FOUNDTHERECORD(REC:PATIENT);
 BEGIN
              SHOWREC(FID^);
 WRITE('Is this record okay?');
 READ(ANSWER);
 IF (ANSWER='N') OR (ANSWER='n') THEN 
 BEGIN
 GETREC(FID^);
 SEEK(FID,RECNUM);
 PUT(FID);
 END;
 WITH REC DO
 BEGIN
 DATES(FID^);
 DIDNTPAY(FID^);
 DOBILL(FID^);
 OKAY;
 REWRITE(OUT,'PRINTER:');
 PRINTBILL(FID^);
 WRITELN('More Copies? ');
 READ(ANSWER);
 WIPESCREEN;
 IF (ANSWER='Y') OR (ANSWER='y') THEN PRINTBILL(FID^);
 ENVELOPE(FID^);
 MOREBILLS;
 CLOSE(OUT);
 END;
 END;(* FOUNDTHERECORD *)

 
 BEGIN  (*  MAIN PROGRAM  *)
 KEEPGOING:=TRUE;
 WHILE KEEPGOING DO
 BEGIN
 PROMPT;
 RECNUM:=0;
 FOUNDIT:=FALSE;
 SEARCH;
 IF FOUNDIT THEN FOUNDTHERECORD(FID^);
 SHALI;
 CLOSE(FID,LOCK);
 END; (* WHILE KEEPGOING *)
 END.

                                                                                                                                                                                                                                                                                                                                                                                                                                   