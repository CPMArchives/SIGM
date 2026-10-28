FORTRAN-80 COMMAND SWITCHES

SWITCH          ACTION

/O              Prints the listing addresses in octal
/H              Prints the listing addresses in hex (default).
/N              Object code is not listed only the source code.
/R              overrides the /N switch - .REL file generated.
/P              alloctes 256 extra bytes to the stack.
/M              Generates ROMABLE code.

FORTRAN-80 RUNTIME ERRORS.

a)Warnings

ID              Description

A2              Both arguments of ATAN2 are 0
BE              Exponent overflow
BI              Buffer exceeded.
CN              Conversion overflow in Real -> Integer.
DE              Exponent overflow
EX              Illegal exponent
FW              Format field width too small
GL              Computed GOTO too large.
GS              Computed GOTO too small.
IB              Input buffer exceeded.
IN              Input record too long.
IS              Integer size too large.
OB              Output buffer exceeded.
OV              Arithmetic Overflow.
RC              Negative repeat count in Format statement.
SN              Argument of SIN too large.
TL              Too many left parentheses in Format.

Fatal Runtime Errors.

ID              Description.

DF              Disk full on Write.
DO              Illegal increment or limit in DO loop.
DT              Data type not in Format Specification.
DZ              Divide by zero
EF              EOF encountered in Read.
FN              File not found in open.
ID              Illegal Format descriptor.
IO              Illegal I/O.
IR              Real in Integer format field.
IT              I/O transmission error.
FO              Format field width is zero.
LG              Negative or zero value in Log function.
ML              Missing left parenthesis in Format.
MP              Missing period in Format.
OM              Out of Memory.
SQ              Negative value to SQRT function.
UN              Logical Unit Number too large.
