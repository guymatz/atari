  processor 6502
  seg Code        ; Define a new segment named Code
  org $F000       ; Define the origin of the ROM Code at address $F000
Start:

  lda #15   ; load 15 into A
  tax       ; Transfer the value from A to X
  tay       ; Transfer the value from A to Y
  txa       ; Transfer the value from X to A
  tya       ; Transfer the value from Y to A

  ldx #6    ; Load X with the decimal value 6
  ;txa       ; Transfer the value from X to Y by first transferring X to A
  ;tay       ; Transfer the value from X to Y by then transferring A to Y
  stx $80
  ldy $80

  jmp Start


  org $FFFC       ; End the ROM by adding required values to memory
  .word Start     ; Put 2 bytes with the reset address
  .word Start     ; Put 2 bytes with the break address
