.label SCREEN = $0400

.encoding "screencode_upper"

BasicUpstart2(start)

start:
    jsr $e544      // Clear screen

    ldx #0         // X = 0

print:
    lda message,x  // A = byte at message + X
    beq done       // Stop at the 0 byte
    sta SCREEN,x   // Print A at SCREEN + X
    inx            // X = X + 1
    jmp print

done:
    jmp done

message:
    .text "HELLO WORLD"
    .byte 0