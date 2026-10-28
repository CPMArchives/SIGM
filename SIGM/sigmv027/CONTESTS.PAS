PROGRAM ATS_MONITOR;
{$I+}
     {This program will act as the user interface to the 
     ATS confidence test programs.  A menu is first displayed
     after which the user is prompt for the tests to be run and
     the repetitions.

     written 9-12-80     d.a. steele
     last update = 20 Feb 81 
     }

CONST
     HEAD_1         =    'ATS Confidence Test   Ver 1.0';
     TMSG_1         =    ' 1. MCP CPU           ';
     TMSG_2         =    ' 2. MCP RAM           ';
     TMSG_3         =    ' 3. Disk Drive System ';
     TMSG_4         =    ' 4. Serial Ports      ';
     TMSG_5         =    ' 5. MCP APU           ';
     TMSG_6         =    ' 6. MCP Data Link     ';
     TMSG_7         =    ' 7. GCP Data Down-load';
     TMSG_8         =    ' 8. Plasma Panel      ';
     TMSG_9         =    ' 9. Touch Panel       ';
     TMSG_10        =    '10. Keyboard          ';
     TMSG_11        =    '11. GCP CPU           ';
     TMSG_12        =    '12. GCP RAM           ';
     TMSG_13        =    '13. GCP EPROM         ';
     TMSG_14        =    '14. GCP APU           ';
     GTEST_MSG      =    'Enter numbers seperated by spaces "0" for all..';
     SPACES         =    '         ';
     NO_OF_TESTS    =    14;
     FAIL_MSG       =    'Failures';
     REP_MSG        =    ' Repetitions';
     SEL_TESTS      =    'Selected tests';
     OKAY           =    'OKAY ?';
     PASS           =    ' Passed';
     FAIL           =    ' Failed';
type
     DEVICE_SET     =    set of char;
VAR
     X,Y            : integer;{used for indexing}
     REPS           : integer;{The number of repatitions to be done}
     REPS_DONE      : integer;{The number of reps that have been completed}
     TEST_ERRORS    : integer;{The error flags returned from test routines}
     TEST_NUM       : integer;
     TEST_FLAGS     : array [1..NO_OF_TESTS] of boolean; {Indicates which 
                                             tests are actually being done}
     FAILURES       : array [1..NO_OF_TESTS] of integer; {A record of the 
                                             number of failures in this 
                                             series of tests}
     ERROR_BITS     : array [1..NO_OF_TESTS] of integer; {The bit corrospondin
                                             to the test failures will be set}
     OUTBIT         : char;{This is the space 1 or 0 to corrospond w/ failures}
     DRIVE          : char;{The selected drive for the disk test to be done on}
     CH             : char;
     CLEAR_SCREEN   : char;{The clear screen command}Š     DEV            : char;{Passes the device for which the bit string is to
                           be written.}
     PRINTER        : text;
     DFILE          : text;
     OUT_FILE       : string 15;
     OUT_DEVICE     : DEVICE_SET;{A set containing all selected output devices}
     SET_OUT_DEVICES: DEVICE_SET;{Set of all possible output devices}

FUNCTION GETCAR :char; external;
FUNCTION CPUTST :integer; external;
FUNCTION DTEST(DRIVE : CHAR) :integer; external;
FUNCTION SERT   :integer; external;
FUNCTION APUT   :integer; external;
FUNCTION LOGIOR(OPER1,OPER2:INTEGER):integer;external;
FUNCTION LOGIAND(OPER1,OPER2:INTEGER):integer;external;
FUNCTION ANDEM  (OPER1,ORER2:INTEGER):boolean;external;
FUNCTION MEMTST :integer; external;
FUNCTION LGCP   :integer; external;
FUNCTION GCPCPU :integer; external;
FUNCTION GCPAPU :integer; external;
FUNCTION GCPMEM :integer; external;
FUNCTION MCPROM: integer;external;
FUNCTION MCPLNK: integer;external;
FUNCTION GCPDWN: integer;external;
FUNCTION PLASMA: integer;external;
FUNCTION TOUCHP: integer;external;
FUNCTION KEYBRD: integer;external;
FUNCTION GCPROM: integer;external;


