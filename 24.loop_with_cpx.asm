.label SCREEN = $0400

BasicUpstart2(start)

start:
    jsr $e544      // Clear screen

    lda #1         // A = 1
    ldx #0         // X = 0

print:
    sta SCREEN,x   // Print A at SCREEN + X
    inx            // X = X + 1
    cpx #10        // Compare X with 10
    bne print      // Go to print until X = 10

loop:
    jmp loop