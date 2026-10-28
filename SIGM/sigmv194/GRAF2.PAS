{************************************************************************
 *                                                                      *
 *                        Copyright 1984 by                             *
 *                         Thomas E. Speer                              *
 *                       All rights reserved                            *
 *                                                                      *
 *       This file provides the ability to draw graphics characters,    *
 *               plot axes, and do whole rectangular grids.             *
 *                                                                      *
 ************************************************************************}

{------------------------------------------------------------------------}
PROCEDURE chset( xsize, ysize, theta: REAL );
{       This procedure sets the character size and orientation
        inputs:
                xsize   horizontal size of character
                ysize   vertical   size of character
                theta   clockwise rotation of character (0 := upright)
        outputs:
                none returned
}
VAR
    t: REAL;

BEGIN    
    chxsz := xsize;
    chysz := ysize;
    chrot := theta;
 
    t := theta/57.29578;
    scale[3] :=  cos( t );
    scale[4] :=  sin( t );
END;
    
{------------------------------------------------------------------------}
FUNCTION posang ( angle:REAL ):REAL;
{       This function returns an angle that is in the range 0 to 360 deg.
        inputs:
                angle   angle to be converted
        outputs:
                posang  converted angle
}
BEGIN
    IF ( (angle < 360.0) AND (angle >= 0.0)) THEN
        posang := angle
    ELSE BEGIN
        angle := angle - 360.0 *  Trunc(angle/360.0);
        IF (angle < 0.0 ) THEN angle := angle + 360.;
        posang := angle;
    END
END;

{------------------------------------------------------------------------}
PROCEDURE ticend( rmin,rmax, dr:REAL; VAR pr1,pr2:REAL );
{       This function calculates endpoints which are multiples of dr and
        lie between rmin and rmax.
        inputs:
                rmin,rmax       range of values along axis
                dr              increment used for axis
        outputs:
                *pr1,*pr2       new values corresponding to rmin,rmax
}
VAR
    r1,r2:REAL;

BEGIN
    r1 :=  Trunc( rmin/dr) * dr;
    r2 :=  Trunc( rmax/dr) * dr;
    
    IF ( (r1 < 0.0) OR (r2 < 0.0) ) THEN BEGIN
        IF ((r1>0.0) OR (r2>0.0)) THEN BEGIN
            pr1 := r1;
            pr2 := r2;
        END
        ELSE BEGIN
            IF ((dr<0.0) AND (r1>rmin)) THEN r1 := r1 + dr;
            IF ((dr>0.0) AND (r2>rmax)) THEN r2 := r2 - dr;
        END
    END
    ELSE BEGIN
        IF ((dr>0.0) AND (r1<rmin)) THEN r1 := r1 + dr;
        IF ((dr<0.0) AND (r2<rmax)) THEN r2 := r2 - dr;
    END;
    pr1 := r1;
    pr2 := r2;
END;

{------------------------------------------------------------------------}
FUNCTION dxdy( x1,x2:REAL; nx:INTEGER; VAR lblnum,lbldec:INTEGER ):REAL;
{       This function calculates a good engineering value for the
        increment between tic marks on an axis.
        inputs:
                x1,x2   minimum and maximum values to associated w/ axis
                nx      approximate number of intervals for axis
        outputs:
                dxdy    increment between tic marks
                lblnum  number of characters required for labels
                lbldec  number of characters after decimal point
}
VAR
    xlen,dx,dxlog,dxmant,t,ln10: REAL;
    dxexp: INTEGER;

