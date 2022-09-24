  processor 6502
  include "vcs.h"
  include "macro.h"

  seg.u Variables
  org $80
P0Height ds 1 ; defines one byte for aplayer 0 hieght
P1Height ds 1 ; defines one byte for aplayer 0 hieght

  seg code
  org $F000   ; defines the origin of the ROM at $F000

Reset:
  CLEAN_START   ; macro to safely clear the memory

  ldx #$80
  stx COLUBK
  ldx #%1111
  stx COLUPF

  lda #10     ; a = 10
  sta P0Height  ; set player0 height to 10
  sta P1Height

  ; set the TIA registers for the colors of P0 and P1
  lda #$40
  sta COLUP0
  lda #$C6
  sta COLUP1

  ; CTRLPF D1 set to 1 means (score)
  ldy #%00000010
  sty CTRLPF

  ;; turn on VBLANK & VSYNC
ResetFrame:
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
VisibleScanLines:
  REPEAT 10
    sta WSYNC
  REPEND

; Display 10 scanline for the scoreboard number
; Pulls data from an array off bytes deffined at NumberBitmap
  ldy #0
ScoreboardLoop:
  lda N_2_Bitmap,Y
  sta PF1
  sta WSYNC
  iny
  cpy #10
  bne ScoreboardLoop

  lda #0
  sta PF1 ; disable playfield

  ; draw 50 empty scanlines between scoreboard and player
  REPEAT 50
    sta WSYNC
  REPEND

; display 10 scanlines for the player 0 graphics
; pulls data from an array of bytes defined at PlayerBitmap
  ldy #0
Player0Loop
  lda PlayerBitmap,Y
  sta GRP0
  sta WSYNC
  iny
  cpy P0Height
  bne Player0Loop

  lda #0
  sta GRP0; disable player 0 graphics

; display 10 scanlines for the player 1 graphics
; pulls data from an array of bytes defined at PlayerBitmap
  ldy #0
Player1Loop
  lda PlayerBitmap,Y
  sta GRP1
  sta WSYNC
  iny
  cpy P1Height
  bne Player1Loop

  lda #0
  sta GRP1; disable player 1 graphics

; draw remaining 102
  REPEAT 102
    sta WSYNC
  REPEND

  ; bottom 30
  lda #2
  sta VBLANK
  REPEAT 30
    sta WSYNC
  REPEND
  lda #0
  sta VBLANK

  jmp ResetFrame;

; player bitmap
  org $FFE8
PlayerBitmap:
  .byte #%01111110
  .byte #%11111111
  .byte #%10011001
  .byte #%10011001
  .byte #%11111111
  .byte #%11111111
  .byte #%11111111
  .byte #%10111101
  .byte #%11000011
  .byte #%01111110

; player bitmap
  org $FFF2
N_2_Bitmap:
  .byte #%11111111
  .byte #%11111111
  .byte #%00000011
  .byte #%00000011
  .byte #%11111111
  .byte #%11111111
  .byte #%11000000
  .byte #%11000000
  .byte #%11111111
  .byte #%11111111

  org $FFFC
  .word Reset
  .word Reset
