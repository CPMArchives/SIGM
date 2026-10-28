function absol(u : newreal) : newreal; external;

function isequal(u, v : newreal) : boolean; external;

function isgreater(u, v : newreal) : boolean; external;

function islower(u, v : newreal) : boolean; external;

function iseqgreat(u, v : newreal) : boolean; external;

function iseqlower(u, v : newreal) : boolean; external;

function isinteger(u : newreal) : boolean; external;

function add(u, v : newreal) : newreal; external;

function sub(u, v : newreal) : newreal; external;

function multp(u, v : newreal) : newreal; external;

function divde(u, v : newreal) : newreal; external;

function modu(u, v : newreal) : newreal; external;

procedure do_read(var u : extdatum; var w : newreal); external;

procedure do_write(u : newreal); external;

function byteadd(var carry : carrytyp; a, b : byte) : byte; external;

function bytesub(var carry : carrytyp; a, b : byte) : byte; external;

function byt1mul(var carry : byte; mcand, mlier : byte) : byte; external;

procedure bytemul(var carry, pprod : byte; mcand, mlier : byte); external;

procedure byt1div(var newcarry, rem : byte; divs1, divs2, divd : byte);
external;