BEGIN
    ln10 := ln(10.0);
    xlen := x2-x1;
    IF (xlen = 0.0) THEN BEGIN
        write(CON, 'zero length axis in dxdy. 0 returned');
        lbldec := 0;
        lblnum := 0;
        dxdy := 0;
    END
    ELSE BEGIN
        dx := Abs(  xlen/nx );   { calculate raw dx }
        dxlog :=  ln(dx)/ln10;
        dxexp := Trunc(dxlog);
        dxmant := dxlog - dxexp;
        IF (dxmant <= 0.0) THEN BEGIN
            dxexp := dxexp - 1;
            dxmant := dxmant + 1;
        END;
        dx := 1.;                               { select good engr. values }
        IF (dxmant > 0.18) THEN
            dx := 2.;
        IF (dxmant > 0.40) THEN
            dx := 5.;
        IF (dxmant > 0.88) THEN
            dx := 10.0;
        dx := dx * exp( ln10*dxexp ) * xlen/Abs(  xlen );

        dxlog := xlen;                         { how many digits in numbers? }
        IF (x1  <> 0.0)  THEN BEGIN
            t :=  Abs(  x1);
            IF (t > dxlog) THEN dxlog :=t;
        END;
        IF (x2  <> 0.0) THEN BEGIN
            t :=  Abs(  x2);
            IF (t > dxlog) THEN dxlog := t;
        END;

        dxlog :=  ln(dxlog)/ln10;
        IF (dxlog > 0.0 ) THEN
            lblnum := Trunc( dxlog + 1.0 )
        ELSE
            lblnum := 0;

        dxlog :=  Abs(  xlen);  { now get f format spec }
        IF (x1 <> 0.0) THEN BEGIN
            t :=  Abs(  x1);
            IF (t < dxlog) THEN dxlog := t;
        END;
        IF (x2 <> 0.0) THEN BEGIN
            t :=  Abs(  x2);
            IF (t < dxlog) THEN dxlog := t;
        END;
        t :=  Abs(  dx);
        IF (t < dxlog) THEN dxlog := t;

        dxlog :=  ln(dxlog)/ln10;
        IF (dxlog < 0.0) THEN 
            lbldec := Trunc( -dxlog + 1.0 )
        ELSE
            lbldec := 0;
        lblnum := lblnum + lbldec + 2;

        dxdy := dx;
    END
END;
        
