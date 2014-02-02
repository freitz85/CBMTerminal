; 10 SYS (31744)

*=$401

        BYTE        $0E, $04, $0A, $00, $9E, $20, $28,  $33, $31, $37, $34, $34, $29, $00, $00, $00

*=$7c00

cur     =$c4        ;Zeilenanf. Adr.
spa     =$c6         ;Cursorspalte
scr     =$c7         ;Adr. f. scrolling
ptr     =$01         ;Ptr. f. CTR-Fkt
scz     =$fb         ;Zähler f. scroll
ppt     =$9e         ;Zeiger in T-Puffer
tpu     =$026f       ;Tastatur-Puffer
zeil    =80         ;Zeilenlänge
size    =2000       ;Schirmgröße
screen  =$8000    ;Schrimadresse

ora     =$e812

start   sei
        jsr clrs        ;CLS
        jsr v24.init
        jsr term.rdy
        lda #$0d
        jsr serout
        lda #$00
        sta ppt

in      jmp tasten

in2     jsr schau

        lda ppt
        beq in
        jsr abbau
        jsr scrout
        jmp in2

scrout  cmp #127        ;ausgabe auf bildschirm
        bcc output
scrout1 ldx #ctrend-ctrtab+1
scr1    cmp ctrtab,x
        beq ctrl
        dex
        bpl scr1
        inx
        rts

ctrl    txa
        asl a
        tax
        lda ctr,x
        sta ptr
        lda ctr+1,x
        sta ptr+1
        ldy spa
        jmp (ptr)       ;ctr ausführen

output  cmp #$40
        bmi outp4
        cmp #$60
        bmi outp5
        and #%11011111
outp5   and #%10111111
        bne outp2
outp4   cmp #$20
        bmi scrout1

outp2   ldy spa
        sta (cur),y
        jsr curp1

        rts

curp1   jsr cweg        ;cursor+1

        inc spa
        iny
        cpy #40
        bne ret1
        ldy #0          ;cr
        sty spa
        jmp cu1
ret1    jmp cursor

curm1   jsr cweg        ;cursor+1
        dec spa
        dey
        bpl cm1
        ldy #zeil-1
        sty spa
        jmp cz
cm1     jmp cursor

curpz   jsr cweg        ;curadr+zeil
cu1     clc
        lda cur
        adc #zeil
        sta cur      
        bcc ret3
        inc cur+1
ret3    jmp cursor

curmz   jsr cweg        ;curadr-zeil
cz      sec
        lda cur      
        sbc #zeil
        sta cur      
        bcs ret4
        dec cur+1
ret4    jmp cursor

cret    jsr cweg        ;cursor->zeilanf.

        ldy #0
        sty spa
        jmp cursor

chome   jsr cweg        ;cursor home
        jsr setcur
        jmp cursor

setcur  lda #<screen    ;curadr->bildanf.
        sta cur
        sta spa
        lda #>screen
        sta cur+1
        rts

cweg    lda (cur),y     ;cursor dunkel
        and #%01111111
        sta (cur),y
        rts

cursor  lda cur+1      ;cursor setzen & hell
        cmp #>screen+size
        bne cur1

        lda cur    
        cmp #<screen+size
        bne cur1
        jsr scroll
        
        jmp cur2
cur1    lda cur+1
        cmp #>screen
        bcs cur2
        jsr setcur

cur2    lda (cur),y
        ora #%10000000  ;hell
        sta (cur),y
        rts             ;zurück zu output

scroll  ldy #<screen
        sty cur
        lda #>screen
        sta cur+1
        sta scr+1
        lda #zeil+zeil  ;2-zeilen scrolling
        sta scr
        lda #4
        sta scz
sc1     lda (scr),y
        sta (cur),y

        jsr schau

        iny
        bne sc1
        inc cur+1
        inc scr+1
        dec scz
        bne sc1
        lda #<screen+size-zeil-zeil    ;vorle
        sta cur
        dec cur+1
        ldy #(zeil+zeil-1)
        lda #$20          ;blank
sc5     sta (cur),y

        dey
        bne sc5
        sty spa
        rts

;********************************

; Initialisierung der V24

;********************************

rcve    =$9440
txmit   =$9440
status  =$9441
cmnd    =$9442
cntr    =$9443

v24.init        sta status
        lda #%00011100  ;8 bit / 4800 bd
        sta cntr
        lda #%00001011
        sta cmnd
        lda rcve
        lda status
        rts

;*******************************

; Chr. an V24 ausgeben

;*******************************

serout  pha
ser1    lda status
        and #%00010000
        beq ser1
        pla
        sta txmit
        rts

;***********************

;Control Funktionen

;***********************

ctr     word curm1
        word curpz
        word cret
        word chrsst
        word curp1
        word clear.scr
        word curmz
        word chome
ctrtab  byte $08
        byte $0a
        byte $0d
        byte $10
        byte $18
        byte $19
        byte $1c
ctrend  byte $1d

;****************************

;Abfrage ob taste gedrückt

;****************************

tasten  lda decinp
        and #%11110000
taste1  sta decinp

        jsr schau

        ldx decout
        cpx #$ff
        beq tastatur

        and #%00001111
        clc
        adc #$01
        cmp #%00001010
        beq endtaste
        ora decinp
        jmp taste1

