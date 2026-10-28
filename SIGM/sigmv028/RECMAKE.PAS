
 
 {Program to create the patient records used by DISKBILL.  Copyright
 1980 by Richard Yensen, Ph.D., 2403 Talbot Rd., Baltimore, MD 21216.
 Distribution for profit is prohibited.}
 
 (*$G+*)
 PROGRAM RECMAKE;
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
 VAR
 RECNUM:INTEGER;
 BUF:PATIENT;
 TITLE:STRING;
 FID:FILE OF PATIENT;
 
 PROCEDURE WIPESCREEN;
 BEGIN
 WRITE(CHR(26));
 END;
 
 PROCEDURE PUTREAL(D:REAL);
 VAR I:INTEGER;
     B:INTEGER;
 BEGIN
 B:=ABS(ROUND((D-TRUNC(D))*100));
 IF B<10 THEN 
 BEGIN
                     WRITE(TRUNC(D):3,'.0',B)
 END
 ELSE  (*  B>=10  *)
 BEGIN
 IF D>=1.0 THEN 
 BEGIN
 WRITE(TRUNC(D):3,'.',B) 
 END;
 IF D<1 THEN
 BEGIN
 I:=ROUND(D*100); 
 IF I>0 THEN (*  D is positive  *) 
 BEGIN 
 WRITE('  0.',B);
 END;
 IF I<0 THEN   (*  D is negative  *) 
 BEGIN
 WRITE(' -0.');
 IF B<10 THEN WRITE('0',B)
 ELSE WRITE(B);
 END;
 IF I=0 THEN WRITE('  0   ');
 END; 
 END  (*  D>=1.0  *);
 WRITELN;
 END  (*  PUTREAL  *);
 
 
 PROCEDURE ZEROREC(VAR REC:PATIENT);
 VAR  SECTION, RATING : INTEGER;
 BEGIN
 WITH REC DO
 BEGIN
 NAME:='';
 STREET:='';
 CITYSTATE:='';
 RECEIVE:=0;
 RATE:=0;
 CUT:=FALSE;
 PERCENT:=0;
 KEY:='';
 INSURANCECO:='';
 DIAGNOSIS:='';
 SYMPTOMS:='';
 ACCTNUMBER:='';
 SOCSECNUMBER:='';
 EMPLOYER:='';
 WKSTREET:='';
 WKCTYSTATE:='';
 FIRSTVISIT:='';
 LASTVISIT:='';
 BIRTHDATE:='';
 WORKPHONE:='';
 HOMEPHONE:='';
 FOR SECTION:=1 TO 2 DO
 BEGIN
 FOR RATING:=1 TO 18 DO
 BEGIN
   HARTMAN[SECTION,RATING]:=0;
 END;
 END;
 END;
               END(*  ZEROREC  *);
 
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
 VAR ANSWER:CHAR;
 BEGIN
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
 WRITELN('<<<<<<< Press Any Character to Begin Entering Corrections >>>>>>>>');
 READ(ANSWER);
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
 WRITE('Professional Discount:');IF READBOOL(CUT) THEN GOTO 1;
 IF CUT THEN
 BEGIN
                                  WRITE('              Percent:');IF READPCT(PERCENT) THEN GOTO 1;
 END
 ELSE PERCENT:=0;
 WRITE('Key to Sort by:        ');IF READSTRING(KEY) THEN GOTO 1;
 WRITE('Diagnosis:             ');IF READSTRING(DIAGNOSIS) THEN GOTO 1;
 WRITE(' First Symptoms:       ');IF READSTRING(SYMPTOMS) THEN GOTO 1;
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
 
 
 BEGIN(*  MAIN PROGRAM  *)
 WIPESCREEN;
 WRITE('FILE TITLE:');
 READLN(TITLE);
 (*$I-*)
 RESET(FID,TITLE);
 IF IORESULT<>0 THEN 
 BEGIN
 WRITELN('I am opening a new file: ',TITLE,' because it is not on this disk');
 REWRITE(FID,TITLE);
 END;
 (*$I+*)
 RECNUM:=0;
 WHILE RECNUM>=0 DO
 BEGIN
 WRITELN;
 WRITE('RECORD NUMBER:');
 READLN(RECNUM);
 IF RECNUM>=0 THEN
 BEGIN
 SEEK(FID,RECNUM);
 GET(FID);
 IF EOF(FID) THEN
 BEGIN
 WIPESCREEN;
 WRITELN('ENTER NEW RECORD:');
 ZEROREC(FID^);
 END
 ELSE
 BEGIN
 WIPESCREEN;
 WRITELN('OLD RECORD:');
 SHOWREC(FID^);
 WRITELN;
 WRITELN('ENTER CHANGES:');
 END;
 GETREC(FID^);
 SEEK(FID,RECNUM);
 PUT(FID);
 END; (*  IF RECNUM>=0  *)
 END(*  WHILE  *);
 CLOSE(FID,LOCK);
 END.
                                                                              *)
 END(*  WHILE  *);
 CLOSE(FID,LOCK);
 END.
                                                                           