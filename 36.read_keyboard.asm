.label SCREEN = $0400
.label GETIN  = $ffe4

BasicUpstart2(start)

start:
    jsr $e544      // Clear screen

wait:
    jsr GETIN      // A = key code, 0 if no key
    beq wait       // Go to wait until a key is pressed

    sec            // Carry = 1
    sbc #64        // Letter key code to screen code
    sta SCREEN     // Print the letter

    jmp wait