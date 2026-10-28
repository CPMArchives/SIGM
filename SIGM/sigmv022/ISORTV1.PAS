PROGRAM InsertionSortLinked;
(************************************************
 *						*
 *	Insertion Sort with Linked List		*
 *						*
 *	From the book - PASCAL An Introduction  *
 *	to Methodical Programming		*
 *	Authors:				*
 *	W. Findlay and D.A. Watt		*
 *						*
 * 	Entered by Ray Penley - 8 Dec 79	*
 *						*
 *	Heavely modified entire program to	*
 *	be interactive with the console.	*
 *						*
 ************************************************)
(* NOTE - This program can be eaisly adapted to sort single *
 * characters, integer numbers, real numbers, months, or any*
 * other items which can be ordered! It is only necessary to*
 * change the definition of the type identifier ITEMS, the  *
 * body of the procedure ReadItem, and possibly the body of *
 * WriteItems.						    *)

CONST
  NameLength	= 10;
  INPUT = 0;	(* PASCAL/Z ver 2.0 *)
  space = ' ';

TYPE
  Items  = PACKED ARRAY[1..NameLength] OF CHAR;
  ItemRecords  = record
		   item  :Items;
		   Next  :^ItemRecords
		 end;
  ItemPointers = ^ItemRecords;

VAR
  ListHead  :ItemPointers;
  Newitem   :Items;
  EndOfList,
  done,
  error	    :boolean;

PROCEDURE ReadItem(VAR  item  :Items);
(*	Valid Alphanumeric chars are:
	 the space - CHR(32) to
	 the tilde - CHR(126)   *)
VAR
 pos  :0..NameLength;
 dummy,
 ch   :Char;

      Procedure ClearReadItem;
      begin
	FOR pos:=1 TO NameLength DO item[ pos ]:= space;
	pos := 0
      end;

begin
  ClearReadItem;
  EndOfList := FALSE;
  error := FALSE;
  REPEAT
    IF pos < NameLength THEN  (* GET VALID INPUTS *)
      begin
      READ( CH );
      If ch = '$' then
	EndOfList := true
      Else
	begin
	IF CH IN [' ' .. '~'] THEN (* valid character *)
	  begin
          pos := pos +1;
          item [pos] := CH
          end(* if *)
	Else
	  begin
          WRITELN(' Alphanumerics only - TURKEY');
	  ClearReadItem;
	  ERROR:=TRUE
          end(* else *)
        end(* else *)
      end(* If *)
    Else	(*   ERROR   *)
      begin
      READLN( dummy );
      WRITELN(' Maximum of ', NameLength:4, ' characters please!');
      ClearReadItem;
      ERROR:=TRUE
      end(* Else *)
  UNTIL EOLN(Input) OR EndOfList;
end(* SCANNER *);

PROCEDURE InsertItem( Newitem  :Items);
VAR
  entry,
  PriorEntry,
  Newentry 	:ItemPointers;
  Searching	:boolean;
begin
  (* FIND the position where the New item will be Inserted *)
  entry := ListHead;
  Searching := TRUE;
  While Searching and (entry <> NIL) DO
    WITH entry^ DO
      IF Newitem < item then
	Searching := FALSE
      Else
	begin
	PriorEntry := entry;
	entry := Next
	end;
(* CREATE the New entry and Insert it in position *)
  New(Newentry);
  Newentry^.item := Newitem;
  Newentry^.Next := entry;
  IF entry = ListHead then
    ListHead := Newentry
  Else PriorEntry^.Next := Newentry;
end;  (* InsertItem *)

PROCEDURE WriteItems;
VAR
  entry  :ItemPointers;
begin
  entry := ListHead;
  While entry <> NIL DO
    WITH entry^ DO
      begin
      Writeln(item);
      entry := Next
      end
end; (* WriteItems *)

begin  (* MAIN PROGRAM *)
  ListHead := NIL;  (* MAKE the LIST EMPTY *)
  Writeln(' ':12,'Insertion Sort Using a Linked List');
  writeln;writeln;writeln;
  writeln('Enter your list after the prompt.');
  writeln('Enter a dollar sign <$> when complete.');
  writeln;writeln;writeln;

  REPEAT
    write('>>');
    ReadItem(Newitem); (* READ the First Item *)
    If NOT error then
      If NOT EndOfList then
	(* Insert the New item in its correct position *)
	InsertItem(Newitem);
  UNTIL EndOfList;

  Writeln(' ':12,'The Sorted List');
  writeln;
  (* Write all the Items in order *)
  WriteItems
end. (* SORTLIST *)
