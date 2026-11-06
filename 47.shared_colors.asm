.label SPRITE0_POINTER = $07f8
.label SPRITE1_POINTER = $07f9
.label SPRITE2_POINTER = $07fa
.label SPRITE0_X       = $d000
.label SPRITE0_Y       = $d001
.label SPRITE1_X       = $d002
.label SPRITE1_Y       = $d003
.label SPRITE2_X       = $d004
.label SPRITE2_Y       = $d005
.label SPRITE_ENABLE   = $d015
.label SPRITE_MULTI    = $d01c
.label SPRITE_COLOR1   = $d025
.label SPRITE_COLOR2   = $d026
.label SPRITE0_COLOR   = $d027
.label SPRITE1_COLOR   = $d028
.label SPRITE2_COLOR   = $d029

BasicUpstart2(start)

start:
    jsr $e544             // Clear screen

    lda #sprite/64        // A = block number of the sprite data
    sta SPRITE0_POINTER   // Sprite 0 uses that block
    sta SPRITE1_POINTER   // Sprite 1 uses the same block
    sta SPRITE2_POINTER   // Sprite 2 uses the same block

    lda #92               // A = 92
    sta SPRITE0_X         // Sprite 0 X position

    lda #172              // A = 172
    sta SPRITE1_X         // Sprite 1 X position

    lda #252              // A = 252
    sta SPRITE2_X         // Sprite 2 X position

    lda #140              // A = 140
    sta SPRITE0_Y         // Sprite 0 Y position
    sta SPRITE1_Y         // Sprite 1 Y position
    sta SPRITE2_Y         // Sprite 2 Y position

    lda #7                // A = 7 (yellow)
    sta SPRITE_COLOR1     // Shared by all sprites

    lda #1                // A = 1 (white)
    sta SPRITE_COLOR2     // Shared by all sprites

    lda #2                // A = 2 (red)
    sta SPRITE0_COLOR     // Own color of sprite 0

    lda #5                // A = 5 (green)
    sta SPRITE1_COLOR     // Own color of sprite 1

    lda #8                // A = 8 (orange)
    sta SPRITE2_COLOR     // Own color of sprite 2

    lda #%00000111        // Bits 0, 1 and 2 are sprites 0, 1 and 2
    sta SPRITE_MULTI      // All three are multicolor
    sta SPRITE_ENABLE     // Turn on all three

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