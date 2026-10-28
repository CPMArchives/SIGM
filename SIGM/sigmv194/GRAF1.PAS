{$-V}
{****************************************************************************
 *                                                                          *
 *              PLOT Version 3.3 Compatible Pascal Library                  *
 *                                                                          *
 *                  Copyright 1984 by Thomas E. Speer                       *
 *                       All rights reserved.                               *
 *         Released to the Public Domain for Non-commercial use only        *
 *                                                                          *
 *             This file contains procedures and functions for              *
 *             access to the lowest level graphics functions.               *
 *                                                                          *
 ****************************************************************************}


{-------------------------------------------------------------------------}
{                 global graphics variables and constants                 }
CONST
    BUFFSIZE = 255;
    FIXVAL   = 32767;

TYPE
    filename = STRING[11];
    bufftype = STRING[ BUFFSIZE ];
    textline = STRING[ 80 ];
    vecfile  = TEXT;

VAR
    buffer: bufftype;
    colour, nxchar, nychar, nxline, nbuff : INTEGER;
    xmin,  xmax,  ymin,  ymax, sxleft, sxrt, sybot, sytop: REAL;
    scale: ARRAY [1..4] of REAL;
    chxsz, chysz, chrot, xpos, ypos: REAL;
    vecunit :vecfile;
{                 global graphics variables and constants                 }

{-------------------------------------------------------------------------}
FUNCTION rx( sxi:REAL ):REAL;
{       This function does a linear conversion between the real world
        and screen X coordinates.
        inputs:
                        sxi     screen Y coordinate
        outputs:
                        rx      real world coordinate
}
BEGIN
    rx := scale[1] * (sxi-sxrt) + xmin;
END;

{-------------------------------------------------------------------------}
FUNCTION ry( syi:REAL ):REAL;
{       This function does a linear conversion between the real world
        and screen Y coordinates.
        inputs:
                        syi     screen Y coordinate
        outputs:
                        ry      real world coordinate
}
BEGIN
    ry := scale[2] * (syi-sybot) + ymin;
END;

{-------------------------------------------------------------------------}
FUNCTION sx( rxi:REAL ):REAL;
{       This function does a linear conversion from the real to the
        screen x coordinates.
        inputs:
                rx      real world coordinate
        outputs:
                sx      screen x coordinate
}
BEGIN
    sx := (rxi - xmin)/scale[1] + sxleft;
END;

{-------------------------------------------------------------------------}
FUNCTION sy( ryi:REAL ):REAL;
{       This function does a linear conversion from the real to the
        screen y coordinates.
        inputs:
                ry      real world coordinate
        outputs:
                sy      screen y coordinate
}
BEGIN
    sy := (ryi - ymin)/scale[2] + sybot;
END;

{-------------------------------------------------------------------------}
PROCEDURE swindo ( sxlti,sxrti,syboti,sytopi:REAL );
{       This procedure sets the screen window
        inputs:         sxlti   value at left   edge of window (screen units)
                        sxrti   value at right  edge of window (screen units)
                        syboti  value at bottom edge of window (screen units)
                        sytopi  value at top    edge of window (screen units)
        outputs:
                        none returned
}
VAR
    t:REAL;

BEGIN
    sxleft := sxlti;
    sxrt   := sxrti;
    sybot  := syboti;
    sytop  := sytopi;

    t := sxrt - sxleft;
    IF ( sytop - sybot < t) THEN t := sytop - sybot;
    IF ( t < 0.0001 ) THEN
        Write(CON, 'Screen window too small.  Size =', t )
    ELSE IF ( (xmax - xmin = 0) OR (ymax - ymin = 0) ) THEN
        Write(CON,'Real window has 0 size.  Scale factors not calculated')
    ELSE BEGIN
        scale[1] := (xmax - xmin)/(sxrt - sxleft);
        scale[2] := (ymax - ymin)/(sytop - sybot);
    END
END;
    
