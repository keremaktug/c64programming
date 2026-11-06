.label BORDER = $d020
.label GETIN  = $ffe4

.const KEY_SPACE = 32

BasicUpstart2(start)

start:
    jsr $e544      // Clear screen

wait:
    jsr GETIN      // A = key code, 0 if no key
    cmp #KEY_SPACE // Compare A with SPACE
    bne wait       // Go to wait until SPACE is pressed

    lda #1         // A = 1 (white)
    sta BORDER     // Border = white

    jmp wait