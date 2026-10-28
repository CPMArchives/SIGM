.fo Section 8 - Command Files                          Page   #

8.0  Command Files

8.1  Command File Processing

     Á Commanä Filå ió á filå containinç commands¬  witè optionaì 
parameteò  substitution¬  whicè caî bå executeä bù ZCPR2®   Theså 
commandó  arå  exactlù thå samå kindó oæ commandó  aó  yoõ  woulä 
issuå  aô  thå console¬  anä anù commanä yoõ caî issuå  froí  thå 
consolå  caî  bå issueä froí withiî á Commanä Filå (witè  jusô  á 
couple of restrictions).

     Thå  Commanä Filå Facilitieó oæ SUB² anä ZEØ  arå  availablå 
undeò ZCPR2®   Similaò iî concepô tï thå SUBMIÔ facilitù oæ CP/M¬ 
botè  SUB² anä ZEØ arå upward-compatablå tï SUBMIÔ (anù SUÂ  filå 
caî ruî undeò theí witè fe÷ restrictions).

     Botè  SUB²  anä  ZEØ  begiî processinç  bù  translatinç  thå 
commanä fileó theù arå giveî intï slightlù differenô forms®  Botè 
dï parameteò substitution¬ extractinç parameteró froí thå commanä 
lineó  anä placinç theí intï thå texô oæ thå commanä streaí  theù 
arå building®   SUB² buildó thå commanä streaí tï bå executeä  oî 
disë  drivå Á undeò thå currenô useò number¬  anä ZEØ buildó  thå 
commanä streaí iî memory.

     Aó  thå useò caî guess¬  ZEØ ió generallù preferreä tï SUB2®  
