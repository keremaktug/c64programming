.label SPRITE0_POINTER = $07f8
.label SPRITE0_X       = $d000
.label SPRITE0_Y       = $d001
.label SPRITE_ENABLE   = $d015

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
    sta SPRITE_ENABLE     // Turn on sprite 0

loop:
    jmp loop

.align 64

sprite:
    .byte %00000000,%00000000,%00000000
    .byte %00000000,%00000000,%00000000
    .byte %00010000,%00000000,%00010000
    .byte %00001000,%00000000,%00100000
    .byte %00000100,%00000000,%01000000
    .byte %00000010,%00000000,%10000000
    .byte %00000001,%00000001,%00000000
    .byte %00000000,%10000010,%00000000
    .byte %00000000,%01000100,%00000000
    .byte %00000000,%00101000,%00000000
    .byte %00000000,%00010000,%00000000
    .byte %00000000,%00101000,%00000000
    .byte %00000000,%01000100,%00000000
    .byte %00000000,%10000010,%00000000
    .byte %00000001,%00000001,%00000000
    .byte %00000010,%00000000,%10000000
    .byte %00000100,%00000000,%01000000
    .byte %00001000,%00000000,%00100000
    .byte %00010000,%00000000,%00010000
    .byte %00000000,%00000000,%00000000
    .byte %00000000,%00000000,%00000000