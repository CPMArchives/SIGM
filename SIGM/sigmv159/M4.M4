S
XM;
GCOMPILE
E
... RVALUE
GIDNAME
F/1
GCATNAME
LM:
L
F/2
GIDFIELD
X
PM
0M0C
... 2
T/3
S
F/4
... 4
... 3
X
... 1
T/5
GCONSTSIMP
F/6
PN/
!C
P 
... 6
T/5
LM+
L
F/7
GEXPRESSION
X
P!
... 7
... 5
R
... EXPRESSION
GTERM
F/8
... 9
LM+
L
F/10
GTERM
X
P!+
O
... 10
T/11
LM-
L
F/12
GTERM
X
P!-
O
... 12
... 11
T/9
S
X
... 8
... 13
R
... TERM
GFACTOR
F/14
... 15
LM*
L
F/16
GFACTOR
X
P!*
O
... 16
T/17
LM/
L
F/18
LM256
L
X
PHZ
O
P!D
O
PZY
O
... 18
T/17
LM%256
L
F/19
PHY
O
PN/
P256*
O
P!-
O
... 19
... 17
T/15
S
X
... 14
... 20
R
... FACTOR
LM(
L
F/21
GEXPRESSION
X
LM)
L
X
... 21
T/22
GCONSTSIMP
F/23
PN/
!C
PY
O
... 23
T/22
GIDNAME
F/24
GCATNAME
LM:
L
F/25
GIDFIELD
X
PM
0M0C
... 25
T/26
S
F/27
... 27
... 26
X
PY
O
... 24
T/22
LM-
L
F/28
GFACTOR
X
P!Z
O
PN/
P0Y
O
PZ-
O
... 28
... 22
R
... CATNAME
0M0Y
!L
R
... TOPLACE
GIDNAME
F/29
02
LM:
L
F/30
GIDFIELD
X
PI
0M0C
... 30
T/31
S
F/32
... 32
... 31
X
20
GCATNAME
... 29
... 33
R
... DECLARE
LM.FIELD
L
F/34
... 35
GIDNEW
F/36
02
GCONSTEXP
X
GCHECKFRANGE
0I02
N/3 I32
... 36
... 37
T/35
S
X
LM;
L
X
... 34
T/38
LM.NAME
L
F/39
... 40
GIDNEW
F/41
02
GCONSTEXP
X
!I02
N/1 I32
... 41
... 42
T/40
S
X
LM;
L
X
... 39
T/38
LM.CONSTANT
L
F/43
... 44
GIDNEW
F/45
02
GCONSTEXP
X
N/2 I32
!I02
... 45
... 46
T/44
S
X
LM;
L
X
... 43
T/38
LM.FUNCTION
L
F/47
... 48
GIDNEW
F/49
N/4 I30
... 49
... 50
T/48
S
X
LM;
L
X
... 47
... 38
R
... CONSTEXP
GCONSTTERM
F/51
... 52
LM+
L
F/53
GCONSTTERM
X
!+
... 53
T/54
LM-
L
F/55
GCONSTTERM
X
!-
... 55
... 54
T/52
S
X
... 51
... 56
R
... CONSTTERM
GCONSTFAC
F/57
... 58
LM*
L
F/59
GCONSTFAC
X
!*
... 59
... 60
T/58
S
X
... 57
... 61
R
... CONSTSIMP
LN
L
F/62
0Y
... 62
T/63
GIDCONS
F/64
0M0Y
... 64
T/63
LQ'
L
F/65
N/0SY
... 65
T/63
LM.X
L
F/66
LH
L
X
0Y
... 66
... 63
R
... CONSTFAC
GCONSTSIMP
F/67
... 67
T/68
LM-
L
F/69
GCONSTFAC
X
!Z
N/0Y
Z-
... 69
T/68
LM(
L
F/70
GCONSTEXP
X
LM)
L
X
... 70
... 68
R
... IDTYPE
LI
F/71
ME
0M3Y
Z=
L
R
.71
L
Z9
R
... IDNAME
N/1 Z
GIDTYPE
F/72
... 72
... 73
R
... IDFIELD
N/3 Z
GIDTYPE
F/74
... 74
... 75
R
... IDFUNC
N/4 Z
GIDTYPE
F/76
... 76
... 77
R
... IDCONS
N/2 Z
GIDTYPE
F/78
... 78
... 79
R
... IDNEW
N/0 Z
GIDTYPE
F/80
... 80
... 81
R
... CHECKFRANGE
0Y
N/5 <
SC
... 82
... 83
F/84
R
J/85
... 84
S
T/86
0C
P IS TOO BIG FOR A FIELD
XO
... 86
... 85
R
... AOUT
LM*1
L
F/87
PU
O
... 87
T/88
LM*2
L
F/89
PV
O
... 89
T/88
LM*
L
F/90
PC
O
... 90
T/88
LQ'
L
F/91
... 91
T/92
LQ"
L
F/93
... 93
... 92
F/94
PP
C
O
... 94
T/88
GRVALUE
F/95
PC
O
... 95
T/88
LM.H
L
F/96
GRVALUE
X
PH
O
... 96
T/88
LM.
L
F/97
PXN
O
... 97
... 88
R
... NOTSYN
LM.OUT
L
F/98
LM(
L
X
... 99
GAOUT
T/99
S
X
LM)
L
X
... 98
T/100
LM.LAB
L
F/101
PP... 
O
GAOUT
X
... 101
... 100
F/102
PO
O
... 102
T/103
LM.ACT
L
F/104
LM(
L
X
... 105
LQ'
L
F/106
... 106
T/107
LQ"
L
F/108
... 108
... 107
F/109
C
LM*1
L
F/110
U
... 110
T/111
LM*2
L
F/112
V
... 112
T/111
S
F/113
... 113
... 111
X
O
... 109
T/114
LQ!
L
F/115
... 115
... 114
T/105
S
X
LM)
L
X
... 104
T/103
LM]
L
F/116
GRVALUE
X
PY
O
... 116
T/103
GRVALUE
F/117
LM=:
L
X
GTOPLACE
X
O
... 117
T/103
LM.IF
L
F/118
LM(
L
X
GCEXP
X
LM)
L
X
PF/
U
O
... 119
GNOTSYN
T/119
S
X
LM.ELSE
L
F/120
PJ/
V
O
P... 
U
O
PS
O
... 121
GNOTSYN
T/121
S
X
LM.END
L
X
P... 
V
O
... 120
T/122
LM.END
L
F/123
P... 
U
O
PS
O
... 123
... 122
X
... 118
T/103
LM.CAT
L
F/124
LM(
L
X
... 125
GAOUT
T/125
S
X
LM)
L
X
... 124
T/103
LM.CONDLAB
L
F/126
LM*1
L
F/127
PUY
O
P0=
O
PT/
U
O
PP... 
O
PU
O
... 127
T/128
LM*2
L
F/129
PVY
O
P0=
O
PT/
U
O
PP... 
O
PV
O
... 129
... 128
X
PO
O
PS
O
P... 
U
O
... 126
T/103
GERRORMESSAGE
F/130
... 130
T/103
LM.ERROR
L
F/131
PSF
O
... 131
T/103
LM.SUCCEED
L
F/132
PS
O
... 132
T/103
LM.FAIL
L
F/133
PSF
O
... 133
T/103
LM&
L
F/134
GIDFUNC
X
PG
C
O
... 134
T/103
LM.RETURN
L
F/135
PR
O
... 135
T/103
LQ!
L
F/136
... 136
T/103
LM.WHILE
L
F/137
P... 
U
O
LM(
L
X
GCEXP
X
LM)
L
X
PF/
V
O
... 138
GNOTSYN
T/138
S
X
LM.ENDWHILE
L
X
PJ/
U
O
P... 
V
O
... 137
... 103
R
... CRIGHT
LM==
L
F/139
PY
O
GRVALUE
X
P=
O
... 139
T/140
LM!=
L
F/141
PY
O
GRVALUE
X
P=
O
PSC
O
... 141
T/140
LM<=
L
F/142
PY
O
GRVALUE
X
P<
O
PSC
O
... 142
T/140
LM>=
L
F/143
PY
O
GRVALUE
X
P>
O
PSC
O
... 143
T/140
LM<
L
F/144
PY
O
GRVALUE
X
P>
O
... 144
T/140
LM>
L
F/145
PY
O
GRVALUE
X
P<
O
... 145
... 140
R
... CTERM
GCFAC
F/146
... 147
LM.ANDIF
L
F/148
PF/
V
O
GCFAC
X
... 148
... 149
T/147
S
X
VY
0=
T/150
P... 
V
O
S
... 150
... 146
... 151
R
... CFAC
GRVALUE
F/152
GCRIGHT
X
... 152
T/153
LM.NOT
L
F/154
GCFAC
X
PSC
O
... 154
T/153
LM(
L
F/155
GCEXP
X
LM)
L
X
... 155
T/153
LM&
L
F/156
GIDFUNC
X
PG
C
O
... 156
... 153
R
... CEXP
GCTERM
F/157
... 158
LM.ORIF
L
F/159
PT/
U
O
GCTERM
X
... 159
... 160
T/158
S
X
UY
0=
T/161
P... 
U
O
S
... 161
... 157
... 162
R
... ERRORMESSAGE
LM.ERMS
L
F/163
LM(
L
X
PT/
U
O
... 164
GAOUT
T/164
S
X
LM)
L
X
PXO
O
P... 
U
O
... 163
... 165
R
... SYN
GIDFUNC
F/166
PG
C
O
... 166
T/167
LQ'
L
F/168
PLM
C
O
PL
O
... 168
T/167
LM.ID
L
F/169
PLI
O
PF/
U
O
PL
O
PME
O
P... 
U
O
... 169
T/167
LM.NUM
L
F/170
PLN
O
PL
O
... 170
T/167
LM.STR
L
F/171
LQ'
L
F/172
... 172
T/173
LQ"
L
F/174
... 174
... 173
X
PLQ
C
O
PL
O
... 171
T/167
LM.EMP
L
F/175
PS
O
... 175
T/167
LM$
L
F/176
P... 
U
O
GSYN
X
PT/
U
O
PS
O
... 176
T/167
LM(
L
F/177
GPHRASE
X
LM)
L
X
... 177
T/167
LM.HEXNUM
L
F/178
PLH
O
PL
O
... 178
... 167
F/179
GERRORMESSAGE
F/180
... 180
T/181
S
F/182
... 182
... 181
X
... 179
... 183
R
... SEQ
GSYN
F/184
PF/
U
O
... 185
GSYN
F/186
PX
O
... 186
T/187
GNOTSYN
F/188
... 188
... 187
T/185
S
X
P... 
U
O
... 184
... 189
R
... ALTS
GSEQ
F/190
... 191
LM/
L
F/192
PT/
U
O
GSEQ
X
... 192
... 193
T/191
S
X
UY
0=
T/194
P... 
U
O
S
... 194
... 190
... 195
R
... PHRASE
LM.PREP
L
F/196
... 197
GNOTSYN
T/197
S
X
GALTS
X
... 196
T/198
GALTS
F/199
... 199
T/198
GNOTSYN
F/200
... 201
GNOTSYN
T/201
S
X
... 200
... 198
R
... STATEMENT
GIDFUNC
F/202
... 202
T/203
GIDNEW
F/204
N/4 I30
... 204
T/203
LI
F/205
L
ME
... 205
F/206
SF
T/207
C
P ILLEGAL STATEMNT NAME
XO
... 207
... 206
T/203
S
F/208
SF
T/209
XN
P LAST LINE
XO
... 209
... 208
... 203
F/210
P... 
C
O
LM=
L
X
GPHRASE
X
LM;
L
X
PR
O
LQ!
L
F/211
... 211
T/212
S
F/213
... 213
... 212
X
... 210
... 214
R
... COMPILE
LM.SYN
L
F/215
LI
F/216
L
ME
... 216
X
PS
O
PXM;
O
PG
C
O
PE
O
XM;
... 217
GDECLARE
T/217
S
X
... 218
GSTATEMENT
T/218
S
... 215
... 219
R

