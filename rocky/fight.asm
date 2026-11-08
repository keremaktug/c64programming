.const MOVE_UP = $01
.const MOVE_DOWN = $02
.const MOVE_LEFT = $04
.const MOVE_RIGHT = $08
.const PUNCH = $10
.const MAX_HP = 8
.const MIN_GAP = 21
.const PUNCH_REACH = 26
.const PUNCH_DEPTH = 10
.const LEFT_EDGE = 14
.const RIGHT_EDGE = 122
.const BACK_EDGE = 146
.const FRONT_EDGE = 200
.const SPRITE_POINTERS = RING_SCREEN + $3f8
.const FIRST_BOXER = (FIGHT_GFX - $4000) / 64
.const MESSAGE_DATA = FIGHT_GFX + 8 * 64
.const MESSAGE_SIZE = 28 * 8
.const FIRST_WALK = (MESSAGE_DATA + 4 * MESSAGE_SIZE - $4000) / 64
.const FIRST_APOLLO_SKIN = FIRST_WALK + 2 * 8
.const WALK_CYCLE = 16
.const HUD_MESSAGE = RING_BITMAP + 4 * 320 + 6 * 8
.const ROCKY_HP_CELLS = RING_SCREEN + 2 * 40 + 9
.const APOLLO_HP_CELLS = RING_SCREEN + 2 * 40 + 26

beginFight:
    lda #$ff
    sta $dc02                   // CIA keyboard columns are outputs.
    lda #0
    sta $dc03                   // CIA keyboard rows are inputs.
    sta $d01b                   // Sprites in front of the bitmap.
    sta $d025                   // Shared sprite outline color.
    lda #$0a
    sta $d026                   // Rocky's skin color.
    lda #$02
    sta $d027
    sta $d028
    lda #$0e
    sta $d029
    sta $d02a
    lda #$08
    sta $d02b                   // Apollo's skin overlay color.
    lda #$10
    sta $d01d                   // Expand the hires overlay across both halves.
    lda #$0f
    sta $d01c                   // Four multicolor sprites, two per boxer.
    lda #$1f
    sta $d017                   // Double the height of both boxers and overlay.
    ldx $02a6                   // KERNAL PAL/NTSC flag.
    lda #60
    cpx #0
    beq !storeRate+
    lda #50
!storeRate:
    sta framesPerSecond

newRound:
    lda #40
    sta rockyX
    lda #97
    sta apolloX
    lda #171
    sta rockyY
    lda #165
    sta apolloY
    lda #MAX_HP
    sta rockyHp
    sta apolloHp
    lda #0
    sta rockyRecovery
    sta apolloRecovery
    sta rockyWalk
    sta apolloWalk
    sta framePhase
    sta roundResult
    sta seconds
    lda #3
    sta minutes
    lda framesPerSecond
    sta clockFrames
    jsr drawMessage
    jsr drawClock
    jsr drawHealth
    jsr drawBoxers
    lda #$1f
    sta $d015

fightLoop:
    jsr waitFrame
    jsr readControls
    inc framePhase
    jsr updateRocky
    lda apolloHp
    beq finishRound
    jsr updateApollo
    lda rockyHp
    beq finishRound
    jsr tickClock
    jsr drawBoxers
    jsr drawHealth
    lda minutes
    ora seconds
    bne fightLoop

finishRound:
    lda #0
    sta rockyWalk
    sta apolloWalk
    jsr drawBoxers
    jsr drawHealth
    ldx #3                     // Draw if both have the same health at timeout.
    lda rockyHp
    cmp apolloHp
    beq !showResult+
    ldx #1
    bcs !showResult+
    ldx #2
!showResult:
    stx roundResult
    jsr drawMessage

waitPunchRelease:
    jsr waitFrame
    jsr readControls
    and #PUNCH
    bne waitPunchRelease
waitRetry:
    jsr waitFrame
    jsr readControls
    and #PUNCH
    beq waitRetry
    jmp newRound

waitFrame:
    lda #250
!leave:
    cmp $d012
    beq !leave-
!arrive:
    cmp $d012
    bne !arrive-
    rts

readControls:
    lda #$ff
    sta $dc00
    lda $dc00                   // Joystick in port 2, active low.
    eor #$ff
    and #(MOVE_UP | MOVE_DOWN | MOVE_LEFT | MOVE_RIGHT | PUNCH)
    sta buttons
    lda #$fd
    sta $dc00
    ldy $dc01
    tya
    and #$04                    // A, column 1 row 2.
    bne !checkW+
    lda buttons
    ora #MOVE_LEFT
    sta buttons
!checkW:
    tya
    and #$02                    // W, column 1 row 1.
    bne !checkS+
    lda buttons
    ora #MOVE_UP
    sta buttons
!checkS:
    tya
    and #$20                    // S, column 1 row 5.
    bne !checkD+
    lda buttons
    ora #MOVE_DOWN
    sta buttons
