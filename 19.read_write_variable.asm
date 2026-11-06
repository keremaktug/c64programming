.label SCREEN = $0400

BasicUpstart2(start)

start:
    jsr $e544      // Clear screen

    lda #5         // A = 5
    sta counter    // counter = 5

    lda #1         // A = 1
    sta SCREEN     // Print A

    lda counter    // A = counter = 5
    sta SCREEN+1   // Print E

loop:
    jmp loop

counter:
    .byte 0