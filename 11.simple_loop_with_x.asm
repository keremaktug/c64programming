BasicUpstart2(start)

start:
    jsr $e544      // Clear screen

repeat:
    ldx #10        // X = 10

loop:
    stx $d020      // Border color = X
    dex            // X = X - 1
    bne loop       // Go to loop until X = 0

    jmp repeat