procedure INITIALIZE;

     {This procedure will initialize the necessary program 
     variables
     }

     begin
     X := LGCP;                    {Load the GCP code}
     if X <> 0 then 
     begin
          writeln('Disk Close Error');
          repeat
          until false
     end;

     CLEAR_SCREEN := chr(12);
          for X := 1 to NO_OF_TESTS do
          begin
               TEST_FLAGS[X] := FALSE;
               FAILURES[X]   := 0;
               ERROR_BITS[x] := 0 
         end;
         
     end; {INITIALIZE}
Šprocedure OPEN_OUT;
     begin
          if 'F' in OUT_DEVICE then     {If they want the desk test then ask  }
          begin                         {for the file name and open that file }
               CH := chr(13);
               writeln(CLEAR_SCREEN);
               writeln('Enter output file');
               readln(OUT_FILE);
               append(OUT_FILE,CH);     {add a carriage return for CP/m}
               rewrite(OUT_FILE,DFILE)
          end;

          if 'P' in OUT_DEVICE then     {If the printer is requested then open}
               rewrite('LST:',PRINTER)  {it as an output device               }

     end {OPEN_OUT};

procedure WRITE_MENU;

     {Writes the test menu onto the display }

     begin
          write(CLEAR_SCREEN);
          writeln(SPACES,SPACES,HEAD_1);
          writeln;
          writeln(SPACES,TMSG_1);
          writeln(SPACES,TMSG_2);
          writeln(SPACES,TMSG_3);
          writeln(SPACES,TMSG_4);
          writeln(SPACES,TMSG_5);
          writeln(SPACES,TMSG_6);
          writeln(SPACES,TMSG_7);
          writeln(SPACES,TMSG_8);
          writeln(SPACES,TMSG_9);
          writeln(SPACES,TMSG_10);
          writeln(SPACES,TMSG_11);
          writeln(SPACES,TMSG_12);
          writeln(SPACES,TMSG_13);
          writeln(SPACES,TMSG_14)
     end; {WRITE_MENU}


procedure SET_FLAG;
     {This will set the flag corrosponding to the test that has been
     requested
     }

     begin

          TEST_FLAGS [TEST_NUM] := TRUE
     
     end; {SET_FLAG}


procedure GET_TEST;Š     {This procedure will prompt the user for the test(s) to be run}

     function VALID :boolean;

          {If the entered number is a valid test number then TRUE is
          returned else FALSE is returned}

          begin
               if (TEST_NUM <= NO_OF_TESTS) and (TEST_NUM >= 1)
               then
                    VALID := TRUE
               else
                    VALID := FALSE;
          end; {VALID}

     procedure ERROR;
          
          {Writes the appropriate error message depending on the input}
          const
               MSG1      =    'The number ';
               MSG2      =    ' is invalid';

          begin
               writeln(MSG1,TEST_NUM:1,MSG2)
          end; {ERROR}


     begin     {main GET TEST procedure}

          write(GTEST_MSG);
          repeat
               read(TEST_NUM);
               if TEST_NUM = 0
               then
                    for X := 1 to NO_OF_TESTS do
                         TEST_FLAGS[X] := TRUE

               else
                    if VALID 
                    then
                         SET_FLAG
                    else
                         ERROR;
          until eoln(0)

     end;{GET TEST}


procedure GET_REPS;
     {Will prompt the user for the number of repetions of the
     tests are to be made.  If '999' is entered then the selected
     tests will continue until the system is reset}
     
     const
          MSG1 = 'Enter Repetitions..';Š
     begin
          write(MSG1);
          readln(REPS)
     end; {GET_REPS}


