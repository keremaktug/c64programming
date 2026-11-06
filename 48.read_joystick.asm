.label BORDER   = $d020
.label JOYSTICK = $dc00

.const JOY_FIRE = %00010000

BasicUpstart2(start)

start:
    jsr $e544      // Clear screen

loop:
    lda JOYSTICK   // A = state of joystick port 2
    and #JOY_FIRE  // Keep only the fire bit
    bne released   // The bit is 1 when fire is not pressed

    lda #1         // A = 1 (white)
    sta BORDER     // Border = white
    jmp loop

released:
    lda #14        // A = 14 (light blue)
    sta BORDER     // Border = light blue
    jmp loop