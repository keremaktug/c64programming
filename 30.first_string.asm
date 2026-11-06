.label SCREEN = $0400

.encoding "screencode_upper"

BasicUpstart2(start)

start:
    jsr $e544      // Clear screen

    ldx #0         // X = 0

print:
    lda message,x  // A = byte at message + X
    sta SCREEN,x   // Print A at SCREEN + X
    inx            // X = X + 1
    cpx #5         // Compare X with 5
    bne print      // Go to print until X = 5

loop:
    jmp loop

message:
    .text "HELLO"