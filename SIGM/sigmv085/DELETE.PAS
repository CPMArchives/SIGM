External btree::delete(1);

PROCEDURE DeleteLeftMost( VAR Employee : apointer;
			  VAR DeleteName : shorty );
{ delete the leftmost node in the tree and }
{  returns its value in DeleteName	   }
BEGIN
  IF Employee^.Left <> NIL THEN
    DeleteLeftMost( Employee^.Left, DeleteName )
  ELSE BEGIN
    DeleteName := Employee^.details.Name;
    Employee := Employee^.right
  END
END{of DeleteLeftMost};


PROCEDURE DeleteRoot( VAR Employee : apointer );
{ deletes the root of the nonempty tree by replacing it  }
{ by its successor (or child) if it has only one, or     }
{ replacing its value by that of the leftmost descendant }
{ of the rightmost subtree.				 }
VAR
  DeletedName : shorty;
BEGIN
  IF Employee^.Left = NIL THEN
    Employee := Employee^.right
  ELSE IF Employee^.right = NIL THEN
    Employee := Employee^.Left
  ELSE BEGIN
    DeleteLeftMost( Employee^.right, DeletedName );
    Employee^.details.Name := DeletedName
  END
END{of DeleteRoot};


PROCEDURE Delete( VAR Employee : apointer;
		      key : shorty );
{ delete key from the tree--if it is not }
{ in the tree, do nothing		  }
BEGIN
  IF Employee = NIL THEN
    WRITELN ( bell, key, ' not in data file' )
  ELSE IF key = Employee^.details.Name THEN
    DeleteRoot( Employee )
  ELSE IF key < Employee^.details.Name THEN
    Delete(Employee^.Left, key )
  ELSE IF key > Employee^.details.Name THEN
    Delete( Employee^.right, key )
END;

 .
LAY

