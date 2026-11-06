.label SPRITE0_POINTER = $07f8
.label SPRITE0_X       = $d000
.label SPRITE0_Y       = $d001
.label SPRITE_ENABLE   = $d015
.label SPRITE0_COLOR   = $d027

BasicUpstart2(start)

start:
    jsr $e544             // Clear screen

    lda #sprite/64        // A = block number of the sprite data
    sta SPRITE0_POINTER   // Sprite 0 uses that block

    lda #172              // A = 172
    sta SPRITE0_X         // Sprite 0 X position

    lda #140              // A = 140
    sta SPRITE0_Y         // Sprite 0 Y position

    lda #7                // A = 7 (yellow)
    sta SPRITE0_COLOR     // Sprite 0 color

    lda #%00000001        // Bit 0 is sprite 0
    sta SPRITE_ENABLE     // Turn on sprite 0

loop:
    jmp loop

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