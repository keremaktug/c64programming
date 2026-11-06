.label SPRITE0_POINTER = $07f8
.label SPRITE0_X       = $d000
.label SPRITE0_Y       = $d001
.label SPRITE_X_HIGH   = $d010
.label RASTER          = $d012
.label SPRITE_ENABLE   = $d015
.label SPRITE_MULTI    = $d01c
.label SPRITE_COLOR1   = $d025
.label SPRITE_COLOR2   = $d026
.label SPRITE0_COLOR   = $d027
.label JOYSTICK        = $dc00

.const JOY_UP         = %00000001
.const JOY_DOWN       = %00000010
.const JOY_LEFT       = %00000100
.const JOY_RIGHT      = %00001000
.const JOY_FIRE       = %00010000
.const WAIT_LINE      = 250
.const TOP_EDGE       = 50
.const BOTTOM_EDGE    = 229
.const LEFT_EDGE      = 24
.const RIGHT_EDGE_LOW = 64

BasicUpstart2(start)

start:
    jsr $e544             // Clear screen

    lda #sprite/64        // A = block number of the sprite data
    sta SPRITE0_POINTER   // Sprite 0 uses that block

    lda #140              // A = 140
    sta SPRITE0_Y         // Sprite 0 Y position

    lda #%00000001        // Bit 0 is sprite 0
    sta SPRITE_MULTI      // Sprite 0 is multicolor

    lda #7                // A = 7 (yellow)
    sta SPRITE_COLOR1     // Bit pair %01

    lda #1                // A = 1 (white)
    sta SPRITE_COLOR2     // Bit pair %11

    lda #2                // A = 2 (red)
    sta SPRITE0_COLOR     // Bit pair %10

    jsr placeSprite       // Copy the position to the VIC-II

    lda #%00000001        // Bit 0 is sprite 0
    sta SPRITE_ENABLE     // Turn on sprite 0

loop:
    jsr waitFrame         // Wait for the next frame
    jsr readJoystick      // Move according to the joystick
    jsr checkFire         // Change the color on a new fire press
    jsr placeSprite       // Copy the position to the VIC-II
    jmp loop

readJoystick:
    lda JOYSTICK          // A = state of joystick port 2
    and #JOY_UP           // Keep only the up bit
    bne checkDown         // Go to checkDown if up is not pressed
    lda SPRITE0_Y         // A = Y position
    cmp #TOP_EDGE         // Compare A with the top edge
    beq checkDown         // Do not move past the edge
    dec SPRITE0_Y         // Move one pixel up

checkDown:
    lda JOYSTICK          // A = state of joystick port 2
    and #JOY_DOWN         // Keep only the down bit
    bne checkLeft         // Go to checkLeft if down is not pressed
    lda SPRITE0_Y         // A = Y position
    cmp #BOTTOM_EDGE      // Compare A with the bottom edge
    beq checkLeft         // Do not move past the edge
    inc SPRITE0_Y         // Move one pixel down

checkLeft:
    lda JOYSTICK          // A = state of joystick port 2
    and #JOY_LEFT         // Keep only the left bit
    bne checkRight        // Go to checkRight if left is not pressed
    jsr moveLeft          // Move one pixel left

checkRight:
    lda JOYSTICK          // A = state of joystick port 2
    and #JOY_RIGHT        // Keep only the right bit
    bne joystickDone      // Go to joystickDone if right is not pressed
    jsr moveRight         // Move one pixel right

joystickDone:
    rts                   // Return to caller

checkFire:
    lda JOYSTICK          // A = state of joystick port 2
    and #JOY_FIRE         // Keep only the fire bit
    bne fireReleased      // Go to fireReleased if fire is not pressed
    lda fireHeld          // A = fireHeld
    bne fireDone          // Fire was already down, do nothing
    lda #1                // A = 1
    sta fireHeld          // Remember that fire is down
    inc SPRITE0_COLOR     // Next color
    rts                   // Return to caller

fireReleased:
    lda #0                // A = 0
    sta fireHeld          // Remember that fire is up

fireDone:
    rts                   // Return to caller

moveLeft:
    lda xHigh             // A = xHigh
    bne canMoveLeft       // X is above 255, so it can move
    lda xLow              // A = xLow
    cmp #LEFT_EDGE        // Compare A with the left edge
    beq leftDone          // Do not move past the edge

canMoveLeft:
    lda xLow              // A = xLow
    bne decreaseLow       // Go to decreaseLow unless xLow is 0
    dec xHigh             // xLow will wrap, so xHigh = xHigh - 1

decreaseLow:
    dec xLow              // xLow = xLow - 1

leftDone:
    rts                   // Return to caller

moveRight:
    lda xHigh             // A = xHigh
    beq canMoveRight      // X is below 256, so it can move
    lda xLow              // A = xLow
    cmp #RIGHT_EDGE_LOW   // Is X equal to 256 + 64 = 320?
    beq rightDone         // Do not move past the edge

canMoveRight:
    inc xLow              // xLow = xLow + 1
    bne rightDone         // Go to rightDone unless xLow wrapped to 0
    inc xHigh             // xLow wrapped, so xHigh = xHigh + 1

rightDone:
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
    .byte 172

xHigh:
    .byte 0

fireHeld:
    .byte 0

.align 64

sprite:
    .byte %00000000,%00101000,%00000000
    .byte %00000000,%00101000,%00000000
    .byte %00000000,%10111110,%00000000
    .byte %00000000,%10111110,%00000000
    .byte %00000000,%10111110,%00000000
    .byte %00000010,%10101010,%10000000
    .byte %00000010,%10101010,%10000000
    .byte %00001010,%10010110,%10100000
    .byte %00001010,%10010110,%10100000
    .byte %00101010,%01010101,%10101000
    .byte %00101010,%01010101,%10101000
    .byte %10101010,%01010101,%10101010
    .byte %10101010,%10101010,%10101010
    .byte %10100010,%10101010,%10001010
    .byte %10000000,%10101010,%00000010
    .byte %00000000,%11010111,%00000000
    .byte %00000011,%11000011,%11000000
    .byte %00000011,%00000000,%11000000
    .byte %00000000,%00000000,%00000000
    .byte %00000000,%00000000,%00000000
    .byte %00000000,%00000000,%00000000