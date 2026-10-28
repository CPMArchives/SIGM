        SUBROUTINE      SET(JQ,NSET)
C////////////////////////////////////////////////////////////////
C/                                                              /
C/      Program-id.     SET                                     /
C/      Date-written.   Jan. 16th 1984                          /
C/      File-name.      SET.FOR (Ver2.0)                        /
C/      Remarks.        Subroutine SET.FOR page 62.             /
C/                      Subroutine SET is the heart of the      /
C/                      information storage and retrieval       /
C/                      system. SET performs three functions:   /
C/                      1. Initialize the filing array NSET     /
C/                      2. Updates the pointer system.          /
C/                      3. Maintain statistics on the number    /
C/                         of entries in each file.             /
C/                                                              /
C////////////////////////////////////////////////////////////////
C
C	* Default size of INTEGER = 2 bytes in F80
C       
        INTEGER*4       NSET(6,1)
C
      COMMON /C1/ID,IM,INIT,JEVNT,JMNIT,MFA,MSTOP,MX,MXC,NCLCT,NHIST,
     1           NOQ,NORPT,NOT,NPRMS,NRUN,NRUNS,NSTAT,OUT,SCALE,ISEED,
     2           TNOW,TBEG,TFIN,MXX,NPRNT,NCRDR,NEP,VNQ(4)
C
      COMMON /C2/ATRIB(4),ENQ(4),INN(4),JCELS(5,22),KRANK(4),MAXNQ(4),
     1           MFE(4),MLC(4),MLE(4),NCELS(5),NQ(4),PARAM(20,4),
C
     2           QTIME(4),SSUMA(10,5),SUMA(10,5),NAME(6),NPROJ,MON,
     3		 NDAY,NYR,JCLR
C
C       --- INIT should be one for initialization of file
C
        IF (INIT - 1) 27,28,27
C
C       --- Initialize file to zero. Set up pointers
C           must initialize KRANK(JQ)
C           must initialize INN(JQ)
C
   28	KOL = 7777
	KOF = 8888
	KLE = 9999
	MX = IM + 1
	MXX = IM + 2
C
C	--- Inirtialize pointing cells of NSET and zero other cells
C	    of NSET
C
      DO 1 I=1,ID
	DO 2 J=1,IM
	  NSET(J,I) = 0
    2   CONTINUE
	NSET(MXX,I) = I - 1
	NSET(MX,I) = I + 1
    1 CONTINUE
	NSET(MX,ID) = KOF
      DO 3 K=1,NOQ
	NQ(K) = 0
	MLC(K) = 0
	MFE(K) = 0
	MAXNQ(K) = 0
	MLE(K) = 0
	ENQ(K) = 0.0
	VNQ(K) = 0.0
        QTIME(K) = TNOW
    3 CONTINUE
C
C	--- First available column = 1
C
	MFA = 1
	INIT = 0
	OUT = 0.0
	RETURN
C
C       --- MFEX is first entry in file which has not been compared 
C           with ITEM to be inserted.
C
   27	MFEX = MFE(JQ)
C
C       --- KNT is a check code to indicate that no comparisons have
C           been made.
C
        KNT = 2
C
C       --- KS is the row on which items of file JQ are ranked.
C
        KS = KRANK(JQ)
C
C       --- Test for putting value in or out
C           if out equals one an item is to be removed from file JQ
C           If OUT is less than ONE an item is to be inserted in
C           file JQ
C
        IF (OUT-1.0) 8,5,100
C
C       --- Putting an entry in file JQ
C
    8   NXFA = NSET(MX,MFA)
C
C       --- If INN(JQ) equals two the file is a HVF file. If INN(JQ)
C           is one the file is a LVF file. For LVF files try to insert
C           Stating at end of file. MLEX is last entry in file which
C           has not been compared with items to be inserted.
C
        IF (INN(JQ) - 1) 100,7,6
    7   MLEX = MLE(JQ)
C
C       --- If MLEX is zero file is empty. item to be inserted will be
C           only item in file.
C
        IF (MLEX) 100,10,11
   10   NSET(MXX,MFA) = KLE
        MFE(JQ) = MFA
C
C       --- There is no successor of item inserted. Since item was 
C           inserted in column MFA the last entry of file JQ is in
C           column MFA.
C
   17   NSET(MX,MFA) = KOL
        MLE(JQ) = MFA
C
C       --- Set new MFA equal to successor of old MFA. that is NXFA
C
   14   MFA = NXFA
        IF (MFA - KOF) 237,238,238
  237   NSET(MXX,MFA) = KLE
