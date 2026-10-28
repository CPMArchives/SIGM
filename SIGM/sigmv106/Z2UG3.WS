.fo Section 10 - ZCPR2 Resident and Alternate Cmnds    Page   #

10.0  ZCPR2 Resident and Alternate Commands

                     ZCPR2 Resident Commands

     Likå thå CP/Í 2.² CCP¬  ZCPR² containó somå commandó  withiî 
itself®   Iô containó alì oæ thå CCĞ commandó (excepô USER¬ whicè 
isn'ô  needeä  anymore©  anä á fe÷ more¬  buô alì  oæ  thå  ZCPR² 
residenô  commandó  arå differenô witè logicaì extensionó tï  thå 
CCĞ commands.

     Thå   followinç  discussioî  applieó  tï   thå   recommendeä 
configuratioî oæ ZCPR2®   Therå arå manù wayó tï configurå ZCPR2¬ 
anä  thió discussioî cannoô possiblù coveò alì oæ them¬  sï É  aí 
coverinç  thå recommendeä configuratioî wherå alì oæ thå residenô 
commandó arå enableä witè alì oæ theiò optionó turneä on.

     Iî  thå  followinç  discussion¬  "afn¢ referó  tï  thå  CP/Í 
ambiguouó  filå namå forí (containinç "?¢ and/oò "*¢  characters© 
anä "ufn¢ referó tï thå CP/Í unambiguouó filå namå forí (doeó noô 
contaiî thå ambiguouó characters).

     Thå DUº prefiø maù bå useä wheneveò á filå namå ió used®  Bù 
attachinç  thió prefix¬  thå filå ió identifieä tï residå iî  thå 
indicateä  directorù  (disë anä useò area)®   Tï revie÷  thå  DUº 
form¬   iô  ió  á  logicaì  extensioî  tï  thå  Dº  prefiø  undeò 
conventional CP/M.  The user number is added, however.

     Iæ  á prefiø oæ Dº  ió used¬  iô referó tï thå currenô  useò 
areá oî thå indicateä disk®  Iæ á prefiø oæ Uº ió used¬ iô referó 
tï thå indicateä useò areá oî thå currenô disk®   DU:¬ oæ course¬ 
refers to the indicated user area on the indicated disk.

     Foò example¬ iæ yoõ arå loggeä intï Disë B¬ Useò 1¬ theî thå 
following is true:

          A:MYFILE.TXÔ  -- referó tï MYFILE.TXÔ oî Disë A¬ Useò 1
          4:MYFILE.TXT  -- refers to MYFILE.TXT on Disk B, User 4
         A4:MYFILE.TXT  -- refers to MYFILE.TXT on Disk A, User 4
            MYFILE.TXT  -- refers to MYFILE.TXT on Disk B, User 1



10.01  The DIR Command

     Thå DIÒ commanä ió useä tï displaù thå nameó oæ thå fileó iî 
the current directory.  It has three basic forms --

          Display $DIR File Names       DIR DU:afn
          Display $SYS File Names       DIR DU:afn S
          Display All File Names        DIR DU:afn A


     Assume you are logged into Disk B, User 1.  Examples:

          DIR 4:              <-- Gives all non-System files
                                   on B4
          DIR 4: A            <-- Gives all files on B4
          DIR A4:*.HLP A      <-- Gives all files of type
                                   HLP on A4
          DIR *.* S           <-- Gives all System files on B1



10.02  The ERA Command

     Thå  ERÁ commanä ió useä tï eraså files®   Iô ió noô ablå tï 
eraså Read/Onlù files¬ buô iô caî eraså Systeí files®  Iô haó twï 
basic forms --

          Erase Specified Files         ERA DU:afn
          Erase with Verify             ERA DU:afn V

     ERÁ  printó thå nameó oæ thå fileó iô erases®   Iæ yoõ  havå 
selecteä thå Verifù option¬  iô alsï promptó yoõ beforå iô eraseó 
them (or aborts, if you desire).



10.03  The REN Command

     Thå  REÎ commanä ió useä tï changå thå namå oæ onå  filå  tï 
another®   Again¬ iô caî noô changå thå namå oæ á Read/Onlù file®  
It has only one basic form --

          Renamå Filå                   REÎ DU:ufn1=ufn²

     Like ERA, REN can "see" System files as well as DIR files.

     Iæ ufn± alreadù exists¬ REÎ wilì asë thå useò iæ hå wantó tï 
Erase it (with the prompt "Erase ufn1?").



10.04  The TYPE and LIST Commands

     TYPÅ  anä LISÔ arå useä tï displaù fileó oî thå consolå  anä 
printer¬  resp®  TYPÅ pageó bù default¬ stoppinç afteò thå screeî 
is filled.  These two commands have three basic forms --

          Print File on Console         TYPE DU:ufn P
            Without Paging
          Print File on Console         TYPE DU:ufn
            With Paging
          Print File on Printer         LIST DU:ufn

     The file may be either System or DIR.Š
10.05  The SAVE Command

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
if he wishes to erase it with the prompt "Erase ufn?".



10.06  The GET Command

     GEÔ  ió  useä  tï loaä á  filå  anywherå  intï  memory®   Iô 
requireó twï argumentsº   á numbeò (assumeä tï bå hexadecimal© oæ 
thå  256-bytå  pagå iî memorù aô whicè tï starô thå loaä anä  thå 
name of the file.

          Load File Into Memory         GET adr DU:ufn

     Notå  thaô thió "adr¢ ió á pagå number¬  sï adr=± referó  tï 
100H, adr=2d refers to 2D00H, etc.



10.07  The GO Command

     Thå GÏ commanä ió useä tï reexecutå thå lasô prograí  loadeä 
into the TPA without having to reload it.

          Reexecute Last Transient      GO params
            Without Reloading It

     Thå parameteró arå parseä aó witè anù transienô command¬ anä 
thå  appropriatå bufferó arå loadeä bù ZCPR2®   Aó  usual¬  ZCPR² 
"calls¢ thå prograí loadeä aô 100È afteò iô haó finisheä witè thå 
parsing and buffer loading.


10.08  The JUMP Command

     JUMĞ ió useä tï brancè tï anywherå iî memory®  Iô takeó onlù 
onå  argument¬  whicè  ió  thå addresó aô whicè  tï  jump®   Thió 
addresó  caî  bå  tï  anù bytå iî memorù (iô  ió  á  fulì  16-biô 
address), and it is assumed to be a hexadecimal number.

          Call Subroutine Anywhere in   JUMP adr
            Memory



10.09  The DU Form for Changing Disk and User

     Thå  DÕ forí standinç alonå ió useä tï loç intï á  differenô 
directory.  There are three basic forms of this command --

          Change Disk                   D:
          Change User                   U:
          Change Disk and User at       DU:
            Same Time



10.10  Alternates to the ZCPR2 Resident Commands

     Aó  thå  readeò  caî seå bù reviewinç thå  helğ  filå  nameä 
Z2RES¬  thå  residenô commandó oæ ZCPR² arå logicaì extensionó oæ 
thå residenô commandó oæ thå CP/Í 2.² CCP®  Witè thå ZCPR² Systeí 
oæ  Programs¬  however¬  comeó á seô oæ transienô programó  whicè 
providå  thå  samå  typeó  oæ functionó  aó  thå  ZCPR²  residenô 
commands but with many more options and much more flexibility.

     Aó  aî  overview¬  thå followinç tablå  compareó  thå  ZCPR² 
residenô  commandó anä theiò transienô alternates®   Thå residenô 
commandó oæ SAVE¬  JUMP¬  GET¬  anä GÏ havå nï alternateó bù  thå 
nature of their functions.


Resident  Alternate Additional Alternate Functions
--------  --------- ------------------------------
  DIR       XDIR    Sorts Display, Prints File Sizes, Negative
          alias       Selection, Disk Output, Printer Output,
            XDIR3     File Scan Function, Named Directories

  ERA       ERASE   File List, Named Directories, Inspect Mode,
                      Can Erase R/O Files, System File Protection

  REN       RENAME  File List, Named Directories, Inspect Mode,
                      Wild Cards Permitted, Control Mode,
                      System File Protection

  TYPE      PAGE    File List, Named Directories, Screen Wrap,
                      Speed Change

  LIST      PRINT   File List, Named Directories, Headings,
                      Page Numbering, Time Stamp, Paging,
                      Skip to Specified Page

     Iî  additioî tï thå transientó nameä oî thå previouó  table¬ 
threå transientó noô relateä tï anù onå specifiã residenô commanä 
whicè kinä oæ falì intï thå categorù oæ "speciaì systeí transienô 
commands" are:

          PROTECT -- Set Protection Codes and Tag Bits on Files

          PATH -- Display and Set Command or File Search Paths

          WHEEL -- Enable and Disable Certain Resident Commands

     These will also be discussed in this HELP File.


     Onå notå beforå proceedingº  alì oæ thå transientó discusseä 
herå  whicè accepô botè filå nameó anä optionó aó argumentó  wilì 
noô accepô á filå namå beginninç witè á slash®   Thió ió á trade-
ofæ É haä tï makå ..®  É wanteä tï makå iô easù tï omiô thå  filå 
namå (assuminç alì fileó selected© anä jumğ righô tï thå options®  
Tï bå consistent¬  É selecteä thå slasè (nonå oæ mù currenô fileó 
begiî  witè á slasè anä É likå iô aó aî optioî delimiteò froí  mù 
experiences with DEC software).

     Hence¬ aó á generaì rulå foò alì transientó É createä tï ruî 
witè ZCPR2¬  iæ á filå namå ió omitted¬ theî thå ¯ characteò musô 
proceeä  thå  firsô  option®   Additionally¬  aî  invaliä  optioî 
invokeó  á  built-iî Helğ facilitù withiî alì oæ thå  transients¬ 
and / is never an option character.  So, we have:

          command filename.typ o...     <-- form with file spec
          command /o...                 <-- form sans file spec
          command //                    <-- always gives help

     Anotheò  iteí tï notå ió thaô manù transientó  supporô  filå 
listó wherå á singlå filå namå waó giveî before®  Iî theså cases¬ 
thå  useò caî specifù á lisô oæ filå specó separateä bù commaó iî 
the file name position:

          command dir:f1.typ,dir:f2.typ,... o...

     Alsï  iî manù cases¬  thå DIÒ forí maù bå prefixeä  tï  eacè 
filå name®   Thå DIÒ forí maù bå thå namå oæ á nameä directorù oò 
it may be a simple DU form.



10.11  The XDIR Command

     Thå  XDIÒ  Commanä (XDIR³ program© ió aî extendeä  directorù 
display utility.  It has the general form of:

          XDIR dir:filename.typ ooo...

where:

          "dir:¢ ió á DIÒ prefix» iô maù bå á nameä directory¬ 
               like ROOT, a DU form, like A5, or omitted
          "filename.typ" is an ambiguous file name reference,
               and it may be omitted
          "o" is an option character, and, if "filename.typ" is
               omitted, the first option must be proceeded by
               a slash


     Valid options under XDIR are:

          Aa -- Set File Attributes
               AA = Select System and Non-System Files
               AN = Select Non-System Files
               AS = Select System Files
          D  -- Send Output to Disk File XDIR.DIR as well as
                    to the Console
          Ff -- Enable a Disk-Based File Scanner Function
               FL = Log Names to FNAMES.DIR
               FP = Print Names Stored in FNAMES.DIR
               FS = Scan Disk and Compare to FNAMES.DIR
          G  -- Toggle Grouping (by filename/type or type/name)
          H  -- Toggle Display (Horizontal/Vertical)
          I  -- Inspect Logged Files (for FL option only)
          N  -- Negate Selection (File NOT Matching Wildcard)
          P  -- Send Output to Printer as well as Console


     Uså  oæ alì oæ theså optionó ió ratheò involved¬  anä  XDIR³ 
haó  á Helğ Filå dedicateä tï it®   Thå nexô informatioî  sectioî 
chains to that Help File.


10.12  The ERASE Command

     Thå ERASÅ commanä ió useä tï eraså files¬  likå ERA®   Therå 
arå  manù majoò differences¬  however®   Thå generaì forí oæ  thå 
ERASE Command is:

          ERASE dir:f1.typ,dir:f2.typ,... o...

     Aó  thå readeò caî see¬  á filå lisô ió permitteä aó welì aó 
the DIR prefix.  The file specs may be ambiguous.

     Á  majoò differencå iî functionaì concepô betweeî ERASÅ  anä 
ERÁ  ió thaô ERÁ alwayó "sees¢ botè Systeí anä Non-Systeí  files®  
ERASÅ onlù "sees¢ Non-Systeí fileó anä musô bå tolä explicitlù tï 
matcè  Systeí fileó aó well®   É feeì thaô thió affordó aî  addeä 
degreå  oæ  protectioî  tï thå  ZCPR²  environmenô  overall¬  anä 
commandó  likå "ERASÅ *.*¢ affecô onlù workinç fileó anä noô  thå 
System files which may be hidden in the directory.



     The options recognized by ERASE are:

          S -- Include System Files; if S is not present, then
                    ERASE does not "see" System Files

          R -- Erase Read/Only Files without asking the user for
                    permission; if ERASE encounters a Read/Only
                    filå whilå iô ió performinç itó functioî
                    without the R option enabled, it will ask
                    the user if he wants to erase the file before
                    it does so; with the R option, it simply goes
                    ahead and erases the file

          I -- Inspect; ERASE can be instructed to display each
                    file to the user and ask permission before
                    it erases it; if the user gives permission
                    and ERASE discovers that the file is R/O with
                    the R option off, it will ask a second time
                    before going ahead

Examples:
     ERASE A4:*.TXT      Erase all Non-System files of type
                         TXT in directory A4; if a file is R/O,
                         ERASE will ask for permission before
                         proceeding

     ERASE *.TXT,TXT:*.TXT RI
                         Erase all Non-System files of type TXT
                         in the current directory and in the
                         directory named TXT; if a file is R/O,
                         go ahead and erase it; allow the user to
                         see the name of the file and approve its
                         erasure before it is erased

     ERASE SCRATCH: SR   Erase all System and Non-System files
                         iî thå directorù nameä SCRATCH» iæ á
                         file is R/O, erase it without asking;
                         this erases absolutely every file in
                         that directory



10.13  The RENAME Command

     Thå RENAMÅ commanä ió á brotheò tï thå REÎ residenô command®  
Therå arå manù majoò differences¬ however:

          . RENAMÅ allowó  ambiguouó filå nameó tï thå used
          . RENAMÅ supports an Inspect Mode, where the user is
               presented with each name change and allowed to
               approve of it before it is done
          . RENAME supports a Control Mode, where the user is
               presented with each file to be RENAMEd and allowed
               to manually enter the new name or not rename the
               file
          . RENAME accepts a list of files
          . RENAME does not "see" System files unless told to
          . RENAME can rename Read/Only files
          . RENAME sets the attibutes (R/O and SYS) of the
               new file names to be the same as those on the
               old file names
          . RENAME supports Named Directories

     The RENAME command is of the general form:

          RENAME dir:f1.typ,dir:f2.typ,... o...

     The options to RENAME are:

          S -- Include System Files
          I -- Allow user to Inspect the file before performing
                    the rename
          C -- (Control Mode) Allow the user to manually name
                    each of the selected files or to skip it

     Iæ á ne÷ filå namå ió thå samå aó aî existinç file¬ thå useò 
wilì  bå askeä iæ hå wisheó tï deletå thå existinç filå iî  ordeò 
for the rename function to be performed.


Examples:
     RENAME A4:MYFILE.TXT=HISFILE.TXT
          Rename HISFILE.TXT in A4 to MYFILE.TXT

     RENAME A4:*.MAC=*.ASM,*.TXT=*.TEX IS
          Rename all files of type ASM in A4 to type MAC; also
          rename all files of type TEX in the current directory
          to type TXT; include System files and Inspect (approve)
          each file before the rename is done

     RENAME TXT: C
          Rename all Non-System files in directory TXT; the user
          is presented with the name of the file and manually
          enters a new name for it

Š
     RENAME 1:*.TXT CS
          Rename all Non-System and System files in User 1 of the
          current disk whose file type is TXT and allow the user
          to manually enter each new name

     RENAME S*.TXT=*.TXT
          Rename all Non-System files in the current directory
          whoså filå typå ió TXÔ sï thaô thå firsô letteò oæ
          their names is an S and the rest of the letters are
          unchanged



10.14  The PAGE Command

     Thå  PAGÅ commanä ió useä tï lisô fileó oî thå console®   Iô 
offeró á fe÷ advantageó oveò TYPÅ iî thaô PAGÅ knowó thå widtè oæ 
thå screeî anä handleó wraparounä (whicè ió á biç complainô  witè 
TYPÅ  wheî  tryinç  tï  pagå througè "wide¢  listingó  likå  thaô 
produceä bù thå assemblers)®   PAGÅ alsï acceptó á filå lisô  anä 
supports named directories.

     PAGE is invoked by a command line of the following form:

          PAGE dir:f1.typ,dir:f2.typ,... o...

wherå  "dir:fn.typ¢ ió aî ambiguouó filå speã (wilä cardó maù  bå 
used©  witè  á DIÒ prefiø (nameä directorieó oò DÕ forí  allowed© 
and "o" is one or more of the following options:

          P - do not pause for user after filling a screen
          Sn, 0 <= n <= 9 - set initial speed (0=fastest)

     Thå Speeä optioî oæ thå PAGÅ commanä shoulä bå discusseä  iî 
somewhaô  morå detail®   Whilå á filå ió beinç pageä tï thå user¬ 
thå  useò caî strikå onå oæ thå digitó tï varù thå speeä  oæ  thå 
outpuô dynamically®  ° ió thå fastest¬ ¹ ió thå slowest®  Iî thió 
way¬  thå  useò caî easilù scaî á filå bù runninç PAGÅ witè thå Ğ 
optioî  (sï  iô  doeó noô stoğ wheî thå  screeî  ió  filled©  anä 
strikinç  á digiô froí timå tï timå tï speeä uğ oveò sectionó  hå 
isn't interested in and slow down for sections he is.

     Whilå  thå  outpuô  ió beinç directeä tï  thå  screen¬  PAGÅ 
supportó  thå followinç single-characteò commandó tï  changå  thå 
output display in one way or another:


          0 to 9 - change speed (0=slowest, 9=fastest)
          P or p - toggle pause when screen fills
                    (the user can dynamically turn on and off
                     the ability to delay when a screen fills)
          C or c - issue PAGE immediate command
                    immediate commands include S to skip to next
                    file, R to restart current file, and Q or ^C
                    to abort to ZCPR2

     Wheî  PAGÅ pauseó wheî thå screeî filló (itó  default)¬  thå 
useò  maù  issuå onå oæ thå immediatå commandó oæ  PAGE®   Hå  ió 
prompted for input at this time.



10.15  The PRINT Command

     Thå  PRINÔ  commanä  ió useä tï prinô á  filå  oî  thå  LSTº 
device¬  likå LISÔ does¬  buô offeró manù morå options®   Iô wilì 
prinô  á heading¬  pagå thå file¬  numbeò thå pages¬  numbeò  thå 
lines¬  placå á date/timå stamğ oî thå output¬  puô thå filå namå 
oî thå output¬ anä others.

     The PRINT command is of the following form:

          PRINT dir:f1.typ,dir:f2.typ,... o...

wherå  "dir:fn.typ¢  ió aî ambigouó filå namå witè á  DIÒ  prefiø 
(supportinç  thå DÕ forí oò á nameä directory© anä "o¢ ió onå  oò 
morå oæ thå following:

          E - Exact Print (Expand Tabs, Form Feed, No Line or
               Page Numbers, No Heading)
          F - Toggle default of file name display on page header
               (iæ defaulô ió ON¬ theî Æ turnó ofæ name display)
          H<delim>text<delim> - Define Heading text to appear
               at the top of each page
          L - Toggle numbering of each line
          M - Toggle Multiple Run Flag
               (if multiple run is ON, then no "Set Top of Form"
                message appears for each file and PRINT moves
                from one file to another unattended)
          N - Toggle numbering of each page
          Sn - Start printing on page n
          T - Toggle date/time stamp in the header of each page
               (a CLOCK subroutine must be assembled into PRINT
                to enable the date/time stamp feature)


     Thå F¬  L¬  M¬ N¬ anä Ô optionó arå seô bù GENINÓ initially®  
Thió  allowó thå installeò tï selecô defaultó foò theså  options¬ 
anä  theså  optioî characteró iî thå commanä linå jusô  servå  tï 
toggle the defaults.
Š
     Thå  specifiã  featureó oæ thå printeò arå alsï seô  bù  thå 
installeò  witè  GENINS®   Sucè featureó includå  thå  numbeò  oæ 
physicaì lineó oî á page¬  thå numbeò oæ lineó oæ texô oî á page¬ 
and the width of a line in characters.

     Thå  date/timå stamğ featurå ió verù machine-dependent¬  anä 
PRINÔ  haó  tï  bå reassembleä tï supporô  it®   Detailó  oæ  thå 
date/timå  stamğ subroutinå arå includeä witè PRINÔ iî thå  ZCPR² 
distribution.



10.16  The PROTECT Command

     Thå  PROTECÔ commanä replaceó thå attributå seô capabilitieó 
oæ  thå  STAÔ transienô anä addó morå  flexibility®   PROTECÔ  ió 
designeä tï allo÷ thå useò tï specifù thå attributeó  (Read/Only¬ 
System¬  anä  Archive© anä taç bitó (thå Mosô Significanô Bitó oæ 
the eight characters in a file name) of a file or set of files.

     The PROTECT command is of the following form:

          PROTECT dir:f1.typ,dir:f2.typ,... o...

     Aó thå readeò caî see¬  á filå lisô ió permitteä aó welì  aó 
nameä directories®   Thå filå specó maù bå ambiguous®  Optionó tï 
the PROTECT Command are:

     PROTECT always "sees" both System and Non-System files.

          I -- Inspect        C -- Control

          R, S, A -- Turn on Attributes Read/Only, System, and
               Archive

          n, 1 <= n <= 8 -- Set Tag Bits

     Inspecô  Modå allowó thå useò tï looë aô eacè filå beforå iô 
ió  "protected¢  anä  permiô  oò  disallo÷  thå  functioî  tï  bå 
performed on a case-by-case basis.

     Controì Mode¬ aó witè thå RENAMÅ command¬ allowó thå useò tï 
seå  thå  namå  oæ  eacè  filå  selecteä  anä  manuallù  seô  itó 
attributeó anä taç bits®  Iî responså tï thå Controì Modå prompt¬ 
thå useò caî typå iî anù combinatioî oæ thå letteró A¬  R¬ S¬ anä 
the digits 1-8.


Examples:
     PROTECT A4:*.COM,ROOT:*.COM RSI
          Set the Attributes of all COM files in directories A4
          and ROOT to Read/Only and System.  Turn off the Archive
          attribute and all tag bits.  Allow the user to inspect
          each file before the operation is performed.

     PROTECT ROOT:*.TXT
          Clear all attributes and all tag bits of all files of
          type TXT in the directory named ROOT

     PROTECT A: C
          Allow the user to manually set all attributes and tag
          bits of all files on Disk A in the current user



10.17  The PATH Command

     Thå  PATÈ  Commanä ió useä tï dynamicallù changå  á  memory-
baseä  filå searcè patè oò thå ZCPR² commanä searcè  path®   Witè 
PATH¬  thå  useò caî definå á ne÷ patè tï bå followeä oò  hå  caî 
view what the current path is.

     Thå  PATÈ commanä ió installeä bù GENINS¬  and¬  durinç  thå 
installatioî process¬  GENINÓ telló PATÈ thå beginninç addresó oæ 
thå patè iô ió tï worë with®  PATÈ maù bå installeä severaì timeó 
bù GENINS¬  giveî differenô patè addresses¬  anä theî saveä undeò 
different names to support each path the ZCPR2 System uses.

     Thå  PATÈ  commanä  dealó witè  patè  expressions®   Á  patè 
expressioî  ió  á  sequencå  oæ  directorù  names  whicè  caî  bå 
expresseä  aó "ambiguous¢ DÕ forms¬  absolutå DÕ forms¬  oò Nameä 
Directory forms.

     Aî  absolutå DÕ forí indicateó jusô á disë  letteò  (currenô 
useò  ió assumed)¬  jusô á useò numbeò (currenô disë ió assumed)¬ 
oò botè á disë letteò anä á useò number®   Aî "ambiguous¢ DÕ forí 
ió  onå  iî  whicè  thå disë letteò oò useò  numbeò  oò  botè  ió 
replaceä witè á "$¢ character¬ meaninç "currenô disk¢ oò "currenô 
user"®   Á Nameä Directorù form¬ oæ course¬ ió simplù thå namå oæ 
a directory.

     Tï illustrate¬  let'ó saù thaô yoõ arå loggeä intï B1®   Thå 
path
          $0 A$ A0 ROOT

represents the sequence

          B0 to A1 to A0 to ROOT


     Thå PATÈ Command¬ then¬ maù bå invokeä bù theså forms:

          PATH //                  <-- Print Help
          PATH                     <-- Display Path
          PATH path-expression     <-- Set Path

     Actuaì  screeî displayó illustratinç thå uså oæ PATÈ follow®  
Comments are denoted at the size by being prefixed with "<<".


B7>path //			<< Print Help
PATH  Version 1.0
        PATH allows the user to display his current path
and set a new path.  It is invoked by one of the forms:

                PATH                    <-- Display Path
                PATH path-expression    <-- Set Path
                PATH //                 <-- Print Help

B7>path				<< Print Current Path
PATH  Version 1.0
Current Path in Symbolic Form -- 
        A$: --> A 15:
Current Path in Absolute Form --
        A  7: --> A 15:
Current Path in Named Directory Form --
        R-WS: --> ROOT:

B7>path $0 a$ base root:	<< Set a Path
PATH  Version 1.0		<< Note: a named dir may have
Current Path in Symbolic Form --   << a : as a suffix
        $  0: --> A$: --> A  0: --> A 15:
Current Path in Absolute Form --
        B  0: --> A  7: --> A  0: --> A 15:
Current Path in Named Directory Form --
        DEV-BASE: --> R-WS: --> BASE: --> ROOT:

B7>path 0 base root help	<< Set a Path with an Error in It
PATH  Version 1.0

Invalid Path Expression Element -- Error Flagged at:
        -->0 BASE ROOT HELP
This may be an invalid DU: form (disk or user out of range)
or an undefined named direcory.

Aborting to CP/M


B7>path a$			<< I kept ROOT in the path before
PATH  Version 1.0		<< This is where my commands are
Current Path in Symbolic Form -- 
        A$:
Current Path in Absolute Form --
        A  7:
Current Path in Named Directory Form --
        R-WS:
B7>path			<< Path Can't be found without ROOT being
PATH?			<< in the path expression
B7>a15:path a$ root	<< ... UNLESS the DU: prefix is used
PATH  Version 1.0	<< (DU: can be disabled by the ZCPR2
Current Path in Symbolic Form --   << installer)
        A$: --> A 15:
Current Path in Absolute Form --
        A  7: --> A 15:
Current Path in Named Directory Form --
        R-WS: --> ROOT:
B7>


     No÷  wå  arå  bacë  tï ouò  originaì  path®   Notå  thaô  bù 
disablinç thå DÕ form¬  á loô oæ securitù ió addeä tï thå system®  
Commandó caî onlù comå froí thå currenô path¬ anä CÄ MUSÔ bå useä 
tï  loç  intï á directory®   Addeä tï this¬  oæ  course¬  ió  thå 
abilitù  tï hidå Systeí Directorieó froí vie÷ bù PWÄ anä  forcinç 
thå  useò  tï  providå  á passworä iî ordeò  tï  enteò  á  Systeí 
Directory.



10.18  The WHEEL Command

     Thå  WHEEÌ  commanä  ió useä tï enablå anä  disablå  certaiî 
selecteä (aô installatioî time© ZCPR² residenô commands®  Á WHEEÌ 
optioî  caî  bå  specifieä wheî ZCPR² ió installeä  oî  á  targeô 
system®  Iæ thå WHEEÌ optioî ió enableä foò á particulaò command¬ 
thaô commanä wilì worë onlù iæ á Wheeì Byte¬ locateä somewherå iî 
memory¬ ió set®  Thå commanä wilì echï aó aî erroò messagå iæ thå 
Wheeì Bytå ió noô set.

     Thå  WHEEÌ commanä ió useä tï seô anä reseô thå Wheeì  Byte®  
It supports the following forms:

          WHEEL or WHEEL //   <-- Print Help
          WHEEÌ passworä SEÔ  <-- Seô Wheeì Bytå (Enablå Cmd)
          WHEEL password      <-- Set Wheel Byte
          WHEEÌ passworä RESEÔ  <-- Reset¬ oò Clear¬ Wheeì Byte

     Thå WHEEÌ concepô caî bå extendeä intï transienô commandó aó 
well®   Thió ió noô donå witè thå transientó supplieä witè ZCPR2¬ 
however.  The WHEEL command is installed by GENINS.

.fo Section 11 - Help System                           Page   #

11.0  Help System

11.1  The HELP2 Subsystem for Online Documentation

     Thå  purposå oæ HELP² ió tï allo÷ thå useò tï  interactivelù 
querù  thå *.HLĞ fileó oæ thå systeí iî ordeò tï receivå informa
tioî  summarieó oî variouó aspectó oæ thå useró workinç  environ
ment¬  sucè aó thå languagå systemó hå ió usinç anä certaiî  sub
systemó availablå tï him.

     Wheî  thå useò typeó "HELP"¬  á searcè ió donå foò thå fileó 
*.HLP®   Thå  namå  oæ  eacè HLĞ filå ió displayeä  tï  thå  useò 
optionallù   followeä  bù  thió  text®    Iæ  thå  useò   desireó 
informatioî  oî á specifiã topiã anä hå haó á HELĞ Filå  oæ  thaô 
namå (ie¬  CPM.HLĞ ió á HELĞ Filå oî CP/M)¬  hå maù issuå oæ HELĞ 
Commanä oæ thå form:

               HELP topic

"topic¢ ió thå namå oæ thå HELĞ Filå (topic.HLP¬ likå CPM.HLP).



11.2  HELP: Welcome to the HELP Command

     Welcomå  tï thå HELĞ Command¡   Thå HELĞ Commanä ió designeä 
tï assisô you¬   thå  CP/Í  user¬  iî  thå uså oæ CP/Í iî generaì  
anä  specifiã  CP/Í commandó  iî  particular®    Iô  ió  designeä  
aó  aî  interactive¬  on-linå assistancå system.

     HELĞ  pulló  iî  fileó nameä <FILENAME>.HLĞ  froí  disë  anä 
displayó  theså tï thå useò iî á pageä mode®   Theså fileó arå oæ 
twï basiã typeó -- indexeä anä non-indexed.

     Indexeä  fileó  arå  thoså HELĞ fileó whicè  starô  witè  aî 
index®   Thió  ió aî  examplå  oæ  aî indexeä file®    Wheî  HELĞ 
loadó   aî  indexeä  file¬   iô displayó  thió indeø tï thå  useò 
anä  allowó hií tï selecô entrieó froí  it®  Thå  useò maù selecô 
aó manù entrieó aó hå desireó iî anù ordeò hå  desireó bù  simplù 
typinç thå letteò oæ hió selection®    Oncå thå useò haó madå hió 
selection¬  HELĞ  wilì looë uğ thå bodù oæ texô hå  selecteä  anä 
displaù iô tï hií  iî á pageä mode®    Wheî thå useò haó finisheä 
readinç   hió   selection¬  HELĞ  theî returnó hií tï  thå  indeø 
menu®   Typinç á Control-Ã  wilì returî thå useò tï CP/M.

     Non-indexeä  fileó  arå  thoså HELĞ fileó whicè dï noô starô  
witè  aî index®    Iî sucè cases¬   HELĞ wilì immediatelù displaù 
thå  contentó  oæ  thå filå tï thå useò and¬   wheî thå useò  haó 
finisheä lookinç aô it¬  HELĞ wilì returî tï CP/M.


     HELĞ ió menu-driven¬  anä alì thå commandó availablå tï  thå 
useò aô anù giveî timå arå displayeä tï him®  

     Thå  versioî oæ HELĞ describeä iî thió HLĞ filå ió  designeä 
tï  worë witè thå ZCPR² systeí anä takå advantagå oæ somå oæ  itó 
special features.


11.3  HELP: How to Use the HELP Command

     The HELP Command is executed in one of three ways:
          (1) by just typing 'HELP'
          (2) by typing 'HELP FILENAME', where FILENAME
              is the name of a disk file named FILENAME.HLP
          (3) by typing 'HELP FILENAME.TYP', where
              FILENAME.TYP is the name of a file created in
              the format of a help file

     Iæ  thå useò typeó jusô 'HELP'¬   hå wilì receivå á lisô  oæ 
thå availablå HELĞ Fileó anä mù elecô tï reaä thå basiã  HELP.HLĞ 
file®  Foò alì otheò formó oæ thå HELĞ command¬ thå useò wilì seå 
thå  specifieä helğ filå information®   Generallù  speaking¬  thå 
namå   oæ  thå  helğ filå shoulä bå indicativå oæ  itó   subject¬  
likå  CPM.HLĞ shoulä contaiî helğ informatioî oî CP/M.


                 The HELP File Search Hierarchy

     Wheneveò  HELĞ lookó foò á specifieä HELĞ Filå (eitheò  froí 
thå   HELĞ  Commanä   oò   froí  aî   Informatioî  Sectioî  whicè  
specifieó  á  Nodå  [seå later])¬  HELĞ wilì perforí á searcè foò 
thå indicateä file®   Thió searcè goeó aó follows:

          1®   Undeò  ZCPR2¬  HELĞ  caî bå seô uğ tï  follo÷  thå 
externaì path®   Aó such¬  HELĞ wilì searcè thå currenô directorù 
(disë  anä  user©  first®   Iæ iô ió noô seô  uğ  tï  searcè  thå 
external path, it will search along its internal path.

          2®   Iæ  thå  HLĞ filå ió noô founä undeò  thå  currenô 
directory¬ HELĞ wilì searcè alonç thå ZCPR² patè foò it.

          3®   Iæ thå HLĞ filå ió noô founä alonç thå ZCPR² path¬ 
theî HELĞ wilì searcè alonç itó internaì patè foò thå file®  Thió 
ió á majoò differencå betweeî HELĞ anä otheò ZCPR² utilities®  Tï 
configurå  HELĞ  witè GENINS¬  yoõ shoulä firsô telì GENINÓ  thaô 
HELĞ doeó noô uså externaì paths¬  definå thå internaì path¬  anä 
theî telì GENINÓ thaô HELĞ useó externaì pathó anä wherå thå patè 
begins.

          4®   Iæ  thå HLĞ filå ió noô found¬  HELĞ  wilì  eitheò 
displaù  thå nameó oæ thå HLĞ fileó alonç thå patè anä prinô  itó 
internaì documentatioî oò finä thå filå HELP.HLĞ anä prinô that.


11.4  HELP: Moving Around within the HELP Command

     Oncå thå useò ió runninç HELP¬ hå ió giveî á seô oæ commandó 
bù whicè hå caî displaù thå particulaò itemó oæ informatioî hå ió 
interesteä in.

     Afteò   issuinç thå HELĞ command¬   thå useò wilì comå uğ iî 
onå oæ twï modeó (dependinç oî thå typå oæ HELĞ filå referenced)®  
Iî Indexeä Mode¬  á Menõ  oæ  topicó ió displayeä tï thå useò anä 
hå  caî   selecô  thå  desireä topiã  bù  typinç  thå  letteò  iî 
fronô  oæ thå topiã title»   iî  Non-Indexeä Mode¬   nï  menõ  ió  
displayeä  anä  thå entirå  filå  ió  vieweä  aó  onå Informatioî 
Section.

     Aî  Informatioî Sectioî ió á collectioî oæ screeî   displayó 
(onå   screeî  fulì  oæ text© calleä   Frames®    Typically¬   aî  
Informatioî Sectioî shoulä contaiî á logicaì groupinç oæ  relateä 
datá  oî á  particulaò topic®   Iî Indexeä Mode¬  eacè Menõ topiã 
referó tï aî Informatioî Section® Bù selectinç á topic¬  thå useò 
ió placeä intï aî Informatioî Section®   Iî Non-Indexeä Mode¬ thå 
entirå HELĞ filå ió onå Informatioî Section.


                      Moving From the Menu

     Aô   thå  Menõ  oæ á HELĞ file¬   thå  useò  haó  twï  basiã 
options®   Theså optionó  arå tï selecô á Menõ topiã tï revie÷ oò 
tï  exiô tï  CP/M®    Iæ  á Menõ topiã ió selected¬  thå useò  ió 
placeä intï thaô Informatioî Section.

     Á   thirä   optioî aô thå Menõ oæ á HELĞ filå  ió  sometimeó 
available®  Thió   optioî   ió tï movå uğ tï thå  previouó   HELĞ  
Level®    Somå  Informatioî   Sectionó arå entirå HELĞ  fileó  iî 
theiò owî right¬  whicè caî bå accesseä independentlù oæ thå HELĞ 
filå thå useò ió currentlù  in®   Iæ thå useò enteró onå oæ theså 
Informatioî Sections¬ thå namå oæ thå currenô HELĞ  filå ió saveä 
anä thå ne÷ HELĞ filå ió loaded®    Wheî thió  happens¬  thå useò 
ió placeä aô thå nexô HELĞ Leveì (aî ascendinç number¬  wherå thå 
originaì HELĞ filå ió aô HELĞ Leveì 0¬   á HELĞ filå calleä  froí 
thió leveì ió aô HELĞ Leveì 1¬ á HELĞ filå calleä froí thió leveì 
ió  aô HELĞ Leveì 2¬  etc.)®    Wheî thå useò ió aô á loweò  HELĞ 
Leveì (useò ió NOÔ aô HELĞ Leveì 0)¬  hå  haó  thå optioî tï movå 
tï  thå nexô higheò HELĞ Leveì (froí  HELĞ Leveì ± tï HELĞ  Leveì 
0¬ foò example).

     Thå  concepô  oæ movinç betweeî HELĞ Leveló ió deriveä  froí 
thå concepô oæ á Treå datá structurå froí Computeò  Science®   Iî 
thió concept¬  thå useò startó  aô  thå rooô oæ thå treå anä theî 
climbó  uğ  anä  dowî thå  treå  tï variouó  levels¬   oò  nodes®   
Froí eacè node¬   thå useò maù onlù movå uğ oò dowî  thå treå  -- 
hå  can'ô  crosó oveò tï á nodå aô thå samå leveì  withouô  firsô 
movinç dowî thå treå anä theî bacë up®    Tï illustrate¬ consideò 
thå following:

     Node A      Node B                                HELP Level
   _________   ____________                                     5
     \  Node C   /
     --------------                                             4
           \  Node D            Node E
         ------------         ----------------                  3
               \       Node F       /        Node G
             ---------------------------   -----------          2
                         \         Node H    /        Node I
                       --------------------------    -------    1
                                   \         Node J    /
Root of Tree -->                 --------------------------     0


     Iî   thå abovå example¬   thå useò musô alwayó starô aô  thå 
rooô  oæ thå treå (Nodå J)®   Thió ió analogouó tï HELĞ Leveì  0¬ 
whicè ió wherå thå useò ió placå wheî hå issueó thå HELĞ Command®   
Tï geô tï Nodå C¬  foò example¬  thå  useò haó tï climâ thå  treå 
froí  Nodå  Ê tï Nodå È tï Nodå Æ tï Nodå  Ä tï  Nodå  C®    Thió 
woulä   bå  likå  thå  useò  enterinç  ´  Node-Typå   Informatioî 
Sections¬ iî whicè differenô HELĞ fileó arå successivelù loaded.

     No÷ thaô thå useò ió aô Nodå C¬  let'ó saù thaô hå wantó  tï 
gï  tï Nodå E®   Undeò thå HELĞ System¬  therå arå twï wayó tï dï 
this:

          1®    Jumğ  ofæ  oæ  thå treå anä theî climâ bacë uğ tï  
Nodå   E®  Here¬   thå useò woulä jumğ froí Nodå Ã tï Nodå Ê  anä 
theî gï tï Nodå È  tï Nodå Æ tï Nodå E®  Undeò HELP¬ thå useò caî 
dï  thió bù exitinç tï CP/Í anä theî  reissuinç thå HELĞ  Commanä 
oò bù issuinç thå Rooô Commanä (.)»   oncå aô  thå  rooô  oæ  thå 
tree¬   hå theî climbó  iô  agaiî  bù  enterinç  thå  appropriatå 
Informatioî Sections.

          2®    Climâ dowî thå treå anä theî bacë up®    Thå useò 
woulä  movå  froí Nodå Ã tï Nodå Ä tï Nodå Æ anä theî bacë uğ  tï 
Nodå  E®   Thå HELĞ useò caî gï tï thå previouó leveì bù  issuinç 
thå  Uğ Leveì (^© command®   Iî thió example¬  hå woulä Uğ  Leveì 
twicå anä theî gï bacë down.


              Moving Within An Information Section

     Oncå  thå useò ió withiî á textuaì Informatioî  Section¬  hå 
haó  severaì capabilitieó foò movinç withiî thió sectioî anä  ouô 
oæ thió section.


     First¬   tï movå ouô oæ aî Informatioî Section¬ thå useò caî 
returî  tï  thå  menõ (iæ thå currenô HELĞ filå  ió  Indexed©  oò 
returî tï CP/M®    Additionally¬   iæ thå useò ió noô oî thå rooô 
(HELĞ  Leveì  0)¬  hå caî returî tï thå previouó HELĞ  Leveì  (Uğ 
Level)®   Iæ  thå  useò ió noô iî aî Indexeä HELĞ  file¬   movinç 
forwarä  beyonä thå Enä oæ Informatioî (EOI© wilì returî  hií  tï  
CP/Í iæ hå ió aô HELĞ Leveì ° oò returî hií tï thå previouó  HELĞ 
Leveì iæ not.

     Tï movå withiî aî Informatioî Section¬ thå datá ió typicallù 
arrangeä sequentially®    Consequently¬ thå useò caî movå Forwarä 
tï  thå nexô Frame¬  Backwarä  tï thå previouó Frame¬   oò tï thå 
beginninç  oæ  thå  Informatioî  Section®   Naturally¬  thå  useò 
cannoô  movå  backwarä  beyonä thå beginninç oæ  thå  Informatioî 
Section®    Also¬   iæ thå useò trieó tï movå forwarä beyonä  thå 
Enä  oæ  Informatioî (EOI)¬   hå ió eitheò returneä tï thå  Menu¬ 
returneä  tï  CP/M¬  oò returneä tï thå previouó  HELĞ  Leveì  aó 
describeä above.



11.5  HELP: HELP Command Prompts

     Thå   followinç   arå  thå basiã promptó foò  useò   commanä  
whicè  HELĞ displayó tï thå useò anä theiò meanings.

^C=CP/M  ^=Level  .=Root  M=Menu  S=Start  L=Last  CR=Next -
    \        \       \        \       \       \       \__Goto Next
     \        \       \        \       \       \__Goto Last Frame
      \        \       \        \       \__Goto Start of Info Sec
       \        \       \        \__Goto Menu of HELP File
        \        \       \__Goto Root if NOT at Level 0
         \        \    (this is displayed only if NOT at Level 0)
          \        \__Goto Previous Level
           \           (this is displayed only if NOT at Level 0)
            \__Return to CP/M
         
  EOI   ^C=CP/M  ^=Level  .=Root  M=Menu  S=Start  L=Last  CR=Next -
   \        \________\_______\________\_______\_______\_______\
    \                         \__ Same As Above __\
     \__User is at the End of Information (end of Info Section)


Type  ^C=CP/M ^=Level .=Root or Enter Selection -
          \        \       \            \__Enter letter of desired
           \        \       \                Information Section
            \        \       \__Goto Root
             \        \    (this is shown only if NOT at Level 0)
              \        \__Goto Previous Level
               \           (this is shown only if NOT at Level 0)
                \__Return to CP/M


     Preceedinç   eacè  oæ  thå abovå promptó ió aî indicatoò  oæ  
thå  HELĞ Leveì anä Framå Numbeò thå useò ió currentlù at®   Thió 
indicatoò maù takå thå followinç forms:

<Nothing>
     \__The user is at the Menu of Level 0

fff:
 \__Current Frame Number within Information Section
      (the user is at Level 0)

Level lll/
       \__Current Level Number (The user is at a Menu Frame)
            (this is displayed only if the user is NOT at Level 0)

Level lll/fff:
       \   \__Current Frame Number within Information Section
        \__Current Level Number
             (this is displayed only if the user is NOT at Level 0)



                    Summary of User Commands

     Cmd  Meaning
      ^   Go to Previous Level
      .   Go to Root Level
      M   Go to Menu of Current HELP File
      S   Go to Start of Information Section
      L   Go to Previous Frame
     CR   (Carriage Return or Space) Go to Next Frame
     ^C   (Control-C) Return to CP/M



11.6  HELP: HELP Error Messages

     Thå   followinç   arå  thå  erroò messageó issueä  bù   HELĞ  
anä  theiò meanings:

HELP FATAL ERROR -- File not Found
     The specified HELP File cannot be found.

HELP FATAL ERROR -- File Name Contains Wild Car
     Thå  specifieä HELĞ Filå containó thå characteò "*¢ oò  "?"®  
Thió ió noô alloweä sincå iô specifieó aî ambiguouó name.

HELP ERROR -- Invalid Response
     The user issued an invalid command.

HELP ERROR -- EOF on HELP File
     Iî searchinç foò aî Informatioî Section¬  HELĞ raî intï  thå 
enä  oæ  thå HELĞ  File®    Thå  Indexeä HELĞ Filå ió  improperlù 
structureä (morå  indeø entrieó thaî Informatioî Sections).Š
HELP ERROR -- Not Possible to Backup Before Start of Info
     Aî   Ì  Commanä  waó issueä wheî thå currenô Framå  waó  thå 
beginninç  oæ thå currenô Informatioî Section.

HELP ERROR -- Node Level Limit Reached -- Aborting
     Thå  limiô  oæ thå nestinç oæ thå HELĞ Leveló  ió  exceeded®  
HELĞ limitó thå numbeò oæ HELĞ Leveló thaô caî bå traverseä tï 1° 
(default¬   whicè  caî bå changed)¬   anä aî attempô waó madå  tï 
enteò HELĞ Leveì 1± (oò defaulô « 1).

HELP ERROR -- Invalid File Name in Load
     Aî  Informatioî  Sectioî whicè ió tryinç tï loaä á nodå  (gï  
tï  nexô HELĞ Level© containó aî invaliä filå name.

HELP ERROR -- No Higher Level to Return to
     Aî  attempô waó madå tï gï tï á HELĞ Leveì previouó tï  HELĞ 
Leveì ° (Ş Commanä issueä froí HELĞ Leveì 0).

HELP ERROR -- Not Enough Room for HELP File
     Thå  selecteä  HELĞ  Filå  ió toï largå  tï  loaä  intï  thå 
availablå memorù iî  thå user'ó computeò system®    Thå HELĞ Filå 
shoulä bå reduceä iî size» usinç HELĞ Leveló (Nodå references© iî 
thå Informatioî Sectionó ió á  gooä waù tï dï this.



11.7  HELP: How to Write HELP Files

     Fileó   useä  bù  thå HELĞ prograí arå eitheò  simplå  CP/M-
standarä   fileó oæ   ASCIÉ   texô  oò  ASCIÉ   fileó   generateä  
bù   thå  Worä   Staò   texô editor/formatter®   Theså files¬  aó 
mentioneä  above¬  arå  oæ twï basiã  typesº  indexeä   anä  non-
indexed¬   anä  eacè typå ió relateä tï thå otheò anä ió  oæ  thå 
samå basiã format.

                     Grouping of Information

     Informatioî displayeä tï thå useò ió groupeä bù thå indeø iî  
indexeä  HELĞ   fileó anä maù alsï bå groupeä bù lineó  beginninç 
witè Forí Feeä (^L© characters®   Groupinç ió aî effectivå waù tï 
logicallù  organizå   informatioî  sï thaô meaninç wilì  bå  morå 
cleaò tï thå useò anä unitó oæ informatioî wilì noô pasó  betweeî 
screeî displays.

     Thå  informatioî  displayeä  tï thå useò ió  organizeä  intï 
logicaì  unitó  calleä Informatioî Sectionó anä  screeî  displayó 
(onå  screeî fulì oæ  text© calleä Frames®   Usinç texô  editors¬ 
thå  useò  caî  creatå  hió  owî  HELĞ  fileó  anä  organizå  hió 
informatioî aó hå desireó foò displaù tï thå HELĞ user.


                     Non-Indexed HELP Files

     Non-indexeä  HELĞ  fileó arå simplå ASCIÉ fileó whicè  starô 
witè  á coloî (:© aó thå firsô characteò oæ thå filå anä  consisô 
oæ ASCIÉ texô (witè eacè linå terminateä bù á carriagå returî anä 
linå feeä characteò combination)®   Thå informatioî  iî  sucè   á 
helğ  filå consistó oæ alì texô afteò  thå  leadinç coloî  uğ  tï 
eitheò  thå  terminatinç end-of-filå marë (control-Z© oò  á   ne÷ 
linå whicè startó witè á colon.


                       Indexed HELP Files

     Indexeä   HELĞ   fileó arå simplå ASCIÉ fileó whicè  dï  noô 
starô  witè   á coloî  (:©  aó thå firsô characteò oæ  thå  file®   
Thió  typå  oæ  HELĞ  filå consistó  oæ onå oò morå normaì  ASCIÉ 
texô  lineó  aó  thå  firsô  lineó  oæ   thå  filå   followeä  bù 
informatioî  sectionó  whicè  begiî  witè  á  linå  whoså   firsô 
characteò  ió  á  coloî  anä enä witè eitheò thå firsô  linå   oæ  
thå  nexô informatioî sectioî oò thå enä oæ thå file.


            Tree Structures within Indexed HELP Files

     Aó  mentioneä above¬  thå Indexeä HELĞ Filå ió divideä  intï 
Informatioî Sections¬  wherå eacè Informatioî Sectioî startó witè 
á coloî (:)®   Therå arå twï basiã typeó oæ Informatioî Section:

          1®    Informatioî Sectionó containinç textuaì material» 
thió typå oæ Informatioî Sectioî simplù containó readinç materiaì 
whicè  ió  organizeä intï Frames¬  wherå á Framå ió equaì tï  onå 
screeî display.
          2®    Informatioî  Sectionó whicè referencå otheò  HELĞ 
files»  thió  typå oæ Informatioî Sectioî beginó witè twï  colonó 
(::©  insteaä  oæ  onå  aó iî  (1© above»   thå  twï  colonó  arå 
immediatelù followeä bù thå namå oæ thå HELĞ filå (thå HELĞ  filå 
typå maù bå optionallù specified).

     Tï illustrate¬   thå followinç outlineó thå structurå oæ thå 
twï typeó oæ Informatioî Sections:


 :Title for Type 1 Information Section
     <text>
 : [next Information Section]

               Figure:  A Text (Type 1) Information Section


 ::HLPFILE                    <-- for HLPFILE.HLP
 : [next Information Section]

 ::HLPFILE.TYP                <-- for HLPFILE.TYP
 : [next Information Section]Š
11.8  HELP: The Tree Structure of HELP

		-- Basic HELP File --
  |Info Sect 1	|Info Sect 2	|Info Sect 3	|Info Sect 4 |
  | Text	| HELP File	| Text		| HELP File  |
 		   /      \			   /    \
 	    -- SubHelp File 1 --	    -- SubHelp File 2 --
        |Info Sect 1 |Info Sect 2 |	|Info Sect 1 |Info Sect2|
 	| Text	     | HELP File  |	| Text	     | Text     |
 			/    \
 		-- SubSubHelp File 1 --
 	|Info Sect 1 |Info Sect 2 |Info Sect 3 |
 	| Text	     | HELP File  | HELP File  |
 			/  \	     /    \
 	-- Sub3Help File 1 --  -- Sub3Help File 2 --
 	|Info Sect |		|Info Sect 1 |Info Sect 2|
 	| Text     |		| Text	     | HELP File |
 						/    \
 					-- Sub4Help File --
 				|Info Sect 1 |Info Sect 2|
 				| Text	     | Text	 |

                   Figure:  Sample HELP File Structure

     Thå    abovå  diagraí  ió  meanô  tï  illustratå  ho÷   treå 
structureó  caî  bå implementeä undeò Versionó 1.´ anä beyonä  oæ 
HELP®   Aó  thå useò caî see¬  á ne÷  nodå oæ thå treå ió createä 
wheneveò  á HELĞ filå ió referenceä bù  aî  Informatioî   Sectioî 
(aó  opposeä tï simplù havinç texô iî thå  Informatioî  Section)®   
Eacè   nodå  becomeó thå baså oæ á ne÷ tree¬   whicè itselæ   maù 
contaiî referenceó tï otheò HELĞ files.

     Froí  thå previouó diagraí (feeì freå tï refeò bacë tï  it)¬  
SubHelğ Leveì  ³ containó twï HELĞ files®    Theså caî bå entereä 
froí   Informatioî Sectioî ² anä Informatioî Sectioî ³ oæ SubHelğ 
Leveì  2®    Bù  simplù enterinç  onå oæ  theså  twï  Informatioî 
Sections¬   thå  appropriatå HELĞ filå  ió loadeä anä thå useò ió 
placeä aô thå nexô level®   Froí theså HELĞ  files¬ thå  useò maù 
movå  withiî  thå HELĞ filå itselæ oò movå uğ  tï  thå   previouó 
leveì  (naturally¬  thå  useò  alwayó haó thå optioî tï  exiô  tï 
CP/M).



11.9  HELP: Sample HELP Files Illustrating Use of Tree Structure

     Thå   followinç   Frameó   sho÷ thå sourcå  tï  threå   HELĞ  
Files¬   nameä DEMO.HLP¬  DEMO2.HLP¬  anä DEMO3.HLP®  DEMO.HLĞ ió 
provideó  thå  Rooô Nodå tï á treå whicè includeó  DEMO2.HLĞ  anä 
DEMO3.HLĞ aó subnodes®    Additionally¬  DEMO3.HLĞ haó á  subnodå 
whicè   referenceó  DEMO.HLP¬    sï  wå  havå  á  recursivå  treå 
structure.


                                 DEMO.HLP
 TEST 1 - OK                  <-- Menu
 TEST 2 - SIMPLE NEST
 TEST 3 - INVOLVED NEST
 TEST 4 - OK
 :TEST 1                      <-- First Info Section (Text)
 THIS
 IS 
 TEST
 1
 ::DEMO2                      <-- 2nd Info Section (Node)
 ::DEMO3                      <-- 3rd Info Section (Node)
 :TEST 4                      <-- 4th Info Section (Text)
 TO BE, OR NOT TO BE, THAT IS THE QUESTION!
 ...
 TO TAKE ARMS AGAINST A SEA OF TROUBLES AND BY OPPOSING END THEM.
 TO DIE, TO SLEEP ... TO SLEEP, PERCHANCE TO DREAM.
 AYE, THERE'S THE RUB!  FOR IN THAT SLEEP, WHAT DREAMS MAY COME!

                                DEMO2.HLP
 :TEST 2                       <-- No Menu -- 1 Info Section
 THIS
 IS
 TEST
 2

                                DEMO3.HLP
 TEST 3A                       <-- Menu
 TEST 3B
 TEST 3C
 :TEST 3A                      <-- First Info Section (Text)
	THIS
	IS
	TEST
	3A
	the rain in Spain falls mainly in the plain

 :TEST 3B                      <-- 2nd Info Section (Text)
	THIS
	IS
	TEST
	3B
 ::demo                        <-- 3rd Info Section (Node)



