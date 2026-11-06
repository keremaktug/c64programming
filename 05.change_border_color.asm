BasicUpstart2(start)

start:
    jsr $e544      // Clear screen

    lda #1
    sta $0400
    sta $d800

    lda #0
    sta $d020

    lda #10
    sta $d021

loop:
    jmp loop