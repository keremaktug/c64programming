.label SCREEN = $0400

BasicUpstart2(start)

start:
    jsr $e544      // Clear screen

loop:
    inc counter    // counter = counter + 1
    lda counter    // A = counter
    sta SCREEN     // Print counter
    jmp loop

counter:
    .byte 0