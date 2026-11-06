.label SPRITE0_POINTER = $07f8
.label SPRITE1_POINTER = $07f9
.label SPRITE0_X       = $d000
.label SPRITE0_Y       = $d001
.label SPRITE1_X       = $d002
.label SPRITE1_Y       = $d003
.label SPRITE_X_HIGH   = $d010
.label RASTER          = $d012
.label SPRITE_ENABLE   = $d015
.label BORDER          = $d020
.label BACKGROUND      = $d021
.label SPRITE0_COLOR   = $d027
.label SPRITE1_COLOR   = $d028
.label JOYSTICK        = $dc00

.const JOY_LEFT         = %00000100
.const JOY_RIGHT        = %00001000
.const WAIT_LINE        = 250
.const LEFT_EDGE        = 24
.const PADDLE_RIGHT_LOW = 64
.const BALL_RIGHT_LOW   = 80
.const TOP_EDGE         = 58
.const BOTTOM_EDGE      = 242
.const PADDLE_Y         = 226
.const PADDLE_SPEED     = 3
.const BALL_SPEED       = 2

BasicUpstart2(start)

start:
    jsr $e544                // Clear screen

    lda #0                   // A = 0 (black)
    sta BORDER               // Border = black
    sta BACKGROUND           // Background = black

    lda #paddleSprite/64     // A = block of the paddle data
    sta SPRITE0_POINTER      // Sprite 0 is the paddle
    lda #PADDLE_Y            // A = paddle height
    sta SPRITE0_Y            // Sprite 0 Y position
    lda #1                   // A = 1 (white)
    sta SPRITE0_COLOR        // Paddle color

    lda #ballSprite/64       // A = block of the ball data
    sta SPRITE1_POINTER      // Sprite 1 is the ball
    lda #7                   // A = 7 (yellow)
    sta SPRITE1_COLOR        // Ball color

    jsr placeSprites         // Copy the positions to the VIC-II

    lda #%00000011           // Bits 0 and 1 are the paddle and the ball
    sta SPRITE_ENABLE        // Turn on both sprites

loop:
    jsr waitFrame            // Wait for the next frame
    jsr readJoystick         // Move the paddle
    jsr moveBall             // Move the ball
    jsr placeSprites         // Copy the positions to the VIC-II
    jmp loop                 // Next frame

readJoystick:
    lda JOYSTICK             // A = state of joystick port 2
    and #JOY_LEFT            // Keep only the left bit
    bne checkRight           // Go to checkRight if left is not pressed
    ldx #PADDLE_SPEED        // X = pixels to move

leftStep:
    jsr movePaddleLeft       // Move one pixel left
    dex                      // X = X - 1
    bne leftStep             // Repeat until X = 0

checkRight:
    lda JOYSTICK             // A = state of joystick port 2
    and #JOY_RIGHT           // Keep only the right bit
    bne joystickDone         // Go to joystickDone if right is not pressed
    ldx #PADDLE_SPEED        // X = pixels to move

rightStep:
    jsr movePaddleRight      // Move one pixel right
    dex                      // X = X - 1
    bne rightStep            // Repeat until X = 0

joystickDone:
    rts                      // Return to caller

movePaddleLeft:
    lda paddleHigh           // A = paddleHigh
    bne canMoveLeft          // X is above 255, so it can move
    lda paddleLow            // A = paddleLow
    cmp #LEFT_EDGE           // Compare A with the left edge
    beq leftDone             // Do not move past the edge

canMoveLeft:
    lda paddleLow            // A = paddleLow
    bne decreaseLow          // Go to decreaseLow unless paddleLow is 0
    dec paddleHigh           // paddleLow will wrap, so paddleHigh = paddleHigh - 1

decreaseLow:
    dec paddleLow            // paddleLow = paddleLow - 1

leftDone:
    rts                      // Return to caller

movePaddleRight:
    lda paddleHigh           // A = paddleHigh
    beq canMoveRight         // X is below 256, so it can move
    lda paddleLow            // A = paddleLow
    cmp #PADDLE_RIGHT_LOW    // Is X equal to 256 + 64 = 320?
    beq rightDone            // Do not move past the edge

canMoveRight:
    inc paddleLow            // paddleLow = paddleLow + 1
    bne rightDone            // Go to rightDone unless paddleLow wrapped to 0
    inc paddleHigh           // paddleLow wrapped, so paddleHigh = paddleHigh + 1

rightDone:
    rts                      // Return to caller

moveBall:
    lda #BALL_SPEED          // A = pixels to move
    sta steps                // steps = A

