BasicUpstart2(start)

start:
    jsr $e544      // Clear screen

    lda #1         // A = 1
    sta $0400      // Print A

    lda #2         // A = 2
    sta $0401      // Print B

    lda #3         // A = 3
    sta $0402      // Print C

loop:
    jmp loop