.he    ZCPR2 -- An Enhanced Z80-Based Replacement for the CP/M CCP
.fo Concepts Manual                                    Page #


                    Concepts Manual for ZCPR2

1.0  Introduction

     Thå   Z80-baseä  Commanä  Processoò  Replacemenô  Versioî  2“ 
(ZCPR2©  ió á replacemenô foò thå CP/Í Consolå Commanä  Processor“ 
(CCP©  whicè createó aî extremelù capablå anä  flexiblå  environ
ment¬  placinç á totallù ne÷ interfacå oî thå user'ó CP/Í system®  
Thå  primarù  purposå oæ ZCPR² ió tï improvå thå user'ó  product
ivitù bù givinç hií aî environmenô whicè ió mucè morå  responsivå 
tï  hió needó anä configurablå tï hió specifiã desireó thaî  CP/Í 
2.² whilå stilì remaininç CP/Í 2.² compatablå anä allowinç hií tï 
ruî  most¬  iæ  noô all¬  oæ hió CP/Í softwarå witè littlå oò  nï 
modification.

     Tï givå yoõ á firsô picturå oæ ZCPR2¬  let'ó takå á compara
tivå looë aô á runninç CP/Í systeí anä á runninç ZCPR² system.


-- Diagram 1 --

Address        CP/M System              ZCPR2 System

High Memory -> ---------------------    -------------------------
               | BIOS              |    | Modified BIOS         |
BDOS+0E00H  -> ---------------------    -------------------------
               | CP/M 2.2 BDOS     |    | CP/M 2.2 BDOS         |
CCP +0800H  -> --------------------- -- -------------------------
               | CP/M 2.2 CCP      | T  | ZCPR2                 |
CCP Base    -> --------------------- P  -------------------------
               | Scratch Area      | A* | Scratch Area          |
100H        -> --------------------- -- -------------------------
               | CP/M Buffers et al|    | ZCPR2 Buffers et al   |
  0H        -> ---------------------    -------------------------


*TPÁ ½ Transienô Prograí Area¬  whicè coveró thå Scratcè Areá anä 
the CCP or ZCPR2

              CP/M and ZCPR2-Based Executing Images


     Aó  thå readeò caî see¬  á ZCPR2-baseä systeí ió  structureä 
likå  á CP/M-baseä system®   Foò alì intentó anä purposes¬  ZCPR² 
lookó  likå CP/Í tï á prograí designeä tï ruî  undeò  CP/M®   Thå 
differencå ió mainlù iî thå waù ZCPR² lookó tï thå user.



1.1  Another Look at CP/M 2.2

     CP/Í  (É wilì refeò tï CP/Í 2.² aó CP/Í froí herå on© ió  aî 
Operatinç  System¬  whicè ió á computeò prograí whoså functioî ió 
tï managå thå resourceó oæ thå computer®  Alì computeró havå fouò 
basiã resourceó tï bå manageä bù thå operatinç system:

          o Memory
          o Processors and Processes (Process = running Program)
          o Devices
          o Information

     Iî thå waù oæ Memorù Management¬ CP/Í doeó verù little®  Thå 
basiã memorù structurå ió defineä aó iî thå previouó diagram¬ anä 
thaô ió thå extenô oæ thå memorù managemenô performeä bù CP/M.

     Likewise¬  iî thå waù oæ Procesó Management¬ CP/Í agaiî doeó 
verù  little®   Sincå  therå ió onlù onå processoò  involved¬  nï 
processoò  managemenô  ió donå aô all®   Witè  onlù  onå  procesó 
involveä  (typically)¬  CP/Í  simplù startó thå procesó anä  theî 
relinquisheó alì control®   Oncå thå procesó haó control¬  iô haó 
completå  controì oveò thå entirå microcomputer¬  anä  CP/Í  doeó 
nothinç tï stoğ iô froí doinç anythinç iô wisheó tï do.

     Thå beautù oæ CP/Í ió thå waù iô doeó devicå anä informatioî 
management®   Devicå  Management“ ió performeä bù thå Basiã Input-
Outpuô System“ (BIOS© oæ CP/M®   Thå BIOÓ provideó á standardized¬ 
hardware-independenô  interfacå tï thå deviceó oæ  thå  microcom
puteò  regardlesó oæ whaô thå actuaì deviceó are®   Theså deviceó 
arå interfaceä tï bù waù oæ á tablå oæ jumğ instructionó  locateä 
aô thå beginninç oæ thå BIOS¬  anä thå parameteró passeä tï theså 
routines¬  thå  parameteró  passeä froí theså routines¬  anä  thå 
functionó oæ theså routineó arå preciselù defined®   Thå softwarå 
anä programmeò dï noô neeä tï kno÷ HO× thå routineó perforí theiò 
functions» thå softwarå anä programmeò onlù neeä tï kno÷ whaô thå 
routineó dï anä ho÷ tï communicatå witè them®   Thió ió á procesó 
box¬ oò blacë box¬ concept:


-- Diagram 2 --               |
                              |  Input Parameters
                              |  are precisely known
                              |
                              V                The Process Box is
                    ---------------------      a "Black Box", and
       Process Box: | Function is       |  <-- it is not needed
                    ü Preciselù Knowî   ü      to know what is in
                    ---------------------      the box to use it
                              |
                              |  Output Parameters
     The Process Box          |  are precisely known
     Concept for CP/M         |
                              V
Š
     Foò example¬  thå fourtè entrù iî thå BIOÓ Jumğ Tablå ió thå 
Consolå  Inpuô Routine¬  anä iî ordeò foò á prograí tï  obtaiî  á 
characteò  froí  thå user'ó console¬  regardlesó oæ whaô typå  oæ 
devicå  thå consolå maù bå (sucè aó á CRÔ oò printinç  terminal)¬ 
alì  thå  softwarå  haó tï dï ió makå á subroutinå  calì  tï  thå 
routinå  startinç  aô BIOÓ « ¹ (eacè Jumğ Tablå  Entrù  ió  threå 
byteó long)¬ anä thå BIOÓ wilì returî thå nexô characteò froí thå 
consolå iî thå Á register®  Tï outpuô á characteò tï thå console¬ 
thå  softwarå neeä onlù placå thaô characteò intï thå Ã  registeò 
anä makå á calì tï thå subroutinå startinç aô BIOÓ « 12.

     Thå  BIOÓ  performó alì oæ thå devicå controì functionó  ne
cessarù foò CP/Í anä thå programó whicè ruî undeò CP/Í tï dï mosô 
oæ whaô theù neeä tï do®   Surprisingly¬ therå arå onlù seventeeî 
general-purposå functionó requireä tï providå thå hardwarå inter
faceó necessarù tï perforí alì characteò anä disë I/Ï undeò CP/M®  
Theså  functionó  arå reallù quitå simplå wheî yoõ comå  dowî  tï 
looë aô them®  Theù are:

          1) Initialization Functions
               ï Colä Booô Initializatioî (wheî thå systeí ió 
                  firsô turneä on)
               o Warm Boot Initialization (performed periodically
                  after the system is turned on)

          2) Character Input/Output Functions
               o Console Status (check for availability of a
                  character at the console)
               o Console Input
               o Console Output
               o List Status (check to see if List Device is
                  ready to output the next character)
               o List (Printer) Output
               o Punch Output
               o Reader Input

          3) Disk Input/Output Functions
               o Home Disk (move head to Track 0)
               o Select Disk (which disk to use)
               o Select Track
               o Select Sector
               o Select Memory Address to Read Into or Write
                  From
               o Read Block (at selected Track and Sector) into
                  Memory (at selected Memory Address)
               o Write Block (to selected Track and Sector) from
                  Memory (at selected Memory Address)
               o Logical-to-Physical Sector Translation (for
                  efficiency of disk use)



     Thå BIOS¬  then¬ createó á Virtuaì Machine¬ whicè ió á hypo
theticaì  computeò  thaô alì CP/Í softwarå runó  under®   Iî  alì 
cases¬  thankó tï thå BIOÓ design¬  thió hypotheticaì computeò ió 
thå  samå computeò regardlesó oæ whaô thå actuaì hardwarå oæ  thå 
microcomputeò is®   Iô makeó nï differencå iæ µ 1/4¢ floppù diskó 
aô  100Ë bytes/disk¬  8¢ floppù diskó aô 600Ë bytes/disk¬  oò  8¢ 
Winchesteò  harä diskó aô 5Í bytes/disë arå used®   Thå  softwarå 
talkó  tï  alì oæ theså deviceó iî thå samå way¬  anä thió  makeó 
sucè  softwarå transportablå AÔ THÅ BINARÙ LEVEÌ betweeî anù  twï 
microcomputeró runninç CP/M®

     Thå  fourtè  anä  finaì functioî oæ aî operatinç  systeí  ió 
Informatioî Management¬  whicè boiló dowî tï thå controì oæ fileó 
oî  disk®   CP/Í shineó herå too¬  extendinç thå virtuaì  machinå 
concepô aó applieä tï hardwarå bù thå BIOÓ tï fileó oî disk®  Thå 
Basiã  Disë Operatinç System“ (BDOS© portioî oæ CP/Í createó  thió 
file-orienteä virtuaì machine®  Tï illustratå mù point¬ somå (anä 
bù nï meanó ALL© oæ thå functionó provideä bù thå BDOÓ are:

          o Reset Disk System
          o Select Disk
          o Create File (actually, create a directory entry for
             a file)
          o Open File (make a file ready for reading or writing)
          o Close File (terminate the read/write process)
          o Delete File
          o Rename File
          o Set Memory Address to Read Into or Write From
          o Read Next Block from File
          o Write Next Block into File

     Notå  thå  similaritù betweeî theså BDOÓ functionó  anä  thå 
BIOÓ  disë  functions®   Theså BDOÓ functionó arå accesseä  iî  á 
differenô  waù  froí  thå BIOS¬  buô thå procesó boø  concepô  ió 
maintained®   Alì thaô onå needó tï kno÷ ió whaô thå inpuô  para
meteró are¬ whaô thå outpuô parameteró are¬ anä whaô thå functioî 
performeä  is®   Oncå more¬  transportabilitù ió realizeä AÔ  THÅ 
BINARÙ LEVEL¬ buô thió timå iô ió witè respecô tï thå informatioî 
manipulateä  bù thå computer®   Thió virtuaì machinå greatlù sup
portó thå exchangå anä salå oæ software®  Iæ effect¬ thå creatioî 
oæ  CP/Í  spawneä aî industrù baseä oî  somethinç  noô  conceiveä 
beforeº   thå exchangå oæ softwarå regardless¬  bù anä large¬  oæ 
thå  actuaì computeò hardwarå involveä anä independenô oæ anù onå 
computeò  hardwarå manufacturer®   Alì oæ thió ió causeä  bù  thå 
CP/Í Virtuaì Machine.


1.2  Where ZCPR2 Fits In

     Let'ó revie÷ Diagraí 1¬  whicè compareó CP/Í 2.² tï á ZCPR2-
baseä system:


-- Diagram 1 --

Address        CP/M System              ZCPR2 System

High Memory -> ---------------------    -------------------------
               | BIOS              |    | Modified BIOS         |
BDOS+0E00H  -> ---------------------    -------------------------
               | CP/M 2.2 BDOS     |    | CP/M 2.2 BDOS         |
CCP +0800H  -> --------------------- -- -------------------------
               | CP/M 2.2 CCP      | T  | ZCPR2                 |
CCP Base    -> --------------------- P  -------------------------
               | Scratch Area      | A* | Scratch Area          |
100H        -> --------------------- -- -------------------------
               | CP/M Buffers et al|    | ZCPR2 Buffers et al   |
  0H        -> ---------------------    -------------------------


*TPÁ ½ Transienô Prograí Area¬  whicè coveró thå Scratcè Areá anä 
the CCP or ZCPR2

              CP/M and ZCPR2-Based Executing Images


     Aó thå readeò caî see¬  thå Virtuaì Machinå oæ CP/Í ió  lefô 
more-or-lesó  intacô iî thå ZCPR² environment®   Thå BDOÓ ió lefô 
unchanged¬  anä  thå BIOÓ ió modifieä (buô thió ió onlù iî  minoò 
wayó  anä  thå interfaceó arå  lefô  unaffected)®   Hence¬  undeò 
ZCPR2¬ wå arå dealinç witè thå samå Virtuaì Machine¬ anä thå samå 
softwarå  whicè  raî undeò CP/Í 2.² wilì alsï  ruî  undeò  ZCPR2¬ 
excepô  iî  thoså  fe÷ caseó wherå thå softwarå useä thå  CCĞ  tï 
perforí  somå  functionó  (iî whicè caseó ZCPR² maù  oò  maù  noô 
work).

     ZCPR²  provideó á verù versatilå interfacå betweeî thå  useò 
anä  hió  microcomputeò witè itó software®   Thå  windo÷  througè 
whicè  thå  useò seeó hió systeí ió changeä radicallù  bù  ZCPR2¬ 
and¬  iî mù opinion¬ thå microcomputeò systeí becomeó á mucè morå 
usefuì  anä versatilå tooì anä thå user'ó productivitù  increaseó 
significantlù  becauså  oæ ZCPR2®   Thió documenô ió intendeä  tï 
coveò thå basiã conceptó oæ ZCPR2¬ emphasizinç ho÷ ZCPR² enhanceó 
thå user'ó capabilitieó anä improveó hió productivity®  Thå read
eò  ió inviteä tï reaä thå Rationalå Manuaì iæ hå wantó  tï  dis
coveò whù ZCPR± anä ZCPR² werå createä iî thå firsô placå anä whù 
thå  thingó  abouô tï bå describeä werå donå thå waù  theù  were®  
Thió Conceptó Manuaì jusô covers¬  bù anä large¬ whaô ZCPR² does¬ 
anä onlù occasionallù explainó whù iô waó donå thió way.


2.0  ZCPR2 Overview

     ZCPR² provideó aî interactivå interfacå tï thå user'ó micro
computeò  whicè  ió  significantlù extendeä oveò  thaô  interfacå 
provideä  bù thå CP/Í 2.² CCP®   Thå useò ió inviteä tï refeò  tï 
thå  Rationalå Manuaì foò á detaileä comparisoî betweeî thå  CP/Í 
2.²  CCĞ anä ZCPR2®   Á workinç knowledgå oæ CP/Í 2.² ió  assumeä 
foò  thå followinç discussion®   Also¬  thå followinç  discussioî 
pertainó tï ZCPR² systemó whicè arå configureä iî thå recommendeä 
waù (seå thå Installatioî Manual)®  Therå arå oveò 4,000,00° wayó 
(conceivably©  thaô onå maù configurå á ZCPR² systeí foò hió  owî 
uses¬ and¬ aó á generaì rule¬ thå featureó describeä belo÷ maù bå 
turneä oî oò ofæ aó thå systeí manageò desires.

2.1  Directories under ZCPR2

     Iî general¬  ZCPR² ió ablå tï addresó uğ tï sixteeî  logicaì 
disks¬ eacè containinç uğ tï thirty-twï directories®  Á directory“ 
undeò ZCPR² ió á useò areá oî á disk¬ anä iô ió identifieä bù thå 
combinatioî  oæ  thå disë letteò anä thå numbeò oæ thå useò  areá 
(likå A1° oò B7© oò bù á mnemoniã namå (likå JEFÆ oò ROOT)®   Thå 
directorù ió á logicaì concept¬  anä physically¬  iî keepinç witè 
CP/Í 2.² compatability¬ therå ió onlù onå physicaì filå directorù 
(whicè  keepó tracë oæ alì thå files© oî eacè  logicaì  disk®   Á 
useò  numbeò ió á parô oæ eacè entrù iî thå filå  directory¬  anä 
thió  useò numbeò associateó thå filå witè thå useò areá oî  disë 
(directory© whicè thaô filå resideó in.

     Thå disk/useò waù oæ identifyinç á directorù (calleä thå  DU“ 
forí froí herå on© ió standarä tï thå ZCPR2-residenô commandó anä 
thå ZCPR2-specifiã utilities®   Iî alì cases¬ theså commandó wilì 
permiô uså oæ thå DUº  forí whereveò thå simpleò Dº forí waó useä 
undeò CP/Í 2.2¬ anä eitheò thå Ä oò thå Õ parô oæ thå DUº forí ió 
optional.

     Hence¬  thå useò caî "sit¢ iî anù directorù oî anù disë  anä 
readilù  worë  witè  fileó iî anù otheò directorù  oî  anù  disk®  
Likewise¬  wherå  thå  useò useä tï bå ablå tï prefiø á COÍ  filå 
witè á disë letteò iî ordeò tï temporarilù loç intï anotheò  disë 
anä  extracô thaô filå froí it¬  thå ZCPR² useò caî prefiø á  COÍ 
filå witè á DÕ form.

     Finally¬  thå thirä logicaì extensioî oæ thió DÕ forí ió  tï 
allo÷  thå useò tï emploù iô tï "loç into¢ á directory¬  likå  hå 
useä  thå Dº  forí beforå tï simplù changå diskó anä thå "USEÒ n¢ 
commanä tï changå useò areas.

     Thå  ZCPR²  prompô changeó sï thaô iô wilì alwayó  telì  thå 
useò  whaô directorù hå ió loggeä into®   ZCPR² caî bå configureä 
tï displaù "d>¢ oò "d0>¢ wheî thå useò ió loggeä intï useò areá ° 
oæ á particulaò disë (notå "A>¢ anä "C>¢ iî thå example)®   Aó  á 
sidå  note¬  becauså oæ thå flexibilitù oæ thå DÕ form¬  thå USEÒ 
commanä  ió nï longeò necessarù anä ió noô availablå undeò  ZCPR² 
unlesó á programmeò implementó iô aó á transient.Š
     ZCPR² ió á replacemenô foò thå CP/Í 2.² CCP¬  buô iô ió onlù 
á parô oæ thå ZCPR² SYSTEM®   Thå ZCPR² System“ ió á collectioî oæ 
programó  consistinç  oæ ZCPR² itselæ anä á serieó  oæ  utilitieó 
designeä  tï  augmenô thå capabilitieó oæ ZCPR2®   Alì  oæ  theså 
utilitieó  responä  tï thå ZCPR² DÕ form¬  jusô likå  thå  ZCPR2-
residenô commands¬  whilå thå conventionaì CP/Í utilitieó dï not®  

     Theså  ZCPR² utilities¬  however¬  supporô á seconä forí  oæ 
directorù  specificatioî  aó welì aó thå DÕ form®   Thió  ió  thå 
nameä directorù specification¬  calleä thå DIÒ forí froí no÷  on®  
Thå DIÒ forí ió á logicaì associatioî betweeî á mnemoniã namå anä 
á disk/useò area®  Foò example¬ thå directorù namå oæ ROOÔ maù bå 
assigneä  tï meaî A0¬  JEFÆ tï meaî C4¬  BACKUĞ tï meaî C0¬  etc®  
Alì oæ thå ZCPR² utilitieó (bù anä large© recognizå thió forí  aó 
well.

     Somå oæ thå ne÷ ZCPR² utilitieó arå designeä tï specificallù 
deaì  witè nameä directories®   Theså utilitieó anä  theiò  basiã 
functionó are:

          o CD -- Log Into a Named Directory (like the simple DU:
                    command, but far more is done)

          o PWD -- Print Working Directory; this command simply
                    lists the names of the directories accessible
                    to the user

          ï MKDIÒ -- Makå á Directory» creatå á ne÷ nameä
                      directory or modify an existing one

          o LD -- Load a Named Directory into the Named
                   Directory Buffer in Memory

     Witè thå nameä directorù environmenô fullù implemented¬  thå 
user'ó  ZCPR² systeí caî bå configureä iî á numbeò  oæ  differenô 
wayó  beyonä eveî thå 4,000,000« basiã wayó ZCPR² caî bå  config
ured®   Iî particular¬  á directorù treå structurå caî bå seô up¬ 
similaò  tï  thå UNIØ concept¬  oò á directorù mesè structurå  ió 
alsï  possible®   Foò example¬  thå followinç environmenô ió  onå 
sucè workinç environmenô whicè caî bå createä undeò ZCPR2:


-- Diagram 2 --

       ----------------- ROOT -----------------------
       |                /    \                      |
     ROBERT         JEFF      LINDA               BOSS
       |           / |  \    / | | \              | ||
    HARDWORK      JA CB JC  LA CB LC LD      WATCHJ |WATCHL
                 /          |        |           WATCHR
                GAMES      SCHOOL   GAMES
 

             Sample ZCPR2 Named Directory Structure


     Notes:
          ROOT is the base of the system
          CB and GAMES under JEFF are the same directories as
               CB and GAMES under LINDA
          Depending on how the Named Directory files were set
               up, it would be possible to readily move from
               any directory to any other directory, or the
               user could be forced to move along a tree
               (i.e., you could go to JEFF directly from SCHOOL
               or be forced to follow the path SCHOOL -> LA ->
               LINDA -> ROOT -> JEFF in order to get there --
               it is up to the person who sets up the Named
               Directory system)


     Thå  topiã  oæ Nameä Directorieó ió quitå  involved¬  anä  á 
wholå sectioî ió devoteä tï thió later®  Thió ió jusô aî overvie÷ 
tï wheô youò appetite¬  sï I'lì movå oî tï thå otheò featureó no÷ 
anä gï intï morå detaiì later.


2.2  ZCPR2 Resident Commands

     Likå thå CP/Í 2.² CCP¬  ZCPR² containó somå commandó  withiî 
itself®   Iô containó alì oæ thå CCĞ commandó (excepô USER¬ whicè 
isn'ô needeä anymore© anä á fe÷ more¬  buô alì oæ thå ZCPR² resi
denô  commandó  arå differenô witè logicaì extensionó tï thå  CCĞ 
commands®   Wå havå alreadù seeî thå DÕ form¬  whicè caî bå  useä 
witè  anù  ZCPR² residenô command®   Notå thaô thå DÕ forí  ió  á 
logicaì extensioî oæ thå Dº prefiø undeò CP/Í 2.2.

     Again¬  witè  alì oæ thå possiblå ZCPR² configurations¬  thå 
followinç discussioî applieó tï thå recommendeä configuration.

     Thå  followinç ió á comparisoî oæ thå variouó residenô  com
manä formó undeò thå CP/Í 2.² CCĞ anä ZCPR2:



              Comparison of ZCPR2 and CP/M 2.2 CCP


Functioî                      ZCPR² Commanä       CCĞ Command
Display $DIR File Names       DIR DU:afn          DIR D:afn
Display $SYS File Names       DIR DU:afn S        No Equivalent
Display All File Names        DIR DU:afn A        No Equivalent

Erase Specified Files         ERA DU:afn          ERA D:afn
Erase with Verify             ERA DU:afn V        No Equivalent

Renamå Filå                   REÎ DU:ufn=ufn²     REÎ DU:ufn=ufn2
Rename Over Existing File     REN DU:ufn=ufn2     No Equivalent

Print File on Console         TYPE DU:ufn P       TYPE D:ufn
  Without Paging
Print File on Console         TYPE DU:ufn         No Equivalent
  With Paging
Print File on Printer         LIST DU:ufn         No Equivalent

Save Memory into File         SAVE n DU:ufn       SAVE n D:ufn
Save Memory into File         SAVE n DU:ufn       No Equivalent
  With Overwrite Warning
Save Memory into File         SAVE nH DU:ufn      No Equivalent
  and Specify Size in Hex
Save Memory into File         SAVE n DU:ufn S     No Equivalent
  and Specify Number of        or
  Blocks                      SAVE nH DU:ufn S

Load File Anywhere Into       GET adr DU:ufn      No Equivalent
  Memory

Reexecute Last Transient      GO params           No Equivalent
  Without Reloading It

Call Subroutine Anywhere in   JUMP adr            No Equivalent
  Memory

Change Disk                   D:                  D:
Change User                   U:                  USER n
Change Disk and User at       DU:                 No Equivalent
  Same Time


2.3  ZCPR2 Standard Transient Commands

     Alì  oæ thå CP/M-supplieä transienô commandó wilì worë  witè 
ZCPR2¬ anä ZCPR² supplieó severaì additionaì ZCPR2-specifiã tran
sients¬ aó indicateä iî thå followinç tables:


            Standard CP/M 2.2 Transients under ZCPR2

Program   Function                           Functional Changes
ASM       Intel 8080 Assembler               No Change
DDT       Debugger                           No Change
DUMP      File Dump                          No Change
ED        Character-Oriented Text Editor     No Change
LOAD      HEX-to-COM File Converter          No Change
MOVCPÍ    Reconfigurå CP/Í foò Differenô     Wilì Onlù Affecô
            Memory Size                        BDOS -- ZCPR2
                                               Musô Bå
                                               Reassembled
PIP       File and Peripheral Transfer       No Change
STAT      Statistics display, etc            No Change
SUBMIT    Batch Command Processor            No Change
SYSGEN    Get/Put System Image on Disk       No Change


                    Standard ZCPR2 Transients

Program   Function
CD        Log Into Named Directory with Extended Preprocessing
COMPARE   Utility to Compare Two Files
CRC       Cyclic Redundancy Check Utility
DIFF      Utility to List File Differences
DU2       Disk Utility, based on DU
ECHO      Utility to Echo Its Command Line
ERASE     File Erase Utility
FINDBAD   Bad Block Scanner, based on FINDBD
GENINS    Utility to Install Itself and Other Utilities
HELP      Online Documentation System
LD        Load Named Directory Buffer
LU/LRUNZ  Command Library Utility and Extended Command Processor
MCHECK    Menu File Syntax Checker
MCOPY     File Copy Utility which can replace PIP in many cases
MENU      Extended Command PreProcessor designed to create menus
MKDIR     Create Named Directory File
PATH      Define/Display ZCPR2 Paths
PROTECT   Utility to Set File Attributes
PWD       Print Current Named Directory Environment
RENAME    File Rename Utility
STARTUP   Initial Command Line Generator
SUB2      Extended SUBMIT Indirect Command File Facility
XDIR      Directory Display and Scan Utility
ZEX       Memory-Based Indirect Command File Facility and Monitor

               Extended I/O Configuration Programs

Program   Function
CONFIG    TVI-950 CRT Configurator Program
DEVICE    Mnemonic-based I/O Redirection Utility
IOLOADER  Extended I/O System Loader
TINIT     TVI-950 CRT Programmer


     Alì  oæ thå ZCPR2-specifiã commandó arå describeä iî  detaiì 
iî thå User'ó Guide¬ aó welì aó thå ZCPR2-residenô commands.


2.4  Multiple Command Lines

     Onå majoò featurå oæ ZCPR² whicè É wilì mentioî herå brieflù 
ió thå Multiplå Commanä Line®   Unlikå CP/Í 2.2¬ ZCPR² wilì allo÷ 
yoõ tï specifù á sequencå oæ commandó tï bå executeä oî onå line®  
Undeò thå recommendeä configuration¬ eacè commanä ió separateä bù 
á semicolon®  Foò example:

          A>B:;DIR A7:*.TXT;DIR C22:*.COM A;C7:;ERA *.COM;DIR

ió á valiä commanä linå tï ZCPR2®  Witè thå Multiplå Commanä Linå 
featurå  enabled¬  noô onlù caî thå useò issuå morå thaî onå com
manä  oî  á line¬  buô programó caî uså thió  facilitù  tï  issuå 
commandó aó well¬ therebù chaininç tï eacè otheò viá ZCPR2.


2.5  Paths

     Command processing under CP/M 2.2 is really quite simple:
          1) Inpuô anä Parså Commanä Linå froí Useò oò File
          2) Determinå iæ iô ió á CCP-residenô commanä anä ruî iô 
             iæ so
          3) Determinå iæ therå ió á COÍ filå iî thå currenô disë 
             anä useò areá anä loaä iô anä ruî iô iæ so
          4) Print error message if 2 and 3 fail

     Command processing under ZCPR2, however, is quite different:
          1) Input and Parse Command Line from User or File
          2) Determinå  iæ iô ió á ZCPR2-residenô commanä anä ruî 
             iô iæ so
          3) Searcè alonç thå commanä searcè path¬  logginç  intï 
             thå diskó anä useò areaó indicateä iî thå patè untiì 
             eitheò  thå  bottoí  oæ thå patè ió reacheä  oò  thå 
             desireä COÍ filå ió found» ruî prograí iæ found
          4) Invokå  aî Extendeä Commanä Processor¬  passinç  thå 
             Commanä Linå tï it
          5) Print error message if 2, 3, and 4 fail


     Aó thå readeò caî see¬  thå concepô oæ á patè ió fundamentaì 
tï  ZCPR2®   Iî  thå ZCPR² vernacular¬  á Path“ ió á  sequencå  oæ 
directorieó  tï bå searcheä foò á file®   Thå specificatioî oæ  á 
patè  ió  aó  á sequencå oæ DÕ formó whicè arå  extendeä  bù  thå 
introductioî  oæ thå "$¢ characteò tï indicatå á currenô disë  oò 
currenô useò area®  Exampleó oæ pathó are:

          1) $¤  $° A¤ A° -- Patè Froí Currenô Disë  anä  Currenô 
             Useò  tï Currenô Disë anä Useò ° tï Disë Á anä  Cur
             renô  Useò  tï Disë Á anä Useò ° (Currenô  Disë  anä 
             Useò  ió  thå  disë anä useò areá thaô thå  useò  ió 
             loggeä into)

          2) $¤ A° A2² A1´ B2² C1² C° B° $° A¤ -- É thinë yoõ caî 
             follo÷ thió path»  thió ió tï illustratå thaô á patè 
             lengtè ió indefinitå (usuallù uğ tï 1¶  directories¬ 
             whicè  ió quitå reasonable© anä caî extenä intï useò 
             areaó beyonä 15¬ whicè can'ô bå loggeä into

     Wheî ZCPR² searcheó foò á file¬ iô followó sucè á path®  Twï 
extremelù flexiblå featureó abouô thå ZCPR² desigî are:

          1) thå commanä searcè patè maù bå redefineä dynamicallù 
             bù thå user
          2) severaì ZCPR² transientó uså pathó also¬  anä  theså 
             pathó maù bå thå samå patè useä bù commanä searcè oò 
             theù maù bå uniquå tï eacè transient


