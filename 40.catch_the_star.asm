.label SCREEN     = $0400
.label STATUS_ROW = SCREEN + 320
.label GETIN      = $ffe4

.const KEY_W       = 87
.const KEY_A       = 65
.const KEY_S       = 83
.const KEY_D       = 68
.const LAST_ROW    = 5
.const LAST_COLUMN = 39
.const STAR_COUNT  = 6

.encoding "screencode_upper"

BasicUpstart2(start)

start:
    jsr $e544          // Clear screen
    jsr drawStar       // Draw * at its first cell
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
    jmp moved

moveDown:
    lda row            // A = row
    cmp #LAST_ROW      // Compare A with the last row
    beq wait           // Stop at the bottom edge
    jsr erasePlayer    // Remove @ from the old position
    inc row            // row = row + 1
    jmp moved

moveLeft:
    lda column         // A = column
    beq wait           // Stop at the left edge
    jsr erasePlayer    // Remove @ from the old position
    dec column         // column = column - 1
    jmp moved

moveRight:
    lda column         // A = column
    cmp #LAST_COLUMN   // Compare A with the last column
    beq wait           // Stop at the right edge
    jsr erasePlayer    // Remove @ from the old position
    inc column         // column = column + 1

moved:
    jsr drawPlayer     // Draw @ at the new position
    jsr checkStar      // Did the player reach the star?
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

drawStar:
    ldy star           // Y = star
    ldx starCells,y    // X = cell of the star
    lda #42            // A = 42 (*)
    sta SCREEN,x       // Print * at SCREEN + X
    rts                // Return to caller

checkStar:
    jsr getCell        // X = cell of the player
    txa                // A = X
    ldy star           // Y = star
    cmp starCells,y    // Compare A with the cell of the star
    bne notCaught      // Go to notCaught if they are different

    jsr printMessage   // Print YOU GOT IT!
    inc star           // star = star + 1
    lda star           // A = star
    cmp #STAR_COUNT    // Compare A with the number of stars
    bne nextStar       // Go to nextStar until the table ends
    lda #0             // A = 0
    sta star           // Start again from the first star

nextStar:
    jsr drawStar       // Draw * at its new cell

notCaught:
    rts                // Return to caller

printMessage:
    ldx #0             // X = 0

printNext:
    lda message,x      // A = byte at message + X
    beq printDone      // Stop at the 0 byte
    sta STATUS_ROW,x   // Print A at STATUS_ROW + X
    inx                // X = X + 1
    jmp printNext

printDone:
    rts                // Return to caller

row:
    .byte 2

column:
    .byte 20

star:
    .byte 0

rowStart:
    .byte 0,40,80,120,160,200

starCells:
    .byte 105,52,118,175,213,8

message:
    .text "YOU GOT IT!"
    .byte 0