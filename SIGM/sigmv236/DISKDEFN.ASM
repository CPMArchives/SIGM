         title 'disk definitions'

         public @dtbl             ; drive table
         public adrv,bdrv,cdrv,ddrv
                                  ; dph-s
         public dskdef            ; disk tables list
         extrn fwrite,fread,flogin,finita,finitb,finitc
                                  ; for extended dph
         extrn swrite,sread,slogin,sinit
                                  ; for semidisk

         maclib cpm3              ; for generating tables

         cseg                     ; common memory

@dtbl:   dtbl <adrv,bdrv,cdrv,ddrv>

dpb128s: dpb 128,26,77,1024,64,2
;dpb256s: dpb 256,26,77,2048,128,2
dpb256s: dw 0034h
         db 04h,0fh
         db 00h                   ; zero extent mask
         dw 00f2h
         dw 007fh
         db 0c0h,00h
         dw 0020h
         dw 0002h
         db 01h,01h
dpb512s: dpb 512,15,77,2048,128,2
dpb1024s:dpb 1024,8,77,2048,128,2

dpb128d: dpb 128,26,154,2048,128,4
dpb256d: dpb 256,26,154,2048,256,4
dpb512d: dpb 512,15,154,2048,256,4
dpb1024d:dpb 1024,8,154,2048,256,4

semidisk:dpb 128,16,256,2048,128,2,8000h

         dseg                     ; banked memory

         dw fwrite
         dw fread
         dw flogin
         dw finita
         db 'A',0
adrv:    dph sk1024,dpb1024d

         dw fwrite
         dw fread
         dw flogin
         dw finitb
         db 'B',0
bdrv:    dph sk1024,dpb1024d

         dw fwrite
         dw fread
         dw flogin
         dw finitc
         db 'C',0
cdrv:    dph sk1024,dpb1024d

         dw swrite
         dw sread
         dw slogin
         dw sinit
         db 'D',0
ddrv:    dph 0,semidisk

sk128:   skew 26,6,1
sk256:   skew 26,9,1
sk512:   skew 15,4,1
sk1024:  skew 8,3,1

dskdef:                           ; table of disk table addresses
         dw sk128
         dw sk256
         dw sk512
         dw sk1024

         dw dpb128s
         dw dpb256s
         dw dpb512s
         dw dpb1024s

         dw sk128                 ; same skew tables for ds disks
         dw sk256
         dw sk512
         dw sk1024

         dw dpb128d
         dw dpb256d
         dw dpb512d
         dw dpb1024d

         end
       ; disk tables list
         extrn fwrite,fread,flogin,f