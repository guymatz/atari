  processor 6502
  seg Code        ; Define a new segment named Code
  org $F000       ; Define the origin of the ROM Code at address $F000
Start:

  sei
  cld
  ldx #0
  txa
  tay
.CLEAR_STACK    dex
  txs
  pha
  bne .CLEAR_STACK

  org $FFFC       ; End the ROM by adding required values to memory
  .word Start     ; Put 2 bytes with the reset address
  .word Start     ; Put 2 bytes with the break address
