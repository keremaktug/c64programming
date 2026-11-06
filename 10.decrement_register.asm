BasicUpstart2(start)

start:
    jsr $e544      // Clear screen

    ldx #1         // X = 1
    stx $0400      // Print A

    inx            // X = 2
    stx $0401      // Print B

    inx            // X = 3
    stx $0402      // Print C

    dex            // X = 2
    stx $0403      // Print B

    dex            // X = 1
    stx $0404      // Print A

loop:
    jmp loop