Undeò ZEX¬  thå commanä streaí ió executeä mucè morå quicklù thaî 
undeò SUB² sincå ZEØ jusô goeó intï memorù foò thå nexô characteò 
whilå ZCPR² haó tï gï tï disk®  ZEX¬ however¬ doeó takå uğ memorù 
space¬ anä thaô ió itó maiî drawback®  Thå TPÁ (Transienô Prograí 
Area©  undeò  ZEØ ió smalleò thaî whaô ió  availablå  tï  commanä 
fileó  runninç undeò SUB2®   Thió ió youò basiã trade-ofæ betweeî 
thå twï Commanä Filå Processors.

     Anotheò differencå betweeî SUB² anä ZEØ ió thaô SUB² commanä 
streamó arå line-orienteä anä extracteä onlù bù ZCPR2®   Thaô is¬ 
SUB²  buildó á commanä filå nameä $$$.SUÂ likå SUBMIÔ  does¬  anä 
ZCPR²  extractó  á  linå froí thå $$$.SUÂ filå eacè  timå  iô  ió 
entered®  Wheî ZCPR² ió entereä bù eitheò á Colä Boot¬ Warí Boot¬ 
oò  simplå RETurî froí á loadeä program¬  iô checkó thå  Multiplå 
Commanä Linå Buffeò foò á pendinç command®   Iæ iô findó  it¬  iô 
executeó it®  Iæ not¬ iô checkó thå Aº drivå (currenô user© foò á 
$$$.SUÂ  file®   Iæ iô findó one¬  iô extractó thå nexô linå froí 
thå $$$.SUÂ file¬  processeó it¬  anä beginó executioî oæ iô froí 
thå Multiplå Commanä Linå Buffer®   Finally¬  iæ thå $$$.SUÂ filå 
is not found, ZCPR2 prompts the user for input.

     Thaô  ió  ho÷  commanä  streaí  processinç  undeò  SUB²   ió 
performed®  ZEX¬ however¬ actó aó á combinatioî oæ SUB² anä XSUB®  
Oncå commanä streaí processinç beginó undeò ZEX¬ thå ZEØ monitor¬ 
locateä undeò ZCPR² witè thå associateä commanä stream¬  supplieó 
á  characteò eacè timå thå BIOÓ Consolå Inpuô Routinå ió  called®  
ZEØ extractó thå nexô characteò froí thå commanä stream¬ examineó 
iô  tï  seå  iæ iô ió á ZEØ commanä anä executeó iô  iæ  so¬  anä 
returns it to the calling program if it is not a ZEX command.Š
     Hence¬  ZCPR²  itselæ doeó noô realizå thaô ZEØ ió  running®  
Neitheò  dï  thå  transienô  programó  iî  general®   ZEØ  simplù 
interceptó alì calló tï thå BIOÓ Consolå Inpuô (anä Inpuô Status© 
routinå anä provideó aî inpuô characteò iî itó place®   Therå arå 
exceptions to this case, but they will be discussed later.

     Botè SUB² anä ZEØ fiô intï thå ZCPR² Systeí nicely¬ anä theù 
caî  bå  useä tï acô aó Extendeä Commanä Processoró  iæ  desired®  
This is discussed later.



8.2  Disk-Based Command Files -- SUB2

     SUB2¬  commonlù  calleä  SUB¬  ió  invokeä  bù  onå  oæ  thå 
following command lines:

          SUB or SUB //            <-- Print Help Message
          SUB /A Text              <-- Abort $$$.SUB File
                                        Processing at User's
                                        Discretion
          SUB /AB Text             <-- Same as /A but Ring Bell
                                        to Alert User
          SUB /D commands          <-- Perform Commands following
                                        the /D
          SUB /I                   <-- Enter Interactive Input
                                        Mode
          SUB filename params      <-- As in Standard SUBMIT


     Thå  "SUÂ  /A¢  anä  "SUÂ  /AB¢  formó  allo÷  thå  useò  tï 
gracefullù  aborô á $$$.SUÂ file®   ^Ã aô thå consolå caî bå useä 
tï  aborô sucè processinç aó undeò CP/M¬  buô thå /Á forí  allowó 
thå  luxurù  oæ  startinç  á commanä streaí  anä  stoppinç  aô  á 
criticaì poinô tï allo÷ thå useò tï takå hió time¬  inspecô  whaô 
haó happened¬ anä theî decidå whetheò tï proceeä oò not.

     Thå  "SUÂ  /D¢  forí  haó  littlå  utilitù  undeò  á  fully-
implementeä  ZCPR²  System®   Yoõ caî obtaiî á betteò  effecô  bù 
simplù  issuinç  á  conventionaì ZCPR² commanä  stream®   Thå  /Ä 
optioî  ió  gooä onlù iî environó whicè dï noô  supporô  multiplå 
commands.

     Thå "SUÂ /I¢ forí eliminateó thå neeä foò thå useò tï uså aî 
editoò tï creatå á .SUÂ file®   Iæ thå useò haó á commanä  streaí 
hå  wantó tï executå immediatelù anä doesn'ô carå tï dï iô again¬ 
hå caî uså thió option®   Iî response¬  SUB² allowó hií tï  enteò 
hió  commanä  streaí (sorry¬  nï parameteò passing© á linå  aô  á 
time®   Wheî  iô ió alì entereä (useò enteró aî emptù line)¬  thå 
$$$.SUÂ filå ió builô anä executed.


     Thå finaì form¬  "SUÂ filenamå params"¬ ió identicaì iî forí 
tï  thå  SUBMIÔ  commanä  supplieä  witè  CP/M®   Thå  "filename¢ 
specifieó  thå  namå  oæ thå .SUÂ filå tï bå  executed¬  anä  thå 
parameteró arå associateä witè thå substitutioî variableó oæ  $1¬ 
$2¬  etc®   Uğ  tï 2° parameteró maù bå specified®   Thå sequencå 
"$$¢  placeó  á  "$¢ intï thå commanä  line¬  anä  thå  characteò 
sequencå  "^c¢  placeó thå indicateä controì characteò  intï  thå 
commanä linå (uparro÷ Ã placeó Control-C).

     Thå  SUB² commanä maù bå nesteä intï á $$$.SUÂ file®   Iæ  á 
"SUÂ  filenamå params¢ commanä ió encountereä iî á $$$.SUÂ  file¬ 
SUB²  runs¬  realizeó  thaô thió haó happened¬  anä  insertó  thå 
indicateä  commanä file¬  witè parameteò substitution¬  intï  thå 
runninç  commanä  streaí aô thå appropriatå place®   Thió maù  bå 
nesteä aó manù leveló deeğ aó desired.

     Undeò ZCPR2¬  iæ SUB² ió executeä witè thå Multiplå  Commanä 
Linå  Facilitù invokeä anä morå commandó follo÷ thå SUB² command¬ 
theî thå resô oæ thå Multiplå Commanä Linå ió inserteä aô thå enä 
of the generated $$$.SUB file.

     Finally¬  SUB² followó thå ZCPR² patè wheî searchinç foò thå 
indicateä  commanä file®   Iô ió fullù integrateä intï thå  ZCPR² 
Systeí  anä  ió  ablå tï emploù thå Externaì  Patè  anä  Multiplå 
Command Line Buffer features of ZCPR2.



8.3  SUB2 Error Messages

     SUB²  provideó  á numbeò oæ informativå diagnosticó  tï  thå 
user®   Iî particular¬  wheî processinç á Commanä File¬  wheî  aî 
erroò ió encountered¬ thå useò ió informeä oæ thå linå numbeò thå 
error occurs at.

     Thå  followinç  summarizeó thå erroò messageó  presenteä  bù 
SUB2:

          Disk Full
               There is no room to write the $$$.SUB file

          Directory Full
               There is no directory space for the $$$.SUB file

          Memory Full
               There is not enough memory in which to build the
               command stream to be placed into the $$$.SUB file

          SUBMIT File Not Found
               The .SUB file specified in the command line could
               not be found along the ZCPR2 path


          Parameter
               Invalid Parameter Specified

          Too Many Parameters
               More than 20 parameters were on the command line

          Line too Long
               The current line in the command stream exceeds
               128 bytes

          SUBMIT File Empty
               The .SUB file specified in the command line was
               found to be empty

          Control Character
               The ^c form was not followed by a letter A-Z



8.4  SUB2 Command Summary

     The following are valid SUB2 command line forms:

          SUB or SUB //            <-- Print Help Message

          SUB /A Text              <-- Abort $$$.SUB File
                                        Processing at User's
                                        Discretion

          SUB /AB Text             <-- Same as /A but Ring Bell
                                        to Alert User

          SUB /D commands          <-- Perform Commands following
                                        the /D

          SUB /I                   <-- Enter Interactive Input
                                        Mode

          SUB filename params      <-- As in Standard SUBMIT



8.5  Memory-Based Command Files -- ZEX

     Thå  Memory-Baseä Commanä Filå Processoò oæ ZCPR2¬  ZEX¬  ió 
invoked by the following forms:

          ZEX //                   <-- Print Help

          ZEX                      <-- Enter Interactive Mode

          ZEX filename params      <-- Process .ZEX or .SUB
                                        file as with SUBMIT
Š
     Thå  Interactivå Modå oæ ZEØ executeó likå  thå  Interactivå 
Modå  oæ  SUB2®   Thå  useò  enteró commanä  lineó  untiì  hå  ió 
satisfieä  anä  theî terminateó thå procesó bù enterinç aî  emptù 
linå (simplù hittinç RETURN)®   ZEØ theî executeó thå commandó iî 
thå sequencå entered®   Nï parameteò passinç ió permitteä iî thió 
mode of operation.

     Thå  "ZEØ  filenamå params¢ forí ió likå  thå  correspondinç 
SUB² form®   ZEØ wilì searcè alonç thå ZCPR² Externaì Patè foò  á 
commanä  filå  oæ thå forí filename.ZEØ oò  filename.SUB®   Iæ  á 
directorù ió entereä whicè containó botè sucè files¬  thå filå oæ 
type ZEX will be executed.

     Oncå  ZEØ haó beguî execution¬  iô placeó á ZEØ Monitoò jusô 
undeò  ZCPR²  anä buildó thå commanä streaí  undeò  thå  monitor®  
Oncå  complete¬  thå addresó oæ thå BDOÓ ió adjusteä sï thaô  thå 
ZEØ  monitoò  anä itó commanä streaí wilì noô bå  overwritteî  bù 
transienô  programs¬  anä executioî begins®   Eacè timå thå  BIOÓ 
Consolå   Inpuô  routinå  ió  called¬   ZEØ  supplieó  thå  inpuô 
character.

     Aó witè SUB2¬  á ^Ã froí thå consolå wilì aborô executioî oæ 
á ZEØ commanä stream®   Also¬  aó witè SUB2¬ iæ á commanä followó 
ZEØ  iî á Multiplå Commanä Line¬  ZEØ appendó thió commanä tï thå 
command stream.

     Unlikå SUB2¬  ZEØ doeó noô permiô nestinç oæ commanä  files®  
ZEØ  wilì  simplù  aborô iæ á ZEØ commanä ió encountereä  iî  thå 
commanä streaí iô ió processing.

     Unlikå  SUB2¬  ZEØ  supportó manù  morå  embeddeä  commands®  
Combininç  thå  facilitieó  oæ SUB² anä XSUÂ iî  thió  case¬  thå 
embeddeä  commandó oæ ZEØ reflecô thå XSUB-likå  capabilitieó  oæ 
ZEØ aó welì aó somå ne÷ ideas.

     Theså  extendeä  controì commandó arå discusseä iî thå  nexô 
information section.



8.6  ZEX Control Commands

     The following summarizes the ZEX Control Commands:

          Cmd  Meaning                Cmd  Meaning
           |   insert <CR>            ^|   insert <CRLF>
          ^º   reruî commanä streaí   ^®   togglå prinô suppress
          ^#   toggle ZEX messages    ^$   define default params
          ^?   wait for user input    ^/   ring bell and ^?
          ^*   ring bell              ^"   accept user input
          ^<   display chars only     ^>   stop display
          ;;   ZEX comment            $n   1<=n<=9 for param
          $$   $                      $^   ^
          $|   |                      ^c   control charŠ
     This summary is also displayed via the built-in ZEX help.

     Thå followinç commandó simplù inserô characteró intï thå ZEØ 
command stream and will not be discussed in any greater detail.

          | inserts a <CR>         ^| inserts a <CR> <LF> pair
          $$ inserts a single $    $^ inserts a single ^
          $| inserts a single |    ^c inserts a control character

     Thå ^ª commanä simplù causeó ZEØ tï rinç thå bell®   Iô doeó 
noô  inserô  á  BELÌ characteò intï thå commanä filå  likå  á  ^Ç 
sequencå   would®    Iô  simplù  ringó  thå  belì  anä  continueó 
processing.

     Thå  ;»  commanä  ió á ZEØ comment®   Iô anä alì  characteró 
followinç  iô  uğ  tï anä includinç thå followinç  <LF¾  arå  noô 
includeä iî thå ZEØ commanä stream®  Theù arå simplù treateä aó á 
commenô  iî  thå  ZEØ  Commanä  Filå  anä  ignored®    Unlikå   á 
conventionaì  ZCPR²  comment¬  thå ZEØ commenô doeó noô  takå  uğ 
spacå  iî thå commanä streaí anä doeó noô appeaò wheî thå commanä 
stream is executed.

     Thå ^¼ anä ^¾ commandó arå useä tï brackeô characteró  whicè 
arå  simplù echoeä bù thå ZEØ monitoò anä noô passeä bacë tï  thå 
callinç  program®   Thió  causeó  thå  characteró  betweeî  theså 
commandó  tï  bå  echoeä  tï thå useò durinç  executioî  buô  noô 
processeä  bù  anù  program®   Thió  featurå  ió  verù  gooä  foò 
embeddinç  commentó  tï  bå printeä aô executioî  timå  intï  thå 
commanä stream®   Unlikå thå ZCPR² commenô form¬  whicè ió á linå 
beginninç  witè á semicolon¬  commentó encloseä bù ^¼ anä ^¾  maù 
appeaò anywhere¬ sucè aó withiî aî editoò session.

     Thå  ^£ commanä toggleó suppressioî oæ informativå  messageó 
generated by ZEX.

     Thå ^® commanä causeó consolå outpuô tï ceaså untiì thå nexô 
^®   ió  encountered®   Characteò  inpuô  froí  thå  ZEØ  Monitoò 
continues¬ buô thå useò doeó noô seå whaô iô is.

     Thå ^º  commanä causeó thå ZEØ monitoò tï restarô  executioî 
oæ  thå  loadeä commanä stream®   Thå entirå commanä  stream¬  aó 
initiallù processeä bù ZEX¬ ió executeä agaiî froí thå beginning.

     $n¬  wherå  1<=n<=9¬  wilì causå thå indicateä specifieä  oò 
default parameter to be substituted from the command line.

     Thå  ^¤  commanä  ió useä tï definå oò redefinå thå  seô  oæ 
inpuô commanä parameters®   Thå resô oæ thå linå followinç thå ^¤ 
ió treateä aó á seô oæ parameteró separateä bù blanks.


     Thå  ^¿  anä ^¯ commandó replacå thå /Á anä /AÂ  optionó  oæ 
SUB2®   ^¿ causeó ZEØ tï stoğ processinç anä waiô foò thå useò tï 
strikå  eitheò thå spacå baò oò thå RETURÎ keù beforå continuing®  
Thå useò caî takå hió timå anä examinå thå display¬  and¬  iæ  hå 
doeó  noô wisè tï continue¬  á ^Ã wilì aborô thå commanä  stream®  
Thå ^¯ commanä ió likå ^?¬  buô iô periodicallù ringó thå belì aô 
the console, summoning the user in an alarm fashion.

     Finally¬  thå  ^¢ commanä causeó ZEØ tï stoğ providinç inpuô 
froí  thå commanä streaí anä allo÷ thå useò tï inpuô whateveò  hå 
wisheó  untiì á speciaì characteò ió output¬  aô whicè  timå  ZEØ 
wilì resumå providinç input®  Iî thió case¬ ZEØ caî bå intimatelù 
linkeä witè ZCPR2¬  anä iô ió intendeä thaô thå speciaì characteò 
thaô ZEØ ió waitinç foò ió associateä witè thå ZCPR² prompt®   Iî 
mù  case¬  É madå thå ZCPR² prompô tï bå á ">¢ characteò witè thå 
mosô significanô biô set®   Thió ió uniquå anä appearó onlù  wheî 
the prompt comes up on my system.

     No÷  thaô  É  havå  beateî thå subjecô oæ  thå  ZEØ  Controì 
Commandó tï death¬ thå followinç exampleó illustratå applicationó 
employinç them®   Mù commentó appeaò ouô tï thå side¬ prefixeä bù 
<--.


B1>zex
ZEX, Version 1.3
1: ^$ this is fun                  <-- I Define 3 params
2: echo $1 $2 $3
3: ^$ hello from happy acres       <-- I Define 4 params
4: echo $1 $2 $3 $4
5: 
(ZEX Active)                       <-- ZEX is running now
B1>echo this is fun

THIS IS FUN
B1>echo hello from happy acres

HELLO FROM HAPPY ACRES
B1>
(ZEX Completed)
By Your Command >


B1>ed demo.zex                     <-- Demo Command File

NEW FILE
     : *i
    1:  ed demo.txt                <-- Edit DEMO.TXT
    2:  i                          <-- Insert text while in ED
    3:  This is a test
    4:  This is only a test
    5:  This is a demo of ZEX Control
    6:  ^Z                         <-- ^Z is 2 chars, xlated into
    7:  b0lt                       <-- Ctrl-Z by ZEX
    8:  1l
    9:  0lt
   10:  i                          <-- Input More Text
   11:  ^"                         <-- I now input text myself
   12:  type demo.txt              <-- When ZEX continues, this
   13:  era demo.txt               <--  is what it does next
   14:  
     : *e

B1>zex demo                        <-- Run the command file
ZEX, Version 1.3
(ZEX Active)
B1>ed demo.txt

NEW FILE
     : *i                          <-- ZEX is typing this in
    1:  This is a test
    2:  This is only a test
    3:  This is a demo of ZEX Control
    4:  
     : *b0lt
    1:  This is a test
    1: *1l
    2: *0lt
    2:  This is only a test
    2: *i                          <-- Now my input begins
    2:  I am now typing this line of my own volition   <-- I type
    3:  ZEX will allow me to continue doing this until
    4:  it sees the ZCPR2 prompt
    5:                                  <-- I type Ctrl-Z
    5: *e                               <-- I type "e"

(ZEX Active)
B1>type demo.txt                        <-- ZEX resumes
This is a test
I am now typing this line of my own volition
ZEX will allow me to continue doing this until
it sees the ZCPR2 prompt
This is only a test
This is a demo of ZEX Control


B1>era demo.txt
DEMO    .TXT
B1>
(ZEX Completed)
By Your Command >
B1>ed demo.mac                     <-- Now to use ZEX for
                                   <--  program assembly
NEW FILE
     : *i                          <-- I type program
    1:          ext     print
    2:  
    3:          call    print
    4:          db      'Hello, World ... It''s Another Day',0
    5:          ret
    6:  
    7:          end
    8:  
     : *e

B1>type a:m80.zex                  <-- My M80.ZEX command file
;  M80.SUB -- MACRO-80 Assembler and Linker
M80 =$1
;  Please Type $^C if Error(s) Exist - ^?
ERA $1.BAK
ERA $1.COM
L80 /P:100,$1,A:SYSLIB/S,$1/N,/U,/E
ERA $1.REL
;  Assembly Complete

B1>zex m80 demo                    <-- Run command file on my pgm
ZEX, Version 1.3
(ZEX Active)
B1>;  M80.SUB -- MACRO-80 Assembler and Linker
B1>M80 =DEMO

No Fatal errr(s)

(ZEX Active)
B1>;  Please Type ^C if Error(s) Exist -     <-- I can abort now
                                             <--  if I wish
B1>ERA DEMO.BAK
DEMO    .BAK
B1>ERA DEMO.COM
No File


B1>L80 /P:100,DEMO,A:SYSLIB/S,DEMO/N,/U,/E

Link-80  3.44  09-Dec-81  Copyright (c) 1981 Microsoft
Data    0100    01C5    <  197>

35936 Bytes Free

Data    0100    01C5    <  197>

35936 Bytes Free
[0000   01C5        1]

(ZEX Active)
B1>ERA DEMO.REL
DEMO    .REL
B1>;  Assembly Complete
B1>
(ZEX Completed)
By Your Command>demo                    <-- I run pgm now
Hello, World ... It's Another Day
B1>



8.7  Restrictions on Command Files

     Thå  followinç  restrictionó  arå applieä tï  commanä  fileó 
processed by SUB2 and ZEX.

                        SUB2 Restrictions

     1®   Yoõ maù noô loç intï useò areaó otheò thaî thå onå  yoõ 
begaî  processinç thå commanä filå in®   Iæ yoõ do¬  ZCPR² looseó 
tracë  oæ  thå $$$.SUÂ filå anä executioî ió  aborteä  untiì  yoõ 
reenter the original user area, at which time execution resumes.

     2®   Uğ  tï 2° parameteró arå permitteä oî thå SUB²  commanä 
line.

     3.  You may nest SUB2 command files to any depth.



                        ZEX Restrictions

     1®   Yoõ  maù movå intï anù directorù yoõ desirå whilå á ZEØ 
command stream is being executed.

     2®   Uğ  tï  ¹ parameteró arå permitteä oî thå  ZEØ  commanä 
line.

     3.  You may NOT nest ZEX command files.

Š
8.8  SUB2 and ZEX as Extended Command Processors Under ZCPR2

     Botè  SUB²  anä  ZEØ makå nicå Extendeä  Commanä  Processoró 
undeò  ZCPR2®   Wå  havå  alreadù  seeî  ho÷  SUB²  anä  ZEØ  arå 
intimatelù  linkeä witè ZCPR2®   Botè uså thå Externaì  Patè  anä 
Multiplå  Commanä  Linå Buffeò Facilitieó oæ ZCPR2¬  anä  ZEØ  ió 
further prompted for input by the ZCPR2 prompt if desired.

     Tï  refresè thå reader¬  anä Extendeä Commanä Processoò ió á 
prograí invokeä bù ZCPR² wheî iô failó tï finä thå commanä  alonç 
itó  path®   ZCPR2¬  upoî  failinç  tï finä thå  COÍ  filå  whicè 
correspondó  tï  thå commanä namå giveî tï it¬  caî bå seô uğ  tï 
eitheò searcè thå patè oò gï directlù tï thå rooô oæ thå patè anä 
looë  foò  aî  Extendeä  Commanä  Processor®    Iæ  found¬  ZCPR² 
simulateó   á  commanä  tï  thaô  Extendeä   Commanä   Processor¬ 
substitutinç thå user'ó commanä linå aó thå argumentó tï it.

     To illustrate my point, consider the following example:

     É  havå á ZEØ filå nameä MASM.ZEX¬  anä iô performó thå samå 
set of commands that my M80.ZEX file did above, namely:

;  MASM.ZEX -- MACRO-80 Assembler and Linker
M80 =$1
;  Please Type $^C if Error(s) Exist - ^?
ERA $1.BAK
ERA $1.COM
L80 /P:100,$1,A:SYSLIB/S,$1/N,/U,/E
ERA $1.REL
;  Assembly Complete

     É typå iî mù program¬  nameä DEMO.MAC¬ anä issuå thå commanä 
"MASÍ DEMO"®   Witè ZEØ aó mù Extendeä Commanä  Processor¬  ZCPR² 
lookó alonç thå patè foò thå commanä MASM¬  failó tï finä it¬ anä 
theî  simulateó thå commanä "ZEØ MASÍ DEMO"®   Thå abovå  commanä 
file is then executed with DEMO as its passed parameter!

     É  thinë  thaô thå abovå examplå illustrateó thå utilitù  oæ 
employinç ZEØ (oò SUB2© aó aî Extendeä Commanä  Processor®   Thió 
ió donå verù simplù iî thå ZCPR² environment®  Tï dï this¬ simplù 
makå á copù oæ ZEX.COÍ anä namå iô CMDRUN.COM®  Sincå thió ió thå 
namå  iî thå ZCPRHDR.LIÂ filå anä thå facilitù ió turneä on¬  yoõ 
now have ZEX as the Extended Command Processor.

.fo Section 9 - Named Directories                      Page   #

9.0  Named Directories

9.1  Overview of the Named Directory Concept

     Thå  Nameä  Directorù  Concepô  undeò  ZCPR²  ió  á  logicaì 
associatioî oæ á mnemoniã namå witè á directory¬  whicè ió á disë 
anä  useò  area®   Witè thió facility¬  thå useò ió permitteä  tï 
refeò  tï  anù directorù bù á mnemoniã  name¬  anä  thió  greatlù 
improveó  thå useò interfacå oveò havinç tï remembeò disë letteró 
and numbers.

     Foò  instance¬  aî  environmenô caî bå seô uğ iî  whicè  thå 
following name assignments are made:

          A15: = ROOT         A0:  = BASE
          B0:  = BBASE        B1:  = JEFF
          B2:  = ROBERT       B3:  = LINDA

     Witè  thå  nameä  directorù  facilitù  enabled¬   thå  ZCPR² 
utilitieó caî refeò tï theså directorieó bù eitheò thå  DUº  forí 
(disk and user number) or by the name:

          XDIR ROOT: = XDIR A15:

     Mosô  oæ thå ZCPR² utilitieó recognizå nameä directorieó  iæ 
thå facilitù ió enabled¬  and¬  sincå theså utilitieó functioî tï 
providå  interfaceó betweeî thå directories¬  theù creatå á  gooä 
workinç environmenô foò uså oæ thå conventionaì CP/Í utilitieó aó 
well®   Iî  otheò words¬  thå ZCPR² utilitieó whicè caî deaì witè 
nameä  directorieó arå thå onlù utilitieó witè whicè  onå  shoulä 
crosó  directorù  boundarieó iî á ZCPR² systeí  anä  conventionaì 
utilities¬ likå aî editoò oò aî assembler¬ shoulä bå useä iî onlù 
onå directorù anä deaì witè fileó iî thå currenô directorù anä oî 
drive A in the same user number (A$ in the vernacular).

     Foò instance¬ tï ediô á filå iî thå ZCPÒ directorù witè Worä 
Master¬  copù  thå  filå intï á workinç directorù whicè  haó  thå 
WM.HLĞ  filå iî Aº  iî thå samå useò areá anä ediô  there®   Theî 
copy it back when done:
          B1>mcopy b1:=zcpr:file.txt
               ...
          B1>wm file.txt
               ...
          B1>mcopy zcpr:=file.txt

     Manù  commerciaì programs¬  likå Worä Masteò anä Worä  Star¬ 
arå  alreadù  programmeä tï looë oî Aº  iæ theù dï noô  finä  thå 
overlaù  theù neeä iî thå currenô directory®   Worä  Master¬  foò 
instance¬  haó á WM.HLĞ filå whicè provideó onlinå documentation¬ 
anä  bù workinç oî drivå Bº  iî thå samå useò thaô á WM.HLĞ  filå 
existó oî A:¬ iæ á useò askó foò Help¬ Worä Masteò wilì finä it.


     Nameä Directories¬  then¬  caî providå á morå human-orienteä 
workinç environment®   Thå useò neeä nï longeò remembeò thaô  hió 
commandó arå iî directorù A15º -- hå neeä onlù remembeò thaô ROOÔ 
containó  hió commands¬  HELĞ containó hió helğ files¬  ROBERÔ ió 
hió namå anä thaô ió wherå hå placeó thå fileó hå ió workinç  on¬ 
BDSÃ ió wherå hió Ã compileò is¬ etc.

     Nameä  Directorieó arå supporteä bù thå ZCPR² utilitieó  anä 
noô bù ZCPR² itself®  Fouò utilitieó arå specificallù designeä tï 
deaì  witè Nameä Directories¬  anä thå resô oæ thå utilitieó  caî 
accesó  Nameä  Directorieó manipulateä bù thå firsô fouò anä  uså 
them.

     Thå  fouò  ZCPR² utilitieó whicè deaì  directlù  witè  Nameä 
Directories are:

          MKDIR -- create a Named Directory
          LD    -- load a Named Directory into a Named Dir Buffer
          PWD   -- print Working Directory and optionally all
                    available Named Directories
          CD    -- log into a Named Directory



9.2  Creating Named Directory Files with MKDIR

     MKDIÒ  ió  useä tï creatå Nameä Directorù Files¬  whicè  arå 
fileó oî disë whicè contaiî thå mnemoniã nameó anä thå  disk/useò 
areaó theù arå associateä with®   Iî essence¬ MKDIÒ ió aî editor®  
Iô  provideó á scratcè areá iî whicè thå useò caî seô uğ á  nameä 
directory¬  revie÷ it¬  ediô it¬  anä makå anù changeó hå wishes®  
Wheî  satisfied¬  thå useò caî writå iô ouô tï disë aó á filå  oò 
abort and throw it away.

     MKDIR is invoked with one of three forms:

          MKDIR //                      <-- Print Help
          MKDIR                         <-- Interactive Mode
          MKDIR dir:filename.typ        <-- Read File First
                                             and Interactive Mode

     Thå  DIRº  forí  ió  alloweä iî alì filå  specificationó  tï 
MKDIR¬ sï thå useò caî prefiø á filå witè á directorù namå oò thå 
DUº  form®   MKDIÒ wilì searcè alonç thå command-searcè patè  foò 
the indicated file.


     Oncå thå useò ió iî MKDIR¬ hå ió prompteä with:

          MKDIR Command (? for Help)?

anä   hå  maù  issuå  thå  followinç  single-characteò   commandó 
(striking RETURN is not necessary):

          C -- Change Directory (Add, Rename, or Delete Entries)
          I -- Initialize Directory
          P -- Print Directory
          R -- Read in a Directory File
          S -- Status of MKDIR Environment
          W -- Write out a Directory File
          X -- Exit
          ? -- Print Help Message

     Iî alì caseó excepô W¬  thå scratcè environmenô withiî MKDIÒ 
ió affected®  Nï fileó arå affecteä untiì thå useò telló MKDIÒ tï 
write the Directory File on disk.

     Thå  Ã  commanä  (Changå  Directory© ió  useä  tï  ediô  thå 
contentó oæ thå scratcè environmenô withiî MKDIR®   Oncå invoked¬ 
the user is prompted with

          Directory Entry (?<RETURN> for Help)?

     Thå  useò ió iî aî inpuô linå editoò now¬  sï  alì  commandó 
musô  bå  terminateä bù strikinç thå RETURÎ keù beforå theù  takå 
effect®  Thió ió thå BDOÓ inpuô linå editor¬ anä strikinç ^Ã wilì 
abort to ZCPR2.

     Thå useò maù typå ¿  followeä bù strikinç RETURÎ tï finä ouô 
what his options are (again, built-in help).

     Undeò thå Ã commanä (Changå Directory)¬ thå useò caî perforí 
the following functions:

          . Add a Named Directory Entry to the Directory
          . Rename a Named Directory Entry in the Directory
          . Delete a Named Directory Entry from the Directory
          . Print the Directory
          . Print a Help Message
          . Exit to MKDIR Command Level

     Iî ordeò tï adä oò renamå á Nameä Directorù Entry¬  thå useò 
typeó thå "DU:dirname¢ form®   Iæ eitheò thå Disë (D© oò Useò (U© 
arå omitted¬ currenô disë anä useò arå assumed®  Thå "dirname¢ ió 
thå  mnemoniã  namå  associateä  witè  thå  directory¬  uğ  tï  ¸ 
characteró  long®   Iæ  á  namå  haó  beeî  associateä  witè  thå 
indicateä disë anä useò already¬  MKDIÒ wilì renamå iô tï thå ne÷ 
namå anä telì yoõ thaô iô ió doinç sï anä whaô thå olä namå  was®  
Iæ á namå haó noô alreadù beeî associateä witè thå indicateä disë 
and user, MKDIR will add this entry to the directory.

     Iî  ordeò tï deletå á Nameä Directorù Entry¬  thå useò typeó 
onlù thå "DU:¢ form®   Iæ á namå haó alreadù beeî associateä witè 
thió disë anä user¬ theî iô wilì bå deleted®  Iæ nï namå haó beeî 
associated, the user will be so informed.

     Tï  prinô thå currenô directorù foò review¬  thå  useò  neeä 
onlù strikå thå RETURÎ key®  Tï exit¬ thå useò enteró aî Ø (uppeò 
or lower case) followed by striking the RETURN key.

     Example:

          Assume the following directory:

               A15:ROOT       A10:SYS        A0:BASE
               B0:DEVBASE     B1:WORK1       B2:WORK2

          If the user wishes to delete WORK1, he types

               B1:

          If the user wishes to rename WORK2 to WORK12, he types

               B2:WORK12

          If the user wishes to add WORK3 as B3:, he types

               B3:WORK3

     Iî alì cases¬  lower-caså characteró arå converteä tï upper-
case.

     Getting on with the commands, they are:

          C -- Change Directory (Add, Rename, or Delete Entries)
          I -- Initialize Directory
          P -- Print Directory
          R -- Read in a Directory File
          S -- Status of MKDIR Environment
          W -- Write out a Directory File
          X -- Exit
          ? -- Print Help Message

     C has just been discussed and ? is obvious.

     É ió useä tï initializå thå directory®  Thå useò ió askeä iæ 
hå  ió surå hå wantó tï dï this¬  and¬  iæ Yes¬  MKDIÒ clearó thå 
scratcè  directory®   É  emphasizå  thaô  onlù  thå  memory-baseä 
scratcè  directorù oæ MKDIÒ ió effected¬  anä MKDIÒ affectó  disë 
files only with the W (Write Directory) command.


     Ğ  ió  useä tï Prinô thå Directory®   Asidå froí  thå  nameó 
assigneä  sï  far¬  thå useò ió tolä ho÷ manù entrieó  havå  beeî 
defined so far and how many are yet to be defined.

     Ò ió useä tï reaä iî á Directorù Filå anä × ió useä tï writå 
iô out®   Wheî MKDIÒ ió firsô invoked¬  iæ thå commanä ió  simplù 
"MKDIR"¬  theî  thå  defaulô  directorù  filå ió  defineä  tï  bå 
NAMES.DIR®   Iæ thå commanä ió "MKDIÒ dir:filename.typ"¬ theî thå 
defaulô directorù filå ió defineä tï bå thå indicateä filå anä iô 
ió  reaä iî immediatelù (subsequenô Ò commanä ió noô  necessary)®  
When the user issues the R command, he will be prompted with:

          Name of File (<RETURN> = filename.typ)?

Iæ hå strikeó RETURN¬  thå defaulô filå ió read®   Otherwise¬  hå 
caî typå iî á filå namå oæ hió choice®   Nï defaulô filå typå  ió 
assumed¬ sï thå filå maù bå anù name®  Thå samå prompô appearó tï 
thå  ×  (Write© command®   Iî botè cases¬  iæ thå useò wisheó  tï 
enteò hió owî filå name¬ iô maù bå oæ thå forí "dir:filename.typ¢ 
sï hå caî reaä iô froí oò placå iô anywhere.

     Onå  noteº   ×  wilì writå bacë tï thå currenô directorù  aó 
opposeä  tï  thå directorù thå filå originallù camå froí  iæ  thå 
defaulô forí ió accepted.

     Finally¬  thå Ó commanä (Status© ió kinä oæ  redundant®   Iô 
simply tells the user some status information on MKDIR.



9.3  Disk-Based and Memory-Based Named Directories

     Thå  onlù  purposå oæ LÄ ió tï loaä á Nameä  Directorù  Filå 
froí disk¬  converô iô intï thå propeò forí foò memory-baseä use¬ 
anä  storå  iô  iî  thå memory-baseä Nameä  Directorù  Buffeò  aó 
implementeä  foò ZCPR2®   Thå reasoî foò thå  memory-baseä  Nameä 
Directorù  Buffeò  ió tï speeä processinç wheî Nameä  Directorieó 
arå  referenced®   Verù  simply¬  alì thå ZCPR²  utilitieó  whicè 
supporô  Nameä Directorieó perforí thå followinç operationó  wheî 
one is referenced:

          1®   Theù scaî thå memory-baseä Nameä Directorù  Buffeò 
foò á matcè tï thå user-supplieä namå anä uså thió definitioî foò 
the name if found.

          2®   Iæ  á memory-baseä Nameä Directorù Buffeò  ió  noô 
availablå  oò thå user-supplieä namå ió noô found¬  theî scaî thå 
disks¬  searchinç  alonç  thå commanä searcè patè  foò  thå  filå 
NAMES.DIR®  Iæ found¬ theù loaä it¬ scaî iô foò thå user-supplieä 
name¬ anä uså thió definition®  Iæ noô found¬ theù issuå aî erroò 
message.


     I call the reader's attention to two main points here:

          1®   Iæ thå user-supplieä namå ió founä iî thå  memory-
baseä  Nameä Directorù Buffer¬  theî á disë accesó ió noô  needeä 
anä  thå utilitù runó fasteò sincå iô doeó noô havå tï dï á  disë 
search.

          2®   Iæ  á  disë searcè ió done¬  iô ió donå alonç  thå 
commanä  searcè patè anä thå firsô NAMES.DIÒ filå encountereä  ió 
used®  Iî thió way¬ aî differenô Nameä Directorù structurå may be
createä  foò  whaô thå useò sa÷ beforå wheî hå  waó  loggeä  intï 
another directory.  To illustrate, consider the following:


          The memory-based Named Directory Buffer contains:

               A0:BASE        A15:ROOT       A16:HELP

          Thå NAMES.DIÒ filå founä froí directorù WORK± contains:

               B1:WORKBASE    B2:HOME        B3:TEST1

anä thå NAMES.DIÒ filå founä froí directorù WORK² contains:

               B1:WBASE       B2:MYHOME      B4:TEST2

     Á useò loggeä intï WORK± cannoô accesó directorù TEST2¬  anä 
á useò loggeä intï WORK² cannoô accesó directorù TEST1®   Also¬ á 
useò iî WORK± anä á useò iî WORK² caî botè accesó B± anä B2¬  buô 
theù dï sï bù differenô names®  Alì useró caî accesó A0¬ A15¬ anä 
A16, and they do it by the same names.

     Á conventioî É likå tï uså oî mù system¬ buô onå whicè ió bù 
nï meanó required¬  ió tï namå thå directorù containinç alì oæ mù 
commandó aó ROOT¬ anä É likå tï keeğ iô uğ ouô oæ thå waù aô A15®  
Bù beinç iî A15¬  É caî loç intï iô wheî É kno÷ thå commandó wilì 
come from it and I want them to run as quickly as possible.

     Anotheò  conventioî  É likå tï uså ió tï placå alì  thå  HLĞ 
fileó  (foò  thå onlinå documentatioî system© uğ  iî  A16®   Thió 
directorù  cannoô bå loggeä into¬  buô É don'ô wanô tï  sincå  nï 
commandó residå there®  Thå HELĞ prograí caî bå madå tï finä theí 
easilù  sincå iô caî bå seô uğ tï eitheò scaî thå commanä  searcè 
patè anä theî scaî itó owî internaì path¬  whicè É havå endinç iî 
A16, or I can set up HELP to just scan its internal path.



9.4  Loading Named Directory Files with LD

     LÄ (Loaä Directory© loadó thå Nameä Directorù Filå NAMES.DIÒ 
oò  thå  filå  specifieä  iî thå commanä linå  intï  thå  memory-
residenô  Nameä  Directorù Buffer®   LÄ automaticallù  scanó  thå 
command search path for the desired directory.

     LD is invoked by one of the following forms:

          LD //                    <-- Print Help
          LD                       <-- Print Load Stats
          LD filename              <-- Load filename.DIR
          LD filename.typ          <-- Load filename.typ

     Notå thaô É dï NOÔ permiô á DIRº  oò DUº  prefiø oî thå filå 
name®   Thå  filå tï bå loadeä haó tï bå founä alonç thå  commanä 
searcè path®   É diä thió tï makå LÄ aó smalì aó possiblå anä ruî 
as quickly as possible.



9.5  Printing Named Directory Files and Buffers with PWD

     PWD (Print Working Directory) is used for two functions:

          1.  To print the name of the directory you currently
               reside in

          2.  To print the names of all directories you can
               access from where you are

     PWD is invoked by the following forms:

          PWD //                   <-- Print Help
          PWD                      <-- Print Current Directory
          PWD DIR                  <-- Print Directory Info




9.6  Moving About with CD

     CÄ  (Changå Directory© ió useä tï movå froí onå directorù tï 
anotheò bù usinç thå nameó associateä witè thå  directories®   CÄ 
is invoked by one of the forms:

          CD //               <-- Print Help
          CD dir or CD dir:   <-- Log into Directory

     Wheî CÄ executes¬ iô determineó thå disë anä useò associateä 
tï thå namå bù thå standarä ZCPR² technique:

          1®   CÄ  scanó thå memory-baseä Nameä Directorù  Buffeò 
foò  á matcè tï thå user-supplieä namå anä useó  thió  definitioî 
foò thå namå iæ found.

          2®   Iæ  á memory-baseä Nameä Directorù Buffeò  ió  noô 
availablå  oò thå user-supplieä namå ió noô found¬  theî CÄ scanó 
thå disks¬  searchinç alonç thå commanä searcè patè foò thå  filå 
NAMES.DIR®  Iæ found¬ CÄ loadó it¬ scanó iô foò thå user-supplieä 
name¬ anä useó thió definition®  Iæ noô found¬ CÄ issueó aî erroò 
message.


     Oncå  CÄ identifieó thå directorù tï loç into¬  iô checkó tï 
seå  iæ iô ió á Systeí Directorù (useò numbeò greateò thaî 1°  -- 
seå later© anä askó foò á passworä iæ so®  Iæ aî invaliä passworä 
is given, CD drops the user back into his original directory.

     Iæ  CÄ  decideó  tï givå thå useò accesó  tï  thå  directorù 
(valiä  passworä ió giveî foò á Systeí Directorù oò iô ió  noô  á 
Systeí Directory)¬ theî CÄ logó intï thå directory¬ checkó tï seå 
iæ thå filå ST.COÍ exists¬ anä chainó tï iô iæ iô doeó (usinç thå 
Multiplå  Commanä Linå Buffer)®   Thió latteò actioî ió noô takeî 
if the Multiple Command Line Buffer is not available.

     ST.COÍ  ió simplù á copù oæ STARTUP.COÍ undeò thå  namå  ST®  
Thå  onlù purposå oæ STARTUĞ ió tï loaä thå Multiplå Commanä Linå 
Buffeò  witè  á  commanä linå wheî iô  ió  executeä  withouô  anù 
options®   Thió  commanä linå maù contaiî á reasonablå numbeò  oæ 
commands which perform any desired set of functions.

     Iî  thå  ZCPR² environment¬  gooä candidatå commandó  tï  bå 
executed by running ST via CD include the following:

          LD dirname     <-- Set up a new Memory-Based Named
                              Directory Environment
          PATÈ path-exğ  <-- Seô uğ á ne÷ Commanä Searcè Path
          MENU           <-- Invoke the MENU Preprocessor
          ECHO message   <-- Print a Message to the User


     Hence¬  thå  user'ó  environmenô caî changå  drasticallù  bù 
usinç  CÄ  tï  loç  intï  á ne÷  directory®   Thå  nameó  oæ  thå 
directorieó hå caî accesó caî changå (LÄ changeó thå Memory-Baseä 
nameó  anä  á ne÷ NAMES.DIÒ filå alonç hió  commanä  searcè  patè 
changeó  thå Disk-Baseä names)¬  thå commanä searcè patè hå  useó 
caî  change¬  anä hå caî eveî finä himselæ iî á MENÕ  environmenô 
insteaä oæ á ZCPR² commanä environment.



9.7  Poor Little ECHO and CD

     ECHÏ ió á ratheò triviaì prograí -- iô simplù echoó thå texô 
following it.  It has only one form:

          ECHO text

anä iô printó "text¢ oî thå consolå wheî iô executes®  Whù havå á 
program like this?  The answer is with CD and ST.

     CD¬  aó É mentioneä earlier¬  automaticallù invokeó SÔ iæ iô 
findó iô iî thå directorù iô logó into®   ECHÏ ió provideä aó onå 
oæ thå commandó SÔ coulä execute®  Iî thió mode¬ thå commanä linå 
containinç thå ECHÏ commanä wilì noô bå printeä tï thå user¬  buô 
thå texô printeä bù ECHÏ will®   Hence¬  ECHÏ caî bå useä tï givå 
the user one-line messages upon entering a new directory.

     Iæ  thå useò ió tï receivå morå thaî onå line¬  theî á  filå 
caî  bå createä somewherå whicè containó thå texô oæ thå message¬ 
anä TYPÅ caî bå useä tï prinô thå filå oî thå console®  Notå thaô 
TYPE permits the DU: form, so the file can be anywhere.



9.8  System Directories

     Therå   existó   á  clasó  oæ  directorieó   calleä   Systeí 
Directorieó undeò ZCPR2®  Theså arå directorieó whoså useò numbeò 
ió  1° oò greateò (thió maù bå changeä foò eacè  installatioî  bù 
using GENINS).

     Iæ  yoõ  issuå  thå  commanä "PWÄ  DIR¢  froí  á  non-Systeí 
directory¬ PWÄ maù telì yoõ thaô somå directorieó arå hidden®  Iô 
wilì  noô  displaù  thå nameó oæ thå Systeí  Directorieó  tï  yoõ 
unless you reside in a System Directory.

     Systeí  Directorieó  arå foò privelegeä users®   Iæ thå  DUº 
forí foò switchinç betweeî directorieó ió noô available¬ thå onlù 
waù tï switcè betweeî directorieó ió bù meanó oæ thå CÄ  command®  
CD¬  wheî  iô  realizeó thaô yoõ havå giveî thå namå oæ á  Systeí 
Directory¬  askó  yoõ foò á password®   Yoõ musô correctlù  enteò 
thió  passworä  beforå  CÄ wilì allo÷ yoõ  tï  enteò  thå  Systeí 
Directory.

     Hence¬  twï leveló oæ protectioî arå affordeä tï á systeí bù 
disablinç thå DUº forí anä usinç nameä directories®  Thå firsô ió 
thaô  á non-privelegeä useò cannoô finä ouô whaô thå nameó oæ thå 
Systeí  Directorieó  arå  bù usinç PWÄ (iô ió uğ  tï  thå  Systeí 
Manageò  tï  insurå thaô nï otheò tooì ió availablå tï  thå  non-
privelegeä useò tï allo÷ hií tï finä ouô thió information)®   Thå 
seconä  ió that¬  eveî iæ thå non-privelegeä useò founä ouô  whaô 
thå  nameó  oæ  thå Systeí Directorieó  are¬  hå  stilì  needó  á 
password to enter them.


9.9  Sample Sessions

     Thå followinç frameó arå sampleó oæ actuaì terminaì sessionó 
whicè  illustratå  severaì oæ thå pointó discusseä iî  thió  HELĞ 
file®   É havå placeä comments¬  preceedeä bù <<¬ ouô tï thå sidå 
tï  helğ  yoõ alonç iî youò readinç oæ thå sessionó anä tï  poinô 
out key features I am trying to illustrate.


B7>mkdir
MKDIR  Version 1.2
MKDIR Command (? for Help)? ?           << Print Help
MKDIR Commands are --
        C -- Change Directory (Add/Rename/Delete Entries)
        I -- Initialize Directory
        P -- Print Directory
        R -- Read Directory File
        S -- Status of MKDIR Environment
        W -- Write Directory File
        X -- Exit Program

MKDIR Command (? for Help)? R           << Read in File 
Name of File (<RETURN> = NAMES   .DIR)?      << Default from Path

MKDIR Command (? for Help)? P           << Print Directory
Disk A --
     0: R-BASE       1: R-ASM        2: R-BDSC       3: R-PAS   
     5: R-BASIC      7: R-WS         8: R-CAT        9: R-DBASE 
    10: SYS         11: ZCPR        15: ROOT        16: HELP    
Disk B --
     0: DEV-BASE     1: ASM          2: BDSC         3: PAS     
     4: SCRATCH      5: BASIC        7: WS           8: CAT     
     9: DBASE   
Disk C --
     0: BACKUP  
 22 Entries in Directory


MKDIR Command (? for Help)? S           << Status
** MKDIR Status **

 22 Entries in Directory
 42 Empty Entries Remaining

Working File Name: NAMES   .DIR

No Changes made to Directory since Startup
File has been loaded

MKDIR Command (? for Help)? C           << Enter Change Mode
** MKDIR Change Mode **
Directory Entry (?<RETURN> for Help)? ? << Print Help

MKDIR Change Mode --
        You may issue the following commands at this point:

                DU:dirname      <-- Create/Rename Dir Entry
                DU:             <-- Delete Dir Entry
                <RETURN>        <-- Print Directory
                X               <-- Exit
                ?               <-- Print this Help

Directory Entry (?<RETURN> fo Help)? b1:          << Delete
        Deleting ASM      --  21 Entries Remaining
Directory Entry (?<RETURN> for Help)? c2:newdir   << Add/Rename
        Adding NEWDIR   --  22 Entries in Directory, Room for  42 More
Directory Entry (?<RETURN> for Help)? b2:
        Deleting BDSC     --  21 Entries Remaining
Directory Entry (?<RETURN> for Help)? b3:
        Deleting PAS      --  20 Entries Remaining
Directory Entry (?<RETURN> for Help)? b1:mydir
        Adding MYDIR    --  21 Entries in Directory, Room for  43 More
Directory Entry (?<RETURN> for Help)? b0:d-base
        Renaming DEV-BASE --  21 Entries in Directory, Room for  43 More

Directory Entry (?<RETURN> for Help)?             << Print Dir
Disk A --
     0: R-BASE       1: R-ASM        2: R-BDSC       3: R-PAS   
     5: R-BASIC      7: R-WS         8: R-CAT        9: R-DBASE 
    10: SYS         11: ZCPR        15: ROOT        16: HELP    
Disk B --
     0: D-BASE       1: MYDIR        4: SCRATCH      5: BASIC   
     7: WS           8: CAT          9: DBASE   
Disk C --
     0: BACKUP       2: NEWDIR  
 21 Entries in Directory
Directory Entry (?<RETURN> for Help)? x      << Exit
MKDIÒ Commanä (¿ foò Help)¿ ×                <¼ Writå to Disk
Name of File (<RETURN> = NAMES   .DIR)? temp.dir  << New File
Writing Directory to Disk ... Done


MKDIR Command (? for Help)? I                << Init Dir
        Are you sure you want to Initialize the Directory (Y/N/<CR>=N)? Y

MKDIR Command (? for Help)? P                << Print New Dir
Empty Directory
MKDIR Command (? for Help)? C                << Enter Names
** MKDIR Change Mode **
Directory Entry (?<RETURN> for Help)? a15:root
        Adding ROOT     --   1 Entries in Directory, Room for  63 More
Drectory Entry (?<RETURN> for Help)? a0:base
        Adding BASE     --   2 Entries in Directory, Room for  62 More
Directory Entry (?<RETURN> for Help)? b1:work1
        Adding WORK1    --   3 Entries in Directory, Room for  61 More
Directory Entry (?<RETURN> for Help)? b2:work2
        Adding WORK2    --   4 Entries in Directory, Room for  60 More
Directory Entry (?<RETURN> for Help)? b3:work3
        Adding WORK3    --   5 Entries in Directory, Room for  59 More

Directory Entry (?<RETURN> for Help)?        << Print Dir
Disk A --
     0: BASE        15: ROOT    
Disk B --
     1: WORK1        2: WORK2        3: WORK3   
  5 Entries in Directory
Directory Entry (?<RETURN> for Help)? b0:workbase
        Adding WORKBASE --   6 Entries in Directory, Room for  58 More
Directory Entry (?<RETURN> for Help)? x      << Exit
MKDIR Command (? for Help)? P                << Print Again
Disk A --
     0: BASE        15: ROOT    
Disk B --
     0: WORKBASE     1: WORK1        2: WORK2        3: WORK3   
  6 Entries in Directory
MKDIR Command (? for Hep)? W                 << Write to Disk
Name of File (<RETURN> = TEMP    .DIR)? temp2.dir << New File
Writing Directory to Disk ... Done

MKDIR Command (? for Help)? R           << Read in File
Name of File (<RETURN> = TEMP2   .DIR)? temp.dir
MKDIR Command (? for Help)? P           << Look at it
Disk A --
     0: R-BASE       1: R-ASM        2: R-BDSC       3: R-PAS   
     5: R-BASIC      7: R-WS         8: R-CAT        9: R-DBASE 
    10: SYS         11: ZCPR        15: ROOT        16: HELP    
Disk B --
     0: D-BASE       1: MYDIR        4: SCRATCH      5: BASIC   
     7: WS           8: CAT          9: DBASE   
Disk C --
     0: BACKUP       2: NEWDIR  
 21 Entries in Directory


MKDIR Command (? for Help)? R           << Read in Another
Name of File (<RETURN> = TEMP    .DIR)? temp2.dir
MKDIR Command (? for Help)? P           << Look at it
Disk A --
     0: BASE        15: ROOT    
Disk B --
     0: WORKBASE     1: WORK1        2: WORK2        3: WORK3   
  6 Entries in Directory
MKDIR Command (? for Help)? X           << Exit

<¼ É havå no÷ createä ² ne÷ directories¬ TEMP.DIÒ anä TEMP2.DIR


B7>mkdir temp2.dir                 << MKDIR and Read File
MKDIR  Version 1.2
MKDIR Command (? for Help)? P      << Print
Disk A --
     0: BASE        15: ROOT    
Dik B --
     0: WORKBASE     1: WORK1        2: WORK2        3: WORK3   
  6 Entries in Directory
MKDIR Command (? for Help)? C      << Change
** MKDIR Change Mode **
Directory Entry (?<RETURN> for Help)? a4:help
        Adding HELP     --   7 Entries in Directory, Room for  57 More
Directory Entry (?<RETURN> for Help)? x
MKDIR Command (? for Help)? R      << Read in file and throw away
Name of File (<RETURN> = TEMP2   .DIR)?      <<  ... changes

MKDIR Command (? for Help)? C      << Change this file instead
** MKDIR Change Mode **
Directory Entry (?<RETURN> for Help)? a16:help
        Adding HELP     --   7 Entries in Directory, Room for  57 More
Directory Entry (?<RETURN> for Help)? 
Disk A --
     0: BASE        15: ROOT        16: HELP    
Disk B --
     0: WORKBASE     1: WORK1        2: WORK2        3: WORK3   
  7 Entries in Directory
Directory Entry (?<RETURN> for Help)? x
MKDIR Command (? for Help)? X      << Exit without saving first

Directory has changed since last Write       << MKDIR caught me
Do you want to write Directory to Disk first (Y/N/<CR>=Y)?Y

Name of File (<RETURN> = TEMP2   .DIR)?      << Save file
Writing Directory to Disk ... Done

B7>dir *.dir
TEMP    .DIR  |  TEMP2   .DIR
B7>pwd //                          << PWD Help
PWD, Version 1.1
        PWD is a ZCPR2 named directory display utility
(PWD=Print Working Directory).  Command Forms are:
                PWD     <-- Print Current Info
                PWD DIR <-- Print Available Directories
                PWD //  <-- Print Help Message

B7>pwd                             << Print Current Dir
PWD, Version 1.1

** Current Directory **
        B 7: WS      

B7>pwd dir                         << Print Known Dirs
PWD, Version 1.1

** Directory Display **

        ** Named Directory Memory-Based Definitions **
  3 Directory Entries Total (  2 Directories Hidden) --
A --
   0: BASE    

Strike Any Key to Continue - 

        ** Named Directory  Disk-Based  Definitions **
 22 Directory Entries Total (  4 Directories Hidden) --
A --
   0: R-BASE     1: R-ASM      2: R-BDSC     3: R-PAS   
   5: R-BASIC    7: R-WS       8: R-CAT      9: R-DBASE 
B --
   0: DEV-BASE   1: ASM        2: BDSC       3: PAS     
   4: SCRATCH    5: BASIC      7: WS         8: CAT     
   9: DBASE   
C --
  0: BACKUP  

** Current Directory **
        B 7: WS      
B7>10:                   << Enter System Dir to see all


B10>pwd dir              << Now look at dirs
PWD, Version 1.1

** Directory Display **

        ** Named Directory Memory-Based Definitions **
  3 Directory Entries Total (  0 Directories Hidden) --
A --
   0: BASE      15: ROOT      16: HELP    

Strike Any Key to Continue - 

        ** Named Directory  Disk-Based  Definitions **
 22 Directory Entries Total (  0 Directories Hidden) --
A --
   0: R-BASE     1: R-ASM      2: R-BDSC     3: R-PAS   
   5: R-BASIC    7: R-WS       8: R-CAT      9: R-DBASE 
  10: SYS       11: ZCPR      15: ROOT      16: HELP    
B --
   0: DEV-BASE   1: ASM        2: BDSC       3: PAS     
   4: SCRATCH    5: BASIC      7: WS         8: CAT     
   9: DBASE   
C --
   0: BACKUP  

** Current Directory **
        Noname
B10>ld //                << LD Help
LD  Version 1.1
        LD is the Load Directory program for ZCPR2.
The functions of LD are to load the memory-resident
named directory uffer from the specified or implied
disk file and to display the contents of the named
directory buffer.

        The forms of the LD command are --

                LD              <-- Display Loaded Directory
                LD filename     <-- Load filename.DIR
                LD filename.typ <-- Load filename.typ
                LD //           <-- Print this Help Message


B10>ld                   << Print Status
LD  Version 1.1
**********************************************
** Memory-Based Named Directory Definitions **
** Number of Entries Permitted:  50         **
** Number of Entries Loaded:   3            **
**********************************************
        -- Named Directory Display --
A --
  0: BASE     15: ROOT     16: HELP    

** Current Directory **
        Not Named in Directory Buffer
B10>ld ld                << Load a Directory (LD.DIR)
LD  Version 1.1
Load Complete

B10>pwd dir              << Print new environ
PWD, Version 1.1

** Diectory Display **

        ** Named Directory Memory-Based Definitions **
 13 Directory Entries Total (  0 Directories Hidden) --
A --
   0: BASE      10: SYS       11: ZCPR      15: ROOT    
B --
   0: DEV-BASE   1: ASM        2: BDSC       3: PAS     
   5: BASIC      7: WS         8: CAT        9: DBASE   
C --
   0: BACKUP  

Strike Any Key to Continue - 

        ** Named Directory  Disk-Based  Definitions **
 22 Directory Entries Total (  0 Directories Hidden) --
A --
   0: R-BASE     1: R-ASM      2: R-BDSC     3: R-PAS   
   5: R-BASIC    7: R-WS       8: R-CAT      9: R-DBASE 
  10: SYS       11: ZCPR      15: ROOT      16: HELP    
B --
   0: DEV-BASE   1: ASM        2: BDSC       3: PAS     
   4: SCRATCH    5: BASIC      7: WS         8: CAT     
   9: DBASE   
C --
   0: BACKUP  

** Current Directory **
        Noname


B10>7:;pwd dir           << Print same environ from non-Sys user
PWD, Version 1.1

** Directory Display **

        ** Named Directory Memory-Based Definitions **
 3 Directory Entries Total (  3 Directories Hidden) --
A --
   0: BASE    
B --
   0: DEV-BASE   1: ASM        2: BDSC       3: PAS     
   5: BASIC      7: WS         8: CAT        9: DBASE   
C --
   0: BACKUP  

Strike Any Key to Continue - 

        ** Named Directory  Disk-Based  Definitions **
 22 Directory Entries Total (  4 Directories Hidden) --
A --
   0: R-BASE     1: R-ASM      2: R-BDSC     3: R-PAS   
   5: R-BASIC    7: R-WS       8: R-CAT      9: R-DBASE 
B --
   0: DEV-BASE  1: ASM        2: BDSC       3: PAS     
   4: SCRATCH    5: BASIC      7: WS         8: CAT     
   9: DBASE   
C --
   0: BACKUP  

** Current Directory **
        B 7: WS      

B7>ld temp2;pwd dir           << Load one of my new environs
LD  Version 1.1
Load Complete
PWD, Version 1.1

** Directory Display **

        ** Named Directory Memory-Based Definitions **
  7 Directory Entries Total (  2 Directories Hidden) --
A --
   0: BASE    
B --
   0: WORKBASE   1: WORK1      2: WORK2      3: WORK3   

Strike Any Key to Coninue - 


        ** Named Directory  Disk-Based  Definitions **
 22 Directory Entries Total (  4 Directories Hidden) --
A --
   0: R-BASE     1: R-ASM      2: R-BDSC     3: R-PAS   
   5: R-BASIC    7: R-WS       8: R-CAT      9: R-DBASE 
B --
   0: DEV-BASE   1: ASM        2: BDSC       3: PAS     
   4: SCRATCH    5: BASIC      7: WS         8: CAT     
   9: DBASE   
C --
   0: BACKUP  

** Current Directory **
        B 7: WS      

B7>ld ld                 << Load Standard Environ
LD  Version 1.1
Load Complete  
B7>cd cat                << CD into CAT Directory
CD Version 2.3

MENU  Version 1.4        << MENU automatically comes up!


                        Disk Cataloging System

Catalog Update Functions --
        1 - Update Disks on C: into a Temporary File
        2 - Update the Disk on C: into the Archival Disk File
        3 - Update the Disk on C: into the Active Disk File

Merge the Temporary File into --
        4 - The Archival Disk File      5 - The Active Disk File

Backup --
        6 - The Archival Disk File      7 - The Active Disk File

Scan --
        A- The Archival Disk Catalog    B - The Active Disk Catalog

Miscellaneous Functions --
        D - Delete TEMP and BAK Files   T - Display the Date and Time
        X - Display Disk Directory      Z - Issue Any ZCPR2 Command

Command (<CR>=Menu, ^C=ZCPR2) - A       << Scan Catalog
Input Files and Disks -- mkdir.mac...............................


CATALOG II  Version 5.3
Catalog File:         MASTER  .CAT
++ SCAN Catalog Function ++
Date of Last Write/Merge:  15 Jan 83

CATALOG File Name: MASTER  .CAT   Date/Comment: 15 Jan 83
Filename.Typ   Diskname.Dsk   Diskname.Dsk   Diskname.Dsk
MKDIR   .MAC   BACK015 .J01   C&ASM   .J06   SRC015  .J00
++ SCAN Function Complete ++
MENU  Version 1.4 Strike Any Key -           << Give user time


                        Disk Cataloging System

Catalog Update Functions --
        1 - Update Disks on C: into a Temporary File
        2 - Update the Disk on C: into the Archival Disk File
        3 - Update the Disk on C: into the Active Disk File

Merge the Temporary File into --
        4 - The Archival Disk File      5 - The Active Disk File

Backp --
        6 - The Archival Disk File      7 - The Active Disk File

Scan --
        A - The Archival Disk Catalog   B - The Active Disk Catalog

Miscellaneous Functions --
        D - Delete TEMP and BAK Files   T - Display the Date and Time
        X - Display Disk Directory      Z - Issue Any ZCPR2 Command

Command (<CR>=Menu, ^C=ZCPR2) - Z       << Enter Command Line
Input Command -- cd ws...................................
CD, Version 2.3                    << Return to Dir WS
MENU  Version 1.4                  << MENU tries, but none there

B7>                 << At Command Level Again

