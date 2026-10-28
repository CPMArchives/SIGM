.he                      User's Guide for ZCPR2
.fo Section 0 - Introduction                           Page   #

0.0 Introduction

     Thió  ió  thå User'ó Guidå foò ZCPR2®   Thå purposå oæ  thió 
documenô  ió  tï  cover¬  iî somå detail¬  alì  oæ  thå  programó 
provideä iî thå distributioî oæ thå ZCPR² System®   Thió documenô 
ió intendeä tï servå aó botè á tutoriaì anä á reference¬  anä thå 
informatioî containeä iî iô is¬  bù anä large¬  alsï containeä iî 
the online Help Files provided in the distribution.

     Thió  User'ó Guidå ió organizeä iî thå  followinç  sections®  
Thå programó indicateä witè thå sectioî nameó arå thoså discusseä 
in each section.

     1.  Input/Output              8.  Command Files
          CONFIG, TINIT                 SUB2
          DEVICE                        ZEX
          IOLOADER
          RECORD                   9.  Named Directories
          STARTUP                       CD
          SYSIO                         STARTUP as ST
                                        LD
     2.  Directory Utility              MKDIR
          XDIR3                         PWD

     3.  Disk Utilities           10.  ZCPR2
          DU2                           DIR, XDIR3
                                        ERA, ERASE
     4.  Library Utilities              REN, RENAME
          LDIRZ                         TYPE, PAGE
          LRUNZ                         LIST, PRINT
          LU                            SAVE
                                        JUMP
     5.  Menu                           GO
          MCHECK                        GENINS
          MENU                          PATH
                                        WHEEL
     6.  File Compare                   PROTECT
          COMPARE
          CRC                     11.  Help
          DIFF                          HELP2

     7.  File Copy
          MCOPY


     Thió User'ó Guide¬  aó welì aó thå otheò ZCPR² manuals¬  waó 
written on the author's ZCPR2 system using Word Star.


0.1  Overview of the ZCPR2 Help Files

     Alì oæ thå ZCPR² utilitieó arå documenteä onlinå bù meanó oæ 
thå ZCPR² Helğ System®  Thió documenô waó deriveä froí thå ZCPR2-
Specifiã Helğ Fileó supplieä witè thå ZCPR² System.

     Thå  readeò ió inviteä tï reaä thå ZCPR² Conceptó Manuaì anä 
thå ZCPR² User'ó Guidå aó welì aó thå Helğ files®  Thå Helğ fileó 
duplicatå thå User'ó Guide¬  bù anä large¬  anä theù providå  thå 
conveniencå oæ allowinç thå useò tï accesó thå informatioî onlinå 
anä oæ allowinç thå useò tï quicklù indeø intï thå informatioî tï 
thå particulaò iteí hå ió interesteä in.

     Thå  followinç tablå summarizeó thå nameó oæ thå Helğ  fileó 
supplieä  witè thå ZCPR² Systeí anä thå programó covereä bù  eacè 
Help file.

Help File      Programs Covered
---------      ----------------

CFILES         Command File Processors -- SUB2 and ZEX
COMPARE        Compare Utilities -- COMPARE, CRC, and DIFF
CPMTR          CP/M-Supplied Transients -- PIP, STAT, etc
DU2            Disk Utility -- DU2
HELP           Very Basic Help
HELP2          Help System -- HELP2

IÏ             Redirectablå I/Ï -- DEVICE¬ IOLOADER¬ RECORD¬
                    SYSIO, and STARTUP/ST
LU             Library Utilities -- LDIRZ, LRUNZ, LU
MCOPY          File Copy Utility -- MCOPY
MENU           Menu System -- MCHECK and MENU

NDIRS          Named Directory Manipulation Utilities -- CD, LD,
                    MKDIR, PWD, STARTUP/ST, and ECHO
XDIR3          Extended Directory Display Utility -- XDIR3

Z2ALT          Alternates to ZCPR2-Resident Commands --
                    ERASE, RENAME, PROTECT, PAGE, PRINT,
                    PATH, and WHEEL
Z2RES          ZCPR2 Resident Commands
ZCPR2          The "Master" Help File


     Onlù  twï  ZCPR² commandó arå noô covereä bù anù Helğ  file®  
Theù arå CCPLOÃ anä GENINS¬ whicè arå covereä iî thå Installatioî 
Manual.


0.2  A Note on File References

     Filå  Referenceó undeò ZCPR² arå largelù oæ thå samå forí aó 
