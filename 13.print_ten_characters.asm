BasicUpstart2(start)

start:
    jsr $e544      // Clear screen

    lda #1         // A = 1
    ldx #10        // X = 10

print:
    dex            // X = X - 1
    sta $0400,x    // Print A at $0400 + X
    bne print      // Go to print until X = 0

loop:
    jmp loop