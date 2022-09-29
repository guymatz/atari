  processor 6502
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Include required files with register mapping and macros
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  include "vcs.h"
  include "macro.h"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start an uninitialized segment at $80 for var declaration.
;; We have memory from $80 to $FF to work with, minus a few at
;; the end if we use the stack.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  seg.u Variables
  org $80
P0XPos byte  ; sprite X coordinate

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start our ROM code segment starting at $F000.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  seg code
  org $F000   ; defines the origin of the ROM at $F000

Reset:
  CLEAN_START   ; macro to safely clear the memory

  ldx #$80    ; black background
  stx COLUBK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initialize variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ldx #$D0           ; a = 50
  stx COLUPF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start a new frame by configuring VBLANK and VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartFrame:
  lda #2
  sta VBLANK
  sta VSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Display 3 vertical lines of VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  REPEAT 3
    sta WSYNC
  REPEND
  lda #0
  sta VSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set player horizontal position while we are in the VBLANK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  lda P0XPos
  and #$7F
  sta WSYNC ; Wait for next scanline
  sta HMCLR ; clear old horizontal position

  sec       ; set Carry FFlag
DivideLoop:
  sbc #15
  bcs DivideLoop

  eor #7    ; Adjust the remainder in A between -8 & 7
  REPEAT 4
    asl     ; shift left by 4, as HMP0 uses only 4 bits
  REPEND
  sta HMP0  ; set fine position
  sta RESP0 ; reset 15-step brute position
  sta WSYNC ; wait for next scanline
  sta HMOVE ; apply the fine position offset

; Display 35 lines of Vertical Buffer (2 already done above)
  REPEAT 35
    sta WSYNC
  REPEND

  lda #0
  sta VBLANK


; Draw the 60 visisble scanlines
  REPEAT 160
    sta WSYNC
  REPEND

  ldy 17
DrawBitmap:
  lda P0Bitmap,Y  ; load player 0 bitmap slice into A
  sta GRP0        ; set graphics for player 0 slice

  lda P0Color,Y   ; load player 0 color rfom lookup table
  sta COLUP0      ; set color for player 0 slice

  sta WSYNC

  dey
  bne DrawBitmap  ; repeat scnaline until finished

  lda #0
  sta GRP0        ; disable P0 bitmap graphics

  lda #1
  sta PF0
  lda #1
  sta PF1
  sta PF2

  REPEAT 15
    sta WSYNC
  REPEND

  lda #0
  sta PF0
  sta PF1
  sta PF2

Overscan:
  lda #2
  sta VBLANK
  REPEAT 30
    sta WSYNC
  REPEND

CheckP0Up:
  lda #%00010000
  bit SWCHA
  bne CheckP0Down
  ; otherwise . . .
  inc P0XPos

CheckP0Down:
  lda #%00100000
  bit SWCHA
  bne CheckP0Left
  ; otherwise . . .
  dec P0XPos

CheckP0Left:
  lda #%01000000
  bit SWCHA
  bne CheckP0Right
  ; otherwise . . .
  dec P0XPos

CheckP0Right:
  lda #%10000000
  bit SWCHA
  bne NoInput
  ; otherwise . . .
  inc P0XPos

NoInput:
  ;

  jmp StartFrame

; player 0 bitmap
P0Bitmap:
  .byte #%00000000
  .byte #%00010100
  .byte #%00010100
  .byte #%00010100
  .byte #%00010100
  .byte #%00010100
  .byte #%00011100
  .byte #%00011100
  .byte #%01011101
  .byte #%01011101
  .byte #%01011101
  .byte #%01011101
  .byte #%01011101
  .byte #%01111111
  .byte #%01111111
  .byte #%00010000
  .byte #%00011100
  .byte #%00011100

; player 0 color
P0Color:
  .byte #$00
  .byte #$02
  .byte #$02
  .byte #$02
  .byte #$02
  .byte #$02
  .byte #$02
  .byte #$02
  .byte #$02
  .byte #$52
  .byte #$52
  .byte #$52
  .byte #$52
  .byte #$52
  .byte #$52
  .byte #$ee
  .byte #$ee
  .byte #$ee

  org $FFFC
  .word Reset
  .word Reset