endtaste        jmp in2

;**************************

;Tastaturabfrage

;**************************

taste           =$97
sh.stat         =$98
chr.puf         =$9e
tab.zg          =$a6
blink.fl        =$a7
blink.za        =$a8
chr.pos         =$a9
blink.sc        =$aa
ta.inp.p        =$026f
decinp          =$e810
pia1            =$e811
decout          =$e812
rvs.stat        =$3f

tastatur        ldx #$ff
        stx tab.zg
        inx
        stx sh.stat
        stx rvs.stat
        ldx #$50
        lda decinp
        and #$f0
        sta decinp

tast8   ldy #$08
        lda decout
        cmp decout
        bne tast8
tast9   lsr a
        bcs tast13
        pha
        lda tabelle,x
        bne tastrvs
        lda #$01
        sta sh.stat
        bne tast12
tastrvs cmp #$12
        bne tast10
        lda #$01
        sta rvs.stat
        bne tast12
tast10  cmp #$ff
        beq tast12
        bit pia1
        bmi tast12
        stx tab.zg
tast12  pla
tast13  dex
        beq tast14

        dey
        bne tast9
        inc decinp
        bne tast8
tast14  lda tab.zg
        cmp taste
        beq tast17
        sta taste     
        tax
        bmi tast15
        lda tabelle,x
        lsr sh.stat
        bcc tast15
        ora #$80
        jmp tast18

tast15  lsr rvs.stat
        bcc tast18
        and #%00011111
tast18  cmp #$1f
        beq tast17
        cmp #$ff
        beq tast17

        cmp #$61
        bmi tast19
        tax
        and #%00011111
        sta chr.puf
        txa
        and #%11000000
        clc
        ror a
        ora chr.puf

tast19  jsr serout

tast17  jmp in2

;Tabelle für Tastatur-Abfrage

tabelle nop
        byte $3d, $2e, $ff
        byte $03, $3c, $20
        byte $5b, $12, $2d
        byte $30, $00, $3e
        byte $ff, $5d, $40
        byte $00, $2b, $32
        byte $ff, $3f, $2c
        byte $4e, $56, $58
        byte $33, $31, $0d
        byte $3b, $4d, $42
        byte $35, $ff, $3a
        byte $4b, $48, $46
        byte $53, $36, $34
        byte $ff, $4c, $4a
        byte $47, $44, $41
        byte $2f, $38, $ff
        byte $50, $49, $59
        byte $52, $57, $39
        byte $37, $5e, $4f
        byte $55, $54, $45
        byte $51, $14, $11
        byte $ff, $29, $5c
        byte $27, $24, $22
        byte $1d, $13, $5f
        byte $28, $26, $25
        byte $23, $21

;*********************************

;Nachschauen ob sich was findet

;*********************************

schau   pha
        txa
        pha
        lda status
        and #%00001000
        beq schau2
        lda rcve
        ldx ppt
        sta tpu,x
        inc ppt
schau2  pla
        tax
        pla
        rts

;*******************************

;Abbauen was er gefunden hat

;*******************************

abbau   ldy tpu
        ldx #$00
abbau1  lda tpu+1,x
        sta tpu,x
        inx
        cpx ppt
        bne abbau1
        dec ppt
        tya
        rts

;*******************************

;Cursor Steuerung

;*******************************

chrsst  jsr cweg

chrsst1 jsr schau 

        lda ppt
        beq chrsst1
        jsr abbau
        tay
        lda tab.lb,y
        sta cur
        lda tab.hb,y
        sta cur+1

chrsst2 jsr schau

        lda ppt
        beq chrsst2
        jsr abbau
        sta spa
        tay

        jmp cursor

;**********************************

;Tabellen für Cursor-Steuerung

;**********************************

tab.lb  byte $00, $28, $50, $78
        byte $a0, $c8, $f0, $18
        byte $40, $68, $90, $b8
        byte $e0, $08, $30, $58
        byte $80, $a8, $d0, $f8
        byte $20, $48, $70, $98
        byte $c0

tab.hb  byte $80, $80, $80, $80
        byte $80, $80, $80, $81
        byte $81, $81, $81, $81
        byte $81, $82, $82, $82
        byte $82, $82, $82, $82
        byte $83, $83, $83, $83
        byte $83

;*******************************

;Clear Screen

;*******************************

clear.scr       jsr cweg
        jsr clrs
        sei
        jsr setcur
        jmp cursor

;*******************************

;Bildschirm löschen

;*******************************

clrs    lda cur
        pha
        lda cur+1
        pha

        lda #>screen
        sta cur+1
        lda #$00
        sta cur

clrs2   lda #$20
        ldy #$00
clrs1   sta (cur),y
        iny
        bne clrs1

        inc cur+1
        lda cur+1
        cmp #$89
        beq end.clrs
        bne clrs2

end.clrs        pla
        sta cur+1
        pla
        sta cur

        rts

;*****************************

;Terminal Ready

;*****************************

term.str        byte 20, 05, 18, 13, 09
        byte 14, 01, 12, 32, 18
        byte 05, 01, 04, 25

term.rdy        ldy #$00
term.rdy1       lda term.str,y
        sta screen+zeil+2,y
        iny
        cpy #14
        bne term.rdy1

        rts

