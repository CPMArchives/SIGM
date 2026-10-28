{ A program to convert WordStar format files to normal ASCII files.  It
  removes all high bits, tosses out any control characters except CR,
  LF, and TAB, and optionally expands tabs.
  Requires the command line argument processor in CLA.PAS.
  Syntax:
    DWS inputname [outputname] [/t]
  -  Bela Lubkin
}

{$ICLA.PAS}  { Include the command line parse routines }

  Type
    FileName=String[20];

  Const
    BufSize=150;
    BufByteSize=19200;

  Var
    Source: File;
    Dest: Text;
    SourceName,DestName,Switch: FileName;
    Buffer: Array [1..BufByteSize] Of Byte;
    B: Byte;
    RecsToRead,Remaining,I,Pos: Integer;
    Done,DeTab: Boolean;

  Begin
    SourceName:=CommandLineArgument('Input file name: ','/',False);
    DestName:=CommandLineArgument('Output file name: ','CON:',False);
    Switch:='/';
    DeTab:=False;
    While Switch<>'' Do
     Begin
      Switch:=CommandLineArgument('','',True);
      If Switch='' Then
      Else If (Switch='/T') Or (Switch='/t') Then DeTab:=True
      Else
       Begin
        WriteLn('Unrecognized switch "',Switch,'"');
        Halt;
       End;
     End;
    Assign(Source,SourceName);
    {$I-} Reset(Source); {$I+}
    If IOResult<>0 Then
     Begin
      WriteLn('File "',SourceName,'" not found.');
      Halt;
     End;
    Assign(Dest,DestName);
    {$I-} ReWrite(Dest); {$I+}
    If IOResult<>0 Then
     Begin
      WriteLn('File "',DestName,'" could not be created.');
      Halt;
     End;
    Remaining:=FileSize(Source);
    While Remaining>0 Do
     Begin
      If BufSize<=Remaining Then RecsToRead:=BufSize
      Else RecsToRead:=Remaining;
      BlockRead(Source,Buffer,RecsToRead);
      Pos:=0;
      Done:=False;
      For I:=1 To 128*RecsToRead Do
       Begin
        B:=Buffer[I] And $7F;
        If B In [0..8,11,12,14..25,27..31,127] Then B:=128;
        If Not Done And (B<>26) Then
         Begin
          If (B=9) And DeTab Then
           Begin
            Write(Dest,Copy('         ',1,8-(Pos And 7)));
            Pos:=(Pos+8) And $FFF8;
           End
          Else If B<>128 Then Write(Dest,Chr(B));
          If B=13 Then Pos:=0
          Else If (B>31) And (B<127) Then Pos:=Pos+1;
         End
        Else Done:=True;
       End;
      Remaining:=Remaining-RecsToRead;
     End;
    Close(Source);
    Close(Dest);
  End.
