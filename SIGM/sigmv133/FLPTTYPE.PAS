type
	carrytyp	= 0..1;
	signtype	= (plus, minus);
	digits		= 0..9;
	byte		= 0..255;
	fraction	= array[0..n] of byte;
	double_fraction = array[0..twicen] of byte;
	long_fraction	= array[0..twicenn] of digits;
	newinteger	= record
			  s  :  signtype;
			  f  :  fraction
			  end;
	newreal		= record
			  s  :  signtype;
			  f  :  fraction;
			  e  :  byte
		          end;
	extdatum	= record
			  s  :  signtype;
			  f  :  array[0..nn] of digits;
			  e  :  integer
			  end;
