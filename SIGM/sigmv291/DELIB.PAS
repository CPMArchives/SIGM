Program DeLibrary;

{ DeLibrary for Turbo Pascal
  Version 1.00
  By Bela Lubkin

  This program extracts all the files from a library.  It does only the bare
  minimum of error checking.  It does not provide any options.  The only thing
  it does is split library files.  If you have any interest in using
  libraries, you are directed to:
    For CP/M-80: LU310.BIN (LU310.COM) in DL2 of SIGCPM, GO PCS-47 or R SIGCPM
    For CP/M-86: LU8645.BIN (LU8645.CMD) in DL9 of SIGCPM
    For MS-DOS:  LU8643.BIN (LU8643.EXE) in DL6 of IBM PC SIG, GO PCS-131 or
                 R IBMSIG.
  (Do a S/KEY:LIBRARY/DES to find all associated documents and to possibly
   find newer versions)
}

  Const
    BufSecs=200;   { Number of 128 byte sectors to allocate for buffer }

  Type
    Sector=Array [0..127] Of Byte;
    String80=String[80];
    FileName=String[20];

  Var
    LibFile,OutFile: File;
    LibName,OutName: FileName;
    DirBuffer: Sector;
    I,J,Offset,DirLength,FirstSec,NumSecs,Secs: Integer;
    Buffer: Array [1..BufSecs] Of Sector;

  Procedure Error(S: String80);

    Begin
      Write(S);
      {$I-} Close(LibFile); {$I+}
      Halt;
    End;

  Begin
    Write('Enter library file name: ');
    ReadLn(LibName);
    If Pos('.',LibName)=0 Then LibName:=LibName+'.LBR';
    Assign(LibFile,LibName);
    {$I-} Reset(LibFile); {$I+}
    If IOResult<>0 Then Error('Library file not found');
    BlockRead(LibFile,DirBuffer,1);
    If DirBuffer[0]<>0 Then Error('Not a library file');
    For I:=1 To 11 Do If DirBuffer[I]<>32 Then Error('Not a library file');
    If (DirBuffer[12]<>0) Or (DirBuffer[13]<>0) Then
      Error('Not a library file');
    DirLength:=DirBuffer[14]+256*DirBuffer[15];
    If DirLength=0 Then Error('Not a library file');
    For I:=1 To DirLength*4-1 Do
     Begin
      Offset:=32*(I Mod 4);
      If Offset=0 Then
       Begin
        Seek(LibFile,I Div 4);
        BlockRead(LibFile,DirBuffer,1);
       End;
      If DirBuffer[Offset]=$FF Then Error('Done!')
      Else If DirBuffer[Offset]=0 Then
       Begin
        OutName:='';
        For J:=1 To 8 Do If DirBuffer[Offset+J]<>32 Then
          OutName:=OutName+Chr(DirBuffer[Offset+J]);
        OutName:=OutName+'.';
        For J:=9 To 11 Do If DirBuffer[Offset+J]<>32 Then
          OutName:=OutName+Chr(DirBuffer[Offset+J]);
        WriteLn('Extracting file ',OutName);
        Assign(OutFile,OutName);
        {$I-} Rewrite(OutFile); {$I+}
        If IOResult<>0 Then Error('Could not create '+OutName);
        FirstSec:=DirBuffer[Offset+12]+256*DirBuffer[Offset+13];
        NumSecs:=DirBuffer[Offset+14]+256*DirBuffer[Offset+15];
        Seek(LibFile,FirstSec);
        While NumSecs>0 Do
         Begin
          If BufSecs<NumSecs Then Secs:=BufSecs
          Else Secs:=NumSecs;
          BlockRead(LibFile,Buffer,Secs);
          BlockWrite(OutFile,Buffer,Secs);
          NumSecs:=NumSecs-Secs;
         End;
        Close(OutFile);
       End;
     End;
    Error('Done!');
  End.
