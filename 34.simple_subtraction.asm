.label SCREEN = $0400

BasicUpstart2(start)

start:
    jsr $e544      // Clear screen

    lda #8         // A = 8
    sec            // Carry = 1
    sbc #5         // A = A - 5 = 3
    sta SCREEN     // Print C

loop:
    jmp loop