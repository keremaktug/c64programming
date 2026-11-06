.label SCREEN = $0400

BasicUpstart2(start)

start:
    jsr $e544      // Clear screen

    lda #1         // A = 1
    ldx column     // X = column
    sta SCREEN,x   // Print A in row 0

    lda column     // A = column
    clc            // Carry = 0
    adc #40        // A = A + 40 (one row down)
    tax            // X = A
    lda #2         // A = 2
    sta SCREEN,x   // Print B in row 1

loop:
    jmp loop

column:
    .byte 10