
              SOFTWARE UPGRADES to SYSLIB and ZCPR2
                          4 March 1983

                               by
                          Richard Conn

               SYSLIB 2.5 Upgrade from SYSLIB 2.4
                ZCPR2 Mod 0.3 Upgrade from ZCPR2


1.0  Baselines

     The  following baseline software is established by this  up-
grade:

               SYSLIB 2.5
               ZCPR2 Mod 0.3


2.0  Associated Upgrade Documentation

     The  following  documentation  provides  additional  upgrade 
information from the previous baselines.   The previous baselines 
were the release versions.

Documentation:  SYSLIB 2.4 Changes (from SYSLIB 2.1) 
Location of Doc:  SYSLIB User and Reference Manual for SYSLIB 2.4 
          by Richard Conn, 4 Feb 1983
     Pages:  Dist-4 to Dist-5


3.0  Changes in Existing Documentation

     No changes to the existing documentation are required to the 
documentation associated with the previous upgrades.


4.0  Files Affected by this Upgrade

     The following files are provided with this upgrade:

Filename.Typ Size K    Filename.Typ Size K    Filename.Typ Size K
-------- --- ------    -------- --- ------    -------- --- ------
DU2     .ASM     72    LDIRZ   .COM      6    SSORT   .MAC     14  
ZCPR2   .ASM     56    MKDIR   .COM      8    SVERSION.MAC      1  
DU2     .COM     10    ZCPRHDR .LIB     15    SYSLIB  .REL     14  
    9 Files Occupying   196K,     9 Files on Disk and    45K Free

     These files have the following CRC values:

    1 File: DU2     .ASM -- Size:    72K -- CRC: 5F 2C
    2 File: DU2     .COM -- Size:    10K -- CRC: E7 32
    3 File: LDIRZ   .COM -- Size:     6K -- CRC: B2 25
    4 File: MKDIR   .COM -- Size:     8K -- CRC: C2 7F
    5 File: SSORT   .MAC -- Size:    14K -- CRC: E3 32
    6 File: SVERSION.MAC -- Size:     1K -- CRC: 2D 3E
    7 File: SYSLIB  .REL -- Size:    14K -- CRC: D4 8D
    8 File: ZCPR2   .ASM -- Size:    56K -- CRC: 5B F1
    9 File: ZCPRHDR .LIB -- Size:    15K -- CRC: 3C 5B


5.0  Reasons for Changes to Programs and Files

     ZCPR2 Change Summary:
          Mod 0.1 corrected a bug in single-character input
                    associated with the ERA and REN functions
          Mod 0.2 corrected a reliability problem with the ^S
                    (output pause) function which showed itself
                    when the TYPE command executed without paging
          Mod 0.3 enhanced responsiveness of ZCPR2 in the rare
                    case where a file which was not $$$.SUB in
                    the directory A$ contained a "$" character
                    in its name; in this rare case, unnecessary
                    disk thrashing occurred, but ZCPR2 continued
                    to perform correctly
       Files Affected:  ZCPR2.ASM, ZCPRHDR.LIB

     ZCPR2 Utility Change Summary:
          DU2 contained a bug in that the queue status report
                    was calling the wrong numeric output routine
          LDIRZ was upgraded via assembly when an error in the
                    M80 assembler caused a bug to be introduced
                    in the SSORT Module of SYSLIB 2.4; no change
                    to the source of LDIRZ was required
          MKDIR was affected by the same bug in the SSORT Module
                    of SYSLIB 2.4
       Files Affected:  DU2.ASM, DU2.COM, LDIRZ.COM, MKDIR.COM

     SYSLIB Change Summary:
          SSORT did not define the storage area required by the
                    identifier "I" and the M80 assembler did not
                    flag this as an error; instead M80 assigned
                    the value 8 to the symbol "I", causing memory
                    locations 8 and 9 to be modified by SSORT;
                    the error was corrected by changing the name
                    of the symbol "I" to "IDX" and assigning
                    storage to this symbol
          SVERSION was upgraded to reflect the new version number
          SYSLIB.REL is Version 2.5 of SYSLIB
       Files Affected:  SSORT.MAC, SVERSION.MAC, SYSLIB.REL