2.6  Overview and Putting the Basic Concepts Together

     As a practical example, let's consider the following case:

          1) I am logged into B1
          2) É  aí workinç oî M8° assembleò languagå programó  iî 
             B1¬  anä alì oæ mù M8° COÍ fileó (M80.COM¬  L80.COM© 
             arå iî A1¬  aó welì aó á commanä filå tï dï assemblù 
             undeò  M8°  whicè ió writteî foò processinç  bù  ZEØ 
             (filå ió M80.ZEX)
          3) Alì oæ mù generaì utilities¬ sucè aó XDIÒ anä ERASE¬ 
             arå iî A0
          4) My path is $$ $0 A$ A0

     Studù thå followinç terminaì session®   Commentó arå denoteä 
ouô tï thå sidå witè "<--"¬  anä thió sessioî haó beeî editeä foò 
clarity and to remove extraneous details.


B1>xdir a:     <-- Directory of all files on A1 (working base)

XDIR III, Version 1.3    Vertical Listing by File Type and Name
 Disk: A  User:   1, File Attributes:  Non-System

Filename.Typ Size K   Filename.Typ Size K   Filename.Typ Size K
-------- --- ------   -------- --- ------   -------- --- ------
ASM     .CFG      4   SYSLIB2 .HLP      4   WM      .HLP      4    
ASM2    .COM      8   SYSLIB3 .HLP      8   SYSLIB  .REL     16    
L80     .COM     12   SYSLIB4 .HLP      8   ASM2    .SUB      4    
L80OLD  .COM     12   SYSLIB5 .HLP      8   M80     .SUB      4    
LIB     .COM      8   SYSLIB6 .HLP      4   M80-2   .SUB      4    
LOAD    .COM      4   SYSLIB7 .HLP      8   MAC     .SUB      4    
M80     .COM     20   SYSLIB8 .HLP      8   RELS    .UTL      4    
M80OLD  .COM     20   SYSLIB9 .HLP      8   ASM2    .ZEX      4    
MAC     .COM     12   SYSLIBA .HLP      8   M80     .ZEX      4    
FNAMES  .DIR      4   SYSLIBB .HLP      8   M80-2   .ZEX      4    
SYSLIB  .HLP     16   SYSLIBC .HLP     12   MAC     .ZEX      4    
SYSLIB1 .HLP     16
   34 Files Occupying   276K,   241 Files on Disk and  2148K Free

B1>xdir a0:*.com aa      <-- dir of all COM files on A0, the root

XDIR III, Version 1.3    Vertical Listing by File Type and Name
 Disk: A  User:   0, File Attributes:  Non-System System

Filename.Typ Size K   Filename.Typ Size K   Filename.Typ Size K
-------- --- ------   -------- --- ------   -------- --- ------
BAD     .COM     28   DISPLAY .COM      4   LRUNZ   .COM      4   
BANNER  .COM      4   DUTIL   .COM     12   LU      .COM     20   
BOOTHD  .COM      4   ECHO    .COM      4   MBASIC  .COM     24   
CALC    .COM      4   ED      .COM      8   MCHECK  .COM      8   
CALENDAR.COM     16   ERASE   .COM      8   MCOPY   .COM     12   
CCPLOC  .COM      4   FINDBAD .COM      4   MEMTEST .COM      4   
CD      .COM      4   FORMAT2 .COM      4   MENU    .COM      4   
CHDIR   .COM     16   FORMATHD.COM      8   NAMEDISK.COM      4   
COMPARE .COM      8   GENINS  .COM     12   PATH    .COM     12   
CONFIG  .COM     20   GETSYS  .COM     12   PIP     .COM      8   
CRC     .COM      8   HDSYSGEN.COM      4   PRINT   .COM      8   
DASM    .COM     12   HELP    .COM      4   PROTECT .COM      8   
DDT     .COM      8   INUSE   .COM      4   PWD     .COM      8   
DEVICE  .COM     12   IOLOADER.COM      4   REGEN   .COM      4   
DIFF    .COM      8   LD      .COM      8   RENAME  .COM      8   
Screen Break -- Type any character to continue 

XDIR III, Version 1.3    Vertical Listing by File Type and Name
 Disk: A  User:   0, File Attributes:  Non-System System

