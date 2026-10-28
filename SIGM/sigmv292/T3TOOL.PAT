 These are the changes that I made in toolu.pas so that the shell in
 tptool.lbr works when compiled with TP vers 3.01. Otherwise the shell
 command line would always have some junk in it from the last command.
 These changes were tested under TP vers. 3 on a Morrow MD-3 running
 CP/M 2.2. I used proclist.shl as the test. Simply replace the lines
 given with their new versions. Except for line three, all of the other
 lines are in the function getkbd.

 IN FILE TOOLU.PAS  change the given lines
 3:
   old:   Version ='1.9.e';
   new:   Version ='1.9.f';
 274:
   old:   if (eof(TRM)) then kbdn:=-1
   new:   if (eof(kbd)) then kbdn:=-1
 275:
   old:   else if eoln(TRM) then begin
   new:   else if eoln(kbd) then begin
 276:
   old:     kbdn:=kbdn-1;kbdline[kbdn]:=NEWLINE
   new:     kbdline[kbdn]:=NEWLINE
 287:
   old:     read(TRM,ch);kbdline[kbdn]:=ord(ch);
   new:     read(KBD,ch); kbdline[kbdn]:=ord(ch);
 290:
   old:     if (kbdline[kbdn]<>DELETE1) and (kbdline[kbdn]<>DELETE2) then
   new:     if (kbdline[kbdn]<>DELETE1) and (kbdline[kbdn]<>DELETE2) then
              write(ch)
 304:
   old:     reset(TRM);
   new:     reset(kbd);

 All that I did was to replace the TRM device with the KBD device. I don't
 have access to an MS-DOS machine right now so if someone else could check
 that it would be appreciated.

device. I don't
 have access to an 