{-------------------------------------------------------------------------}
PROCEDURE rwindo( xmini, xmaxi, ymini, ymaxi:REAL );
{       This procedure sets the real world window for scaling purposes
        inputs:
                        xmini   value at left   edge of window (user units)
                        xmaxi   value at right  edge of window (user units)
                        ymini   value at bottom edge of window (user units)
                        ymaxi   value at top    edge of window (user units)
        outputs:
                        none returned
}
BEGIN
    xmin := xmini;
    xmax := xmaxi;
    ymin := ymini;
    ymax := ymaxi;
    
    swindo( sxleft, sxrt, sybot, sytop );
END;

{-------------------------------------------------------------------------}
PROCEDURE concat2(VAR strng1:bufftype; nchar1:INTEGER; VAR strng2:bufftype;
                nchar2:INTEGER; VAR strng3:bufftype);
{     This procedure concatenates portions of strng1 and strng2 into strng3
        inputs:
                strng1  string for first postion
                nchar1  number of characters in strng1
                strng2  string for second position
                nchar2  number of characters in strng1
        outputs:
                strng3  concatenated string
}
BEGIN
    strng3 := Concat( Copy(strng1,1,nchar1), Copy(strng2,1,nchar2) );
END;

{------------------------------------------------------------------------}
PROCEDURE buffout(VAR outunit:vecfile; outbuf:bufftype; size:INTEGER);
{       This procedure writes the buffer to the indicated file.
        inputs:
                outunit file pointer for output
                outbuf  string (may contain '/0' characters!)
                size    number of characters to send out
        outputs:
                none returned
}
VAR
    i: INTEGER;
    c: CHAR;

BEGIN
    FOR i := 1 TO size DO BEGIN
        c := Copy( outbuf,i,1 );
        Write( outunit, c);
    END
END;

{-------------------------------------------------------------------------}
PROCEDURE writecmd ( cmd:bufftype; cmdlen:INTEGER );
{       This procedure adds a command to the buffer and writes it if full.
        inputs:
                cmd     input command string
                cmdlen  length of command string
        outputs:
                none returned
}
BEGIN
    IF (cmdlen + nbuff < BUFFSIZE) THEN BEGIN
        concat2 (buffer, nbuff, cmd, cmdlen, buffer);
        nbuff := nbuff + cmdlen;
        END
    ELSE BEGIN
        buffout( vecunit, buffer, nbuff);
        nbuff := 0;
        buffer:= '';
        concat2 (buffer, nbuff, cmd, cmdlen, buffer);
        nbuff := cmdlen;
    END
END;


{------------------------------------------------------------------------}
PROCEDURE erase;
{       This procedure causes the picture to be set to the currently selected
        color.
        inputs:
                none
        outputs:
                none returned
}
BEGIN
    writecmd ( 'E', 1);
END;

{------------------------------------------------------------------------}
PROCEDURE fill( x1, y1, x2, y2, yf:REAL);
{       This procedure fills in a solid area between a line segment and
        a horizontal line.
        inputs:
                x1,y1   coordinates for start of line segment
                x2,y2   coordinates for end   of line segment
                yf      height of horizonal level
        outputs:
                none returned
}
VAR
    fxy: INTEGER;
    cmd: STRING[11];

BEGIN
    cmd := 'F';
    fxy := Trunc( x1 * FIXVAL);                 { convert to fixed point }
    cmd := cmd + Chr(fxy MOD 256);              { load low  byte of integer }
    cmd := cmd + Chr((fxy DIV 256) MOD 256);    { load high byte of integer }
    fxy := Trunc( y1 * FIXVAL);                 { convert to fixed point }
    cmd := cmd + Chr(fxy MOD 256);              { load low  byte of integer }
    cmd := cmd + Chr((fxy DIV 256) MOD 256);    { load high byte of integer }
    fxy := Trunc( x2 * FIXVAL);                 { convert to fixed point }
    cmd := cmd + Chr(fxy MOD 256);              { load low  byte of integer }
    cmd := cmd + Chr((fxy DIV 256) MOD 256);    { load high byte of integer }
    fxy := Trunc( y2 * FIXVAL);                 { convert to fixed point }
    cmd := cmd + Chr(fxy MOD 256);              { load low  byte of integer }
    cmd := cmd + Chr((fxy DIV 256) MOD 256);    { load high byte of integer }
    fxy := Trunc( yf * FIXVAL);                 { convert to fixed point }
    cmd := cmd + Chr(fxy MOD 256);              { load low  byte of integer }
    cmd := cmd + Chr((fxy DIV 256) MOD 256);    { load high byte of integer }

    writecmd( cmd, 11 );
    xpos := x2;
    ypos := y2;
