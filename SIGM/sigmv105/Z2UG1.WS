.fo Section 4 - Library Utilities                      Page   #

4.0  Library Utilities

4.1  Author Credits and Introduction to LU

     Thió  documenô applieó tï versioî 1.1° oæ LU.COM®   Iô  alsï 
applieó  tï Versioî 1.° oæ LDIRÚ bù Richarä Conî anä Versioî  1.° 
oæ  LRUNÚ  bù Richarä Conî (whicè waó deriveä froí LRUÎ  bù  Garù 
Novosielski).

Copyright (c) 1982 Gary P. Novosielski
All rights reserved.

     Permissioî  ió  herebù  granteä  tï copù anä distributå thió 
documenô   foò   anù  non-commerciaì  purpose®  Anù uså  oæ  thió 
materiaì   foò   commerciaì   advantagå  withouô   prioò  writteî 
consenô oæ thå authoò ió prohibited.

     É  havå  modifieä thå originaì documenô foò inclusioî  iî  á 
HELĞ  filå  anä elaborateä oî thå subjecô witè  documentatioî  oî 
LRUNZ and LDIRZ.


                          INTRODUCTION

     Librarù  Utilitù  (LU©  ió  á  prograí tï allo÷ combininç oæ 
multilplå   fileó   intï  onå  largeò  file®   Iô  requireó  CP/Í 
versioî  2.°  oò  higheò  tï  run®  LÕ  runó undeò ZCPR2.

     Thió  largeò  filå ió divideä intï twï  basiã  partó  -- thå 
directorù  (aô  thå  fronô  oæ thå file© anä  thå  fileó  oæ  thå 
library®  Thå directorù informatioî ió storeä iî thå samå filå aó 
thå   data¬   oò   membeò  files®   Thå  amounô  oæ  spacå tï  bå 
allocateä  tï  thå  directorù  musô bå specifieä bù thå useò wheî  
á  ne÷ librarù ió created¬  buô caî bå changeä wheî thå filå   ió 
reorganized® Thå sizå oæ eacè directorù entrù ió 3² bytes¬  whicè  
meanó  eacè  fouò  directorù entrieó takå uğ onå sectoò   oæ  thå 
librarù file®  Currentlù onlù 1¶ byteó oæ eacè entrù  arå   used¬  
witè  1¶  byteó  beinç  reserveä foò uså  witè  possiblå   futurå 
enhancements®  Thå directorù itselæ useó onå entrù  foò   controì  
information¬  sï  thå numbeò oæ directorù sectoró  needeä  foò  á 
librarù oæ í memberó ió (í « 1© ¯ 4¬ roundeä uğ tï thå nexô wholå 
number.

     Thå   useò  neeä noô bå concerneä witè  thió  discussioî  aó 
directorù   sizå   ió calculateä bù thå  program®  Alì  directorù 
sizeó   arå   inpuô anä outpuô iî termó oæ  entries¬  eacè  entrù 
beinç á potentiaì membeò file® Thå prograí adjustó directorù sizå 
tï aî integraì numbeò oæ sectors.

     LRUNÚ   ió   á  smalì prograí whicè allowó runninç  á   .COÍ 
(objecô  code© filå membeò directlù froí  anù  library¬   withouô  
havinç   tï   extracô  iô  tï  á  separatå  disë  file®    Iô  ió 
specificallù  intendeä tï bå useä witè á defaulô COMMAND.LBÒ filå 
under ZCPR2 and can be used as an Extended Command Processor.Š
     LDIRÚ ió á prograí whicè allowó thå useò tï displaù á sorteä 
directorù oæ thå fileó iî á defaulô COMMAND.LBÒ file®   Simplå iî 
nature¬  LDIRÚ  giveó  thå useò thå abilitù tï selecô  groupó  oæ 
fileó viá wilä cardó anä displaù á sorteä listinç whicè  includeó 
individual file sizes.



4.2  Why Use Libraries?

     First¬   á librarù filå usuallù takeó uğ lesó spacå thaî thå 
totaì  oæ  thå individuaì membeò fileó whicè wenô intï  it®   Thå  
reasoî   foò   thió  ió thaô CP/Í allocateó disë spacå  iî  fixeä  
blockó  oò groups¬  typicallù 2ë byteó each® Anù spacå afteò  thå  
lasô   sectoò   oæ  á filå uğ tï thå nexô 2ë  blocë  boundrù   ió 
wasted®  Thå  samå  fileó  iî á librarù uså onlù  thå  numbeò  oæ 
sectoró  theù actuallù need¬  anä thougè thå librarù itselæ   maù  
havå   á  partiallù wasteä blocë aô thå end¬  anä requireó   somå  
spacå  foò  directorù  informatioî  aô  thå beginning¬   thå  neô  
effecô  ió  usuallù  á savinç oæ totaì space®   Thå  besô resultó 
arå seeî wheî manù smalì fileó arå combineä intï onå library.

     Second¬  á librarù filå makeó mosô efficienô uså oæ thå CP/Í 
disë  directory¬  sincå  iô ió treateä aó onlù onå filå  bù  CP/Í 
regardlesó oæ ho÷ manù memberó iô contains.

     Third¬   librarieó   caî   aiä iî transferrinç  packageó  oæ 
softwarå  froí  onå systeí tï anotheò usinç XMODEM® Onlù onå filå  
ió transferred¬  eliminatinç thå neeä tï ruî thå XMODEÍ   ransfeò  
prograí severaì times¬  thå chancå oæ overlookinç á needeä  file¬ 
anä  thå  problemó oæ naminç conflicts¬  (sucè aó READ.MÅ  files© 
amonç unrelateä packages.



4.3  Why Not Use Libraries?

     Therå    arå   somå   verù  gooä  reasonó  foò   noô   usinç 
libraries®   Foò  onå  thing¬  fileó  withiî á  librarù  arå  noô 
availablå  tï  mosô "normal¢ programs®  Iæ á frequentlù  accesseä 
filå ió placeä  iî  á library¬  iô wilì havå tï bå extracteä froí 
thå librarù  tï  itó  free-standinç counterparô beforå iô caî  bå 
useä   bù   á  program®  (.COÍ fileó arå á notablå  exceptioî  tï 
this¬   becauså   oæ   thå  availabilitù  oæ  thå LRUNÚ  command¬ 
covereä later.)


     Librarieó  caî  actuallù  wastå disë space® Wheî á disë filå  
ió erased¬  CP/Í returnó thå spacå formerlù useä bù thå filå   tï  
thå   freå  spacå pooì foò uså bù ne÷ files®  Wheî á membeò  filå  
ió   deleteä   froí  á  librarù  however¬  thå  spacå  previouslù  
occupieä  bù  thå  filå ió noô  useable®  Thå  librarù  musô   bå  
reorganizeä   tï makå thió spacå availablå tï CP/M®   Whilå  thió  
ió  easù  tï  dï witè thå LÕ command¬  iô ió noô automatic¬   anä  
iæ thå situatioî ió ignored¬  largå areaó oæ disë caî bå tieä  uğ 
aó unproductivå "deaä space".



4.4  How to Use the Library Utility LU

     LÕ  haó twï basiã methodó  oæ  operationº  interactive¬  anä 
parameteò  driven®  Uså oæ thå interactivå methoä ió probablù thå  
besô  waù tï geô tï kno÷ thå program¬  becauså thå effecô oæ eacè 
actioî caî bå immediatleù seen.

     Tï  starô aî interactivå librarù maintenancå  session¬  jusô 
typå   LÕ   oî   thå  commanä linå witè nï parameteró  afteò  it®  
Afteò   yoõ   arå  familiaò  witè thå program¬  yoõ  caî  specifù 
multiplå  paramteró  oî thå commanä linå anä LÕ  wilì  worë  witè 
littlå   oò  nï intervention®  Inpuô froí disë files¬  Ã  prograí 
"pipes"¬   anä   thå  XSUÂ facilitù arå alsï supporteä  foò  morå 
advanceä applications.

     Alì   thå   methodó  makå  uså oæ  similaò  syntax®  Commanä 
inpuô   takeó twï formsº  operatoró (sometimeó  calleä  tags¬  oò 
options© anä operands.

     Aî   operatoò   ió   defineä  aó  anù twï  characteò  strinç 
wherå  thå  firsô  characteò ió á minuó sign®  Operatoró telì thå  
prograí whaô tï do® Valiä operatoró arå -a¬ -d¬ -e¬ -l¬ -o¬ anä -
r®  Anythinç elså witè á similaò forí ió aî operatoò too¬  buô aî 
invaliä one.

     Operandó  arå  everythinç  else® Normally¬ operandó arå filå 
nameó whicè yoõ wanô tï adä to¬  deletå from¬  oò extracô froí  á  
librarù  file¬   oò arå nameó oæ librarù fileó tï bå opened® Theù 
maù contaiî thå characteró ª oò ¿  iî whicè caså theù arå  calleä 
ambiguouó operands® Somå valiä operandó are:

 foo.bar       b:test.fil     z         *.*       comm?nd

     Tï  refeò tï á filå nameä "-z¢ thå operanä woulä havå tï  bå  
entereä  aó  "-z.¢ witè thå period¬  sincå otherwiså iô woulä  bå 
mistakeî aó aî invaliä operator.

     Whaô   actioî   ió takeî upoî thå filå  dependó  upoî  whicè 
operatoò   mosô   recentlù  precedeä  it®   Iæ  nï  operatoò  waó 
entered¬   oò  aî invaliä one¬ oò onå thaô takeó nï operands¬ thå 
operanä wilì bå ignored.
Š     Wheî runninç interactively¬  LÕ promptó foò eacè operanä anä  
operator¬   onå peò inpuô line®  Multiplå inputó peò linå arå noô 
alloweä usinç thå interactivå method.

     Thå   prompô   yoõ   wilì  seå  ió thå namå oæ  thå  currenô 
operatoò   followeä   bù  á  ">¢ character¬  foò  examplå  "-E>"®  
Thió   indicateó  thaô thå -å operatoò ió iî effect¬  anä  iæ  aî 
operanä   ió   entereä iô wilì bå interpreteä aó thå  namå  oæ  á 
membeò   filå   tï  bå  Extracteä  froí  thå  library®  Wheî  thå 
prograí   firsô  startó up¬  thå prompô ió "-?>¢ whicè  meanó  nï 
operatoò   ió   currentlù  iî  effect®   Iî thió case¬  thå  onlù 
valiä inpuô ió aî operator® Anù operanä wilì bå ignored.


4.5  Summary of Operators

     The operators available under LU are:

          -A   Add Files to Library
          -D   Delete Files from Library
          -E   Extract Files from Library
          -L   List Library
          -O   Open a Library
          -R   Reorganize a Library

     Theså   operatoró  arå  discusseä  iî  morå  detaiì  iî  thå 
following frames.

     -á    adä   fileó  tï  library®   -á  causeó thå  prompô  tï 
changå   tï  -A¾ whicè wilì theî accepô aó operandó thå nameó  oæ  
fileó   tï  bå  addeä tï thå opeî library®  (Iæ nï  librarù  namå  
haó   beeî  openeä  witè  thå  -ï operator¬  thå defaulô  librarù  
LIBRARY.LBÒ   ió   alwayó   useä  instead.©   Ambiguouó  operandó  
matcè   alì  disë  fileó whicè qualifù accordinç tï normaì   CP/Í  
wild-carä  conventions¬   excepô  thoså  witè á filetypå oæ .LBR® 
Expliciô drivå specificatioî oî aî operanä causeó  thaô drivå  tï 
bå searcheä foò thå file(s© insteaä oæ thå currenô drive.

     -ä    deletå  fileó froí library®  -ä causeó thå  prompô  tï 
changå  tï  -D¾  whicè  acceptó nameó oæ fileó tï bå deleteä froí  
thå   opeî   library®   Ambiguouó  nameó matcè alì  membeò  fileó  
whicè   qualify®   Drivå specificationó oî operandó arå  ignored¬   
sincå   thå  librarù  memberó  arå  obviouslù  oî whicheveò drivå 
containó thå opeî library.

     -å    extracô  fileó  froí library®  -å causeó thå prompô tï 
changå tï -E¾ whicè acceptó nameó oæ librarù membeò fileó tï   bå   
extracteä   tï  normaì  free-standinç   CP/Í   files®   Ambiguouó  
nameó  matcè alì membeò fileó whicè qualify®  Drivå specificatioî  
oî  á  membeò  namå causeó thå outpuô filå tï bå  placeä  oî  thå 
specifieä  drivå ratheò thaî thå currenô  drive®   Anù   existinç  
filå   witè   thå  samå namå wilì bå overwritteî unlesó   iô   ió 
protecteä bù virtuå oæ itó Read/Onlù flaç biô beinç set.


     -ì   lisô  currenô librarù map®  -ì causeó thå directorù  oæ  
thå   currenô  librarù  tï  bå listeä oî thå console®  Thå membeò  
nameó   arå  displayed¬   alonç  witè  theiò index¬  oò  startinç  
positioî   withiî   thå  library¬   anä theiò  sizå  iî  sectors®  
Also¬  informatioî  ió displayeä abouô thå numbeò oæ sectoró   iî  
thå  library¬  anä  ho÷  mucè space¬ ió useä oò unuseä  (wasted)®  
Informatioî   ió   alsï displayeä abouô thå numbeò oæ entrieó  iî 
thå directory¬  anä ho÷ manù arå active¬  deleted¬   oò  freå foò 
use®  Thió helpó determinå whetheò thå librarù  needó  tï  bå re-
organizeä  tï  freå  unuseä  spacå  anä  deleteä   entries®   Thå  
operatoò   -ì  expectó  nï  operands¬   sï  afteò   thå  lisô  ió 
displayed¬  thå  prompô changeó bacë tï -?¾ foò entrù oæ  anotheò 
operator.

     -ï   opeî  á library®  -ï causeó thå prompô tï changå tï -O¾  
whicè  acceptó  thå namå oæ á librarù filå tï bå openeä foò   uså  
witè  subsequenô  operators® Iæ anotheò librarù ió alreadù  open¬  
iô   ió closeä first®  Iæ thå ne÷ librarù doeó noô  exist¬  iô ió 
createä  witè  aî  emptù directory®  Ambiguouó  nameó   arå   noô 
allowed®  Drivå specificatioî ió allowed® Thå filå  typå  maù  bå 
specified¬  buô  defaultó tï .LBÒ whicè ió stronglù suggesteä  aó 
thå filå typå foò alì librarù files.

     Yoõ   wilì   recalì thaô fileó oæ typå  -á  (add©  operator®  
Thió   preventó   librarieó   froí  beinç accidentallù  addeä  tï 
otheò   libraries¬   oò  tï themselves»  á situatioî  noô  unlikå 
tryinç   tï   drivå  á  trucë uğ itó owî tailpipe®  Iæ  foò  somå 
reasoî  yoõ wanô tï adä onå librarù tï another¬  bå mù guest¬ buô  
yoõ   wilì   havå   tï   specifù   thå   namå   withouô  ª  oò  ¿ 
characteró wheî addinç it.

     -ò    reorganizå   library®   -ò causeó thå  currentlù  opeî 
librarù  tï  bå  reorganized® First¬ thå directorù ió sorteä intï  
alphabeticaì  order¬  anä  theî alì activå memberó arå copieä  tï  
á   worë   librarù   whicè ió openeä oî thå  currenô  drive¬  noô 
necessarilù thå drivå containinç thå olä library®  Thå  useò  maù 
specifù  á differenô numbeò oæ entrieó foò thå worë  librarù   iæ  
iô  ió  necessarù  tï  expanä  oò  compresó  thå  directory®  Thå 
directorù  wilì  alwayó bå madå largå enougè tï contaiî  alì  thå 
activå  memberó  oæ thå olä library¬  sï á sizå oæ   ±   maù   bå  
specifieä   tï  makå  thå directorù aó smalì  aó  possible®  (Seå 
Specifyinç Directorù Sizeó below.)

     Wheî   reorganizatioî   ió  complete¬   thå olä  librarù  ió 
deleteä  anä  thå worë librarù ió renameä tï thå namå oæ thå  olä   
library®     Nï    backuğ   copù   ió   retained®    Thå    newlù 
reorganizeä   librarù   remainó   opeî  foò uså  witè  subsequenô 
operations.

     Wheneveò  thå prograí ió promptinç foò aî  operand¬  anotheò 
operatoò   maù  bå  entereä insteaä tï changå thå statuó  oæ  thå 
prompt®  Tï enä aî interactivå session¬ enteò á blanë linå aô thå 
prompt.

                    SPECIFYING DIRECTORY SIZE

     Wheneveò  aî  olä librarù ió opened¬  thå directorù sizå  ió 
displayeä aó follows:

 Old library LIBRARY.LBR has 32 entries, 5 free.

     Thió   meanó  thaô  µ morå memberó maù bå addeä  beforå  thå 
directorù   becomeó  full®   Wheî  thå  directorù   ió  full¬  -á 
becomeó   aî   invaliä  operator¬   anä  thå  librarù   musô   bå 
reorganizeä tï adä anù morå members.

     Wheî   á librarù ió createä foò thå firsô time¬  thå useò ió 
prompteä likå this:

 New library COMMAND.LBR. Allow how many entries?_

     Anù numbeò froí ± tï 6553µ ió valid®  Thå actuaì maximuí  ió  
determineä  bù thå amounô oæ freå memorù availablå oî thå  systeí 
iî  use®  Directorù  sizå  wilì bå roundeä uğ tï thå  nexô  wholå  
sectoò  necessarù  tï  contaiî  thå numbeò oæ entrieó  requested®  
Thió   numbeò   wilì   remaiî  iî  effecô untiì  thå  librarù  ió 
reorganized® Sincå thå directorù itselæ countó aó aî  entry¬  onå 
entrù  ió  addeä  tï  whateveò ió entereä beforå  thå   sizå   ió  
calculated®   Thereforå  jusô enteò thå maximuí numbeò oæ  membeò 
fileó yoõ wanô thå librarù tï bå capablå oæ holding.

     Thå   maximuí numbeò oæ membeò fileó ió alsï constraineä  bù  
thå   amounô   oæ   availablå   disë  space®  Iæ  durinç  aî  adä 
operatioî  thå disë spacå runó out¬  thå namå ió noô addeä tï thå  
directory®  Iæ á multiplå adä ió iî progress¬ duå tï aî ambiguouó  
operand¬  thå  remaininç  qualifyinç fileó arå  stilì  addeä   iæ 
possible® Iæ anù oæ theí ió smalì enougè tï fiô iî thå  remaininç  
disë  space¬  iô wilì bå added®  Iæ anù sectoró werå  writteî  bù  
aî   adä  attempt¬  anä theî neveò  utilized¬  theù   remaiî   aó  
unuseä  sectors¬ anä thå librarù shoulä bå reorganized.




4.6  LU Command Line Forms

     Alì  oæ thå informatioî needeä foò á maintenancå ruî maù  bå 
specifieä  oî  thå commanä line®  Thå operatoró anä operandó  arå  
entered¬  separateä  bù spaces¬  afteò thå LÕ  command¬  anä  thå 
operationó  wilì takå placå withouô consolå intervention¬  excepô  
iî   thå  caså  wherå  thå  directorù  sizå foò á ne÷ librarù  ió 
requested® Thå syntaø is:

 LU <opr> [<opd> [<opd> ...]] [<opr> [<opd> ...]...

 where square brackets indicate optional parameters, and:
     <opr> is any operator.
     <opd> is any operand.
     ...   indicates  that the preceding parameter may occur
several times.

     Anù   nameó   occurrinç  prioò  tï thå  firsô  operator¬  oò 
followinç   aî   operatoò  whicè doeó noô  expecô  operands¬  arå 
ignored.



                     Advanced Features of LU

     Inpuô   froí  BDÓ Ã "pipes¢ oò ordinarù sequentiaì fileó  ió  
alsï   possible®  Thå filenamå ió specifieä oî thå  commanä  linå  
precedeä  bù á "<¢ characteò anä nï interveninç blank®  Example:

 LU <CONSOL.DUP
     readó thå contentó oæ thå filå CONSOL.DUĞ anä useó eacè linå  
oæ   thå   filå  aó  iæ  iô haä beeî typeä aô thå normaì  consolå   
bù  thå  interactivå  method®   Iî  thió  case¬  nï operatoró  oò  
operandó    maù   bå  present®   Consolå  outpuô  maù  alsï    bå  
redirecteä  bù  specifyinç  aî  outpuô filå oî thå commanä   linå  
afteò   thå  characteò  ">"®   Thió  applieó tï parameteò  driveî 
aó welì aó interactivå (includinç "piped"© input® Examples:

 LU -O SPECIAL -A ZOT.COM >LOGFILE.OUT
     woulä  adä  thå filå zot.coí tï thå librarù special.lbò  anä  
writå   thå  consolå outpuô tï á filå  calleä  logfile.out®   thå  
locatioî  oæ  thå  outpuô namå oî thå linå doeó  noô  matteò  anä  
excepô   foò turninç oî redirecteä output¬  iô ió ignoreä bù  alì 
operators.

 LU <BATCH.IN >B:RECORD.DOC
     woulä   takå interactivå commandó froí thå filå batch.iî anä  
writå  consolå  outpuô  tï  á filå calleä record.doã oî drivå B.

     Normally¬  consolå  filå  outpuô  ió alsï echoeä oî thå reaì  
console¬   excepô  wheî inpuô ió alsï redirected¬ aó iî thå  lasô 
example® Tï forcå visiblå consolå outpuô wheî botè aî  inpuô  anä  
outpuô   filå   arå  used¬   thå  ">¢  characteò  precedinç   thå  
outpuô  filå  namå  maù  bå changeä tï á "+¢ instead:Š
LU +RECORD.DOC <BATCH.IN
     woulä   havå   thå   samå  effecô aó thå  previouó  example¬ 
excepô   thaô   messagå  outpuô  woulä  alsï bå  visiblå  oî  thå 
console.



4.7  CAUTIONS

    Thå   importancå   oæ   keepinç  backuğ  copieó oæ  alì  disë 
files¬   anä  especiallù libraries¬ cannoô bå overemphasized®  Bù  
usinç  librarù files¬ thå useò ió exposeä tï thå dreadeä all-the-
eggs-in-one-baskeô  syndrome®   Thaô is¬ iæ somethinç happenó  tï 
thå librarù file¬  particularlù thå directory¬ iô maù  bå  beyonä  
thå   capabilitieó  oæ eveî á CP/Í wizarä tï restorå  thå  membeò 
files® Thå situatioî ió madå particularlù stickù bù thå facô thaô 
thå  thå directorù musô bå updateä iî placå aó memberó arå  addeä 
oò deleted.

     Precautionó  havå beeî takeî tï minimizå thió risk®  Foò onå  
thing¬   thå   directorù  ió  reaä  intï  memorù wheî thå librarù  
ió  firsô  opened¬  anä  ió onlù writteî bacë iæ iô differó  froí  
thå  copù  oî  thå  disë  wheî thå librarù ió closed®  Operationó  
whicè  changå  thå directorù areº  adds¬ deletes¬  anä  thå  sorô  
operatioî   whicè  ió  donå  beforå reorganization®    Iæ    onlù   
extractó    (oò    LRUNZ   prograí  executions©   arå  done¬   thå 
directorù  ió  neveò rewritten¬  anä thå .LBÒ filå maù  bå  writå 
protecteä iæ desired.

     Foò   anotheò   thing¬   thå  entirå  emptù   directorù   ió 
allocateä   anä   writteî  tï disë wheî á ne÷  librarù  ió  firsô 
created®  Thió  insureó thaô therå wilì alwayó bå enougè spacå oî 
disë  foò thå numbeò oæ directorù entrieó requesteä aô  thå  timå  
oæ   creation®   Thå  disë spacå maù ruî ouô whilå  addinç  fileó 
later¬ buô therå wilì alwayó bå enougè rooí oî disë tï updatå thå 
directorù oncå iô ió successfullù created.

     Thå   facô  thaô  onlù thå memorù copù oæ thå  directorù  ió 
modifieä  untiì thå filå ió closeä maù comå iî verù handù iæ  yoõ  
mistakenlù   deletå   á filå anä recognizå iô  righô  away®   Foò  
example¬  supposå  yoõ  makå  thå mistakå oæ typinç *.ª afteò thå 
-D¾ prompt.

     Briefly¬   youò  hearô sinks¬  aó thå "Deleting:¢ messagå ió  
displayeä   anä  alì  thå membeò nameó ziğ intï oblivion®   Don'ô  
panic®  Onlù thå memorù copù oæ thå directorù haó beeî  modified®  
Wheî   thå   -D¾ prompô returns¬  dï noô  hiô  RETURN®   Instead¬  
aborô  thå prograí witè Control-C®  Thió wilì canceì thå  prograí 
withouô  updatinç  thå directory¬  anä thå originaì memberó  wilì 
stilì bå present.


     Herå  ió  anotheò  caution®  Sincå thå entirå directorù (buô 
noô  membeò  sectors©  musô fiô iî memorù foò  á  librarù  tï  bå 
successfullù opened¬ iô ió possiblå thaô á hugå directorù createä  
oî  á youò systeí wilì bå toï largå tï fiô iî memorù iæ  reaä  oî 
anotheò  systeí  wilì lesó memory®  Thió shoulä noô bå á  probleí 
witè á librarù oæ undeò á hundreä entries.

     Tï  givå  yoõ aî ideá oæ ho÷ mucè elbowrooí yoõ havå tï worë 
with¬  LÕ displayó thå highesô memorù locatioî useä eacè timå  iô 
terminates®  Thió  wilì varù dependinç oî thå  largesô  directorù  
useä  durinç  operation®   Iô doeó noô includå thå stack¬   whicè  
growó   dowî  froí higè memory¬  anä ió alloweä abouô  á thousanä 
byteó oæ spacå foò subroutinå linkageó anä temporarù worë areas.



4.8  LRUNZ Command

     Thå   LRUNÚ   commanä waó createä foò thoså oæ uó  whï  havå 
lotó   oæ  commanä fileó wå likå tï keeğ oî linå  alì  thå  time®  
Whaô usuallù happenó ió thaô somå nicå littlå .COÍ fileó arå verù  
smalì   programs¬  buô havinç á loô oæ theí oî disë eató uğ  filå  
spacå   aô  aî  alarminç ratå duå tï thå fixeä CP/Í blocë   size®  
Puô  theí alì intï á librarù calleä COMMAND.LBÒ usinç   LU®   Yoõ 
caî theî ruî anù .COÍ filå directlù froí thå librarù bù saying:

 LRUNZ <followed by normal command line just like always>

     LRUNÚ ió deriveä froí Gary'ó LRUN®  Stilì basicallù thå samå 
program¬  LRUNÚ  addó ZCPR2-specifiã features¬  iî particulaò thå 
abilitù tï searcè foò thå LBÒ filå alonç thå Externaì  Path®   Iî 
thió  way¬  LRUNÚ  caî bå useä aó aî Extendeä Commanä  Processor¬ 
and¬  wheî invoked¬  wilì searcè foò COMMAND.LBÒ (oò such©  alonç 
thå  patè anä extracô thå COÍ filå froí thå firsô COMMAND.LBÒ  iô 
finds.

     LRUNZ can be invoked by command line of the following forms:

          LRUNZ // or LRUNZ             <-- Print Help
          LRUNZ -lbrfile cmdline        <-- Run command from lbr
          LRUNZ cmdline                 <-- Run command from
                                             default COMMAND.LBR


     The full syntax of LRUNZ is:

 LRUNZ [-<lbrfile>] <commember> [<parameters>]


Where:

     <lbrfile¾   ió   thå  librarù  tï bå  searched®  Thå  squarå 
bracketó   arounä   -<lbrfile¾  indicatå iô ió  optional®  Thå  - 
characteò telló LRUNÚ thaô whaô followó ió á librarù name®  Iô ió 
noô aî actuaì parô oæ thå name® Don'ô leavå á spacå afteò thå  -® 
Iæ  thå  firsô parameteò doesn'ô begiî witè  - theî  thå  defaulô  
librarù  COMMAND.LBÒ  ió  used®   Iæ á drivå speã ió given¬  sucè 
aó B:¬  theî onlù thaô drivå ió searcheä foò thå library®  Iæ  nï  
drivå  speã ió given¬ thå currenô drivå ió searcheä first¬ anä iæ 
nï  librarù oæ thaô namå ió found¬  thå Aº   drivå  ió   searcheä  
beforå  givinç up®  Iæ á name¬  buô nï typå ió entered¬  .LBÒ  ió 
assumed.

     <commember¾   ió   thå  namå oæ thå commanä tï  bå  run®  Nï 
drivå  speã ió useä here®  Thå typå defaultó tï .COÍ anä neeä noô 
bå entered.

     <parameters¾   ió   á  thå normaì (possiblù empty©  lisô  oæ 
parameteró   whicè   thå  .COÍ  filå  expectó  tï   finä  oî  thå 
commanä   linå   wheî  iô  ió  run®  Thió lisô ió parseä  tï  thå 
requireä   filå   controì   blockó anä commanä linå  areá  beforå 
executioî   begins¬   sï   thå  prograí  wilì noô bå  awarå  thaô 
anythinç   cutå   ió  goinç  on®  (Thankó tï Roî Roî  Fowleò  foò 
supplyinç thå codå whicè makeó thió possible.)



                         LRUNZ EXAMPLES

 LRUNZ ED FOO.BAR
     thå   filå   ED.COÍ ió searcheä foò iî  COMMAND.LBÒ  oî  thå 
currenô  drive¬  oò thå Aº drive® Iæ found¬ ED.COÍ ió loadeä froí  
thå  library¬  anä  FOO.BAÒ  ió  passeä  tï  iô  aó  á parameter.

 LRUNZ -C:SPECIAL LU -O COMMAND -A A:*.COM
     thå  filå  LU.COÍ  ió searcheä foò iî SPECIAL.LBÒ oî  thå  Ã 
drive®   Iæ   found¬   LU.COÍ  ió  loaded¬   anä thå stringó  -O¬ 
COMMAND¬ -A¬ anä *.COÍ arå passeä tï iô aó parameters.

 LRUNZ - -ZIP
     thå  filå  -ZIP.COÍ ió searcheä foò iî  COMMAND.LBÒ  oî  thå 
currenô drive¬  oò thå Aº drive® Iæ found¬ -ZIP.COÍ ió loadeä anä  
executeä   witè  á  blanë parameteò list®  Sincå -ZIP.COÍ  beginó  
witè á -¬  thå extrá - followeä bù á spacå waó needeä tï acô aó á 
place-holdeò foò thå librarù name® Comparå with:


 LRUNZ -ZIP
     thå   librarù   -ZIP.LBÒ  ió lookeä for¬  buô  nothinç  elså 
happens¬ becauså nï commanä waó specified.

 LRUNZ
     witè   nï   parameteró  aô  all¬   causeó á screeî  oæ  helğ 
informatioî tï bå displayeä aó á memorù refresher.



4.9  LDIRZ Command

     LDIRÚ printó á sorteä directorù oæ thå defaulô librarù file®  
Thå  printouô  giveó  thå nameó oæ thå selecteä fileó  anä  theiò 
sizes®   Iô ió sorteä alphabeticallù bù filå namå anä type®   Twï 
optionó arå permitted¬  anä theù arå thå namå oæ thå librarù filå 
(caî bå specifieä bù lbrfile¬  iî whicè caså lbrfile.LBÒ wilì  bå 
accessed¬  oò  bù  á fulì filename.typ© anä thå filå  speã  (wilä 
cardó arå OK)®  Formó oæ thå LDIRÚ commanä are:

          LDIRZ //            <-- Print Help
          LDIRZ               <-- All Files
          LDIRZ -lbrfile fn.t <-- Selected Files from Library
          LDIRZ filename.typ  <-- Selected Files



4.10  LRUNZ as an Extended Command Processor Under ZCPR2

     Iæ  thå  readeò caî recall¬  commanä processinç undeò  ZCPR² 
follows these steps:

          1.  ZCPR2 receives a command

          2®   ZCPR²  parseó thå command¬  determineó iæ iô ió  á 
ZCPR2-resident command and executes it if it is

          3®   Iæ  not¬  ZCPR² searcheó alonç thå  command-searcè 
patè  foò á COÍ filå whicè haó thå samå namå aó thå  command»  iæ 
found, it is loaded and executed

          4®   Iæ thió fails¬  ZCPR² maù eitheò searcè alonç  thå 
command-searcè  patè  oò  gï  directlù tï thå rooô  oæ  thå  patè 
lookinç  foò  aî Extendeä Commanä  Processor»  iæ  found¬  iô  ió 
loaded¬  passeä  thå commanä linå aó thå useò presenteä  it¬  anä 
executed; if not, an error message is given

     LRUNÚ  ió  aî  excellenô candidatå foò aî  Extendeä  Commanä 
Processor®   Iæ  thå commanä tï bå executeä ió TEST.COM¬  anä  iô 
takeó  texô  aó aî argument¬  theî thå commanä  linå  tï  executå 
TEST.COM under ZCPR2 would be:

          TEST text
ŠIf  TEST.COÍ  ió iî COMMAND.LBÒ (oò such)¬  thå commanä  linå  tï 
execute the same file using LRUNZ would be:

          LRUNZ TEST text

Thió  latteò commanä ió simulateä bù ZCPR² wheî iô failó tï  finä 
thå  COÍ  file®   Thå  namå  oæ thå  Extendeä  Commanä  Processoò 
(recommended©  ió CMDRUN¬  and¬  bù renaminç LRUNÚ tï  CMDRUÎ  oò 
makinç  á  copù oæ LRUNÚ aó CMDRUN¬  LRUNÚ becomeó  thå  Extendeä 
Commanä Processor.

     LDIRÚ  fitó iî nicelù witè thió scheme®   COMMAND.LBÒ caî bå 
kepô  aô thå ROOÔ alonç witè LRUNÚ anä  LDIRZ¬  anä  LRUNZ¬  wheî 
executed¬   wilì   gï  tï  thå  ROOÔ  lookinç  foò  anä   findinç 
COMMAND.LBR¬  aô  whicè poinô iô extractó thå requireä COÍ  file®  
LDIRZ¬  wheî  executed¬  wilì  searcè  alonç  thå  patè  foò  thå 
COMMAND.LBÒ file¬ and¬ hopefully¬ finä iô aô thå ROOÔ anä extracô 
the information (file names) requested by the user.

     Botè  LRUNÚ anä LDIRÚ caî bå installeä bù GENINÓ anä bå  seô 
tï  looë  foò thå samå COMMAND.LBÒ filå aó welì aó bå tolä  wherå 
the path they are to follow is located.

.fo Section 5 - Menu                                   Page   #

5.0  Menu

5.1  Overview of MENU

     MENÕ  ió thå ZCPR² Menu-Orienteä Commanä  Preprocessor®   Iô 
actó  aó  á front-enä tï ZCPR2¬  providinç á  menu-orienteä  useò 
interfacå  tï  ZCPR2®   Itó  functioî caî bå representeä  bù  thå 
following diagram:
                    ------    ------    ------    ------
                    |M   |    |Z   |    |B   |    |P   |
     User           | E  |    | C  |    | D  |    | g  |
     Menu      ---->|  N |--->|  P |--->|  O |--->|  m |
     Command        |   U|    |   R|    |   S|    |   s|
                    |    |    |   2|    |    |    |    |
                    ------    ------    ------    ------

     Thå "Useò Menõ Command¢ ió á singlå characteò thaô thå  useò 
strikeó  whicè instructó MENÕ tï perforí á function®   Oncå  MENÕ 
beginó  processinç  thió function¬  iô buildó á commanä linå  foò 
ZCPR2¬  optionallù  askinç thå useò foò furtheò inpuô (sucè aó  á 
filå  name)¬  anä theî passeó thå commanä linå tï ZCPR²  viá  thå 
Multiplå Commanä Linå Buffer®   ZCPR² theî runó thå commanä line¬ 
and, when completed, returns to MENU.

     Hence¬  iî  á nutshell¬  MENÕ buildó commanä lineó baseä  oî 
simplå  inpuô froí thå user®   Thå useò neeä neveò kno÷ whaô  thå 
actuaì commanä linå is®  Thå commanä linå itselæ ió alwayó oæ thå 
form:

          <command> <optional user input>;MENU <menu options>

     Aó aî example¬ á commanä builô bù MENÕ tï ruî XDIÒ witè useò 
inpuô  foò  á  filå  namå  specification¬  coulä  looë  likå  thå 
following:

          XDIR <user input>;MENU


     Wheî MENÕ ió executed¬ iô lookó foò thå filå MENU.CPÒ iî thå 
currenô  directory®   Iæ  iô findó one¬  iô loadó iô  anä  beginó 
processing.  If it does not find one, it simply exits.

     Thå  MENU.CPÒ  filå  caî  contaiî  uğ tï  25µ  menuó  tï  bå 
processeä  bù MENU®   Thå defaulô conditioî foò MENÕ ió tï  begiî 
processinç  aô  thå  firsô menõ  iî  MENU.CPR¬  buô  optionó  arå 
availablå  tï  selecô  anotheò menu®   Iî  particular¬  thå  Menõ 
Optionó are:

          W    - Wait for User to Strike a Key before beginning
          nn   - Begin Processing at Menu nn


     The full MENU command line is structured as follows:

          MENU [W][nn]

Optionó  arå  encloseä  iî [İ buô musô bå  placeä  iî  thå  ordeò 
specified, i.e., W, if present, must be first.

     Iæ thå Waiô Optioî ió used¬  iô ió alwayó first®  Thå numbeò 
followó Waiô immediately¬  anä therå arå nï spaceó betweeî  themº          

          MENÕ ×              <-- Waiô anä Starô aô Firsô Menu
          MENU W4             <-- Wait and Start at 4th Menu
          MENU 4              <-- Start at 4th Menu

     Thå useò anä menõ programmeò neeä noô bå concerneä witè thió 
mosô oæ thå time®  Menuó shoulä bå seô uğ tï starô witè thå firsô 
menõ bù default¬  sï thaô onlù thå commanä "MENU¢ ió necessarù tï 
invokå  thå desireä menu®   Thå optionó describeä abovå arå  useä 
primarilù  bù MENÕ itselæ wheî iô buildó thå commanä linå sï thaô 
thå  useò wilì returî witè aî optionaì waiô anä tï thå menõ  thaô 
hå  jusô  camå from®   Hence¬  iæ thå useò waó iî thå  4tè  menu¬ 
selecteä  thå Ø commanä (foò XDIR)¬  anä thå Menõ Programmeò  haä 
seô uğ thå XDIÒ commanä tï waiô oî returî sï thå useò coulä  takå 
hió  timå  anä  looë aô thå directorù display¬  theî  MENÕ  woulä 
appenä  thå commanä "MENÕ W4¢ tï thå enä oæ thå commanä  linå  iô 
builds.

     MENÕ  itselæ  ió á COÍ file¬  likå anù otheò  prograí  undeò 
ZCPR2®  Unlikå mosô otheò programs¬ however¬ iô generateó commanä 
lineó  tï bå executeä bù ZCPR² anä appendó á MENÕ commanä tï  thå 
enä oæ eacè oæ thå commanä lineó iô generateó sï thaô ZCPR²  wilì 
return to MENU when finished.  In this way a loop is set up:

                    -->--+->- MENU ->- ZCPR2 ->-+
                         ^                      v
                         |                      |
                         +-<- Command Line -<---+

     Onlù  MENÕ  itselæ caî terminatå thió  loop®   Iæ  thå  MENÕ 
programmeò  wishes¬  hå caî seô uğ thå MENU.CPÒ filå sï thaô thió 
looğ  wilì neveò bå exited¬  oò hå caî seô uğ thå filå  tï  allo÷ 
anyonå  tï exiô aô anù timå oò jusô á speciaì persoî whï knowó  á 
passworä  tï  exiô  wheî  hå  wisheó  to®   Therå  ió  á  loô  oæ 
flexibilitù  designeä intï thå system¬  anä iô wilì bå  discusseä 
later in the section on programming MENU.CPR files.

     Iî  á  nutshell¬  then¬  á  MENU.CPÒ filå caî bå seô  uğ  tï 
executå anù ZCPR² commanä oò sequencå oæ commands®   Thå MENU.CPÒ 
filå caî alsï bå seô uğ tï noô allo÷ thå useò tï leavå  MENU¬  tï 
allo÷  hií tï leavå MENÕ aô will¬  oò tï allo÷ hií tï leavå  MENÕ 
onlù iæ hå knowó á password.


     Thió  HELĞ filå ió divideä intï twï basiã parts®   Thå  infï 
sectionó  oî  "Usinç  MENU¢ anä "Summarù oæ  MENÕ  Commands¢  arå 
designeä  tï  bå  reaä bù á persoî wantinç tï uså  MENÕ  buô  noô 
wantinç  tï  learî ho÷ MENÕ workó oò ho÷ tï  prograí  it®   Theså 
sectionó  describå ho÷ tï movå froí onå menõ tï another¬  ho÷  tï 
issuå  MENÕ  commands¬  anä ho÷ tï leavå MENÕ iæ  thå  optioî  ió 
presenteä tï him.

     Thå   otheò   sectionó  oæ  thió  HELĞ  filå  describå   thå 
programminç  aspectó  oæ MENÕ anä arå intendeä tï bå useä  aó  aî 
onlinå  referencå  foò thå MENÕ  programmer®   Thå  MENÕ  commanä 
programminç  summarù  ió especiallù usefuì iî thaô iô provideó  á 
summarù  oæ thå commandó whicè thå MENÕ programmeò maù  issuå  tï 
MENÕ withiî á MENU.CPR.

                           Using MENU

     When you first invoke MENU, one of three things will happen:

          1©  Á  MENÕ  wilì appeaò anä bå pageä uğ  tï  filì  thå 
               screen» á commanä prompô wilì appeaò aô thå bottoí 
               oæ thå menu

          2©  Á MENÕ wilì appeaò anä noô bå pageä uğ tï filì  thå 
               screen» á commanä prompô wilì appeaò aô thå bottoí 
               oæ thå menu

          3©  Á commanä prompô wilì appeaò witè nï menõ (thió  ió 
               called the Expert Mode)

     Iæ  aô anù timå youò Menõ Displaù ió garbleä oò yoõ wanô  tï 
seå thå currenô Menõ (aó sometimeó happenó wheî yoõ arå iî Experô 
Mode)¬ jusô strikå thå RETURÎ key®  Thå RETURÎ keù refresheó youò 
menu at all times.

     Thå  prompô whicè appearó aô thå bottoí oæ youò Menõ displaù 
has the following general form:

Command (<CR>=Menu,^C=ZCPR2,*=1st Menu,<=Prev Menu,>=Next Menu) -

     Aó É mentioneä iî thå introduction¬  therå caî bå uğ tï  25µ 
menuó  iî onå MENU.CPÒ file®   Thå MENÕ commanä prompô varieó  tï 
reflecô this®  Foò instance¬ iæ onlù onå Menõ waó presenô anä yoõ 
werå noô giveî thå optioî tï aborô ouô oæ MENÕ tï ZCPR2¬ theî thå 
Menõ Commanä prompô woulä takå itó simplesô form¬ lookinç like:

Command (<CR>=Menu) -

     Yoõ  caî  strikå thå RETURÎ keù aô thió timå tï refresè  thå 
Menõ  Displaù oò yoõ caî strikå thå characteò oæ á  Menõ  Option®  
Theså  arå youò onlù choices¬  anä strikinç á characteò whicè  ió 
noô  thå  RETURÎ  keù  oò á menõ optioî resultó  iî  thå  messagå 
"Invalid Command" being displayed.

     Iæ  thå  MENU.CPÒ programmeò gavå yoõ thå optioî tï exiô  tï 
ZCPR² anä therå ió onlù onå Menõ iî thå MENU.CPÒ file¬  theî youò 
commanä linå wilì looë likå this:

Command (<CR>=Menu,^C=ZCPR2) -

     Yoõ  no÷ havå thå additionaì optioî oæ abortinç tï ZCPR²  bù 
strikinç Control-Ã (holä dowî oî thå Control¬  oò CTRL¬  keù  anä 
strikå  thå  letteò C)®   Thió wilì returî yoõ tï ZCPR² anä  exiô 
MENU¬  leavinç yoõ witè thå abilitù tï issuå anù availablå  ZCPR² 
command.

     Onå brieæ notå oî optioî letteró beforå goinç on®  Iæ onå oæ 
youò optionó ió á letteò iî thå rangå froí Á tï Z¬  theî caså  ió 
noô  significant¬  anä  yoõ  caî invokå thå  optioî  A¬  say¬  bù 
striking an upper- or lower-case A.

     Iæ  therå ió morå thaî onå menõ iî youò MENU.CPÒ  file¬  thå 
commanä  linå optionó becomå slightlù morå complex¬  buô theù arå 
stilì quitå easù tï follow.

     Iî thå followinç examples¬  É aí assuminç thaô thå optioî tï 
exiô tï ZCPR² ió off¬ sï thå "^C=ZCPR2¢ optioî wilì NOÔ appear.

     Iæ yoõ arå aô thå firsô menõ iî thå file¬  youò commanä linå 
wilì looë likå thå following:

Command (<CR>=Menu,>=Next Menu) -

     Tï advancå tï thå nexô menu¬  yoõ caî strikå thå ">¢ oò  thå 
".¢ character®   Oî mosô keyboards¬  ">¢ ió thå shifô oæ thå "."¬ 
sï  MENÕ allowó yoõ tï movå easilù withouô havinç tï worrù  abouô 
shifting the keyboard all the time.

     Iæ  yoõ arå aô thå lasô menõ iî thå file¬  youò commanä linå 
will look like the following:

Command (<CR>=Menu,*=1st Menu,<=Prev Menu) -

     Thió allowó yoõ tï strikå thå "*¢ characteò tï jumğ bacë  tï 
thå  firsô  menõ iî youò MENU.CPÒ file®   Iæ "<¢ oò ",¢ ió  stucë 
("<¢ ió usuallù thå shifô oæ thå ",")¬  theî yoõ wilì bacë uğ onå 
menu to the previous menu in the file.

     Iæ  yoõ  arå somewherå iî thå middlå oæ thå  MENU.CPÒ  file¬ 
youò commanä linå will¬ aó onå woulä expect¬ looë likå this:

Command (<CR>=Menu,*=1st Menu,<=Prev Menu,>=Next Menu) -

     Again¬  "*¢  wilì gï directlù tï thå firsô menu¬  "<¢ oò ",¢ 
wilì gï tï thå previouó menu¬  anä ">¢ oò ".¢ wilì gï tï thå nexô 
menu.  Striking the RETURN key will refresh the menu display.


     Onå  lasô  optioî yoõ havå undeò MENÕ involveó accesó  tï  á 
Systeí Menu®   Thió menõ ió speciaì iî thaô therå ió onlù onå waù 
to get to it -- via the "$" command.

     Thå Systeí Menõ ió intendeä tï givå privelegeä useró  accesó 
tï  speciaì commandó thaô thå resô oæ thå useró can'ô run®   Iæ á 
Systeí  Menõ ió available¬  MENÕ wilì responä tï thå "$¢  commanä 
with the prompt:

          Pass?

     Yoõ arå giveî onå chancå tï typå iî thå correcô passworä  tï 
enteò thå Systeí Menu®   Iæ yoõ arå wrong¬ thå messagå "Pasó Err¢ 
wilì  appeaò anä yoõ wilì bå returneä tï thå menõ yoõ camå  from®  
Iæ yoõ arå correct¬  yoõ wilì enteò thå Systeí Menu®  Physically¬ 
thå  Systeí  Menõ ió alwayó thå lasô menõ iî thå  file¬  anä  itó 
command prompt is:

Command (<CR>=Menu,*=1st Menu,<=Prev Menu) -

     Iæ yoõ arå aô thå menõ jusô beforå thå Systeí Menu¬  thå ">¢ 
wilì  noô  functioî  tï allo÷ yoõ tï enteò  it¬  eveî  thï  therå 
technicallù ió á "Nexô Menu"®  Thå ">¢ optioî iî thå commanä linå 
wilì  noô appear®   Aó É stateä before¬  thå onlù waù tï enteò  á 
System Menu is thru the "$" command.

     So¬ iî summary¬ movinç abouô withiî MENÕ ió quitå easy®  "*¢ 
moveó yoõ tï thå firsô menu¬ "<¢ tï thå previouó menu¬ ">¢ tï thå 
nexô menu¬ anä "$¢ tï thå Systeí Menu.



5.2  Summary of MENU Commands

     The full Menu Command Line looks like the following:

Command (<CR>=Menu,^C=ZCPR2,*=1st Menu,<=Prev Menu,>=Last Menu) -

     The Menu Commands are:

          Command   Function

          <CR>      Refresh Menu Display (RETURN Key)
          ^C        Exit to ZCPR2 (Control-C)
          *         Jump to the First Menu
          < or ,    Jump to the Previous Menu
          > or .    Jump to the Next Menu
          $         Jump to the System Menu (Password Required)
          other     Menu Option or Invalid Command; letters are
                         automatically capitalized, so a=A


5.3  Programming MENU.CPR Files

     Thå MENU.CPÒ filå ió simplù á texô filå whicè maù bå createä 
witè  anù conventionaì CP/Í  editor¬  includinç  WordStar®   MENÕ 
ignoreó  thå Mosô Significanô Biô oæ alì bytes¬  sï editoró  likå 
WordStar¬ whicè occasionallù seô thió bit¬ caî bå used.

     Alì  MENU.CPÒ  fileó havå thå samå generaì  structure®   Thå 
firsô  linå ió eitheò á globaì optioî linå oò thå beginninç oæ  á 
menõ  display®   Iæ  á globaì optioî line¬  iô  beginó  witè  thå 
characteò  "-"¬  anä  thió characteò ió immediatelù  followeä  bù 
globaì  optioî characters®   Thå globaì optioî line¬  theî  lookó 
likå this:

-options


     Afteò thå globaì optioî line¬  iæ any¬ comeó thå firsô menu®  
Each menu is structured as follows:

                         #options
                              <Text of Menu Display>
                         #
                         menu commands

     The following are two sample Menu File structures:

               -options                 #options
               #options                      <Text>
                    <Text>              #
               #                        commands
               commands                 ##
               #options
                    <Text>
               #
               commands
               ##


     Therå arå onlù fivå optioî characters®   Iî usinç them¬ caså 
is not significant.  These option characters are:

          Option    Function
             C      Display Command Line to User
             D      Display Menu to User
             P      Page Out Menu Display
             X      Allow User to Exit to CP/M

     Thå  Ã optioî displayó thå commanä linå builô bù MENÕ tï thå 
user®   Thió optioî ió primarilù intendeä foò debugginç purposes¬ 
tï allo÷ thå programmeò tï seå whaô commandó arå beinç built®  Iô 
ió instructivå tï thå user¬ however¬ anä maù bå employeä foò thaô 
purpose as well.
Š     Thå Ä optioî displayó thå menõ tï thå user®   Iæ thå displaù 
functioî  ió  noô  turneä on¬  wå arå iî  Experô  Mode¬  anä  thå 
commandó  arå  availablå withouô  á  menõ  display®   RETURN¬  oæ 
course, can be used to invoke the display if necessary.

     Thå  Ğ  optioî pageó ouô thå menõ displaù iæ iô ió  invoked®  
Iæ  thå pagå functioî ió engaged¬  theî thå MENÕ prograí  outputó 
<CRLF¾  combinationó  untiì  2´ lineó havå beeî  printeä  oî  thå 
screen®  Thió ió somewhaô morå attractivå anä eliminateó olä texô 
froí previouó commands¬  allowinç thå useò tï concentratå oî  hió 
currenô seô oæ options®   However¬  iô ió annoyinç iæ thå useò ió 
accessinç thå system¬  say¬ aô 30° bauä viá á diaì up®  Iô ió foò 
thió  reasoî  thaô É gavå thå MENÕ programmeò thå optioî tï  turî 
this option off.

     Finally¬ thå Ø optioî enableó thå facilitù whicè permitó thå 
user to type ^C and return to ZCPR2.

     Wheî MENÕ firsô comeó up¬ alì optionó arå turneä off:

          C is OFF -- no command display to user
          D is OFF -- no menu display to user
          P is OFF -- no menu display paging
          X is OFF -- user cannot exit to CP/M

     Thå globaì optionó line¬  which¬  iæ present¬  ió thå  firsô 
linå  oæ thå file¬  turnó oî theså optionó foò thå courså oæ  thå 
session in general.  That is, if a global options line like

          -DPx

ió useä (notå caså ió insignificant)¬  theî menõ display¬ paging¬ 
anä  exiô tï ZCPR² wilì bå availablå foò alì menus®   Thå  globaì 
options line affects all menus.

     Thå  globaì  optionó  line¬  then¬  turnó oî  thå  indicateä 
optionó foò alì menuó iî general®   However¬ thå samå optionó maù 
bå presenteä oî thå firsô linå oæ eacè menõ immediatelù afteò thå 
"#¢  characteò tï temporarilù complemenô thå currenô  optioî  foò 
onlù thaô menu.

     Iæ aî optioî ió NOÔ includeä iî thå globaì optionó line¬  iô 
ió turneä OFÆ foò alì menuó iî general®  Thå defaultó selecteä bù 
usinç  thå globaì optionó linå arå overriddeî oî á per-menõ basió 
bù thå locaì menõ options.


     Example:

          -dpx
          #x
               This menu is displayed and paged, but no
               exit to ZCPR2 is permitted
          #
          commands
          #dx
               This menu is not displayed and the user may not
               exit to ZCPR2.
          #
          commands
          #c
               Thió menõ ió displayed¬ paged¬ anä thå useò maù
               exit to ZCPR2.  Additionally, the MENU-generated
               commands are printed to the user.
          #
          commands
          ##


     So¬  anù  optioî thaô maù appeaò oî thå globaì optionó  linå 
maù alsï appeaò oî thå optionó linå foò á particulaò  menu®   Thå 
reverse¬  however¬  ió noô true®   Thå menõ optionó linå supportó 
onå  additionaì  option¬  viz®  "$"®   Thió optioî  declareó  thå 
following menu to be a System Menu.

     Iî  programminç á MENU.CPÒ file¬  yoõ MUSÔ placå thå  Systeí 
Menõ aó thå lasô menõ iî thå file®  Tï dï otherwiså ió flaggeä aó 
aî error®  Thå followinç illustrateó á MENU.CPÒ filå containinç á 
Systeí Menu:

          -dp
          #
               Thió menõ ió displayeä anä paged¬ buô thå useò maù
               not exit to ZCPR2.
          #
          commands
          #$x
               This is a System Menu, and it is displayed, paged,
               and the user may exit to ZCPR2.
          ##


     Iæ  á  menõ  ió  á  Systeí  Menu¬  thå  "$¢  characteò  musô 
immediatelù follo÷ thå "#"®  Iî thå caså oæ thå letteò optionó iî 
botè  thå  globaì  anä locaì cases¬  thå ordeò ió  noô  importanô 
("dpx¢ meanó thå samå aó "xpd").

     GENINÓ ió useä tï definå thå passworä useä tï enteò á Systeí 
Menu®   Thió ió thå Privilegeä Useò Passworä iî thå GENINÓ  Menu®  
Notå thaô thió passworä caî bå upper- anä lower-case¬ anä caså ió 
significant.Š
     Thió  informatioî sectioî haó describeä thå structurå oæ thå 
MENU.CPÒ filå anä ho÷ tï seô uğ aó manù menuó aó  desired®   Whaô 
haó  noô  beeî discusseä ió thå naturå oæ thå commandó  followinç 
the menu displays.  This is discussed in the next section.


5.4  MENU.CPR Commands

     Thå  commandó  iî thå MENU.CPÒ filå  follo÷  arå  relativelù 
simplå structure®  Eacè commanä occupieó onlù onå line¬ anä blanë 
lineó  iî thå commanä grouğ arå noô permitted®   Thå commanä linå 
is structured as follows:

          l[o][command]["Prompt]

where:
          l is the single character used to invoke the command
               note that it may be upper- or lower-case
          o is an opening option, which is one of:
               :nn -- go to Menu nn
               !   -- have MENU wait when the command is finished
          command is an optional ZCPR2 command; note that if
               the option is ":nn", then a command here makes no
               sense
          "Prompt is a command to MENU to print a prompt and wait
               for user input to fill out the command line


     Thå  ":nn¢ optioî telló MENÕ tï movå tï á differenô menõ  iî 
the MENU.CPR file.  The first menu is number 1.  Example:

          -dpx
          #
               1st Menu:  A - Goto Menu 2     3 - Goto Menu 3
          #
          a:2
          3:3
          #
                    2nd Menu Command: 3 - Goto Menu 3
          #
          3:3
          #x
                    3rd Menu Command: 2 - Goto Menu 2
          #
          2:2
          ##


     Iî thå firsô menu¬ thå useò maù strike:

          "a¢ oò "A¢ tï gotï Menõ 2
          "3¢ tï gotï Menõ 3
          ">¢  oò  ".¢ tï gotï thå nexô menõ (Menõ 2)
          ^Ã tï gotï ZCPR2

     In the second menu, the user may strike:

          "3" to goto Menu 3
          "*" or "<" or "," to goto Menu 1
          ">" or "." to goto Menu 3
          ^C to goto ZCPR2

     In the third menu, the user may strike:

          "2" or "<" or "," to goto Menu 2
          "*" to goto Menu 1


     Thå  "!¢  optioî  placeó  á "W¢ iî  thå  MENÕ  commanä  linå 
(remembeò  froí before?)®   Thió causeó MENÕ tï pauså anä asë thå 
useò tï "Strikå Anù Key¢ beforå continuing®   Iî thió way¬  iæ  á 
commanä  generateó informatioî tï bå reaä bù thå useò beforå MENÕ 
clearó  hió screen¬  thå "!¢ optioî maù bå useä tï givå thå  useò 
alì thå timå hå wantó tï reaä thió display.

     Thå  "Prompô  suffiø  causeó MENÕ tï accepô á  taiì  tï  thå 
commanä linå iô ió buildinç sï thaô thå useò caî inpuô  argumentó 
for the command.  The Prompt is simply text to prompt the user.

     Examples:

          -dxp
          #
               A - Run XDIR without Pause or Input
               B - Run XDIR and Pause before Returning to MENU
               C - Run XDIR, Allow User Input, and Pause before
                    Returning to MENU
               Z - Run Any ZCPR2 Command and Pause before
                    Returning to MENU

          #
          z!"Enter Command Line --
          axdir
          b!xdir
          c!xdir "Enter Ambiguous File Name --
          ##

     Notå thå Spacå righô beforå thå "Prompô form®  Thió spacå ió 
significanô  tï  keeğ  thå commanä anä useò  inpuô  froí  runninç 
together®  Wå wanô thió "ruî together¢ foò thå Ú command.


     Yoõ  caî  havå  aó  manù commandó  aó  thå  printablå  ASCIÉ 
characteò  seô (withouô lower-caså letteró anä thå  MENÕ  commanä 
characters© wilì allow®   Youò text¬  however¬ foò eacè menõ musô 
bå ablå tï fiô oî á screeî witè thå commanä prompô aô thå bottom®  
Thió typicallù meanó thaô thå texô cannoô exceeä 2² lines.

     MENÕ  fitó iî nicelù tï thå ZCPR² Systeí oæ  programs®   Thå 
informatioî sectioî oî "MENU'ó Relationshiğ tï thå ZCPR²  System¢ 
explainó ho÷ MENÕ anä thå otheò ZCPR² programó worë together.

     É  havå noô discusseä erroò messageó yoõ caî encounteò undeò 
MENÕ iî thió informatioî section®   Thaô comeó lateò iî thå Erroò 
Message section.



5.5  MENU Programming Command Summary

     Eacè MENÕ commanä occupieó onlù onå line¬ anä blanë lineó iî 
thå  commanä  grouğ  arå noô  permitted®   Thå  commanä  linå  ió 
structureä aó follows:

          l[o][command]["Prompt]

where:
          l is the single character used to invoke the command
               note that it may be upper- or lower-case
          o is an opening option, which is one of:
               :nn -- go to Menu nn
               !   -- have MENU wait when the command is finished
          command is an optional ZCPR2 command; note that if
               the option is ":nn", then a command here makes no
               sense
          "Prompt is a command to MENU to print a prompt and wait
               for user input to fill out the command line

     The MENU commands are:

          Command   Function

          :nn       Goto Menu nn, where the first menu is Menu 1
          !         Wait after command line is executed before
                         processing the menu
          "Prompt   Prompt the user for input and accept it

     Thå  followinç ASCIÉ characteró maù NOÔ bå useä aó  commandó 
since they are used elsewhere:

          <SPACE>   #    %    ,    .    <    >    *    <DEL>

          <Any Char Less than Space>


5.6  MENU's Relationship to the ZCPR2 System

     MENU¬  likå mosô oæ thå ZCPR² utilities¬  interactó witè thå 
systeí  aó  á  wholå anä cannoô bå useä witè systemó  otheò  thaî 
ZCPR2®   Iî particular¬  MENÕ requireó thå ZCPR² Multiplå Commanä 
Linå Buffeò facilitù tï bå availablå tï iô anä cannoô ruî withouô 
it®   Iô  chainó  tï  otheò  commandó anä  tï  itselæ  thrõ  thió 
facility.

     MENÕ ió installeä bù GENINS®  GENINÓ ió useä tï instalì MENÕ 
anä seô thå parameteró foò wherå thå Multiplå Commanä Linå Buffeò 
ió locateä anä whaô thå passworä foò enterinç á Systeí Menõ is.

     Also¬  CÄ (Changå Directory© anä STARTUĞ (or¬ SÔ foò CD© caî 
comå intï plaù witè MENU®  Wheî CÄ logó intï tï ne÷ directory¬ iô 
lookó foò thå filå ST.COÍ anä executeó iô iæ therå ió one®  SÔ ió 
simplù  STARTUĞ  renamed¬  anä  STARTUĞ wilì  loaä  thå  Multiplå 
Command Line Buffer with a command line and then terminate.

     Froí  thå poinô oæ vie÷ oæ MENU¬  thå commanä loadeä  bù  SÔ 
coulä bå MENU®  Thå effecô oæ thió ió tï automaticallù enteò MENÕ 
when the user employs CD to enter a given directory.

     Hence¬  bù  usinç  CD¬  á  useò caî enteò  á  directorù  anä 
suddenlù  finä himselæ iî á menõ insteaä oæ aô thå ZCPR²  commanä 
level®   Thió  ió gooä foò applicationó wherå á directorù ió  seô 
asidå  foò á specifiã purposå anä onlù certaiî operationó arå  tï 
bå  performeä  iî  it¬  sucè  aó  cataloginç  diskó  oò  handlinç 
accounts®   Also¬  witè CD'ó passworä facility¬ iæ thió directorù 
ió á Systeí Directory¬  thå useò woulä havå tï givå á passworä tï 
enter it.

     No÷  thaô MENÕ ió runninç foò thå directory¬  á MENÕ commanä 
coulä bå anotheò CÄ tï anotheò directory®   Oò iô coulä simplù bå 
a DU: form.  Example:

          #dp
               A - Enter ZCPR Directory
               B - Enter A0:
          #
          acd zcpr
          ba0:
          #

     Here¬  iæ  Á ió issued¬  theî CÄ wilì movå  intï  ZCPRº  anä 
executå ST.COÍ iæ therå ió onå there®   Iæ Â ió issued¬  thå useò 
ió  loggeä  intï  A0:®   MENÕ ió thå nexô commanä iî  botè  caseó 
(commanä  lineó  arå  "CÄ ZCPR;MENU¢  anä  "A0:;MENU")¬  sï  MENÕ 
automaticallù reinvokeó anä lookó foò MENU.CPR®   Iæ iô findó it¬ 
wå arå iî anotheò MENÕ system¬ and¬ iæ iô doesn't¬ wå arå bacë tï 
ZCPR2 command level.


     Undeò thå Á option¬  iæ CÄ findó ST.COM¬  SÔ wilì  overwritå 
thå resô oæ thå commanä line¬ therebù throwinç awaù thå nexô MENÕ 
command and giving us something totally different to work with.

     Undeò thå Â option¬ wå wilì ruî MENÕ nexô anä simplù exiô iæ 
a MENU.CPR file is not found.



5.7  MENU Error Messages

     Iî  ordeò tï makå MENÕ aó smalì aó possiblå (iô ió undeò  2Ë 
byteó  iî size)¬  É havå reduceä thå erroò messageó tï á minimum®  
Instead¬  MENÕ  provideó á minimuí indicatioî thaô  somethinç  ió 
wrong and aborts.

     Thå prograí MCHECË ió designeä tï telì yoõ morå specificallù 
whaô ió wrong®  MCHECË ió á MENU.CPÒ Syntaø Checker¬ anä iô lookó 
foò  alì  sortó oæ erroò conditionó thaô caî occuò iî á  MENU.CPÒ 
file.  MCHECK is discussed in the next information section.

     MENÕ provideó thå followinç minimaì erroò messages:

          Message             Meaning

          Full                Memory is Full
          Invalid Option      User Command is in Error
          Pass Err            Invalid Password Given
          Str Err             MENU.CPR File Structure Error



5.8  MCHECK -- MENU.CPR Syntax Checker

     MCHECË  shoulä catcè anù erroró madå iî á MENU.CPÒ filå bù á 
programmer®   Iô  ió noô guaranteed¬  buô haó beeî  testeä  quitå 
thoroughly.

     MCHECK accepts command lines of the following forms:

          MCHECK or MCHECK //      <-- Print Internal Help
          MCHECK dir:filename      <-- Check "filename.CPR"
          MCHECK dir:filename.typ  <-- Check "filename.typ"

     Thå  DIRº  prefiø  maù bå useä witè thå filå names®   Iô  ió 
optional®  Aó á DIRº prefix¬ thió acceptó thå DUº forí oò á nameä 
directory.



     MCHECK gives you the "standard" opening error messages:

          Error in Disk or User Number -- Aborting
               DIR: form was not acceptable

          Error in Opening File -- Aborting
               Problem with file

          TPA Overflow -- MENU.CPR File is Too Big -- Aborting
               It could be too big for MENU also (Full error of
                    MENU)

     Iô theî startó processinç thå MENU.CPÒ filå iæ nonå oæ theså 
erroró  occur®   MCHECË printó thå linå numbeò anä erroò  messagå 
foò  eacè erroò encountered®   Iô alsï printó commentó aó  iô  ió 
running along.

     Non-error comments printed by MCHECK include:

          ** Global Options Detected **
               There are global options in the file

          ** Menu Number nnn
               It is beginning the indicated menu

          ** End of Menu Check **
          No Errors Detected -or- nnnnn Errors Detected
               Done and Error Count


     Fatal Errors which cause MCHECK to stop processing are:

          Error -- New Menu Expected, But # NOT Found -- Aborting
               Like it says; it gives a line number to help you
                    find the problem

          Error -- Premature EOF Encountered -- Aborting
               The file did not end with ##


     Non-Fatal Errors for MCHECK (fatal for MENU, tho) are:

          Error -- Invalid Option:
               Invalid option in global or local option line

          Error -- Menu Number Out of Range
               A ":nn" option referenced a number out of range


     Thå  followinç ió á samplå ruî oæ MCHECË oî á gooä  MENU.CPÒ 
file:


B7>mcheck zcpr:menu.cpr
MCHECK  Version 1.1

 Line Comment/Error Message
 ---- ---------------------
    1 ** Global Options Detected **
    2 ** Menu Number   0
   17 ** Menu Number   1
   28 ** Menu Number   2
   39 ** Menu Number   3
   48 ** Menu Number   4
   57 ** End of Menu Check **
        No Errors Detected

.fo Section 6 - File Compare Utilities                 Page   #

6.0  File Compare Utilities

6.1  File Comparison Utilities Under ZCPR2

     Twï  utilitieó  arå  provideä witè ZCPR² tï  comparå  files®  
Both utilities are simple in form to use.  These utilities are:

     COMPARE -- Compares two files by reading one, computing its
                    CRC value, saving its CRC and size, and then
                    reading the other and seeing if they match

     DIFF -- Prints out a difference listing between two files;
                    different bytes encountered at the same
                    relative displacements from the beginning of
                    thå fileó arå printeä iî hexadecimal¬
                    decimal, and ASCII forms


     These commands are invoked by the following forms:

          COMPARE or COMPARE //                   <-- Print Help
          COMPARE dir:file1.typ,dir:file2.typ M   <-- Compare

          DIFF or DIFF //                         <-- Print Help
          DIFF dir:file1.typ,dir:file2.typ M      <-- Compare

     Thå  filå specó musô bå unambiguouó oò aî erroò wilì result®  
Thå DIRº  prefiø ió optional¬  anä maù bå á nameä directorù oò  á 
DU: form.

     Thå "M¢ ió optional¬ and¬ iæ present¬ selectó á Multiplå Ruî 
Modå  iî whicè thå useò ió alloweä tï changå diskó aó hå desires¬ 
á COMPARÅ oò DIFÆ ió done¬  anä theî thå procesó continueó  untiì 
the user aborts it.



6.2  CRC Check Utility Under ZCPR2

     Thå  CRÃ  Checë Utilitù distributeä witè ZCPR² computeó  CRÃ 
valueó  foò  á lisô oæ files®   Iô useó thå samå  CRÃ  polynomiaì 
employeä bù Keitè Peterseî iî hió CRCË program¬  and¬  naturally¬ 
the values come out the same.

     Thå  CRÃ Checë Utilitù computeó thå CRÃ valueó oæ á selecteä 
seô  oæ fileó anä printó ouô thå filå  names¬  theiò  sizes¬  anä 
theiò CRÃ valueó iî hexadecimal®  Á lisô oæ ambiguouó fileó nameó 
maù  bå  provideä  tï CRC¬  anä iô alsï respondó tï á  serieó  oæ 
options.

     The general form of the CRC command is:

          CRC dir:afn1,dir:afn2,... ooo...
Š     Iî  alì  ambiguouó  filå  references¬  thå  DIRº  prefiø  ió 
optional®   Thió prefiø maù bå á nameä directorù oò á  DUº  form®  
The options available under CRC are:


          C - Comment Output; the user is given an opportunity
                    to enter comments for each file

          D - Disk Output; send output to the disk file CRC.CRC
                    as well as to the console

          I - Inspect and approve file before CRC is computed

          P - Printer Output; send output to the printer as
                    well as to the console

     Theså optionó maù bå combineä iî anù manneò desired®   Á CRÃ 
command of the form "CRC" or "CRC //" prints a help message.



6.3  Examples

B7>compare help:lu.hlp,zcpr:lu.hlp
COMPARE  Version 1.4
Source File 1 -- A 16: LU      .HLP
Source File 2 -- A 11: LU      .HLP
** Files are Identical **

B7>compare help.txt,s100.txt
COMPARE  Version 1.4
Source Fie 1 -- B  7: HELP    .TXT
Source File 2 -- B  7: S100    .TXT
** Files are Different **

B7>compare help:lu.hlp,c0:
COMPARE  Version 1.4
Source File 1 -- A 16: LU      .HLP
Source File 2 -- C  0: LU      .HLP
LU      .HLP  File Not Found

B7>compare help:du2.hlp,c0:
COMPARE  Version 1.4
Source File 1 -- A 16: DU2     .HLP
Source File 2 -- C  0: DU2     .HLP
** Files are Identical **

B7>compare help:du2.hlp,c0: m
COMPARE  Version 1.4
Source File 1 -- A 16: DU2     .HLP
Source File 2 -- C  0: DU2     .HLP
  Change Disks if Desired and Type ^C or A to Abort or <RETURN>
               to Continue - 


Source File 1 -- A 16: DU2     .HLP
Source File 2 -- C  0: DU2     .HLP
** Files are Identical **
COMPARE  Version 1.4
Source File 1 -- A 16: DU2     .HLP
Source File 2 -- C  0: DU2     .HLP
  Change Disks if Desired and Type ^C or A to Abort or <RETURN>
          to Continue - 

B7>diff help:du2.hlp,c0:
DIFF  Version 1.6
Source File 1 -- A 16: DU2     .HLP
Source File 2 -- C  0: DU2     .HLP
NO Differences Noted in Files

B7>save 1 test.bin
B7>zsid test.bin
ZSID VERS 1.4
NEXT  PC  END
0200 0100 A2FF
#s100
0100 C3 0
0101 70 1
0102 01 2
0103 FF .
#s1f0
01F0 09 0
01F1 3C 0
01F2 3D 0
01F3 32 .
#^C
B7>save 1 test2.bin

B7>compare test.bin,test2.bin
COMPARE  Version 1.4
Source File 1 -- B  7: TEST    .BIN
Source File 2 -- B  7: TEST2   .BIN
** Files are Different **

B7>diff test.bin,test2.bin
DIFF  Version 1.6
Source File 1 -- B  7: TEST    .BIN
Source File 2 -- B  7: TEST2   .BIN
 Rel Offset   B  7: TEST    .BIN     B  7: TEST2   .BIN
 Hex    Dec       Hex  Dec Asc           Hex  Dec Asc
0000      0        C3  195  C             00    0  .
0001      1        70  112  p             01    1  .
0002      2        01    1  .             02    2  .
00F0    240        09    9  .             00    0  .
00F1    241        3C   60  <             00    0  .
00F2    242        3D   61  =             00    0  .


B7>crc *.* di
CRC  Version 2.0

** File Inspection **
COMPARE .HLP -- Select (Y/N/S=Skip Rest/Q=Quit/other=Y)? Y
CRC     .CRC -- Select (Y/N/S=Skip Rest/Q=Quit/other=Y)? N
HELP    .TXT -- Select (Y/N/S=Skip Rest/Q=Quit/other=Y)? Y
S100    .TXT -- Select (Y/N/S=Skip Rest/Q=Quit/other=Y)? S
** Inspection Complete **

    1 File: COMPARE .HLP -- Size:     4K -- CRC: 9F 8E
    2 File: HELP    .TXT -- Size:     4K -- CRC: 77 6E

B7>type crc.crc

    1 File: COMPARE .HLP -- Size:     4K -- CRC: 9F 8E
    2 File: HELP    .TXT -- Size:     4K -- CRC: 77 6E

B7>crc *.* icd
CRC  Version 2.0

** File Inspection **
COMPARE .HLP -- Select (Y/N/S=Skip Rest/Q=Quit/other=Y)? Y
CRC     .CRC -- Select (Y/N/S=Skip Rest/Q=Quit/other=Y)? N
HELP    .TXT -- Select (Y/N/S=Skip Rest/Q=Quit/other=Y)? Y
S100    .TXT -- Select (Y/N/S=Skip Rest/Q=Quit/other=Y)? S
** Inspection Complete **

    1 File: COMPARE .HLP -- Size:     4K
        Comment? Help File for COMPARE and DIFF and CRC
 -- CRC: 9F 8E
        Comment: Help File for COMPARE and DIFF and CRC
    2 File: HELP    .TXT -- Size:     4K
        Comment? Note on Help Files
 -- CRC: 77 6E
        Comment: Note on Help Files

B7>type crc.crc

    1 File: COMPARE .HLP -- Size:     4K -- CRC: 9F 8E
        Comment: Help File for COMPARE and DIFF and CRC
    2 File: HELP    .TXT -- Size:     4K -- CRC: 77 6E
        Comment: Note on Help Files

.fo Section 7 - File Copy Utility                      Page   #

7.0  File Copy Utility

7.1  MCOPY Overview

     MCOPÙ  ió á filå copù prograí designeä foò uså undeò  ZCPR2®  
Iô  supportó  manù  featureó relateä specificallù  tï  thå  ZCPR² 
System and is very intimately tied into the ZCPR2 System.

     Thå  basiã  purposå  oæ  MCOPÙ ió tï  copù  fileó  froí  onå 
directorù (disk/useò area© tï anotheò undeò ZCPR2®   Iô  supportó 
thå   nameä  directorù  formó  oæ  ZCPR2¬   anä  thå  sourcå  anä 
destinatioî  directorieó  caî  bå specifieä  iî  termó  oò  nameä 
directories or DU: forms or both.

     MCOPÙ  ió alsï intendeä tï bå useä foò backuğ purposes®   Iô 
haó  thå  abilitù  tï repeatedlù copù á seô  oæ  fileó  froí  onå 
directorù  tï another¬  pausinç betweeî successivå copù passeó tï 
allo÷  thå useò tï changå disks®   Á keù tï thå uså oæ  MCOPÙ  iî 
generaì  ió thaô oncå MCOPÙ haó beguî operations¬  thå useò  neeä 
neveò concerî himselæ witè Warí Bootinç thå systeí afteò changinç 
disks; MCOPY is doing that for him.

     Iî  copyinç  á  filå froí onå directorù  tï  another¬  MCOPÙ 
performs the following steps:

          1®  Iô logó intï thå sourcå directorù anä scanó foò thå 
files specified by the user

          2®   Iô logó intï thå destinatioî directory¬ determineó 
iæ á copù oæ thå filå existó oî thå destinatioî anä deleteó iô iæ 
it does

          3®   MCOPÙ copieó thå filå iî thå sourcå directorù intï 
the destination directory

          4®   MCOPÙ  setó  thå  attributeó oæ thå  filå  iî  thå 
destinatioî  directorù  tï  bå thå samå aó thoså  iî  thå  sourcå 
directory

          5®   MCOPÙ optionallù verifieó botè fileó bù meanó oæ á 
CRC Check

     MCOPY is invoked by one of the following forms:

          MCOPY //                 <-- Print Help
          MCOPÙ                    <-- Enteò Interactivå Mode
          MCOPY files options      <-- Immediately Copy


     Thå "MCOPÙ fileó options¢ forí ió extremelù flexiblå iî  itó 
capabilities®    Wheî   firsô  invoked¬   MCOPÙ  haó  á   defaulô 
destinatioî directorù defineä (bù GENINS)®   Thå "files¢ fielä ió 
á  serieó  oæ  filå  assignmenô  specifications¬   wherå  sucè  á 
specification is of the form:

          dir:=dir:filename.typ or dir:filename.typ

Iæ  thå  firsô forí ió encountered¬  thå defaulô  destinatioî  ió 
temporarilù  redefineä tï bå thå directorù indicateä oî thå  lefô 
oæ  thå "=¢ character¬  anä alì fileó referenceä thereafteò untiì 
the next "dir:=dir:filename.typ" form are copied to this default.

     To illustrate my point, note the following example:

          MCOPY FILE1.*,HELP:FILE2.HLP,TEMP:=TEST.TXT,HI.*

Let'ó assumå thaô thå defaulô defineä bù GENINÓ ió thå  directorù 
nameä  BACKUP®   Iî  thió  case¬  fileó matchinç FILE1.ª  iî  thå 
currenô  directorù arå copieä tï BACKUP¬  thå filå  FILE2.HLĞ  iî 
directorù  HELĞ  ió copieä tï BACKUP¬  thå filå TEST.TXÔ  iî  thå 
currenô directorù ió copieä tï TEMP¬  anä thå fileó matchinç HI.ª 
in the current directory are copied to TEMP.

     Oncå  á  DIR:½ ió encountered¬  thå defaulô  destinatioî  ió 
redefined®   Encounterinç á differencå source¬  however¬ doeó noô 
change what the default source directory is.



7.2  MCOPY Command Line Options

     Thå  optionó portioî oæ thå "MCOPÙ fileó options¢ commanä ió 
a set of none or more of the following characters:

          E -- Test for Existence of File on Destination and
               User Approves Copy before Copy is Done

          I -- User Approves Each File before Copy Begins

          M -- Multiple Copy (Repeat) Facility

          Q -- Quiet Operation (No Activity Displays)

          V -- Verify Facility

     GENINÓ ió useä tï seô thå defaulô settingó foò eacè oæ theså 
optionó (turninç theí oî oò off)¬ anä thå optioî characteró servå 
to toggle the settings from the defaults.


     Thå  Å  optioî  (Existencå Test© lookó  oî  thå  destinatioî 
directorù  tï  seå  iæ thå filå iô ió abouô tï  copù  ió  alreadù 
there®  Iô theî telló thå useò oæ itó findingó anä askó hií iæ hå 
wantó tï gï aheaä witè thå copy®   Thå useò maù elecô tï copù  oò 
noô copù aó hå desires.

     Thå  É  optioî (Inspect© displayó alì fileó whicè matcè  thå 
indicateä sourcå fileó tï thå user¬  allowinç hií tï selecô whicè 
fileó  hå  wantó tï copy®   Iô theî copieó  thå  selecteä  files®  
MCOPÙ  performó  thió  operatioî  foò eacè seô oæ  fileó  iî  thå 
command line (separated by commas).

     Thå  Í  optioî (Multiplå Copy© pauseó  beforå  startinç  thå 
copy¬  allowinç  thå useò tï aborô thå procedurå oò inserô á disë 
intï thå source¬  thå destination¬  oò botè anä instrucô MCOPÙ tï 
proceed®   Afteò copyinç alì oæ thå indicateä files¬  MCOPÙ  theî 
pauseó  again¬  allowinç  thå useò tï agaiî changå  disks®   Thió 
continues until the user aborts the procedure.

     Thå  Ñ optioî (Quiet© turnó ofæ thå MCOPÙ activitù  display®  
Iî normaì operation¬ MCOPÙ ió constantlù tellinç thå useò whaô iô 
ió  doing®   É  feeì  thaô thió ió  betteò  thaî  quietlù  havinç 
problems without the user knowing what is going on.

     Thå  Ö  optioî (Verify© ió useä tï checë thå copieä filå  tï 
insurå thaô thå copù ió good®   Witè thió optioî  engaged¬  MCOPÙ 
computeó  á  CRÃ valuå oæ thå sourcå filå aó iô readó  it®   Wheî 
MCOPÙ haó completeä thå copy¬ iô readó thå destinatioî filå back¬ 
computinç itó CRÃ value¬  and¬ wheî complete¬ iô compareó thå twï 
CRÃ  values¬  tellinç thå useò iæ aî erroò iî thå  copù  occurreä 
(i.e., different CRC values resulted).



7.3  MCOPY Interactive Mode

     Iæ   thå  user'ó  commanä  ió  simplù  "MCOPY"¬   theî   thå 
Interactivå Modå ió enabled®   Iî responså tï thió command¬ MCOPÙ 
displays the following prompt:

MCOPY Status: EIMQV -- MCOPY Command (? for Help)?

wherå anù oæ thå characteró iî "EIMQV¢ maù bå omitted®  Thå EIMQÖ 
characteró  indicatå  thå  statuó oæ thå variouó  MCOPÙ  options¬ 
namely:

          E indicates that File Existence Test is ON
          I indicates that Inspect Mode is ON
          M indicates that Multiple Copy is ON
          Q indicates that Quiet Mode is ON
          V indicates that MCOPY will Verify


     Thå MCOPÙ commanä prompteä foò ió á singlå  character¬  caså 
insignificant®   Yoõ  caî  togglå  eacè onå oæ theså  optionó  bù 
simply striking the appropriate letter.

     Therå  arå siø MCOPÙ Commandó tï perforí variouó  functions®  
These commands are:

          C - Copy a File or Set of Files
          D - Directory Display
          F - Compute Amount of Free Space on Disk
          L - Log in New Directories
          S - Display MCOPY Status
          X or ^C - Exit

     Thå  Ã  commanä  (Copy©  allowó yoõ  tï  specifù  á  seô  oæ 
destinations¬ sources¬ anä fileó aó yoõ coulä aô thå commanä linå 
level®     Eacè    seô    ió   separateä   bù    commaó    (like¬ 
"dir:=dir:f1.typ,f2.typ,dir:=dir:f3.typ").

     Thå Ä commanä (Directory© displayó á sorteä directorù tï thå 
useò  oæ  thå  defaulô directorù oò onå  oæ  hió  choice®   Nameä 
directorieó oò thå DUº forí maù bå useä tï specifù thå directory®  
Thå defaulô directorù ió thå lasô destinatioî directorù copieä tï 
or selected by the L command.

     Thå  Æ  commanä  computeó thå amounô oæ freå spacå  lefô  oî 
disk.  The user may select the disk or ride with the default.

     Thå  Ì commanä allowó thå useò tï specifù á ne÷  destinatioî 
or source directory.

     Thå   Ó  commanä  telló  thå  useò  thå  Statuó  oæ   MCOPY¬ 
particularlù  whaô thå currenô sourcå anä destinatioî directorieó 
are.

     X or ^C exits MCOPY to ZCPR2.



7.4  Sample MCOPY Sessions

B7>mcopy help:=mcopy.hlp
MCOPY  Version 2.8
        Copy B  7: MCOPY   .HLP to A 16:
No Original File MCOPY   .HLP on Destination
Reading     7K  Writing     7K

    Copy Complete,  Verify Phase --
Reading     7K
    Verify Complete
**** MCOPY Compete ****
            1 File Copied     0 Copy Errors


B7>mcopy 1:=*.hlp,*.txt i
MCOPY  Version 2.8
        Copy B  7: ????????.HLP to B  1:
MCOPY   .HLP -- Copy (Y/N/Q=Quit and Skip Rest/<CR>=Y)? Y
No Original File MCOPY   .HLP on Destination
Reading     7K  Writing     7K

    Copy Complete,  Verify Phase --
Reading     7K
    Verify Complete
        Copy B  7: ????????.TXT to B  1:
HELP    .TXT -- Copy (Y/N/Q=Quit and Skip Rest/<CR>=Y)? Y
S100    .TXT -- Copy (Y/N/Q=Quit and Skip Rest/<CR>=Y)? N
No Orginal File HELP    .TXT on Destination
Reading     1K  Writing     1K

    Copy Complete,  Verify Phase --
Reading     1K
    Verify Complete
**** MCOPY Complete ****
            2 Files Copied     0 Copy Errors

B7>mcopy
MCOPY  Version 2.8
MCOPY Status:     V -- MCOPY Command (? for Help)? ?
        MCOPY Status:  E I M Q V
These Status Characters have the following meanings:
   E - File Existence Test Mode is ON
   I - File Selection Inspect Mode is ON
   M - Muliple Copy Function Mode is ON
   Q - Quiet Mode is ON
   V - Verify Mode is ON

The Status Characters, as commands, toggle their respective modes.
Other valid MCOPY Commands are:
   C - Copy a File or Set of Files
   D - Directory Display
   F - Compute Amount of Free Space on Disk
   L - Log in New User/Disks
   S - Display MCOPY Status (Cur and Dest User/Disk)
   X or ^C - Exit MCOPY

MCOPY Status:     V -- MCOPY Command (? for Help)? d
** Directory Display **
        File Spec (<CR>=C  0:*.*)? b1:
DEMO    .COM    4K  DEMO    .MAC    4K  DEMO    .ZEX    4K  GENINS  .MAC   44K
HELP    .TXT    4K  MCOPY   .HLP    8K  TEMPLATE.MAC   12K
**    80K Occupied by Displayed Files,  4048K Remaining on Disk B **


MCOPY Status:     V -- MCOPY Command (? for Help)? c
        File Spec (<CR>=Abort)? zcpr:=mcopy.hlp
        Copy B  7: MCOPY   .HLP to A 11:
No Original File MCOPY   .HLP on Destination
Reading     7K  Writing     7K

    Copy Complete,  Verify Phase --
Reading     7K
    Verify Complete
**** MCOPY Complete ****
            1 File Copied     0 Copy Errors

MCOPY Status:     V -- MCOPY Command (? for Help)? f
** Free Space Data **
        Disk (<CR>=A)? 

 1328K Bytes Remaining on Disk A
MCOPY Status:     V -- MCOPY Command (? for Help)? f
** Free Space Data **
        Disk (<CR>=A)? B

 4048K Bytes Remaining on Disk B

MCOPY Status:     V -- MCOPY Command (? for Help)? x
** MCOPY Exiting **

