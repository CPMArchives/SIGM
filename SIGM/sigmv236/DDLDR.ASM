         title 'disk definitions for drive a'

         public adrv              ; dph for drive a
         public dskdef            ; disk tables list

         maclib cpm3              ; for generating tables

         cseg                     ; common memory

dpb128s: dpb 128,26,77,1024,64,2,8000h
dpb256s: dpb 256,26,77,2048,128,2,8000h
dpb512s: dpb 512,15,77,2048,128,2,8000h
dpb1024s:dpb 1024,8,77,2048,128,2,8000h

dpb128d: dpb 128,26,154,2048,128,4,8000h
dpb256d: dpb 256,26,154,2048,256,4,8000h
dpb512d: dpb 512,15,154,2048,256,4,8000h
dpb1024d:dpb 1024,8,154,2048,256,4,8000h


adrv:    dw sk1024
         ds 9
         db 0
         dw dpb1024d
         dw 0
         dw 0
         dw bcb
         dw bcb
         dw 0ffffh
bcb:     db 0ffh
         ds 9
         dw buff

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

buff:    end
,8000h
dpb512s: dpb 512,15,77,2048,128