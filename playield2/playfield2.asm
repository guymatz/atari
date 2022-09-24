  processor 6502
  include "vcs.h"
  include "macro.h"

  seg code
  org $F000   ; defines the origin of the ROM at $F000

  CLEAN_START   ; macro to safely clear the memory
Start:

  ldx #$80
  stx COLUBK
  ldx #$1c
  stx COLUPF

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

  ; reflect the PF
  ldx #%00000001
  stx CTRLPF

  ; top border
  ldx #0
  stx PF0
  stx PF1
  stx PF2
  REPEAT 7
    sta WSYNC
  REPEND

  ; top PF Border
  ldx #%01100000 ; <--  first 4 bits only
  stx PF0
  ldx #%11111111 ; -->
  stx PF1
  ldx #%11111111 ; <--
  stx PF2
  REPEAT 7
    sta WSYNC
  REPEND

  ; sides of PF Border
  ldx #%01100000
  stx PF0
  ldx #%00000000
  stx PF1
  ldx #%10000000
  stx PF2
  REPEAT 164
    sta WSYNC
  REPEND

  ; bottom PF Border
  ldx #%11100000
  stx PF0
  ldx #%11111111
  stx PF1
  stx PF2
  REPEAT 7
    sta WSYNC
  REPEND

  ; bottom border
  ldx #0
  stx PF0
  stx PF1
  stx PF2
  REPEAT 7
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

  jmp StartFrame;


  org $FFFC
  .word Start
  .word Start
