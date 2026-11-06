BasicUpstart2(start)

start:
    jsr $e544      // Clear screen

    lda #1         // A = 1
    ldx #0         // X = 0

    sta $0400,x    // $0400 + 0 = $0400

    inx            // X = 1
    sta $0400,x    // $0400 + 1 = $0401

    inx            // X = 2
    sta $0400,x    // $0400 + 2 = $0402

loop:
    jmp loop