{************************************************************************
 *                                                                      *
 *                          PLOT Test Program                           *
 *                                                                      *
 ************************************************************************}

PROGRAM main;
VAR
    x,y: ARRAY [1..20] of REAL;
    a,x1,y1,x2,y2,yf: REAL;
    i,j,n: INTEGER;

{$I GRAF1.PAS}
{$I GRAF2.PAS}

BEGIN
    grinit ('test.vec   ');

    {        Plot Polygon           }
    n := 20;                         

    FOR i := 1 to n DO BEGIN              { set up corner coord. }
        a := 6.28318 * i / n;
        x[i] := cos(a)*0.49 + 0.5;
        y[i] := sin(a)*0.49 + 0.5;
    END;

    Writeln(CON, 'Plotting ',n,' sided polygon');

    FOR i := 1 to n DO BEGIN                  { connect corners }
        FOR j := i+1 to n DO segmnt( x[i],y[i], x[j],y[j] );
    END;

    gprint;                                { advance to new frame }
    color(0);
    erase;
    color(127);

    writecmd('T',1);                       {use Text cmd to advance page}
    FOR I := 1 TO 18 DO writecmd( Chr(10),1 );
    writecmd( Chr(0),1 );

    {            Plot Sine Curve Graph               }

    Writeln(CON, 'Plotting sine curve figure');

    Writeln(CON, '    Drawing axes and grid');
    chset( 0.0292, 0.0279, 0.0 );
    graph( 0.0,10.0,5, -1.0,1.0,6, 0.15,0.85,0.1,0.9 );

    Writeln(CON, '    Drawing outline curve');
    point ( sx(0.0), sy(0.0) );

    a := 0.2;
    WHILE a<=10.0 DO BEGIN         { draw outline }
        x1 := a;
        y1 := exp( -a/5.0 ) * sin(a);

        vector( sx(x1), sy(y1) );
        a := a + 0.2
    END;

    Writeln(CON, '    Filling area under curve');
    yf := sy(0.0);
    x1 := sx(0.0);
    y1 := sy(0.0);

    color(96);

    a := 0.2;
    WHILE a<=10.0 DO BEGIN          { fill in outline }
        x2 := sx(a);
        y2 := sy( exp( -a/5.0 ) * sin(a) );
        fill ( x1,y1, x2,y2, yf);
        x1 := x2;
        y1 := y2;
        a := a + 0.2
    END;

    Writeln(CON, '    Printing title');
    gstrng( 0.425, 0.95,'Sine Curve Test Plot');

    Writeln(CON, 'Finished Plotting');
    grfini;
END.
