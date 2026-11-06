.const SCREEN = $0400
.const COLOR  = $d800
.const WIDTH  = 40

BasicUpstart2(start)

start:
    jsr $e544      // Clear screen

    lda #1         // A = 1
    ldx #WIDTH     // X = 40

print:
    dex            // X = X - 1
    sta SCREEN,x   // Print A at SCREEN + X
    sta COLOR,x    // White at COLOR + X
    bne print      // Go to print until X = 0

loop:
    jmp loop