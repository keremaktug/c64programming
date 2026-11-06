.label SCREEN          = $0400
.label COLOR           = $d800
.label SCORE_HUNDREDS  = SCREEN + 6
.label SCORE_TENS      = SCREEN + 7
.label LIVES_CELL      = SCREEN + 39
.label MESSAGE_ROW     = SCREEN + 535
.label SPRITE0_POINTER = $07f8
.label SPRITE1_POINTER = $07f9
.label SPRITE0_X       = $d000
.label SPRITE0_Y       = $d001
.label SPRITE1_X       = $d002
.label SPRITE1_Y       = $d003
.label SPRITE_X_HIGH   = $d010
.label RASTER          = $d012
.label SPRITE_ENABLE   = $d015
.label SPRITE_HIT      = $d01e
.label BORDER          = $d020
.label BACKGROUND      = $d021
.label SPRITE0_COLOR   = $d027
.label SPRITE1_COLOR   = $d028
.label SID_FREQ_HIGH   = $d401
.label SID_CONTROL     = $d404
.label SID_AD          = $d405
.label SID_SR          = $d406
.label SID_VOLUME      = $d418
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
.const BRICK_ROWS       = 6
.const BRICK_COUNT      = 80
.const RESULT_LOST      = 1
.const RESULT_WON       = 2
.const TONE_BRICK       = 48
.const TONE_PADDLE      = 24
.const TONE_LOST        = 6

.encoding "screencode_upper"

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

    jsr initSound            // Prepare the SID chip

    jsr printStatus          // Print the score and the lives
    jsr drawBricks           // Draw the bricks

    jsr placeSprites         // Copy the positions to the VIC-II

    lda #%00000011           // Bits 0 and 1 are the paddle and the ball
    sta SPRITE_ENABLE        // Turn on both sprites

loop:
    jsr waitFrame            // Wait for the next frame
    jsr readJoystick         // Move the paddle
    jsr checkPaddle          // Did the ball touch the paddle?
    jsr moveBall             // Move the ball
    jsr placeSprites         // Copy the positions to the VIC-II
    lda gameResult           // A = gameResult
    beq loop                 // Keep playing while it is 0

    lda #0                   // A = 0
    sta SPRITE_ENABLE        // Turn off the sprites
    jsr showResult           // Print the result

finished:
    jmp finished             // The game is over

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

checkPaddle:
    lda SPRITE_HIT           // A = touching sprites, reading it clears it
    and #%00000011           // Keep the paddle and ball bits
    cmp #%00000011           // Are both bits set?
    bne paddleDone           // Go to paddleDone if not
    lda ballDirY             // A = ballDirY
    bne paddleDone           // The ball is already going up
    lda #1                   // A = 1
    sta ballDirY             // Turn up

    lda #TONE_PADDLE         // A = paddle tone
    jsr playTone             // Play it

    lda paddleLow            // A = paddleLow
    clc                      // Carry = 0
    adc #8                   // Add half of the paddle minus half of the ball
    sta centerLow            // Low byte of the middle point
    lda paddleHigh           // A = paddleHigh
    adc #0                   // Add the carry
    sta centerHigh           // High byte of the middle point

    lda ballXLow             // A = ballXLow
    cmp centerLow            // Compare the low bytes
    lda ballXHigh            // A = ballXHigh
    sbc centerHigh           // Compare the high bytes, carry = 0 if ball is smaller
    bcc hitLeft              // Go to hitLeft if the ball is on the left half
    lda #0                   // A = 0
    sta ballDirX             // Go right
    rts                      // Return to caller

hitLeft:
    lda #1                   // A = 1
    sta ballDirX             // Go left

paddleDone:
    rts                      // Return to caller

moveBall:
    lda #BALL_SPEED          // A = pixels to move
    sta steps                // steps = A

ballStep:
    jsr moveBallX            // Move one pixel on X
    jsr moveBallY            // Move one pixel on Y
    jsr checkBricks          // Did the ball hit a brick?
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
    jmp lostBall             // The ball went past the paddle

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

drawBricks:
    ldx #40                  // X = 40

nextBrick:
    dex                      // X = X - 1
    dex                      // X = X - 1, bricks are two cells wide

    lda #160                 // A = 160 (solid block)
    sta SCREEN+80,x          // Left half of the brick, row 3
    sta SCREEN+120,x         // Row 4
    sta SCREEN+160,x         // Row 5
    sta SCREEN+200,x         // Row 6

    lda #97                  // A = 97 (half block)
    sta SCREEN+81,x          // Right half of the brick, row 3
    sta SCREEN+121,x         // Row 4
    sta SCREEN+161,x         // Row 5
    sta SCREEN+201,x         // Row 6

    lda #2                   // A = 2 (red)
    sta COLOR+80,x           // Left half color
    sta COLOR+81,x           // Right half color
    lda #8                   // A = 8 (orange)
    sta COLOR+120,x          // Left half color
    sta COLOR+121,x          // Right half color
    lda #7                   // A = 7 (yellow)
    sta COLOR+160,x          // Left half color
    sta COLOR+161,x          // Right half color
    lda #5                   // A = 5 (green)
    sta COLOR+200,x          // Left half color
    sta COLOR+201,x          // Right half color

    cpx #0                   // Compare X with 0
    bne nextBrick            // Repeat until X = 0
    rts                      // Return to caller

