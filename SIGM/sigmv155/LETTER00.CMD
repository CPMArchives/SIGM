* LETTER00.CMD------------------ VERSION 1.0 ------------------ OCTOBER 30, 1982
* by  Allen Cleveland                                     CLEVELAND & ASSOCIATES
*
*       FORM LETTER NUMBER 1 (written for demonstration purposes)
*
?? DATELINE
?
?
? NAMELINE
? ADDLINE:1
? ADDLINE:2
? CITYLINE
?
?
? 'Dear '+ NAME:1 + ':'
?
? 'This is a example of a "form " letter which is typed only once in the form'
? 'of a dBASE II command file with the file name of LETTERXX.CMD, where "XX"'
? 'is a two character code identifying that particular "form". You MUST have'
? 'a file name of "LETTERXX" because the command file which "calls" this form'
? 'letter file looks ONLY for a file with the first six characters of the '
? 'name as "LETTER". The file "type" MUST be "CMD" so that control can be'
? 'transfered to the file for the actual printing of your form.'
?
? NAME:1 + ', you will also note that each line which you wish to be printed'
? 'as it is typed, MUST be proceeded by a "?", a space and the quote mark.'
? 'The last character to be typed in any line MUST be followed by another'
? 'quote mark. The single quote "delimeters" are necessary to indicate'
? 'to dBASE exactly what is to printed as a "literial". Therefore you will'
? 'note that any other use of the single quote is not allowed...( Use of'
? 'single quotes as the string delimeter allows the use of regular "double"'
? 'quotation marks to be embedded in the text. The "square" brackets may'
? 'be used instead of the single or double quotes..however in any given line'
? 'you must be consistant as to what is the delimeter.)'

? 'As illustrated in the date and address at the beginning and the use of'
? 'a first name in the paragraph above, you may also have any previously'
? 'defined "variable" also printed in the body of the "form".'
?
? 'When including "variables" in the body of such forms take care to make'
? 'sure that you know their "type" and the number of spaces required for'
? 'their printing. For instance should you want to control the number of'
? 'columns required to print out a number (previously defined as a "numeric"'
? 'variable), you can change its type to a "character" variable and define'
? 'the number of columns required for printing by use of the "STR" function.'
?
? 'You must also be aware of the length of you lines and how they relate to'
? 'the paper size and the margins as set up on your printer. The FORM/PRT.CMD'
? 'file prompts for a left margin set at col. # 5...ONLY because it is assumed'
? 'that the form lines will be be approximately 75 characters (max.) in length'
? 'and hence the printed "text" will be centered on a 8 1/2" wide sheet (85'
? 'characters total at 10 pitch such as this example).'
?
?
? 'Sincerely,'
?
?
? 'J. Rufus Flywheel, President'
? 'FORM LETTERS UNLIMITED INC.'
RETURN
* NOTE: DO NOT DO AN "EJECT" HERE AS FORM/PRT.CMD ALWAYS ISSUES
* AN "EJECT" COMMAND AS SOON AS CONTROL IS RETURNED TO IT.
* YOU MUST HOWEVER MAKE THE LAST COMMAND OF THIS FILE A "RETURN"
* SO THAT CONTROL WILL BE TRANSFERED BACK TO  FORM/PRT.CMD FOR
* CONTINUATION OF THE PRINTING OF THE NEXT LETTER(S).
