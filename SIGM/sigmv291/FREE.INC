function FreeSpace(Drive: char): integer;
{ This function finds and reads the bit map for the selected
  disk, and returns the space remaining in K.  Drive is in the
  range A..P, and must be legal for your system.
  If the Drive passed is not in A..P  then current drive is used. }

  const
    Current_Drive = 25;
    Set_Drive     = 14;

  var
    HomeDrive, blkshf : byte;
    blkmax, free : integer;

  begin
    HomeDrive := BDOS(Current_Drive); {get the present disk #}
    if Drive in ['A'..'P'] then
      BDOS(Set_Drive,ord(Drive)-$41);  {drive must be in 0..15}
    INLINE (
       $0E/$1F/       {        LD      C,CURDPB    ;Request DPB}
       $CD/$05/$00/   {        CALL    BDOS}
       $23/           {        INC     HL}
       $23/           {        INC     HL}
       $7E/           {        LD      A,(HL)      ;Get block shift}
       $32/BLKSHF/    {        LD      (BLKSHF),A}
       $23/           {        INC     HL          ;Bump to block max}
       $23/           {        INC     HL}
       $23/           {        INC     HL}
       $5E/           {        LD      E,(HL)      ;Get max block #}
       $23/           {        INC     HL}
       $56/           {        LD      D,(HL)}
       $EB/           {        EX      DE,HL}
       $22/BLKMAX/    {        LD      (BLKMAX),HL ;Save it}
       $0E/$1B/       {        LD      C,GALLOC    ;Get address of allocation vector}
       $CD/$05/$00/   {        CALL    BDOS}
       $EB/           {        EX      DE,HL}
       $2A/BLKMAX/    {        LD      HL,(BLKMAX) ;Get its length}
       $23/           {        INC     HL}
       $01/$00/$00/   {        LD      BC,0        ;Init block count to 0}
       $D5/           {GSPBYT: PUSH    DE          ;Save alloc address}
       $1A/           {        LD      A,(DE)}
       $1E/$08/       {        LD      E,8         ;Set to process 8 blocks}
       $17/           {GSPLUP: RLA                 ;Test bit}
       $38/$01/       {        JR      C,NOTFRE}
       $03/           {        INC     BC}
       $57/           {NOTFRE: LD      D,A         ;Save bits}
       $2B/           {        DEC     HL          ;Count down blocks}
       $7D/           {        LD      A,L}
       $B4/           {        OR      H}
       $28/$08/       {        JR      Z,ENDALC    ;Quit if out of blocks}
       $7A/           {        LD      A,D         ;Restore bits}
       $1D/           {        DEC     E           ;Count down 8 bits}
       $20/$F2/       {        JR      NZ,GSPLUP           ;Do another bit}
       $D1/           {        POP     DE          ;Bump to next byte..}
       $13/           {        INC     DE          ;..of alloc. vector}
       $18/$EA/       {        JR      GSPBYT      ;Process it}
       $D1/           {ENDALC: POP     DE          ;Clear allocation vector pointer from stack}
       $69/           {        LD      L,C         ;Copy blocks to hl}
       $60/           {        LD      H,B}
       $3A/BLKSHF/    {        LD      A,(BLKSHF)  ;Get block shift factor}
       $D6/$03/       {        SUB     3           ;Convert from sectors to K}
       $28/$04/       {        JR      Z,SAVFRE    ;Skip shifts if 1K blocks - return free in HL}
       $29/           {FREKLP: ADD     HL,HL       ;Multiply blocks by K/BLK}
       $3D/           {        DEC     A}
       $20/$FC/       {        JR      NZ,FREKLP}
       $22/FREE/      {SAVFRE: LD      (Free),HL   ;Save the free space for later}
       $00);
    BDOS(Set_Drive, HomeDrive);  {reselect original disk}
    FreeSpace := free;
  end;