undeò CP/Í excepô thaô á ¯ (slash© maù noô bå thå firsô characteò 
oæ  á  filå  name®    Filå  Referenceó  arå  processeä   slightlù 
differentlù  undeò  ZCPR2¬  anä thå FCBó arå  slightlù  differenô 
betweeî  ZCPR² anä CP/Í wheî thå special¬  disalloweä  characteró 
are included in a file reference.

     The following are these disallowed characters:

          < > , ; : = ? * [ ]

     This¬  oæ  course¬  applieó tï unambiguouó filå  references®  
Ambiguous file references may contain ? or *.




0.3  Line Editing and Output Control

     The following are the line editing functions --

          rubout    Deletå  anä echï thå lasô characteò typeä  aô 
                    thå console.
          Ctrl-H    Deletå  thå  lasô characteò typed»  Backspacå 
                    onå character» CRT-oriented
          Ctrl-U    Deletå thå entirå linå typeä aô thå console.
          Ctrl-X    Deletå  thå entirå linå typeä aô thå console» 
                    Backspacå  tï  thå beginninç oæ  thå  currenô 
                    line» CRT-oriented.
          Ctrl-R    Retypå currenô commanä lineº   typeó á "cleaî 
                    line¢ followinç characteò deletioî witè  rub
                    outs.
          Ctrl-E    Physicaì enä oæ lineº   carriagå ió returned¬ 
                    buô  linå ió noô senô untiì thå carriagå  re
                    turî keù ió depressed.
          Ctrl-M    Terminates input (carriage return).
          Ctrl-J    Terminateó  currenô inpuô (linå  feed)»  CRT-
                    oriented
          Ctrl-C    CP/M system reboot (warm start).
          Ctrl-Z    Enä  inpuô froí thå consolå (useä iî PIĞ  anä 
                    ED).

     Other control functions affect console output --

          Ctrl-P    Copù  alì  subsequenô consolå outpuô  tï  thå 
                    currently-assigneä lisô devicå (LST:)®   Out
                    puô  ió senô tï botè thå lisô devicå anä  thå 
                    consolå  devicå  untiì  thå  nexô  Ctrl-Ğ  ió 
                    typed®  Uså oæ Ctrl-Ğ ió noô recommendeä aó á 
                    generaì rulå undeò ZCPR2¬ anä iô ió preferreä 
                    thaô  thå  useò  emploù  á  Redirectablå  I/Ï 
                    Devicå Driveò foò thió function.Š
          Ctrl-S    Stoğ thå consolå outpuô temporarily®  Prograí 
                    executioî  anä outpuô continuå wheî thå  nexô 
                    characteò  ió typeä aô thå  console®   Typinç 
                    Ctrl-Ã returnó controì tï CP/M.

     Inpuô lineó caî generallù bå quitå long¬  thå sizå specifieä 
aô  ZCPR² installatioî time®   Theù arå noô acteä upoî untiì  thå 
carriagå returî keù ió typed.

     Alì  oæ  theså linå editinç functionó arå supporteä  bù  thå 
CP/Í BDOÓ and¬  consequently¬  useä bù ZCPR² itself®   Manù ZCPR² 
utilities¬ althï noô all¬ uså thå BDOÓ linå editoò also.

.fo Section 1 - Input/Output                           Page   #

1.0  Input/Output

1.1  Redirectable I/O Under ZCPR2

     Basically¬  thå  concepô  oæ redirectablå I/Ï  involveó  thå 
assignmenô  oæ physicaì deviceó tï logicaì  devices®   ZCPR²  anä 
CP/Í supporô fouò logicaì devices:

          CON: - Console - An I/O Device for User/System Commo
          LST: - Printer - An Output-Only Device for Printouts
          RDR: - Reader  - An Input-Only Device
          PUN: - Punch   - An Output-Only Device

     Undeò  CP/M¬  therå arå onlù fouò physicaì deviceó whicè maù 
bå  assigneä tï eacè oæ thå fouò logicaì devices®   Undeò  ZCPR2¬ 
therå  maù  bå aó manù physicaì deviceó aó desireä whicè  maù  bå 
assigned to each of the four logical devices.

     Á   "physicaì  device¢  iî  thå  traditionaì  senså   ió   á 
conventionaì I/Ï device¬  likå á CRÔ oò á Printer®   Iî thå senså 
oæ ZCPR2¬  iô ió á devicå driver¬  oò bodù oæ software¬  whicè ió 
communicateä witè viá thå BIOS®   Thió bodù oæ software¬ iî turn¬ 
may communicate with any device OR SET OF DEVICES that it wishes.

     SYSIÏ  ió á samplå seô oæ Redirectablå I/Ï Driveró  designeä 
tï bå useä witè ZCPR² oî mù system®   Undeò SYSIO¬  thå followinç 
"physical devices" are implemented:

CON: Devices - TTY
               CRT
               CRT Input and CRT/Remote Computer Output
               CRT and Modem Input and CRT and Modem Output
                    in Parallel
               CRT Input and CRT/Modem Output

LST: Devices - TTY
               CRT
               Modem
               Remote Computer

RDR: and PUN: Devices - Modem
                        Clock


     Aó  yoõ caî see¬  thå "physicaì devices¢ undeò ZCPR² caî  bå 
combinationó  oæ actuaì devices®   Thå CRÔ Inpuô  anä  CRT/Remotå 
Computeò Outpuô device¬  foò instance¬  ió useä tï allo÷ á remotå 
computeò recorä screeî displayó whicè gï tï thå CRT.


     Undeò ZCPR2¬  yoõ caî creatå aó manù sets¬  oò packages¬  oæ 
Redirectablå I/Ï Driveró aó yoõ wish®  Eacè packagå caî bå seô uğ 
tï givå thå useò differenô typeó oæ capabilities®   Foò instance¬ 
onå  packagå  caî  bå likå thå onå É  havå  defineä  abovå  whilå 
anotheò  packagå caî providå Disë Recordinç capability¬  sucè  aó 
CRT Input and CRT/Disk File Output.

     Thå  ZCPR²  Systeí  oæ  Programó  containó  threå  utilitieó 
designeä tï supporô thå Redirectablå I/Ï System®  Theså utilitieó 
and their functions are:

          IOLOADER -- Load a Redirectable I/O Package
          DEVICE   -- Display and Select Physical I/O Devices
          RECORD   -- Turn on and off the Recording Facility

     Thió  sectioî oæ thå User'ó Guidå discusseó theså  utilitieó 
anä ho÷ theù arå intendeä tï bå used.

     Chapteò  ·  oæ  thå "Conceptó Manuaì  foò  ZCPR2¢  discusseó 
redirectablå  I/Ï  aó  iô caî bå implementeä  undeò  ZCPR2®   Thå 
reader is invited to refer to this for much more detail.


1.2  Loading Redirectable I/O Drivers -- IOLOADER

     IOLOADEÒ  ió useä tï loaä aî indicateä oò implieä I/Ï driveò 
packagå  intï  youò redirectablå I/Ï buffeò  area®   IOLOADEÒ  ió 
invoked by one of the following forms:

          IOLOADER //              <-- Print Help Message
          IOLOADER                 <-- Load SYSIO.IO
          IOLOADER filename        <-- Load filename.IO
          IOLOADER filename.typ    <-- Load filename.typ

     Notå  thaô  thå  DIRº  prefiø ió  NOÔ  supporteä  witè  thió 
program®   Iî alì caseó oæ loadinç files¬ IOLOADEÒ searcheó alonç 
thå ZCPR² patè foò thå indicateä oò implieä file®  Oncå found¬ iô 
is loaded into your redirectable I/O buffer.

     GENINÓ  ió useä tï instalì IOLOADER¬  anä IOLOADEÒ neeä onlù 
kno÷ thå addresó oæ thå externaì path¬ thå symboì foò thå currenô 
useò anä disë indicator¬  anä thå addresó oæ thå redirectablå I/Ï 
buffer®  STARTUĞ maù bå useä tï automaticallù executå IOLOADEÒ oî 
Colä Boot¬  or¬  aó ST¬  STARTUĞ maù bå useä tï executå  IOLOADEÒ 
wheneveò á directorù ió loggeä intï bù CD.

1.3  Displaying and Selecting Redirectable I/O Drivers -- DEVICE

     DEVICE¬  oò  DEVICE²  (sï calleä becauså iô  ió  thå  seconä 
generatioî  oæ mù DEVICÅ program)¬  ió useä tï allo÷ thå useò  tï 
interactivelù displaù thå nameó oæ thå availablå physicaì deviceó 
(actually¬  devicå  drivers© whicè maù bå assigneä tï thå logicaì 
deviceó  anä tï allo÷ thå useò tï assigî á physicaì devicå  tï  á 
logical device by name.Š
     DEVICE is invoked by one of the following forms:

          DEVICE //           <-- Print Help Info
          DEVICE              <-- Enter Interactive Command Mode
          DEVICE cmd,cmd,...  <-- Immediately Execute Commands

     Iî  alì cases¬  wheneveò yoõ arå givinç commandó tï  DEVICE¬ 
whetheò  iô  ió  froí thå commanä leveì oæ ZCPR² oò  froí  withiî 
DEVICÅ itself¬  yoõ caî specifù á serieó oæ commandó separateä bù 
commas.

     The following commands can be given to DEVICE:

          DISPLAY ALL or CON or LST or RDR or PUN
               <-- Display Physical Device Driver Names which
                    can be assigned to CON:, LST:, RDR:, or PUN:
                    Logical Devices; also display the current
                    assignment

          CON or LST or RDR or PUN = Device
               <-- Assign a Physical Device Driver to a Logical
                    Device

     Iî alì cases¬ onlù thå firsô letteò oæ DISPLAÙ anä thå firsô 
letteò oæ á Logicaì Devicå oò thå worä "ALL¢ ió  necessary®   Alì 
otheò  letteró  arå ignored®   Thå completå namå oæ  thå  device¬ 
however, is necessary.

     Also¬   thå   spacå  anä  thå  characteò  "=¢  maù  bå  useä 
interchangably and case is not significant.

     The following are examples of DEVICE commands:

          D C,D L or D=C,D=L
               Display CON: and LST: Devices

          con:=crt,list=tty,reader=modeí oò c=crt,ì tty,r=modem
               Select the Physical Device Driver called CRT for
               the CON: Logical Device, select TTY for the LST:
               Logical Device, and select MODEM for the RDR:

     Thå  followinç terminaì sessioî furtheò illustrateó thå  uså 
oæ DEVICÅ witè mù particulaò seô oæ Redirectablå I/Ï Drivers®  Mù 
comments are indicated by <<--.


B7>device display console
DEVICE2, Version 1.3

CON: Devices --
        CRTMOD2  - Televideo 950 CRT Input and CRT/Modem Output
        CRTREM   - Televideo 950 CRT Input and CRT/Remote Output
        CRTMOD   - Televideo 950 CRT and Modem in Parallel
        CRT      - Televideo 950 CRT
        TTY      - Model 43 Printing Terminal
  Current Assignment: CRTMOD  

B7>device
DEVICE2, Version 1.3
DEVICE2 Interactive Command System
Type ? and Strike RETURN for Help
DEVICE2 Command? d l,lst:=modem         <<-- Multiple Commands in
                                        <<-- Free Format
LST: Devices --
        MODEM    - DC Hayes Smartmodem
        REMOTE   - Remote Computer
        CRT      - Televideo 950 CRT
        TTY      - Model 43 Printing Terminal
  Current Assignment: TTY     
DEVICE2 Command? display list

LST: Devices --
        MODEM    - DC Hayes Smartmodem
        REMOTE   - Remote Computer
        CRT      - Televideo 950 CRT
        TTY      - Model 43 Printing Terminal
  Current Assignment: MODEM   

DEVICE2 Command? l tty             <<-- Assign Device
DEVICE2 Command? l ttyx            <<-- How DEVICE Handles Errors
Invalid Name Assignment at -- TTYX
DEVICE2 Command? d l

LST: Devices --
        MODEM    - DC Hayes Smartmodem
        REMOTE   - Remote Computer
        CRT      - Televideo 950 CRT
        TTY      - Model 43 Printing Terminal
  Current Assignment: TTY     


DEVICE2 Command? ?                 <<-- Built-In Help
DEVICE2 Commands are of the form:
Command,Command, ...    <-- Issue Commands
where "command" may take the following forms:
                DISPLAY=ALL     <-- Display Names of All Devices
                DISPLAY=CON     <-- Display Names of Consoles
                DISPLAY=LST     <-- Display Names of Printers
                DISPLAY=RDR     <-- Display Names of Readers
                DISPLAY=PUN     <-- Display Names of Punches

                CON:=name       <-- Select Console
                LST:=name       <-- Select Printer
                RDR:=name       <-- Select Reader
                PUN:=name       <-- Select Punch


Á commanä linå beginninç witè á semicoloî (;© ió á comment®  
Thå Ø Commanä Exitó DEVICE2.

DEVICE2 Command? x            <<-- Exit



1.4  Controlling the Disk Output Facility -- RECORD

     RECORÄ  ió  useä tï controì thå Disë Outpuô Facilitù oæ  thå 
Redirectablå I/Ï Drivers®   Copieó oæ Consolå anä Printeò outputó 
caî bå createä iî disë fileó bù thå uså oæ thió facility¬  anä iô 
maù bå extendeä intï á numbeò oæ otheò applicationó aó well.

     RECORD is invoked by one of the following forms:

          RECORD or RECORD //           <-- Get Help
          RECORD ON or OFF              <-- Console Recording
          RECORD ON or OFF PRINTER      <-- Printer Recording

     Foò RECORÄ tï perforí itó function¬  iô musô bå  implementeä 
iî thå Redirectablå I/Ï Drivers®  Thió ió lefô aó aî exerciså foò 
thå  reader®   Thå  Redirectablå I/Ï Driveró supplieä witè  ZCPR² 
havå  simplå RETurî instructionó aó thå subroutineó  executeä  bù 
the RECORD functions.


     Fouò  routineó  arå accesseä iî thå Redirectablå I/Ï  Driveò 
package to control the RECORD function.  They are:

          COPEN -- Open File for Recording Console Output
          LOPEN -- Open File for Recording List Output
          CCLOSE -- Close File for Recording Console Output
          LCLOSE -- Close File for Recording List Output

     Iî  thå caseó oæ COPEÎ anä LOPEN¬  theù arå passeä á pointeò 
tï  thå  firsô twelvå byteó oæ aî FCÂ iî HL®   Theù arå  tï  copù 
theså  twelvå  byteó  intï theiò internaì FCBó anä  uså  theí  tï 
definå thå filå names®   Typically¬ thå outpuô fileó generateä bù 
thå  RECORÄ functioî arå placeä iî thå currenô  directory¬  althï 
thå  Redirectablå  I/Ï Driveró maù bå configureä  tï  placå  theí 
anywherå desired.

     Wheî  RECORÄ  ió  invokeä  tï  turî OÎ  onå  oæ  thå  recorä 
functions¬ iô promptó thå useò foò thå namå oæ thå filå tï recorä 
into®  RECORÄ theî calló thå appropriatå OPEÎ routine.

     Thå  RECORÄ  prograí knowó iæ disë filå outpuô  driveró  arå 
availablå thrõ thå Redirectablå I/Ï Packagå Statuó  Routine®   Iæ 
Registeò Á ió returneä witè thå high-ordeò biô set¬  sucè driveró 
arå available.

     RECORÄ  ió tieä intï thå Redirectablå I/Ï Packageó anä workó 
witè  them®   Thå readeò ió inviteä tï refeò tï thå  Installatioî 
Manuaì  anä  thå  Conceptó  Manuaì  foò  furtheò  detaiì  oî  thå 
organizatioî anä functioî oæ sucè packages.

     RECORÄ ió alsï indirectlù tieä intï DEVICE®  Invokinç RECORÄ 
itselæ   doeó  noô  necessarilù  starô  thå   recordinç   procesó 
immediately®   Twï  functionó musô takå placå tï begiî  recordinç 
outpuô ontï disë files:

          1) RECORD has to turn the appropriate Driver ON
          2) DEVICE has to select the appropriate Driver

     Thió leadó tï interestinç possiblities®   Bù turninç  RECORÄ 
OFÆ  durinç  á recordinç session¬  thå outpuô filå ió closeä  anä 
availablå  foò otheò uses®   Iæ RECORÄ ió lateò  turneä  ON¬  thå 
outpuô  filå  maù  bå deleteä (iæ thå samå filå  ió  selecteä  tï 
recorä into)®   However¬ iæ á ne÷ devicå ió selecteä whilå RECORÄ 
ió  OÎ  (say¬  DEVICÅ  CON:=CRÔ ió  issued)¬  theî  recordinç  ió 
SUSPENDEÄ (NOÔ turneä off© untiì thå recordinç devicå ió selecteä 
again®   Hence¬  iæ  iô  lookó likå thå recordinç sessioî ió  noô 
goinç well¬  recordinç caî bå suspended¬  thå probleí fixed¬  anä 
theî recordinç caî bå resumed.


     Thió  combineä systeí oæ DEVICÅ anä RECORÄ provideó  á  verù 
flexiblå  outpuô  recordinç  system®   Iî  addition¬  thå  outpuô 
recordinç  neeä noô necessarilù gï tï á disë file®   Iô coulä  bå 
seô uğ tï senä CONº outpuô tï thå CRÔ and¬ say¬ á Remotå Computeò 
foò  processing®   Thå systeí caî bå configureä iî á largå numbeò 
oæ ways.


1.5  Redirectable I/O and the ZCPR2 System

     Thå  ZCPR² Systeí caî functioî witè oò withouô  Redirectablå 
I/Ï  aó implementeä bù thå Redirectablå I/Ï Driveò  Packageó  anä 
thå IOLOADER¬  DEVICE¬ anä RECORÄ programs®  Obviously¬ thå ZCPR² 
System is made much more flexible by employing these facilities.

     DEVICÅ  anä RECORÄ arå tieä directlù tï thå Redirectable I/Ï 
Packageó themselves®  Theù don'ô uså anù oæ thå otheò featureó oæ 
thå  ZCPR² Systeí tï speaë of¬  anä theù arå installeä bù  GENINÓ 
(theù neeä tï kno÷ wherå thå Redirectablå I/Ï Buffeò ió located)®  
IOLOADEÒ alsï needó tï bå tolä wherå thå Redirectablå I/Ï  Buffeò 
ió  locateä  bù GENINS¬  anä iô useó thå ZCPR² patè tï  finä  itó 
files.

     Thå  programó  controllinç thå Redirectablå I/Ï Driveró  arå 
tied together in this manner:

          IOLOADER loads the drivers
          DEVICE controls the drivers
          RECORD enables and disables the disk recording
               facilities of the drivers


1.6  On the Programming of Terminals

     Thå CRÔ Terminal¬ whicè ió usuallù thå principaì devicå useä 
aó  á  consolå foò CP/Í anä ZCPR2¬  ió á first-linå tooì  oæ  thå 
user®   Iô  ió thå devicå througè whicè hå seeó thå worlä oæ  hió 
microcomputer¬ and¬ aó such¬ É feeì thaô iô shoulä bå aó flexiblå 
anä complianô á tooì aó possiblå foò him¬ bendinç tï hió wilì anä 
doing as much work for him as possible.

     É  founä thaô thå Televideï 95° provideä á loô oæ  thå  fea
tureó  thaô É wanteä tï seå iî á terminal®   Iô sooî becamå  evi
dent¬  however¬ thaô iô waó necessarù tï seô uğ á seô oæ softwarå 
undeò  ZCPR² whicè woulä prograí thå TVÉ 95° sï thaô É coulä makå 
betteò uså oæ it®   Thå TVÉ 95° ió whaô É woulä calì aî  intelli
genô  terminal¬  havinç  á built-iî microcomputeò whicè  provideó 
offlinå  editinç anä manù otheò  features¬  includinç  character-
strinç  programmablå functioî keyó anä á statuó line¬  whicè makå 
lifå much¬  mucè nicer®   É havå createä twï programs¬ CONFIÇ anä 
TINIT¬  whicè  prograí thió terminaì tï mù tastes®   Thå useò  ió 
inviteä tï reaä thå built-iî documentatioî anä thå  documentatioî 
iî thå sourcå code.
.fo Section 2 - The ZCPR2 Directory Utility XDIR3      Page   #

2.0  Directory Utility

2.1  Overview of XDIR3

     XDIR³  ió aî extendeä directorù displaù utilitù designeä  tï 
ruî  undeò CP/Í 2.² anä supporô somå oæ thå extendeä featureó  oæ 
ZCPR² aó well®  Anù conventionaì CP/Í 2.² useò maù uså XDIR3¬ buô 
hå  shoulä makå surå hå turnó ofæ thå ZCPR2-specifiã featureó  bù 
runninç  thå  ZCPR² Installatioî Program¬  GENINS¬  oî XDIR³  anä 
manuallù turninç theí ofæ beforå usinç XDIR3.

     XDIR³  automaticallù  adaptó tï anù Org-° CP/Í  2.²  system¬ 
regardlesó oæ thå sizå oæ itó disks®  Iô readó thå disë parameteò 
blocë informatioî froí thå operatinç systeí tï determinå whaô thå 
attributeó  oæ  thå  disë iô ió workinç witè  are¬  anä  iô  theî 
presentó itó displaù informatioî accordingly.

     XDIR3 runs in two basic modes:
          . as a directory display utility
          . as a file scanner utility (File Name Buffer Facility)

     XDIR³  ió á ZCPR² utilitù whicè supportó thå extendeä  ZCPR² 
features¬ particularlù nameä directories.

     Aó   á  directorù  displaù  utility¬   iô  displayó  tï  yoõ 
informatioî  abouô  thå fileó oî á particulaò disë  iî  alì  useò 
areaó  oò  á particulaò useò area®   Iô giveó yoõ  thå  followinç 
information:

          . Name of File
          . Size of File (in K bytes)
          . Attributes of File (Read/Only or System)
          . Sum of Sizes of All Files Displayed
          . Total Number of Files on Disk
          . Amount of Space Remaining on Disk
          . What Disk and What User Area you are looking at

     Aó á filå scanneò utility¬ iô doeó thå following:

          . Logs a group of selected files to disk for later scan
          . Prints the contents of such a log file
          ® Scanó á loç filå anä compareó iô witè thå fileó
               selected by you, telling you what files are
               missing and what files are additional


     XDIR³ ió quitå human-oriented¬  witè manù built-iî  featureó 
whicè  providå  á  human-interfacå typå oæ servicå tï  thå  user®  
Some of these include:

          . Named Directories may be specified
          . The file listing is alphabetized by file name and
               type or file type and name, depending on user
               preference
          . The file listing is organized vertically or
               horizontally, depending on user preference
          . Output may also be sent to disk or printer
          ® XDIR³ ió designeä tï ruî quickly



2.2  Basic Use of XDIR3 under ZCPR2

     XDIR3 is invoked by one of the following command lines:

          XDIR afn oooo... or XDIR afn /oooo...
and
          XDIR /oooo...

where all elements after the XDIR command are optional.

     'afn§  ió aî ambiguouó filå reference¬  aó describeä oî  thå 
followinç frames®   'o§ ió aî optioî letter¬ whicè ió onå oò morå 
oæ  thå optionó describeä oî thå nexô frame®   Notå thaô sincå  á 
slasè denoteó thaô aî optioî follows¬ aî afî maù noô begiî witè á 
slash®   Thió  caî bå changeä bù aî equatå iî thå sourcå codå  oæ 
XDIR3 if desired.

          Aa - Set the attributes of the files to be displayed
               a=S for System Files, a=N for Non-System Files
               a=A for All Files (Non-System and System)
          D  - Send Output to Disk
          Ff - Engage File Name Buffer Facility
               f=L to Log File Names to Disk
               f=P to Print Names Logged to Disk
               f=S to Scan Disk for File Names and Compare to
                    Log
          G  - Toggle Grouping (group files by name and type or
                    type and name)
          H  - Toggle Horizontal or Vertical display format
          I  - Inspect files selected by FL option
          N  - Negate Selection; select those files which do NOT
                    match the ambiguous file name
          P  - Send Output to Printer


     'afn' is an ambiguous file reference, of the general form:

          dir:filename.typ

where
     filename.typ   is a conventional CP/M ambiguous file name
                         (wild card characters of ? and * are OK,
                         but file name must NOT start with /)
     dir:           is a ZCPR2 directory specification, which may
                         be one of the following forms:
          d:        where 'd' is a disk letter (A-P) to indicate
                         the current user area on that disk
          u:        where 'u' is a user number (0-31) to indicate
                         that user on the current disk; 'u' may
                         be a '?', in which case all user areas
                         are selected
          du:       where 'du' specifies both disk and user
          name:     where 'name' is the name of a directory
                         (disk/user area)


     Examples of an ambiguous file reference are:

          A:FILE.TXT          A4:FILE.TXT
          ROOT:FILE.TXT       A?:*.COM
          12:*.*              A12:SYSLIB*.*

     Examples of XDIR3 commands are:

          XDIR ROOT:*.COM AAN
               -- Select All Files in directory ROOT which do
                  NOT match *.COM
          XDIR B10: ASD
               -- Select the System Files in B10, and send
                  output to disk as well as console
          XDIR /AADP
               -- Select All Files in current directory, and
                  send output to disk and printer as well as
                  console




2.3  XDIR3 Output Control Options

     These options are:

          D  - Send Output to Disk
          G  - Toggle Grouping (group files by name and type or
                    type and name)
          H  - Toggle Horizontal or Vertical display format
          P  - Send Output to Printer

     Ä anä Ğ arå fairlù obvious®   Iæ Ğ ió specified¬  thå outpuô 
goeó tï youò printeò (CP/Í LSTº  device© aó welì aó youò console®  
Iæ  Ä ió specified¬  thå outpuô goeó tï youò currenô directorù aó 
thå filå XDIR.DIR®  Iæ XDIR.DIÒ alreadù exists¬ iô ió replaced.

     Ç anä È arå toggleä options®  If¬ viá GENINÓ aô installatioî 
time¬  yoõ selecteä alphabetizatioî bù filå namå anä type¬  thå Ç 
optioî  wilì fliğ thió tï alphabetizå bù filå typå anä name¬  anä 
vice-versa®  Thå samå witè thå È option.

     Ç  allowó yoõ tï selecô youò displaù tï bå  alphabetizeä  bù 
filå  namå anä typå oò typå anä name®   Iæ bù filå namå anä type¬ 
theî AA.TXÔ comeó beforå BB.COM®   Iæ bù filå typå anä name¬ theî 
BB.COÍ  comeó beforå AA.TXT®   Alphabetizatioî bù filå  namå  anä 
typå groupó fileó oæ thå samå namå togetheò (FÎ fields¬  likå alì 
XDIR3.ª  files)¬  whilå bù filå typå anä namå groupó fileó oæ thå 
samå typå togetheò (FÔ fields¬ likå alì *.TXÔ files).

     È allowó yoõ tï selecô youò alphabetizeä fileó tï bå  listeä 
dowî  thå  screeî (vertical© oò acrosó thå  screeî  (horizontal)®  
Thå screeî ió divideä intï threå columns¬  anä á verticaì listinç 
alphabetizeó dowî thå firsô column¬ theî thå second¬ anä theî thå 
third¬ whilå á horizontaì listinç alphabetizeó first¬ second¬ anä 
third columns on the first line, and so on with each line.

     É  likå tï grouğ mù listingó bù filå typå  first¬  anä  theî 
name¬  anä  É alsï prefeò thå verticaì displaù format®   Herå  ió 
sucè á listing:



XDIR III, Version 1.5    Vertical Listing by File Type and Name
 Disk: B  User:   7, File Attributes:  Non-System

Filename.Typ Size K RS   Filename.Typ Size K RS   Filename.Typ Size K RS
-------- --- ------ --   -------- --- ------ --   -------- --- ------ --
SYSLIB  .ART    108      STD     .MSG      4      Z2INS   .WS      52      
XDIR3   .BAK     24      TALK    .SUM     12      Z2CON   .WSH      8      
DU2     .HLP     36      S100    .TXT      4      Z2INS   .WSH      8      
XDIR3   .HLP     24      Z2CON   .WS     112      
   11 Files Occupying   392K,    67 Files on Disk and  4020K Free

     Note that we are alphabetized down the columns by file type.

     Some prefer to alphabetize by file name:


XDIR III, Version 1.5    Vertical Listing by File Name and Type
 Disk: B  User:   7, File Attributes:  Non-System

Filename.Typ Size K RS   Filename.Typ Size K RS   Filename.Typ Size K RS
-------- --- ------ --   -------- --- ------ --   -------- --- ------ --
DU2     .HLP     36      TALK    .SUM     12      Z2CON   .WS     112      
S100    .TXT      4      XDIR1   .DIR      4      Z2CON   .WSH      8      
STD     .MSG      4      XDIR3   .BAK     24      Z2INS   .WS      52      
SYSLIB  .ART    108      XDIR3   .HLP     24      Z2INS   .WSH      8      
   12 Files Occupying   396K,    68 Files on Disk and  4016K Free

     Again¬  wå arå alphabetizeä dowî thå columns¬  buô thå ordeò 
ió  bù filå namå anä theî filå type®   Refeò bacë tï thå previouó 
screen display to compare.

     Finally¬  somå  prefeò  horizontaì aó  opposeä  tï  verticaì 
listings®   Herå  ió  anotheò  listinç whicè  ió  horizontaì  anä 
grouped by file name first.


XDIR III, Version 1.5    Horizontal Listing by File Name and Type
 Disk: B  User:   7, File Attributes:  Non-System

Filename.Typ Size K RS   Filename.Typ Size K RS   Filename.Typ Size K RS
-------- --- ------ --   -------- --- ------ --   -------- --- ------ --
DU2     .HLP     36      S100    .TXT      4      STD     .MSG      4      
SYSLIB  .ART    108      TALK    .SUM     12      XDIR1   .DIR      4      
XDIR2   .DIR      4      XDIR3   .BAK     24      XDIR3   .HLP     24      
Z2CON   .WS     112      Z2CON   .WSH      8      Z2INS   .WS      52      
Z2INS   .WSH      8      
   13 Files Occupying   400K,    69 Files on Disk and  4012K Free



2.4  XDIR3 File Selection Options

     Thå  followinç  optionó (anä thå DIRº  field©  controì  filå 
selection:

          Aa - Set the attributes of the files to be displayed
               a=S for System Files, a=N for Non-System Files
               a=A for All Files (Non-System and System)
          N  - Negate Selection; select those files which do NOT
                    match the ambiguous file name

     Thå Î optioî negateó youò ambiguouó filå namå reference¬ buô 
iô  stayó  iî thå SAMÅ seô oæ systeí oò  non-systeí  files®   Foò 
instance¬  XDIÒ  *.COÍ /NAÓ selectó alì SYSTEÍ fileó whicè dï NOÔ 
matcè *.COM®  Iæ yoõ havå installeä XDIR³ tï automaticallù selecô 
botè SYSTEÍ anä NON-SYSTEÍ files¬  theî XDIÒ *.COÍ /Î wilì selecô 
all non-COM files in your current directory.Š
     Thå  Á  optioî  setó  thå attributeó  oæ  thå  fileó  tï  bå 
displayed®   Iæ AÁ ió presented¬  theî botè Non-Systeí anä Systeí 
fileó wilì bå displayed®   Iæ AS¬  theî jusô Systeí files¬ anä iæ 
AN¬ theî jusô Non-System®

     Yoõ  caî  seô  thå  defaulô filå  attributå  displaù  tï  bå 
whateveò   yoõ  desire®    Usinç  GENINS¬   yoõ  caî  havå  XDIR³ 
automaticallù selecô jusô thå Systeí files¬  jusô thå  Non-Systeí 
files¬  oò  botè Non-Systeí anä Systeí fileó wheneveò yoõ ruî  iô 
withouô usinç thå Á option.


B7>xdir root:*.com aan

XDIR III, Version 1.5    Vertical Listing by File Type and Name
 Disk: A  User:  15, File Attributes:  Non-System System

Filename.Typ Size K RS   Filename.Typ Size K RS   Filename.Typ Size K RS
-------- --- ------ --   -------- --- ------ --   -------- --- ------ --
VITALS  .BAD      4 R    TEXT    .CFG      4 R    NAMES   .DIR      4      
ASM     .CFG      4 R    CPZM    .CPM     12 R    BAD     .DOC      8 R    
C       .CFG      4 R    CPZMH   .CPM     12 R    NOTESHD .DOC     16 R    
PASCAL  .CFG      4 R    FNAMES  .DIR      4      SYSIO   .IO       4 RS   
STD     .CFG      4 R    LD      .DIR      4      NEWDISK .ZEX      4 R    
   15 Files Occupying    92K,   266 Files on Disk and  1568K Free


     Thió selectó alì non-COÍ fileó iî thå directorù ROOT®   Botè 
Systeí anä Non-Systeí fileó arå selected®   Notå thaô SYSIO.IÏ ió 
thå  onlù  Systeí filå whicè waó selected¬  anä iô happenó tï  bå 
Read/Only as well.


B7>xdir root:*.com asn
XDIR III, Version 1.5    Vertical Listing by File Type and Name
 Disk: A  User:  15, File Attributes:  System

Filename.Typ Size K RS   Filename.Typ Size K RS   Filename.Typ Size K RS
-------- --- ------ --   -------- --- ------ --   -------- --- ------ --
SYSIO   .IO       4 RS   
    1 Files Occupying     4K,   266 Files on Disk and  1568K Free



     Thió selectó thå non-COÍ Systeí fileó iî thå directorù ROOT®  
As expected, SYSIO.IO is the only file given.


B7>xdir root:*.com n
XDIR III, Version 1.5    Vertical Listing by File Type and Name
 Disk: A  User:  15, File Attributes:  Non-System

Filename.Typ Size K RS   Filename.Typ Size K RS   Filename.Typ Size K RS
-------- --- ------ --   -------- --- ------ --   -------- --- ------ --
VITALS  .BAD      4 R    TEXT    .CFG      4 R    NAMES   .DIR      4      
ASM     .CFG      4 R    CPZM    .CPM     12 R    BAD     .DOC      8 R    
C       .CFG      4 R    CPZMH   .CPM     12 R    NOTESHD .DOC     16 R    
PASCAL  .CFG      4 R    FNAMES  .DIR      4      NEWDISK .ZEX      4 R    
STD     .CFG      4 R    LD      .DIR      4      
   14 Files Occupying    88K,   266 Files on Disk and  1568K Free

     Thió  selectó thå non-COÍ fileó iî thå directorù ROOÔ  whicè 
are Non-System.  Non-System is my selected default for XDIR3.



2.5  XDIR3 File Name Buffer Facility

     Thå  optionó oæ XDIR³ whicè deaì witè thå Filå  Namå  Buffeò 
Facility are:

          Ff - Engage File Name Buffer Facility
               f=L to Log File Names to Disk
               f=P to Print Names Logged to Disk
               f=S to Scan Disk for File Names and Compare to
                    Log
          I  - Inspect files selected by FL option

     Thå  filå selectioî optionó comå intï plaù aó welì witè  thå 
FÌ  optioî  tï selecô thå fileó tï bå placeä intï thå  loç  file¬ 
FNAMES.DIR.

     Thå  FÌ optioî writeó thå useò numberó anä filå nameó oæ thå 
selecteä  fileó  tï  disë intï thå  filå  nameä  FNAMES.DIR®   Iæ 
FNAMES.DIÒ alreadù exists¬  theî iô ió rewritten®  Thå FNAMES.DIÒ 
files is used by the FP and FS options.

     Thå  É  optioî  (foò inspect© allowó thå  useò  tï  manuallù 
approve each file before its name is placed into FNAMES.DIR.

     Thå  FĞ optioî simplù printó ouô thå useò numberó anä  nameó 
oæ alì thå fileó storeä iî FNAMES.DIR®   Iæ FNAMES.DIÒ ió noô  iî 
thå currenô directory¬  FĞ wilì searcè alonç thå ZCPR² patè untiì 
it finds it or reaches the end of the path.


     Thå FÓ optioî scanó FNAMES.DIÒ anä thå fileó selecteä bù thå 
useò  (oò implieä iæ nï specifiã filå selectioî optioî ió  given© 
anä compareó them®  Iæ á filå existó iî FNAMES.DIÒ buô noô iî thå 
selecteä files¬ itó namå ió printeä aó á missinç file®  Iæ á filå 
existó  oî disë buô noô iî thå FNAMES.DIÒ file¬  theî itó namå ió 
printed as an additional file.

     Notå  thaô thå useò shoulä keeğ iî minä whaô hå ió  scanninç 
foò wheî hå useó thå Filå Namå Buffeò Facility®  Foò instance¬ iæ 
hå  selectó botè Non-systeí anä Systeí fileó witè thå  FÌ  optioî 
anä theî defaultó tï Non-Systeí witè thå FÓ option¬  theî severaì 
files will come up missing while this is not necessarily true.

     Usinç GENINS¬  thå Installatioî Prograí foò ZCPR2¬  yoõ  caî 
creatå  twï  differenô  versionó oæ XDIR³  -- onå  foò  Directorù 
Displaù   operationó  anä  onå  foò  Filå  Namå  Buffeò  Facilitù 
functions®  Iæ yoõ dï this¬ theî yoõ coulä alsï seô thå Directorù 
Displaù versioî tï worë witè Non-Systeí fileó bù  default¬  whilå 
yoõ  coulä seô thå Filå Namå Buffeò Facilitù versioî tï worë witè 
botè Non-Systeí anä Systeí files.

     Thå followinç ió á samplå terminaì sessioî whicè illustrateó 
thå  uså oæ thå XDIR³ Filå Namå Buffeò  Facility®   Commentó  arå 
placeä ouô tï thå sidå oæ thå commandó anä arå denoteä bù "<--".

B7>xdir /fli        <-- Log Files to Disk and Inspect

XDIR III, Version 1.5
Inspection of Files for Logging to Disk
Log  7 DU2     .HLP   to Disk (Y/N/<CR>=Y)? Y
Log  7 S100    .TXT   to Disk (Y/N/<CR>=Y)? N
Log  7 STD     .MSG   to Disk (Y/N/<CR>=Y)? N
Log  7 SYSLIB  .ART   to Disk (Y/N/<CR>=Y)? N
Log  7 TALK    .SUM   to Disk (Y/N/<CR>=Y)? N
Log  7 TEMP    .TXT   to Disk (Y/N/<CR>=Y)? Y
Log  7 XDIR3   .HLP   to Disk (Y/N/<CR>=Y)? Y
Log  7 Z2CON   .WS    to Disk (Y/N/<CR>=Y)? Y
Log  7 Z2CON   .WSH   to Disk (Y/N/<CR>=Y)? Y
Log  7 Z2INS   .WS    to Disk (Y/N/<CR>=Y)? Y
Log  7 Z2INS   .WSH   to Disk (Y/N/<CR>=Y)? Y

Logging File Names to Disk --
         7 File Names to be Logged to Disk
     Horizontal Listing by File Name and Type
 U Filename.Typ   U Filename.Typ   U Filename.Typ   U Filename.Typ
 - -------- ---   - -------- ---   - -------- ---   - -------- ---
 7 DU2     .HLP   7 TEMP    .TXT   7 XDIR3   .HLP   7 Z2CON   .WS   
 7 Z2CON   .WSH   7 Z2INS   .WS    7 Z2INS   .WSH  


B7>xdir /fp         <-- Print out the names of the logged files
XDIR III, Version 1.5

Printout of Recrded File Names --
         7 File Names Recorded
     Horizontal Listing by File Name and Type
 U Filename.Typ   U Filename.Typ   U Filename.Typ   U Filename.Typ
 - -------- ---   - -------- ---   - -------- ---   - -------- ---
 7 DU2     .HLP   7 TEMP    .TXT   7 XDIR3   .HLP   7 Z2CON   .WS   
 7 Z2CON   .WSH   7 Z2INS   .WS    7 Z2INS   .WSH  

B7>era temp.txt          <-- Erase one of the logged files
TEMP    .TXT             <--   for this demo
B7>xdir /fs              <-- Scan the disk

XDIR III, Version 1.5
File Name Scanner
Files Named in FNAMES.DIR missing from Disk --
     Horizontal Listing by Fie Name and Type
 U Filename.Typ   U Filename.Typ   U Filename.Typ   U Filename.Typ
 - -------- ---   - -------- ---   - -------- ---   - -------- ---
 7 TEMP    .TXT  
Additional Files on Disk NOT in FNAMES.DIR --
     Horizontal Listing by File Name and Type
 U Filename.Typ   U Filename.Typ   U Filename.Typ   U Filename.Typ
 - -------- ---   - -------- ---   - -------- ---   - -------- ---
 7 FNAMES  .DIR   7 S100    .TXT   7 STD     .MSG   7 SYSLIB  .ART  
 7 TALK    .SUM  
File Scan Complete



2.6  Use of XDIR3 on Secure Systems

     Oî Securå Systems¬ sucè aó Remotå CP/Í Systems¬ XDIR³ maù bå 
configured¬  viá GENINS¬  tï providå á securå directorù  utility®  
Somå ideaó alonç thió linå include:

          . You can install XDIR3 so that it cannot look at any
               directory other than the one it is in
          . You can install XDIR3 so that you can look at the
               current user area on any disk, but not in other
               user areas
          . You can install XDIR3 so that you can look at all
               user areas on the current disk, but not on any
               other disk
          . You can install XDIR3 so that you cannot look at any
               System files
          . You can install XDIR3 so that none of the F options
               are available
          ® Yoõ caî instalì XDIR³ sï thaô useró maù lisô thå
               files (FP) or scan the disk (FS), but not log
               files to disk (FL)

     Theså arå jusô somå oæ thå wayó É havå designeä XDIR³ tï  bå 
flexiblå iî theså typeó oæ environments®   Iî á morå conventionaì 
environment¬  sucè  aó  á softwarå developmenô  environment¬  yoõ 
woulä  probablù  wanô  XDIR³  tï  givå  yoõ  completå  accesó  tï 
everything.

     Seå  thå  nexô sectioî oî installatioî foò morå  detailó  oî 
setting XDIR3 capabilities and defaults.

2.7  Installation of XDIR3

     GENINÓ  ió thå installatioî prograí whicè comeó  alonç  witè 
ZCPR²  anä  allowó thå useò tï definå thå basiã capabilitieó  anä 
defaulô  functionó  executeä  bù á particulaò  copù  oæ  á  ZCPR² 
utility®   GENINÓ ió awarå oæ thå specifiã requirementó oæ alì oæ 
thå  keù ZCPR² utilities¬  includinç XDIR3¬  anä adaptó foò  eacè 
utility'ó specifiã needs.

     Wheî  GENINÓ ió executed¬  iô askó thå useò foò thå namå  oæ 
thå filå tï bå installed®   Thå useò maù specifù thió filå iî thå 
normaì ZCPR² format:

          dir:filename.typ

     GENINÓ  wilì  reaä  thå  firsô blocë  oæ  thió  file¬  whicè 
containó thå customizatioî information¬  anä theî allo÷ yoõ tï dï 
onå oæ threå thingó (itó basiã commanä prompt):

          . Display the Current Features
          . Set the Features of the program to the user's liking
          . Exit and optionally create a new COM file

     Thå  featureó  whicè maù bå seô bù thå systeí manageò  undeò 
GENINS for XDIR3 are:

          . Whether the user may specify a directory (disk/user)
          . If directory specification is allowed, whether the
               user may specify just disk or just user (but not
               necessarily both)
          . Whether the user may employ any of the F options
          . If the F options may be used, if the user may employ
               the FL option specificially
          . Whether the user may employ the AS option
          . Whether XDIR3 will perform a Directory Display
               of File Name Buffer Facility function by default
          . Whether XDIR3 will display Non-System or System files
               (or both) by default
          . Whether the alphabetization will be by file name and
               type or type and name by default
          . Whether the listing will be vertical or horizontal by
               default
          ® Whetheò ZCPR² Externaì Pathó arå available¬ and¬ iæ
               so, what the base path address is
Š
     Iæ  thå useò ió noô runninç ZCPR2¬  hå shoulä disablå alì oæ 
the ZCPR2 features.

















               This Page Intentionally Left Blank

                    For the Sake of My Sanity

   Figuring This One Out is Left as an Exercise for the Reader



.fo Section 3 - Disk Utility                           Page   #

3.0  Disk Utility

3.1  Invoking DU2 and DU2 Installation

     DU2 is invoked by a command line of the following form:

          DU2 <text>

wherå <text¾ ió anù valiä DU² commanä sequence®  Iæ thå firsô twï 
characteró  oæ  <text¾ arå '/?'¬  thå built-iî  documentatioî  ió 
displayeä  anä thå useò ió returneä tï CP/M¬  aó peò thå  TOOLSEÔ 
Convention.

  Examples:

   DU2 /?
     -- Displaù Built-iî Documentation

   DU2 lb,g0,d
     -- Executå  commandó tï Loç iî Drivå B¬  gotï Grouğ  0¬  anä 
displaù thå firsô Blocë oæ Grouğ 0

     DU²  ió designeä tï bå installeä witè á minimuí oæ  trouble® 
Iî  fact¬  iî  almosô alì cases¬  nï changeó tï thå  sourcå  filå 
shoulä  bå necessarù tï geô DU² uğ anä running®  Thió ió  becauså 
DU² useó thå disë parameteò blocë oæ CP/Í tï determinå thå  char-
acteristicó oæ thå disë environment.

     Thå  onlù parameteró thaô shoulä neeä tï bå changeä wilì  bå 
thå clocë speeä flaç anä thå numbeò oæ lineó oî thå CONº  Device® 
GENINÓ caî bå useä tï perforí thió installation® 

     DU² ió intendeä foò uså oî á ZCPR² system®  Aó such¬ iô wilì 
onlù  ruî witè á Z8° microprocessoò anä oî á CP/Í 2.² (oò higher© 
system® DU² wilì NOÔ ruî oî CP/Í 1.4.


3.2  DU2 Command Summary

@    Exec Prev Command             =data     Search for data
<    Save Current Block in Temp    >         Get Saved Block
<B   Save Current Block on Queue   >B        Get Block from Queue
<G   Save Current Group on Queue   >G        Get Current Group
<Gn  Save Group N on Queue         >Gn       Get Group N
#    Print Disk Stats              ?         Print Help Info
+n   Advance to Next Sector        -n        Back up to Last Sec
!    Halt and Wait for User        /nn       Repeat Command Line

n    Exec Macro (0<=n<=9)          :n<text>  Define Macro n
 :Pn Print Macro n                 :PA       Print All Macros
 :P@ Print Prev Command

An-n      ASCII Dump               Hn-n      Hex Dump
Dn-n      ASCII and Hex Dump

CAn vals or CAn1-n2 val       Change ASCII Values
CHn vals or CHn1-n2 val       Change Hex Values

Ffile     Find File                Uu        Set User u for F

Tn   Position to Track n (dec)     Sn        Position to Sec n
Gn   Position to Group n (hex)     G         Show position

Ld   Log in Disk                   N         New Disk

M    Map Disk                      Mn        Show file in Group n

P    Toggle Printer

Q    Print Queue Statistics        QZ        Zero (Empty) Queue
QSfile    Save Queue as File

R    Read Current Block            W         Write Current Block

Vn   View n blocks                 Zn        Sleep n Seconds

X    Exit to CP/M; opt Warm Boot   ^C        Exit to CP/M

     Á  commanä linå maù consisô oæ onlù onå commanä oò á  serieó 
oæ  commandó  separateä  bù commas®   Iî  thå  latteò  form¬  thå 
commandó arå executeä sequentially®   Thå onlù exceptionó tï thió 
rulå  arå thå :ntexô commanä (whicè storeó thå commanä linå  awaù 
aó á macro© anä thå *nî commanä (whicè repeató thå commanä line).


3.3  Commands for Logging and Viewing Disk Parameters

     Thå  followinç commandó arå discusseä iî thió sectioî oæ thå 
HELP file:

          F -- Find File
          L -- Log in Disk
          N -- New Disk (Reset Disk System)
          M -- Map Disk Directory
          U -- Select User Number
          # -- Print Disk and Queue Statistics


                          Ffilename.typ

     Prinô  directorù  foò  filå  "filename.typ"®   Thió  commanä 
presentó  thå  directorù  entrù  foò  thå  firsô  extenô  oæ  thå 
indicateä  file®   Seå  thå  sectioî  oî  "Interpretinç  thå  DU² 
Directorù  Display¢ foò infï oî ho÷ tï interpreô thå  informatioî 
presented.

     Example (actual DU2 session):

DU2  B1? fz80.mac
40  015A3830 20202020  204D4143 0000000E  *.Z80     MAC....*
50  9A000000 00000000  00000000 00000000  *................*
Group = 0000:00, Track = 122, Sector = 1, Physical Sector = 1

DU2  B1? ftest.txt
++ File Not Found ++
Group = 0000:00, Track = 122, Sector = 1, Physical Sector = 1


                              L[d]

     Thå simplå "L¢ commanä re-logó iî thå currenô disk®  Yoõ maù 
pulì ouô á disk¬  puô iî á new¬  anä "L¢ jusô tï loç iô in®   Thå 
forí "Ld"¬  wherå ä ió á valiä drivå letteò (likå "LB")¬  ió useä 
tï  loç  iî  á  specifiã disë anä permiô  yoõ  tï  worë  oî  thaô 
particulaò disë froí thió timå foreword.

     Example (actual DU2 session):

DU2  B1? l

DU2  B1? la

DU2  A1? lb


                                N

     Thió  telló DU² thaô yoõ jusô puô iî á ne÷ disk®  Foò  thoså 
BIOÓ  implementationó thaô neeä tï bå tolä  specificallù  (Reset© 
thaô á disë changå haó beeî made¬ uså thió commanä everù timå yoõ 
changå á disë whilå DU² ió running.

     Example:

DU2  B1? n

     Noteº   Therå  waó  á  significanô delaù beforå  thå  prompô 
returned.  A complete disk system reset took place.



                              M[n]

     Dumpó  á  mağ oæ thå grouğ allocationó foò files®  Mî  showó 
whicè filå ió allocateä tï grouğ "n".

     Example (actual DU2 session, edited):

DU2  B1? m
0010-0010  07 STD     .MSG 00 : 0011-0011  07 TALK    .SUM 00 
0012-0012  07 Z2CON   .WSH 00 : 0013-0013  00 LDIR    .C   00 
0014-0014  00 COMMAND .LBR 01 : 0015-0015  00 LDIR    .C   00 
     < Detail Left Out >
004B-004B  08 MASTER  .CAT 03 : 004C-0050  00 COMMAND .LBR 05 
0051-0051  00 COMMAND .LBR 07 : 0052-0052  00 UNERA15 .COM 00 
0053-0053  08 MENU    .CPR 00 : 0054-0057  00 COMMAND .LBR 07 
Type Any Character to Continue or ^C to Abort - 
DU2  B1? m54
0054-0057  00 COMMAND .LBR 07 : 
Group = 0000:00, Track = 122, Sector = 1, Physical Sector = 1


     The entries are divided up as follows:

0010-0010  07 STD     .MSG 00 : 0011-0011  07 TALK    .SUM 00 
  ^        ^    ^          ^
  |        |    Filename   Extent
  |        User Number
  Group Range


                               Uu

     Logó useò 'u§ foò nexô Æ (Finä File© command.

     Example (actual DU2 session):

DU2  B1? u7

DU2  B7? u1


                                #

     Prints the disk parameters:

     . Current Disk Drive          . Number of Tracks on Disk
     . Size of Group in Blocks     . Number of Sectors Per Track
     . Number of Groups on Disk    . Number of Directory Entries
     . Number of System Tracks

     Prints the queue statistics:

     . Size of Queue               . Space Available

     Example (actual DU2 session):


DU2  B1? #
+=============================+
|    -- Queue Information --  |
+-----------------------------+
0 Blocks in Queue
249 Blocks Left in Queue
Address of Head of Queue: 3E00 Hex
Address of Tail of Queue: 3E00 Hex


+=============================+
|    -- Disk Information --   |
+-----------------------------+

Disk Drive:         B
Tracks:             244
Sectors/Track:      336
Group Size:         32 Blocks/Group
Total Groups:       1280
Directory Entries:  512
System Tracks:      122
===============================


3.4  Commands for Positioning and Reading Data

     Thå followinç commandó arå discusseä iî thió sectioî oæ  thå 
HELP file:

          G -- Position to Group
          S -- Position to Sector
          T -- Position to Track
          R -- Read Block
          W -- Write Block
          + -- Advance to Next Logical Sector
          - -- Backup to Last Logical Sector



                              G[nn]

     Positioî tï grouğ nî anä reaä block®   Iæ thå forí ió simplù 
"G", show your current position.

     Example (actual DU2 session):

DU2  B1? g0
Group = 0000:00, Track = 122, Sector = 1, Physical Sector = 1

DU2  B1? g4
Group = 0004:00, Track = 122, Sector = 129, Physical Sector = 129

DU2  B1? g
Group = 0004:00, Track = 122, Sector = 129, Physical Sector = 129

DU2  B1? g0
Group = 0000:00, Track = 122, Sector = 1, Physical Sector = 1



                           Tnn and Snn

     "Tnn¢  doeó  á seeë tï tracë nî buô doeó noô reaä  á  block®  
"Snn¢  positionó tï sectoò nî oî thå currenô tracë anä readó  thå 
blocë there.  Example (actual DU2 session):

DU2  B1? t124
Group = 0015:00, Track = 124, Sector = 1, Physical Sector = 1

DU2  B1? s24
Group = 0015:17, Track = 124, Sector = 24, Physical Sector = 24


                             R and W

     Ò readó thå blocë currentlù positioneä tï intï memory®  Notå 
Ò (Read© ió impliciô iî thå G¬  +¬ anä - commands¬ buô NOÔ iî thå 
Ó anä Ô commands.

     × writeó bacë thå currenô blocë (NOTEº maù noô bå useä afteò 
aî  Æ  command¬  aó  CP/Í  waó  useä tï  finä  thå  filå  iî  thå 
directory).

     Examples:

DU2  B1? r

DU2  B1? w


                         +[nn] and -[nn]

     "+¢  advanceó ± sectoò (iæ belo÷ tracë 2¬  thió advanceó  tï 
nexô  numericaì  sectoò anä iæ ² oò more¬  advanceó baseä oî  thå 
system'ó sectoò skewinç algorithm¬  i.e®  sï « wilì geô thå  nexô 
logicaì sectoò oæ thå file)®  "-¢ backupó uğ ± sectoò iî thå samå 
sense.

     Notå « anä - maù takå aî amountº  foò example¬  +1µ stepó iî 
1µ sectors® Notå alsï thaô "-¢ issueä aô thå firsô logicaì sectoò 
oæ  thå  disë wilì wrağ bacë tï thå lasô anä "+¢ issueä  aô  lasô 
sectoò wilì wrağ forwarä tï thå first.

     Examples (actual DU2 session):

DU2  B1? g0
Group = 0000:00, Track = 122, Sector = 1, Physical Sector = 1

DU2  B1? d
00  07535444 20202020  204D5347 00000002  *.STD     MSG....*
10  10000000 00000000  00000000 00000000  *................*
20  004C4449 52202020  20432020 00000038  *.LDIR    C  ...8*
30  13001500 00000000  00000000 00000000  *................*
40  0843504D 55472020  20434154 01000046  *.CPMUG   CAT...F*
50  1C001E00 38003D00  41004300 45000000  *....8.=.A.C.E...*
60  00434F4D 4D414E44  204C4252 01000080  *.COMMAND LBR....*
70  14001600 17001800  19001A00 1B001D00  *................*


DU2  B1? +d
Group = 0000:01, Track = 122, Sector = 2, Physical Sector = 2
00  0754414C 4B202020  2053554D 00000049  *.TALK    SUM...I*
10  11002300 24000000  00000000 00000000  *..#.$...........*
20  00554E45 52413135  2041534D 00000060  *.UNERA15 ASM...`*
30  3E003F00 40000000  00000000 00000000  *>.?.@...........*
40  075A3249 4E532020  20575348 0000002A  *.Z2INS   WSH...**
50  21002500 00000000  00000000 00000000  *!.%.............*
60  075A3243 4F4E2020  20575348 0000003F  *.Z2CON   WSH...?*
70  12002200 00000000  00000000 00000000  *..".............*

DU2  B1? +d
Group = 0000:02, Track = 122, Sector = 3, Physical Sector = 3
00  07445532 20202020  2042414B 00000057  *.DU2     BAK...W*
10  26002800 29000000  00000000 00000000  *&.(.)...........*
20  04535441 52545550  20C3CF4D 0000001E  *.STARTUP COM....*
30  27000000 00000000  00000000 00000000  *'...............*
40  00434F4D 4D414E44  204C4252 03000080  *.COMMAND LBR....*
50  1F002000 30003100  32003300 34003500  *.. .0.1.2.3.4.5.*
60  00434F4D 4D414E44  204C4252 05000080  *.COMMAND LBR....*
70  36003700 39004C00  4D004E00 4F005000  *6.7.9.L.M.N.O.P.*

DU2  B1? +2
Group = 0000:04, Track = 122, Sector = 5, Physical Sector = 5

DU2  B1? d
00  084D4153 54455220  20434154 01000080  *.MASTER  CAT....*
10  2D002F00 3A003B00  3C004200 44004600  *-./.:.;.<.B.D.F.*
20  00464958 54455820  2041534D 0100001E  *.FIXTEX  ASM....*
30  65006600 69006B00  6C000000 00000000  *e.f.i.k.l.......*
40  00554E45 52413135  20434F4D 00000007  *.UNERA15 COM....*
50  52000000 00000000  00000000 00000000  *R...............*
60  084D454E 55202020  20C35052 00000008  *.MENU    CPR....*
70  53000000 00000000  00000000 00000000  *S...............*

DU2  B1? -3d
Group = 0000:01, Track = 122, Sector = 2, Physical Sector = 2
00  0754414C 4B202020  2053554D 00000049  *.TALK    SUM...I*
10  11002300 24000000  00000000 00000000  *..#.$...........*
20  00554E45 52413135  2041534D 00000060  *.UNERA15 ASM...`*
30  3E003F00 40000000  00000000 00000000  *>.?.@...........*
40  075A3249 4E532020  20575348 0000002A  *.Z2INS   WSH...**
50  21002500 00000000  00000000 00000000  *!.%.............*
60  075A3243 4F4E2020  20575348 0000003F  *.Z2CON   WSH...?*
70  12002200 00000000  00000000 00000000  *..".............*




3.5  Commands for Searching for Data

                             =string

     Thió commanä performó á searcè foò thå indicateä ASCIÉ text¬ 
startinç  aô currenô sector®  <xx¾ heø maù bå imbedded¬  oò  useä 
aloneº   Tï finä "IÎ 0FEH"º  =<db><fe>®   Biô · ió ignoreä unlesó 
<xx¾ ió used®  Notå that¬ duå tï thå parsinç schemå oæ DU2¬ formó 
sucè  aó "+=string"¬  whicè positionó tï thå nexô sectoò anä theî 
startó  thå  search¬  arå allowed®   Formó likå  "+2=string¢  arå 
equally permitted.  The search may be aborted by a ^C.  Example:

DU2  B1? g0
Group = 0000:00, Track = 122, Sector = 1, Physical Sector = 1

DU2  B1? =DU2
= at 24
Group = 0000:0E, Track = 122, Sector = 15, Physical Sector = 15

DU2  B1? d
00  07533130 30202020  20545854 0000000C  *.S100    TXT....*
10  0C010000 00000000  00000000 00000000  *................*
20  07445532 20202020  2042414B 00000068  *.DU2     BAK...h*
30  2A006100 6D007800  00000000 00000000  **.a.m.x.........*
40  015A3830 20202020  204D4143 0000000E  *.Z80     MAC....*
50  9A000000 00000000  00000000 00000000  *................*
60  E5444953 4B4F5554  20434F4E 00000020  *eDISKOUT CON... *
70  60000000 00000000  00000000 00000000  *`...............*

DU2  B1? +=DU2
Group = 0000:0F, Track = 122, Sector = 16, Physical Sector = 16
= at 64
Group = 0000:10, Track = 122, Sector = 17, Physical Sector = 17

DU2  B1? d
00  075A3243 4F4E2020  20575320 05000080  *.Z2CON   WS ....*
10  3D013E01 3F014001  41014201 43014401  *=.>.?.@.A.B.C.D.*
20  075A3243 4F4E2020  20575320 06000077  *.Z2CON   WS ...w*
30  45014601 47014801  00000000 00000000  *E.F.G.H.........*
40  E5444953 4B4F5554  20434F4E 00000020  *eDISKOUT CON... *
50  97000000 00000000  00000000 00000000  *................*
60  07445532 20202020  20484C50 01000006  *.DU2     HLP....*
70  98009900 9B009C00  9D000000 00000000  *................*


DU2  B1? +=DU2,d
Group = 0000:11, Track = 122, Sector = 18, Physical Sector = 18
= at 24
Group = 0000:11, Track = 122, Sector = 18, Physical Sector = 18
00  E547454E 494E5320  204D4143 01000080  *eGENINS  MAC....*
10  D700EF00 F000F400  F500F600 F700F800  *W.o.p.t.u.v.w.x.*
20  E5445532 20202020  2041534D 01000080  *eDU2     ASM....*
30  EC00ED00 EE00FA00  07010B01 0E011301  *l.m.n.z.........*
40  04445532 20202020  20C3CF4D 0000004E  *.DU2     COM...N*
50  F100F200 F3000000  00000000 00000000  *q.r.s...........*
60  E547454E 494E5320  204D4143 02000039  *eGENINS  MAC...9*
70  F9000F01 00000000  00000000 00000000  *y...............*



3.6  Commands for Saving and Restoring Data

     Thå  followinç commandó arå discusseä iî thió sectioî oæ thå 
HELP file:

          <  -- Save Current Block
          >  -- Restore Saved Block
          <B -- Save Current Block at Tail of Queue
          >B -- Load Current Block from Head of Queue
          <G -- Read and Save Group at Tail of Queue
          >G -- Copy Group from Head of Queue and Write
          Q  -- Print Queue Statistics
          QZ -- Zero (Clear) Queue
          QS -- Save Queue as a File
  


                             < and >

     "<¢  saveó  currenô blocë iî aî internaì savå  buffer®   ">¢ 
copieó thå internaì savå buffeò intï thå currenô blocë areá  (buô 
doeó NOÔ writå iô ouô tï disk).

                            <B and >B

     "<B¢ saveó thå currenô blocë ontï thå taiì oæ thå DU² Queue®  
Thió  Queue¬  á FIFÏ (Firsô In-Firsô Out© datá structure¬  caî bå 
useä tï collecô á numbeò oæ blockó foò lateò copù tï á disë  filå 
oò  expliciô placemenô somewherå oî thå disk®   ">B¢ extractó thå 
blocë aô thå heaä oæ thå DU² Queuå anä placeó iô intï thå workinç 
buffeò area.



                        <G[nn] and >G[nn]

     "<G¢ readó thå currenô grouğ anä saveó iô oî taiì oæ thå DU² 
Queue®   Thå  sizå  oæ á grouğ ió dependenô oî thå formaô oæ  thå 
disk¬  anä  DU²  automaticallù adjustó tï thå propeò  grouğ  sizå 
withouô  yoõ havinç tï worrù abouô whaô iô is®   ">G¢ copieó  thå 
grouğ aô thå heaä oæ thå DU² Queuå ontï disk®  Iæ nî ió specifieä 
(aó iî "<Gnn¢ oò ">Gnn")¬  theî thå indicateä grouğ ió reaä  froí 
oò  writteî  to®   Iæ  nî ió noô given¬  theî thå grouğ  yoõ  arå 
currentlù positioneä tï ió affected.

                        Q, QZ, and QSfile

     Ñ  reportó  thå statuó oæ thå DU²  Queue¬  namelù  ho÷  manù 
blockó  arå storeä iî iô anä ho÷ mucè spacå remains®   QÚ  zeroeó 
(clears© thå DU² Queue®   "QSfilename.typ¢ saveó thå DU² Queuå oî 
disk in the current user area as the indicated file.

     Examples (actual DU2 session):


DU2  B1? g0
Group = 0000:00, Track = 122, Sector = 1, Physical Sector = 1

DU2  B1? d
00  07535444 20202020  204D5347 00000002  *.STD     MSG....*
10  10000000 00000000  00000000 00000000  *................*
20  004C4449 52202020  20432020 00000038  *.LDIR    C  ...8*
30  13001500 00000000  00000000 00000000  *................*
40  0843504D 55472020  20434154 01000046  *.CPMUG   CAT...F*
50  1C001E00 38003D00  41004300 45000000  *....8.=.A.C.E...*
60  00434F4D 4D414E44  204C4252 01000080  *.COMMAND LBR....*
70  14001600 17001800  19001A00 1B001D00  *................*

DU2  B1? <

DU2  B1? ch0-7f e5

DU2  B1? d
00  E5E5E5E5 E5E5E5E5  E5E5E5E5 E5E5E5E5  *eeeeeeeeeeeeeeee*
10  E5E5E5E5 E5E5E5E5  E5E5E5E5 E5E5E5E5  *eeeeeeeeeeeeeeee*
20  E5E5E5E5 E5E5E5E5  E5E5E5E5 E5E5E5E5  *eeeeeeeeeeeeeeee*
30  E5E5E5E5 E5E5E5E5  E5E5E5E5 E5E5E5E5  *eeeeeeeeeeeeeeee*
40  E5E5E5E5 E5E5E5E5  E5E5E5E5 E5E5E5E5  *eeeeeeeeeeeeeeee*
50  E5E5E5E5 E5E5E5E5  E5E5E5E5 E5E5E5E5  *eeeeeeeeeeeeeeee*
60  E5E5E5E5 E5E5E5E5  E5E5E5E5 E5E5E5E5  *eeeeeeeeeeeeeeee*
70  E5E5E5E5 E5E5E5E5  E5E5E5E5 E5E5E5E5  *eeeeeeeeeeeeeeee*


DU2  B1? >,d
00  07535444 20202020  204D5347 00000002  *.STD     MSG....*
10  10000000 00000000  00000000 00000000  *................*
20  004C4449 52202020  20432020 00000038  *.LDIR    C  ...8*
30  13001500 00000000  00000000 00000000  *................*
40  0843504D 55472020  20434154 01000046  *.CPMUG   CAT...F*
50  1C001E00 38003D00  41004300 45000000  *....8.=.A.C.E...*
60  00434F4D 4D414E44  204C4252 01000080  *.COMMAND LBR....*
70  14001600 17001800  19001A00 1B001D00  *................*

DU2  B1? q
** Queue Status Summary **
0 Blocks in Queue
249 Blocks Left in Queue
Address of Head of Queue: 3E00 Hex
Address of Tail of Queue: 3E00 Hex

DU2  B1? <g
Reading from Group 0000
32 Blocks in Queue
Group = 0000:00, Track = 122, Sector = 1, Physical Sector = 1

DU2  B1? g1
Group = 0001:00, Track = 122, Sector = 33, Physical Sector = 33

DU2  B1? <g
Reading from Group 0001
64 Blocks in Queue
Group = 0001:00, Track = 122, Sector = 33, Physical Sector = 33

DU2  B1? q
** Queue Status Summary **
64 Blocks in Queue
185 Blocks Left in Queue
Address of Head of Queue: 3E00 Hex
Address of Tail of Queue: 5E00 Hex

DU2  B1? qsdir.sys
Queue Saved in File

DU2  B1? qz
** Queue Status Summary **
0 Blocks in Queue
249 Blocks Left in Queue
Address of Head of Queue: 3E00 Hex
Address of Tail of Queue: 3E00 Hex

DU2  B1? g0
Group = 0000:00, Track = 122, Sector = 1, Physical Sector = 1


DU2  B1? <b
1 Blocks in Queue

DU2  B1? +<b
Group = 0000:01, Track = 122, Sector = 2, Physical Sector = 2
2 Blocks in Queue

DU2  B1? +<b
Group = 0000:02, Track = 122, Sector = 3, Physical Sector = 3
3 Blocks in Queue

DU2  B1? +<b
Group = 0000:03, Track = 122, Sector = 4, Physical Sector = 4
4 Blocks in Queue

DU2  B1? +2<b
Group = 0000:05, Track = 122, Sector = 6, Physical Sector = 6
5 Blocks in Queue



3.7  Commands for Viewing Data


                              V[nn]

     Ö  viewó  thå currenô blocë aó ASCIÉ characters®   Thå  forí 
"Vnn¢  viewó  thå  indicateä numbeò oæ  blockó  startinç  aô  thå 
currenô one.

                           A, D, and H

     Ä  displayó á blocë oò portioî thereoæ iî  botè  hexadecimaì 
notatioî anä aó ASCIÉ characters®   Á displayó á blocë oò portioî 
thereoæ  aó ASCIÉ characters¬  anä È displayó á blocë oò  portioî 
thereoæ  aó  hexadecimaì numbers®   Alì threå commandó  accepô  á 
range¬ sucè aó thå following:

			D0-#7F	is the same as just D
			D3-5
			A20-#3F

     See next section for examples.


3.8  Commands for Altering Data


                            CH and CA

     CÈ  allowó  thå useò tï changå thå contentó oæ  thå  currenô 
blocë bù specifyinç ne÷ valueó aó hexadecimaì numbers®  CÁ allowó 
the same by specifying an ASCII character string.

CHaddr val val val...
     Change Hex data values in block

CAaddr char string...
     Change ASCII data values in block

     NOTÅ thaô <xx¾ maù bå heø imbeddeä iî thå ASCIIº 
          ca0 OK<d><a><1a>

     Use W to write changes to disk.

     Ranges may be specified:

CHaddr-addr byte or CAaddr-addr byte
     Changes a range of bytes to the same value

     Examples (actual DU2 session):

DU2  B7? g0
Group = 0000:00, Track = 122, Sector = 1, Physical Sector = 1

DU2  B7? d
00  07535444 20202020  204D5347 00000002  *.STD     MSG....*
10  10000000 00000000  00000000 00000000  *................*
20  004C4449 52202020  20432020 00000038  *.LDIR    C  ...8*
30  13001500 00000000  00000000 00000000  *................*
40  0843504D 55472020  20434154 01000046  *.CPMUG   CAT...F*
50  1C001E00 38003D00  41004300 45000000  *....8.=.A.C.E...*
60  00434F4D 4D414E44  204C4252 01000080  *.COMMAND LBR....*
70  14001600 17001800  19001A00 1B001D00  *................*

DU2  B7? d0-#f
00  07535444 20202020  204D5347 00000002  *.STD     MSG....*

DU2  B7? h0-#f
00  07535444 20202020  204D5347 00000002  

DU2  B7? a0-#f
00  *.STD     MSG....*

DU2  B7? fdu2.hlp
20  07445532 20202020  20484C50 01000039  *.DU2     HLP...9*
30  28009800 99009B00  9C009D00 00000000  *(...............*
Group = 0000:00, Track = 122, Sector = 1, Physical Sector = 1
ŠDU2  B7? g28
Group = 0028:00, Track = 125, Sector = 273, Physical Sector = 273

DU2  B7? d
00  496E766F 6B696E67  20445532 20616E64  *Invoking DU2 and*
10  20445532 20496E73  74616C6C 6174696F  * DU2 Installatio*
20  6E0D0A44 55322043  6F6D6D61 6E642053  *n..DU2 Command S*
30  756D6D61 72790D0A  436F6D6D 616E6473  *ummary..Commands*
40  20666F72 204C6F67  67696E67 20446973  * for Logging Dis*
50  6B732061 6E642045  78616D69 6E696E67  *ks and Examining*
60  20446973 6B205061  72616D65 74657273  * Disk Parameters*
70  0D0A436F 6D6D616E  64732066 6F722050  *..Commands for P*

DU2  B7? v
Invoking DU2 and DU2 Installation
DU2 Command Summary
Commands for Logging Disks and Examining Disk Parameters
Commands for P
Group = 0028:00, Track = 125, Sector = 273, Physical Sector = 273

DU2  B7? v3
Invoking DU2 and DU2 Installation
DU2 Command Summary
Commands for Logging Disks and Examining Disk Parameters
Commands for Positioning and Reading Data
Commands for Searching for Data
Commands for Saving and Restoring Data
Commands for Viewing data
Commands for Altering Data
Commands for Manipulating Macros and the @ Command
Miscellanea
Examples of command use
Interpret
Group = 0028:02, Track = 125, Sector = 275, Physical Sector = 275


DU2  B7? g28
Group = 0028:00, Track = 125, Sector = 273, Physical Sector = 273

DU2  B7? d
00  496E766F 6B696E67  20445532 20616E64  *Invoking DU2 and*
10  20445532 20496E73  74616C6C 6174696F  * DU2 Installatio*
20  6E0D0A44 55322043  6F6D6D61 6E642053  *n..DU2 Command S*
30  756D6D61 72790D0A  436F6D6D 616E6473  *ummary..Commands*
40  20666F72 204C6F67  67696E67 20446973  * for Logging Dis*
50  6B732061 6E642045  78616D69 6E696E67  *ks and Examining*
60  20446973 6B205061  72616D65 74657273  * Disk Parameters*
70  0D0A436F 6D6D616E  64732066 6F722050  *..Commands for P*


DU2  B7? ch0-10 0

DU2  B7? d
00  00000000 00000000  00000000 00000000  *................*
10  00445532 20496E73  74616C6C 6174696F  *.DU2 Installatio*
20  6E0D0A44 55322043  6F6D6D61 6E642053  *n..DU2 Command S*
30  756D6D61 72790D0A  436F6D6D 616E6473  *ummary..Commands*
40  20666F72 204C6F67  67696E67 20446973  * for Logging Dis*
50  6B732061 6E642045  78616D69 6E696E67  *ks and Examining*
60  20446973 6B205061  72616D65 74657273  * Disk Parameters*
70  0D0A436F 6D6D616E  64732066 6F722050  *..Commands for P*

DU2  B7? ca11 This is a test

DU2  B7? d0-#1f
00  00000000 00000000  00000000 00000000  *................*
10  00546869 73206973  20612074 6573746F  *.This is a testo*



3.9  Commands for Manipulating Macros and the @ Command

                             Macros

     Á  Macrï  ió  á short-hanä yoõ caî uså tï definå  á  commanä 
sequence®   Ratheò  thaî havinç tï typå aî involveä commanä  oveò 
anä oveò again¬  thå DU² macrï facilitù allowó yoõ tï assigî thió 
commanä  sequencå  tï á numbeò (° tï 9© anä theî  executå  iô  bù 
simplù  presentinç  thió  numbeò aó  á  command®   Thå  followinç 
commands are associated with this facility.


                          :ntext and n

     ":n<text>¢ defineó thå texô followinç thå digiô 'n§ tï bå  á 
Macro®   Aó  always¬  ° <½ î <½ 9®   Thå macrï definitionó maù bå 
createä  anä  redefineä aô will®   Iæ á macrï  haó  alreadù  beeî 
defineä  foò thå indicateä number¬  iô wilì bå overwritteî bù thå 
executioî oæ thió command®   "n"¬ wherå ° <½ î <½ 9¬ executeó thå 
indicateä macro.


                           :Pn and :PA

     ":Pn"¬ wherå ° <½ î <½ 9¬ printó thå texô oæ Macrï Numbeò n®  
":PA¢ printó thå texô oæ alì 1° macros.


                            @ and :P@

     "@¢ executeó thå previouó commanä linå thaô diä noô  contaiî 
thå  "@¢ Command®   Thió provideó aî easù waù tï repeaô thå  lasô 
commanä linå typed®  Foò example:

          g0             <-- go to Group 0
          ch0-7f e5,<    <-- Initialize the first block and Save
          >,w,+          <-- Read in the Saved Block, Write it 
                              out to disk, and advance to next
                              logical block
          @              <-- Do the Previous Command Again
          @              <-- And Again
          @              <-- And Again


     ":P@¢  printó thå previouó commanä linå (anä doeó noô changå 
it).

     Examples (edited DU2 session):

DU2  B7? g0
Group = 0000:00, Track = 122, Sector = 1, Physical Sector = 1

DU2  B7? :1+,d0-#1f

DU2  B7? :p1
Macro Definitions --
1: +,d0-#1f

DU2  B7? 1
Group = 0000:01, Track = 122, Sector = 2, Physical Sector = 2
00  0754414C 4B202020  2053554D 00000049  *.TALK    SUM...I*
10  11002300 24000000  00000000 00000000  *..#.$...........*

DU2  B7? 1
Group = 0000:02, Track = 122, Sector = 3, Physical Sector = 3
00  07444953 4B4F5554  20434F4E 00000000  *.DISKOUT CON....*
10  00000000 00000000  00000000 00000000  *................*

DU2  B7? 1
Group = 0000:03, Track = 122, Sector = 4, Physical Sector = 4
00  04584449 52202020  20C3CF4D 00000054  *.XDIR    COM...T*
10  2C002E00 48000000  00000000 00000000  *,...H...........*

DU2  B7? g0,d0-#1f
Group = 0000:00, Track = 122, Sector = 1, Physical Sector = 1
00  07535444 20202020  204D5347 00000002  *.STD     MSG....*
10  10000000 00000000  00000000 00000000  *................*

DU2  B7? 1
Group = 0000:01, Track = 122, Sector = 2, Physical Sector = 2
00  0754414C 4B202020  2053554D 00000049  *.TALK    SUM...I*
10  11002300 24000000  00000000 00000000  *..#.$...........*Š
DU2  B7? :pa
Macro Definitions --
0: 

1: +,d0-#1f

2: 

     < Detail Left Out >

9: 

DU2  B7? g0,d0-#1f,1,1,1
Group = 0000:00, Track = 122, Sector = 1, Physical Sector = 1
00  07535444 20202020  204D5347 00000002  *.STD     MSG....*
10  10000000 00000000  00000000 00000000  *................*
Group = 0000:01, Track = 122, Sector = 2, Physical Sector = 2
00  0754414C 4B202020  2053554D 00000049  *.TALK    SUM...I*
10  11002300 24000000  00000000 00000000  *..#.$...........*
Group = 0000:02, Track = 122, Sector = 3, Physical Sector = 3
00  07444953 4B4F5554  20434F4E 00000000  *.DISKOUT CON....*
10  00000000 00000000  00000000 00000000  *................*
Group = 0000:03, Track = 122, Sector = 4, Physical Sector = 4
00  04584449 52202020  20C3CF4D 00000054  *.XDIR    COM...T*
10  2C002E00 48000000  00000000 00000000  *,...H...........*

DU2  B7? @

Command --
g0,d0-#1f,+,d0-#1f,+,d0-#1f,+,d0-#1f
Group = 0000:00, Track = 122, Sector = 1, Physical Sector = 1
00  07535444 20202020  204D5347 00000002  *.STD     MSG....*
10  10000000 00000000  00000000 00000000  *................*
Group = 0000:01, Track = 122, Sector = 2, Physical Sector = 2
00  0754414C 4B202020  2053554D 00000049  *.TALK    SUM...I*
10  11002300 24000000  00000000 00000000  *..#.$...........*
Group = 0000:02, Track = 122, Sector = 3, Physical Sector = 3
00  07444953 4B4F5554  20434F4E 00000000  *.DISKOUT CON....*
10  00000000 00000000  00000000 00000000  *................*
Group = 0000:03, Track = 122, Sector = 4, Physical Sector = 4
00  04584449 52202020  20C3CF4D 00000054  *.XDIR    COM...T*
10  2C002E00 48000000  00000000 00000000  *,...H...........*


3.10  Miscellanea

                                ?

     "?¢  giveó  á commanä summarù anä telló thå  useò  whaô  thå 
currenô  valueó arå foò Processoò Clocë Speeä anä Lineó peò  Pagå 
oî  CONº  aó  welì  aó thå addresó foò thå Grouğ  Storagå  Buffeò 
(wherå thå DU² Queuå begins).


                              *[nn]

     "*nn¢  repeató thå currenô commanä linå (aó entereä sï  far© 
nî  times®   Thió  commanä  defaultó tï "forever¢ iæ  nî  ió  noô 
specified® 'nn§ maù bå ² tï 65535.


                                !

     "!¢  haltó processinç oæ commands¬  displayó á  continuatioî 
messagå  tï  thå user¬  anä waitó foò thå useò tï typå  anù  key®  
Typinç  á Control-Ã abortó commanä processing®   Thió commanä  ió 
usefuì  iî  stoppinç loopó tï givå thå useò aó mucè  timå  aó  hå 
wantó tï revie÷ thå display.


                                P

     "P¢ toggleó thå printeò switcè oî anä off®  Iô allowó yoõ tï 
turî oî anä ofæ á recordinç oæ youò consolå output.


                                X

     "X¢ exiô bacë tï CP/M®  Thå useò ió giveî thå optioî tï Warí 
Boot¬ iî whicè caså thå CCĞ anä BDOÓ arå reloaded¬ oò not.


                              Z[nn]

     "Znn¢ causeó thå prograí tï sleep¬ oò pause¬ anä maù bå useä 
tï looë aô á dumğ quicklù iî á loopinç commanä line®  Ú ió ± sec®  
Znî ió nî secondó oî aî î MHú 8080®   Thå processoò speeä maù  bå 
specifieä bù thå useò undeò GENINÓ foò hió particulaò system.


                               ^C

     "^C" exits to CP/M and Warm Boots.


     Examples (actual DU2 session):

DU2  B7? g0
Group = 0000:00, Track = 122, Sector = 1, Physical Sector = 1

DU2  B7? d0-#f,+,!,*
00  07535444 20202020  204D5347 00000002  *.STD     MSG....*
Group = 0000:01, Track = 122, Sector = 2, Physical Sector = 2

Type Any Character to Continue or ^C to Abort - 
00  0754414C 4B202020  2053554D 00000049  *.TALK    SUM...I*
Group = 0000:02, Track = 122, Sector = 3, Physical Sector = 3

Type Any Character to Continue or ^C to Abort - 
00  07444953 4B4F5554  20434F4E 00000000  *.DISKOUT CON....*
Group = 0000:03, Track = 122, Sector = 4, Physical Sector = 4

Type Any Character to Continue or ^C to Abort - 
00  04584449 52202020  20C3CF4D 00000054  *.XDIR    COM...T*
Group = 0000:04, Track = 122, Sector = 5, Physical Sector = 5

Type Any Character to Continue or ^C to Abort - 

DU2  B7? g1
Group = 0001:00, Track = 122, Sector = 33, Physical Sector = 33

DU2  B7? d0-#f,+,*3
00  E5482020 20202020  2042414B 00000004  *eH       BAK....*
Group = 0001:01, Track = 122, Sector = 34, Physical Sector = 34
00  E5535542 32202020  2042414B 0100007B  *eSUB2    BAK...{*
Group = 0001:02, Track = 122, Sector = 35, Physical Sector = 35
00  E5434420 20202020  204D4143 00000047  *eCD      MAC...G*
Group = 0001:03, Track = 122, Sector = 36, Physical Sector = 36

DU2  B7? ^C
B7>



3.11  Examples

Multiple commands may be separated by ","

     Anù  valiä commanä strinç maù bå placeä aó aî operanä oæ thå 
originaì DU² command¬ i.e.:

	 A>DU2 G0,D,G2,=OK<D><A><1A>,D


     Exampleº  thå  followinç  commandó  wilì eraså  thå  Â  disë 
directorù tï alì E5's:

	lb		log in b drive
	g0		position to dir.
	ch0-7f e5	fill with e5
	<		save the sector
	>,w,+,/16	restore, write, next,
			repeat 16

     This could be shortened to:

	lb,g0,ch0-7f e5,<
	>,w,+,/16


     Using Macros, the following two macros could be defined:

   Macro 0 --
     :0g0,ch0-7f e5,<
   Macro 1 --
     :1>,w,+,/16

     Now¬  foò  thå useò tï initializå thå directorù oî Drivå  Aº 
anä theî oî Drivå B:¬ thå followinç commandó coulä bå issued:

     la,0      <-- Log in A and Initialize first block
     1         <-- Perform write
     lb,0      <-- Log in B and Initialize first block
     1         <-- Perform write
     n,0       <-- Declare New Disk and Initialize first 
                    block
     1         <-- Perform write




3.12  Interpretation of Directory Data Presented by DU2

     Thå followinç explainó thå formaô oæ á CP/Í directorù  entrù 
aó  showî bù DU2¬   usinç eitheò thå Æ (Finä File©  command¬   oò 
jusô  doinç Ä (Dump© oæ thå directorù sectors¬  whicè arå locateä 
iî  groupó ° anä ± oî á singlå densitù disk®   Samplå  resulô  oæ 
"FSID.COM¢ command:

First	    40	00534944 20202020 20434F4D  0000003A  *.SID	COM...:*
line	    ||	|||			 |  ||	  ||	|	  |
	    ||	||^----hex file name-----^  ||	  ||	^file name^
	    ||	||			    ||	  ||	 in ASCII
	    ||	||		     extent-^^	  ||
	    ||	||				  ||
	    ||	||	     file size in sectors-^^
	    ||	||
	    ||	^^-00 = file active
	    ||	   E5 = file erased
	    ^^-displacement of line in directory sector


Second	    50	33343536 3738393A  00000000 00000000  *3456789:........*
line		|				   |
		^---allocation group numbers-------^


.fi z2ug1.ws
.fi z2ug2.ws
.fi z2ug3.ws
