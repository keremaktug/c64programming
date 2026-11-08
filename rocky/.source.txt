BasicUpstart2(start)

.const BITMAP_LAYOUT = "Bitmap=$0000, ScreenRam=$1f40, ColorRam=$2328, BackgroundColor=$2710"
.var title = LoadBinary("rocky-c64.bin", BITMAP_LAYOUT)
.var ring = LoadBinary("ring-stage.bin", BITMAP_LAYOUT)

.const RING_SCREEN = $4c00
.const RING_BITMAP = $6000
.const FIGHT_GFX = $5400
.const BITMAP_CONTROL = $18     // Multicolor, 40 columns, no horizontal scroll.
.const TITLE_LOGO_RASTER = 212  // Black gap between the portrait and logo.
.const TITLE_WAVE_START = 214
.const TITLE_WAVE_END = 241
.const TITLE_WAVE_LENGTH = 24
.const TITLE_WAVE_HOLD_INTERVAL = 5
.const TITLE_RESTORE_RASTER = 252

.const colorSource = $fb
.const colorDestination = $fd
.const scanKeyboard = $ff9f
.const getKey = $ffe4

start:
    sei
    lda #0
    sta $c6                     // Clear pending BASIC keyboard input.
    sta titleWavePhase
    lda #TITLE_WAVE_HOLD_INTERVAL
    sta titleWaveHold
    lda #$03                    // VIC bank 0.
    ldx #>titleColors
    ldy #title.getBackgroundColor()
    jsr showScene

waitForSpace:
    lda #TITLE_LOGO_RASTER
!waitLogo:
    cmp $d012
    bne !waitLogo-
    lda #0
    sta $d021                   // The scroll reveals black at the left edge.
    ldx titleWavePhase
    ldy #TITLE_WAVE_START
!waveLine:
    lda titleWaveScroll,x
!waitLine:
    cpy $d012
    bne !waitLine-
    sta $d016
    inx
    iny
    cpy #TITLE_WAVE_END
    beq !nextPhase+
    tya
    and #7
    cmp #3                      // A VIC badline with the current Y scroll.
    bne !waveLine-

    // Set the next badline's offset after the logo pixels on this line.
    // This avoids losing the write while the VIC fetches the screen row.
    .for (var cyclePair = 0; cyclePair < 10; cyclePair++) {
        nop
    }
    bit $00
    lda titleWaveScroll,x
    sta $d016
    inx
    iny
    jmp !waveLine-

!nextPhase:
    dec titleWaveHold           // Repeat one phase every five frames.
    bne !advancePhase+
    lda #TITLE_WAVE_HOLD_INTERVAL
    sta titleWaveHold
    jmp !waitRestore+
!advancePhase:
    inc titleWavePhase
    lda titleWavePhase
    cmp #TITLE_WAVE_LENGTH
    bcc !waitRestore+
    lda #0
    sta titleWavePhase

!waitRestore:
    lda #TITLE_RESTORE_RASTER
!waitBorder:
    cmp $d012
    bne !waitBorder-
    lda #BITMAP_CONTROL
    sta $d016                   // Restore the portrait's settings in the border.
    lda #title.getBackgroundColor()
    sta $d021

readTitleInput:
    jsr scanKeyboard
    jsr getKey
    cmp #$20
    beq enterRing
    lda #$ff
    sta $dc00
    lda $dc00
    and #$10
    beq enterRing
    jmp waitForSpace

enterRing:
    lda #$02                    // VIC bank 1.
    ldx #>ringColors
    ldy #ring.getBackgroundColor()
    jsr showScene
    jmp beginFight

// A selects the VIC bank, X is the color data page, Y is the background color.
showScene:
    sta colorSource
    lda #$0b
    sta $d011                   // Blank the screen while setting up the VIC-II.

    lda $dd02
    ora #$03
    sta $dd02
    lda $dd00
    and #$fc
    ora colorSource
    sta $dd00

    lda #$38
    sta $d018                   // Screen at bank + $0c00, bitmap at bank + $2000.
    lda #BITMAP_CONTROL
    sta $d016
    lda #$00
    sta $d020                   // Black border.
    sty $d021

    sta colorSource
    sta colorDestination
    stx colorSource + 1
    lda #$d8
    sta colorDestination + 1
    ldy #0
    ldx #3

copyColorPage:
    lda (colorSource),y
    sta (colorDestination),y
    iny
    bne copyColorPage
    inc colorSource + 1
    inc colorDestination + 1
    dex
    bne copyColorPage

copyLastColors:
    lda (colorSource),y
    sta (colorDestination),y
    iny
    cpy #232                    // 1000 bytes total, including the three pages.
    bne copyLastColors

    lda #$3b
    sta $d011                   // Enable bitmap mode and turn the display on.
    rts

titleWavePhase: .byte 0
titleWaveHold: .byte 0
titleWaveScroll:
    .fill TITLE_WAVE_LENGTH + TITLE_WAVE_END - TITLE_WAVE_START, BITMAP_CONTROL + round(3.5 + 3.5 * sin(i * 2 * PI / TITLE_WAVE_LENGTH))

* = $0c00 "Title screen RAM"
    .fill title.getScreenRamSize(), title.getScreenRam(i)
* = $1000 "Title color data"
titleColors:
    .fill title.getColorRamSize(), title.getColorRam(i)
* = $1400 "Fight logic"
#import "fight.asm"
* = $2000 "Title bitmap"
    .fill title.getBitmapSize(), title.getBitmap(i)

* = RING_SCREEN "Ring screen RAM"
    .fill ring.getScreenRamSize(), ring.getScreenRam(i)
* = $5000 "Ring color data"
ringColors:
    .fill ring.getColorRamSize(), ring.getColorRam(i)
* = FIGHT_GFX "Boxer sprites, fight messages, walk poses and Apollo skin masks"
    .import binary "fight-gfx.bin"
* = RING_BITMAP "Ring bitmap"
    .fill ring.getBitmapSize(), ring.getBitmap(i)
