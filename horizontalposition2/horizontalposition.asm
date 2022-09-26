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

  ldx #$10    ; black background
  stx COLUBK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initialize variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  lda #40           ; a = 50
  sta P0XPos

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

  sec       ; set Carry FFlag

  sta WSYNC ; Wait for next scanline
  sta HMCLR ; clear old horizontal position

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
  REPEAT 60
    sta WSYNC
  REPEND

  ldy 8
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

  REPEAT 124
    sta WSYNC
  REPEND

Overscan:
  lda #2
  sta VBLANK
  REPEAT 30
    sta WSYNC
  REPEND

  ; decrment Player0 Y position and loop
  lda P0XPos
  cmp #80
  bpl ResetX
  jmp IncrementX
ResetX:
  lda #40
  sta P0XPos
IncrementX:
  inc P0XPos

  jmp StartFrame

; player 0 bitmap
P0Bitmap:
  .byte #%00000000
  .byte #%00010000
  .byte #%00001000
  .byte #%00011100
  .byte #%00110110
  .byte #%00101110
  .byte #%00101110
  .byte #%00111110
  .byte #%00011100

; player 0 color
P0Color:
  .byte #$00
  .byte #$02
  .byte #$02
  .byte #$52
  .byte #$52
  .byte #$52
  .byte #$52
  .byte #$52
  .byte #$52
  .byte #$52

  org $FFFC
  .word Reset
  .word Reset
