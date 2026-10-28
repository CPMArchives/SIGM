External btree::order(3);


PROCEDURE Preorder( Employee : apointer );
{  prints data from left side of tree to right  } 
BEGIN
  IF Employee <> NIL THEN BEGIN
    DISPLAY( Employee );	{visit the root}
    Preorder( Employee^.Left );	{traverse the left subtree}
    Preorder( Employee^.Right )	{traverse the right subtree}
  END
END{of preorder};


PROCEDURE Inorder( Employee : apointer );
{  prints data outer to inner of tree  }
BEGIN
  IF Employee <> NIL THEN BEGIN
    Inorder( Employee^.Left );	{traverse the left subtree}
    DISPLAY( Employee );	{visit the root}
    Inorder( Employee^.Right )	{traverse the right subtree}
  END
END{of inorder};


PROCEDURE Postorder( Employee : apointer );
{  prints data from leaves first then branchs  }
BEGIN
  IF Employee <> NIL THEN BEGIN
    Postorder( Employee^.Left );	{traverse the left subtree}
    Postorder( Employee^.Right );	{traverse the right subtree}
    DISPLAY( Employee );		{visit the root}
  END
END{of postorder};
 .
**
