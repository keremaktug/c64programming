.label SCREEN = $0400

BasicUpstart2(start)

start:
    jsr $e544      // Clear screen

    lda #5         // A = 5
    cmp #5         // Compare A with 5
    beq equal      // Go to equal if A = 5
    jmp loop       // Not equal, print nothing

equal:
    lda #1         // A = 1
    sta SCREEN     // Print A

loop:
    jmp loop