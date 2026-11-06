.label SCREEN = $0400
.label GETIN  = $ffe4

.const KEY_W       = 87
.const KEY_A       = 65
.const KEY_S       = 83
.const KEY_D       = 68
.const LAST_ROW    = 5
.const LAST_COLUMN = 39

BasicUpstart2(start)

start:
    jsr $e544          // Clear screen
    jsr drawPlayer     // Draw @ at the start position

wait:
    jsr GETIN          // A = key code, 0 if no key
    cmp #KEY_W         // Compare A with the W key
    beq moveUp         // Go to moveUp if W is pressed
    cmp #KEY_S         // Compare A with the S key
    beq moveDown       // Go to moveDown if S is pressed
    cmp #KEY_A         // Compare A with the A key
    beq moveLeft       // Go to moveLeft if A is pressed
    cmp #KEY_D         // Compare A with the D key
    beq moveRight      // Go to moveRight if D is pressed
    jmp wait

moveUp:
    lda row            // A = row
    beq wait           // Stop at the top edge
    jsr erasePlayer    // Remove @ from the old position
    dec row            // row = row - 1
    jsr drawPlayer     // Draw @ at the new position
    jmp wait

moveDown:
    lda row            // A = row
    cmp #LAST_ROW      // Compare A with the last row
    beq wait           // Stop at the bottom edge
    jsr erasePlayer    // Remove @ from the old position
    inc row            // row = row + 1
    jsr drawPlayer     // Draw @ at the new position
    jmp wait

moveLeft:
    lda column         // A = column
    beq wait           // Stop at the left edge
    jsr erasePlayer    // Remove @ from the old position
    dec column         // column = column - 1
    jsr drawPlayer     // Draw @ at the new position
    jmp wait

moveRight:
    lda column         // A = column
    cmp #LAST_COLUMN   // Compare A with the last column
    beq wait           // Stop at the right edge
    jsr erasePlayer    // Remove @ from the old position
    inc column         // column = column + 1
    jsr drawPlayer     // Draw @ at the new position
    jmp wait

getCell:
    ldy row            // Y = row
    lda rowStart,y     // A = first cell of the row
    clc                // Carry = 0
    adc column         // A = A + column
    tax                // X = A
    rts                // Return to caller

drawPlayer:
    jsr getCell        // X = cell of the player
    lda #0             // A = 0 (@)
    sta SCREEN,x       // Print @ at SCREEN + X
    rts                // Return to caller

erasePlayer:
    jsr getCell        // X = cell of the player
    lda #32            // A = 32 (space)
    sta SCREEN,x       // Print space at SCREEN + X
    rts                // Return to caller

row:
    .byte 2

column:
    .byte 20

rowStart:
    .byte 0,40,80,120,160,200