function  VERIFY :boolean;
     {Will prompt the user to varify the test selection that he
     has made}

     begin
          writeln(CLEAR_SCREEN);
          writeln(SPACES,HEAD_1);
          writeln;
          writeln(SEL_TESTS);
          for X := 1 to NO_OF_TESTS do
               if TEST_FLAGS[X] then
                    case X of
                         1: writeln(TMSG_1);
                         2: writeln(TMSG_2);
                         3: writeln(TMSG_3);
                         4: writeln(TMSG_4);
                         5: writeln(TMSG_5);
                         6: writeln(TMSG_6);
                         7: writeln(TMSG_7);
                         8: writeln(TMSG_8);
                         9: writeln(TMSG_9);
                         10: writeln(TMSG_10);
                         11: writeln(TMSG_11);
                         12: writeln(TMSG_12);
                         13: writeln(TMSG_13);
                         14: writeln(TMSG_14)
                    end;
          writeln;
          writeln(REP_MSG,REPS);

          writeln; writeln;

          write('Output to ');
               if 'P' in OUT_DEVICE then
                    write('Printer - ');

               if 'C' in OUT_DEVICE then
                    write('Console - ');

               if 'F' in OUT_DEVICE then
                    write('Disk file ',OUT_FILE);

               writeln;

          if TEST_FLAGS[3] then
               writeln('Testing drive ',DRIVE);

          writeln;Š          writeln(OKAY);

          CH := GETCAR;

          if (CH = 'y') or( CH = 'Y')
          then
               VERIFY := TRUE
          else
               VERIFY := FALSE


     end; {VERIFY}

procedure GET_DEVICE;
     {This procedure will prompt the user for the output devices
     to be used. P-printer C-console F-disk file
     }

begin
     SET_OUT_DEVICE := ['f','F','c','C','P','p'];
     OUT_DEVICE := [];
     write('Enter P(rinter C(onsole F(ile..');
     repeat
          CH := GETCAR;
          if CH in SET_OUT_DEVICE then
          begin
               if ord(CH) > 91 then     {if it is lower case }
               begin                    {change to upper     }
                    X := ord(CH);
                    CH := chr(X-32)
               end;

               OUT_DEVICE := OUT_DEVICE + [CH]
          end;
     until CH = chr(13);
     if OUT_DEVICE = [] then
          OUT_DEVICE := ['C'];     {defult to console}
     writeln
end;
procedure GET_DRIVE;

     type     DRV_SET    =    set of char;
     
     var      VALID_DRIVES : DRV_SET;

     begin
          VALID_DRIVES := ['a','A','B','b'];

          if TEST_FLAGS[3] then    {if he wants the desk test then}
          begin                    {get the drive name}
               write('Enter Drive To Test..'); 
               repeat
                    DRIVE := GETCAR;
               until DRIVE in VALID_DRIVES
          endŠ     end;


