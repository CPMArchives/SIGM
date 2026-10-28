        SUBROUTINE      RANDU(IY,YFL)
C////////////////////////////////////////////////////////////////
C/                                                              /
C/      Program-id.     RANDU                                   /
C/      Date-written.   Jan. 16th 1984                          /
C/      File-name.      RANDU.FOR                               /
C/      Remarks.        Subroutine RANDU.FOR page 96.           /
C/                      RANDU is a modefied IBM 1130 subroutine /
C/                                                              /
C////////////////////////////////////////////////////////////////
C
        IY = IY * 899
        IF (IY.GE.0) GO TO 10
        IY = IY + 32767 + 1 
   10   YFL = IY
        YFL = YFL / 32767.0
        RETURN
        END