Filename.Typ Size K   Filename.Typ Size K   Filename.Typ Size K
-------- --- ------   -------- --- ------   -------- --- ------
SCRAMBLE.COM      4   TERM    .COM     24   WM      .COM     12   
SD      .COM      4   TIME    .COM      8   XDIR    .COM     12   
SGEN    .COM      4   TINIT   .COM      8   ZDT     .COM      8   
SQ      .COM     16   TYPESQ  .COM     12   ZEX     .COM      8   
STARTUP .COM      8   UNLOAD  .COM      4   ZRUN    .COM      4   
STAT    .COM      8   USQ     .COM     12   ZSID    .COM     12   
SUB     .COM      4
   64 Files Occupying   564K,   241 Files on Disk and  2148K Free

     <-- Noteº  Mù Patè ió $¤ $° A¤ A0¬ or¬ specifically¬ B1¬ B0¬ 
          A1, A0

B1>ed demo.mac      <-- Use ED to create simple program
                    <-- For this to run, ZCPR2 searched B1, B0,
                    <-- A1, and A0 for ED.COM, finding it on A0
                    <-- and ED placed DEMO.MAC on B1
NEW FILE
     : *i
    1:          ext     padc    ;print A as decimal chars
    2:          ext     print   ;print string at return adr
    3:  
    4:          mvi     b,10    ;set loop counter
    5:          mvi     c,0     ;set display value
    6:  loop:
    7:          inr     c       ;add 1
    8:          call    print
    9:          db      0dh,0ah,'This is line ',0
   10:          mov     a,c     ;get line number
   11:          call    padc    ;print as decimal
   12:          dcr     b       ;count down
   13:          jnz     loop
   14:          ret             ;return to OS
   15:  
   16:          end
   17:  
     : *e

B1>dir    <-- Display Local Files
DEMO    .BAK  |  DEMO    .MAC
B1>dir a:*.zex      <-- Display ZEX Command Files on A1
M80     .ZEX  |  ASM2    .ZEX  |  M80-2   .ZEX  |  MAC     .ZEX


B1>type a:m80.zex   <-- Look at my M80 Command File
;  M80.SUB -- MACRO-80 Assembler and Linker
M80 =$1
;  Please Type $^C if Error(s) Exist - ^?
ERA $1.BAK
ERA $1.COM
L80 /P:100,$1,A:SYSLIB/S,$1/N,/U,/E
ERA $1.REL
;  Assembly Complete

B1>time;zex m80 demo;time     <-- Run Command File with Timing
                              <-- Data; Note Multiple Commands
TIME  Version 1.1    2:03:26 AM on Sunday December 19, 1982
                              <-- TIME was found on A0
ZEX, Version 1.1              <-- ZEX was found on A0, but then
(ZEX Active)                  <-- ZEX searched the path and
                              <-- found M80.ZEX on A1 and
                              <-- processed it
B1>;  M80.SUB -- MACRO-80 Assembler and Linker
B1>M80 =DEMO

No Fatal error(s)

(ZEX Active)
B1>;  Please Type ^C if Error(s) Exist - 

B1>ERA DEMO.BAK
DEMO    .BAK
B1>ERA DEMO.COM
No File
B1>L80 /P:100,DEMO,A:SYSLIB/S,DEMO/N,/U,/E

Link-80  3.44  09-Dec-81  Copyright (c) 1981 Microsoft
Data    0100    0210    <  272>

35838 Bytes Free

Data    0100    0210    <  272>

35838 Bytes Free
[0000   0210        2]

(ZEX Active)
B1>ERA DEMO.REL
DEMO    .REL
B1>;  Assembly Complete
B1>TIME
TIME  Version 1.1    2:04:25 AM on Sunday December 19, 1982
B1>
(ZEX Completed)

By Your Command >demo    <-- Now I run my program

This is line   1
This is line   2
This is line   3
This is line   4
This is line   5
This is line   6
This is line   7
This is line   8
This is line   9
This is line  10
B1>


3.0  ZCPR2 Directories and Files

     Aó  mentioneä  earlier¬  á directory¬  iî thå vernaculaò  oæ 