procedure BITTER (ERROR_BITS :integer) ;
          {This procedure will print out ones or zeros corrosponding
          with the bits which are set in the ERROR_BITS.  These bits
          should then corrospond to the tests which failed with '1'
          indicating a failed test                                  }

     var
          MASK      : integer;

     begin
          MASK := LOGIAND(-32767,-2);   {Set the high bit of the mask}
          OUTBIT := ' ';

          repeat
               if ANDEM(ERROR_BIT,MASK) then {If the error bit is set then    }
                    OUTBIT := '1';           {set the char. to be output to   }
                                             {a 1.                            }
               if DEV = 'P' then             {Now output to all devices       }
                    write (PRINTER, OUTBIT); {for which output has been       }
                                             {requested.                      }
               if DEV = 'C' then
                    write (OUTBIT);

               if DEV = 'F' then
                    write(DFILE,OUTBIT);

               if OUTBIT = '1' then          {Reset the output char so we     }
                    OUTBIT := '0';           {don't show the next test failed }
                                             {also.                           }
               if MASK = LOGIAND(-32767,-2) then{Sence this is 2'sC arithmetic}
                    MASK := 16384            {it won't work to just devide    }
               else                          {to shift the high bit.          }
                    MASK := MASK div 2;      {Shift right the mask            }

          until MASK = 0                     {If it's zero then we are done   }
     end;


procedure CON_WRITE;
     
begin
          DEV := 'C';

          if x = 1 then
               writeln(REPS_DONE:1,REP_MSG,SPACES,SPACES,FAIL_MSG);
                         
          if TEST_FLAGS[X] then
               case X of
                    1: begin
                       write(TMSG_1,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writelnŠ                      end;

                    2: begin
                       write(TMSG_2,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writeln
                      end;

                    3: begin
                       write(TMSG_3,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writeln
                      end;

                    4: begin
                       write(TMSG_4,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writeln
                      end;

                    5: begin
                       write(TMSG_5,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writeln
                      end;

                    6: begin
                       write(TMSG_6,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writeln
                      end;

                    7: begin
                       write(TMSG_7,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writeln
                      end;

                    8: begin
                       write(TMSG_8,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writeln
                      end;

                    9: begin
                       write(TMSG_9,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writeln
                      end;

                    10: begin
                       write(TMSG_10,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writeln
                      end;Š
                    11: begin
                       write(TMSG_11,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writeln
                      end;
                    12: begin
                       write(TMSG_12,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writeln
                      end;
                    13: begin
                       write(TMSG_13,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writeln
                      end;
                    14: begin
                       write(TMSG_14,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writeln
                      end
               end
end;


procedure DSK_WRITE;

begin
          DEV := 'F';

          if x = 1 then
           writeln(DFILE,REPS_DONE:1,REP_MSG,SPACES,SPACES,FAIL_MSG);

          if TEST_FLAGS[X] then
               case X of
                    1: begin
                       write(DFILE,TMSG_1,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writeln(DFILE)
                      end;

                    2: begin
                       write(DFILE,TMSG_2,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writeln(DFILE)
                      end;

                    3: begin
                       write(DFILE,TMSG_3,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writeln(DFILE)
                      end;

                    4: begin
                       write(DFILE,TMSG_4,FAILURES[X],SPACES);Š                       BITTER(ERROR_BITS[X]);
                       writeln(DFILE)
                      end;

                    5: begin
                       write(DFILE,TMSG_5,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writeln(DFILE)
                      end;

                    6: begin
                       write(DFILE,TMSG_6,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writeln(DFILE)
                      end;

                    7: begin
                       write(DFILE,TMSG_7,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writeln(DFILE)
                      end;

                    8: begin
                       write(DFILE,TMSG_8,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writeln(DFILE)
                      end;

                    9: begin
                       write(DFILE,TMSG_9,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writeln(DFILE)
                      end;

                    10: begin
                       write(DFILE,TMSG_10,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writeln(DFILE)
                      end;

                    11: begin
                       write(DFILE,TMSG_11,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writeln(DFILE)
                      end;
                    12: begin
                       write(DFILE,TMSG_12,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writeln(DFILE)
                      end;
                    13: begin
                       write(DFILE,TMSG_13,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writeln(DFILE)
                      end;Š                    14: begin
                       write(DFILE,TMSG_14,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writeln(DFILE)
                      end

               end
end;


procedure LST_WRITE;

begin
          DEV := 'P';
          if x = 1 then
            writeln(PRINTER,REPS_DONE:1,REP_MSG,SPACES,SPACES,FAIL_MSG);
     
          if TEST_FLAGS[X] then
               case X of
                    1: begin
                       write(PRINTER,TMSG_1,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writeln(PRINTER)
                      end;

                    2: begin
                       write(PRINTER,TMSG_2,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writeln(PRINTER)
                      end;

                    3: begin
                       write(PRINTER,TMSG_3,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writeln(PRINTER)
                      end;

                    4: begin
                       write(PRINTER,TMSG_4,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writeln(PRINTER)
                      end;

                    5: begin
                       write(PRINTER,TMSG_5,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writeln(PRINTER)
                      end;

                    6: begin
                       write(PRINTER,TMSG_6,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writeln(PRINTER)
                      end;
Š                    7: begin
                       write(PRINTER,TMSG_7,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writeln(PRINTER)
                      end;

                    8: begin
                       write(PRINTER,TMSG_8,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writeln(PRINTER)
                      end;

                    9: begin
                       write(PRINTER,TMSG_9,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writeln(PRINTER)
                      end;

                    10: begin
                       write(PRINTER,TMSG_10,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writeln(PRINTER)
                      end;

                    11: begin
                       write(PRINTER,TMSG_11,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writeln(PRINTER)
                      end;
                    12: begin
                       write(PRINTER,TMSG_12,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writeln(PRINTER)
                      end;
                    13: begin
                       write(PRINTER,TMSG_13,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writeln(PRINTER)
                      end;
                    14: begin
                       write(PRINTER,TMSG_14,FAILURES[X],SPACES);
                       BITTER(ERROR_BITS[X]);
                       writeln(PRINTER)
                      end

               end
end;


procedure PRINT_FAILURES;
     {At the end of eavh series of tests this procedure will be
     called to print a summary of all failures that have occured
     since this test cycle was started}

     beginŠ          writeln(CLEAR_SCREEN);

          writeln(HEAD_1);


          for X := 1 to NO_OF_TESTS do
          begin
               if 'P' in OUT_DEVICE then
                    LST_WRITE;
               if 'C' in OUT_DEVICE then
                    CON_WRITE;
               if 'F' in OUT_DEVICE then
                    DSK_WRITE
          end

     end;{PRINT FAILURES}


procedure DOHEAD;
     begin
          writeln(CLEAR_SCREEN);
          writeln(HEAD_1);
          writeln
     end;

procedure TEST_1;
     begin
          write('test 1 ');
          if CPUTST <> 0 then
               FAILURES[1] := FAILURES[1] + 1;
          writeln
     end;

procedure TEST_2;
     begin
          write('test 2');
          TEST_ERRORS := MEMTST;
          if TEST_ERRORS <> 0 then
          begin
               FAILURES[2] := FAILURES[2] +1;
               ERROR_BITS[2] := LOGIOR(ERROR_BITS[2], TEST_ERRORS)
          end;
          writeln
     end;

procedure TEST_3;

     const
          TMSG_3    =    'test 3';
          
     begin
          writeln(TMSG_3);
          TEST_ERRORS := DTEST(DRIVE);

          if TEST_ERRORS <> 0 thenŠ          begin
               FAILURES[3] := FAILURES[3]+1;
          end
     end;

procedure TEST_4;

     const
          T1_MSG    =    'Uart 0 test';
          T2_MSG    =    'Uart 1 test';
          TMSG_4    =    'test 4';

     begin
          writeln(TMSG_4);
          TEST_ERRORS := SERT;

          if TEST_ERRORS <> 0 then
               begin
                    FAILURES[4] := FAILURES[4] + 1;
                    ERROR_BITS[4] := LOGIOR(ERROR_BITS[4] ,TEST_ERRORS);

                    if ANDEM(TEST_ERRORS,1) then
                         writeln(SPACES,T1_MSG,FAIL);
                    if ANDEM(TEST_ERRORS,1) then
                         writeln(SPACES,T2_MSG,FAIL);

                    for x := 0 to 10000 do {delay}
               end
     end;

procedure TEST_5;

     const
          T1_MSG    =    'APU BUS Error Test';
          T2_MSG    =    'APU Stack Test';
          T3_MSG    =    'DADD Test';
          T4_MSG    =    'DSUB Test';
          T5_MSG    =    'DMUL and DDIV Test';
          T6_MSG    =    'Skip busy bit test';
          T7_MSG    =    '16 bit Arithmatic Test';
          T8_MSG    =    'Misc. Function Test';
          T9_MSG    =    'No busy bit !! TEST ABORTED !!';


     begin
          write('test 5');
          TEST_ERRORS := APUT;

          if TEST_ERRORS <> 0 then
               begin
                    FAILURES[5] := FAILURES[5] +1;
                    ERROR_BITS[5] := LOGIOR(ERROR_BITS[5], TEST_ERRORS);

                    if ANDEM(TEST_ERRORS , 1) then
                         writeln(SPACES,T1_MSG,FAIL);Š                    if ANDEM(TEST_ERRORS , 2) then
                         writeln(SPACES,T2_MSG,FAIL);
                    if ANDEM(TEST_ERRORS , 3) then
                         writeln(SPACES,T3_MSG,FAIL);
                    if ANDEM(TEST_ERRORS , 8) then
                         writeln(SPACES,T4_MSG,FAIL);
                    if ANDEM(TEST_ERRORS , 16) then
                         writeln(SPACES,T5_MSG,FAIL);
                    if ANDEM(TEST_ERRORS , 32) then
                         writeln(SPACES,T6_MSG,FAIL);
                    if ANDEM(TEST_ERRORS , 64) then
                         writeln(SPACES,T7_MSG,FAIL);
                    if ANDEM(TEST_ERRORS , 128) then
                         writeln(SPACES,T8_MSG,FAIL);
                    if ANDEM(TEST_ERRORS , 256) then
                         writeln(SPACES,T9_MSG,FAIL);

                    for X := 0 to 10000 do {DELAY}
               end;
               writeln
       end;


procedure TEST_6;   {mcplnk}
     begin
          write('test 6');
          TEST_ERRORS := MCPLNK;
          if TEST_ERRORS <> 0 then
          begin
               FAILURES[6] := FAILURES[6] + 1;
               ERROR_BITS[6] := LOGIOR(ERROR_BITS[6],TEST_ERRORS)
          end;
          writeln
     end;

procedure TEST_7;   {gcpdwn}
     begin
          write('test 7');
          TEST_ERRORS := GCPDWN;
          if TEST_ERRORS <> 0 then
          begin
               FAILURES[7] := FAILURES[7] + 1;
               ERROR_BITS[7] := LOGIOR(ERROR_BITS[7],TEST_ERRORS)
          end;
          writeln
     end;

procedure TEST_8;   {plasma}
     begin
          write('test 8');
          TEST_ERRORS := PLASMA;
          if TEST_ERRORS <> 0 then
          begin
               FAILURES[8] := FAILURES[8] + 1;
               ERROR_BITS[8] := LOGIOR(ERROR_BITS[8],TEST_ERRORS)Š          end;
          writeln
     end;

procedure TEST_9;  {touchp}
     begin
          write('test 9');
          TEST_ERRORS := TOUCHP;
          if TEST_ERRORS <> 0 then
          begin
               FAILURES[9] := FAILURES[9] + 1;
               ERROR_BITS[9] := LOGIOR(ERROR_BITS[9],TEST_ERRORS)
          end;
          writeln
     end;

procedure TEST_10;  {keyboard}
     begin
          write('test 10');
          TEST_ERRORS := KEYBRD;
          if TEST_ERRORS <> 0 then
          begin
               FAILURES[10] := FAILURES[10] + 1;
               ERROR_BITS[10] := LOGIOR(ERROR_BITS[10],TEST_ERRORS)
          end;
          writeln
     end;

procedure TEST_11;
     begin
          write('test 11');
          TEST_ERRORS := GCPCPU;
          if TEST_ERRORS <> 0 then
          begin
               FAILURES[11] := FAILURES[11] + 1;
               ERROR_BITS[11] := LOGIOR(ERROR_BITS[11],TEST_ERRORS)
          end;
          writeln
     end;

procedure TEST_12;
     begin
          write('test 12');
          TEST_ERRORS := GCPMEM;
          if TEST_ERRORS <> 0 then
          begin
               FAILURES[12] := FAILURES[12] + 1;
               ERROR_BITS[12] := LOGIOR(ERROR_BITS[12],TEST_ERRORS)
          end;
          writeln
     end;

procedure TEST_13;
     begin
          write('test 13');Š          TEST_ERRORS := GCPROM;
          if TEST_ERRORS <> 0 then
          begin
               FAILURES[13] := FAILURES[13] + 1;
               ERROR_BITS[13] := LOGIOR(ERROR_BITS[13],TEST_ERRORS)
          end;
          writeln
     end;

procedure TEST_14;
     begin
          write('test 14');
          TEST_ERRORS := GCPAPU;
          if TEST_ERRORS <> 0 then
          begin
               FAILURES[14] := FAILURES[14] + 1;
               ERROR_BITS[14] := LOGIOR(ERROR_BITS[14],TEST_ERRORS)
          end;
          writeln
     end;
{---------------------------------------------------------------}
{    begin main program ATS MONITOR                             }
     begin
          repeat
               INITIALIZE;
               WRITE_MENU;
               GET_TEST;
               GET_REPS;
               GET_DEVICE;
               OPEN_OUT;
               GET_DRIVE;
          until VERIFY;
     
          REPS_DONE := 0;

          repeat
               DOHEAD;
               for X := 1 to NO_OF_TESTS do
                    if TEST_FLAGS[X] then
                         case X of
                              1: TEST_1;
                              2: TEST_2;
                              3: TEST_3;
                              4: TEST_4;
                              5: TEST_5;
                              6: TEST_6;
                              7: TEST_7;
                              8: TEST_8;
                              9: TEST_9;
                              10: TEST_10;
                              11: TEST_11;
                              12: TEST_12;
                              13: TEST_13;
                              14: TEST_14
                         end;{case}Š
                    REPS_DONE := REPS_DONE+1;
               PRINT_FAILURES;
               for X := 1 to 10000 do
                    Y := X;

          until (REPS_DONE = REPS) and (REPS <> 999)
     end.

