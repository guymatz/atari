  processor 6502
  include "vcs.h"
  include "macro.h"

  seg.u Variables
  org $80

P0Height byte     ; player sprite height
Player0YPos byte  ; player sprite Y coordinate

  seg code
  org $F000   ; defines the origin of the ROM at $F000

Reset:
  CLEAN_START   ; macro to safely clear the memory

  ldx #$00    ; black background
  stx COLUBK

  lda #180     ; a = 180
  sta Player0YPos   ; Player 0 Y Position = 180

  lda #9
  sta P0Height  ; set player0 height to 9

  ;; turn on VBLANK & VSYNC
StartFrame:
  lda #2
  sta VBLANK
  sta VSYNC

  REPEAT 3
    sta WSYNC
  REPEND
  lda #0
  sta VSYNC

  REPEAT 37
    sta WSYNC
  REPEND

  lda #0
  sta VBLANK


; Draw the 192 visisble scanlines
  ldx #192
ScanLine:
  txa             ; transfer current line number to A
  sec             ; Set Carry flag (For subtraction)
  sbc Player0YPos   ; subtract sprite Y coordinate
  cmp P0Height    ; is current line - P0Pos < height of sprite?
  bcc LoadBitmap  ; if so, goto LoadBitmap
  lda #0

LoadBitmap:
  tay             ; transfer current sprite line number to y
  lda P0Bitmap,Y  ; load player 0 bitmap slice into A
  sta WSYNC       ; wait for next scanline
  sta GRP0        ; set graphics for player 0 slice
  lda P0Color,Y   ; load player 0 color rfom lookup table
  sta COLUP0      ; set color for player 0 slice
  dex
  bne ScanLine    ; next scanline ^^

Overscan:
  lda #2
  sta VBLANK
  REPEAT 30
    sta WSYNC
  REPEND

  ; decrment Player0 Y position and loop
  dec Player0YPos
  jmp StartFrame

; player 0 bitmap
P0Bitmap:
  .byte #%00000000
  .byte #%00101000
  .byte #%01110100
  .byte #%11111010
  .byte #%11111010
  .byte #%11111010
  .byte #%11111110
  .byte #%01101100
  .byte #%00110000

; player 0 color
P0Color:
  .byte #$00
  .byte #$40
  .byte #$40
  .byte #$40
  .byte #$40
  .byte #$42
  .byte #$42
  .byte #$44
  .byte #$D2

  org $FFFC
  .word Reset
  .word Reset
