.label SPRITE0_POINTER = $07f8
.label SPRITE0_X       = $d000
.label SPRITE0_Y       = $d001
.label SPRITE_X_HIGH   = $d010
.label RASTER          = $d012
.label SPRITE_ENABLE   = $d015
.label SPRITE0_COLOR   = $d027

.const WAIT_LINE  = 250
.const START_X    = 24
.const END_X_LOW  = 64

BasicUpstart2(start)

start:
    jsr $e544             // Clear screen

    lda #sprite/64        // A = block number of the sprite data
    sta SPRITE0_POINTER   // Sprite 0 uses that block

    lda #140              // A = 140
    sta SPRITE0_Y         // Sprite 0 Y position

    lda #7                // A = 7 (yellow)
    sta SPRITE0_COLOR     // Sprite 0 color

    lda #%00000001        // Bit 0 is sprite 0
    sta SPRITE_ENABLE     // Turn on sprite 0

loop:
    jsr waitFrame         // Wait for the next frame
    jsr moveRight         // Update xLow and xHigh
    jsr placeSprite       // Copy the position to the VIC-II
    jmp loop

moveRight:
    inc xLow              // xLow = xLow + 1
    bne checkEnd          // Go to checkEnd unless xLow wrapped to 0
    inc xHigh             // xLow wrapped, so xHigh = xHigh + 1

checkEnd:
    lda xHigh             // A = xHigh
    beq moved             // X is below 256, nothing to check
    lda xLow              // A = xLow
    cmp #END_X_LOW        // Is X equal to 256 + 64 = 320?
    bne moved             // Go to moved if not

    lda #START_X          // A = start position
    sta xLow              // xLow = start position
    lda #0                // A = 0
    sta xHigh             // xHigh = 0

moved:
    rts                   // Return to caller

placeSprite:
    lda xLow              // A = xLow
    sta SPRITE0_X         // Low byte of the X position
    lda xHigh             // A = xHigh
    sta SPRITE_X_HIGH     // Bit 0 is the ninth bit of sprite 0
    rts                   // Return to caller

waitFrame:
    lda RASTER            // A = current raster line
    cmp #WAIT_LINE        // Compare A with the wait line
    bne waitFrame         // Go to waitFrame until they match

waitLeave:
    lda RASTER            // A = current raster line
    cmp #WAIT_LINE        // Compare A with the wait line
    beq waitLeave         // Stay here until the line has passed
    rts                   // Return to caller

xLow:
    .byte START_X

xHigh:
    .byte 0

.align 64

sprite:
    .byte %00000000,%00011000,%00000000
    .byte %00000000,%00111100,%00000000
    .byte %00000000,%00111100,%00000000
    .byte %00000000,%01111110,%00000000
    .byte %00000000,%01100110,%00000000
    .byte %00000000,%01100110,%00000000
    .byte %00000000,%11100111,%00000000
    .byte %00000000,%11111111,%00000000
    .byte %00000001,%11111111,%10000000
    .byte %00000001,%11111111,%10000000
    .byte %00000011,%11111111,%11000000
    .byte %00000111,%11111111,%11100000
    .byte %00001111,%11111111,%11110000
    .byte %00011111,%11111111,%11111000
    .byte %00111000,%11111111,%00011100
    .byte %00110000,%11111111,%00001100
    .byte %00000000,%11000011,%00000000
    .byte %00000001,%11000011,%10000000
    .byte %00000001,%10000001,%10000000
    .byte %00000000,%00000000,%00000000
    .byte %00000000,%00000000,%00000000