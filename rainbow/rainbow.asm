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

  ldx #192
LoopVisible:
  stx COLUBK
  sta WSYNC
  dex
  bne LoopVisible

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