{------------------------------------------------------------------------}
PROCEDURE gchar( cx,cy:REAL ;charin:CHAR );
{       This procedure will plot a graphic character at an arbitrary
        size and orientation.
        inputs:
                cx,cy   coordinates for lower left corner of char.
                charin  character to be plotted
        outputs:
                none returned

        Note: The elements of tchar have a specific format.  The lower 4
        bits contain the Y coordinate, the next 3 bits the X
        coordinate, and the high bit indicates whether or not the byte
        corresponds to a move or a line ("pen up" or "pen down"). The
        value 255 signals the end of the sequence of segments for a
        character.
}
CONST
    tchar:ARRAY [1..721] of BYTE = (                    { 721 elements }
       255,  56, 181,  51, 178, 255,  40, 166,  72, 198, 255,  40,
       162,  72, 194,   6, 230,   4, 228, 255,  56, 178,  87, 151,
       134, 149, 213, 228, 211, 147, 255, 104, 130,   8, 168, 166,
       134, 136,  68, 228, 226, 194, 196, 255,  98, 151, 168, 184,
       199, 198, 148, 147, 162, 178, 212, 255,   6, 151, 152, 136,
       135, 151, 255,  72, 182, 180, 194, 255,  40, 182, 180, 162,
       255,  21, 213,  39, 195,  71, 163, 255,  55, 179,  21, 213,
       255,  17, 162, 163, 147, 146, 162, 255,  21, 213, 255,  34,
       163, 147, 146, 162, 255,  88, 146, 255,  40, 200, 214, 212,
       194, 162, 148, 150, 168, 255,  38, 184, 178,  34, 194, 255,
        23, 168, 200, 215, 214, 147, 146, 210, 255,  23, 168, 200,
       215, 214, 197, 212, 211, 194, 162, 147, 255,  72, 194,  55,
       148, 212, 255,  88, 152, 150, 198, 213, 211, 194, 162, 147,
       255,  87, 200, 168, 151, 147, 162, 194, 211, 212, 197, 165,
       148, 255,  24, 216, 162, 255,  37, 197, 212, 211, 194, 162,
       147, 148, 165, 150, 151, 168, 200, 215, 214, 197, 255,  19,
       162, 194, 211, 215, 200, 168, 151, 150, 165, 197, 214, 255,
        23, 167, 166, 150, 151,  20, 164, 163, 147, 148, 255,  17,
       162, 163, 147, 146, 162,  22, 166, 165, 149, 150, 255,  87,
       149, 211, 255,  22, 214,  20, 212, 255,  23, 213, 147, 255,
        23, 168, 200, 215, 214, 180,  50, 177, 255,  23, 168, 200,
       215, 211, 194, 162, 147, 148, 165, 181, 178, 255,   2, 184,
       226,  20, 212, 255,   5, 197, 212, 211, 194, 130, 136, 200,
       215, 214, 197, 255,  87, 200, 152, 135, 131, 146, 194, 211,
       255,   2, 136, 200, 214, 212, 194, 130, 255,  88, 136, 130,
       210,  53, 133, 255,  88, 136, 130,  53, 133, 255,  87, 200,
       152, 135, 131, 146, 194, 211, 213, 181, 255,   2, 136,  88,
       210,  85, 133, 255,  40, 200,  56, 178,  34, 194, 255,  20,
       147, 162, 178, 195, 200,  56, 216, 255,   8, 130,  88, 133,
       210, 255,  24, 146, 210, 255,   2, 136, 181, 232, 226, 255,
         2, 136, 226, 232, 255,   7, 152, 216, 231, 227, 210, 146,
       131, 135, 255,   2, 136, 200, 215, 214, 197, 133, 255,   7,
       152, 216, 231, 228, 194, 146, 131, 135,  68, 226, 255,   2,
       136, 200, 215, 214, 197, 133,  53, 210, 255,  87, 200, 152,
       135, 134, 149, 197, 212, 211, 194, 146, 131, 255,   8, 232,
        56, 178, 255,  24, 147, 162, 194, 211, 216, 255,   8, 178,
       232, 255,   8, 146, 181, 210, 232, 255,   8, 226, 104, 130,
       255,  24, 180, 178,  88, 180, 255,   8, 232, 130, 226, 255,
        88, 184, 178, 210, 255,  24, 210, 255,  24, 184, 178, 146,
       255,  22, 184, 214, 255,   0, 224, 255, 102, 215, 216, 232,
       231, 215, 255,   5, 150, 182, 197, 195, 178, 146, 131, 148,
       196,  67, 210, 255,  24, 146, 194, 211, 212, 197, 149, 255,
        85, 165, 148, 147, 162, 210, 255,  88, 210, 162, 147, 148,
       165, 213, 255,  82, 162, 147, 148, 165, 197, 212, 148, 255,
        87, 200, 184, 167, 162,  21, 197, 255,  17, 160, 176, 193,
       197, 165, 148, 147, 162, 194, 255,  18, 152,  21, 181, 196,
       194, 255,  50, 181,  55, 184, 255,  18, 145, 160, 176, 193,
       197,  71, 200, 255,  24, 146,  20, 199,  37, 210, 255,  40,
       184, 178,  34, 194, 255,   2, 133,   4, 149, 165, 180, 178,
        52, 197, 213, 228, 226, 255,  18, 149,  20, 165, 197, 212,
       210, 255,  20, 165, 197, 212, 211, 194, 162, 147, 148, 255,
        16, 149, 197, 212, 211, 194, 146, 255,  80, 213, 165, 148,
       147, 162, 210, 255,  18, 149,  20, 165, 181, 196, 255,  19,
       162, 194, 211, 196, 164, 149, 166, 198, 213, 255,  40, 163,
       178, 194, 211, 212,  22, 182, 255,  21, 147, 162, 194, 211,
       213,  83, 226, 255,  21, 178, 213, 255,  21, 162, 180, 194,
       213, 255,  21, 194,  18, 197, 255,  21, 178,  85, 178, 161,
       144, 255,  21, 213, 146, 210, 255,  72, 184, 167, 166, 149,
       164, 163, 178, 194, 255,  48, 184, 255,  40, 184, 199, 198,
       213, 196, 195, 178, 162, 255,   7, 152, 168, 198, 214, 231,
       255  );    

    ichar:ARRAY [1..95] of INTEGER =  (                        { 95 elements }
         1,   2,   7,  12,  21,  32,  45,  57,  64,  69,  74,  81,
        86,  93,  96, 102, 105, 115, 121, 130, 142, 148, 158, 171,
       175, 192, 205, 216, 228, 232, 237, 241, 250, 263, 269, 281,
       290, 298, 305, 311, 322, 329, 336, 345, 351, 355, 361, 366,
       376, 384, 396, 406, 419, 424, 431, 435, 441, 446, 452, 457,
       462, 465, 470, 474, 477, 484, 497, 505, 512, 520, 529, 537,
       548, 555, 560, 569, 576, 582, 595, 603, 613, 621, 629, 636,
       647, 656, 665, 669, 675, 680, 687, 692, 702, 705, 715  );