!checkD:
    lda #$fb
    sta $dc00
    lda $dc01
    and #$04                    // D, column 2 row 2.
    bne !checkSpace+
    lda buttons
    ora #MOVE_RIGHT
    sta buttons
!checkSpace:
    lda #$7f
    sta $dc00
    lda $dc01
    and #$10                    // Space, column 7 row 4.
    bne !restore+
    lda buttons
    ora #PUNCH
    sta buttons
!restore:
    lda #$ff
    sta $dc00
    lda buttons
    rts

updateRocky:
    lda rockyRecovery
    beq !depth+
    dec rockyRecovery
!depth:
    ldy #0                     // Count successful moves, not pressed directions.
    lda buttons
    and #(MOVE_UP | MOVE_DOWN)
    cmp #MOVE_UP
    bne !down+
    lda rockyY
    cmp #BACK_EDGE
    beq !sideways+
    dec rockyY
    iny
    jmp !sideways+
!down:
    cmp #MOVE_DOWN
    bne !sideways+
    lda rockyY
    cmp #FRONT_EDGE
    beq !sideways+
    inc rockyY
    iny
!sideways:
    lda buttons
    and #(MOVE_LEFT | MOVE_RIGHT)
    cmp #MOVE_LEFT
    bne !right+
    lda rockyX
    cmp #LEFT_EDGE
    beq !punch+
    dec rockyX
    iny
    jmp !punch+
!right:
    cmp #MOVE_RIGHT
    bne !punch+
    jsr boxerGap
    cmp #MIN_GAP + 1
    bcc !punch+
    inc rockyX
    iny
!punch:
    tya
    beq !storeWalk+
    lda rockyWalk
    jsr advanceWalk
!storeWalk:
    sta rockyWalk
    lda rockyRecovery
    bne !done+
    lda buttons
    and #PUNCH
    beq !done+
    lda #22
    sta rockyRecovery
    jsr checkPunchRange
    bcs !done+
    dec apolloHp
    lda apolloX
    clc
    adc #4
    cmp #RIGHT_EDGE
    bcc !knockback+
    lda #RIGHT_EDGE
!knockback:
    sta apolloX
!done:
    rts

updateApollo:
    lda apolloRecovery
    beq !approach+
    dec apolloRecovery
    lda apolloRecovery
    cmp #40                    // Contact after the wind-up frames.
    bne !done+
    jsr checkPunchRange
    bcs !done+
    dec rockyHp
    lda rockyX
    sec
    sbc #4
    cmp #LEFT_EDGE
    bcs !knockback+
    lda #LEFT_EDGE
!knockback:
    sta rockyX
    rts
!approach:
    jsr checkPunchRange
    bcs !step+
    lda #0
    sta apolloWalk
    lda #49
    sta apolloRecovery
    rts
!step:
    lda framePhase
    and #1
    bne !sideways+
    lda apolloWalk
    jsr advanceWalk
    sta apolloWalk
    lda apolloY
    cmp rockyY
    beq !sideways+
    bcc !stepDown+
    dec apolloY
    jmp !sideways+
!stepDown:
    inc apolloY
!sideways:
    lda framePhase
    and #3
    bne !done+
    jsr boxerGap
    cmp #PUNCH_REACH
    bcc !done+
    dec apolloX
!done:
    rts

boxerGap:
    lda apolloX
    sec
    sbc rockyX
    rts

// Carry is clear when both the horizontal gap and the depth gap are in reach.
checkPunchRange:
    jsr boxerGap
    cmp #PUNCH_REACH
    bcs !done+
    lda apolloY
    sec
    sbc rockyY
    bcs !depth+
    eor #$ff
    adc #1
!depth:
    cmp #PUNCH_DEPTH
!done:
    rts

drawBoxers:
    lda rockyY
    sta $d001
    sta $d003
    lda apolloY
    sta $d005
    sta $d007
    sta $d009
    lda #0
    sta spriteHighBits
    ldx #0
    lda rockyX
    jsr placeBoxer
    ldx #4
    lda apolloX
    jsr placeBoxer
    lda $d004
    sta $d008                   // Apollo's overlay starts at his left half.
    lda spriteHighBits
    and #$04
    asl
    asl
    ora spriteHighBits
    sta $d010

    lda rockyWalk
    jsr walkPose
    ldx rockyRecovery
    cpx #14
    bcc !rockyGuard+
    clc
    adc #2
!rockyGuard:
    sta SPRITE_POINTERS
    clc
    adc #1
    sta SPRITE_POINTERS + 1
    lda apolloWalk
    jsr walkPose
    clc
    adc #4
    ldx apolloRecovery
    cpx #38
    bcc !apolloGuard+
    clc
    adc #2
    iny
!apolloGuard:
    sta SPRITE_POINTERS + 2
    clc
    adc #1
    sta SPRITE_POINTERS + 3
    tya
    clc
    adc #FIRST_APOLLO_SKIN
    sta SPRITE_POINTERS + 4
    rts

advanceWalk:
    cmp #WALK_CYCLE
    bcc !next+
    lda #0