END;

{------------------------------------------------------------------------}
PROCEDURE segmnt(x1,y1,x2,y2:REAL);
{       This function plots a line segment from (x1,y1) to (x2,y2).
        inputs:
                x1,y1   coordinates for start of segment
                x2,y2   coordiantes for end   of segment
        outputs:
                none returned.
}
VAR
    fxy:INTEGER;
    cmd:STRING[9];

BEGIN
    cmd := 'D';
    fxy := Trunc( x1 * FIXVAL);                 { convert to fixed point }
    cmd := cmd + Chr(fxy MOD 256);              { load low  byte of integer }
    cmd := cmd + Chr((fxy DIV 256) MOD 256);      { load high byte of integer }
    fxy := Trunc( y1 * FIXVAL);                 { convert to fixed point }
    cmd := cmd + Chr(fxy MOD 256);              { load low  byte of integer }
    cmd := cmd + Chr((fxy DIV 256) MOD 256);      { load high byte of integer }
    fxy := Trunc( x2 * FIXVAL);                 { convert to fixed point }
    cmd := cmd + Chr(fxy MOD 256);              { load low  byte of integer }
    cmd := cmd + Chr((fxy DIV 256) MOD 256);      { load high byte of integer }
    fxy := Trunc( y2 * FIXVAL);                 { convert to fixed point }
    cmd := cmd + Chr(fxy MOD 256);              { load low  byte of integer }
    cmd := cmd + Chr((fxy DIV 256) MOD 256);      { load high byte of integer }

    writecmd(cmd, 9);

    xpos := x2;
    ypos := y2;
END;

{-------------------------------------------------------------------------}
PROCEDURE gmove( x,y:REAL );
{       This function moves the present coordinates to a new location
        without plotting.
        inputs:
                x,y     coordinates for new location
        outputs:
                none returned
}
VAR
    fxy: INTEGER;
    cmd: STRING[5];

BEGIN    
    cmd := 'M';
    fxy := Trunc (x * FIXVAL);                  { convert to fixed point }
    cmd := cmd + Chr(fxy MOD 256);              { load low  byte of integer }
    cmd := cmd + Chr((fxy DIV 256) MOD 256);      { load high byte of integer }
    fxy := Trunc( y * FIXVAL);                  { convert to fixed point }
    cmd := cmd + Chr(fxy MOD 256);              { load low  byte of integer }
    cmd := cmd + Chr((fxy DIV 256) MOD 256);      { load high byte of integer }
    
    writecmd( cmd, 5 );
    xpos := x;
    ypos := y;
END;

{------------------------------------------------------------------------}
PROCEDURE vector( x,y:REAL );
{       This procedure plots a line segment from the present position
        to the given coordinates
        inputs:
                x,y     coordinates for end of segment
        outputs:
                none returned
}
VAR
    fxy:INTEGER;
    cmd:STRING[5];
    
BEGIN
    cmd := 'I';
    fxy := Trunc( x * FIXVAL);                { convert to fixed point }
    cmd := cmd + Chr(fxy MOD 256);            { load low  byte of integer }
    cmd := cmd + Chr((fxy DIV 256) MOD 256);  { load high byte of integer }
    fxy := Trunc( y * FIXVAL);                { convert to fixed point }
    cmd := cmd + Chr(fxy MOD 256);            { load low  byte of integer }
    cmd := cmd + Chr((fxy DIV 256) MOD 256);  { load high byte of integer }

    writecmd( cmd, 5 );
    xpos := x;
    ypos := y
END;

{------------------------------------------------------------------------}
PROCEDURE color(code: INTEGER);
{       This procedure sets the color to be used in plotting
        inputs:
                code    new color code
        outputs:
                none returned
}
VAR
    cmd: STRING[2];

BEGIN
    colour := code;
    cmd := 'C' + Chr(code MOD 256);
    
    writecmd ( cmd, 2 );
