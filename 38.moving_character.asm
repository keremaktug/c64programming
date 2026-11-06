.label SCREEN = $0400
.label GETIN  = $ffe4

.const KEY_A       = 65
.const KEY_D       = 68
.const LAST_COLUMN = 39

BasicUpstart2(start)

start:
    jsr $e544          // Clear screen
    jsr drawPlayer     // Draw @ at the start position

wait:
    jsr GETIN          // A = key code, 0 if no key
    cmp #KEY_A         // Compare A with the A key
    beq moveLeft       // Go to moveLeft if A is pressed
    cmp #KEY_D         // Compare A with the D key
    beq moveRight      // Go to moveRight if D is pressed
    jmp wait

moveLeft:
    lda position       // A = position
    beq wait           // Stop at the left edge
    jsr erasePlayer    // Remove @ from the old position
    dec position       // position = position - 1
    jsr drawPlayer     // Draw @ at the new position
    jmp wait

moveRight:
    lda position       // A = position
    cmp #LAST_COLUMN   // Compare A with the last column
    beq wait           // Stop at the right edge
    jsr erasePlayer    // Remove @ from the old position
    inc position       // position = position + 1
    jsr drawPlayer     // Draw @ at the new position
    jmp wait

drawPlayer:
    ldx position       // X = position
    lda #0             // A = 0 (@)
    sta SCREEN,x       // Print @ at SCREEN + X
    rts                // Return to caller

erasePlayer:
    ldx position       // X = position
    lda #32            // A = 32 (space)
    sta SCREEN,x       // Print space at SCREEN + X
    rts                // Return to caller

position:
    .byte 20