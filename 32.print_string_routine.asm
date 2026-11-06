.label SCREEN = $0400

.encoding "screencode_upper"

BasicUpstart2(start)

start:
    jsr $e544             // Clear screen

    ldx #hello-messages   // X = offset of hello
    ldy #0                // Y = start of row 0
    jsr printString       // Print the message

    ldx #world-messages   // X = offset of world
    ldy #40               // Y = start of row 1
    jsr printString       // Print the message

loop:
    jmp loop

printString:
    lda messages,x        // A = byte at messages + X
    beq done              // Stop at the 0 byte
    sta SCREEN,y          // Print A at SCREEN + Y
    inx                   // X = X + 1
    iny                   // Y = Y + 1
    jmp printString

done:
    rts                   // Return to caller

messages:

hello:
    .text "HELLO"
    .byte 0

world:
    .text "FROM C64"
    .byte 0