END;

{------------------------------------------------------------------------}
PROCEDURE gprint;
{       This procedure causes the picture to be printed
        inputs:
                none
        outputs:
                none returned
}
BEGIN
    writecmd ( 'O', 1 );
END;

{-------------------------------------------------------------------------}
PROCEDURE grfini;
{       This procedure terminates the plot and closes the file.
        inputs:
                none
        outputs:
                none returned
}
BEGIN
    IF (nbuff > BUFFSIZE-2) THEN BEGIN
        buffout( vecunit, buffer, nbuff);
        nbuff := 0;
        buffer := ''
    END;
    nbuff := nbuff + 1;
    buffer := buffer + 'O';
    nbuff := nbuff + 1;
    buffer := buffer + 'Q';
    buffout( vecunit, buffer, nbuff);
    Close( vecunit);
END;

{------------------------------------------------------------------------}
PROCEDURE grinit (name: filename);
{       This function initializes the plot package.
        inputs:
                name    name of disk file for output of vector commands
        outputs:
                a '0' is returned if unsuccessful in opening file name.
}
VAR
    cmd: STRING[5];

BEGIN
    Assign( vecunit, name );
    Rewrite( vecunit );
    nbuff := 0;
    buffer:= '';
    
    { output command stream to initialize memory map }
    cmd := 'C' + Chr(0)+ 'EC' + Chr(127);
    
    writecmd (cmd, 5);

    xmin   := 0.0;
    xmax   := 1.0;
    ymin   := 0.0;
    ymax   := 1.0;
    sxleft := 0.0;
    sxrt   := 1.0;
    sybot  := 0.0;
    sytop  := 1.0;
    chxsz  := 0.0125;
    chysz  := 0.02;
    chrot  := 0.0;
    xpos   := 0.0;
    ypos   := 0.0;
    scale[1]:=1.0;
    scale[2]:=1.0;
    scale[3]:=1.0;
    scale[4]:=0.0;
    nxchar  := 0;
    nychar  := 0;
    nxline  := 1;
END;

{-------------------------------------------------------------------------}
PROCEDURE gstrng(x, y:REAL; strng:textline);
{       This procedure will plot a string of hardware generated characters
        inputs:
                        x,y     starting coordinates for string
                        strng   string to be plotted
        outputs:
                        none returned
}
VAR
    fx,fy,nchar:INTEGER;
    cmd: STRING[86];

BEGIN
    nchar := Length(strng);

    IF (nchar > 0) THEN BEGIN
        fx := Trunc (x * FIXVAL);
        fy := Trunc( (y * FIXVAL));
        cmd := 'S';
        cmd := cmd + Chr(fx MOD 256);           { load low  byte of integer }
        cmd := cmd + Chr((fx DIV 256) MOD 256); { load high byte of integer }
        cmd := cmd + Chr(fy MOD 256);           { load low  byte of integer }
        cmd := cmd + Chr((fy DIV 256) MOD 256); { load high byte of integer }

        cmd := cmd + strng + Chr(13);
        nchar := nchar + 6;
        writecmd ( cmd, nchar );
    END
END;

{-------------------------------------------------------------------------}
PROCEDURE point( x,y:REAL );
{       This function plots a point at the given coordinates
        inputs:
                x,y     coordinates of point
        outputs:
                none returned
}
VAR
    fxy:INTEGER;
    cmd:STRING[5];
    
BEGIN
    IF ((Abs(x) <= 1.0) AND (Abs(y) <= 1.0 )) THEN BEGIN
        cmd :='P';
        fxy := Trunc( x * FIXVAL);                  { convert to fixed point }
        cmd := cmd + Chr(fxy MOD 256);              { load low  byte of integer }
        cmd := cmd + Chr((fxy DIV 256) MOD 256);    { load high byte of integer }
        fxy := Trunc( y * FIXVAL);                  { convert to fixed point }
        cmd := cmd + Chr(fxy MOD 256);              { load low  byte of integer }
        cmd := cmd + Chr((fxy DIV 256) MOD 256);    { load high byte of integer }

        writecmd( cmd, 5 );
        xpos := x;
        ypos := y
    END
END;

