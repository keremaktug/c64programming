BasicUpstart2(start)

start:
    jsr $e544      // Clear screen

    ldx #1         // X = 1
    stx $0400      // Print A

    ldx #2         // X = 2
    stx $0401      // Print B

    ldx #3         // X = 3
    stx $0402      // Print C

loop:
    jmp loop