.label SCREEN   = $0400
.label JOYSTICK = $dc00

.const JOY_UP    = %00000001
.const JOY_DOWN  = %00000010
.const JOY_LEFT  = %00000100
.const JOY_RIGHT = %00001000

BasicUpstart2(start)

start:
    jsr $e544       // Clear screen

loop:
    ldx #32         // X = 32 (space)
    lda JOYSTICK    // A = state of joystick port 2
    and #JOY_UP     // Keep only the up bit
    bne showUp      // The bit is 1 when up is not pressed
    ldx #21         // X = 21 (U)

showUp:
    stx SCREEN      // Print X in the first column

    ldx #32         // X = 32 (space)
    lda JOYSTICK    // A = state of joystick port 2
    and #JOY_DOWN   // Keep only the down bit
    bne showDown    // The bit is 1 when down is not pressed
    ldx #4          // X = 4 (D)

showDown:
    stx SCREEN+2    // Print X in the third column

    ldx #32         // X = 32 (space)
    lda JOYSTICK    // A = state of joystick port 2
    and #JOY_LEFT   // Keep only the left bit
    bne showLeft    // The bit is 1 when left is not pressed
    ldx #12         // X = 12 (L)

showLeft:
    stx SCREEN+4    // Print X in the fifth column

    ldx #32         // X = 32 (space)
    lda JOYSTICK    // A = state of joystick port 2
    and #JOY_RIGHT  // Keep only the right bit
    bne showRight   // The bit is 1 when right is not pressed
    ldx #18         // X = 18 (R)

showRight:
    stx SCREEN+6    // Print X in the seventh column

    jmp loop