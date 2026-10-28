.he    ZCPR2 -- An Enhanced Z80-Based Replacement for the CP/M CCP
.fo Installation Instructions                          Page #


               Installation Instructions for ZCPR2

1.0 Introduction

     Installatioî  oæ ZCPR² ió á somewhaô involveä  process¬  anä 
thå installeò shoulä havå á fair-to-gooä workinç knowledgå oæ thå 
following:

          1© 808° anä Z8° assemblù languagå programming
          2) CP/M 2.2
          3) the CP/M SYSGEN procedure and how to replace the
               operating system on the system tracks of the
               target system

     Thå memorù imageó oæ á CP/Í systeí anä á ZCPR2-baseä  systeí 
arå  presenteä belo÷ foò á conventionaì CP/Í system®   Thå actuaì 
addresseó  maù  varù  froí systeí tï system¬  anä  thå  installeò 
shoulä  bå  awarå oæ whaô theså addresseó arå  foò  thå  specifiã 
target system.


-- Diagram 1 --

Address        CP/M Image               ZCPR2 Image

               ---------------------    ----------------------
               | BIOS              |    | BIOS with Modified |
               |                   |    |   Cold Boot *      |
BDOS+0E00H-->  ---------------------    ----------------------
               | BDOS              |    | BDOS (No Change)   |
CCP +0800H-->  ---------------------    ----------------------
               | CP/M 2.2 CCP      |    | ZCPR2 *            |
BOOT+0080H-->  ---------------------    ----------------------
               | BOOT              |    | BOOT               |
BASE+xxxxH-->  ---------------------    ----------------------
               | Junk and SYSGEN   |    | Junk and SYSGEN    |
BASE= 100H-->  ---------------------    ----------------------


            CP/M and ZCPR2-based SYSGEN Memory Images

     Installatioî  requireó  á modifieä BIOÓ imagå  anä  á  ZCPR² 
imagå  tï  bå  placeä  oveò thå originaì CP/Í 2.²  BIOÓ  anä  CCĞ 
images®   Thå  resô oæ thå systeí caî staù thå same®   Thoså  ne÷ 
imageó arå markeä witè aî asterisë (*© above.


     Typical address values are indicated below:

                         SYSGEN Image             SYSGEN Image
Value                    Conventional CP/M        Morrow CP/M
xxxxH                         800H                   ~ 980H
BOOT  = BASE + xxxxH          900H                    1080H
ZCPR2 = BOOT + 80H            980H                    1100H
BDOS  = ZCPR2 + 800H         1180H                    1900H
BIOS  = BDOS + 0E00H         1F80H                    2700H
End of Operating System      ????H                    2DFFH

     Refer back to Diagram 1 for clarification.

     The installation process involves three steps:

          1) Configuring your BIOS and setting the ZCPR2 options
          2) Overlaying the CCP with ZCPR2 and the old BIOS with
               the new BIOS in the SYSGEN Image
          3) Placing the new SYSGEN Image onto the Operating
               System tracks of the disk

     Thå installeò ió inviteä tï refeò tï thå CP/Í 2.° Alteratioî 
Guide“ bù Digitaì Researcè foò detailó iî procedure®   Thió manuaì 
specificallù  coveró installatioî oæ á BOOÔ anä BIOS¬  buô  theså 
conceptó caî bå logicallù extendeä tï thå CCĞ (ZCPR2© aó well.


1.1 Required Software for Installation

     ZCPR² ió tï bå installeä oî á workinç CP/Í 2.² system®   Thå 
specific commercial software required to do this installation is:

          1) A working CP/M 2.2 System
          2) the MAC assembler of Digital Research
               (another assembler may be substituted, but source
                code modification to ZCPR2 may be required to do
                an installation with an assembler other than MAC)
          3) a debugger, like DDT, for the overlay process
          4) a disk utility, like SYSGEN, to be used to place the
               operating system image onto the operating system
               tracks on disk


    Thå  non-commerciaì softwarå requireä foò ZCPR² installatioî 
is:

       1) source to ZCPR2

       2©  thå  CCPLOÃ  prograí (maù  bå  required¬  anä  ió 
          provideä iî thå ZCPR² distribution)

       3©  sourcå tï thå BIOÓ oæ thå targeô machinå  oò  thå 
          overlaù  foò  thå BIOÓ Colä Booô routinå  foò  thå 
          targeô machinå (thió maù bå availablå commercially)

       4©  thå ZCPR² utilitieó (sourcå ió typicallù noô  re
          quireä  foò installatioî sincå thå GENINÓ  prograí 
          caî  perforí  installatioî iî mosô  cases)»  theså 
          utilitieó  anä  theiò sourceó aî includeä  iî  thå 
          ZCPR² distribution

     Á  listinç  oæ thå ZCPR²  distributioî  software¬  witè  CRÃ 
valueó  sï thaô yoõ caî checë tï seå thaô yoõ havå gooä copieó oæ 
everything¬ ió includeä iî Appendiø Á oæ thió document.


1.2  Required Hardware for Installation and Running ZCPR2

     Thå  hardwarå requirementó foò thå installatioî oæ ZCPR² arå 
as follows:

          CP/M 2.2 - based system (or ZCPR2 - based system)
          8080 or Z80 microprocessor
          32K bytes of memory
          110K bytes of disk space for source, BAK, and HEX files
          computer terminal

     The hardware requirements for running ZCPR2 are:

          ZCPR2 - based system
          Z80 microprocessor
          48K bytes of memory
          110K bytes of disk space (recommended minimum)
          computer terminal



2.0 Installing ZCPR2

     Iî  ordeò tï instalì ZCPR² oî á  targeô  microcomputer¬  thå 
useò  musô  kno÷  twï  basiã thingó  abouô  hió  Consolå  Commanä 
Processor (CCP):

          1) Where it is located when it is executed
          2© Wherå iô ió locateä iî thå SYSGEÎ Imagå or¬ foò 
               systemó whicè don'ô supporô SYSGEN¬ wherå hió CCĞ 
               is located on disk and how to place the new ZCPR2
               on top of it

     Note Diagrams 1 and 2:

-- Diagram 1 --

Address        CP/M Image               ZCPR2 Image

               ---------------------    ----------------------
               | BIOS              |    | BIOS with Modified |
               |                   |    |   Cold Boot *      |
BDOS+0E00H-->  ---------------------    ----------------------
               | BDOS              |    | BDOS (No Change)   |
CCP +0800H-->  ---------------------    ----------------------
               | CP/M 2.2 CCP      |    | ZCPR2 *            |
BOOT+0080H-->  ---------------------    ----------------------
               | BOOT              |    | BOOT               |
BASE+xxxxH-->  ---------------------    ----------------------
               | Junk and SYSGEN   |    | Junk and SYSGEN    |
BASE= 100H-->  ---------------------    ----------------------

            CP/M and ZCPR2-based SYSGEN Memory Images


-- Diagram 2 --

Address        CP/M Image               ZCPR2 Image

               ---------------------    ----------------------
               | BIOS              |    | BIOS with Modified |
               |                   |    |   Cold Boot        |
BDOS+0E00H-->  ---------------------    ----------------------
               | BDOS              |    | BDOS (No Change)   |
CCP +0800H-->  ---------------------    ----------------------
               | CP/M 2.2 CCP      |    | ZCPR2              |
CCP Base  -->  ---------------------    ----------------------
               | Scratch Area      |    | Scratch Area       |
100H      -->  ---------------------    ----------------------
               | CP/M Buffers et al|    | ZCPR2 Buffers et al|
  0H      -->  ---------------------    ----------------------

              CP/M and ZCPR2-based Executing Images

Š
Question 1:  Where is the CCP located when it is executed?

     Á  prograí calleä CCPLOÃ ió provideä iî thå ZCPR²  distribu
tion®   Thió program¬ whoså COÍ filå ió seô uğ tï ruî startinç aô 
100H¬  wilì returî tï yoõ thå baså addresseó oæ youò  CCP¬  BDOS¬ 
anä BIOS®   Thió prograí bù itselæ answeró thå firsô questioî foò 
you.

     Iæ yoõ arå runninç á non-ORÇ ° CP/Í system¬ yoõ wilì havå tï 
reassemblå CCPLOÃ iî ordeò tï ruî it®  Thió discussioî ió orient
eä towardó ORÇ ° CP/Í systems¬  buô iô ió noô difficulô tï adjusô 
offsetó foò non-ORÇ ° systems.


Questioî 2º  Wherå ió thå CCĞ locateä iî thå SYSGEÎ Imagå or¬ foò 
systemó  whicè don'ô supporô SYSGEN¬  wherå ió thå CCĞ locateä oî 
disë anä ho÷ wilì thå ne÷ ZCPR² bå placeä oî toğ oæ it?

     Thió questioî ió noô answereä nearlù sï easily®  Iæ yoõ havå 