ZCPR2¬  ió  á logicaì areá oî á disë whicè ió designateä bù á  DÕ 
form®   Á disë maù havå uğ tï 3² directories¬  numbereä ° tï  31¬ 
but¬  iî  ordeò tï maintaiî CP/Í 2.² compatability¬  thå useò maù 
loç intï onlù 1¶ oæ theí (° tï 15)®  Thå otheò 1¶ directorieó (1¶ 
tï 31© maù bå useä tï onlù storå files®  Seå thå Rationalå manuaì 
foò aî explanatioî aó tï whù É diä noô chooså tï changå thió  anä 
allo÷ thå useò tï loç intï alì 3² directories.

     Wheî á useò ió "loggeä into¢ á directory¬ hió environmenô ió 
configureä (undeò ZCPR² anä thå BDOS© sï thaô wheneveò hå createó 
á ne÷ filå (assuminç hå doesn'ô specifù á directory)¬  iô wilì bå 
placeä  iî  thå directorù hå ió currentlù loggeä into®   Sucè  aî 
environmenô allowó thå useò tï keeğ thå fileó hå ió interesteä iî 
aô  thå  particulaò timå iî á directorù separatå froí  thå  otheò 
fileó  oî thå disk®   Iî thió way¬  thå useò neeä noô  alwayó  bå 
workinç arounä alì thå otheò fileó oî hió disk.

     Eacè filå iî á directorù haó twï basiã attributeó associateä 
witè itº   itó SYSTEÍ attributå anä itó READ/ONLÙ attribute®   Iæ 
thå  SYSTEÍ attributå ió Seô (i.e.¬  iô ió declareä tï bå á  $SYÓ 
file)¬  theî  iô becomeó hiddeî froí normaì viewinç bù thå  user®  
Thå DIÒ command¬  foò instance¬  wilì noô displaù iô unlesó thå Ó 
(SYSTEM© oò Á (ALL© optionó arå specified®   Iæ thå SYSTEÍ attri
butå ió Cleaò (i.e.¬  iô ió declareä tï be á $DIÒ file)¬  theî iô 
ió  normallù alwayó displayeä tï thå useò withouô hií  specifyinç 
anù optionó tï thå commands.

     Thå  READ/ONLÙ  attributå declareó thå filå tï bå  protecteä 
froí beinç writteî oveò oò deleteä iæ thió attributå ió Set®  Yoõ 
maù onlù reaä froí sucè á filå iæ thió attributå ió Set®  Severaì 
oæ thå ZCPR² utilities¬  specificallù ERASE¬  havå optionó tï  gï 
aheaä  anä perforí theiò functionó oî Read/Onlù fileó iî spitå oæ 
theiò attributå settings.

     Thå PROTECÔ utilitù ió useä tï seô thå SYSTEÍ anä  READ/ONLÙ 
attributeó  oæ  files¬   aó  welì  aó  severaì  others®   Wå  arå 
maintaininç fulì CP/Í 2.² compatabilitù here¬ anä uğ tï eighô TAÇ 
bits and an ARCHIVE bit may be set also.

     É havå discusseä thå DÕ forí tï somå extenô earlieò anä wilì 
noô  gï  intï aî extendeä discussioî oæ iô here®   Iô  ió  reallù 
ratheò straight-forward®   Eacè directorù ió indicateä bù á  disë 
anä  useò area¬  sï thå DÕ forí giveó exactlù thió specification®  
The ZCPR2-resident commands support this form extensively:

          A>DIR C7:
          A>ERA B22:MYFILE.TXT V
          A>TYPE A31:TEMP.TXT
          A>REN C12:FILE.TXT=FILE1.TXT
          A>LIST A31:TEMP.TXT
          A>DIR B4: AŠ
     Iî addition¬ yoõ maù uså thå DÕ forí tï loç intï á differenô 
disë  anä staù iî thå samå useò area¬  á differenô useò areá  anä 
staù  oî thå samå disk¬  oò á differenô useò areá oî á  differenô 
disk:

          A>B7:
          B7>12:
          B12>A:
          A12>B15:
          B15>B0:
          B>A:
          A>

     Iô  shoulä  alsï bå noteä thaô mosô  oæ  thå  ZCPR2-supplieä 
utilities have been programmed to recognize the DU form as well:

          A>XDIR B7:
          A>ERASE B4:*.TXT,C2:*.*
          A>CRC 4:*.*,5:*.*
          A>PROTECT B:*.* RS

     Iî  additioî  tï  thå DÕ form¬  mosô oæ  thå  ZCPR2-supplieä 
utilitieó  caî  deaì witè á directorù specificatioî  iî  whicè  á 
mnemoniã namå haó beeî defineä foò á directory®  Sucè á directorù 
forí  ió  calleä thå DIÒ forí oò thå Nameä Directory“ forí iî  thå 
ZCPR²  vernacular®   Nameä  directorieó arå noô  knowî  bù  ZCPR² 
itselæ  buô onlù bù ZCPR² utilitieó iî thå ZCPR²  System®   Therå 
arå  fouò  utilitieó  specificallù designeä tï  deaì  witè  nameä 
directories:

          MKDIR -- Create and Edit Named Directories

          LD    -- Load a Named Directory File into a Named
                   Directory Memory Buffer

          CD    -- Change Directory into a Named Directory
                   (like the DU: command, but more extensive)

          PWD   -- Print Working Directory

     Nameä  Directorieó  arå defineä iî á filå calleä  NAMES.DIR®  
Wheî  á utility¬  sucè aó XDIR¬  ió giveî á commanä  involvinç  á 
Nameä  Directory¬  iô performó á searcè alonç thå commanä  searcè 
patè foò á filå nameä NAMES.DIR®   Aó sooî aó onå ió found¬ iô ió 
loadeä  anä scanneä foò á match®   Iæ á matchinç entrù ió  found¬ 
thå  associateä  informatioî ió extracteä (DÕ informatioî ió  no÷ 
available)¬  anä  thå utilitù workó witè thå DÕ informatioî  froí 
theî on.


     Thå NAMES.DIÒ filå ió structureä aó á filå containinç 6´ 11-
bytå records¬ eacè recorä containinç thå followinç information:

          Byte 0:  Disk Letter (A-P)
          Byte 1:  User Number
          Bytes 2-10:  Directory Name (up to 8 chars terminated
                       by a binary zero)

     Thå emptù entrù ió onå whoså Bytå ² ió á binarù ° (nï name)®  
Emptù  entrieó  maù bå intersperseä witè  non-emptù  entries¬  sï 
don'ô  assumå thaô thå enä oæ thå directorù ió reacheä  wheî  thå 
firsô emptù entrù ió found.

     Thå  storù giveî abovå foò whaô happenó ió noô exactlù  truå 
iî alì ZCPR² systems®  Iî thå interesô oæ speeä anä efficiency¬ á 
Nameä  Directorù Buffeò maù bå defineä tï thå utilitieó employinç 
thå  capabilitieó oæ dealinç witè Nameä Directories®   Wheî  thió 
buffeò  facilitù ió enabled¬  thå utilitù performó thå  followinç 
operationó wheî á Directorù Namå ió giveî tï it:

  o Checë  tï  seå iæ iô ió á DÕ forí (disë  letteò  iî  thå 
    rangå  oæ  Á tï d¬  wherå ä ió defineä tï  thå  utility¬ 
    followeä bù á useò numbeò iî thå rangå oæ ° tï u¬  wherå 
    õ ió alsï defineä tï thå utility)®  Iæ thió ió thå case¬ 
    assumå thå forí tï bå DÕ anä gï witè it.

  o Iæ wå arå noô dealinç witè á DÕ form¬ assumå iô ió á DIÒ 
    form®   Iî thió case¬ scaî thå memory-baseä Nameä Direc
    torù Buffeò foò á match®  Iæ onå ió found¬ gï witè it.

  o Iæ  therå  ió nï memory-baseä Nameä Directorù Buffeò  oò 
    therå waó nï matcè iî saiä buffer¬ theî searcè alonç thå 
    commanä searcè patè foò thå NAMES.DIÒ file®   Iæ  found¬ 
    loaä  iô anä scaî iô foò thå indicateä name®   Iæ onå ió 
    found¬ gï witè it.

  o Iæ thå NAMES.DIÒ filå ió noô founä oò iæ iô ió founä anä 
    therå  ió nï matcè amonç itó entries¬  issuå  aî  appro
    priatå erroò messagå anä abort.

     Thå  LÄ  commanä ió useä tï Loaä á Directorù filå  intï  thå 
Nameä Directorù buffer®   Iô ió iî thió waù thaô thå contentó  oæ 
thå Nameä Directorù buffeò arå defined®   MKDIÒ ió useä tï creatå 
á  filå defininç á grouğ oæ nameä directories¬  anä LÄ ió useä tï 
loaä  thió filå intï memory®   Thå onlù operatinç systeí  supporô 
requireä foò thió featurå ió foò thå BIOÓ tï initializå thå Nameä 
Directorù Buffeò oî Colä Boot®   Thå BIOÓ doeó thió bù storinç aî 
entrù  counô  aó thå firsô bytå oæ thå buffeò (thió  entrù  counô 
telló LÄ ho÷ manù entrieó maù bå storeä iî thå buffer)¬  anä theî 
fouò  zeroeó aó thå nexô fouò byteó oæ thió  buffer®   Thå  firsô 
zerï  indicateó thaô therå arå nï entrieó presenô iî thå  buffer¬ 
anä  thå  nexô  threå zeroeó definå aî emptù entrù aó  thå  firsô 
entry®    Thå  Nameä  Directorù  Buffeò  ió  structureä  slightlù 
differently than the NAMES.DIR file:Š
        Header Bytes --
          Byte 0:  Number of Entries Allowed in the Named
                   Directories Buffer
          Byte 1:  Number of Entries Currently Stored in the
                   Named Directories Buffer

        Entry Bytes --
          Byte 0:  Disk Number (0 to 15, Disk A = 0)
          Byte 1:  User Number (0 to 31)
          Bytes 2-9:  Directory Name (8 bytes, Byte 2=0 if none)

     Thió  internaì  structuraì informatioî ió giveî  mainlù  foò 
youò reference¬  anä yoõ dï noô neeä tï kno÷ thió detaiì iî ordeò 
tï makå uså oæ thå system®   Essentially¬ oncå thå systeí anä itó 
utilitieó  arå properlù installed¬  thå procedurå foò  usinç  thå 
Named Directory facilities is:

          (1© uså LÄ tï loaä thå Nameä Directorù Buffer
          (2© uså MKDIÒ tï creatå Nameä Directorù Files
          (3) use the utilities and Named Directories at will

     Twï  morå commands¬  besideó MKDIÒ anä LD¬  arå availablå tï 
helğ thå useò deaì witè nameä directorieó specifically®  Theù arå 
PWÄ (Prinô Workinç Directory© anä CÄ (Changå Directory).

     Thå  PWÄ commanä ió useä tï prinô ouô thå nameó oæ thå  dir
ectorieó baseä oî hió commanä searcè path®   Iô wilì firsô  prinô 
ouô thå contentó oæ thå Nameä Directorù Buffeò iæ onå exists¬ anä 
iô  wilì theî prinô ouô thå contentó oæ thå firsô NAMES.DIÒ  filå 
iô encounteró alonç thå user'ó commanä searcè path.

     CÄ ió useä tï loç intï á Nameä Directory¬  iî lieõ oæ thå DÕ 
form®  Whaô CÄ buyó thå useò ió twï things:

          (1© Iî á securå environment¬ thå DÕ forí maù bå disabl
eä anä onlù CÄ madå availablå tï thå user®   Thå useò MUSÔ uså CÄ 
tï loç intï á differenô directory¬  and¬  eacè timå CÄ ió run¬ iô 
checkó tï seå iæ thå directorù thå useò ió tryinç tï loç intï  ió 
á "Systeí Directory¢ anä askó thå useò foò á passworä iæ iô is.

          (2© Wheî CÄ logó á useò intï á directory¬  iô lookó foò 
á filå nameä ST.COM®   Iæ iô findó one¬ iô chainó tï it®  SÔ ió á 
versioî oæ thå STARTUĞ commanä whicè ió configureä tï perforí onå 
oò  morå  initiaì  commandó oncå á directorù ió  entereä  bù  CD®  
Theså  commandó can¬  amonç otheò things¬  completelù reconfigurå 
thå user'ó environment¬  givinç hií á totallù differenô  environ
menô  froí thå onå hå jusô left®   Candidateó foò commandó tï  bå 
executeä bù CÄ include:

               o IOLOADER -- load a new I/O system
               o MENU -- enter a menu system
               o PATH -- define a new command search path
               o ZEX  -- run a command file
Š
     Securå  environmentó wilì bå discusseä iî theiò owî  sectioî 
later¬  buô onå additionaì featurå tï mentioî herå ió thaô PWÄ ió 
awarå oæ Systeí Directories¬  and¬ wheneveò iô runs¬ iô checkó tï 
seå  iæ  iô ió runninç froí á Systeí Directory®   Iæ  iô  is¬  iô 
displayó  alì knowî directorieó tï thå user®   Iæ iô ió  not¬  iô 
displayó onlù thå non-Systeí directorieó tï thå user.

     Á Systeí Directory“ iî thå ZCPR² vernaculaò ió onå whoså useò 
numbeò ió abovå 1° (defaulô recommendeä value)®  Anù sucè direct
orù  ió  declareä  tï bå á Systeí Directory¬  anä á  passworä  ió 
requireä  tï enteò iô wheî thå CÄ commanä ió used®   Aó witè  anù 
Nameä  Directory¬  Systeí Directorieó arå noô knowî tï ZCPR²  it
self¬ sï iæ thå DÕ forí oæ ZCPR² ió enabled¬ iô wilì ignorå theså 
restrictionó  anä  movå thå useò righô intï  á  Systeí  Directorù 
withouô qualms.

     É  thinë  iô ió timå foò anotheò terminaì sessioî tï  illus
tratå thå pointó covereä sï far®  Hence¬ pleaså studù thå follow
ing terminal session:

B1>;
B1>;  When my ZCPR2 system cold boots, it always runs the command
B1>;  STARTUP -- notice what STARTUP does:
B1>startup s
STARTUP, Version 1.1
STARTUP Setup Command (?=Help)? ?
  Setup Mode Commands are --
        A -- Define Address of Multiple Command Buffer
        C -- Define STARTUP Multiple Command Line
        D -- Display STARTUP Values
        S -- Define Size of Multiple Command Buffer
        X -- Exit and Optionally Rewrite STARTUP
STARTUP Setup Command (?=Help)? D

**** STARTUP Settings ****
        Multiple Command Buffer Address -- FF00H
        Size of Multiple Command Buffer -- 200 Bytes
        Multiple Command Line --
        --->ioloader;ld ld;tinit;echo welcome to zcpr ii
**** STARTUP Settings ****

STARTUP Setup Command (?=Help)? X
        Do you wish to update STARTUP (Y/N/<CR>=Y)? N
B1>;
B1>;  As the reader can see, it uses the ZCPR2 Multiple Command
B1>;  Line Buffer facility to store an initial command line which
B1>;  runs the following commands:
B1>;    IOLOADER -- loads I/O system
B1>;    LD LD    -- loads the named directory LD.DIR into the
B1>;                    memory-based Named Directory Buffer
B1>;    TINIT    -- programs my TVI 950 CRT terminal (function
B1>;                    keys, status line, etc)
B1>;    ECHO     -- prints the message "WELCOME ..." on my CRT
B1>;ŠB1>;
B1>;  Before proceeding, let's look at my command search path
B1>;
B1>path
PATH Version 2.2
Current Symbolic Path --
        $$: --> $0: --> A$: --> A0:
Current Absolute Path --
        B1: --> B0: --> A1: --> A0:
Current Named Path --
        ASM: --> DEV-ROOT: --> R-ASM: --> ROOT:
B1>
B1>;
B1>;  This is the path along which CD, PWD, LD, and many other
B1>;  utilities search for the NAMES.DIR file.  As I am
B1>;  currently set up, I have only one NAMES.DIR file, and
B1>;  it is located at A0.
B1>;
B1>
B1>;
B1>;  Now let's see what directories are available to us:
B1>;
B1>pwd
PWD, Version 1.0

** Directory Display **

        ** Named Directory Memory-Based Definitions **
 12 Directory Entries Total (  2 Directories Hidden) --
A --
   0: ROOT    
B --
   0: BROOT      1: ASM        2: BDSC       3: PAS     
   5: BASIC      7: WS         8: CAT        9: DBASE   
C --
   0: BACKUP  

Strike Any Key to Continue - 

        ** Named Directory  Disk-Based  Definitions **
 20 Directory Entries Total (  2 Directories Hidden) --
A --
   0: ROOT       1: R-ASM      2: R-BDSC     3: R-PAS   
   5: R-BASIC    7: R-WS       8: R-CAT      9: R-DBASE 
B --
   0: DEV-ROOT   1: ASM        2: BDSC       3: PAS     
   4: SCRATCH    5: BASIC      7: WS         8: CAT     
   9: DBASE   
C --
   0: BACKUP  

** Current Directory **
        B 1: ASM     

B1>;
B1>;  As the reader can see, I have several more directories
B1>;  defined in NAMES.DIR than in the memory buffer.  I have
B1>;  chosen to define only my more frequently used directories
B1>;  in the memory buffer.
B1>;  Also note that two directories are hidden in each case.
B1>;  These are System Directories.
B1>;
B1>;  Let's move around a little via CD to show you how it works:
B1>;
B1>cd root
CD, Version 2.1
A>;
A>;  Since Root was found in memory, CD ran slightly faster
A>;  than if it had to do a NAMES.DIR search:
A>;
A>cd r-asm:
CD, Version 2.2
A1>cd ws:
CD, Version 2.2
B7>cd zcpr
CD, Version 2.2
Access Password? 
** Access Granted **
A11>;
A11>;  Note that in this last example, I moved into a System
A11>;  Directory which was hidden in the previous PWD display.
A11>;  Now it is not:
A11>;
A11>pwd
PWD, Version 1.0

** Directory Display **

        ** Named Directory Memory-Based Definitions **
 12 Directory Entries Total (  0 Directories Hidden) --
A --
   0: ROOT      10: SYS       11: ZCPR    
B --
   0: BROOT      1: ASM        2: BDSC       3: PAS     
   5: BASIC      7: WS         8: CAT        9: DBASE   
C --
   0: BACKUP  

Strike Any Key to Continue - 


        ** Named Directory  Disk-Based  Definitions **
 20 Directory Entries Total (  0 Directories Hidden) --
A --
   0: ROOT       1: R-ASM      2: R-BDSC     3: R-PAS   
   5: R-BASIC    7: R-WS       8: R-CAT      9: R-DBASE 
  10: SYS       11: ZCPR    
B --
   0: DEV-ROOT   1: ASM        2: BDSC       3: PAS     
   4: SCRATCH    5: BASIC      7: WS         8: CAT     
   9: DBASE   
C --
   0: BACKUP  

** Current Directory **
        A11: ZCPR    
A11>cd root:
CD, Version 2.2
A>;
A>;  End of Demo
A>;


     Treeó arå implementeä relativelù easilù iî thió environment®  
Sincå  thå  NAMES.DIÒ whicè ió useä tï definå thå environmenô  ió 
thå  firsô NAMES.DIÒ encountereä alonç thå commanä  searcè  path¬ 
theî  thió  NAMES.DIÒ becomes¬  effectively¬  thå rooô oæ  á  ne÷ 
subtree®   Commonly-knowî nodeó caî bå storeä iî thå memory-baseä 
Nameä  Directorù Buffer¬  anä theså wilì alwayó bå scanneä first®  
Iæ  thió  scaî  fails¬  thå currenô  root¬  whicè  ió  thå  firsô 
NAMES.DIÒ filå founä alonç thå commanä searcè path¬  wilì providå 
thå directorù name¬ iæ any.

     Wholå  ne÷  workinç  environmentó oî thå samå  disë  caî  bå 
createä  ratheò  easilù undeò thå ZCPR²  environment¬  especiallù 
wheî  CÄ  ió useä tï movå arounä betweeî  directories®   Thió  ió 
primarilù becauså CÄ alwayó lookó foò thå ST.COÍ filå iî thå  ne÷ 
directorù  iô  ió movinç intï anä chainó tï iô iæ onå  ió  there®  
The new ST.COM, then, can set up the new environment.


     Foò  example¬  imaginå  thaô yoõ wanô tï seô uğ á wholå  ne÷ 
workinç environmenô calleä ROBERT®   ROBERÔ wilì bå thå baså oæ á 
subtreå  whicè wilì havå thå directorieó oæ  GAMES¬  SCHOOL¬  anä 
OTHER under it:

                         ROOT
                        /    \
                    others    ROBERT
                             /  |   \
                       SCHOOL GAMES  OTHER

     Let'ó arbitrarilù assigî ROBERT=C7¬ SCHOOL=C8¬ GAMES=C9¬ anä 
OTHER=C10®   Iî  ordeò  tï  implemenô this¬  wå  woulä  creatå  á 
NAMES.DIÒ filå witè theså entrieó iî iô anä placå thió  NAMES.DIÒ 
iî ROBERÔ (C7)®  Hence¬ thió NAMES.DIÒ becomeó thå baså directorù 
foò  ouò subtree®   Thå Memory-Baseä Nameä Directorù wilì contaiî 
thå Globaì Nameó only¬ foò thió example¬ sï let'ó saù iô containó 
only one entry, and that entry is ROOT=A0.

     Wå havå no÷ defineä ouò directorieó thaô wå wanô tï bå  ablå 
tï  geô tï aó NAMES.DIÒ undeò ROBERT®   Wå no÷ wanô tï seô uğ thå 
SÔ internaì commanä linå whicè wilì bå executeä wheî wå loç  intï 
ROBERT.  The following command line is all you need:

          PATH $$ C7 A$ A0

and ST.COM can be created by running the "STARTUP S" command.

     Tï  illustratå thå flexibilitù oæ ZCPR² eveî  further¬  wheî 
Roberô  wantó tï loç intï hió GAMEÓ directory¬  hå ofteî wantó tï 
ruî thå samå gameó oveò anä over®   Tï keeğ lifå simplå foò  him¬ 
let'ó  seô  uğ anotheò ST.COÍ filå iî hió GAMEÓ  directorù  whicè 
runs MENU when this directory is logged into.

     Thå followinç terminaì sessioî illustrateó thió exampleº


B4>;
B4>;  First, I will set up the Named Directory Environments
B4>;  LD will load the Global Directory, LD.DIR
B4>;  NAMES.DIR will reside in ROBERT to define the subtree
B4>;
B4>mkdir
MKDIR, Version 1.0
MKDIR Command (? for Help)? ?
MKDIR Command Summary
        A -- Set Address of ZCPR2 External Path
        D -- Display Currently-Defined Directory Names
        F -- Set Name of Directory File
        I -- Initialize MKDIR
        N -- Create a New Directory Name
        Q -- Quit without Changing Program on Disk
        R -- Read in Directory File from Disk
        S -- Sort Directory by Disk and User Number
        W -- Write Directory File to Disk
        X -- Exit and Update Program on Disk
MKDIR Command (? for Help)? a
External Path Undefined
New Path Address (Hex)? 40.....

MKDIR Command (? for Help)? f
New Directory File? ld.dir......

MKDIR Command (? for Help)? n
System User Areas start at 10
        Disk Letter and User (RETURN=Done or A-P 0-31, like A10)? a0
        Directory Name (RETURN = Delete Old Name)? root....

        Disk Letter and User (RETURN=Done or A-P 0-31, like A10)? 

MKDIR Command (? for Help)? d
Directory File is ld.dir
External Path Address is 40 Hex
Defined Directory Names --
A -- 
  A 0: ROOT      
1 Directory Names Displayed
1 Directory Names Defined, Space Left for 63 More Names

Current Directory -- Not Defined by Name

MKDIR Command (? for Help)? w
Writing Directory File ld.dir to Disk ... Done
MKDIR Command (? for Help)? i   Verify Initialization (Y/N)? y
All Directory Names Cleared
MKDIR Command (? for Help)? f
New Directory File? names.dir...


MKDIR Command (? for Help)? n
System User Areas start at 10
        Disk Letter and User (RETURN=Done or A-P 0-31, like A10)? c7
        Directory Name (RETURN = Delete Old Name)? robert..

        Disk Letter and User (RETURN=Done or A-P 0-31, like A10)? c8
        Directory Name (RETURN = Delete Old Name)? school..

        Disk Letter and User (RETURN=Done or A-P 0-31, like A10)? c9
        Directory Name (RETURN = Delete Old Name)? games...

        Disk Letter and User (RETURN=Done or A-P 0-31, like A10)? c10
        Directory Name (RETURN = Delete Old Name)? other...

        Disk Letter and User (RETURN=Done or A-P 0-31, like A10)? 

MKDIR Command (? for Help)? d
Directory File is names.dir
External Path Address is 40 Hex
Defined Directory Names --
C -- 
  C 7: ROBERT      C 8: SCHOOL      C 9: GAMES       C10: OTHER     
4 Directory Names Displayed
4 Directory Names Defined, Space Left for 60 More Names

Current Directory -- Not Defined by Name

MKDIR Command (? for Help)? w
Writing Directory File names.dir to Disk ... Done
MKDIR Command (? for Help)? q   Verify Abort (Y/N)? y
B4>;
B4>;  We now have the Global and Subtree Directories Defined:
B4>;
B4>dir
LD      .DIR  |  NAMES   .DIR
B4>mcopy c7:=names.dir
MCOPY  Version 2.2
        Copy B  4: NAMES   .DIR to C  7:
No Original File NAMES   .DIR on Destination
!

    Copy Complete,  Verify Phase --

    Verify Complete
**** MCOPY Complete ****
            1 Files Copied
            0 Copy Errors
B4>;
B4>;  The Subtree Directory is now in its root at C7
B4>;


B4>ld ld
LD  Version 1.0
Load Complete
B4>;
B4>;  Global Directory is Now Loaded
B4>;
B4>cd robert
CD, Version 2.2
C7>;
C7>;  I will now define the new path to be set up when logged
C7>;  into ROBERT
C7>;
C7>startup s
STARTUP, Version 1.1
STARTUP Setup Command (?=Help)? C
        Current Multiple Command Buffer Contents is --
ioloader;ld ld;tinit;echo welcome to zcpr ii, version 2.0
        New Line? path $$ c7 a$ a0

**** STARTUP Settings ****
        Multiple Command Buffer Address -- FF00H
        Size of Multiple Command Buffer -- 200 Bytes
        Multiple Command Line --
        --->path $$ c7 a$ a0
**** STARTUP Settings ****

STARTUP Setup Command (?=Help)? X
        Do you wish to update STARTUP (Y/N/<CR>=Y)? Y
        STARTUP will write file to current disk/user
        STARTUP File is STARTUP .COM
        Enter New File Name or <CR> if OK: st.com
        STARTUP File is ST      .COM
        Enter New File Name or <CR> if OK: 
        Writing File ST      .COM to Disk ... Done
C7>dir
NAMES   .DIR  |  ST      .COM
C7>;
C7>;  We now have ST available to define the new environ
C7>;
C7>
C7>;
C7>;  I will set up the MENU File for the GAMES directory
C7>;
C7>cd games
CD, Version 2.2


C9>;
C9>;  I will create an ST.COM in GAMES to run MENU
C9>;
C9>startup s
STARTUP, Version 1.1
STARTUP Setup Command (?=Help)? C
        Current Multiple Command Buffer Contents is --
ioloader;ld ld;tinit;echo welcome to zcpr ii, version 2.0
        New Line? menu

**** STARTUP Settings ****
        Multiple Command Buffer Address -- FF00H
        Size of Multiple Command Buffer -- 200 Bytes
        Multiple Command Line --
        --->menu
**** STARTUP Settings ****

STARTUP Setup Command (?=Help)? X
        Do you wish to update STARTUP (Y/N/<CR>=Y)? Y
        STARTUP will write file to current disk/user
        STARTUP File is STARTUP .COM
        Enter New File Name or <CR> if OK: st.com
        STARTUP File is ST      .COM
        Enter New File Name or <CR> if OK: 
        Writing File ST      .COM to Disk ... Done
C9>;
C9>;  I'll set up a MENU.CPR file to
C9>;  illustrate what can be done
C9>;
C9>ed menu.cpr

NEW FILE
     : *i
    1:  -dx
    2:  #
    3:  This is a sample Menu -- I set the Global Menu
    4:  options to display menu and allow exit to ZCPR2
    5:  
    6:  Menu Commands --
    7:          X -- Display Directory (XDIR)
    8:          Z -- Run Any Command Line
    9:          Q -- Jump Out to ROBERT
   10:  #
   11:  x!xdir "Input Options -- 
   12:  z!"Input Command Line -- 
   13:  qcd robert
   14:  ##
   15:  
     : *e

C9>dir
ST      .COM  |  MENU    .BAK  |  MENU    .CPR
C9>era *.bak
MENU    .BAKŠC9>;
C9>;  I will now run MCHECK to perform a syntax check on the
C9>;  MENU.CPR file
C9>;
C9>mcheck menu
MCHECK  Version 1.0

 Line Comment/Error Message
 ---- ---------------------
    1 ** Global Options Detected **
    2 ** Menu Number   0
   14 ** End of Menu Check **
        No Errors Detected
C9>;
C9>;  We are now ready for a full demo --
C9>;  Let's play like we are Robert, and he has just come up
C9>;  (I will start at B4 since the NAMES.DIR defining ROBERT
C9>;  is there, but he would start at A0)
C9>;
C9>b4:
B4>dir
LD      .DIR  |  NAMES   .DIR
B4>;
B4>;  On powerup, STARTUP would run LD LD, among others
B4>;
B4>ld ld
LD  Version 1.0
Load Complete
B4>;
B4>;  Robert would now log into his directory
B4>;
B4>cd robert
CD, Version 2.2

PATH Version 2.2
Current Symbolic Path --
        $$: --> C7: --> A$: --> A0:
Current Absolute Path --
        C7: --> C7: --> A7: --> A0:
Current Named Path --
        ROBERT: --> ROBERT: --> Noname: --> Noname:
C7>dir
NAMES   .DIR  |  ST      .COM
C7>;
C7>;  We are now in ROBERT, and can access his world:
C7>;


C7>pwd
PWD, Version 1.0

** Directory Display **

        ** Named Directory Memory-Based Definitions **
  1 Directory Entries Total (  0 Directories Hidden) --
A --
   0: ROOT    

Strike Any Key to Continue - 

        ** Named Directory  Disk-Based  Definitions **
  4 Directory Entries Total (  1 Directories Hidden) --
C --
   7: ROBERT     8: SCHOOL     9: GAMES   

** Current Directory **
        C 7: ROBERT  
C7>;
C7>;  Like going to SCHOOL --
C7>;
C7>cd school
CD, Version 2.2
C8>dir
No File
C8>;
C8>;  Or going into OTHER (which is a System Directory)
C8>;
C8>cd other
CD, Version 2.2
Access Password? 
** Access Granted **
C10>dir
No File
C10>;
C10>;  Or playing games -- note that by CDing into GAMES, we
C10>;  automatically come up in a Menu Environment
C10>;
C10>cd games
CD, Version 2.2

MENU  Version 1.1

This is a sample Menu -- I set the Global Menu
options to display menu and allow exit to ZCPR2

Menu Commands --
        X -- Display Directory (XDIR)
        Z -- Run Any Command Line
        Q -- Jump Out to ROBERT
Command (<CR>=Menu Disp, ^C=CP/M) - X
Input Options -- *.dir...................................
ŠXDIR III, Version 1.3    Vertical Listing by File Type and Name
 Disk: C  User:   9, File Attributes:  Non-System
No files selected

MENU  Version 1.1 Strike Any Key - 

This is a sample Menu -- I set the Global Menu
options to display menu and allow exit to ZCPR2

Menu Commands --
        X -- Display Directory (XDIR)
        Z -- Run Any Command Line
        Q -- Jump Out to ROBERT
Command (<CR>=Menu Disp, ^C=CP/M) - Z
Input Command Line -- dir.....................................
ST      .COM  |  MENU    .CPR
MENU  Version 1.1 Strike Any Key - 

This is a sample Menu -- I set the Global Menu
options to display menu and allow exit to ZCPR2

Menu Commands --
        X -- Display Directory (XDIR)
        Z -- Run Any Command Line
        Q -- Jump Out to ROBERT
Command (<CR>=Menu Disp, ^C=CP/M) - Q
CD, Version 2.2

PATH Version 2.2
Current Symbolic Path --
        $$: --> C7: --> A$: --> A0:
Current Absolute Path --
        C7: --> C7: --> A7: --> A0:
Current Named Path --
        ROBERT: --> ROBERT: --> Noname: --> Noname:
MENU  Version 1.1

Menu Not Found
C7>;
C7>;  Note that MENU was still running, but it aborted gracefully
C7>;  under the new directory
C7>;
C7>
C7>;
C7>;  End of Demo
C7>;


4.0  ZCPR2 Commands

     ZCPR² will¬ generallù speaking¬ accepô anù conventionaì CP/Í 
commanä  anä iô ió ablå tï ruî virtuallù alì oæ thå existinç CP/Í 
softwarå  (witè  thå fe÷ minoò exceptionó aó  noteä  previously)®  
Thió sectioî oæ thå Conceptó Manuaì dealó witè thå ZCPR2-specifiã 
commands¬  i.e.¬  thå  ZCPR² Residenô Commandó anä thå  transienô 
programs released with ZCPR2.

4.1  ZCPR2 Resident Commands

     Likå thå CP/Í 2.² CCP¬  ZCPR² containó somå commandó  withiî 
itself®   Iô containó alì oæ thå CCĞ commandó (excepô USER¬ whicè 
isn'ô needeä anymore© anä á fe÷ more¬  buô alì oæ thå ZCPR² resi
denô  commandó  arå differenô witè logicaì extensionó tï thå  CCĞ 
commands®  Thå  followinç discussioî applieó tï  thå  recommendeä 
configuratioî oæ ZCPR2.

     Iî thå followinç discussion¬ "afn¢ referó tï thå CP/Í ambig
uouó  filå  namå forí (containinç "?¢ and/oò "*¢ characters©  anä 
"ufn¢  referó  tï thå CP/Í unambiguouó filå namå forí  (doeó  noô 
contaiî thå ambiguouó characters).

4.1.1  The DIR Command
     Thå DIÒ commanä ió useä tï displaù thå nameó oæ thå fileó iî 
the current directory.  It has three basic forms --

          Display $DIR File Names       DIR DU:afn
          Display $SYS File Names       DIR DU:afn S
          Display All File Names        DIR DU:afn A

4.1.2  The ERA Command
     Thå  ERÁ commanä ió useä tï eraså files®   Iô ió noô ablå tï 
eraså Read/Onlù files¬ buô iô caî eraså Systeí files®  Iô haó twï 
basic forms --

          Erase Specified Files         ERA DU:afn
          Erase with Verify             ERA DU:afn V

4.1.3  The REN Command
     Thå  REÎ commanä ió useä tï changå thå namå oæ onå  filå  tï 
another®   Again¬ iô caî noô changå thå namå oæ á Read/Onlù file®  
It has only one basic form --

          Renamå Filå                   REÎ DU:ufn1=ufn²

     Iæ ufn± alreadù exists¬ REÎ wilì asë thå useò iæ hå wantó tï 
Erase it (with the prompt "ERA ufn1?").


4.1.4  The TYPE and LIST Commands
     TYPÅ  anä LISÔ arå useä tï displaù fileó oî thå consolå  anä 
printer¬  resp®  TYPÅ pageó bù default¬ stoppinç afteò thå screeî 
is filled.  These two commands have three basic forms --

          Print File on Console         TYPE DU:ufn P
            Without Paging
          Print File on Console         TYPE DU:ufn
            With Paging
          Print File on Printer         LIST DU:ufn

4.1.5  The SAVE Command
     Thå  SAVÅ  commanä ió useä tï savå thå contentó oæ  thå  TPÁ 
ontï disë aó á file®   Iô acceptó twï argumentsº   á numbeò anä á 
filå  name®   Thå  filå  namå maù bå optionallù followeä  bù  thå 
letteò "S¢ tï indicatå thaô thå numbeò ió thå numbeò oæ  128-bytå 
Sectoró  (Blocks©  tï bå saved¬  and¬  iæ thió optioî  letteò  ió 
omitted¬ thå numbeò ió assumeä tï bå thå numbeò oæ 256-bytå Pageó 
to be saved.  The SAVE command has two basic forms --

          Save Memory into File         SAVE n DU:ufn
          Save Memory into File         SAVE n DU:ufn S
            and Specify Number of
            Blocks

     Iæ thå number¬  n¬ ió followeä bù thå suffiø "H"¬ aó iî "FH¢ 
oò  "2DH"¬  theî  î ió takeî tï bå á hexadecimaì  value®   Iæ  nï 
suffiø  ió given¬  î ió assumeä tï bå decimal®   Thió hexadecimaì 
optioî  eliminateó  thå  neeä  foò  conversioî  froí  thå  valueó 
supplied by debuggers, like DDT.

     Iæ thå indicateä filå alreadù exists¬ SAVÅ wilì asë thå useò 
if he wishes to erase it with the prompt "ERA ufn?".

4.1.6  The GET Command
     GEÔ  ió  useä  tï loaä á  filå  anywherå  intï  memory®   Iô 
requireó twï argumentsº   á numbeò (assumeä tï bå hexadecimal© oæ 
thå  256-bytå  pagå iî memorù aô whicè tï starô thå loaä anä  thå 
name of the file.

          Load File Into Memory         GET adr DU:ufn

4.1.7  The GO Command
     Thå GÏ commanä ió useä tï reexecutå thå lasô prograí  loadeä 
into the TPA without having to reload it.

          Reexecute Last Transient      GO params
            Without Reloading It


4.1.8  The JUMP Command
     JUMĞ ió useä tï brancè tï anywherå iî memory®  Iô takeó onlù 
onå  argument¬  whicè  ió  thå addresó aô whicè  tï  jump®   Thió 
addresó  caî  bå  tï  anù bytå iî memorù (iô  ió  á  fulì  16-biô 
address), and it is assumed to be a hexadecimal number.

          Call Subroutine Anywhere in   JUMP adr
            Memory

4.1.9  The DU Form for Changing Disk and User
     Thå  DÕ forí standinç alonå ió useä tï loç intï á  differenô 
directory.  There are three basic forms of this command --

          Change Disk                   D:
          Change User                   U:
          Change Disk and User at       DU:
            Same Time


4.2  ZCPR2 Standard Transient Commands

     Alì  oæ thå CP/M-supplieä transienô commandó wilì worë  witè 
ZCPR2¬ anä ZCPR² supplieó severaì additionaì ZCPR2-specifiã tran
sients¬ aó indicateä iî thå followinç tables:


            Standard CP/M 2.2 Transients under ZCPR2

Program   Function                           Functional Changes
ASM       Intel 8080 Assembler               No Change
DDT       Debugger                           No Change
DUMP      File Dump                          No Change
ED        Character-Oriented Text Editor     No Change
LOAD      HEX-to-COM File Converter          No Change
MOVCPÍ    Reconfigurå CP/Í foò Differenô     Wilì Onlù Affecô
            Memory Size                        BDOS -- ZCPR2
                                               Musô Bå
                                               Reassembled
PIP       File and Peripheral Transfer       No Change
STAT      Statistics display, etc            No Change
SUBMIT    Batch Command Processor            No Change
SYSGEN    Get/Put System Image on Disk       No Change



                    Standard ZCPR2 Transients

     Thå  standarä transientó oæ ZCPR² caî bå groupeä bù  subjecô 
areá  aó  organizeä  iî theiò Helğ Files®   Thió groupinç  ió  aó 
follows:

     1.  I/O                       8.  Command Files
          CONFIG, TINIT                 SUB2
          DEVICE                        ZEX
          IOLOADER
          RECORD                   9.  Named Directories
          STARTUP                       CD
          SYSIO                         STARTUP as ST
                                        LD
     2.  Directories                    MKDIR
          XDIR3                         PWD

     3.  Disk Utilities           10.  ZCPR2
          DU2                           DIR, XDIR3
                                        ERA, ERASE
     4.  Library                        REN, RENAME
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

     7.  File Copy                12.  Misc
          MCOPY                         CCPLOC
                                        ECHO


              ZCPR2 Transients Grouped by Function


     Thå  followinç ió á brieæ overvie÷ oæ theså transientó whicè 
concentrateó oî theiò functionó anä interactions®   Thió overvie÷ 
ió  organizeä accordinç tï thå functionaì groupingó giveî  above®  
Alì  oæ thå ZCPR2-specifiã anä ZCPR2-residenô commandó  arå  des
cribeä iî detaiì iî thå User'ó Guide.



     1.  Input/Output

          Thå  CONFIÇ anä TINIÔ programó arå useä tï prograí  thå 
TVÉ 95° CRÔ terminal®  Theså arå provided¬ oæ course¬ foò TVÉ 95° 
owners¬ buô theù alsï servå aó exampleó oæ ho÷ tï seô uğ terminaì 
programmeró foò otheò typeó oæ terminaló aó well®  CONFIÇ ió useä 
tï  creatå  configuratioî fileó foò variouó typeó  oæ  functions¬ 
sucè  aó  assemblù  languagå  softwarå  development¬  Ã  languagå 
softwarå development¬  worä processing¬  anä datá baså work®  Thå 
fileó  createä bù CONFIÇ contaiî datá whicè maù bå useä bù CONFIÇ 
itself or TINIT to program the terminal.

          Iî  programminç  thå terminal¬  thå attributeó  oæ  thå 
display¬  thå typå oæ cursor¬  thå contentó oæ thå functioî keys¬ 
anä  thå displaù oæ thå statuó linå arå somå oæ thå functionó  oæ 
thå  terminaì whicè maù bå programmed®   CONFIÇ serveó tï  creatå 
configuratioî  fileó (oæ typå CFG© mainly¬  anä TINIÔ ió useä  tï 
perforí thå programming®  TINIÔ readó thå indicateä configuratioî 
filå afteò followinç á patè iî lookinç foò iô anä theî sendó  thå 
appropriate command sequences to the terminal.

          SYSIO.ASÍ  ió  á samplå Redirectablå I/Ï Packagå  whicè 
runó  oî mù ZCPR² system®   Iô caî bå useä tï acô aó á modeì  foò 
thå  desigî  oæ  otheò sucè packageó  foò  variouó  purposeó  anä 
hardware configurations.  The reader is invited to study it.

          IOLOADEÒ  ió  useä tï loaä á Redirectablå  I/Ï  Packagå 
intï memorù anä calì itó initializatioî routine®   DEVICÅ ió useä 
tï displaù thå nameó anä meaningó oæ thå devicå driveró containeä 
iî  aî  I/Ï packagå anä tï selecô  á  physical-to-logicaì  devicå 
assignmenô aó desireä bù thå user®  RECORÄ ió useä tï controì thå 
disë  filå  outpuô  functionó foò recordinç  consolå  outpuô  anä 
printeò outpuô intï disë files.

          Finally¬   STARTUĞ  ió  includeä  iî  thió  listinç  tï 
emphasizå   thaô   iô  maù  bå  useä  tï  executå  IOLOADEÒ   foò 
initialization purposes.


     2.  Directories

          XDIR³  ió  thå extendeä directorù  displaù  utilitù  oæ 
ZCPR2®   Iô  supportó á widå varietù oæ functions¬  ranginç  froí 
directorù  displaù  tï  filå namå scanner®   Iô  useó  pathó  anä 
supports the named directory scheme under ZCPR2.


     3.  Disk Utilities

          DU²  ió  á  slightlù enhanceä versioî  oæ  DU¬  á  disë 
utilitù designeä bù Warä Christensen®  Thå reasonó É camå uğ witè 
DU²  werå  tï adä á couplå oæ additionaì  features¬  changå  DU'ó 
human-engineerinç interfacå tï matcè mù particulaò tastes¬ anä tï 
makå iô mesè morå cleanlù witè ZCPR2.Š
     4.  Library Utilities

          LÕ  (Librarù  Utility©  ió á prograí  writteî  bù  Garù 
Novosielské whicè placeó á numbeò oæ smalleò fileó intï onå largå 
filå  witè itó owî directory®   Amonç otheò things¬  thió prograí 
helpó tï conservå spacå oî disë bù eliminatinç á loô oæ thå wastå 
associateä witè thå unuseä spacå iî thå lasô grouğ oæ á filå  anä 
provideó á convenienô waù tï grouğ programó together.

          LDIRÚ ió á prograí É wrotå tï allo÷ thå useò tï examinå 
thå  contentó  oæ á librarù filå anä displaù thå contentó  iî  aî 
alphabeticaì  listinç witè filå sizå information®   Iô useó pathó 
tï  finä  thå librarù filå (oæ typå LBR© thaô iô wisheó  tï  deaì 
with.

          LRUNÚ  ió  á modificatioî oæ thå  Gary'ó  LRUÎ  prograí 
whicè performó thå samå functioî buô searcheó alonç pathó foò thå 
librarù file.


     5.  Menu

          MENÕ   anä  MCHECË  arå  thå  programó  useä  tï   deaì 
specificallù  witè á menõ commanä systeí undeò ZCPR2®   Menuó arå 
createä  iî thå forí oæ MENU.CPÒ files¬  witè onlù  onå  MENU.CPÒ 
filå   permitteä  peò  directorù  anä  witè  eacè  MENU.CPÒ  filå 
containinç  uğ tï 25µ menus®   Thå Menõ Systeí setó uğ á  commanä 
environmenô iî whicè thå commandó whicè thå useò maù executå  arå 
presenteä  tï  hií iî thå forí oæ á menu¬  anä thå useò  executeó 
them by selecting an option letter.

          MENÕ  executeó MENU.CPÒ files¬  anä MCHECË ió  useä  tï 
check the syntax of such files.


     6.  File Compare

          COMPARÅ  ió useä tï simplù comparå twï  files¬  tellinç 
thå  useò iæ theù arå thå samå oò not®   DIFÆ ió useä tï lisô ouô 
thå differenceó betweeî twï fileó oî á byte-for-bytå basis®   Thå 
relativå offsetó intï thå files¬  anä thå differenô bytå  values¬ 
expressed in decimal, hexadecimal, and ASCII, are presented.

          CRÃ  ió useä tï computå Cycliã Redundancù Checë  valueó 
foò  files®   Iæ twï fileó arå thå samå sizå anä theiò CRÃ valueó 
arå  thå  same¬  theî therå ió á verù gooä chancå thaô  theù  arå 
copieó oæ thå samå file®  CRÃ ió particularlù usefuì iî comparinç 
á filå thaô haó jusô beeî downloadeä bù á program¬  likå  XMODEM¬ 
to the file on the remote computer it was downloaded from.


     7.  File Copy

          MCOPÙ  ió á prograí whicè ió useä tï copù fileó iî  thå 
ZCPR²  environment®   Iô knowó abouô paths¬  caî deaì witè  nameä 
directories¬ caî deaì witè listó oæ fileó aó arguments¬ anä haó á 
numbeò  oæ  extendeä  featureó anä  facilities®   Somå  oæ  theså 
features include:

               . Disk Directory Display with Sizing Info
               . Can Copy to Any Directory on Any Disk
               . Supports Multiple Copy in which a group of
                    files can be copied to several disks by
                    simply loading one disk after another
                    without concerning the user with Warm
                    Booting the system
               . Permits Disks to be changed on it at will
                    once it is loaded and begins running
               . Supports an Inspect Mode
               . Optional Verify via CRC's and Rereading
                    the files from the destination
               . Can be run from the command line or from
                    an internal command processor
               . Built-In Help



     8.  Command Files

          SUB²  ió  á disk-baseä indirecô commanä  filå  facilitù 
likå SUBMIÔ whicè waó baseä oî Roî Fowler'ó SuperSUÂ anä supportó 
stilì  morå  features¬  includinç patè searcheó foò  thå  commanä 
files to execute.

          ZEØ  ió  á memory-baseä indirecô commanä filå  facilitù 
whicè ió baseä oî EØ anä supportó morå features¬  includinç  patè 
searches, immediate user input, and ZCPR2 interfacing.



     9.  Named Directories

          MKDIÒ ió useä tï creatå anä ediô nameä directorù files®  
Thå useò caî add¬ rename¬ anä deletå entrieó froí sucè á filå anä 
theî  savå  thå resultó oî disë aó thå samå filå oò  á  differenô 
file.

          LÄ  loadó á nameä directorù filå createä bù MKDIÒ  intï 
thå  memory-baseä nameä directorù buffer®   Iô alsï reformató thå 
informatioî iî thå filå tï bå compatablå witè thå formaô useä  iî 
the buffer.


          PWÄ  printó thå namå oæ thå currenô directorù thå  useò 
ió  loggeä  intï anä caî alsï prinô thå nameó oæ alì  directorieó 
whicè maù bå accesseä bù thå useò froí thå currenô directory®  Iô 
deriveó  itó  informatioî froí thå memory-baseä  nameä  directorù 
buffeò  anä  thå  firsô  NAMES.DIÒ  filå  encountereä  alonç  itó 
indicated path.

          CÄ  ió  useä  tï  Changå  Directorieó  oò  loç  intï  á 
directorù bù usinç itó name®   CÄ logó intï á nameä directorù  iî 
the following manner:

               1.  Scan first the memory-based named
                    directory buffer and then search
                    along the path and scan the first
                    disk-based NAMES.DIR file; this
                    is done to match the name given to
                    CD

               2.  Determine if the user number of the
                    desired directory is in the privil-
                    eged areas and, if so, ask for and
                    validate the access password

               3.  Once access right is determined, temp-
                    orarily log into the indicated directory
                    and look for ST.COM; if found, log in
                    permanently and execute it via the
                    Multiple Command Line Buffer facility;
                    if not found, simply log the user in


          STARTUĞ ió mentioneä herå because¬  wheî renameä tï ST¬ 
iô  provideó  aî  initiaì commanä sequencå tï  bå  executeä  upoî 
enterinç  á particulaò directory®   Thió commanä sequencå maù  bå 
used to perform functions like the following:

               1.  Load New I/O Drivers
               2.  Load a New Memory-Based Named Dir
               3.  Establish a New Command Search Path
               4.  Reprogram the User's Terminal
               5.  Run the MENU System


    10.  ZCPR2

          Therå arå twï setó oæ programs/commandó directlù  asso
ciateä witè ZCPR² itself®   Theså arå thå ZCPR² Residenô Commandó 
anä  theiò Alternatå Transienô Commands®   Thå Residenô  Commandó 
perforí basiã functionó ratheò quickly¬  anä thå Alternatå Trans
ienô Commandó elaboratå oî theså basiã functionó buô perforí theí 
morå  slowly¬  aó  á generaì rule®   Somå oæ thå commandó iî  thå 
Alternatå  clasó  havå nï correspondinç commanä iî  thå  Residenô 
class¬  buô  theù  arå  includeä becauså theù  perforí  á  ZCPR2-
supporting function.Š
          The Resident Commands include:

               DIR  - Directory Display
               ERA  - File Erase
               REN  - File Rename
               TYPE - Print File on Console
               LIST - Print File on Printer
               SAVE - Save Memory Image on Disk
               JUMP - Jump to Anywhere in Memory
               GO   - Reexecute Last Loaded Transient

          The Alternate Transient Commands include:

               XDIR3   - Directory Display
               ERASE   - File Erase
               RENAME  - File Rename
               PAGE    - Print File on Console
               PRINT   - Print File on Printer

               GENINS  - Utility Install Program
               PROTECT - File Attribute Set Program
               PATH    - External Path Display/Set Utility
               WHEEL   - Set/Reset Wheel Byte



    11.  Help

          Thå   HELĞ   prograí   supportó   thå   ZCPR²    onlinå 
documentatioî system®   Oveò 300Ë iî Helğ Fileó (oæ typå HLP© arå 
provideä witè thå ZCPR² System¬ anä alì commandó distributeä witè 
ZCPR2 are documented therein.


    12.  Miscellaneous

          CCPLOÃ ió useä tï displaù thå addresó oæ thå CCP¬ BDOS¬ 
and BIOS.  This program is used during installation.

          ECHÏ  ió useä tï echï thå commanä line®   Iô ió useä tï 
issuå  á simplå one-linå messagå tï thå useò wheî hiddeî  commanä 
lines, like those generated by STARTUP/ST, are executed.
 



5.0  Multiple Command Lines

     Thå  Multiplå  Commanä Linå Facilitù oæ ZCPR²  supportó  twï 
basic functions in the ZCPR2 environment:

          1) iô  allowó thå useò tï specifù á serieó oæ  commandó 
             separateä bù semicolonó (aó recommended)

          2) iô  allowó onå prograí tï easilù chaiî tï anotheò oò 
             á wholå serieó oæ programs

     Thå  firsô  applicatioî  oæ thió  facilitù  haó  beeî  showî 
several times.  It permits command lines like the following:

          ed prog.mac;m80 =prog;l80 prog/e;era *.bak;era *.rel

     Thå seconä applicatioî ió employeä extensivelù bù fouò ZCPR² 
utilitieó iî particulaò -- STARTUP¬  MENU¬ CD¬ anä ZEX®  STARTUP¬ 
CD¬ anä MENÕ havå beeî demonstrateä earlier.

     Thå Multiplå Commanä Linå Buffer¬ whicè ió useä tï storå thå 
Multiplå Commanä Line¬  ió locateä externaì tï ZCPR² iî somå safå 
areá  oæ  memorù  (sucè  aó uğ iî thå BIOS©  wherå  iô  won'ô  bå 
overwritteî  everù timå á Warí Booô occurs®   Iô ió structureä aó 
follows:

          Bytes 0 and 1:  Address of Next Character in Buffer
          Byte 2:  Size of Buffer
          Byte 3:  Dummy used by BDOS Readln Function 10
          Bytes 4-n:  Buffer Contents, terminated by a binary 0

     Wheî  thå Colä Booô routinå iî thå BIOÓ  executes¬  iô  musô 
initializå  thió  buffeò  foò subsequenô uså bù  ZCPR2®   Iô  maù 
optionallù  storå á commanä oò seô oæ commandó tï bå executeä  oî 
Colä Boot¬  amonç otheò things¬ buô iô MUSÔ perforí thå followinç 
functions as a minimum:

          1© seô thå Addresó oæ thå Nexô Chaò tï poinô tï Bytå 4
          2) set the buffer size
          3) initialize the buffer contents, making sure they are
             terminated by a binary 0


     Foò example¬ iæ thå buffeò startó aô 0FF00È anä ió 128 byteó 
long¬  thå  BIOÓ  Colä  Booô Routinå shoulä storå  thå  followinç 
values starting at 0FF00H:

          FF00: 04  ; Low-Order Address of First Char
          FF01: FF  ; High-Order Address of First Char
          FF02: 80  ; Size of Buffer (80H=128 Bytes)
          FF03: xx  ; Don't Care
          FF04: 0   ; Buffer MUST be terminated by a 0

     Iæ  á defaulô commanä linå ió tï bå executeä oî  Colä  Boot¬ 
theî  thå  buffeò  startinç aô 0FF04È shoulä bå filleä  witè  thå 
characteró oæ thå linå (caså ió immaterial)®   Iî anù  case¬  thå 
buffer contents MUST be terminated by a binary 0.

     Onå  prograí  caî  uså thió knowledgå tï  chaiî  tï  anotheò 
prograí  bù simplù storinç á commanä linå intï thå Multiplå  Com
manä Linå Buffer®   Thió ió ho÷ MENÕ performó itó  function®   Iô 
takeó  thå commanä linå giveî bù thå menõ programmeò (hå whï  seô 
uğ  thå MENU.CPÒ file© anä storeó iô verbatií (witè limiteä  pro
cessing©  intï  thå Multiplå Commanä Linå Buffer®   Oncå  stored¬ 
MENÕ  theî terminateó thió commanä witè á semicoloî (tï  indicatå 
thaô anotheò commanä follows)¬  itó namå (MENU© sï thaô MENÕ wilì 
bå reentereä wheî thå user'ó commanä ió finished¬ anä aî optionaì 
menõ numbeò tï reenteò at®  Alì oæ thió ió followeä bù á binarù ° 
tï indicatå aî enä oæ thå buffer.

     CD¬  wheî  iô logó intï á ne÷ directory¬  lookó foò thå filå 
ST.COM¬  and¬  iæ iô ió found¬  CÄ chainó tï ST.COÍ bù usinç  thå 
Multiplå  Commanä  Linå  Buffer®   Sincå CÄ anä SÔ arå  botè  twï 
characteró  long¬  anä  thå originaì CÄ commanä ió stilì  iî  thå 
buffer¬  CÄ simplù takeó thå currenô valuå oæ thå buffeò  pointeò 
(whicè  ió  pointinç tï thå characteò afteò thå CÄ  command¬  viú 
eitheò á semicoloî oò á binarù 0)¬  backó iô uğ ² bytes¬ replaceó 
thå pointer¬  storeó thå letteró "ST¢ wherå "CD¢ useä tï be¬  anä 
returnó  tï  ZCPR² witè thå appropriatå user/disë  flaç  sï  thaô 
ZCPR² wilì loç iî thå ne÷ directory®  ZCPR2¬ afteò logginç iî thå 
ne÷  directory¬  lookó aô thå Multiplå Commanä Linå Buffer¬  seeó 
thå commanä "ST"¬ anä runó it®  Nicå anä simple!

     Thå  followinç  terminaì sessioî illustrateó thå uså oæ  thå 
Multiplå  Commanä Linå Buffeò iî chaininç programó  togetheò  viá 
ZCPR2®  Notå thaô ANÙ commanä line¬ eveî onå consistinç oæ sever
aì  commandó  separateä  bù semicolons¬  maù bå storeä  intï  thå 
Multiplå  Commanä Linå Buffeò foò thå purposå oæ  chaining®   Thå 
terminaì sessioî followó oî thå nexô page:


B1>;
B1>;  This is a demo of chaining under ZCPR2
B1>;  Note that SYSLIB is used extensively in this
B1>;    example, and the reader is invited to refer
B1>;    to the SYSLIB User's Guide and SYSLIB User
B1>;    and Reference Manual if he really wants to see
B1>;    how this program works
B1>;
B1>
B1>;
B1>;  First, I have created a program that chains to itself,
B1>;  printing its command line each time:
B1>;
B1>type me.mac p
;
;  This program demonstrates the program chaining capability
;  under ZCPR2.
;
cr      equ     0dh     ;<CR>
lf      equ     0ah     ;<LF>

        ext     cline   ;SYSLIB routine to extract cmd line
        ext     pstr    ;SYSLIB routine to print string
        ext     print   ;SYSLIB routine to print ret string
        ext     bbline  ;one of the SYSLIB input line editors
        ext     cin     ;char in via SYSLIB
        ext     caps    ;char caps via SYSLIB
        ext     cout    ;char out via SYSLIB
        ext     crlf    ;new line

;
;  Print Banner
;
        call    print
        db      cr,lf,'Chaining Demo -- Command Line is: ',0
;
;  Extract and Print Command Line
;
        lxi     h,80h   ;pt to command line buffer
        call    cline   ;extract it
        call    pstr    ;print it
;
;  Prompt User and Get Single-Char Input from him
;
        call    print
        db      cr,lf,'Do you want to chain to ME? ',0
        call    cin     ;get response
        call    caps
        call    cout    ;echo
        call    crlf    ;new line
        cpi     'Y'     ;respond to Y only
        jnz     abort


;
;  Set Buffer Ptr and
;  Store ME Command into Multiple Command Line Buffer
;
        lxi     h,0ff00h        ;address of multiple command line
                                ;  buffer in my ZCPR2 System
        lxi     d,0ff00h+4      ;address of first char in buffer
        mov     m,e     ;set buffer ptr to first char
        inx     h
        mov     m,d     ;store low, high address of first char
        xchg            ;HL pts to first char in buffer
        lxi     d,command       ;store command name
        call    strput  ;save command name
        mvi     m,' '   ;store <SPACE> after command name
        inx     h       ;pt to char after space
        xchg            ;DE pts to next char in command line
;
;  Prompt User for and Get Command Line
;
        call    print
        db      cr,lf,'  Command Line? ',0
        xra     a       ;don't capitalize input
        call    bbline  ;get line from user
;
;  Store Rest of Command Line into Multiple Command Line Buffer
;
        xchg            ;DE pts to user input string, HL pts to
                        ;next char in command line
        call    strput  ;save string
        mvi     m,0     ;store ending zero in command
        ret             ;return to OS and let it run the command
;
;  Abort Program
;
abort:
        call    print
        db      cr,lf,'ME done',0
        ret
;
;  Utility Routine to Copy String pted to by DE to memory pted
;  to by HL until end of string (binary 0) is encountered.
;
strput:
        ldax    d       ;get char
        ora     a       ;done?
        rz              ;return if so
        mov     m,a     ;put it
        inx     h       ;pt to next
        inx     d
        jmp     strput  ;continue


;
;  ME Command
;
command:
        db      'me',0  ;name of this command

        end

B1>;
B1>;  Now to run the program -- all it does is store another
B1>;  command into the multiple Command Line Buffer which
B1>;  consists of its own name (ME) followed by the text input
B1>;  by the user.  When ME.COM runs, it prints the command
B1>;  line (the user text) and asks the user if he wants to
B1>;  do it again.
B1>;
B1>me

Chaining Demo -- Command Line is: 
Do you want to chain to ME? Y

  Command Line? this is the first run of ME

Chaining Demo -- Command Line is:  THIS IS THE FIRST RUN OF ME
Do you want to chain to ME? Y

  Command Line? this is another run of me

Chaining Demo -- Command Line is:  THIS IS ANOTHER RUN OF ME
Do you want to chain to ME? Y

  Command Line? this is the third run

Chaining Demo -- Command Line is:  THIS IS THE THIRD RUN
Do you want to chain to ME? Y

  Command Line? i'm bored, so let's quit now

Chaining Demo -- Command Line is:  I'M BORED, SO LET'S QUIT NOW
Do you want to chain to ME? N

ME done
B1>;
B1>;  End of Demo
B1>;


6.0  Paths, Command Processing, and Extended Command Processors

6.1  Paths

     Aó thå readeò haó seen¬ thå concepô oæ á patè ió fundamentaì 
tï  ZCPR2®   Iî  thå ZCPR² vernacular¬  á Path“ ió á  sequencå  oæ 
directorieó  tï bå searcheä foò á file®   Thå specificatioî oæ  á 
patè  ió  aó  á sequencå oæ DÕ formó whicè arå  extendeä  bù  thå 
introductioî  oæ thå "$¢ characteò tï indicatå á currenô disë  oò 
currenô useò area®  Exampleó oæ pathó are:

          1) $¤  $° A¤ A° -- Patè Froí Currenô Disk/Currenô  Useò 
             tï  Currenô  Disk/Useò ° tï Disë A/Currenô  Useò  tï 
             Disë  A/Useò  ° (Currenô Disk/Useò ió thå  disk/useò 
             areá thaô thå useò ió loggeä into)

     Iæ É waó loggeä intï Disë B¬  Useò 5¬  theî "$¢ iî thå  disë 
positioî  (firsô character© woulä meaî Â anä "$¢ iî thå 2nä posi
tioî woulä meaî Useò 5®   Hence¬  thå abovå path¬ whicè ió á sym
boliã path“ sincå iô containó thå "$¢ character¬  woulä bå  trans
lateä  intï aî absolutå path“ oæ Bµ B° Aµ A° iæ É waó loggeä  intï 
Bµ oò C· C° A· A° iæ É waó loggeä intï C7.

          2) $¤ A° A2² A1´ B2² C1² C° B° $° A¤ -- É thinë yoõ caî 
             follo÷ thió path»  thió ió tï illustratå thaô á patè 
             lengtè ió indefinitå (usuallù uğ tï 1¶  directories¬ 
             whicè  ió quitå reasonable© anä caî extenä intï useò 
             areaó beyonä 15¬ whicè can'ô bå loggeä into

     Again¬  iæ É waó loggeä intï B5¬ thió symboliã patè woulä bå 
translateä intï thå absolutå patè of:

          B5 A0 A22 A14 B22 C12 C0 B0 B0 A5

     Thå PATÈ commanä ió availablå tï thå ZCPR² useò tï allo÷ hií 
tï  displaù  hió currenô patè anä dynamicallù changå iô durinç  á 
session®   Oncå changed¬ thå patè stayó iî thå altereä forí untiì 
eitheò  á Colä Booô occuró oò thå useò employó PATÈ tï changå  iô 
again®   Thió  haó beeî illustrateä severaì timeó beforå iî  thió 
document®   Studù  thå  followinç terminaì sessioî  foò  specifiã 
exampleó oæ thå uså oæ pathó iî ZCPR2.

B1>;
B1>;  This example illustrates paths under ZCPR2
B1>;
B1>


B1>;
B1>;  First, I have this program:
B1>;
B1>type where.mac
        ext     retud
        ext     print
        ext     padc
        ext     cout

        call    retud   ;get user/disk in C/B
        call    print
        db      'You are logged into Disk ',0
        mov     a,b     ;get disk
        adi     'A'     ;convert to letter
        call    cout
        call    print
        db      ' and User ',0
        mov     a,c     ;get user
        call    padc    ;print as decimal
        ret

        end

B1>;
B1>;  ... which does this:
B1>;
B1>where
You are logged into Disk B and User   1
B1>
B1>;
B1>;  There is currently only one copy of WHERE.COM, and that is
B1>;  in B1
B1>;
B1>
B1>;
B1>;  My path is:
B1>;
B1>path
PATH Version 2.2
Current Symbolic Path --
        $$: --> $0: --> A$: --> A0:
Current Absolute Path --
        B1: --> B0: --> A1: --> A0:
Current Named Path --
        ASM: --> DEV-ROOT: --> R-ASM: --> ROOT:
B1>2:


B2>;
B2>;  I do not cover B1 now, so WHERE.COM will not be found
B2>;  when I issue the command:
B2>;
B2>where
WHERE?
B2>;
B2>;  Unless, of course, I tell ZCPR2 where to look:
B2>;
B2>1:where
You are logged into Disk B and User   2
B2>;
B2>;  OR ... I could change the path to cover B1
B2>;
B2>path $$ $0 a$ a0 b1
PATH Version 2.2
Current Symbolic Path --
        $$: --> $0: --> A$: --> A0: --> B1:
Current Absolute Path --
        B2: --> B0: --> A2: --> A0: --> B1:
Current Named Path --
        BDSC: --> DEV-ROOT: --> R-BDSC: --> ROOT: --> ASM:
B2>;
B2>;  Now, WHERE in B1 will ALWAYS be found, because B1 is
B2>;  Specifically in the PATH!
B2>;
B2>where
You are logged into Disk B and User   2
B2>;
B2>;  ... whereever I go, B1 is in the path, and WHERE.COM in
B2>;  B1 will be found:
B2>;
B2>a10:;path
PATH Version 2.2
Current Symbolic Path --
        $$: --> $0: --> A$: --> A0: --> B1:
Current Absolute Path --
        A10: --> A0: --> A10: --> A0: --> B1:
Current Named Path --
        SYS: --> ROOT: --> SYS: --> ROOT: --> ASM:
A10>where
You are logged into Disk A and User  10
A10>b15:
B15>where
You are logged into Disk B and User  15
B15>a0:;where
You are logged into Disk A and User   0
A>b1:


B1>;
B1>;  Now, in a normal ZCPR2 working environment, it is nice to store
B1>;  commands in one of the user areas you can't log into, and then
B1>;  set up the path to go into it:
B1>;
B1>mcopy a16:=where.com
MCOPY  Version 2.2
        Copy B  1: WHERE   .COM to A 16:
No Original File WHERE   .COM on Destination
!

    Copy Complete,  Verify Phase --

    Verify Complete
**** MCOPY Complete ****
            1 Files Copied
            0 Copy Errors
B1>path $$ $0 a$ a0 a16
PATH Version 2.2
Current Symbolic Path --
        $$: --> $0: --> A$: --> A0: --> A16:
Current Absolute Path --
        B1: --> B0: --> A1: --> A0: --> A16:
Current Named Path --
        ASM: --> DEV-ROOT: --> R-ASM: --> ROOT: --> Noname:
B1>era where.com
WHERE   .COM
B1>where
You are logged into Disk B and User   1
B1>b5:;where
You are logged into Disk B and User   5
B5>a14:
A14>where
You are logged into Disk A and User  14
A14>;
A14>;  See the point?  Now, if I take away WHERE.COM from A16,
A14>;  it won't be found anymore:
A14>;
A14>era a16:where.com
WHERE   .COM
A14>where
WHERE?
A14>b1:
B1>where
WHERE?
B1>;
B1>;  End of Demo
B1>;



6.2  Command Processing

     Commanä  processinç  undeò  ZCPR²  followó  á  verù  logicaì 
sequence of events each time a command is issued:

 1) Inpuô anä Parså Commanä Linå froí Useò oò File

 2) Determinå  iæ iô ió á ZCPR2-residenô commanä anä ruî  iô 
    iæ so

 3) Searcè  alonç thå commanä searcè path¬  logginç intï thå 
    diskó anä useò areaó indicateä iî thå patè untiì  eitheò 
    thå  bottoí  oæ thå patè ió reacheä oò thå  desireä  COÍ 
    filå ió found» ruî prograí iæ found

 4) Invokå  aî Extendeä Commanä Processor¬  passinç thå Com
    manä Linå tï it

 5) Prinô erroò messagå iæ 2¬ 3¬ anä ´ fail


     Wheî  ZCPR² searcheó foò á file¬  iô followó á  path®   Thió 
patè  ió referreä tï aó thå Commanä Searcè Path®   Twï  extremelù 
flexiblå featureó iî thió desigî are:

 1) thå commanä searcè patè maù bå redefineä dynamicallù  bù 
    thå user

 2) severaì ZCPR² transientó uså pathó also¬ anä theså pathó 
    maù  bå thå samå patè useä bù commanä searcè oò theù maù 
    bå uniquå tï eacè transient

     Iæ thå patè searcè fails¬ ZCPR² caî theî searcè foò anä loaä 
aî  extendeä  commanä  processoò foò furtheò  processinç  oæ  thå 
commanä  linå beyonä thoså facilitieó oæ ZCPR² itself®   Refeò tï 
thå  examplå  undeò  sectioî 6.± foò detailó oî  thå  ZCPR²  patè 
searcè techniques.


6.3  Extended Command Processors

     Thå lasô functioî tï bå performeä beforå ZCPR² finallù giveó 
uğ  iî itó searcè foò á commanä specifieä bù thå useò ió tï  looë 
foò anä ruî aî Extendeä Commanä Processor®   Thió facilitù caî bå 
engageä  oò  disengageä aô thå discretioî oæ thå systeí  manager¬ 
and¬ iæ iô ió engaged¬ thå systeí manageò caî elecô tï havå ZCPR² 
searcè  thå entirå commanä searcè patè foò thå  Extendeä  Commanä 
Processoò oò tï onlù looë iî thå lasô directorù loggeä iî (aô thå 
enä oæ thå path).


     Thå  lasô twï optionó arå seô aô assemblù timå bù thå  ROOT
ONLÙ  equate®   Thå prioò option¬  thaô oæ havinç thió featurå oò 
not¬  ió  alsï seô aô assemblù timå bù thå CMDRUÎ  equate®   Alsï 
specifieä  aô  thió timå ió thå namå anä typå oæ thå filå  tï  bå 
executeä aó thå Extendeä Commanä Processor.

     Iæ thå Extendeä Commanä Processoò ió noô found¬  thå conven
tionaì erroò messagå ió given¬  flagginç thå originaì commanä  aó 
beinç  iî error®   Iæ thå Extendeä Commanä Processoò (nameä  CMD
RUN.COÍ  aó  peò thå recommendation© ió found¬  theî  thå  entirå 
commanä  linå ió passeä tï iô aó thï iô haä beeî ruî aó á commanä 
iî  itó owî right®   Foò instance¬  iæ thå originaì commanä  linå 
was:

          MASM MYPROG

anä  thå  filå MASM.COÍ waó noô founä buô  thå  Extendeä  Commanä 
Processoò  CMDRUÎ was¬  theî thió woulä bå equivalenô tï  issuinç 
thå command:

          CMDRUÎ MASÍ MYPROG

     Thå  utilitù oæ thió featurå caî bå seeî immediately®   Ima
ginå  thaô thå SUBMIÔ prograí werå renameä tï CMDRUN®   Theî  thå 
failurå oæ á commanä woulä causå SUBMIÔ tï ruî anä attempô tï ruî 
á commanä file.


     Witè  thió featurå iî mind¬  threå ZCPR² transientó arå pro
videä whicè maù bå useä aó Extendeä Commanä Processors®  Theù arå 
SUB2¬  ZEX¬ anä LRUNZ®  SUB² anä ZEØ arå commanä filå processors®  
SUB² ió likå aî enhanceä SUBMIT¬ anä ZEØ ió alsï likå aî enhanceä 
SUBMIÔ  buô  iô placeó itó executablå texô intï memorù  anä  runó 
mucè faster.

     LRUNÚ ió á COÍ filå extractor®  Iô workó iî conjunctioî witè 
thå Librarù Utilitù (LU© prograí anä caî extracô á COÍ filå  froí 
COMMAND.LBÒ  anä theî ruî it®   Iî essence¬  LRUNÚ aó aî Extendeä 
Commanä Processoò actó aó á mediarù betweeî á COÍ filå storeä  iî 
COMMAND.LBÒ  anä ZCPR2®   Iî thió case¬  iæ thå originaì  commanä 
was:

          XXXØ THIÓ IÓ IT

anä  XXXX.COÍ waó noô found¬  theî CMDRUÎ (LRUNZ© woulä bå execu
ted¬  finä  XXXX.COÍ iî COMMAND.LBÒ (afteò searchinç thå  commanä 
searcè patè foò COMMAND.LBR)¬ simulatinç thió command:

          LRUNÚ XXXØ THIÓ IÓ IT


     Oncå  LRUNÚ locateä XXXX.COÍ iî COMMAND.LBR¬  iô woulä  loaä 
XXXX.COÍ anä pasó tï iô thió commanä line:

          THIÓ IÓ IT

     Thå  SUB2¬  ZEX¬  anä LRUNÚ programó arå describeä  iî  morå 
detail in the User's Guide.

     Thå  followinç ió á terminaì sessioî illustratinç thå uså oæ 
ZEX as an Extended Command Processor:

B1>;
B1>;  I will illustrate the use of ZEX as the Extended
B1>;  Command Processor.  To do this, CMDRUN.COM must be
B1>;  created from the file ZEX.COM, and the name of the
B1>;  desired command file(s) must be made different from any
B1>;  corresponding COM file:
B1>;
B1>a0:
A>pip cmdrun.com=zex.com[r]

A>dir *.com
CMDRUN  .COM
A>1:
A1>;
A1>;  Since I have M80.ZEX and M80.COM, I want M80.ZEX to be
A1>;  unique so that a COM file won't be picked up before the
A1>;  ZEX file is run:
A1>;
A1>pip masm.zex=m80.zex

A1>b:

B1>;
B1>;  Now to illustrate by creating and assembling a program
B1>;
B1>ed demo.mac

NEW FILE
     : *i
    1:          ext     cline
    2:          ext     pstr
    3:  	lxi	h,80h	;pt to command line from OS
    4:          call    cline   ;get command line
    5:          call    pstr    ;print it
    6:          ret
    7:  
    8:          end
    9:  
     : *e


B1>;
B1>;  Now to use the MASM.ZEX file as tho it were a COM file.
B1>;  In the next command line, "time" is TIME.COM and "masm"
B1>;  is MASM.ZEX:
B1>;
B1>time;masm demo;time
TIME  Version 1.1    7:18:55 AM on Tuesday December 21, 1982
ZEX, Version 1.1
(ZEX Active)
B1>;  M80.SUB -- MACRO-80 Assembler and Linker
B1>M80 =DEMO

No Fatal error(s)

(ZEX Active)
B1>;  Please Type ^C if Error(s) Exist - 

B1>ERA DEMO.BAK
DEMO    .BAK
B1>ERA DEMO.COM
No File
B1>L80 /P:100,DEMO,A:SYSLIB/S,DEMO/N,/U,/E

Link-80  3.44  09-Dec-81  Copyright (c) 1981 Microsoft
Data    0100    02C4    <  452>

35668 Bytes Free

Data    0100    02C4    <  452>

35668 Bytes Free
[0000   02C4        2]

(ZEX Active)
B1>ERA DEMO.REL
DEMO    .REL
B1>;  Assembly Complete
B1>TIME
TIME  Version 1.1    7:20:02 AM on Tuesday December 21, 1982
B1>
(ZEX Completed)
By Your Command >dir
DEMO    .MAC  |  DEMO    .COM
B1>demo this is a test
 THIS IS A TEST
B1>;
B1>;  End of Demo
B1>;


7.0  Redirectable I/O

7.1  The Concept

     Redirectablå  Input/Output“ referó tï thå abilitù oæ thå CP/Í 
useò  tï  switcè  tï differenô Input/Outpuô  deviceó  durinç  thå 
courså oæ á CP/Í session®  Optionallù implementeä througè thå I/Ï 
Byte¬ I/Ï undeò CP/Í supportó fouò logicaì devices¬ namely:

          Á Consolå (CON:)¬ whicè ió aî input/outpuô device
          A Printer (LST:), which is an output-only device
          A Reader (RDR:), which is usually an input-only device
          A Punch (PUN:), which is usually an output-only device

Eacè  oæ  theså  fouò logicaì deviceó maù havå anù  onå  oæ  fouò 
physicaì deviceó assigneä tï them¬  givinç thå useò uğ tï sixteeî 
physicaì  deviceó  hå maù worë with®   Thå readeò ió  inviteä  tï 
refeò  tï thå CP/Í 2.² Alteratioî Guide“ bù Digitaì  Researcè  foò 
furtheò information.

     Thå  I/Ï Bytå (aô memorù locatioî 3© ió useä tï specifù  thå 
assignmenô  oæ  theså  devices®   Iô ió divideä intï  fouò  2-biô 
fields¬  eacè fielä associateä witè á logicaì devicå anä eacè  oæ 
thå  fouò  biô combinationó (00¬  01¬  10¬  11© withiî thå  fielä 
associateä witè á physicaì device®   Thå STAÔ commanä ió useä  tï 
makå mnemoniã assignmentó tï thå variouó devices¬  aó iî commandó 
likå  "STAÔ  CON:=CRT:"®   Thå  followinç  tablå  summarizeó  thå 
logicaì  anä physicaì devicå assignmentó anä mnemonicó  availablå 
through the I/O Byte:

                      I/O Byte Assignments

          Logical Device -->  LST: | PUN: | RDR: | CON:
          Bit Position   -->  7 6  | 5 4  | 3 2  | 1 0 
     Physical Assignment   |  ---- | ---- | ---- | ----
           0     00 Binary |  TTY: | TTY: | TTY: | TTY:
           1     01 Binary |  CRT: | PTP: | PTR: | CRT:
           2     10 Binary |  LPT: | UP1: | UR1: | BAT:
           3     11 Binary |  UL1: | UP2: | UR2: | UC1:


                        I/O Byte Devices
         Physical Device     Typical Meaning
               TTY:           Teletype
               CRT:           Cathode Ray Tube Terminal
               BATº           Batcè Processoò (RDR=in¬ LST=out)
               UC1:           User-Defined Console
               PTR:           Paper Tape Reader
            UR1:, UR2:        User-Defined Reader Devices
               PTP:           Paper Tape Punch
            UP1:, UP2:        User-Defined Punch Devices
               LPT:           Line Printer
               UL1:           User-Defined List Device
Š
     Hence¬  bù  usinç thå STAÔ command¬  thå CP/Í 2.²  useò  maù 
reassigî  thå  physicaì  deviceó tï hió  logicaì  devices¬  usinç 
differenô  deviceó  froí  timå tï timå witè  hió  systeí  withouô 
actuallù changinç thå hardwarå configuration®   Foò instance¬  mù 
systeí  comeó  uğ witè CON:=CRT:¬  anä thå CRÔ ió  thå  principaì 
consolå  device¬  buô É caî changå iô wheî É wisè tï mù  printinç 
terminaì  bù  issuinç thå commanä "STAÔ CON:=TTY:"¬  siô  aô  thå 
printinç terminaì aó thï É waó aô thå CRT¬  and¬  wheî  finished¬ 
movå bacë tï thå CRÔ bù issuinç thå commanä "STAÔ CON:=CRT:".


7.2  A More Flexible Redirectable I/O System

     Undeò ZCPR2¬  É havå implementeä á slightlù differenô schemå 
foò redirectablå I/O®   Aó peò thå ZCPR² norm¬  yoõ maù selecô tï 
continuå  usinç youò olä schemå oò switcè tï thió ne÷  one®   Thå 
concepô oæ thió ne÷ schemå follows.

     First¬ thå BIOÓ aó loadeä froí thå systeí trackó oæ thå disë 
containó  onlù  á fe÷ primitivå I/Ï drivers®   Onlù thå CRÔ aó  á 
consolå ió enabled¬  anä thå reader¬  punch¬ anä lisô deviceó arå 
assigned to the CRT.  No redirection is permitted at this time.

     Second¬  thå  BIOÓ ió structureä witè alì thå I/Ï entrieó iî 
itó  jumğ tablå branchinç tï á seconä jumğ tablå (whicè ió  init
ializeä  bù thå Colä Booô Routine)®   Thió seconä jumğ  tablå  ió 
placeä  oî á pagå boundarù aô thå beginninç oæ á 1K-bytå  scratcè 
area®   Iô  ió  iî  thió 1K-bytå scratcè areá thaô  thå  physicaì 
devicå driveró foò mù systeí reside®  Thå recommendatioî oæ á 1K-
bytå areá ió á minimum®   É havå implementeä á 2K-bytå areá whicè 
ió  largå  enougè tï supporô almosô anythinç É caî  conceivå  of¬ 
includinç redirectioî tï disk®  Picturå follows:



                      Sample BIOS Structure

Base of BIOS -->    ------------------------------------
(Lower Memory)      | Jump for Cold and Warm Boots     |
                    | Console Status Jump to IOBASE+12 |
                    | Console Input Jump to  IOBASE+15 |
                    | Console Output Jump to IOBASE+18 |
                    | List Output Jump to    IOBASE+21 |
                    | Punch Output Jump to   IOBASE+24 |
                    | Reader Input Jump to   IOBASE+27 |
                    | Jumps for Disk I/O               |
                    | List Status Jump to    IOBASE+30 |
                    | Jump for Sector Translation      |
End of Jump Table ->|----------------------------------|
                    | Body of BIOS, Containing:        |
                    |    Cold and Warm Boot Routines   |
                    |    Disk I/O Routines             |
                    |    Sector Translation Routine    |
IOBASE ->           |----------------------------------|
(On Page Boundary,  | Jump to Status Routine           |
1K Bytes in Size)   | Jump to Device Select Routine    |
                    | Jump to Device Name Routine      |
                    | Jump to Package Init Routine     |
IOBASE + 12 -->     | Jump to Console Status           |
IOBASE + 15 -->     | Jump to Console Input            |
IOBASE + 18 -->     | Jump to Console Output           |
IOBASE + 21 -->     | Jump to List Output              |
IOBASE + 24 -->     | Jump to Punch Output             |
IOBASE + 27 -->     | Jump to Reader Input             |
IOBASE + 30 -->     | Jump to List Status              |
IOBASE + 33 -->     | Jump to New I/O Routine          |
End of Jump Table ->|----------------------------------|
                    | Body of Redirectable I/O Driver  |
                    |  Package Containing the Routines |
                    |  Jumped to Starting at IOBASE    |
End of BIOS -->     ------------------------------------



7.3  What the Redirectable I/O System Buys You

     Aó thå readeò caî see¬  CP/Í compatabilitù ió maintaineä  iî 
thaô  therå arå stilì onlù fouò logicaì devices®   Theså arå  thå 
Consolå (CON:)¬  Printeò (LST:)¬ Readeò (RDR:)¬ anä Puncè (PUN:)®  
Whaô  thå  readeò  maù  noô seå yeô ió thaô  thå  restrictioî  oæ 
assigninç  onlù  fouò physicaì deviceó tï eacè oæ  theså  logicaì 
deviceó ió no÷ gonå aó welì aó thå ratheò obscurå nameó giveî  tï 
thå physicaì deviceó (sucè aó UR1:¬ UC1:¬ BAT:¬ etc).

     Thå  designeò oæ thió systeí doeó noô neeä tï paù  attentioî 
tï thå structurå oæ thå I/Ï Bytå aó defineä bù Digitaì  Research®  
Instead¬ hå caî structurå thå I/Ï Bytå anù waù hå chooseó oò eveî 
selecô  á  differenô structure¬  sucè aó á 2-bytå  I/Ï  Word¬  tï 
controì hió redirectablå I/O.Š
     Environments such as the following can be implemented:

          No Reader or Punch Devices are available
          The LST: Device may be any of the following:
               1) the Printing Terminal
               2) the CRT
               3) a Line Printer
               4) a Modem
               5) a Link to Another Computer
               6) a Disk File
          The CON: Device may be any of the following:
               1) the Printing Terminal (TTY)
               2) the CRT
               3) a Modem
               4) a Link to Another Computer
               5) CRT Input and CRT and Modem Output
               6) CRT Input and CRT and Remote Computer Output
               7) CRT Input and CRT and Disk File Output
               8) TTY Input and TTY and Modem Output
               9) TTY Input and TTY and Remote Computer Output
              10) TTY Input and TTY and Disk File Output

     Aó thå readeò caî see¬ É no÷ havå ¶ LSTº deviceó anä 1° CONº 
