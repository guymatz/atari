  processor 6502
  include "vcs.h"
  include "macro.h"

  seg code
  org $F000   ; defines the origin of the ROM at $F000

START:
  ;CLEAN_START   ; macro to safely clear the memory

  ; set background to yellow
  lda #$1E  ; load NTSC yellow to A
  sta COLUBK  ; store A to background colow address $09

  jmp START

  org $FFFC
  .word START
  .word START
