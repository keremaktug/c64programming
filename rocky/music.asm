.const SID = $d400
.const LEAD = SID
.const BASS = SID + 7
.const HARMONY = SID + 14
.const PAL_FRAME_TICKS = 6
.const NTSC_FRAME_TICKS = 5
.const MUSIC_LOOP = $80

initMusic:
    lda #0
    ldx #24
!clear:
    sta SID,x
    dex
    bpl !clear-
    lda #$14
    sta LEAD + 5
    lda #$92
    sta LEAD + 6
    lda #$02
    sta BASS + 5
    lda #$61
    sta BASS + 6
    lda #$15
    sta HARMONY + 5
    lda #$32
    sta HARMONY + 6
    lda #$0c
    sta SID + $18
    lda $02a6                   // KERNAL PAL/NTSC flag.
    beq !ntsc+
    lda #PAL_FRAME_TICKS
    bne !store+
!ntsc:
    lda #NTSC_FRAME_TICKS
!store:
    sta musicFrameTicks
    jsr resetMusicStream
    jmp saveMusicPosition

// The supplied MIDI is stored as timed changes for three monophonic voices.
// A record holds a delay at 300 Hz, a channel mask, then one note per set bit.
// Note zero releases that voice. A zero mask waits, and $80 restarts the stream.
updateMusic:
    lda musicWait
    sec
    sbc musicFrameTicks
    bcc !events+
    beq !events+
    sta musicWait
    rts

!events:
    eor #$ff
    clc
    adc #1
    sta musicBudget
    lda musicPosition
    sta colorSource
    lda musicPosition + 1
    sta colorSource + 1
!event:
    jsr readMusicByte
    cmp #MUSIC_LOOP
    beq !loop+
    sta musicChannelMask
    beq !nextChange+
    ldx #0
!voice:
    lsr musicChannelMask
    bcc !nextVoice+
    jsr playMusicNote
!nextVoice:
    lda musicChannelMask
    beq !nextChange+
    txa
    clc
    adc #7
    tax
    bne !voice-

!loop:
    jsr resetMusicStream
    jmp !advanceTime+
!nextChange:
    jsr readMusicByte
!advanceTime:
    sta musicWait
    lda musicBudget
    sec
    sbc musicWait
    bcc !pending+
    sta musicBudget
    jmp !event-
!pending:
    lda musicWait
    sec
    sbc musicBudget
    sta musicWait
saveMusicPosition:
    lda colorSource
    sta musicPosition
    lda colorSource + 1
    sta musicPosition + 1
    rts

resetMusicStream:
    lda #<rockyTheme
    sta colorSource
    lda #>rockyTheme
    sta colorSource + 1
    jsr readMusicByte
    sta musicWait
    rts

readMusicByte:
    ldy #0
    lda (colorSource),y
    inc colorSource
    bne !done+
    inc colorSource + 1
!done:
    cmp #0
    rts

playMusicNote:
    jsr readMusicByte
    beq !release+
    tay
    lda $02a6
    beq !ntsc+
    lda musicPalLow,y
    sta SID,x
    lda musicPalHigh,y
    jmp !trigger+
!ntsc:
    lda musicNtscLow,y
    sta SID,x
    lda musicNtscHigh,y
!trigger:
    sta SID + 1,x
    lda musicWaveforms,x
    ora #1
    sta SID + 4,x
    rts
!release:
    lda musicWaveforms,x
    sta SID + 4,x
    rts

musicPosition: .word 0
musicWait: .byte 0
musicFrameTicks: .byte 0
musicBudget: .byte 0
musicChannelMask: .byte 0
musicWaveforms: .byte $20, 0, 0, 0, 0, 0, 0, $10, 0, 0, 0, 0, 0, 0, $10

.function sidWord(note, sidClock) {
    .return round(440 * pow(2, (note - 69) / 12.0) * 16777216 / sidClock)
}

musicPalLow: .fill 96, <sidWord(i, 985248)
musicPalHigh: .fill 96, >sidWord(i, 985248)
musicNtscLow: .fill 96, <sidWord(i, 1022727)
musicNtscHigh: .fill 96, >sidWord(i, 1022727)
