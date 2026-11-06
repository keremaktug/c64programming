.label SCREEN = $0400

BasicUpstart2(start)

start:
    jsr $e544      // Clear screen

    inc counter    // counter = 1
    inc counter    // counter = 2
    inc counter    // counter = 3

    lda counter    // A = counter
    sta SCREEN     // Print C

loop:
    jmp loop

counter:
    .byte 0