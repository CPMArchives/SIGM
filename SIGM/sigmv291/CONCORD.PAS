{$A-}
Program Concordance;

Const
  MaxWordLen = 20;
  InName = 'OUT.';
  OutName = 'Con:';

Type
  CharIndex = 1..MaxWordLen;
  CountType = 1..MaxInt;
  WordType = Array [CharIndex] Of Char;
  Pointer = ^EntryType;
  EntryType =
    Record
      Left,Right : Pointer;
      Word : WordType;
      Count : CountType;
    End;

Var
  WordTree : Pointer;
  NextWord : WordType;
  Letters  : Set Of Char;
  Input,OutPut : Text;

Procedure ReadWord ( Var PackedWord : WordType );

Const
  Blank = ' ';

Var
  Buffer    : Array [CharIndex] Of Char;
  CharCount : 0..MaxWordLen;
  Ch        : Char;

Begin
  If Not Eof(Input)
    Then
      Repeat
        Read(Input,Ch)
      Until Eof(Input) Or (Ch In Letters);
  If Not Eof(Input)
    Then
      Begin
        CharCount := 0;
        While Ch In Letters Do
          Begin
            If CharCount < MaxWordLen
              Then
                Begin
                  CharCount := CharCount + 1;
                  Buffer[CharCount] := Ch
                End;
            If Eof(Input)
              Then Ch := Blank
              Else Read(Input,Ch)
          End;
        For CharCount := Charcount + 1 To MaxWordLen Do
          Buffer[CharCount] := Blank;
        PackedWord := Buffer
      End;
End; { ReadWord }

Procedure PrintWord (PackedWord : WordType);

Var
  CharPos : 1..MaxWordLen;

Begin
  For CharPos := 1 To MaxWordLen Do
    Write(OutPut,PackedWord[CharPos])
End; { PrintWord }

Procedure MakEntry ( Var Tree  : Pointer;
                         Entry : WordType);

Begin
  If Tree = Nil
    Then
      Begin
        New(Tree);
        With Tree^ Do
          Begin
            Word := Entry;
            Count := 1;
            Left := Nil;
            Right := Nil;
          End;
      End
    Else
      With Tree^ Do
        If Entry < Word
          Then MakEntry(Left,Entry)
        Else If Entry > Word
          Then MakEntry(Right,Entry)
        Else Count := Count + 1
End; { MakEntry }

Procedure PrintTree ( Tree : Pointer );

Begin
  If Tree <> Nil
    Then
      With Tree^ Do
        Begin
          PrintTree(Left);
          PrintWord(Word);
          Writeln(OutPut,Count);
          PrintTree(Right)
        End
End; { PrintTree }

Begin { Concordance }
  Assign(Input,InName);
  Assign(OutPut,OutName);
  Reset(Input);
  ReWrite(OutPut);
  Letters := ['A'..'Z','a'..'z'];
  WordTree := Nil;
  While Not Eof(Input) Do
    Begin
      ReadWord(NextWord);
      If Not Eof(Input)
        Then MakEntry(WordTree,NextWord)
    End;
  PrintTree(WordTree);
  Close(Input);
  Close(OutPut);
End.

