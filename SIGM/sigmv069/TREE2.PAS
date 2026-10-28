PROGRAM Tree2;
	{ Maintain a sorted list in a binary tree }
TYPE
	Tree = ^Node;
	$STRING12 = STRING 12;
	Node = RECORD
		Name : $STRING12;
		Left, Right : Tree
		END;

VAR
	k : $STRING12;
	Root,t : Tree;
	ch,c : CHAR;

	{--------------------------------------------}
PROCEDURE InitTree (VAR  t : Tree);
	{ initialize the tree }
BEGIN
	t := NIL
END;
	{---------------------------------------------}
PROCEDURE INSERT (VAR t : Tree;
			k : $STRING12);
	{ insert k into the Tree t; if it is there
		already then do nothing}
BEGIN
	IF t = NIL THEN 
	BEGIN
	  NEW (t);
	  t^.Name := k;
	  t^.left := NIL;
	  t^.right := NIL
	END
	ELSE
	  IF k = t^.Name THEN
	    WRITELN (k,' already in tree')
	  ELSE
	    IF k < t^.Name THEN
	      Insert (t^.left, k)
  	    ELSE
	      IF k > t^.Name THEN
		Insert (t^.right, k)
END;
	{------------------------------------}
PROCEDURE DeleteLeftMost (VAR t : Tree;
			  VAR DeleteName : $STRING12);
	{ delete the leftmost node in the tree t and
	    return its value in deleteName}
BEGIN
	IF t^.Left <> NIL THEN
	  DeleteLeftMost (t^.left, DeleteName)
	ELSE
	  BEGIN
	    DeleteName := t^.Name;
	    t := t^.right
	  END
END;
	{------------------------------------}
PROCEDURE DeleteRoot (VAR  t : Tree);
	{ deletes the root of the nonempty tree t by 
	  replacing it by its successor (or child)if
	  it has only one, or replacing its value by 
	  that of the leftmost descendant of the 
	  rightmost subtree}
VAR
	DeletedName : $STRING12;
BEGIN
	IF t^.left = NIL THEN
	  t := t^.right
	ELSE
	  IF t^.right = NIL THEN
	    t := t^.left
	  ELSE
	    BEGIN
		DeleteLeftMost (t^.right, DeletedName);
		t^.Name := DeletedName
	    END
END;
	{--------------------------------------}
PROCEDURE Delete (VAR t : Tree;
		   k : $STRING12);
	{delete k from the tree t--if it is not
	 in the tree, do nothing}
BEGIN
	IF t = NIL THEN
	  WRITELN ( k, ' not in tree')
	ELSE
	  IF k = t^.Name THEN
	    DeleteRoot (t)
	  ELSE
	    IF k < t^.Name THEN
	      Delete (t^.left, k)
	    ELSE
		IF k > t^.Name THEN
		  Delete (t^.right, k)
END;
	{------------------------------------}
PROCEDURE Preorder( p : Tree );
	{prints data from left side of tree to right} 
BEGIN
	IF p <> NIL THEN
	BEGIN
		WRITELN( p^.Name );
		Preorder( p^.Left );
		Preorder( p^.Right )
	END
END;		{preorder}
	{------------------------------------}
PROCEDURE Inorder( p : Tree );
	{prints data outer to inner of tree}
BEGIN
	IF p <> NIL THEN
	BEGIN
		Inorder( p^.Left );
		WRITELN(p^.Name );
		Inorder( p^.Right )
	END
END;		{inorder}
	{-------------------------------------}
PROCEDURE Postorder( p : Tree );
	{prints data from leaves first then branchs'}
BEGIN
	IF p <> NIL THEN
	BEGIN
		Postorder( p^.Left );
		Postorder( p^.Right );
		WRITELN( p^.Name )
	END
END;		{postorder}
	{--------------------------------------}
BEGIN		{ MAIN PROGRAM BLOCK }
	InitTree (t);
	WRITELN ('Type i (insert) or d (delete) followed ');
	WRITELN ('      by a NAME ( "*" to Quit)');
	READ (c);
	WHILE (c = 'i') or (c = 'd') DO
	  BEGIN
		READLN (k);
		CASE c OF
		  'i' : Insert (t,k);
		  'd' : Delete (t,k)
		END;
		WRITELN; WRITELN;
		Preorder(t); 
		WRITELN;
		Inorder(t);
		WRITELN;
		Postorder(t);
		WRITELN;
		WRITELN ('Type i (insert) or d (delete)');
		WRITELN ('followed by an integer item, or');
		WRITELN ('anything else to quit:  ');
		READ (c)
	  END
END.