thå abilitù tï SYSGEÎ youò system¬  iô ió mucè easieò  (commonly© 
thaî iæ yoõ dï not®   Yoõ must¬  afteò assemblinç ZCPR² properly¬ 
integratå  iô intï thå SYSGEÎ (oò disk© imagå oæ CP/M®   Thió caî 
bå donå bù obtaininç á SYSGEÎ imagå oæ youò system¬  scanninç  iô 
viá  á  debuggeò  sucè  aó DDÔ tï finä thå offseô  foò  thå  CCP¬ 
readinç ZCPR² iî oî toğ oæ thå CP/Í 2.² CCP¬  anä finallù runninç 
SYSGEÎ  agaiî tï placå thå resultanô systeí oî disk®   Iæ yoõ  DÏ 
NOÔ havå SYSGEÎ capability¬ á Disë Utilitù prograí ió requireä tï 
locatå  thå  CCĞ oî disë anä theî writå ZCPR² oî toğ oæ  thå  olä 
one®   Thå  neô  resulô oæ thió integratioî ió thå  placemenô  oæ 
ZCPR²  ontï  disë iî thå propeò placå sï thaô iô wilì  bå  loadeä 
witè thå resô oæ CP/Í oî colä booô anä executeä properly.

     Tï  finä  thå originaì CP/Í 2.² CCP¬  yoõ typicallù havå  tï 
locatå  iô bù itó appearance®   Iô maù bå storeä contiguouslù  oî 
disk¬ so¬ oncå iô ió found¬ á sequentiaì overwritå ió alì thaô ió 
required®   Thió ió noô alwayó thå case¬ however¬ anä youò parti
culaò situatioî maù bå different®   Probabilitù ió extremelù higè 
thaô iô ió storeä contiguouslù iî thå SYSGEÎ image.

     Thå  CCĞ  startó  witè twï anä ONLÙ  TWÏ  jumğ  instructionó 
followeä bù á buffeò areá (possiblù containinç aî initiaì commanä 
and/oò thå Digitaì Researcè copyrighô notice)®   Thå Digitaì  Re
searcè  manualó  sho÷  thå CCĞ tï residå aô addresó 980È  iî  thå 
SYSGEÎ Image¬  buô thió maù varù witè thå particulaò systeí (notå 
previouó diagrams)®   Tï finä thió image¬  uså DDÔ oò somå  otheò 
debugger¬  loaä thå SYSGEÎ image¬  anä examinå memorù startinç aô 
arounä 900È foò thå twï (anä ONLÙ two© jumpó describeä above®  Iæ 
yoõ finä aî areá witè morå thaî twï jumpó (á grouğ oæ them)¬  yoõ 
arå probablù lookinç aô thå BIOÓ anä shoulä gï loweò foò thå CCP®  
Thå  CCĞ wilì probablù starô oî aî eveî pagå oò half-pagå addresó 
(likå 900H¬ 980H¬ 1100H¬ etc).


     No÷ thå locationó oæ thå CCĞ iî thå SYSGEÎ imagå anä iî  thå 
runninç imagå arå known®   Recorä theså addresseó foò later®  Yoõ 
arå  no÷ readù foò thå integratioî oæ ZCPR² anä thå ne÷ BIOÓ intï 
youò system®  Tï dï this¬ perforí thå followinç steps:

          1©  Assuminç thaô yoõ caî uså SYSGEN¬  obtaiî á  SYSGEÎ 
imagå oæ youò currenô CP/Í systeí anä savå iô oî disk®   Alsï ruî 
CCPLOÃ anä obtaiî itó values.

          2©  Ediô  ZCPRHDR.LIÂ anä seô thå CPRLOÃ equatå tï  thå 
addresó oæ thå runninç CCĞ imagå obtaineä above®   Seô anù  flagó 
anä valueó aó yoõ desirå (seå thå ZCPR² Customizatioî section).

          3© Ediô youò BIOÓ oò BIOÓ Overlaù anä seô uğ youò  Colä 
Booô  routinå  tï perforí thå necessarù initializationó  foò  thå 
ZCPR² featureó yoõ havå selecteä (seå thå sectioî oî Modificatioî 
oæ  thå BIOÓ Colä Booô Routinå below)®   Wheî satisfied¬  enä thå 
ediô session.

          4©  Assemblå  ZCPR² witè  MAÃ  (oò  equivalent)®   Thió 
assembleò  ió  requireä  becauså oæ thå MACROó  used®   Onlù  thå 
resultanô  HEØ filå ió requireä foò thå resô oæ thå  installatioî 
procedure¬  sï yoõ caî geô riä oæ ZCPR² sourcå iæ yoõ arå runninç 
shorô oî disë space.

          5© Assemblå youò BIOÓ oò BIOÓ Overlay®  Again¬ onlù thå 
resultanô HEØ filå ió required¬  sï yoõ caî geô riä oæ thå sourcå 
oncå thå assemblù ió complete.

          6©  Loaä  thå  SYSGEÎ imagå intï memorù  witè  DDÔ  (oò 
equivalent)®  Oncå loaded¬ verifù thaô thå originaì CCĞ ió aô thå 
IMAGÅ  addresó  founä abovå anä computå  thå  integratioî  offseô 
usinç thå DDÔ È command:
                         H<IMAGÅ address>,<RUNNINÇ address>

Thå  seconä numbeò displayeä giveó yoõ thå OFFSEÔ valuå  requireä 
foò stepó · anä 8.

          7©  Integratå ZCPR² intï youò SYSGEÎ imagå viá DDT'ó  É 
anä  ROFFSEÔ  commands®   Uså  IZCPR2.HEØ (oò thå  namå  oæ  youò 
versioî  oæ ZCPR2© tï loaä thå FCÂ anä ROFFSEÔ (wherå OFFSEÔ  waó 
computeä iî Steğ 6© tï loaä thå ZCPR2.HEØ filå intï memorù aô thå 
propeò  location®   Checë  tï seå thaô ZCPR² ió  indeeä  properlù 
loaded by examining the SYSGEN IMAGE area.

          8© Integratå youò ne÷ ZCPR² BIOÓ intï youò SYSGEÎ imagå 
viá DDT'ó É anä ROFFSEÔ commands®   Uså IBIOS.HEØ (oò thå namå oæ 
youò  versioî  oæ  thå BIOS© tï loaä thå FCÂ anä  ROFFSEÔ  (wherå 
OFFSEÔ  waó  computeä iî Steğ 6© tï loaä thå BIOS.HEØ  filå  intï 
memorù  aô thå propeò location®   Checë tï seå thaô thå  BIOÓ  ió 
indeeä properlù loadeä bù examininç thå SYSGEÎ IMAGÅ area.

          9©  Placå thå ne÷ systeí oî disë bù runninç SYSGEÎ  anä 
NOT loading the system from disk (use the memory image).Š
2.1 ZCPR2 Installation Example

     Foò  furtheò  clarificatioî  oæ  thå  abovå  procedure¬  thå 
followinç  ió á samplå terminaì sessioî whicè outlineó thå  stepó 
taken®   Iô ió ruî froí á ZCPR² system¬  anä thå screeî  displayó 
are edited to omit unnecessary detail and improve clarity.

B1>;
B1>;  Sample terminal session which illustrates ZCPR2 installation
B1>;   This is done from a running ZCPR2 system and shows some of
B1>; the extended features of ZCPR2
B1>;
B1>
B1>;
B1>;  Step 1a -- SYSGEN
B1>;
B1>hdsysgen
SYSGEN VER 2.2
SOURCE DRIVE NAME (OR RETURN TO SKIP)a
SOURCE ON A, THEN TYPE RETURN
FUNCTION COMPLETE
DESTINATION DRIVE NAME (OR RETURN TO REBOOT)

B1>save 45 cpzm.cpm
B1>;
B1>;  Step 1b -- Run CCPLOC to get addresses
B1>;
B1>ccploc
CCPLOC  Version 1.0

CP/M Element    Base Page       Base Address
------------    ---------       ------------
    CCP            BDH             BD00H
    BDOS           C5H             C506H
    BIOS           D3H             D300H


B1>;
B1>;  Note the files I am working with
B1>;
B1>xdir

XDIR III, Version 1.3    Vertical Listing by File Type and Name
 Disk: B  User:   1, File Attributes:  Non-System

Filename.Typ Size K   Filename.Typ Size K   Filename.Typ Size K
-------- --- ------   -------- --- ------   -------- --- ------
CHBIOSZ .ASM     52   CPZM    .CPM     12   ZCPRHDR .LIB     12      
ZCPR    .ASM     56   CBIOSHDR.LIB     12      
    5 Files Occupying   144K,    33 Files on Disk and  4360K Free

B1>


B1>;
B1>;  Step 2 -- Edit ZCPRHDR.LIB and set all options and values
B1>;
B1>ed zcprhdr.lib
     -- Detail Left Out --
B1>
B1>;
B1>;  Step 3 -- Edit CHBIOSZ.ASM and CBIOSHDR.LIB and set Cold
B1>;      Boot Inits
B1>;      You will probably only have to deal with one BIOS file
B1>;
B1>ed chbiosz.asm
     -- Detail Left Out --
B1>ed cbioshdr.lib
     -- Detail Left Out --
B1>;  I'll erase the backup files now
B1>era *.bak
CHBIOSZ .BAK  |  ZCPRHDR .BAK  |  CBIOSHDR.BAK
B1>
B1>;
B1>;  Step 4 -- Assemble ZCPR2
B1>;        I will also run TIME to show you how long it takes
B1>;
B1>time;mac zcpr2 $pz sz;time
TIME  Version 1.1    1:43:38 AM on Thursday December 16, 1982
CP/M MACRO ASSEM 2.0
C4FC                <-- Note the ZCPR2 MUST end before BDOS
01CH USE FACTOR     <-- begins!
END OF ASSEMBLY

TIME  Version 1.1    1:45:18 AM on Thursday December 16, 1982
B1>
B1>;
B1>;  Step 5 -- Assemble BIOS
B1>;
B1>time;mac chbiosz $pz sz;time
TIME  Version 1.1    1:49:15 AM on Thursday December 16, 1982
CP/M MACRO ASSEM 2.0
FCE0
01AH USE FACTOR
END OF ASSEMBLY

TIME  Version 1.1    1:50:32 AM on Thursday December 16, 1982
B1>xdir

XDIR III, Version 1.3    Vertical Listing by File Type and Name
 Disk: B  User:   1, File Attributes:  Non-System

Filename.Typ Size K   Filename.Typ Size K   Filename.Typ Size K
-------- --- ------   -------- --- ------   -------- --- ------
CHBIOSZ .ASM     52   CHBIOSZ .HEX      8   CBIOSHDR.LIB     12      
ZCPR2   .ASM     56   ZCPR2   .HEX      8   ZCPRHDR .LIB     12      
CPZM    .CPM     12      
    7 Files Occupying   160K,    35 Files on Disk and  4344K FreeŠ
B1>;
B1>;  Step 6 -- Run DDT and locate the CCP
B1>;
B1>ddt cpzm.cpm
DDT VERS 2.0
NEXT  PC
2E00 0100
-d900,90f      <-- Start looking around here
0900 31 80 E7 3E 06 3C 3C FE 1B CA 00 C2 DA 11 E7 D6 
-da00,a0f
0A00 31 00 01 01 01 0C C5 CD 0F E4 21 00 BE 11 00 04 
-db00,b0f
0B00 31 00 01 01 01 11 C5 CD 0F E4 21 00 C0 11 00 02 
-db80,b8f
0B80 31 00 01 01 09 01 CD A8 00 21 00 D2 11 00 C2 0E 
        -- Detail Left Out --
-d1100         <-- I found it at 1100H; note the 2 JMP's
1100 C3 FF BD C3 FB BD 50 10 20 20 20 20 20 20 20 20 
1110 20 20 20 20 20 20 20 20 00 00 00 00 00 00 00 00 
1120 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
        -- Detail Left Out --
-h1100,bd00
CE00 5400      <-- Integration Offset is 5400 for my system
-^Ã            <-- Returî tï CP/M» É kno÷ thaô CPRLOÃ wilì be
                    BD00H and the IMAGE offset is 1100H

B1>
B1>;
B1>;  Steps 7 and 8 -- Perform integration of ZCPR2 and BIOS
B1>;
B1>ddt cpzm.cpm          <-- Edit CP/M Image
DDT VERS 2.0
NEXT  PC
2E00 0100
-h1100,800               <-- Compute End Address of CCP
1900 0900                <-- (CCP is 800H bytes long)
-f1100 18ff 0            <-- Zero Fill Area (I like to do this)
-izcpr2.hex              <-- Overlay ZCPR2
-r5400                   <-- Offset Computed Above
NEXT  PC
2E00 0000
-h1900,e00               <-- Compute Beginning of BIOS
2700 0B00
-f2700 2dff 0            <-- Zero Fill Area (I like)
-ichbiosz.hex            <-- Overlay BIOS
-r5400                   <-- Offset Computed Above
NEXT  PC
2E00 0000
-^C                      <-- Done


B1>;
B1>;  Step 9 -- Perform SYSGEN
B1>;
B1>save 2dh cpzm.cpm          <-- Save file (note HEX page count)
Erase CPZM    .CPM?y
B1>hdsysgen                   <-- SYSGEN to disk from memory
SYSGEN VER 2.2
SOURCE DRIVE NAME (OR RETURN TO SKIP)             <-- Skip
DESTINATION DRIVE NAME (OR RETURN TO REBOOT)a     <-- Select A
DESTINATION ON A, THEN TYPE RETURN
FUNCTION COMPLETE
DESTINATION DRIVE NAME (OR RETURN TO REBOOT)      <-- REBOOT!


B1>

3.0 ZCPR2 Customization

     Thå  filå ZCPRHDR.LIÂ containó alì oæ thå customizatioî equ
ateó anä valueó foò ZCPR2¬  anä iô ió typicallù noô necessarù  tï 
ediô ZCPR2.ASÍ iî ordeò tï configurå iô tï youò desires®  Editinç 
ZCPRHDR.LIÂ  ió  thå  onlù procedurå necessarù  tï  perforí  sucè 
customization.

     Iî thió sectioî oæ thå Installatioî Manuaì É wilì gï througè 
eacè oæ thå equateó anä valuå settingó iî ZCPRHDR.LIÂ iî sequencå 
(froí beginninç tï end)®   Thió allowó yoõ tï simplù steğ througè 
thå  filå witè aî editoò whilå yoõ arå readinç thió manual®   Thå 
documentatioî  iî  thió  manuaì  augmentó  thå  documentatioî  iî 
ZCPRHDR.LIÂ  tï  givå yoõ á fairlù completå explanatioî  oæ  eacè 
option.

     Iô  ió  importanô  thaô yoõ havå reaä  thå  Conceptó  Manuaì 
beforå performinç thió customization®   Knowledgå oæ ho÷ CP/Í 2.² 
workó  anä thå contentó oæ thå Conceptó Manuaì ió assumeä iî thió 
sectioî oæ thå Installatioî Manual.


     1®  REÌ -- Configureó CPRLOÃ (CPRLOÃ eqõ 0© foò  integratioî 
viá  MOVCPÍ ratheò thaî thå DDT/SYSGEÎ techniquå outlineä  above» 
seô  tï TRUÅ foò MOVCPÍ integratioî oò FALSÅ foò DDT/SYSGEÎ inte
gration

     2®  BASÅ -- Baså addresó oæ youò CP/Í system»  standarä CP/Í 
haó  á baså oæ 0¬  buô somå CP/Í systemó (sucè aó foò thå  TRS-8° 
Modeì  I© starô physicaì RAÍ memorù aô á higheò  address»  equatå 
BASÅ tï thå startinç RAÍ memorù addresó oæ youò system

     3®  CPRLOÃ -- Thió ió thå startinç addresó oæ ZCPR2» seô thå 
seconä  CPRLOÃ equatå tï thå addresó yoõ obtaiî froí  CCPLOC»  iæ 
yoõ  havå  á "standard¢ system¬  yoõ maù wisè tï uså  thå  MSIZE¬ 
BIOSEX¬ anä CPRLOÃ equateó whicè arå commenteä ouô insteaä oæ thå 
simplå CPRLOÃ É prefeò tï use

     4®   CPRÒ  -- Thió ió thå valuå oæ OFFSET¬  anä yoõ maù  seô 
thió  equatå accordinç tï youò systeí aó desired»  iô ió noô useä 
bù ZCPR2¬ buô iô doeó providå yoõ witè thå requireä valuå withouô 
having to compute it via the H command in DDT

     5®   BIOÓ -- Thió ió á standarä equatå anä usuallù doeó  noô 
need to be changed

     6®   COMTYĞ  anä SUBTYĞ -- Theså MACROó allo÷ yoõ tï  definå 
thå  filå typå oæ thå COÍ anä SUÂ files»  thió ió aî optioî whicè 
improveó  flexibility¬  and¬  iî  somå environments¬  iô  maù  bå 
desirable to type COM files as something else, like OBJ

     7®   SUBOÎ  -- Thió  turnó  oî thå  SUBMIÔ  filå  processinç 
facility of ZCPR2
Š      8®   DRVPREFIØ  -- Thió enableó oò disableó thå abilitù  tï 
specifù commandó beginninç witè á disk/useò prefix¬  likå  "A4:X¢ 
oò "B:RUNIT"

     Á  sidå  effecô oæ DRVPREFIØ beinç TRUÅ ió thaô thå  currenô 
disk/useò ió automaticallù scanneä beforå thå patè searcè begins.

      9®   DRVPFATÔ  -- Thió  flaç allowó thå useò tï selecô  thå 
attributeó  oæ thå fileó iî thå currenô disk/useò tï bå  examineä 
iæ thå DRVPREFIØ flaç ió TRUE®  Thå followinç valueó arå defined:

               DRVPFATT  Files Selected
               --------  --------------
                   0     System
                  80H    Directory
                   1     Both System and Directory

     10®   USEROÎ -- Thió flaç enableó oò disableó thå abilitù oæ 
the user to select different user areas via the DU: prefix.

     11®   xxxxOÎ -- Theså flagó enablå oò disablå variouó ZCPR2-
residenô commands®   MACROó arå availablå lateò iî ZCPRHDR.LIÂ tï 
definå  thå  nameó oæ thå commandó iæ thå useò wisheó  tï  changå 
them®  Theså xxxxOÎ flagó are:

               Flag      Commands Affected
               ----      -----------------
               DIRON          DIR
               LTON           LIST, TYPE
               GOON           GO
               ERAON          ERA
               SAVEON         SAVE
               RENON          REN
               GETON          GET
               JUMPON         JUMP

     12®  INTPATÈ -- Thió flaç determineó iæ ZCPR² useó aî inter
naì patè oò aî externaì patè foò COÍ filå searches®   Iæ  INTPATÈ 
ió  FALSE¬  theî  Externaì Patè ió selecteä anä thå nexô  equate¬ 
PATH¬ defineó thå baså addresó oæ thió Externaì Path®  Iæ INTPATÈ 
ió  TRUE¬  theî thå followinç IPATÈ macrï ió useä tï  definå  thå 
Internaì  Path¬  anä  thió  patè ió locateä withiî  ZCPR²  itselæ 
(takinç uğ space).


     13®   ERAxø  anä  ERDFLÇ -- Theså equateó deaì witè thå  ERÁ 
commanä  specifically¬  anä arå simplù ignoreä iæ ERÁ  ió  turneä 
off®  Theù worë togetheò tï providå thå followinç featureó tï thå 
ERA command:

          -- Settings --
          ERAOK     ERAV      Feature
          FALSE     anything  ERA will not ask to verify before
                                performing the erase
          TRUÅ      FALSÅ     ERÁ wilì alwayó asë tï verifù 
                                before performing the erase
          TRUE      TRUE      ERA will ask to verify before
                                performing the erase only if the
                                ERDFLG (recommended to be "V")
                                flag appears in the command line
                                after the file spec

     14®   DUPRMPÔ  -- Thió equatå enableó oò disableó thå  "du>¢ 
prompt®   Iæ  enabled¬  thå prompô foò useò inpuô wilì appeaò  aó 
"d>¢ oò "du>¢ (seå thå SUPREÓ flaç belo÷ also)®  Iæ disabled¬ thå 
prompô  wilì  onlù appeaò aó ">"®   Seå alsï  CPRMPÔ  anä  SPRMPÔ 
below.

     15®   MULTCMÄ  eô aì -- Thió equatå enableó oò disableó  thå 
ZCPR² multiplå commanä linå feature®  Iæ seô tï TRUE¬ thå featurå 
ió enableä anä thå CMDSEP¬  CLBASE¬  anä BUFLEÎ equateó takå  ef
fect.

          These other equates mean the following:

               CMDSEP -- definå  thå  characteò useä tï  separatå 
                         eacè entrù iî thå commanä line» iæ chan
                         geä  froí thå defaulô oæ  ";"¬  alì  thå 
                         ZCPR² utilitieó havå tï bå reinstalled

               CLBASE -- baså  addresó  oæ thå  Multiplå  Commanä 
                         Linå Buffer

               BUFLEN -- sizå oæ thå Multiplå Commanä Linå Buffeò 
                         iî bytes»  MUSÔ bå lesó thaî 25´ (É havå 
                         founä 20° tï bå quitå sufficient)


     16®   Wheeì  Bytå  Selectioî -- Thå Wheeì Bytå  facilitù  oæ 
ZCPR² ió useä tï makå ZCPR² á morå securå systeí bù enablinç  anä 
disablinç  selecteä ZCPR² residenô commands®   Witè thió facilitù 
enabled¬ á Wheeì Byte¬ whicè ió simplù á bytå whoså valuå ió ° oò 
0FFÈ thaô existó somewherå iî memory¬ ió examineä beforå á wheel-
baseä commanä ió executed®   Iæ thió bytå ió noô zero¬  theî  thå 
commanä executes»  iæ iô ió zero¬ theî thå commanä ió noô alloweä 
tï  executå  anä  ió exiteä witè aî  erroò  message®   Thå  ZCPR² 
transienô WHEEÌ ió employeä bù á privilegeä useò tï seô anä reseô 
thå  Wheeì Byte»  witè thå WHEEÌ command¬  á passworä ió requireä 
before any action is taken.

          Thå  nexô  seô  oæ equateó ió useä tï  (1©  definå  thå 
addresó  oæ thå Wheeì Bytå anä (2© selecô thå commandó whicè  arå 
tï responä tï thå Wheeì Bytå settinç anä aborô witè erroò iæ  thå 
Wheel Byte is a zero.

               WHLADR - Address of Wheel Byte

               WERA, WREN, WLT, WGO, WSAVE, WGET, WJUMP, WDU -
                    If TRUE, these equates make their associated
                    commands respond to the Wheel Byte:

                    Equate  Association      Equate  Association
                    WERA      ERA            WSAVE     SAVE
                    WREN      REN            WGET      GET
                    WLT       LIST/TYPE      WJUMP     JUMP
                    WGO       GO             WDU       DU: Change


     17®   Thå nexô equateó arå useä tï definå thå stacë useä  bù 
ZCPR2®   Thå  stacë  maù bå placeä internaì tï ZCPR²  (takinç  uğ 
space©  oò externaì tï ZCPR2®   Thå INTSTACË equatå determineó iæ 
thå stacë ió internaì tï ZCPR2»  iæ TRUE¬  sucè ió thå case®   Iæ 
INTSTACË ió FALSE¬  theî thå STKBASÅ equatå determineó wherå  thå 
bottoí oæ thå 48-bytå stacë ió locateä iî memory®   Thå installeò 
shoulä  noô  changå thå STACË equatå followinç STKBASÅ  sincå  4¸ 
byteó  (anä nï more© arå requireä foò thå stack®   Notå thaô  thå 
stack grows DOWN to STKBASE.  Summary:

          INTSTACK - TRUE if stack is internal to ZCPR2
          STKBASE  - if INTSTACK is FALSE, then this is the
                         address of the bottom of the stack


     18®   Simplå  Customizatioî Symboló -- Theså symboló providå 
foò furtheò customizatioî oæ ZCPR² tï á user'ó particulaò  tasteó 
anä  hardwarå  facilities®   Theù arå covereä brieflù herå  sincå 
theù arå alì quitå straight-forward.

Option Name    Function

   NLINES      Number of lines on the user's CRT for paging

   WIDE        Thió  equatå  ió useä tï selecô á narro÷  oò  widå 
               displaù undeò thå DIÒ command»  iæ WIDÅ ió equateä 
               tï  TRUE¬  eacè  filå  namå ió  separateä  bù  twï 
               spaces¬  á FENCE¬  anä twï morå spaces» iæ WIDÅ ió 
               equateä tï FALSE¬  eacè filå namå ió separateä  bù 
               onå space¬ á FENCE¬ anä onå morå space

   FENCE       Thió equatå defineó thå characteò useä tï separatå 
               entrieó  iî  á  displaù causeä bù thå DIÒ and  ERÁ 
               commands

   PGDFLT      Thió  ió  thå  Paginç Defaulô flaç  foò  thå  TYPÅ 
               command»  iæ PGDFLÔ ió seô tï TRUE¬  thå TYPÅ com
               manä  wilì  pagå itó outpuô bù defaulô anä  thå  Ğ 
               optioî  oî thå TYPÅ commanä (seå below© wilì  pro
               hibiô paging»  iæ PGDFLÔ ió seô tï FALSE¬ thå TYPÅ 
               commanä  wilì NOÔ pagå itó outpuô bù  defaulô  anä 
               thå Ğ optioî wilì enablå paging

   PGDFLG      Thió setó thå optioî characteò iî thå commanä linå 
               foò thå TYPÅ commanä (thå 'P§ mentioneä above)» iæ 
               thå  useò wisheó tï changå thió optioî  character¬ 
               hå neeä onlù changå thió equate

   MAXUSR      Thió  ió thå largesô useò numbeò recognizeä bù thå 
               useò numbeò processor»  iæ thå useò wisheó tï pro
               tecô thå higheò useò areas¬ hå maù seô thió symboì 
               tï thå highesô areá normallù accessable» 3± ió thå 
               largesô permitteä valuå foò MAXUSR»  iî anù  case¬ 
               1µ  ió  thå largesô useò numbeò onå maù  loç  intï 
               (unlesó MAXUSÒ ió lesó thaî 15)¬ buô iô ió noô thå 
               largesô useò numbeò thaô maù bå referenceä bù DIR¬ 
               ERA¬  anä thå otheò ZCPR2-residenô commandó (like¬ 
               "DIR A22:")

   MAXDISK     Thió  equatå  defineó thå numbeò oæ logicaì  diskó 
               thå  useò supportó oî hió system»  iô maù  noô  bå 
               greater than 16


   SYSFLG      Thió  ió thå optioî characteò foò thå DIÒ  commanä 
               linå whicè ió useä tï specifù thaô DIÒ searcè  Alì 
               Fileó  (botè $SYÓ anä $DIR© foò itó  display»  thå 
               distributeä defaulô foò thió ió 'A'
Š   SOFLG       Thió  ió thå optioî characteò foò thå DIÒ  commanä 
               linå whicè ió useä tï specifù thaô DIÒ searcè ONLÙ 
               thå  $SYÓ fileó foò itó display»  thå  distributeä 
               defaulô foò thió ió 'S'

   SUPRES      Seô  SUPREÓ tï TRUÅ tï suppresó printinç thå  useò 
               numbeò wheî thå useò ió undeò Useò Numbeò ° oò seô 
               SUPREÓ  tï FALSÅ tï ALWAYÓ displaù thå Useò Numbeò 
               witè thå ZCPR² prompt»  witè SUPREÓ seô tï TRUE¬ á 
               useò oî Bº  iî useò ° seeó 'B>§ aó thå prompt¬ buô 
               witè SUPREÓ seô tï FALSE¬  á useò oî Bº  iî useò ° 
               seeó 'B0>§ aó thå prompt

   SPRMPT      Thió ió thå ZCPR² prompô characteò whicè indicateó 
               thaô á SUBMIÔ filå ió iî execution»  bù defaulô iô 
               ió seô tï '$'¬  sï promptó likå 'A$§ appeaò durinç 
               SUBMIÔ filå execution

   CPRMPT      Thió ió thå ZCPR² prompô characteò whicè indicateó 
               thaô ZCPR² ió awaitinç á useò consolå command»  bù 
               defaulô  iô ió seô tï '>'¬  sï promptó  likå  'A>§ 
               appeaò  durinç  useò inpuô tï ZCPR2»  notå thaô  É 
               havå seô thå MSÂ oæ thió characteò sï thaô iô wilì 
               probablù  bå uniquå tï alì characteró senô tï  thå 
               consolå -- thå reasoî foò thió ió sï thaô thå  ZEØ 
               utilitù  wilì havå somethinç uniquå tï looë foò iî 
               ordeò tï resumå processinç froí useò inpuô  -- foò 
               morå details¬ refeò tï thå documentatioî oî ZEX

   NUMBASE     Thió  ió  thå escapå characteò useä bù thoså  com
               mandó  whicè requirå á DECIMAÌ numbeò aó aî  argu
               ment»  placinç  thió  characteò afteò  thå  numbeò 
               argumenô  switcheó thå baså  tï  HEXADECIMAL»  foò 
               example¬  'SAVÅ  1µ  MYFILE§ caî bå  expresseä  aó 
               'SAVÅ  FÈ  MYFILE§ iæ NUMBASÅ ió seô tï  'H§  (thå 
               default)

   SECTFLG     Thió  characteò constanô ió thå suffiø optioî  foò 
               thå SAVÅ commanä whicè specifieó thaô sectors¬  aó 
               opposeä  tï pages¬  arå tï bå saved»  thå  defaulô 
               valuå ió 'S'

   CURIND      Thió  characteò defineó thå symboì useä tï  repre
               senô  thå  currenô  disë oò currenô  useò  iî  thå 
               commanä searcè path» itó recommendeä valuå ió '$'

   COMMENT     Thió  characteò  ió useä tï makå thå entirå  ZCPR² 
               commanä  linå intï á commenô iæ iô appearó aó  thå 
               firsô characteò iî thå line» itó recommendeä valuå 
               ió ';'



     19®   NCHARÓ  anä  CTABLÅ -- NCHARÓ ió useä tï  specifù  thå 
numbeò oæ characteró iî á ZCPR2-residenô command®  Itó recommend
eä  valuå ió ´ (tï limiô thå overalì sizå oæ thå  commands)®   C
TABLÅ  ió á tablå containinç thå texô oæ eacè commanä namå  (eacè 
texô  entrù musô bå NCHARÓ long© anä thå addresó oæ eacè  commanä 
routine®  Thå tablå ió structureä aó follows:

               DB   'TEXT'    ;Command Text
               DW   ADR       ;Command Address
               ...            ;And So On ...

Witè  thió  tablå yoõ caî changå thå namå oæ  anù  ZCPR2-residenô 
commanä  tï  anythinç yoõ want¬  withiî reason®   'TYPE§  maù  bå 
changeä tï 'PRNT'¬  foò example®  Aó á rule¬ dï noô changå thå D× 
entrieó  withouô  á verù gooä reason®   Theså symboló  arå  fixeä 
withiî ZCPÒ2.ASM.

     20®   EXTFCÂ  anä  FCBADÒ -- EXTFCÂ indicateó wherå thå  FCÂ 
useä  tï  contaiî intermediatå anä commanä filå nameó  ió  tï  bå 
located®   Iæ  EXTFCÂ  ió TRUE¬  thió FCÂ ió locateä externaì  tï 
ZCPR2¬  anä  itó addresó ió indicateä bù FCBADR®   Iæ  EXTFCÂ  ió 
FALSE¬  thió FCÂ ió locateä internaì tï ZCPR2¬  anä morå spacå ió 
takeî  uğ withiî ZCPR² (3¶ byteó more© thaî woulä bå takeî uğ  iæ 
EXTFCÂ waó TRUE.

     21®   CMDRUN¬  ROOTONLY¬  anä  CMDFCÂ -- CMDRUÎ enableó  thå 
abilitù  oæ ZCPR² tï executå aî extendeä commanä processoò shoulä 
thå searcè foò á COÍ filå alonç thå commanä searcè patè fail®  Iæ 
CMDRUÎ  ió  TRUE¬  thió facilitù ió enabled®   Oncå iô  ió  TRUE¬ 
ROOTONLY and CMDFCB are active.

          ROOTONLÙ  indicateó whetheò ZCPR² wilì searcè alonç thå 
patè  foò thå extendeä commanä processoò oò jumğ directlù tï  thå 
rooô  (lasô directorù iî thå path)®   Iæ ROOTONLÙ ió  FALSE¬  thå 
patè searcè ió done®   ROOTONLÙ beinç FALSÅ causeó thå  executioî 
oæ  thå extendeä commanä processoò tï takå jusô á littlå biô morå 
timå  thaî iô woulä otherwise¬  buô morå flexibilitù ió addeä  tï 
thå system.

          CMDFCÂ  ió á MACRÏ whicè defineó thå firsô 1² byteó  oæ 
thå  FCÂ whicè defineó thå namå oæ thå extendeä commanä processoò 
tï bå searcheä for®   Yoõ maù namå iô anythinç yoõ desire¬ buô iô 
ió  recommendeä thaô thió namå contaiî aô leasô ¶  characteró  sï 
thaô  commanä  prefixinç  maù bå donå easilù iæ  sï  desireä  foò 
furtheò chaining.

          Refeò tï thå sectioî oî thå Extendeä Commanä  Processoò 
in the Concepts Manual for more information.



3.1  Patching SUBMIT.COM

     SUBMIT.COÍ maù bå patcheä tï ruî witè ZCPR² bù thå followinç 
procedurå  (thió  ió  recommendeä  iæ  thå  useò  doeó  noô  havå 
SUB.COM)®   Thió  patcè simplù makeó iô alwayó placå thå  $$$.SUÂ 
filå oî Drivå A:®  Illustrativå terminaì sessioî follows:


A>ddt b:submit.com
DDT VERS 2.0
NEXT  PC
0600 0100
-s5bb		<-- Patch is at 5BB Hex
05BB 00 1	<-- Change 0 (default drive) to 1 (drive A:)
05BC 24 .	<-- That's it!
-d5b0 5cf	<-- See change
05B0 00 00 00 00 00 00 30 30 31 20 24 01 24 24 24 20 ......001 $.$$$ 
05C0 20 20 20 20 53 55 42 00 00 00 1A 1A 1A 1A 1A 1A     SUB.........
-^C		<-- Done
A>save 5 newsubmt.com	<-- Save new SUBMIT.COM file


4.0  Special Installation Considerations

4.1  ZCPR2 Sizing

     Unlikå thå previouó commanä processor¬  ZCPÒ 1.0¬ ZCPR² siz
inç  ió somewhaô oæ á problem®   Certaiî combinationó oæ thå  op
tionó  foò thå TRUE/FALSÅ equateä symboló caî causå thå  sizå  oæ 
ZCPR²  tï exceeä 2Ë bytes¬  anä thió ió typicallù oæ concerî  anä 
noô  desireä (seå thå Rationalå manual)®   Iæ thå installer¬  foò 
instance¬  attemptó tï duplicatå thå ZCPÒ configuration¬ theî thå 
sizå oæ ZCPR² wilì exceeä 2Ë byteó bù abouô 3° bytes.

     Tï  helğ  thå installeò tï keeğ awarå oæ thå impacô  oæ  hió 
selection¬  thå  followinç sizinç charô ió provided®   Thió charô 
showó thå recommendeä optioî settingó oæ thå equateó iî  questioî 
anä thå costó (measureä iî byteó oæ code© associateä witè settinç 
theså  equates®   Iæ á cosô ió positive¬  theî thaô sayó thaô thå 
recommendeä  equatå settinç causeó thå indicateä numbeò oæ  byteó 
tï  bå  consumed¬  anä iæ thió settinç werå  reverseä  (i.e.¬  iæ 
currentlù TRUE¬  seô iô tï FALSE)¬  theî thå indicateä numbeò  oæ 
byteó woulä bå saved®  Á negativå cosô showó thaô thå recommendeä 
settinç ió consuminç feweò byteó thaî thå opposite.


                       ZCPR2 Sizing Chart
        Recommended                        Recommended
Symbol    Setting   Cost           Symbol    Setting   Cost

CMDRUN     TRUE       53           JUMPON     TRUE       11
DIRON      TRUE       41           LTON       TRUE      138
DRVPREFIX  TRUE       13           MULTCMD    TRUE      -67

DUPRMPT    TRUE       32           PGDFLT     TRUE        0
ERAOK      TRUE       40           RENON      TRUE       72
ERAON      TRUE       62           ROOTONLY   FALSE       0

ERAV       TRUE       19           SAVEON     TRUE       90
EXTFCB     TRUE      -33           SUBON      TRUE      142
GETON      TRUE       18           SUPRES     TRUE        3

GOON       TRUE       11           USERON     TRUE        3
INTPATH    FALSE      -9           WIDE       TRUE        2
INTSTACK   FALSE     -48           Wxxxx      FALSE     -8-3N*

ª  Therå arå eighô Wxxxø equateó whicè enablå thå indicateä  com
mandó tï responä tï thå Wheeì Byte®  Therå ió aî initiaì overheaä 
oæ  eighô byteó foò anù onå equatå tï bå enableä anä therå ió  aî 
additionaì  overheaä  oæ  threå byteó foò eacè  equatå  whicè  ió 
enabled®   Thaô is¬ tï enablå onå equatå costó 1± bytes¬ anä eacè 
additionaì equatå afteò thaô costó threå byteó more.


     Aó  aî installatioî trade-ofæ example¬  iæ thå useò  decideó 
thaô hå doeó NOÔ wanô tï supporô thå SUÂ filå capabilitù  (wisheó 
tï uså ZEØ exclusively)¬  theî hå caî seô SUBOÎ tï FALSÅ anä savå 
14²  bytes®   Iæ hå alsï decideó thaô hå doeó noô wanô tï havå tï 
worrù abouô allocatinç buffeò spacå foò aî externaì FCB¬  hå  caî 
seô  EXTFCÂ tï FALSE¬  buô thió costó hií 3³ byteó (3³ morå byteó 
arå consumeä bù havinç thió FCÂ internaì tï ZCPR² thaî havinç  iô 
external)®   Notå  thaô duå tï somå overlağ oæ functionó (sucè aó 
RENOÎ anä SAVEON)¬  spacå savingó maù varù dependinç oî thå  com
binationó oæ thå optionó selected.

4.2  Programs Which Try to Load the FCB Command Line

     Onå thinç thå useò anä installeò shoulä bå concerneä witè ió 
thå  uså oæ programó whicè emploù internaì knowledgå oæ thå  CP/Í 
2.²  CCĞ  tï  perforí somå oæ  theiò  functions®   Sucè  programó 
typicallù tampeò witè thå internaì commanä linå buffeò oæ thå CCĞ 
anä  theî  transfeò  controì tï thå CCĞ iî sucè á  waù  thaô  thå 
commanä  linå  theù storeä therå ió executed®   Undeò  ZCPR2¬  iæ 
MULTCMÄ  ió  TRUÅ (thå Multiplå Commanä Linå Buffeò  Facilitù  ió 
enabled)¬  theî  programó likå thió wilì bå  modifyinç  code/datá 
areá  insteaä oæ thå intendeä buffer¬  whicè ió nï longeò  there¬ 
and frequently cause bad things to happen.

     Anotheò  examplå ió wherå thå BIOÓ wisheó tï issuå á commanä 
oî  Warí oò Colä Bootó anä iô attemptó tï storå saiä  commanä  iî 
thå CCĞ commanä linå buffeò aó describeä above®  Similaò problemó 
will result.

     Thió  doeó noô meaî thaô ZCPR² ió removinç thió  capability¬ 
buô  iô doeó meaî thaô thå capabilitù ió noô invokeä iî thå  samå 
way®   Iî ordeò tï executå á desireä commanä linå seô bù á  tran
sienô  program¬  foò example¬  thå transienô neeä onlù storå  thå 
desireä commanä line¬  terminateä bù á binarù zero¬ iî thå propeò 
Multiplå  Commanä Linå Buffeò anä seô thå nexô characteò  pointeò 
tï  thå  firsô characteò tï bå executed®   Likewiså foò thå  BIOÓ 
case.


5.0  Modifications to the BIOS Cold Boot Routines

     Tï  fullù instalì ZCPR² aó recommendeä iî Sectioî  4.1¬  thå 
Colä Booô routinå iî thå BIOÓ musô allocatå somå buffeò spacå anä 
perforí somå initializationó whicè iô doeó noô normallù do®  Aó á 
workinç examplå oæ whaô É aí referrinç to¬  studù thå sourcå codå 
to the Cold Boot Routine in my BIOS:

;
;  Cold Boot Routine for CHBIOSZ
;    This routine allocates and initializes buffer space as
;    required to implement ZCPR2 as recommended.
;
cboot:
	lxi	sp,tpa		;Set up stack

;
;  Section CB-1:  Init Multiple Command Line Buffer
;
	if	multcmd		;Multiple Commands Allowed
	lxi	d,cmdset	;Set buffers for Multiple
                                ;  Command Processing
	lxi	h,clbase	;Command Line Base
	call	mover		;Copy an arbitrary 128 bytes
	endif

;
;  Section CB-2:  Init Memory-Based Named Directory
;
	if	ndir		;Named Directory Based in Memory
	lxi	d,ndvals	;Initial Values in Directory
	lxi	h,ndbase	;Named Directory Base
	call	mover		;Copy an arbitrary 128 bytes
	endif

;
;  Section CB-3:  Init IOBYTE and Redirectable I/O Drivers
;
	mvi	a,intioby	;Initialize the I/O Byte
	sta	iobyte
        lxi     d,iodrivers     ;Default I/O Drivers
        lxi     h,iobase        ;Base Address of Drivers
        call    mover           ;Copy an arbitrary 128 bytes

;
;  Section CB-4:  Init Default Command Search Path
;
	lxi	d,path		;Copy Cold-Boot Path
	lxi	h,pathbase	;Into System External Path Area
	mvi	b,9		;Always 9 bytes
	call	movlop


;
;  Section CB-5:  Print Prompt and Select User/Disk
;
	lxi	h,prompt	;Prep for sending signon message
	call	message		;Send the prompt
	mvi	a,0             ;Select user 0 and disk A
	sta	cpmdrv
	sta	cdisk

	jmp	gocpm

     ...

;
;  Copy An Arbitrary 128 Bytes from DE to HL
;
mover:
        mvi     b,128
movlop:
        ldax    d
        mov     m,a
        inx     h
        inx     d
        dcr     b
        jnz     movlop
        ret

     ...


;
;  Primitive Redirectable I/O Drivers which are loaded to
;  initially support I/O.  They are copied into a reserved
;  area of memory (I have allowed 1K for this) starting at
;  IOBASE (my base address is 0DC00H).  These drivers
;  provide only console I/O and disable the redirection
;  facilities.  During the course of work, these primitive
;  drivers are overlaid by the IOLOADER program with much
;  more sophisticated drivers.
;
;  Note the I use Z80 Relative Jump Instructions here because
;  this code is not executed where it is stored.  Any absolute
;  jumps would have to have their addresses adjusted after
;  the routines had been copied.
;
uart equ  0E3F9H         ;UART Address
rda  equ  4              ;UART RDA Bit

iodrivers:
     jr   ioerror        ;set no Status Routine
     db   0              ;Fill 3 bytes
     jr   ioerror        ;set no Select Routine
     db   0              ;Fill 3 bytes
     jr   ioerror        ;set no Namer Routine
     db   0              ;Fill 3 bytes

     ret                 ;No Terminal Init Necessary
     db   0,0            ;Fill 3 bytes
     jr   ustat          ;Console Input Status
     db   0              ;Fill 3 bytes
     jmp  djcin          ;Console Input Char in PROM
     jmp  djcout         ;Console Output Char in PROM

     jmp  djcout         ;List Output Char in PROM

     jmp  djcout         ;Punch Output Char in PROM

     jmp  djcin          ;Reader Input Char in PROM

     mvi  a,0ffh         ;List Status Ready
     ora  a              ;Set Flags
     ret                 ;Done with List and No New I/O Routine

ioerror:
     xra  a              ;No Device Assignments May be Made
     ret
ustat:
     lda  uart           ;Get status byte
     cma                 ;Inverted Logic
     ani  rda            ;RDA?
     rz
     mvi  a,0ffh         ;OK Flag
     ret
Š
     ...

;
;  Initial Command Line in Multiple Command Line Buffer
;  Only the first five bytes are required, the fifth byte being
;  a binary 0 to indicate an empty command line, if you do not
;  wish to have an initial command
;
     if   multcmd
clbase    equ  0ff00h    ;base address of buffer
buflen    equ  200       ;size of buffer in bytes
cmdset:
     dw   clbase+4  ;pt to first char
     db   buflen    ;size of buffer
     db   0         ;don't care value
     db   'STARTUP' ;command to run on Cold Boot
     db   0         ;end of Cold Boot Command
     endif

     ...

;
;  Initial Contents of Memory-Based Named Directory Buffer
;  Note:  this defines an empty Named Directory Buffer
;
     if   ndir      ;turned on?
ndbase    equ  0fd00h    ;base address of buffer
ndvals:
     db   50        ;allow 50 entries
     db   0         ;no entries stored (entry count)
     db   0         ;dummy for no disk
     db   0         ;dummy for no user
     db   0         ;dummy for no name
     endif

     ...

;
;  Initial External Path
;  The contents of the path are outlined in the comments
;
pathbase  equ  40h       ;base address of first byte of path
path:
     db   '$$'      ;current disk and current user
     db   '$',0     ;current disk and user 0
     db   1,'$'     ;disk A and current user
     db   1,0       ;disk A and user 0
     db   0         ;end of path

;
»  Noteº  Iô ió noô necessarù tï initializå anù otheò buffers¬ 
;    such as EXTFCB, since their values will be initialized by
;    ZCPR2
;Š
     Thió  samplå provideó á fairlù gooä modeì foò  configuratioî 
oæ  thå Colä Booô Routinå iî ordeò tï implemenô ZCPR²  aó  recom
mended®  Notå thaô fouò featureó requirå initialization:

          1) Multiple Command Line Buffer
          2) Memory-Based Named Directory Buffer
          3) Command Search Path
          4) Redirectable I/O Drivers

     Oæ  course¬  É  alsï initializeä thå I/Ï Bytå aô locatioî  ³ 
(thå STÁ IOBYTÅ instruction)¬  aî internaì currenô disë flag¬ anä 
thå  currenô user/currenô disë flaç dowî aô locatioî ´  (thå  STÁ 
CDISË instruction).

     Also¬  notå  thaô É jusô useä aî arbitrarù transfeò  routinå 
whicè  diä  noô consideò thå actuaì sizå oæ thå significanô  datá 
transferreä  foò thå initializatioî oæ thå Multiplå Commanä  Linå 
Buffer¬  thå Memory-Baseä Nameä Directorù Buffer¬  anä thå Redir
ectablå I/Ï Drivers®     Sincå botè bufferó anä thå driveró  werå 
undeò 12¸ byteó iî size¬ thió waó á quicë waù out.


5.1  Installation Note:  Multiple Command Line Buffer

     The structure of the Multiple Command Line Buffer is:

          Bytes 0 and 1:  Address of Next Char in Buffer
          Byte 2:  Size of Buffer
          Byte 3:  Dummy used by BDOS Readln Function 10
          Bytes 4 to n:  Buffer Contents, terminated by binary 0

     Thió buffeò MUSÔ bå initializeä bù thå Colä Booô routinå  iæ 
thå  Multiplå Commanä Linå facilitù ió enabled®   Thå addresó  oæ 
Bytå  ´ ió placeä iî Byteó ° anä ± (low-ordeò first)¬  thå buffeò 
sizå ió placeä iî bytå 2¬ anä anù valuå maù bå placeä iî Bytå 3.

     Thå  commanä linå tï bå executeä oî Colä Booô maù bå  placeä 
iî  Byteó  ´ tï n®   Notå thaô thió linå MUSÔ bå terminateä bù  á 
binarù  0®   Iæ yoõ havå nï commanä linå tï bå executeä  oî  Colä 
Boot, Byte 4 MUST be 0.

     Thå Multiplå Commanä Linå Buffeò playó manù keù roleó iî thå 
ZCPR²  System®   Iî mù opinion¬  iô ió onå oæ thå mosô  importanô 
featureó tï implement®  Througè thió buffer¬ thå useò caî perforí 
thå "simple¢ functioî oæ issuinç morå thaî onå commanä oî á line¬ 
but¬  morå importantly¬  programó caî uså iô tï chaiî tï á SERIEÓ 
oæ otheò programs®  Thå MENÕ commanä useó thió buffeò tï chaiî tï 
thå  selecteä prograí anä theî tï returî tï itselæ aô thå  propeò 
place®   STARTUĞ useó iô tï executå á commanä line¬  and¬ iî con
junctioî witè CD¬  STARTUĞ undeò thå namå oæ SÔ ió useä tï  esta
blisè  á  workinç  environmenô oncå thå useò haó  loggeä  intï  á 
directory®   Thió  workinç  environmenô  maù havå á  ne÷  commanä 
searcè path¬ á ne÷ nameä directorù structure¬ ne÷ devicå drivers¬ 
anä maù eveî bå menu-driven.Š
5.2  Installation Note:  Memory-Based Named Directories

     Iæ thå memory-baseä nameä directorù facilitù ió enabled¬  iô 
MUSÔ  bå initializeä bù thå Colä Booô Routine®   Thå structurå oæ 
thå   nameä  directorù  buffeò  (oî  initialization©  shoulä   bå 
(assuming it is empty):

          Byte 0:  Maximum number of entries
          Byte 1:  Number of entries stored
          Byte 2:  First Disk Number
          Byte 3:  First User Number
          Bytes 4-11:  First Directory Name

     Iæ  thå initializeä nameä directorù buffeò ió tï  bå  empty¬ 
Bytå ° shoulä bå seô tï thå numbeò oæ entrieó permitteä (baseä oî 
thå sizå oæ youò buffer© anä byteó ± tï ´ shoulä bå seô tï 0®  Iî 
computinç thå numbeò oæ entrieó alloweä iî á memory-baseä direct
orù buffer¬ thå followinç simplå equatioî applies:

          Byte 0 = (size of buffer)/10

Iæ thå remaindeò oæ thió divisioî ió lesó thaî 2¬ subtracô ± froí 
Bytå ° tï allo÷ foò thå spacå takeî bù byteó ° anä 1®   Thå 1° ió 
thå  numbeò oæ byteó occupieä bù aî entrù (² byteó foò  disk/useò 
anä ¸ foò directorù name).

     Thå memory-baseä nameä directorù featurå waó createä foò twï 
reasonsº  tï speeä uğ thå executioî oæ á utilitù wheî iô needó tï 
kno÷  thå  directorù  referenceä  bù á namå anä  tï  establisè  á 
"global¢ directorù structure®   Ratheò thaî doinç á disë  search¬ 
thå  utilitù  simplù  lookó iî thå memory-baseä  nameä  directorù 
buffer¬ anä thió saveó thå timå requireä foò thå disë accesseó iæ 
thå namå ió founä iî thå buffer®   Aó á "global¢ directory¬  thió 
memory-baseä  nameä directorù ió alwayó searcheä  first¬  sï  thå 
entrieó  iî  iô arå examineä beforå thå "local¢ directorù iî  thå 
NAMES.DIÒ filå oî disë ió examined®   Iî thió way¬  regardlesó oæ 
thå  treå oò mesè structurå imposeä bù logginç intï  variouó  en
vironments¬  á  seô  oæ directorieó caî remaiî commoî tï alì  en
vironmentó (unless¬  oæ course¬ SÔ loadó á ne÷ memory-baseä nameä 
directorù seô wheî thå useò logó intï á directorù viá CD).


5.3  Installation Note:  Redirectable I/O System

     Iæ  youò  ZCPR²  systeí ió tï emploù  thå  redirectablå  I/Ï 
systeí  whicè  maù  bå implementeä bù thå  IOLOADEÒ  anä  DEVICE² 
commands¬ theî thå Colä Booô Routinå wilì havå tï initializå thió 
system®   Ratheò thaî enteò á wordù explanatioî oæ whaô haó tï bå 
done¬  thå followinç ió thå sourcå tï mù initiaì Redirectablå I/Ï 
Driveró aó installeä bù thå Colä Booô Routine®   Notå twï thingsº  
(1©  thå  Colä Booô Routinå simplù copieó theså driveró intï  thå 
buffeò startinç aô IOBASÅ anä (2© alì brancheó tï routineó withiî 
theså  driveró arå relativå sï thaô É don'ô havå tï  worrù  abouô 
adjustinç addresseó foò theiò location.  Source Code follows:Š
*****************************************************************
*								*
* Primitive I/O Drivers which are loaded at Cold Boot time.	*
*                                                               *
* Note:  DJCIN and DJCOUT are in PROM, so their addresses are   *
*        fixed and need not be adjusted because of the copy.    *
*								*
*****************************************************************
uart	equ	0e3f9h		;UART address
rda	equ	4		;UART RDA Bit

iodrivers:
	jr	ioerror		;no Status Routine
	db	0		;Fill 3 bytes
	jr	ioerror		;no Select Routine
	db	0		;Fill 3 bytes
	jr	ioerror		;no Namer Routine
	db	0		;Fill 3 bytes

	ret			;Initialize Terminal
	db	0,0		;Fill 3 bytes
	jr	ustat		;Console Input Status
	db	0		;Fill 3 bytes
	jmp	djcin		;Console Input Char
	jmp	djcout		;Console Output Char

	jmp	djcout		;List Output Char

	jmp	djcout		;Punch Output Char

	jmp	djcin		;Reader Input Char

	mvi	a,0ffh		;List Status Ready
	ora	a		;Set Flags

	ret			;New I/O Driver Installation Routine

ioerror:
	xra	a		;No device assignments
	ret

ustat:
	lda	uart		;Get status byte
	cma			;Inverted Logic
	ani	rda		;RDA?
	rz
	mvi	a,0ffh		;OK Flag
	ret


     Asidå  froí  givinç  thå useò á loô oæ  flexibilitù  iî  thå 
desigî oæ hió I/Ï system¬ thå Redirectablå I/Ï Systeí alsï offeró 
aî  alternativå  tï thå Control-Ğ (Consolå Print© functioî  undeò 
CP/M®   Usinç  Control-P¬  thå  useò caî temporarilù  togglå  thå 
printeò  oî  tï prinô whaô ió cominç tï  hió  display®   However¬ 
undeò certaiî conditions¬  wheî thå prompô reappeared¬ thå print
ouô  woulä continuå anä requirå anotheò Control-Ğ tï turî iô  ofæ 
whilå  undeò otheò conditions¬  wheî thå prompô  reappeared¬  thå 
printouô woulä bå turneä ofæ bù itself.

     Usinç  Redirectablå  I/O¬  á devicå driveò foò  thå  Consolå 
whicè consisteä oæ CRÔ Inpuô anä CRT/Printeò Outpuô coulä  easilù 
bå created®  Let'ó saù iô ió nameä CRTPRINÔ and¬ usinç DEVICE¬ iô 
woulä bå turneä oî witè á commanä like:

          DEVICÅ CON:=CRTPRINT

Turninç iô ofæ woulä amounô tï issuinç á commanä like:

          DEVICÅ CON:=CRT

     Usinç  sucè  á devicå driveò solveó twï problemsº   (1©  thå 
useò haó preciså controì oæ thå printeò anä (2© thå user¬ viá thå 
devicå  driver¬  caî controì whaô goeó ouô tï  thå  printer¬  anä 
speciaì characteò sequenceó whicè woulä normallù gï tï thå screeî 
caî bå filtereä froí goinç tï thå printeò aó well®   Somå concerî 
haä beeî raiseä abouô usinç á characteò witè thå mosô significanô 
biô  seô  tï  prompô ZEØ froí ZCPR² sincå sucè  characteró  placå 
certaiî  printeró  intï á graphicó mode®   Sucè á  devicå  driveò 
coulä  cleaò  thå mosô significanô biô beforå iô ió senô  tï  thå 
printer.


5.4  Installation Note:  Default Command Search Path

     Iæ thå externaì patè featurå ió enabled¬  theî thå Colä Booô 
Routinå MUSÔ initializå thió path®   Thå patè ió representeä bù á 
standarä patè expression¬ wherå "$¢ indicateó thå currenô useò oò 
disk¬  diskó  arå  numbereä froí ± (disë Á ½ 1)¬  anä  useró  arå 
numbereä froí 0®  Thå patè MUSÔ bå terminateä bù á binarù 0.

     Searcè  pathó  providå WORLDÓ oæ flexibilitù  tï  thå  user®  
ZCPR² requireó aô leasô onå patè tï bå implemented®   Thió ió thå 
commanä searcè path¬ whicè ió thå patè alonç whicè ZCPR² searcheó 
foò commandó (COÍ files© wheî theù arå issued®   Thió patè maù bå 
placed internal to ZCPR2 or external to it.


     Thå commanä searcè patè ió thå onlù patè REQUIREÄ iî á ZCPR² 
System¬  buô  manù  morå pathó maù bå  established®   Eacè  ZCPR² 
Systeí utilitù prograí ió seô uğ tï deaì witè pathó iî onå oæ twï 
oò  morå waysº   (1© iô maù follo÷ aî externaì patè knowinç  onlù 
thå addresó oæ thå beginninç oæ thå path¬  anä (2© iô maù  follo÷ 
itó  owî  internaì patè knowinç exactlù whaô thaô patè  is®   Thå 
HELĞ  prograí ió aî exceptioî tï thió iî thaô iô followó  aî  ex
ternaì  patè  (iæ therå ió one© and¬  iæ thaô fails¬  followó  aî 
internaì path®   Thå externaì pathó followeä bù thå utilitieó  iî 
thå ZCPR² Systeí maù bå thå samå aó thå commanä searcè path¬  buô 
theù  don'ô  havå tï be®   ZEX¬  foò instance¬  maù bå seô uğ  tï 
ignorå thå commanä searcè patè anä follo÷ á patè whicè immediate
lù goeó tï á directorù containinç á hosô oæ ZEØ commanä files.

     Configuratioî  noteó caî bå founä iî thå User'ó Guidå  whicè 
providå ideaó aó tï ho÷ pathó maù bå establisheä foò thå  variouó 
ZCPR² Systeí utilities®   Remembeò thaô foò eacè patè establisheä 
whicè  ió  externaì  tï  á utilitù program¬  thió  patè  musô  bå 
initialized in one way or another before the utility uses it.

     Thió initializatioî oæ externaì pathó otheò thaî thå commanä 
searcè  patè  useä  bù ZCPR² itselæ maù bå donå iî aô  leasô  twï 
differenô waysº   (1© thå Colä Booô Routinå maù perforí thå init
ialization¬  oò  (2© PATÈ (whicè maù bå executeä oî colä booô  bù 
thå  STARTUĞ program© maù bå useä tï perforí thå  initialization®  
Iæ  morå thaî onå externaì patè ió defineä anä thå useò ió tï  bå 
ablå tï changå thå contentó oæ thió patè iæ hå wishes¬  theî  thå 
PATÈ  utilitù  shoulä  bå installeä morå thaî  oncå  anä  severaì 
versionó  oæ  PATÈ shoulä bå createä (usinç differenô  names¬  oæ 
course)®   Onå versioî oæ PATÈ ió requireä foò eacè externaì patè 
whicè ió tï bå manipulated®  GENINÓ caî bå useä tï quicklù creatå 
thå differenô versionó oæ PATH.


5.5  Installation Note:  Sample ZCPR2 Structure

     Aó aî example¬  thå followinç ió aî outlinå oæ thå structurå 
oæ mù ZCPR² system®  Alì addresseó arå expresseä iî hexadecimal.

     Page 0 (Base Page):
          Location  Contents
           0 -  2   JMP to BIOS Warm Start at D300
           3        IOBYTE
           4        UDFLAG - User Number in Upper 4 Bits; Disk
                         Number (A=0) in Lower 4 Bits
           5 -  7   JMP to BDOS at C506
           8 - 37   Unused Interrupt Vectors
          38 - 3A   RST 7 used by DDT, ZSID, and others
          3B        Wheel Byte
          3C - 3F   Unused
          40 - 5B   Default Command Search Path (up to 13 elts
                         and terminating 0)
          5C - 6B   First FCB Half
          6C - 7B   Second FCB Half
          7C        CR Field if 5C-7B used as one complete FCB
          7D - 7F   Random Record Number
          80 - FF   Default DMA Buffer

     Belo÷ BD00º    Optionaì ZEØ Monitoò anä Texô (Variablå Size)
     Address BD00:  Beginning of ZCPR2
     Address C500:  Beginning of BDOS
     Address D300:  Beginning of BIOS
     Address DC00:  Reserved Buffer Area
     Address E000:  Disk PROM
     Address E400:  Disk RAM
     Address E800 - EFFF:  Redirectable I/O Drivers (2K Avail)
     Address F000 - F600:  Free Space Optionally Used by
                              Redirectable I/O Drivers
     Address F5D0 - F5FF:  ZCPR2 Stack (48 Bytes)
     Address F600 - FCFF:  Buffer Space Used by BIOS
     Address FD00 - FEFF:  Memory-Based Named Directory Buffer
                              (512 Bytes for 50 Entries)
     Address FF00 - FFCF:  Multiple Command Line Buffer
                              (200 Bytes for text + 4 for
                               initial buffers + Dead Space)
     Address FFD0 - FFFF:  ZCPR2 External FCB


6.0 Installing the ZCPR2 Utilities

     Sï far¬  É havå beeî concentratinç oî ZCPR² itself®   ZCPR2¬ 
however¬ ió onlù á parô (lesó thaî 1/1° iî termó oæ codå size© oæ 
thå ZCPR² System®  Thå resô oæ thå Systeí ió madå uğ oæ thå ZCPR² 
utilities.

     Mosô oæ thå ZCPR² Utilitieó neeä tï kno÷ somethinç abouô thå 
ZCPR²  environment®   Iî particular¬  theså utilitieó neeä tï  bå 
installeä  iî  ordeò  tï becomå aî integraì parô oæ  thå  overalì 
system¬  anä á program¬ GENINÓ (foò Generaì Install)¬ ió provideä 
to do this.

     GENINÓ provideó teî basiã configuratioî optionó tï thå user®  
These are:

     0.  Named Directory Data

       a.  Address of Memory-based Named Directory Buffer
          Thió  ió  thå startinç addresó oæ thå  Nameä  Directorù 
Buffeò storeä iî memory®   Iæ yoõ dï noô havå one¬ seô thió valuå 
tï 0.

       b®  Numbeò oæ Nameä Directorieó Alloweä iî á Nameä Direct
orù File
          Thió  valuå  ió initiallù seô bù thå MKDIÒ  prograí  bù 
creatinç  thå  Nameä Directorù Filå witè thå indicateä numbeò  oæ 
entries®   Alì programó usinç thió filå musô bå seô tï responä tï 
thå samå numbeò oæ entries®  Anù numbeò lesó thaî 25¶ ió allowed¬ 
anä  6´ ió recommendeä foò standardizatioî purposeó (anä  becauså 
iô ió reasonablå aó determineä througè experience).

       c.  Name of the Named Directory File to Scan for on Disk
          Thió  ió  thå namå oæ thå filå tï bå scanneä foò  iæ  á 
directorù  namå ió noô founä iî thå memory-baseä Nameä  Directorù 
Buffer®   Thå recommendeä namå (foò standardizatioî purposes©  ió 
NAMES.DIR.

     1.  External and Internal Path Data

       a.  Enable or Disable External Paths
          Thå  utilitù ió tolä whetheò iô maù uså externaì  pathó 
foò itó functionó oò noô bù thió option®  Externaì pathó arå useä 
foò  filå  searcheó anä Nameä Directorù filå searcheó  primarily¬ 
buô theù maù havå otheò useó aó well¬  dependinç oî thå  utility®  
Iæ externaì pathó arå available¬  thå PATÈ commanä maù bå useä tï 
initializå theí oî colä booô oò tï changå theí dynamicallù durinç 
á terminaì session®   Iæ externaì pathó arå noô tï bå used¬  theî 
internaì  paths¬  uniquå  tï  eacè utility¬  maù bå  defineä  anä 
employeä instead®   Iæ neitheò externaì noò internaì pathó arå tï 
bå used¬ theî thå utilitù (usually© wilì onlù examinå thå currenô 
directorù  foò whaô iô needs®   Aó á generaì  rule¬  iæ  externaì 
pathó  arå noô used¬  definå aî internaì path¬  anä thió internaì 
path may be as simple as current directory.Š
       b.  If enabled, the Address of the External Path
          Iæ  aî  externaì  patè ió enabled¬  thió  ió  thå  baså 
addresó  oæ  thå beginninç oæ thå path®   Iæ externaì  pathó  arå 
disabled¬  GENINÓ  doeó noô givå thå useò thå optioî tï seô  thió 
value.

       c.  Enable or Disable Internal Paths
          GENINÓ  giveó thå useò thå optioî tï enablå anä  definå 
aî internaì patè regardlesó oæ hió selectioî foò externaì  paths®  
Somå commands¬ HELĞ iî particular¬ maù uså botè pathó iæ theù arå 
available®  Iî thå caså oæ HELP¬ wheî lookinç foò á HELĞ file¬ iô 
searcheó  alonç  thå  externaì patè  first¬  and¬  failinç  that¬ 
searches along its internal path.

       d®  Iæ enabled¬ definå thå internaì patè foò thaô particu
laò utility
          Thå  internaì patè ió defineä iæ thå useò  selecteä  tï 
enablå  internaì paths®   Symboliã notatioî ió useä tï definå thå 
path¬ anä thå useò ió prompteä foò eacè patè elemenô iî sequence®  
Nameä Directorieó maù NOÔ bå useä iî thå  definition®   Hence¬  á 
definitioî  likå  $¤  $° A¤ A° (foò  currenô  disk/user¬  currenô 
disk/useò  0¬  disë  A/currenô user¬  anä disë A/useò 0©  maù  bå 
specified.

     2.  Multiple Command Line Data

       a.  Enable or Disable the Multiple Command Line Buffer
          Iæ  thå  Multiplå Commanä Linå facilitù ió  enableä  bù 
ZCPR² anä thå Colä Booô Routinå iî thå BIOS¬ theî thå useò shoulä 
telì thå utilitù thaô thió facilitù ió available®   Notå thaô thå 
buffeò MUSÔ bå initializeä beforå use®   Severaì utilitieó emploù 
thå Multiplå Commanä Linå Buffeò foò chaininç purposes¬  anä somå 
utilities, like MENU and STARTUP, cannot run without it.

       b.  If enabled, address of Multiple Command Line Buffer
          Thió  specifieó wherå thå Multiplå Commanä Linå  Buffeò 
ió located®   Notå thaô onlù ONÅ Multiplå Commanä Linå Buffeò maù 
bå defineä foò á particulaò system¬ unlikå thå externaì paths¬ iî 
whicè caså therå maù bå aó manù aó desired®   ZCPR² ió desireä tï 
deaì  witè onlù onå sucè buffeò anä cannoô accepô  commandó  froí 
more than one.
          Note¬  however¬  thaô  manù buffeò areaó maù bå defineä 
foò  thå  purposå  oæ  passinç  informatioî  betweeî   utilities¬ 
particularlù  thoså whï maù bå chaineä togetheò viá thå  Multiplå 
Commanä  Linå Buffeò Facility®   Theså utilitieó arå chaineä  viá 
thå buffer¬ buô maù uså otheò bufferó tï pasó informatioî tï eacè 
other®   Theù  maù  alsï pasó informatioî tï eacè otheò  viá  thå 
command lines in the Multiple Command Line Buffer.


     3.  Maximum Disk which may be Referenced

          Thió  parameteò ió availablå foò thå purposeó  oæ  pro
tectinç thå systeí anä providinç á leveì oæ security®  Iî thå waù 
oæ  protectinç thå system¬  bù specifyinç thå maximuí disë letteò 
(likå Ä iæ therå arå fouò drives)¬  theî thå utilitù wilì flaç aî 
erroò iæ á referencå ió madå tï anù drivå greateò thaî D¬ therebù 
trappinç thå erroò beforå thå BDOS/BIOÓ seeó it.
          Iî  thå waù oæ providinç á leveì oæ  security¬  certaiî 
programó  maù  bå madå availablå  iî  twï  versions®   XDIR¬  foò 
instance¬ caî bå seô uğ tï bå founä alonç á useò patè iî whicè iô 
onlù  knowó  oæ driveó Á anä Â anä doeó noô permiô accesó  tï  C¬ 
while¬  oncå á useò haó loggeä intï á systeí directorù anä á new¬ 
systeí  patè ió established¬  á differenô XDIÒ maù bå encountereä 
alonç thió systeí patè whicè knowó abouô drivå Ã also.

     4.  Maximum User which may be Referenced

          Thió  parameteò  ió availablå foò thå purposå  oæ  pro
vidinç á leveì oæ securitù only®   Alonç thå lineó oæ (3©  above¬ 
twï  pathó (useò anä system© anä twï setó oæ commandó (likå XDIR© 
maù  bå establisheä iî whicè thå anyonå employinç thå  useò  patè 
cannoô  accesó beyonä á giveî useò numbeò whilå anyonå  employinç 
thå systeí patè can.

     5.  Allow the User to Reference a Disk

          Again¬  tï  providå aî eveî furtheò leveì oæ  security¬ 
thå abilitù tï referencå anù disë otheò thaî thå currenô disë caî 
bå  disabled®   Thió musô bå permitteä iî ordeò foò thå Ä parô oæ 
thå DÕ forí tï bå effectivå foò thå particulaò utility¬ anä Nameä 
Directory references are affected as well.

     6.  Allow the User to Reference a User Area

          Thió ió thå samå aó (5)¬  buô thå abilitù tï  referencå 
any user area other than the current user can be disabled.


     7.  Privileged User Areas

       a.  Base Address (first priv user area)
          Á  seô  oæ useò areas¬  beginninç aô á particulaò  useò 
area¬  caî  bå  declareä tï bå privileged®   Accesó  tï  theí  ió 
granteä  onlù iæ thå correcô passworä ió given®   Thå recommendeä 
baså addresó oæ thå privilegeä useò areaó ió 10¬ sï useò areaó 1° 
tï 3± maù bå accesseä onlù wheî á passworä ió given®   Notå  thaô 
thió  optioî applieó ONLÙ tï thå ZCPR² utilitieó anä noô tï ZCPR² 
itself®   Oncå  thå ZCPR² Systeí ió configureä foò thió  forí  oæ 
security¬  thå  DÕ  forí shoulä bå disableä withiî ZCPR²  oò  thå 
Wheel facility should be set up to control use of the DU form.
          Thå privilegeä useò definitionó applù tï thå CÄ (Changå 
Directory©  prograí iî particular®   Thió prograí ió useä iî lieõ 
oæ thå DUº commanä tï loç intï ne÷ directories®  Iô alwayó checkó 
tï  seå iæ thå useò ió enterinç á privilegeä directorù  anä  askó 
for the password before it allows him to enter.

       b.  Password required to enter a priv user area
          This is the password required for access rights.

     8.  Current User/Disk Symbol

          Iæ  thå  installeò haó opteä tï uså somå  otheò  symboì 
(otheò thaî "$"© tï represenô thå currenô disë oò currenô useò iî 
symboliã  patè  expressionó undeò ZCPR2¬  thå utilitù  shoulä  bå 
informeä  oæ  thió  fact®    Naturally¬  somå  valuå  haó  tï  bå 
specified¬  anä  thå  recommendeä symboì oæ "$¢ ió preferreä  foò 
standardization purposes.

     9.  DMA Address for Disk I/O

          Iæ thå useò haó á non-ORG-° system¬  theî thió musô  bå 
seô  tï definå thå DMÁ Addresó (Defaulô establisheä bù ZCPR2©  oæ 
thå  system®   Thió  addresó ió usuallù RAÍ baså « 80H¬  anä  thå 
value for an ORG-0 system is 80H.



     Whilå runninç GENINS¬  whicè ió menu-oriented¬  thå useò  ió 
provided with the abilities to perform the following functions:

     1®   Seô anù combinatioî oæ thå abovå characteristicó foò  á 
particulaò utility

          Thå  Ó  optioî  allowó thå useò  tï  sequentiallù  pasó 
througè  alì oæ thå necessarù parameteró anä seô  them®   Iæ  thå 
useò wisheó tï selecô theí individually¬ typinç á digiô froí ° tï 
¹  selectó  thaô  particulaò parameteò foò  installation®   Iæ  á 
particulaò  optioî ió noô needeä bù thå utilitù  currentlù  beinç 
installed¬  iô ió flaggeä witè aî asterisk¬ anä selectioî oæ thió 
optioî bù digiô performó nï operatioî whatsoever®   Thå Ó option¬ 
iæ  selected¬  simplù skipó alì parameteró flaggeä witè aî aster
isk.
          Somå  utilitieó requirå parameteró tï bå seô whicè  arå 
noô  covereä  bù thå standarä group®   Knowledgå oæ  thå  utilitù 
(refeò  tï thå User'ó Guide© ió requireä tï makå á gooä  judgmenô 
oî thå propeò settinç foò thå requireä parameter®   Iæ additionaì 
parameteró arå tï bå set¬ aî Á optioî appearó iî thå menu®  Thå Ó 
optioî  automaticallù  extendó tï  coveò  thoså  utility-specifiã 
parameters¬  anä  thå Á optioî maù bå useä likå á digiô optioî tï 
select just the utility-specific parameters to be set.

     2®  Displaù thå currenô settingó foò á particulaò utility

          Thå  Ğ  optioî  displayó thå currenô  settingó  oæ  alì 
parameteró foò thå utilitù beinç installed®   Iæ utility-specifiã 
parameters are available, these are printed as well.

     3®  Savå thå currenô settingó sï thaô anotheò utilitù maù bå 
seô uğ iî aî identicaì waù bù meanó oæ á simplå restorå command

          Thå  ¼ optioî saveó alì oæ thå standarä parameteró intï 
tï  savå buffeò foò lateò recalì bù thå ¾  option®   Usinç  theså 
optionó iî thå menu¬  thå useò caî gï througè thå tasë oæ settinç 
alì  oæ thå optionó oæ á "complete¢ utilitù (onå iî whicè alì  oæ 
thå parameteró indicateä bù digitó arå necessary© onlù once¬ theî 
savå hió selectionó witè thå ¼ option¬  writå thå currenô utilitù 
tï  disk¬  reaä iî thå nexô utilitù withouô leavinç  GENINS¬  anä 
theî  seô  itó parameteró bù thå ¾ option®   Thå nexô utilitù  ió 
theî  writteî tï disk¬  anä á thirä utilitù ió selecteä  anä  itó 
parameteró  seô  bù >®   Thió caî gï oî  indefinitely¬  anä  thió 
procesó  significantlù  reduceó thå timå requireä tï instalì  thå 
seô oæ ZCPR² utilities.

          GENINÓ  itselæ musô bå installeä bù  GENINS¬  and¬  al
thougè GENINÓ doeó noô requirå alì oæ thå parameters¬  É havå seô 
iô uğ tï declarå alì parameteró necessary®   Hence¬  aó á generaì 
rule¬  instalì  GENINÓ firsô anä savå youò installatioî  settingó 
viá  <®   Then¬  simplù  instalì eacè oæ thå otheò  utilitieó  iî 
successioî  bù usinç ¾ tï seô thå digit-specifieä parameteró  anä 
usinç thå Á optioî tï seô thå utility-specifiã parameters.
Š
     4®   Restorå  thå settingó froí thå lasô savå aó thå currenô 
settingó foò á ne÷ utility

          Froí  before¬  thå  ¾  optioî ió useä  tï  restorå  thå 
parameteró  saveä bù thå ¼ optioî intï á ne÷ utility®   Iæ ¼  haó 
noô beeî previouslù issueä durinç thå currenô GENINÓ run¬ theî aî 
erroò messagå wilì bå printeä iæ thå useò attemptó tï emploù  thå 
> option.

     5®   Quiô  anä Dï NOÔ Updatå thå utilitù oò Exiô anä  Updatå 
thå currenô utility

          Iæ  thå useò reallù ble÷ thå procesó oæ installinç  thå 
currenô  utility¬  hå  caî  simplù thro÷ awaù everythinç  hå  diä 
without affecting the utility file on disk.

     6®   Seô  otheò attributeó specifiã tï thå  currenô  utilitù 
whicè arå noô commoî tï thå otheò ZCPR² utilities

          Theså parameteró arå noteä wheî aî Á optioî appearó  iî 
thå  menu®   Theså  arå  uniquå tï á specifiã utilitù oò  seô  oæ 
utilitieó anä arå noô affecteä bù thå ¼ anä ¾ commandó (onlù  thå 
digit-selected parameters are affected by these commands).

6.1  Sample GENINS Session

     Thå  followinç  GENINÓ  sessioî illustrateó thå  procesó  oæ 
utilitù installatioî extensively®   Commentó arå noteä ouô tï thå 
right side as text preceeded by the "<<" symbol.


B4>genins genins         << Install GENINS first
GENINS Version 2.1       << This is probably NOT the version
                              << number which will be distributed
                              << with the ZCPR2 System
GENINS -- General Installation Program for ZCPR2 Utilities
Ready to Set Default Values   << It has found and read in the
                              << parameter section of the file

File Being Installed: GENINS  .COM
** GENINS Flag/Value Setup **      << Menu Follows
        Select Standard Flags and Values
                (* indicates unnecessary option) --

        P  Print Flags and Values       S  Setup ALL Flags and Values
        <  Save All Flags/Values        >  Restore All Flags/Values
        Q  Quit and Do Not Update       X  Exit and Optionally Update

        0  Setup Named Directory Data     5  Set Disk Allowed Flag
        1  Setup External Path Data       6  Set User Allowed Flag
        2  Setup Multiple Command Line    7  Setup Priv User Data
        3  Set Max Disk                   8  Set Current User/Disk Data
        4  Set Max User                   9  Set File DMA Address
ŠSetup Command (? for Menu)? P      << Print current params
**** Default Flag/Value Settings ****
Enable External Paths: Yes  External Path Address: 0040 Hex
   Internal Path is -- Empty
Enable Multiple Command Line Buffer: Yes  Buffer Address: FF00 Hex
Maximum Disk: D   Maximum User Number:  31
Disk Specification Allowed: Yes   User Spec Allowed: Yes
Base of Privileged User Areas:  10   Password: chdir
Current User/Disk Indicator: $   DMA Address for Disk I/O: 0080 Hex
Address of Memory-Resident Named Directory Buffer: FD00 Hex
   Number of Named Dirs Allowed:  64   Named Dir File: NAMES   .DIR

Setup Command (? for Menu)? S      << Set ALL Params in sequence

Address of Memory-Resident Named Directory Buffer: FD00 Hex
   Number of Named Dirs Allowed:  64   Named Dir File: NAMES   .DIR
** Setup Questions **
1  Address of Memory-Resident Named Directory Buffer
        Enter Hex Number or <RETURN> = None? fd00
2  Number of Named Directories Permitted? 
        Enter Decimal Number or <RETURN> =  64? 
3  Name of Named Directory File? 
        Enter only File Name and Type -- DIR: form will be ignored
        Directory File Name (<RETURN> = NAMES   .DIR)? 

Enable External Paths: Yes  External Path Address: 0040 Hex
   Internal Path is -- Empty
** Setup Questions **
1  Enable External Paths (Y/N/other=Y)? 
1a Address of External Path in Hex (<RETURN> = 0040 Hex)? 
2  Enable Internal Path (Y/N/other=Y)? 
2a Define Internal Path Using Symbolic Notation --
1.  Path Element (<CR>=Done)? a$
2.  Path Element (<CR>=Done)? a15
3.  Path Element (<CR>=Done)? 

Enable Multiple Command Line Buffer: Yes  Buffer Address: FF00 Hex
** Setup Questions **
1  Enable Multiple Command Line Buffer (Y/N/other=Y)? 
1a Address of Multiple Command Line Buffer
        Enter Hex Number or <RETURN> = FF00 Hex? 

Maximum Disk: D   Maximum User Number:  31
** Setup Questions **
1  Maximum Disk Allowed? B

Maximum User Number:  31
** Setup Questions **
1  Maximum User Number Allowed (<RETURN> =  31)? 15

Disk Specification Allowed: Yes   User Spec Allowed: Yes
** Setup Questions **
1  Specification of Disk Allowed (Y/N/other=Y)? 

ŠUser Spec Allowed: Yes
** Setup Questions **
1  Specification of User Allowed (Y/N/other=Y)? 

Base of Privileged User Areas:  10   Password: chdir
** Setup Questions **
1  Base of Privileged User Areas (<RETURN> =  10)? 
2  Privileged User Password? chdir

Current User/Disk Indicator: $   DMA Address for Disk I/O: 0080 Hex
** Setup Questions **
1  Current User/Disk Indicator? $

DMA Address for Disk I/O: 0080 Hex
** Setup Questions **
1  DMA Address for Disk I/O
        Enter Hex Number or <RETURN> = 0080 Hex? 


Setup Command (? for Menu)? P      << Print new settings
**** Default Flag/Value Settings ****
Enable External Paths: Yes  External Path Address: 0040 Hex
   Internal Path is -- A$: --> A 15:
Enable Multiple Command Line Buffer: Yes  Buffer Address: FF00 Hex
Maximum Disk: B   Maximum User Number:  15
Disk Specification Allowed: Yes   User Spec Allowed: Yes
Base of Privileged User Areas:  10   Password: chdir
Current User/Disk Indicator: $   DMA Address for Disk I/O: 0080 Hex
Address of Memory-Resident Named Directory Buffer: FD00 Hex
   Number of Named Dirs Allowed:  64   Named Dir File: NAMES   .DIR

Setup Command (? for Menu)? /      << Any invalid cmd gives menu
File Being Installed: GENINS  .COM << Reminder of file name
** GENINS Flag/Value Setup **
        Select Standard Flags and Values
                (* indicates unnecessary option) --

        P  Print Flags and Values       S  Setup ALL Flags and Values
        <  Save All Flags/Values        >  Restore All Flags/Values
        Q  Quit and Do Not Update       X  Exit and Optionally Update

        0  Setup Named Directory Data     5  Set Disk Allowed Flag
        1  Setup External Path Data       6  Set User Allowed Flag
        2  Setup Multiple Command Line    7  Setup Priv User Data
        3  Set Max Disk                   8  Set Current User/Disk Data
        4  Set Max User                   9  Set File DMA Address

Setup Command (? for Menu)? <      << Save params


Setup Command (? for Menu)? X      << Exit and Update
Do you want to save changes (Y/N/other=Y)? Y      << Yes, Update
Please Provide Name of Output File
Namå  oæ Filå (<CR>=GENINÓ  .COM)¿  genins²         <¼  Ne÷  filå 
Namå oæ Outpuô Filå ió GENINS² .COÍ -- Verifù (Y/N/other=Y)¿ 
Writing File GENINS2 .COM to Disk --

Reading Block    95      << Numbers flash by as GENINS works
Writing Block    95
Please Provide Name of File to Install       << Ready to Continue
Name of File (<CR>=Abort)? mcopy        << New File
Ready to Set Default Values

File Being Installed: MCOPY   .COM
** GENINS Flag/Value Setup **
        Select Standard Flags and Values
                (* indicates unnecessary option) --

        P  Print Flags and Values       S  Setup ALL Flags and Values
        <  Save All Flags/Values        >  Restore All Flags/Values
        Q  Quit and Do Not Update       X  Exit and Optionally Update

        0  Setup Named Directory Data     5  Set Disk Allowed Flag
        1  Setup External Path Data       6  Set User Allowed Flag
        2  Setup Multiple Command Line    7  Setup Priv User Data
        3  Set Max Disk                   8  Set Current User/Disk Data
        4  Set Max User                   9  Set File DMA Address

        A  Set MCOPY Special Default Values

Setup Command (? for Menu)? >           << Restore params from
                                        << previous setting

Setup Command (? for Menu)? P           << Print
**** Default Flag/Value Settings ****
Enable External Paths: Yes  External Path Address: 0040 Hex
   Internal Path is -- A$: --> A 15:
Enable Multiple Command Line Buffer: Yes  Buffer Address: FF00 Hex
Maximum Disk: B   Maximum User Number:  15
Disk Specification Allowed: Yes   User Spec Allowed: Yes
Base of Privileged User Areas:  10   Password: chdir
Current User/Disk Indicator: $   DMA Address for Disk I/O: 0080 Hex
Address of Memory-Resident Named Directory Buffer: FD00 Hex
   Number of Named Dirs Allowed:  64   Named Dir File: NAMES   .DIR
Verify by Default: Yes
Inspect by Default: No
Quiet by Default: No
Multiple Run by Default: No
Default Destination Disk/User: C  0:


Setup Command (? for Menu)? X      << OK, so exit and update
Do you want to save changes (Y/N/other=Y)? N      << No save
Please Provide Name of File to Install       << New file
Name of File (<CR>=Abort)? wheel        << File Name
Ready to Set Default Values

File Being Installed: WHEEL   .COM
** GENINS Flag/Value Setup **
        Select Standard Flags and Values
                (* indicates unnecessary option) --

        P  Print Flags and Values       S  Setup ALL Flags and Values
        <  Save All Flags/Values        >  Restore All Flags/Values
        Q  Quit and Do Not Update       X  Exit and Optionally Update

        0* Setup Named Directory Data     5* Set Disk Allowed Flag
        1* Setup External Path Data       6* Set User Allowed Flag
        2* Setup Multiple Command Line    7  Setup Priv User Data
        3* Set Max Disk                   8* Set Current User/Disk Data
        4* Set Max User                   9* Set File DMA Address

        A  Set WHEEL Byte Address       << Note all the un-
                                   << necessary options and the
                                   << A option

Setup Command (? for Menu)? P
**** Default Flag/Value Settings ****
Base of Privileged User Areas:  10   Password: chdir
Address of Wheel Byte: 003B Hex

Setup Command (? for Menu)? X
Do you want to save changes (Y/N/other=Y)? 
Please Provide Name of Output File
Name of File (<CR>=WHEEL   .COM)? wheel2
Name of Output File is WHEEL2  .COM -- Verify (Y/N/other=Y)? 
Writing File WHEEL2  .COM to Disk --

Reading Block    10
Writing Block    10
Please Provide Name of File to Install
Name of File (<CR>=Abort)? 


B4>difæ  genins2.com,genins.coí          <¼ DIFÆ ió gooä tï
                                         << compare with
DIFF Versioî 1.6
Source File 1 -- B  4: GENINS2 .COM
Source File 2 -- B  4: GENINS  .COM
 Rel Offset   B  4: GENINS2 .COM     B  4: GENINS  .COM
 Hex    Dec       Hex  Dec Asc           Hex  Dec Asc
0006      6        01    1  .             00    0  .
0007      7        24   36  $             00    0  .
0008      8        01    1  .             00    0  .
0009      9        0F   15  .             00    0  .
001A     26        02    2  .             04    4  .
001B     27        0F   15  .             1F   31  .

B4>diff wheel2.com,wheel.com
DIFF  Version 1.6
Source File 1 -- B  4: WHEEL2  .COM
Source File 2 -- B  4: WHEEL   .COM
NO Differences Noted in Files
























               This Page Intentionally Left Blank







                           Appendix A

                    ZCPR2 Distribution Files

Disk 1 --

    1 File:  ZCPR2  .°1  -- Size:     0K -- CRC: 00 00
	Comment: 
    2 File: SYSIO   .ASM -- Size:    29K -- CRC: 91 11
	Comment: Sample Redirectable I/O Driver Package
    3 File: ZCPR2   .ASM -- Size:    56K -- CRC: 4F D1
	Comment: Source to ZCPR2
    4 File: ZCPRHDR .LIB -- Size:    15K -- CRC: E6 29
	Comment: Header/Configuration File for ZCPR2

Disk 2 --

    1 File:  ZCPR2  .°2  -- Size:     0K -- CRC: 00 00
	Comment: 
    2 File: DU2     .ASM -- Size:    72K -- CRC: 19 DA
	Comment: Disk Utility
    3 File: HELP2   .ASM -- Size:    33K -- CRC: 16 19
	Comment: Online Documentation System
    4 File: LRUNZ   .ASM -- Size:    26K -- CRC: B8 6F
	Comment: Library-Oriented Extended Command Processor
    5 File: SUB2    .ASM -- Size:    31K -- CRC: 57 FB
	Comment: Disk-Based Command File Processor/Ext Cmd Proc
    6 File: ZEX     .ASM -- Size:    45K -- CRC: 09 11
	Comment: Memory-Based Command File Processor/Ext Cmd Proc
    7 File: ZEX     .ZEX -- Size:     5K -- CRC: 53 28
	Comment: Command File Used to Assemble ZEX



Disk 3 --

    1 File:  ZCPR2  .°3  -- Size:     0K -- CRC: 00 00
	Comment: 
    2 File: CCPLOC  .MAC -- Size:     5K -- CRC: FA DA
	Comment: CCP/BDOS/BIOS Locator Program
    3 File: CD      .MAC -- Size:     9K -- CRC: F5 5D
	Comment: Change Directory (Log Into Named Directory) Util
    4 File: COMPARE .MAC -- Size:    13K -- CRC: 2F 8A
	Comment: File Compare Utility
    5 File: CRC     .MAC -- Size:    20K -- CRC: 4C 09
	Comment: CRC Utility
    6 File: DEVICE  .MAC -- Size:    13K -- CRC: 92 0A
	Comment: Redirectable I/O Driver Select/Display Utility
    7 File: DIFF    .MAC -- Size:    17K -- CRC: 74 C2
	Comment: File Difference Listing Utility
    8 File: ECHO    .MAC -- Size:     6K -- CRC: 99 64
	Comment: Command Line Echo Utility
    9 File: ERASE   .MAC -- Size:    15K -- CRC: 25 6B
	Comment: File Erase Utility
   10 File: GENINS  .MAC -- Size:    43K -- CRC: B2 18
	Comment: Utility Installation Program
   11 File: IOLOADER.MAC -- Size:     7K -- CRC: 4F 23
	Comment: Redirectable I/O Driver Package Loader
   12 File: LD      .MAC -- Size:    10K -- CRC: 6C D4
	Comment: Memory-Based Named Directory Loader
   13 File: LDIRZ   .MAC -- Size:    12K -- CRC: FF 1B
	Comment: Library Directory Utility
   14 File: MCHECK  .MAC -- Size:    14K -- CRC: B1 12
	Comment: Menu Syntax Check Utility
   15 File: MCOPY   .MAC -- Size:    37K -- CRC: BA 14
	Comment: Multiple File Copy with Named Directories Utility



Disk 4 --

    1 File:  ZCPR2  .°4  -- Size:     0K -- CRC: 00 00
	Comment: 
    2 File: MENU    .CPR -- Size:     1K -- CRC: 18 6F
	Comment: Sample MENU.CPR File
    3 File: MENU    .MAC -- Size:    24K -- CRC: 0D BE
	Comment: Menu Command Preprocessor
    4 File: MKDIR   .MAC -- Size:    21K -- CRC: BE 0A
	Comment: Named Directory Create/Edit Utility
    5 File: PATH    .MAC -- Size:    14K -- CRC: 9F 91
	Comment: Path Display/Set Utility
    6 File: PROTECT .MAC -- Size:    18K -- CRC: EB 24
	Comment: File Protect Utility
    7 File: PWD     .MAC -- Size:    12K -- CRC: 1A 64
	Comment: Named Directory Environment Print Utility
    8 File: RECORD  .MAC -- Size:     7K -- CRC: DB 87
	Comment: Disk-Oriented Redirectable I/O Control Utility
    9 File: RENAME  .MAC -- Size:    18K -- CRC: 68 15
	Comment: File Rename Utility
   10 File: SINSFORM.MAC -- Size:     3K -- CRC: 3B E7
	Comment: General Header for ZCPR2 Utilities
   11 File: STARTUP .MAC -- Size:    10K -- CRC: D6 3F
	Comment: Command Line Insertion Utility
   12 File: TEMPLATE.MAC -- Size:    11K -- CRC: C5 DA
	Comment: ZCPR2 Utility Template
   13 File: TINIT   .MAC -- Size:    13K -- CRC: 9F 1E
	Comment: Terminal Init Program for TVI 950 CRT (uses Paths)
   14 File: WHEEL   .MAC -- Size:     6K -- CRC: 32 B6
	Comment: Wheel Set/Reset Utility
   15 File: XDIR3   .MAC -- Size:    39K -- CRC: 8C D9
	Comment: Extended Directory Display Utility



Disk 5 --

    1 File:  ZCPR2  .°5  -- Size:     0K -- CRC: 00 00
    2 File: CCPLOC  .COM -- Size:     2K -- CRC: A0 7F
    3 File: CD      .COM -- Size:     4K -- CRC: CF FC
    4 File: COMPARE .COM -- Size:     6K -- CRC: 00 1D
    5 File: CONFIG  .COM -- Size:    20K -- CRC: 44 4F
    6 File: CRC     .COM -- Size:     8K -- CRC: BB 23
    7 File: DEVICE  .COM -- Size:     4K -- CRC: 76 53
    8 File: DIFF    .COM -- Size:     6K -- CRC: E3 AF
    9 File: DU2     .COM -- Size:    10K -- CRC: 30 22
   10 File: ECHO    .COM -- Size:     2K -- CRC: C1 E9
   11 File: ERASE   .COM -- Size:     8K -- CRC: 00 7B
   12 File: GENINS  .COM -- Size:    14K -- CRC: 97 4D
   13 File: HELP    .COM -- Size:     4K -- CRC: 34 47
   14 File: IOLOADER.COM -- Size:     4K -- CRC: D3 C7
   15 File: LD      .COM -- Size:     6K -- CRC: F2 FC
   16 File: LDIRZ   .COM -- Size:     6K -- CRC: 98 7F
   17 File: LRUNZ   .COM -- Size:     2K -- CRC: B2 4D
   18 File: MCHECK  .COM -- Size:     6K -- CRC: A1 1D
   19 File: MCOPY   .COM -- Size:    12K -- CRC: 5A 81
   20 File: MENU    .COM -- Size:     2K -- CRC: DB E8
   21 File: MKDIR   .COM -- Size:     8K -- CRC: 22 60
   22 File: PATH    .COM -- Size:     6K -- CRC: ED 05
   23 File: PROTECT .COM -- Size:     8K -- CRC: CB 21
   24 File: PWD     .COM -- Size:     6K -- CRC: B6 32
   25 File: RECORD  .COM -- Size:     2K -- CRC: 6E 42
   26 File: RENAME  .COM -- Size:     8K -- CRC: 5A 09
   27 File: STARTUP .COM -- Size:     4K -- CRC: 98 04
   28 File: SUB     .COM -- Size:     4K -- CRC: 46 9D
   29 File: TEMPLATE.MAC -- Size:    12K -- CRC: C5 DA
   30 File: TINIT   .COM -- Size:     6K -- CRC: 60 62
   31 File: WHEEL   .COM -- Size:     2K -- CRC: D5 A0
   32 File: XDIR    .COM -- Size:    12K -- CRC: 1B E1
   33 File: ZEX     .COM -- Size:     6K -- CRC: 08 3E


Disk 6 --

    1 File:  ZCPR2  .°6  -- Size:     0K -- CRC: 00 00
    2 File: CFILES  .HLP -- Size:    22K -- CRC: 10 97
    3 File: COMPARE .HLP -- Size:     7K -- CRC: B3 F0
    4 File: CPMTR   .HLP -- Size:    24K -- CRC: 63 7B
    5 File: DU2     .HLP -- Size:    35K -- CRC: 5F 7B
    6 File: HELP    .HLP -- Size:     1K -- CRC: 15 97
    7 File: HELP2   .HLP -- Size:    22K -- CRC: 2D E1
    8 File: IO      .HLP -- Size:    14K -- CRC: D5 CA
    9 File: LU      .HLP -- Size:    27K -- CRC: 48 F2
   10 File: MCOPY   .HLP -- Size:    11K -- CRC: 96 9E
   11 File: MENU    .HLP -- Size:    29K -- CRC: 1C 39



Disk 7 --

    1 File:  ZCPR2  .°7  -- Size:     0K -- CRC: 00 00
    2 File: NDIRS   .HLP -- Size:    35K -- CRC: F8 19
    3 File: XDIR3   .HLP -- Size:    22K -- CRC: 21 DA
    4 File: Z2ALT   .HLP -- Size:    22K -- CRC: 25 85
    5 File: Z2RES   .HLP -- Size:     7K -- CRC: FA D4
    6 File: ZCPR2   .HLP -- Size:     6K -- CRC: 73 08
























               This Page Intentionally Left Blank





