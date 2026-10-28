

(*********************************************************)
(*                                                       *)
(* a program to transfer files between cp/m and ms-dos   *)
(* with a cp/m host system                               *)
(*                                                       *)
(* Written by David Koski     1985                       *)
(*            P.O. Box 1078                              *)
(*            Fort Bragg, CA  95437-1078                 *)
(*            707/964-0806                               *)
(*                                                       *)
(* This program is intended for private non-commertial   *)
(* use and is considered to be public domain material    *)
(*                                                       *)
(*********************************************************)



program Transfer;

const
  SecTrans          = true;     { sector translation for bios read/write }
  SO                = 0;        { offset added to sector number          }

  MinSector         = 0;
  MaxFATSize        = 1024;
  Vers              = 1.0;
  SectorSizeMax     = 512;
  BufferSize        = SectorSizeMax;
  MenuMargin        = 18;
  ClusterSizeMax    = 2048;
  NameSize          = 8;
  TypeSize          = 3;
  First             = true;
  Next              = false;
  EODirectory       = $FF;
  MTDirectory       = 1;
  FoundDir          = 0;

type
  SizeArray= Array[1..4] of Byte;
  Str20    = string[20];
  Bufr     = array[1..BufferSize] of char;
  CBufr    = array[1..ClusterSizeMax] of char;
  FATarray = array[1..MaxFATSize] of byte;
  FAT_ID   = (Unidentified,ss8spt,ds8spt,ss9spt,ds9spt,B_20);
  NameAry  = array[1..NameSize] of char;
  TypeAry  = array[1..TypeSize] of char;
  NameStr  = string[20];

  PC_FCB   = record
    Name:      NameAry;
    Extention: TypeAry;
    Attribute: byte;
    Rsrvd:     array[12..21] of byte;
    Time:      integer;
    Date:      integer;
    ClusterNo: integer;
    FileSize:  SizeArray;
    end;

  CpmFCB   = record
    DriveCode: byte;
    Name:      NameAry;
    Extention: TypeAry;
    Extent:    byte;
    S1,S2:     byte;
    RC:        byte;
    Rsrvd:     array[16..31] of byte;
    CR:        byte;
    R0,R1,R2:  byte;
    end;
var
  CPM_Buf:           array[1..128] of char;
  Done:              boolean;
  Selection:         char;
  I:                 integer;

  DefaultDisk:       integer;
  MS_DOS_Drive:      integer;
  CPM_Drive:         integer;
  CPM_DriveCh:       char;
  Track:             integer;
  Sector:            integer;

  SecsPerCluster:    integer;
  FAT:               FATarray;
  FATSize:           integer;
  SectorSize:        integer;
  RecordsPerSector:  integer;
  DirSecs:           integer;
  NTracks:           integer;
  NSectors:          integer;
  NClusters:         integer;
  Identity:          FAT_ID;

  FirstFATSector:    integer;
  FirstDirSector:    integer;
  FirstDataSector:   integer;
  FirstDataTrack:    integer;
  DirSector:         integer;
  DirTrack:          integer;
  DirSectorCount:    integer;
  SingleSided:       boolean;

  DOS_FCB:           ^PC_FCB;
  CPM_FCB:           CpmFCB;
  Buffer:            Bufr;
  DirBuffer:         Bufr;
  DirOffset:         integer;
  DirName:           NameStr;
  ClusterBuffer:     CBufr;
  MaxSector:         integer;
  OutFile:           File;
  BiosError:         boolean;
  VolumeName:        boolean;
  SubDirName:        boolean;



{$I TRANS-01.INC}
{$I TRANS-02.INC}
{$I TRANS-03.INC}
{$I TRANS-04.INC}
{$I TRANS-05.INC}



procedure EraseMS_DOS;
var
  FileName:          Str20;
  Next,I,Err:        integer;
  CPMFile:           File;
  Cl:                integer;
  Stop:              boolean;
begin
IdentifyMS_DOS;
if not (Identity = Unidentified) then
  begin
  ClrScr;
  writeln;
  write('File Name to Erase From MS-DOS: ');
  readln(FileName);
  writeln;
  Stop:= false;

  SearchFirst(FileName,Err);

  if (Err = $FF) then
    begin
    write('File Not Found, ');
    end
  else
    begin
    write('Erasing -');

    repeat
      writeln;
      for I:= 1 to NameSize do
        if not (DOS_FCB^.Name[I] = ' ') then
          write(DOS_FCB^.Name[I]);
      write('.');
      for I:= 1 to TypeSize do
        write(DOS_FCB^.Extention[I]);

      Cl:= DOS_FCB^.ClusterNo;
      if (Cl <= NClusters) then
        begin
        Next:= Cl;
        repeat
          Cl:= Next;
          Next:= FATPointer(Cl);
          SetFATPointer(Cl,0);
          until ((Next > NClusters) or (Next = 0));
        end;

      DOS_FCB^.Name[1]:= #$E5;
      WriteSector(DirSector,DirTrack,addr(DirBuffer));
      SearchNext(FileName,Err);
      Stop:= Break;
      until (Err = EODirectory) or Stop;

    writeln;
    writeln;
    end;
  if Stop then write('Aborted, ');
  PutFAT;
  Continue;
  end;
end;



(********************)
(*                  *)
(*   main program   *)
(*                  *)
(********************)



begin
ClrScr;
DefaultDisk:= bdos(25);

repeat
  gotoxy(1,5);
  write('Which Drive is the MS-DOS Disk in? ');
  read(KBD,Selection);
  write(upcase(Selection),':');
  MS_DOS_Drive:= ord(upcase(Selection)) - ord('A');
  writeln;
  write('Which drive is the  CP/M  Disk in? ');
  read(KBD,CPM_DriveCh);
  CPM_DriveCh:= upcase(CPM_DriveCh);
  Write(CPM_DriveCh,':');
  CPM_Drive:= ord(upcase(CPM_DriveCh)) - ord('A');
  BiosSelect(CPM_Drive);
  until not BiosError;

writeln;
Delay(500);
BiosSelect(DefaultDisk);
done:= false;

repeat
  Selection:= MainSelection;
  ClrScr;

  case Selection of
    '1': WriteMS_DOS;
    '2': ReadMS_DOS;
    '3': DirMS_DOS;
    '4': MapMS_DOS;
    '5': DirCPM;
    '6': EraseMS_DOS;
    '7': RestoreFAT;
    '8': Done:= True;
    end; (* case *)

  until Done;

end.
