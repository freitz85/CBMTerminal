*=$c000

portA = $dd00
ddr_portA = $dd02
portB = $dd01
ddr_portB = $dd03
icr = $dd0d
chrout = $ffd2

start
        lda #$00
        sta ddr_portB   ;User Port auf input
@loop   lda icr         ;FLAG2 lesen
        and #$10
        beq @loop
        lda portB       ;PortB lesen
        jsr chrout      ;Zeichen ausgeben
        jmp @loop
