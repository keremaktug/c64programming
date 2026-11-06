BasicUpstart2(start)

start:
    jsr $e544      // Clear screen

    ldy #1         // Y = 1
    sty $0400      // Print A

    ldy #2         // Y = 2
    sty $0401      // Print B

    ldy #3         // Y = 3
    sty $0402      // Print C

loop:
    jmp loop