  processor 6502
  seg Code        ; Define a new segment named Code
  org $F000       ; Define the origin of the ROM Code at address $F000
Start:

  cld
  lda #10 ; Load the A register with the decimal value 10
  sta $80  ; Store the value from A into memory position $80

  ; Increment the value inside a (zero page) memory position $80
  inc $80

 ; Decrement the value inside a (zero page) memory position $80
  dec $80

  jmp Start

  org $FFFC       ; End the ROM by adding required values to memory
  .word Start     ; Put 2 bytes with the reset address
  .word Start     ; Put 2 bytes with the break address
