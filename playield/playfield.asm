  processor 6502
  include "vcs.h"
  include "macro.h"

  seg code
  org $F000   ; defines the origin of the ROM at $F000

  CLEAN_START   ; macro to safely clear the memory
Start:

  ;; turn on VBLANK & VSYNC
NextFrame:
  lda #2
  sta VBLANK
  sta VSYNC

  sta WSYNC
  sta WSYNC
  sta WSYNC

  lda #0
  sta VSYNC

  ldx #37
LoopVBlank:
  sta WSYNC
  dex
  bne LoopVBlank

  lda #0
  sta VBLANK

  ldy 7
  ldx #88

  ; blue
  ldx #88
  stx $80
  ; yellow
  ldx #18
  stx $81
  ; border loops
  ldx #7
  stx $82
  ; main loops
  ldx #164
  stx $82

  ldx $80
  ldy $81
LoopTopBK:
  stx COLUBK
  sta WSYNC
  dey
  bne LoopTopBK

  ldx $1111111
  stx $PF0
  stx $PF1
  stx $PF2
  ldy $82
LoopTopPF:
  stx COLUBK
  sta WSYNC
  dey
  bne LoopTopPF

  lda #92
  sta VBLANK

  ldx #30
LoopOverscan:
  sta WSYNC
  dex
  bne LoopOverscan

  jmp NextFrame;


  org $FFFC
  .word Start
  .word Start