C
C       ---Update statistics of file JQ
C
  238   XNQ = NQ(JQ)
        ENQ(JQ) = ENQ(JQ) + XNQ * (TNOW - QTIME(JQ))
        VNQ(JQ) = VNQ(JQ) + XNQ * XNQ * (TNOW - QTIME(JQ))
        QTIME(JQ) = TNOW
        NQ(JQ) = NQ(JQ) + 1
        MAXNQ(JQ) = MAX0(MAXNQ(JQ),NQ(JQ))
        MLC(JQ) = MFE(JQ)
        RETURN
C
C       --- Test ranking value of new item against value of item
C           in column
C
   11   IF (NSET(KS,MFA)-NSET(KS,MLEX)) 12,13,13
C
C       --- Insert item after column MLEX.
C
   13   MSU = NSET(MX,MLEX)
        NSET(MX,MLEX) = MFA
        NSET(MXX,MFA) = MLEX
        GO TO (18,17),KNT
C
C       --- Since KNT equals one a comparison was made and there
C           is A.
C
   18   NSET(MX,MFA) = MSU
        NSET(MXX,MSU) = MFA
        				GO TO 14
C
C       --- Set KNT to one since a comparison was made.
C
   12   KNT = 1
C
C       --- Test MFA against predecessor of MLEX by letting
C           MLEX equal predecessor of MLEX.
C
        MLEX = NSET(MXX,MLEX)
        IF (MLEX-KLE) 11,16,11
C
C       --- If MLEX had no predecessor MFA is first in file
C
   16   NSET(MXX,MFA) = KLE
        MFE(JQ) = MFA
C
C
C
   26   NSET(MX,MFA) = MFEX
        NSET(MXX,MFEX) = MFA
        				GO TO 14
C
C       --- FOR HVF OPERATION TRY TO INSERT ITEM STARTING AT BEGINNING
C           OF FILE JQ.
C
    6   IF (MFEX) 100,10,19
C
C       --- Test ranking value of new item against value of
C           item in column MFEX.
C
   19   IF (NSET(KS,MFA)-NSET(KS,MFEX)) 20,21,21
C
C       --- If new value if lower. MFA must be compared against 
C           successor of MFEX.
C
   20   KNT = 1
C
C       --- Let MPRE = MFEX and let MFEX be the successor of MFEX.
C
        MPRE = MFEX
        MFEX = NSET(MX,MFEX)
        IF (MFEX-KOL) 19,24,19
C
C       --- If new value is higher, it should be inserted between
C           MFEX and ITS.
C
   21   GO TO (22,16),KNT
   22   KNT = 2
C
C       --- MFA is to be inserted after MPRE. Make MPRE the prdece
C           ssor of MFA and MFA the successor of MPRE.
C
   24   NSET(MXX,MFA) = MPRE
        NSET(MX,MPRE) = MFA
C
C       --- If KNT was not reset to 2, thre is no successor of MFA
C           pointers are updated at statement 17.
C
        GO TO (17,26), KNT
C
C       --- Removal of an item from file JQ.
C
5       OUT = 0.0
C
C       --- Update pointing system to account for removal of MLC(JQ)
C
        MMLC = MLC(JQ)
C
C       --- Reset out to 0 and clear column removed.
C
      DO 32 I=1,IM
   	NSET(I,MMLC) = 0
   32 CONTINUE
        JL = NSET(MX,MMLC)
        JK = NSET(MXX,MMLC)
        IF (JL - KOL) 33,34,33
   33   IF (JK - KLE) 35,36,35
   35   NSET(MX,JK) = JL
        NSET(MXX,JL) = JK
C
C       --- Update pointers.
C
   37   NSET(MX,MMLC) = MFA
        NSET(MXX,MMLC) = KLE
        IF (MFA - KOF) 234,235,235
  234   NSET(MXX,MFA) = MMLC
  235   MFA = MLC(JQ)
        MLC(JQ) = MFE(JQ)
C
C       --- Update file statistaics
C
        XNQ = NQ(JQ)
        ENQ(JQ) = ENQ(JQ) + XNQ * (TNOW - QTIME(JQ))
        VNQ(JQ) = VNQ(JQ) + XNQ * XNQ * (TNOW - QTIME(JQ))
        QTIME(JQ) = TNOW
        NQ(JQ) = NQ(JQ) - 1
        RETURN
C
C       --- MLC was first entry but not last entry. update pointers.
C
   36   NSET(MXX,JL) = KLE
        MFE(JQ) = JL
        				GO TO 37
   34   IF (JK - KLE) 38,39,38
C
C       --- MLC was last entry but not first entry. Update pointers.
C
   38   NSET(MX,JK) = KOL
        MLE(JQ) = JK
        				GO TO 37
C
C       --- MLC was both the last and first entry, therefore, it is
C           the only entry.
C
   39   MFE(JQ) = 0
        MLE(JQ) = 0
        				GO TO 37
  100   CALL    ERROR(88,NSET)
        CALL    EXIT
        END