deviceó  (whicè  ió quitå á biô morå flexiblå thaî havinç onlù  ´ 
LSTº  deviceó anä ´ CONº devices)®  Also¬ ¶ deviceó requireó onlù 
³  bitó  tï represenô theí (0-5© anä 1° deviceó requireó  onlù  ´ 
bitó tï represenô theí (0-9)¬ sï onlù onå bytå ió requireä foò aî 
I/Ï Byte.

     Thå  Redirectablå  I/Ï Driveró contaiî threå  routineó  (thå 
firsô  threå iî thå jumğ tablå startinç aô IOBASE© whicè  providå 
the following functions:

   1) STATUS -- Telló thå callinç prograí ho÷ manù  physicaì 
                deviceó  arå availablå foò thå  CON:¬  LST:¬ 
                RDR:¬  anä  PUNº  logicaì deviceó anä  whicè 
                physicaì  devicå  ió currentlù  assigneä  tï 
                eacè oæ thå logicaì devices

   2) SELECT -- Allowó  á callinç prograí tï assigî á physi
                caì devicå tï á logicaì device.

   3) NAMER  -- Returnó tï thå callinç prograí á pointeò  tï 
                á  texô  strinç whicè describeó  á  physicaì 
                device®   Thå callinç prograí passeó tï thió 
                routinå  thå  logicaì  devicå  anä  physicaì 
                devicå numbers.


     Thå  STATUÓ routinå requireó nï inputó anä returnó á pointeò 
