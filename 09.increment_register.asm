BasicUpstart2(start)

start:
    jsr $e544      // Clear screen

    ldx #1         // X = 1
    stx $0400      // Print A

    inx
    stx $0401      // Print B

    inx
    stx $0402      // Print C

loop:
    jmp loop