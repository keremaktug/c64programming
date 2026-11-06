.label SPRITE0_POINTER = $07f8
.label SPRITE0_X       = $d000
.label SPRITE0_Y       = $d001
.label SPRITE_X_HIGH   = $d010
.label RASTER          = $d012
.label SPRITE_ENABLE   = $d015
.label BORDER          = $d020
.label BACKGROUND      = $d021
.label SPRITE0_COLOR   = $d027
.label JOYSTICK        = $dc00

.const JOY_LEFT         = %00000100
.const JOY_RIGHT        = %00001000
.const WAIT_LINE        = 250
.const LEFT_EDGE        = 24
.const PADDLE_RIGHT_LOW = 64
.const PADDLE_Y         = 226
.const PADDLE_SPEED     = 3

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

    jsr placePaddle          // Copy the position to the VIC-II

    lda #%00000001           // Bit 0 is the paddle
    sta SPRITE_ENABLE        // Turn on the paddle

loop:
    jsr waitFrame            // Wait for the next frame
    jsr readJoystick         // Move the paddle
    jsr placePaddle          // Copy the position to the VIC-II
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

placePaddle:
    lda paddleLow            // A = paddleLow
    sta SPRITE0_X            // Low byte of the paddle X
    lda paddleHigh           // A = paddleHigh
    sta SPRITE_X_HIGH        // Bit 0 is the ninth bit of the paddle
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

.align 64

paddleSprite:
    .byte %01111111,%11111111,%11111110
    .byte %11111111,%11111111,%11111111
    .byte %11111111,%11111111,%11111111
    .byte %11111111,%11111111,%11111111
    .byte %01111111,%11111111,%11111110
    .fill 48, 0