tï á tablå iî HL®   Thió tablå ió structureä aó á serieó oæ  fouò 
bytå  pairs®   Thå  firsô bytå paiò ió associateä witè  thå  CONº 
device¬  thå seconä witè thå RDRº device¬ thå thirä witè thå PUNº 
device¬  anä thå fourtè witè thå LSTº  device®  Thå firsô bytå oæ 
eacè paiò containó thå numbeò oæ physicaì deviceó thaô thå logic
aì  devicå maù bå assigneä tï (thió numbeò ió iî thå rangå froí ° 
tï 255)®  Thå seconä bytå oæ eacè paiò containó thå numbeò oæ thå 
physicaì devicå currentlù assigneä tï thå logicaì devicå (iî  thå 
rangå froí ° tï numbeò oæ deviceó - 1).  Summary:

                 STATUS Routine Table Structure

                       Count       Assignment
          Device    Byte Number    Byte Number
            CON:         0              1
            RDR:         2              3
            PUN:         4              5
            LST:         6              7

     Example:
          STABLE:
               DB   6,2       ;6 Devices, Device 2 (3rd Device)
                              ;  Assigned to CON:
               DB   0,0       ;No RDR: Devices
               DB   0,0       ;No PUN: Devices
               DB   10,5      ;10 Devices, Device 5 (6th Device)
                              ;  Assigned to LST:

     Thå  SELECÔ routinå ió useä tï assigî á physicaì devicå tï á 
