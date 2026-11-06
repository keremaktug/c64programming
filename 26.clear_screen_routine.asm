.label SCREEN = $0400

BasicUpstart2(start)

start:
    jsr clearScreen   // Fill the screen with spaces

    lda #1            // A = 1
    sta SCREEN        // Print A

loop:
    jmp loop

clearScreen:
    lda #32           // A = 32 (space)
    ldx #250          // X = 250

clear:
    dex               // X = X - 1
    sta SCREEN,x      // Cells 0-249
    sta SCREEN+250,x  // Cells 250-499
    sta SCREEN+500,x  // Cells 500-749
    sta SCREEN+750,x  // Cells 750-999
    bne clear         // Go to clear until X = 0
    rts               // Return to caller