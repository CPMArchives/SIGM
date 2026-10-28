program terms(0);
{$c-}
{$m-}
{$f-}
{$R-}
{$u-}
{program to maintain file of terms for diagnosis			}
{last revision: 8/11/82							}



{COPYRIGHT 1982 (C) BY CRAIG RUDLIN, M.D.  ALL RIGHTS RESERVED.        }







{This program establishes a file of terms and their associated code, for use}
{in encoding the patient's diagnoses.  The program establishes two files:   }
{1- file arranged by term   and  2- file arranged by code        	    }
{Each file is organized as a binary tree to facilitate location of the term}
{or code, without having to maintain the file in alphabetical or numerical }
{order, respectively.  Hence it is VERY IMPORTANT that both the terms and  }
{their assigned codes are COMPLETELY RANDOMIZED --if they are not, the tree }
{degenerates into a linked list, which must be searched sequentially...very }
{slow!  The program allows for synonyms to have the same code, but does not }
{allow the same term to be entered into the file more than once.  Because   }
{synonyms are permitted, each code must be checked, and the user informed if}
{it has been used previously. The user may then enter a different code, or  }
{approve the use of the same code.  The program as written allows for 32K   }
{terms -- the limit is due to the fact that pascal z must use an integer as }
{the record number in a file, and the maximum integer is 32K.  		    }


{As written, the program searches the file of codes each time a new term is }
{entered, to insure that the code has not been used previously (and if so,  }
{that it is ok to use it again).  Obviously, this is slower than creating an}
{array of the codes used thus far, maintaining this array as a file on disk }
{reading it into memory at the beginning of the program, and updating the   }
{array and disk file, whenever changes are made.  This more expedient proce-}
{dure was not adopted in this version for two reasons: 1- it limits the size}
{of the term file to 9600 terms, because the maximum size of an array in    }
{Pascal Z is 32K;  2- this program is written to run under both CP/M and MP/M}
{MP/M does not permit more than 48K of TPA per user.  Hence, under certain  }
{situations, the use of the array might cause the program to be too large for}
{MP/M.  I recommend that if you are planning to use the program only with   }
{CP/M, and to have more than several hundred terms, but not more than 9600  }
{that you define the following types and vars and use the array:	    }

{types: xnumbers: record code:array[1..128] of integer; end;
        fxnumbers:file of xnumbers;

 var	fnumbers:fxnumbers;
	numbers :xnumbers;
	findcode: array[1..9600] of integer;				   }


{--------------------------------------------------------------------------}

label 1;

const
ucase = true;
lower_case = false;
letters_only = true;
alphanumeric = false;


type

byte = 0..255;
$string80 = string 80;

char20 =  array[1..20] of char;
char21 =  array[1..21] of char;
char10 =  array[1..10] of char;
char28 =  array[1..28] of char;
char30 =  array[1..30] of char;
char6  =  array[1..6]  of char;
char4  =  array[1..4]  of char;
char2  =  array[1..2]  of char;
data   =  array[1..80] of char;

XTERMS =	RECORD
		TERM: 	char21;
		code:	real;
		LEFT:	INTEGER;   {pointers for tree}
		RIGHT:  INTEGER;
		PARENT: INTEGER;
		PRINT_FLAG: BOOLEAN;
		end;

FXTERMS = FILE OF XTERMS;


xtest_units = (fake,NONE,OTHER,UGMS_DL,MGS_DL,MEQ_L,IU,PER_CC,
		MG_24_HR,GM_24_HR,MG_KG,GM,ML_MIN,CELLS_CC,UNITS_ML,
	       NGMS_ML,UUNIT_ML,NGMS_DL,PGMS_ML,MEQ_ML,MICRO_IU,
	       NGM_ML_HR,ML,MG_TV,MUNITS_ML);


{currently there are 25 possible units}



var {*******}

assigned_units:xtest_units;

fnumterms,FTERMS:FXTERMS;
newterms,TERMS:XTERMS;


recursive,found,terminate,end_of_field,end_of_input,end_of_record:boolean;

needs_units,error:boolean;

last_rec,reference_number:integer; {passes record number between procedures}

blanks: data;

numrecs:integer;

b:byte;
command_line:array[1..80] of char;

num_file,term_file:array[1..12] of char;


{***************** external procedures and functions *****************} 

procedure clear_screen;external;
procedure move_cursor(x,y:byte);external;
procedure erase_lines(starting_line,number_of_lines:byte);external;
procedure prompt(x,y,length:byte;P:$string80;
	         protected_field_desired:boolean);external;
procedure keyin(var cix:char);external;
procedure menu;external;
procedure add(change,numfile:boolean);external;
procedure change;external;
procedure delete(change,numfile:boolean);external;
procedure find(code:boolean;flag:byte);external; 
procedure show_information(hardcopy:boolean);external;
procedure get_info(new:boolean);external;

procedure check_code(new:boolean;xcode:real;recno:integer);external;
procedure initialize;external;

procedure search(recno:integer;key:real;key1:char21;delete:boolean);external;

procedure print_terms(hardcopy:boolean);external;

procedure make_file_name;external;
procedure get_file(invalid:boolean);external;
function  xvalid:boolean;external;

function query(x,y:byte;message:$string80):boolean;external;
function input(x,y,len:byte;xucase,xletters_only:boolean;field:data):data;
	 external;
function password:boolean;external;


function realtoarray(number:real):data;external;
function arraytoreal(field:data):real;external;

{*************************  main program *****************************}
begin

{password; debug--leave out until installed in mpm}

terminate:=false;

initialize;

while terminate = false do menu;

end.