ballStep:
    jsr moveBallX            // Move one pixel on X
    jsr moveBallY            // Move one pixel on Y
    dec steps                // steps = steps - 1
    bne ballStep             // Repeat until steps = 0
    rts                      // Return to caller

moveBallX:
    lda ballDirX             // A = 0 for right, 1 for left
    bne ballLeft             // Go to ballLeft if it is 1
    lda ballXHigh            // A = ballXHigh
    beq stepRight            // X is below 256, so it can move
    lda ballXLow             // A = ballXLow
    cmp #BALL_RIGHT_LOW      // Is X equal to 256 + 80 = 336?
    bne stepRight            // Go to stepRight if not
    lda #1                   // A = 1
    sta ballDirX             // Turn left
    rts                      // Return to caller

stepRight:
    inc ballXLow             // ballXLow = ballXLow + 1
    bne xDone                // Go to xDone unless ballXLow wrapped to 0
    inc ballXHigh            // ballXLow wrapped, so ballXHigh = ballXHigh + 1

xDone:
    rts                      // Return to caller

ballLeft:
    lda ballXHigh            // A = ballXHigh
    bne stepLeft             // X is above 255, so it can move
    lda ballXLow             // A = ballXLow
    cmp #LEFT_EDGE           // Compare A with the left edge
    bne stepLeft             // Go to stepLeft if they are different
    lda #0                   // A = 0
    sta ballDirX             // Turn right
    rts                      // Return to caller

stepLeft:
    lda ballXLow             // A = ballXLow
    bne decreaseBall         // Go to decreaseBall unless ballXLow is 0
    dec ballXHigh            // ballXLow will wrap, so ballXHigh = ballXHigh - 1

decreaseBall:
    dec ballXLow             // ballXLow = ballXLow - 1
    rts                      // Return to caller

moveBallY:
    lda ballDirY             // A = 0 for down, 1 for up
    bne ballUp               // Go to ballUp if it is 1
    lda ballY                // A = ballY
    cmp #BOTTOM_EDGE         // Compare A with the bottom edge
    bne stepDown             // Go to stepDown if they are different
    lda #1                   // A = 1
    sta ballDirY             // Turn up
    rts                      // Return to caller

stepDown:
    inc ballY                // ballY = ballY + 1
    rts                      // Return to caller

ballUp:
    lda ballY                // A = ballY
    cmp #TOP_EDGE            // Compare A with the top edge
    bne stepUp               // Go to stepUp if they are different
    lda #0                   // A = 0
    sta ballDirY             // Turn down
    rts                      // Return to caller

stepUp:
    dec ballY                // ballY = ballY - 1
    rts                      // Return to caller

placeSprites:
    lda paddleLow            // A = paddleLow
    sta SPRITE0_X            // Low byte of the paddle X
    lda ballXLow             // A = ballXLow
    sta SPRITE1_X            // Low byte of the ball X
    lda ballY                // A = ballY
    sta SPRITE1_Y            // Ball Y
    lda ballXHigh            // A = ballXHigh
    clc                      // Carry = 0
    adc ballXHigh            // A = A + A, this moves the bit to bit 1
    adc paddleHigh           // Add the paddle bit in bit 0
    sta SPRITE_X_HIGH        // Ninth X bits of both sprites
    rts                      // Return to caller

waitFrame:
    lda RASTER               // A = current raster line
    cmp #WAIT_LINE           // Compare A with the wait line
    bne waitFrame            // Go to waitFrame until they match

waitLeave:
    lda RASTER               // A = current raster line
    cmp #WAIT_LINE           // Compare A with the wait line
    beq waitLeave            // Stay here until the line has passed
    rts                      // Return to caller

paddleLow:
    .byte 172

paddleHigh:
    .byte 0

ballXLow:
    .byte 172

ballXHigh:
    .byte 0

ballY:
    .byte 150

ballDirX:
    .byte 0

ballDirY:
    .byte 0

steps:
    .byte 0

.align 64

paddleSprite:
    .byte %01111111,%11111111,%11111110
    .byte %11111111,%11111111,%11111111
    .byte %11111111,%11111111,%11111111
    .byte %11111111,%11111111,%11111111
    .byte %01111111,%11111111,%11111110
    .fill 48, 0

.align 64

ballSprite:
    .byte %00111100,%00000000,%00000000
    .byte %01111110,%00000000,%00000000
    .byte %11111111,%00000000,%00000000
    .byte %11111111,%00000000,%00000000
    .byte %11111111,%00000000,%00000000
    .byte %11111111,%00000000,%00000000
    .byte %01111110,%00000000,%00000000
    .byte %00111100,%00000000,%00000000
    .fill 39, 0