logicaì  device®   Iô  ió calleä witè thå logicaì  devicå  numbeò 
(wherå CONº  ió 0¬  RDRº ió 1¬ PUNº ió 2¬ anä LSTº ió 3© iî thå Â 
Registeò anä thå physicaì devicå numbeò iî thå Ã  register®   SE
LECÔ  returnó witè thå Zerï Flaç Seô (Z© iæ aî invaliä  selectioî 
waó madå (sucè aó Â ¾ ³ oò Ã ¾ maø devicå number)®  Example:

               MVI  B,0       ;Select CON:
               MVI  C,4       ;Physical Device 4
               CALL IOBASE+3  ;SELECT Routine
               JZ   DEVERR    ;Error Handler
               MVI  B,3       ;Select LST:
               MVI  C,2       ;Physical Device 2
               CALL IOBASE+3  ;SELECT Routine
               JZ   DEVERR    ;Error Handler


     Finally¬  thå NAMEÒ routinå ió uså tï returî tï thå calleò á 
texô strinç (á vectoò oæ ASCIÉ characteró terminateä bù á  binarù 
0©  whicè describeó thå physicaì devicå requested®   Oî input¬  Â 
containó  thå logicaì devicå numbeò anä Ã containó  thå  physicaì 
devicå numbeò (aó iî thå SELECÔ routine)®   Oî output¬  HÌ pointó 
tï  thå strinç anä thå Zerï Flaç ió Seô (Z© iæ aî invaliä  selec
tioî waó made®  Thió returneä texô strinç ió containó thå mnemon
iã namå oæ thå devicå (uğ tï eighô characteró long© followeä bù á 
spacå  anä anù desireä texô whicè describeó thå attributeó oæ thå 
physicaì device®  Example:

               MVI  B,0       ;Select CON:
               MVI  C,2       ;Physical Device 2
               CALL IOBASE+6  ;NAMER Routine
               JZ   DEVERR    ;Error Handler
               CALL PRINT     ;Print String pted to by HL

May result in the following text being printed:

          MODEM DC Hayes Smartmodem

Notå  thaô  thió  conformó tï entrù ³ (Physicaì Devicå ²  ió  thå 
thirä device© iî mù tablå á couplå oæ pageó back.

     Tï  puô  thió alì together¬  thå prograí calleä  DEVICE²  ió 
provideä witè thå ZCPR² System®   Iô performó thå followinç func
tions:

          o Returns the Names of All Physical Devices
          o Returns the Names of only the Physical Devices
               Associated with a Particular Logical Device
          o Allows the User to Assign a Physical Device to a
               Logical Device

     Tï  illustratå  thió concepô iî general¬  pleaså  studù  thå 
followinç  terminaì  session®   Thió  ió aî oldeò versioî  oæ  mù 
currenô system¬  thå maiî differencå beinç thaô mù currenô systeí 
supportó  redirectioî  tï disë fileó aó welì aó mosô oæ  thå  en
vironmenô giveî iî thå followinç example.


B7>;
B7>;  This is a sample terminal session illustrating the DEVICE2
B7>;  Program and how Redirectable I/O can work under ZCPR2
B7>;
B7>device2 //
DEVICE2, Version 1.0
        DEVICE is a program which enables the user to
manipulate the extended ZCPR2 redirectable device
drivers.  It allows the user to perform the following
functions:
                Display the Names of the Current Devices
                Set One or More of the Current Devices
        The format of the DEVICE command is:
                DEVICE                          <-- Enter Interac
                DEVICE //                       <-- Ask for Help
                DEVICE Command,Command, ...     <-- Issue Command
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

B7>device2 display=all
DEVICE2, Version 1.0

CON: Devices --
        CRTREM Televideo 950 CRT Input and CRT/Remote Output
        CRTMOD Televideo 950 CRT and Modem in Parallel
        CRT Televideo 950 CRT
        TTY Model 43 Printing Terminal
  Current Assignment: CRTMOD Televideo 950 CRT and Modem in Paral

RDR: Devices --
        CLOCK DC Hayes Chronograph
        CRTMOD CRT or Modem Input with CRT Output
        MODEM DC Hayes Smartmodem
        REMOTE Remote Computer
  Current Assignment: CLOCK DC Hayes Chronograph
Strike Any Key to Continue -- 

PUN: Devices --
        CLOCK DC Hayes Chronograph
        CRTREM CRT and Remote Computer Output
        MODEM DC Hayes Smartmodem
        REMOTE Remote Computer
  Current Assignment: CLOCK DC Hayes Chronograph


LST: Devices --
        MODEM DC Hayes Smartmodem
        REMOTE Remote Computer
        CRT Televideo 950 CRT
        TTY Model 43 Printing Terminal
  Current Assignment: TTY Model 43 Printing Terminal
B7>;
B7>;  Interactive Mode allows the user to repeatedly perform
B7>;  functions
B7>;
B7>device2
DEVICE2, Version 1.0
DEVICE2 Interactive Command System
Type ? and Strike RETURN for Help
DEVICE2 Command? ?
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

A command line beginning with a semicolon (;) is a comment.
The X Command Exits DEVICE2.

DEVICE2 Command? ;  Note that DEVICE2 commands may be abbreviated
DEVICE2 Command? display=con

CON: Devices --
        CRTREM Televideo 950 CRT Input and CRT/Remote Output
        CRTMOD Televideo 950 CRT and Modem in Parallel
        CRT Televideo 950 CRT
        TTY Model 43 Printing Terminal
  Current Assignment: CRTMOD Televideo 950 CRT and Modem in Paral
DEVICE2 Command? d=c

CON: Devices --
        CRTREM Televideo 950 CRT Input and CRT/Remote Output
        CRTMOD Televideo 950 CRT and Modem in Parallel
        CRT Televideo 950 CRT
        TTY Model 43 Printing Terminal
  Current Assignment: CRTMOD Televideo 950 CRT and Modem in Paral
DEVICE2 Command? ;  Note that DEVICE2 commands may be stacked


DEVICE2 Command? d=c,display list

CON: Devices --
        CRTREM Televideo 950 CRT Input and CRT/Remote Output
        CRTMOD Televideo 950 CRT and Modem in Parallel
        CRT Televideo 950 CRT
        TTY Model 43 Printing Terminal
  Current Assignment: CRTMOD Televideo 950 CRT and Modem in Parallel

LST: Devices --
        MODEM DC Hayes Smartmodem
        REMOTE Remote Computer
        CRT Televideo 950 CRT
        TTY Model 43 Printing Terminal
  Current Assignment: TTY Model 43 Printing Terminal
DEVICE2 Command? ;  The Display command is delimited by space or =
DEVICE2 Command? ;  The assignments commands are not, however
DEVICE2 Command? d punch

PUN: Devices --
        CLOCK DC Hayes Chronograph
        CRTREM CRT and Remote Computer Output
        MODEM DC Hayes Smartmodem
        REMOTE Remote Computer
  Current Assignment: CLOCK DC Hayes Chronograph
DEVICE2 Command? pun:=modem
DEVICE2 Command? d p

PUN: Devices --
        CLOCK DC Hayes Chronograph
        CRTREM CRT and Remote Computer Output
        MODEM DC Hayes Smartmodem
        REMOTE Remote Computer
  Current Assignment: MODEM DC Hayes Smartmodem
DEVICE2 Command? p=crtrem,d p

PUN: Devices --
        CLOCK DC Hayes Chronograph
        CRTREM CRT and Remote Computer Output
        MODEM DC Hayes Smartmodem
        REMOTE Remote Computer
  Current Assignment: CRTREM CRT and Remote Computer Output
DEVICE2 Command? punch=clock,display punch

PUN: Devices --
        CLOCK DC Hayes Chronograph
        CRTREM CRT and Remote Computer Output
        MODEM DC Hayes Smartmodem
        REMOTE Remote Computer
  Current Assignment: CLOCK DC Hayes Chronograph
DEVICE2 Command? x
B7>;
B7>;  End of Demo
B7>;Š
7.4  Loading Redirectable I/O Drivers at Cold Boot Time

     Thå  Colä Booô Routinå iî thå maiî bodù oæ thå BIOÓ initial
izeó  thå I/Ï packagå startinç aô IOBASE¬  providinç  aî  initiaì 
jumğ tablå anä aî initiaì seô oæ routines.

     Again¬  iî mù system¬ oncå thå Colä Booô Routinå haó finish
ed¬  iô  passeó controì tï ZCPR2®   Onå oæ thå thingó iô haó donå 
beforå iô passeó control¬  however¬  ió tï storå aî initiaì  com
mand¬ STARTUP¬ iî thå Multiplå Commanä Linå Buffer®  ZCPR² startó 
up¬  seeó  thió  commanä iî itó buffer¬  anä executeó  it®   Upoî 
execution¬  STARTUĞ loadó thå Multiplå Commanä Linå Buffeò witè á 
serieó oæ commands¬ which¬ iî mù case¬ are:

          IOLOADER -- Load SYSIO.IO into the Redirectable I/O
                      Buffer Starting at IOBASE
          LD LD    -- Load the Named Directory LD.DIR into the
                      Memory-Based Named Directory Buffer
          TINIT    -- Program my Televideo 950 CRT with the
                      Configuration found in STD.CFG
          ECHO msg -- Print a Welcome Message to the User

     Oæ interesô foò thió discussioî ió thå functioî performeä bù 
IOLOADER®   Generallù speaking¬  IOLOADEÒ searcheó alonç thå com
manä  searcè patè foò á filå containinç Redirectablå I/Ï  Driveró 
anä  loadó thå drivers¬  wheî found¬  intï thå buffeò startinç aô 
IOBASE®  Alì sucè fileó havå á filå typå oæ IO¬ anä É caî havå aó 
manù  sucè setó oæ I/Ï driveró aó É desire®   Iæ IOLOADEÒ ió  noô 
giveî á filå name¬ iô searcheó foò SYSIO.IO» iæ IOLOADEÒ ió giveî 
á  filå name¬  aó iî "IOLOADEÒ DISKIO"¬  iô searcheó  foò  "file
name.IO¢ (DISKIO.IO).

     Oncå  IOLOADEÒ haó completeä itó load¬  iô calló thå  driveò 
initializatioî routinå aô IOBASE+¹ anä returnó tï ZCPR² wheî thió 
routinå ió finished®   Thå initializatioî routinå performó  what
eveò devicå initializationó arå desired.

     Alì oæ theså commandó arå discusseä iî detaiì iî thå  User'ó 
Guide®   Pleaså  notå thaô theså programó arå stilì beinç refineä 
(prioò tï releaså oæ ZCPR2)¬  anä theù maù perforí slightlù diff
erentlù  thaî  advertiseä iî thió Conceptó  Manual®   Thå  User'ó 
Guidå  identifieó thå programó thaô iô discusseó bù versioî  num
ber¬  anä  iô wilì bå prepareä aó thå programó arå finalizeä  foò 
release.

     Foò  mucè  morå technicaì informatioî oî thå contentó  oæ  á 
Redirectablå  Devicå Driveò Package¬  looë aô thå sourcå codå  tï 
SYSIO.ASM®   Thió  ió thå sourcå tï thå standarä packagå whicè  É 
uså oî mù maiî microcomputer.

















               This Page Intentionally Left Blank