VAR
    schar,cmd,ix,iy: BYTE;
    i: INTEGER;
    x,y,t: REAL;

BEGIN
    schar := Ord(charin) AND 127;

    IF (schar >= 32) THEN BEGIN

        i := schar - 31;
        i := ichar[i];

        WHILE tchar[i] < 255 DO BEGIN
            cmd := tchar[i];
            i  := i + 1;
            iy := cmd AND 15;
            ix := cmd AND 112;
            ix := ix DIV 16;
            x := ix * chxsz / 7.0;
            y := iy * chysz / 9.0;
            t := x;
            x := cx + scale[3]*t - scale[4]*y;
            y := cy + scale[4]*t + scale[3]*y;

            IF (cmd < 128) THEN
                gmove( x,y )
            ELSE
                vector( x,y )
        END
    END
END;

{------------------------------------------------------------------------}
PROCEDURE gwrite(x,y:REAL ;chars:textline; nchar:INTEGER);
{       This function plots a string of graphic characters with the
        preset orientation and size.
        inputs:
                x,y     coordinates for start of string (bottom left corner)
                chars   string to be plotted
        outputs:
                none returned
}
VAR
    i: INTEGER;
    
BEGIN
    FOR i := 1 TO nchar DO BEGIN
        gchar( x, y, chars[i] );
        x := x + chxsz*scale[3];
        y := y + chxsz*scale[4];
    END
END;

{------------------------------------------------------------------------}
PROCEDURE axis(r1,r2,dri,sx1,sy1,sx2,sy2,ticlen,ticang: REAL;
               lblnum,lbldec: INTEGER; lblang: REAL);
{       This procedure plots and labels a linear graph axis
        inputs:
                r1      real world value at start of axis
                r2      real world value at end of axis
                dri     real world increment for labels
                sx1,sy1 screen coordinates of start of axis
                sx2,sy2 screen coordinates at end   of axis
                ticlen  length of tic marks (screen units 0.0-->1.0)
                ticang  angle between horizontal and tic marks
                lblnum  number of characters in labels
                lbldec  number of digits right of decimal place
                lblang  angle between horizontal and labels
        outputs:
                none returned
}
VAR
    angtic,anglbl,lentic,xlen,ylen,rlen,dr,rtic,rend,xtic,ytic,
          angtst,xlabel,ylabel,t,radian,x,y,dtic: REAL;
    alabel:  STRING[20];
    stemp:  STRING[6];

BEGIN    
    radian := 57.29578;
    IF ((dri = 0.0) OR (r2-r1 = 0.0))  THEN BEGIN
        Write(CON, 'Zero value for real length or increment. Axis not plotted');
    END
    ELSE BEGIN
        IF (lblnum < 7) THEN lblnum := 7;
        IF ( ((r1<0.0) OR (r2<0.0)) AND (lblnum<8) ) THEN lblnum := 8;
        angtic := ticang;
        IF (ticlen < 0.0) THEN angtic := -angtic;
        angtic := posang (angtic);
        anglbl := posang (lblang);
        lentic := Abs( ticlen );
        xlen := sx2-sx1;
        ylen := sy2-sy1;
        rlen :=  r2-r1;
        dr := Abs( dri ) * Abs( rlen )/rlen;
        ticend(r1,r2,dr,rtic,rend);
        angtst := posang(angtic - anglbl);
        angtic := angtic/radian;
        anglbl := anglbl/radian;
        xtic := lentic * cos( angtic );
        ytic := lentic * sin( angtic );
        scale[3] :=  cos( anglbl );
        scale[4] :=  sin( anglbl );

        {       calculate offsets for labels     }

        IF ( (angtst < 45.0) OR         { tic is "left" of label }
             (angtst >= 315.0) )  THEN BEGIN
            xlabel := ( chxsz*scale[3] + chysz*scale[4])/2.0;
            ylabel := (-chysz*scale[3] - chxsz*scale[4])/2.0;
        END
        ELSE IF ( angtst < 135.0) THEN BEGIN    { tic is "below" label }
            t := (lblnum-lbldec-1) * chxsz;
            xlabel := -t*scale[3] - chysz*scale[4]/2.0;
            ylabel := -t*scale[4] + chysz*scale[3]/2.0;
        END
        ELSE IF ( angtst < 225.0) THEN BEGIN    { tic is "right" of label }
            t := ( lblnum + 0.5 ) *chxsz;
            xlabel := -scale[4]*chysz/2.0 - t*scale[3];
            ylabel := -scale[3]*chysz/2.0 - t*scale[4];
        END
        ELSE IF ( angtst < 315.0) THEN BEGIN    { tic is "above" label }
            t := (lblnum-lbldec-1) * chxsz;
            xlabel := -t*scale[3] + chysz*scale[4]*1.5;
            ylabel := -t*scale[4] - chysz*scale[3]*1.5;
        END;

        {  Draw Axis }

        segmnt( sx1,sy1, sx2,sy2 );
        WHILE ((dr<0.0)AND(rtic>=rend)) OR ((dr>0.0)AND(rtic<=rend)) DO BEGIN
            dtic := (rtic-r1)/rlen;
            x := xlen*dtic + sx1;
            y := ylen*dtic + sy1;
            gmove(x,y);
            x := x + xtic;
            y := y + ytic;
            vector(x,y);
            x := x + xlabel;
            y := y + ylabel;

            Str(rtic:lblnum:lbldec, alabel);
            gwrite(x, y, alabel, lblnum);
            rtic := rtic + dr;
        END;
        {  clean up static storage }
        t := chrot/radian;
        scale[3] :=  cos( t );
        scale[4] :=  sin( t );
    END