!next:
    clc
    adc #1
    rts

// Each pose group keeps the same order: Rocky guard, Rocky jab,
// Apollo guard, Apollo jab. Pass through the guard legs between strides.
// A is the group's sprite pointer and Y is the offset of its skin mask.
walkPose:
    beq !guard+
    cmp #7
    bcc !longStride+
    cmp #9
    bcc !guard+
    cmp #15
    bcc !shortStride+
!guard:
    ldy #0
    lda #FIRST_BOXER
    rts
!longStride:
    ldy #2
    lda #FIRST_WALK
    rts
!shortStride:
    ldy #4
    lda #FIRST_WALK + 8
    rts

// Convert logical pixels into a 9-bit VIC X coordinate for each sprite half.
placeBoxer:
    asl
    clc
    adc #24
    sta $d000,x
    lda #0
    adc #0
    sta spriteXHigh
    beq !rightHalf+
    lda spriteBits,x
    ora spriteHighBits
    sta spriteHighBits
!rightHalf:
    lda $d000,x
    clc
    adc #24
    sta $d002,x
    lda spriteXHigh
    adc #0
    beq !done+
    lda spriteBits + 2,x
    ora spriteHighBits
    sta spriteHighBits
!done:
    rts

drawHealth:
    ldx #0
!pip:
    cpx rockyHp
    lda #$b0                   // Dark gray for an empty pip.
    bcs !rockyEmpty+
    lda #$70
!rockyEmpty:
    sta ROCKY_HP_CELLS,x
    cpx apolloHp
    lda #$b0
    bcs !apolloEmpty+
    lda #$30
!apolloEmpty:
    sta APOLLO_HP_CELLS,x
    inx
    cpx #MAX_HP
    bne !pip-
    rts

tickClock:
    dec clockFrames
    bne !done+
    lda framesPerSecond
    sta clockFrames
    lda seconds
    bne !subtract+
    dec minutes
    lda #$59
    jmp !update+
!subtract:
    sed
    sec
    sbc #1
    cld
!update:
    sta seconds
    jmp drawClock
!done:
    rts

drawClock:
    ldx #0
    lda minutes
    jsr drawDigit
    ldx #1
    lda seconds
    lsr
    lsr
    lsr
    lsr
    jsr drawDigit
    ldx #2
    lda seconds
    and #$0f
    // Fall through to draw the last digit.
drawDigit:
    sta digitIndex
    lda digitAddressLow,x
    sta colorDestination
    lda digitAddressHigh,x
    sta colorDestination + 1
    lda digitIndex
    asl
    asl
    clc
    adc digitIndex
    tax
    ldy #0
!row:
    lda digitRows,x
    sta (colorDestination),y
    inx
    iny
    cpy #5
    bne !row-
    rts

drawMessage:
    ldx roundResult
    lda messageAddressLow,x
    sta colorSource
    lda messageAddressHigh,x
    sta colorSource + 1
    ldy #0
!copy:
    lda (colorSource),y
    sta HUD_MESSAGE,y
    iny
    cpy #MESSAGE_SIZE
    bne !copy-
    rts

spriteBits: .byte 1,0,2,0,4,0,8
digitAddressLow:
    .byte <(RING_BITMAP + 3 * 320 + 11 * 8 + 2), <(RING_BITMAP + 3 * 320 + 13 * 8 + 2), <(RING_BITMAP + 3 * 320 + 14 * 8 + 2)
digitAddressHigh:
    .byte >(RING_BITMAP + 3 * 320 + 11 * 8 + 2), >(RING_BITMAP + 3 * 320 + 13 * 8 + 2), >(RING_BITMAP + 3 * 320 + 14 * 8 + 2)
messageAddressLow: .fill 4, <(MESSAGE_DATA + i * MESSAGE_SIZE)
messageAddressHigh: .fill 4, >(MESSAGE_DATA + i * MESSAGE_SIZE)
digitRows:
    .byte $54,$44,$44,$44,$54
    .byte $10,$50,$10,$10,$54
    .byte $50,$04,$10,$40,$54
    .byte $50,$04,$10,$04,$50
    .byte $44,$44,$54,$04,$04
    .byte $54,$40,$50,$04,$50
    .byte $14,$40,$54,$44,$54
    .byte $54,$04,$10,$10,$10
    .byte $54,$44,$54,$44,$54
    .byte $54,$44,$54,$04,$50

rockyX: .byte 0
apolloX: .byte 0
rockyHp: .byte 0
apolloHp: .byte 0
rockyRecovery: .byte 0
apolloRecovery: .byte 0
buttons: .byte 0
framePhase: .byte 0
roundResult: .byte 0
minutes: .byte 0
seconds: .byte 0
clockFrames: .byte 0
framesPerSecond: .byte 0
digitIndex: .byte 0
spriteHighBits: .byte 0
spriteXHigh: .byte 0
rockyY: .byte 0
apolloY: .byte 0
rockyWalk: .byte 0
apolloWalk: .byte 0
