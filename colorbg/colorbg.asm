  processor 6502
  include "vcs.h"
  include "macro.h"

  seg code
  org $F000   ; defines the origin of the ROM at $F000

  CLEAN_START   ; macro to safely clear the memory
START:

  ; set background to yellow
  lda #$2E  ; load NTSC yellow to A
  sta COLUBK  ; store A to background colow address $09

  jmp START

  org $FFFC
  .word START
  .word START
