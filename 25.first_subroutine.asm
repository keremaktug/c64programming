.label SCREEN     = $0400
.label BACKGROUND = $d021

BasicUpstart2(start)

start:
    jsr $e544             // Clear screen

    jsr changeBackground  // Run the subroutine

    lda #1                // A = 1
    sta SCREEN            // Print A

loop:
    jmp loop

changeBackground:
    lda #0                // A = 0
    sta BACKGROUND        // Background = black
    rts                   // Return to caller