checkBricks:
    lda ballY                // A = ballY
    sec                      // Carry = 1
    sbc #46                  // Middle of the ball, measured from the first row
    lsr                      // A = A / 2
    lsr                      // A = A / 4
    lsr                      // A = A / 8, this is the row
    cmp #BRICK_ROWS          // Compare A with the number of rows
    bcs noBrick              // Below the bricks, nothing to check
    tay                      // Y = row

    lda ballXLow             // A = ballXLow
    sec                      // Carry = 1
    sbc #20                  // Middle of the ball, measured from the first column
    sta cellLow              // Low byte of the distance
    lda ballXHigh            // A = ballXHigh
    sbc #0                   // Subtract the borrow
    sta cellHigh             // High byte of the distance

    lsr cellHigh             // Divide the two bytes by 2
    ror cellLow              // The bit that fell out moves into cellLow
    lsr cellHigh             // Divide by 2 again, 4 in total
    ror cellLow
    lsr cellHigh             // Divide by 2 again, 8 in total
    ror cellLow              // cellLow is now the column

    lda rowStart,y           // A = first cell of the row
    clc                      // Carry = 0
    adc cellLow              // A = A + column
    tax                      // X = cell number

    lda SCREEN,x             // A = what is on the screen there
    cmp #32                  // Is it a space?
    beq noBrick              // Nothing to hit

    txa                      // A = cell number
    and #%11111110           // Clear bit 0 to find the left half of the brick
    tax                      // X = left half
    lda #32                  // A = 32 (space)
    sta SCREEN,x             // Erase the left half
    sta SCREEN+1,x           // Erase the right half

    lda #1                   // A = 1
    sec                      // Carry = 1
    sbc ballDirY             // A = 1 - ballDirY
    sta ballDirY             // Turn the other way

    lda #TONE_BRICK          // A = brick tone
    jsr playTone             // Play it

    jsr addScore             // Add 10 points
    dec bricksLeft           // bricksLeft = bricksLeft - 1
    bne noBrick              // Go to noBrick if bricks are left
    lda #RESULT_WON          // A = won
    sta gameResult           // The game is over
noBrick:
    rts                      // Return to caller

printStatus:
    ldx #0                   // X = 0

statusNext:
    lda statusLine,x         // A = byte at statusLine + X
    beq statusDone           // Stop at the 0 byte
    sta SCREEN,x             // Print A at SCREEN + X
    inx                      // X = X + 1
    jmp statusNext

statusDone:
    rts                      // Return to caller

addScore:
    inc SCORE_TENS           // The digit on the screen is our counter
    lda SCORE_TENS           // A = tens digit
    cmp #58                  // Did it pass 9?
    bne scoreDone            // Go to scoreDone if not
    lda #48                  // A = 48 (the digit 0)
    sta SCORE_TENS           // Tens digit = 0
    inc SCORE_HUNDREDS       // Hundreds digit = hundreds digit + 1

scoreDone:
    rts                      // Return to caller

lostBall:
    lda #TONE_LOST           // A = lost ball tone
    jsr playTone             // Play it

    dec lives                // lives = lives - 1
    lda lives                // A = lives
    clc                      // Carry = 0
    adc #48                  // Number to digit code
    sta LIVES_CELL           // Print the lives
    lda lives                // A = lives
    bne resetBall            // Go to resetBall if lives are left
    lda #RESULT_LOST         // A = lost
    sta gameResult           // The game is over

resetBall:
    lda #172                 // A = 172
    sta ballXLow             // Ball X, low byte
    lda #0                   // A = 0
    sta ballXHigh            // Ball X, high byte
    sta ballDirY             // Go down
    lda #150                 // A = 150
    sta ballY                // Ball Y
    rts                      // Return to caller

printMessage:
    lda messages,x           // A = byte at messages + X
    beq messageDone          // Stop at the 0 byte
    sta MESSAGE_ROW,y        // Print A at MESSAGE_ROW + Y
    inx                      // X = X + 1
    iny                      // Y = Y + 1
    jmp printMessage

messageDone:
    rts                      // Return to caller

showResult:
    ldx #lostText-messages   // X = offset of the lost message
    lda gameResult           // A = gameResult
    cmp #RESULT_LOST         // Did the player lose?
    beq printResult          // Go to printResult if so
    ldx #wonText-messages    // X = offset of the won message

printResult:
    ldy #0                   // Y = start of the message row
    jsr printMessage         // Print the message
    rts                      // Return to caller

initSound:
    lda #15                  // A = 15 (full volume)
    sta SID_VOLUME           // Master volume
    lda #%00001001           // Attack 0, decay 9
    sta SID_AD               // Voice 1 attack and decay
    lda #0                   // A = 0
    sta SID_SR               // Voice 1 sustain and release
    rts                      // Return to caller

playTone:
    sta SID_FREQ_HIGH        // A is the pitch of the tone
    lda #%00010000           // Triangle wave, gate off
    sta SID_CONTROL          // Stop the previous tone
    lda #%00010001           // Triangle wave, gate on
    sta SID_CONTROL          // Start the new tone
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

centerLow:
    .byte 0

centerHigh:
    .byte 0

cellLow:
    .byte 0

cellHigh:
    .byte 0

rowStart:
    .byte 0,40,80,120,160,200

lives:
    .byte 3

bricksLeft:
    .byte BRICK_COUNT

gameResult:
    .byte 0

statusLine:
    .text "SCORE 000                        LIVES 3"
    .byte 0

messages:

lostText:
    .text "GAME OVER"
    .byte 0

wonText:
    .text "YOU WIN"
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