.label SPRITE0_POINTER = $07f8
.label SPRITE0_X       = $d000
.label SPRITE0_Y       = $d001
.label SPRITE_ENABLE   = $d015
.label SPRITE_MULTI    = $d01c
.label SPRITE_COLOR1   = $d025
.label SPRITE_COLOR2   = $d026
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

    lda #%00000001        // Bit 0 is sprite 0
    sta SPRITE_MULTI      // Sprite 0 is multicolor

    lda #7                // A = 7 (yellow)
    sta SPRITE_COLOR1     // Bit pair %01

    lda #1                // A = 1 (white)
    sta SPRITE_COLOR2     // Bit pair %11

    lda #2                // A = 2 (red)
    sta SPRITE0_COLOR     // Bit pair %10

    lda #%00000001        // Bit 0 is sprite 0
    sta SPRITE_ENABLE     // Turn on sprite 0

loop:
    jmp loop

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