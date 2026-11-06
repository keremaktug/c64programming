.label SCREEN = $0400

BasicUpstart2(start)

start:
    jsr $e544      // Clear screen

    lda value      // A = value
    cmp #5         // Compare A with 5
    beq equal      // Go to equal if A = 5

    lda #2         // A = 2
    sta SCREEN     // Print B
    jmp loop

equal:
    lda #1         // A = 1
    sta SCREEN     // Print A

loop:
    jmp loop

value:
    .byte 5