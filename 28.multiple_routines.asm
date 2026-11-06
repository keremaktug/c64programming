.label SCREEN     = $0400
.label TITLE      = SCREEN + 498
.label BORDER     = $d020
.label BACKGROUND = $d021

BasicUpstart2(start)

start:
    jsr clearScreen   // Fill the screen with spaces
    jsr drawTitle     // Print C64
    jsr changeColors  // Black border and background

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

drawTitle:
    lda #3            // A = character C
    sta TITLE         // Print C
    lda #54           // A = character 6
    sta TITLE+1       // Print 6
    lda #52           // A = character 4
    sta TITLE+2       // Print 4
    rts               // Return to caller

changeColors:
    lda #0            // A = 0 (black)
    sta BORDER        // Border = black
    sta BACKGROUND    // Background = black
    rts               // Return to caller