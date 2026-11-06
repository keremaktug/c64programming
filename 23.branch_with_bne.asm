.label SCREEN = $0400

BasicUpstart2(start)

start:
    jsr $e544      // Clear screen

    lda value      // A = value
    cmp #5         // Compare A with 5
    bne different  // Go to different if A is not 5

    lda #1         // A = 1
    sta SCREEN     // Print A
    jmp loop

different:
    lda #2         // A = 2
    sta SCREEN     // Print B

loop:
    jmp loop

value:
    .byte 5