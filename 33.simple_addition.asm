.label SCREEN = $0400

BasicUpstart2(start)

start:
    jsr $e544      // Clear screen

    lda #2         // A = 2
    clc            // Carry = 0
    adc #3         // A = A + 3 + Carry = 5
    sta SCREEN     // Print E

loop:
    jmp loop