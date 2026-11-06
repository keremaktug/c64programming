BasicUpstart2(start)

start:
    jsr $e544      // Clear screen

    ldx #26        // X = 26

print:
    txa            // A = X
    sta $03ff,x    // Print letter at $03ff + X
    dex            // X = X - 1
    bne print      // Go to print until X = 0

loop:
    jmp loop