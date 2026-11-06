BasicUpstart2(start)

start:
    lda #1
    sta $0400    
    sta $d800
    jmp start