  processor 6502
  seg Code        ; Define a new segment named Code
  org $F000       ; Define the origin of the ROM Code at address $F000
Start:

  cld
  lda #1  ; Load the A register with the decimal value 1
  ldx #2  ; Load the X register with the decimal value 2
  ldy #3  ; Load the Y register with the decimal value 3
  inx     ; Increment X
  iny     ; Increment Y
  ; Increment A
  clc
  adc #1
  dex     ; Decrement X
  dey     ; Decrement Y
  ; Decrement A
  sec
  sbc #1


  org $FFFC       ; End the ROM by adding required values to memory
  .word Start     ; Put 2 bytes with the reset address
  .word Start     ; Put 2 bytes with the break address