END;

{-------------------------------------------------------------------------}
PROCEDURE graph(xmini,xmaxi:REAL; nx:INTEGER; ymini,ymaxi:REAL;ny:INTEGER;
                sxl,sxr,syb,syt:REAL);
{       This procedure plots and labels a graph and establishes scale factors
        for future use.
        inputs:
                xmini,xmaxi     min & max real world values for x axis
                nx              approximate no. of intervals on x axis
                ymini,ymaxi     min & max real world values for y axis
                ny              approximate no. of intervals on y axis
                sxl,sxr         screen left & right coord. for graph area
                syb,syt         screen bottom & top coord. for graph area
        outputs:
                none returned
}
VAR
    dx,dy,tic,xdot,ydot,dxydot,xydot,ticnd: REAL;
    lblnum,lbldec: INTEGER;

BEGIN
    { Set Scale Factors }

    xmin := xmini;
    ymin := ymini;
    xmax := xmaxi;
    ymax := ymaxi;
    swindo(sxl,sxr,syb,syt);

    { Draw Axes }

    dx := dxdy(xmin,xmax,nx,lblnum,lbldec);
    nxchar := lblnum;
    axis(xmin,xmax,dx, sxl,syb,sxr,syb, chysz/2.,270.0, lblnum,lbldec,0.0);

    dy := dxdy(ymin,ymax,ny,lblnum,lbldec);
    nychar := lblnum;
    axis(ymin,ymax,dy, sxl,syb,sxl,syt, chxsz/2.,180.0, lblnum,lbldec,90.0);

    { Do Vertical Dotted Lines }

    ticend(xmin,xmax,dx,tic,ticnd);
    dxydot := dy/5.0;
    IF (tic = xmin) THEN tic := tic + dx;
    WHILE ((dx>0.0)AND(tic<=ticnd)) OR ((dx<0.0)AND(tic>=ticnd)) DO BEGIN
        xdot := sx(tic);
        tic := tic + dx;
        xydot := ymin + dxydot;
        WHILE ((dxydot>0.0)AND(xydot<=ymax)) OR
              ((dxydot<0.0)AND(xydot>=ymax)) DO BEGIN
            ydot  := sy(xydot);
            xydot := xydot + dxydot;
            point( xdot,ydot );
        END
    END;
    { Do Horizontal Dotted Lines }

    ticend(ymin,ymax,dy,tic,ticnd);
    dxydot := dx/5.0;
    IF (tic = ymin) THEN tic := tic + dy;
    WHILE ((dy>0.0)AND(tic<=ticnd)) OR ((dy<0.0)AND(tic>=ticnd)) DO BEGIN
        ydot := sy(tic);
        tic  := tic + dy;
        xydot := xmin + dxydot;
        WHILE ((dxydot>0.0)AND(xydot<=xmax)) OR
              ((dxydot<0.0)AND(xydot>=xmax)) DO BEGIN
            xdot  := sx(xydot);
            xydot := xydot + dxydot;
            point( xdot,ydot );
        END
    END
END;

{-------------------------------------------------------------------------}
